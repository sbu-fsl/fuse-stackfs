#!/bin/bash

#Check the user of the script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

file="parse-cpu-stats"
if [ -f $file ]
then
	echo "$file found."
else
	echo "$file not found. Please run make and retry."
	exit 1
fi

file="parse-disk-stats"
if [ -f $file ]
then
        echo "$file found."
else
        echo "$file not found. Please check and retry."
        exit 1
fi

file="parse-filebench"
if [ -f $file ]
then
        echo "$file found."
else
        echo "$file not found. Please check and retry."
        exit 1
fi

#Usage Function
Usage () {
	echo "sh automate-no-fuse.sh <intermediate_results> <Time in secs> <outputDir>"
	echo "<intermediate_results>	: Whether script need to capture statistics at regular intervals specified by time(in secs)"
	echo "<Time in secs>		: Capture the statistics at this period of time"
	echo "<outputDir>		: Store the statistics at this location"
	echo "Example			: sh automate.sh 1|0 5 /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/"
	exit 0
}

#Arguments Check
if [ $# -ne 2 -a $# -ne 3 ]
then
	Usage
fi

if [ $# -eq 2 ]
then
	intermediate_results=$1
	outputDir=$2
	sleeptime=1
else
	intermediate_results=$1
	sleeptime=$2
	outputDir=$3
fi

#HARDCODED
TYPE="SSD"
WORKLOAD_DIR="/home/bvangoor/fuse-playground/workloads/No-fuse/$TYPE/"
MOUNT_POINT="/home/bvangoor/EXT4_FS/"
COMMON_FOLDER="/home/bvangoor/fuse-playground/kernel-statistics/Stat-files/"

#work_load_types=( sq rd cr preall ) 	# Sequential and random workloads
#work_load_ops=( wr re de )   	# write and read workloads
work_load_types=( sq )
work_load_ops=( re )
io_sizes=( 4KB ) 	# I/O sizes
threads=( 32 )		# No. of threads
count=1 		# No. of times you are repeating the experiment

#Clean up the output directory
rm -rf $COMMON_FOLDER/*

: '
/dev/sdb is the HDD
/dev/sdd is the SSD
'

#iterate over W_L_T
for wlt in "${work_load_types[@]}"
do
	if [ "$wlt" == "cr" ]
	then
		work_load_ops=( wr )
		io_sizes=( 4KB )
		files=( 4M )
	elif [ "$wlt" == "preall" ]
	then
		work_load_ops=( re de )
		io_sizes=( 4KB )
	fi
	for wlo in "${work_load_ops[@]}"
	do
		###############################################
		for thrd in "${threads[@]}"
		do
			########################################
			if [ "$wlt" == "sq" -a "$wlo" == "wr" ]
			then
				files=( $thrd )
			elif [ "$wlt" == "rd" -a "$wlo" == "wr" ]
			then
				files=( 1 )
			elif [ "$wlt" == "sq" -a "$wlo" == "re" ]
			then
				if [ $thrd -eq 1 ]
				then
					files=( 1 )
				elif [ $thrd -eq 32 ]
				then
					files=( 32 )
				fi
			elif [ "$wlt" == "rd" -a "$wlo" == "re" ]
			then
				files=( 1 )
				count=3
			elif [ "$wlt" == "cr" ]
			then
				files=( 4M )
				io_sizes=( 4KB )
				count=3
			elif [ "$wlt" == "preall" -a "$wlo" == "re" ]
			then
				files=( 1M ) #(SSD)
			elif [ "$wlt" == "preall" -a "$wlo" == "de" ]
			then
				files=( 2M ) #(SSD)
			fi
			for file in "${files[@]}"
			do
				for io_size in "${io_sizes[@]}"
				do
					#file-sq-wr-4KB-1th-1f.f
					filename="file-$wlt-$wlo-$io_size-${thrd}th-${file}f.f"
					for (( runcount=1; runcount<=$count; runcount=runcount+1 ))
					do
#						echo $runcount : $filename
						echo "Started Running experiment $wlt $wlo $io_size $thrd threads on $file files and runcount : $runcount"
						#Unmount and format every time we run the experiment
						umount /home/bvangoor/EXT4_FS/
						# Change accordingly for HDD(sdb) and SDD(sdd) (very important, failing this will alter the results)
						if [ "$TYPE" == "HDD" ]
						then
							mkfs.ext4 -F -E  lazy_itable_init=0,lazy_journal_init=0 -O ^uninit_bg /dev/sdb > /dev/null
							mount -t ext4 /dev/sdb /home/bvangoor/EXT4_FS/
						else
							mkfs.ext4 -F -E  lazy_itable_init=0,lazy_journal_init=0 -O ^uninit_bg /dev/sdd > /dev/null
							mount -t ext4 /dev/sdd /home/bvangoor/EXT4_FS/
						fi

						echo "" > /sys/kernel/debug/tracing/trace
						# enable ext4 trace points
						echo 1 > /sys/kernel/debug/tracing/events/filemap/filemap_generic_read_iter_difference/enable

						cat /sys/kernel/debug/tracing/trace_pipe > /tmp/trace.out &
						PROC_ID_TRACING=$!

						#Run the Filebench script
						filebench -f $WORKLOAD_DIR/$filename > filebench.out &
						PROC_ID=$!

						rm -rf cpustats.txt
						#Generate CPU stats using /proc/stat
						sh cpu_stats_wrapper.sh $sleeptime >> cpustats.txt &
						CPUSTAT_PID=$!

						rm -rf diskstats.txt
						#Generate Disk stats using /proc/diskstats
						sh disk_stats_wrapper.sh $sleeptime >> diskstats.txt &
						DISKSTAT_PID=$!

						echo "File bench PID : $PROC_ID"
						echo "CPU Stat PID : $CPUSTAT_PID"
						echo "DISK Stat PID : $DISKSTAT_PID"

						# wait until the filebench process completes
						while kill -0 "$PROC_ID" > /dev/null 2>&1;
						do
							# check whether Filebench exited or not
							sleep 1
						done

						kill -9 $PROC_ID_TRACING
						# kill the CPU stats generating script
						kill -9 $CPUSTAT_PID
						kill -9 $DISKSTAT_PID

						# Create the output folder to copy the stats
						outputfolder=$COMMON_FOLDER/Stat-files-$wlt-$wlo-$io_size-${thrd}th-${file}f-$runcount/
						`mkdir -p $outputfolder`
						#copy the stats
						cp -r filebench.out $outputfolder/
						cp -r cpustats.txt $outputfolder/
						cp -r diskstats.txt $outputfolder/
						cp /tmp/trace.out $outputfolder/
						#remove them (to be safe)
#						rm -rf $MOUNT_POINT/*
						rm -rf filebench.out
						rm -rf cpustats.txt
						rm -rf diskstats.txt
						#Unmount and mount again (to be safe)
#						umount $MOUNT_POINT
#						mount -t ext4 /dev/sdb $MOUNT_POINT

						echo 0 > /sys/kernel/debug/tracing/events/filemap/filemap_generic_read_iter_difference/enable

						echo "Completed Running experiment $wlt $wlo $io_size $thrd threads on $file files and runcount : $runcount"
					done
#					echo "====================="
				done
			done
		done
	done
done

#Change the Permisions
chmod -R 777 $COMMON_FOLDER/*

ls $COMMON_FOLDER > temp.txt

filename="temp.txt"
while read -r line
do
	name="$line"
	./parse-cpu-stats $COMMON_FOLDER/$name
	./parse-disk-stats $COMMON_FOLDER/$name
	./parse-filebench $COMMON_FOLDER/$name
	echo "Completed Parsing $COMMON_FOLDER/$name"
done < "$filename"

exit 0
