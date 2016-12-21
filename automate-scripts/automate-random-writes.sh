#!/bin/bash
#Random writes
#Check the user of the script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

file="parse-output"
if [ -f $file ]
then
	echo "$file found."
else
	echo "$file not found. Please run make and retry."
	exit 1
fi

#Usage Function
Usage () {
	echo "sh automate-random-writes.sh <fuseoption> <intermediate_results> <Time in secs> <outputDir>"
	echo "<fuseoption>		: 0, 1 or 2 for default, writeback_cache and big_writes respectively"		
	echo "<intermediate_results>	: Whether script need to capture statistics at regular intervals specified by time(in secs)"
	echo "<Time in secs>		: Capture the statistics at this period of time"
	echo "<outputDir>		: Store the statistics at this location"
	echo "Example			: sh automate-random-writes.sh [0|1|2] [1|0] [5] /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/"
	exit 0
}

#Arguments Check
if [ $# -ne 3 -a $# -ne 4 ]
then
	Usage
fi

if [ $# -eq 3 ]
then
	fuse_option=$1
	intermediate_results=$2
	outputDir=$3
	sleeptime=1
else
	fuse_option=$1
	intermediate_results=$2
	sleeptime=$3
	outputDir=$4
fi

#HARDCODED
if [ $fuse_option -eq 0 ]
then
	WORKLOAD_DIR="/home/bvangoor/fuse-playground/workloads/default-fuse"
elif [ $fuse_option -eq 1 ]
then
	WORKLOAD_DIR="/home/bvangoor/fuse-playground/workloads/writeback-cache-fuse"
else
	WORKLOAD_DIR="/home/bvangoor/fuse-playground/workloads/big-writes-fuse"
fi

MOUNT_POINT="/tmp/bigfileset/00000001/"
COMMON_FOLDER="/home/bvangoor/fuse-playground/kernel-statistics/Stat-files/"
KERNEL_STATS_FOLDER="/sys/fs/fuse/connections/"
USER_STATS_FILE="/tmp/user_stats.txt" #HardCoded
WATCH_DIR="/tmp/" #Hardcoded
STACKFS="/home/bvangoor/fuse-playground/StackFS_LowLevel/StackFS_ll"
FILESIZE=64424509440 #60GB in Bytes
#Clean up the output directory
rm -rf $COMMON_FOLDER/*

if [ $fuse_option -eq 0 ]
then
	max_write_strt=4096
	max_write_end=4096
	io_size_strt=1048576
	io_strt_end=1048576
else
	max_write_strt=32768
	max_write_end=67108864
	io_size_strt=4096
	io_size_end=1048576
fi

#Ranging the I/O size from 1 MB (1048576) to 64MB (67108864)
for (( io_size=$io_size_strt; io_size<=$io_size_end; io_size=io_size*2 ))
do
	#Ranging the MAX WRITES from 32KB (32768) to 64MB (67108864), increasing by factor of 2
	for (( max_write=$max_write_strt; max_write<=$max_write_end; max_write=max_write*2 ))
	do
		if [ $fuse_option -ne 0 ]
		then
			export MAX_WRITE=$max_write
		fi

		#Ranging the Iterations from 1, 2 ... 32768 (1MB, 2MB to 32 GB)
		iterations=$(( $FILESIZE / $io_size ))
		for (( runcount=1; runcount<=1; runcount=runcount+1 ))
		do
			echo "Started running experiment with max_write $max_write with $io_size B I/O, iterations $iterations (run : $runcount)"
			
			#Filebench FileName
			FILE_NAME="random-write-$io_size-$iterations.f"

			#Tweak for pre alloc file 
			rm -rf $MOUNT_POINT/*
			rm -rf /home/bvangoor/EXT4_FS/*
			$STACKFS -o max_write=1048576 -o big_writes --statsdir=$WATCH_DIR -r /home/bvangoor/EXT4_FS/ $MOUNT_POINT > /dev/null &

			#Run the Filebench script
			filebench -f $WORKLOAD_DIR/$FILE_NAME > filebench.out &
			PROC_ID=$!
			sleep 2
			DEV_ID=`stat --format "%d" $MOUNT_POINT`
			pid=`ps -ef | grep $MOUNT_POINT | grep -v "grep" | awk '{print $2}'`
			count=0
	
			echo "Device ID $DEV_ID"
			echo "Fuse User LIB PID $pid"
	
			#Generate CPU stats using iostat
			iostat -y -c $sleeptime 100000 > cpustats.txt &
			CPUSTAT_PID=$!
	
			#generate Disk stats using iostat (for block device /dev/sdb)
			iostat -y -d -x -p sdb $sleeptime 100000 > diskstats.txt &
			DISKSTAT_PID=$!
	
			#generate MemInfo and context switches info
			sh memstats.sh $sleeptime > memstats.txt &
			MEMSTAT_PID=$!
	
			#Generate the intermediate statistics
			while kill -0 "$PROC_ID" > /dev/null 2>&1; 
			do
				sleep $sleeptime
				count=$(expr "$count" + "$sleeptime")
				outputfolder=$COMMON_FOLDER/Stat-files-$io_size-$max_write-$iterations-$count-$runcount
				`mkdir -p $outputfolder`
				cp -r $KERNEL_STATS_FOLDER/$DEV_ID/wbc_flush_pages_ios $outputfolder/
				echo "Done copying to $outputfolder"
				if [ $intermediate_results -eq 1 ]
				then
					count=$(expr "$count" + "$sleeptime")
					outputfolder=$COMMON_FOLDER/Stat-files-$io_size-$max_write-$iterations-$count-$runcount
					`mkdir -p $outputfolder`
					rm -rf $USER_STATS_FILE
					kill -s USR1 $pid
					cp -r $KERNEL_STATS_FOLDER/$DEV_ID/background_queue_requests_timings $outputfolder/
					cp -r $KERNEL_STATS_FOLDER/$DEV_ID/pending_queue_requests_timings $outputfolder/
					cp -r $KERNEL_STATS_FOLDER/$DEV_ID/processing_queue_requests_timings $outputfolder/
					cp -r $KERNEL_STATS_FOLDER/$DEV_ID/queue_lengths $outputfolder/
					cp -r $KERNEL_STATS_FOLDER/$DEV_ID/write_cache_pages_return $outputfolder/
					while [ ! -f "$USER_STATS_FILE" ]
					do
						echo "$USER_STATS_FILE Not found, waiting"
						inotifywait -qq -e close_write -t 2 $WATCH_DIR
					done
					cp -r $USER_STATS_FILE $outputfolder/
					echo "Done copying to $outputfolder"
				fi
			done

			#Kill the CPU, DISK, and MEM Stat Procs
			kill -9 $CPUSTAT_PID
			kill -9 $DISKSTAT_PID
			kill -9 $MEMSTAT_PID
			pid=`ps -ef | grep $MOUNT_POINT | grep -v "grep" | awk '{print $2}'`
			echo "Fuse User LIB PID $pid"
			#Generate the stats after the completion
			outputfolder=$COMMON_FOLDER/Stat-files-$io_size-$max_write-$iterations-Final-$runcount
			`mkdir -p $outputfolder`
			rm -rf $USER_STATS_FILE
			kill -s USR1 $pid
			cp -r $KERNEL_STATS_FOLDER/$DEV_ID/background_queue_requests_timings $outputfolder/
			cp -r $KERNEL_STATS_FOLDER/$DEV_ID/pending_queue_requests_timings $outputfolder/
			cp -r $KERNEL_STATS_FOLDER/$DEV_ID/processing_queue_requests_timings $outputfolder/
			cp -r $KERNEL_STATS_FOLDER/$DEV_ID/queue_lengths $outputfolder/
			cp -r $KERNEL_STATS_FOLDER/$DEV_ID/writeback_req_sizes $outputfolder/
			cp -r $KERNEL_STATS_FOLDER/$DEV_ID/write_cache_pages_return $outputfolder/
			cp -r $KERNEL_STATS_FOLDER/$DEV_ID/wbc_flush_pages_ios $outputfolder/
			while [ ! -f "$USER_STATS_FILE" ]
			do
				echo "$USER_STATS_FILE Not found, waiting"
				inotifywait -qq -e close_write -t 2 $WATCH_DIR
			done
			cp -r $USER_STATS_FILE $outputfolder/
			cp -r filebench.out $outputfolder/
			cp -r cpustats.txt $outputfolder/
			cp -r diskstats.txt $outputfolder/
			cp -r memstats.txt $outputfolder/

			echo "Done copying to $outputfolder"

			#Removing Anything under mount point
			rm -rf /tmp/bigfileset/00000001/00000001
			rm -rf filebench.out
			rm -rf cpustats.txt
			rm -rf diskstats.txt
			rm -rf memstats.txt
	
			#Unmount the Fuse F/S
			fusermount -u $MOUNT_POINT
			echo "Completed running experiment with max_write $max_write with $sz_in_MB MB I/O, iterations $iterations (run : $runcount)"
			rm -rf wbc_flush_pages_ios
			for (( tempcount=1; tempcount<=$count; tempcount=tempcount+1 ))
			do
				tempfilename=$COMMON_FOLDER/Stat-files-$io_size-$max_write-$iterations-$tempcount-$runcount/wbc_flush_pages_ios
				cat $tempfilename >> wbc_flush_pages_ios
				rm -rf $COMMON_FOLDER/Stat-files-$io_size-$max_write-$iterations-$tempcount-$runcount
			done
			cat $outputfolder/wbc_flush_pages_ios >> wbc_flush_pages_ios
			mv wbc_flush_pages_ios $outputfolder/wbc_flush_pages_ios
		done
	done
done
#Change the Permisions
chmod -R 777 $COMMON_FOLDER/*

ls $COMMON_FOLDER | grep -i "\-Final\-" > temp.txt

filename="temp.txt"
while read -r line
do
	name="$line"
	echo "$COMMON_FOLDER/$name"
	./parse-output $COMMON_FOLDER/$name
	echo "Completed Parsing $COMMON_FOLDER/$name"
done < "$filename"

exit 0
