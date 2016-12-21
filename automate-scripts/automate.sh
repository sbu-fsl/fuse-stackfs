#!/bin/bash

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

file="parse-bdi-stats"
if [ -f $file ]
then
        echo "$file found."
else
        echo "$file not found. Please run make and retry."
        exit 1
fi

file="parse-tracefile-pause"
if [ -f $file ]
then
        echo "$file found."
else
        echo "$file not found. Please run make and retry."
        exit 1
fi

#Usage Function
Usage () {
	echo "sh automate.sh <fuseoption> <intermediate_results> <Time in secs> <outputDir>"
	echo "<fuseoption>		: 0, 1 or 2 for default, writeback_cache and big_writes respectively"		
	echo "<intermediate_results>	: Whether script need to capture statistics at regular intervals specified by time(in secs)"
	echo "<Time in secs>		: Capture the statistics at this period of time"
	echo "<outputDir>		: Store the statistics at this location"
	echo "Example			: sh automate.sh [0|1|2] [1|0] [5] /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/"
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
BDI_STATS_FOLDER="/sys/kernel/debug/bdi/"
USER_STATS_FILE="/tmp/user_stats.txt" #HardCoded
USER_TRACE_FILE="/tmp/trace_stackfs.log" #HardCoded
WATCH_DIR="/tmp/" #Hardcoded

#Clean up the output directory
rm -rf $COMMON_FOLDER/*

if [ $fuse_option -eq 0 ] # default Case
then
	max_write_strt=4096
	max_write_end=4096
	iterations_strt=61440
	iterations_end=61440
	io_size_strt=1048576
	io_strt_end=1048576
elif [ $fuse_option -eq 1 ]  # Write back cache case
then
	max_write_strt=32768
	max_write_end=67108864
	iterations_strt=61440
	iterations_end=61440
	io_size_strt=1048576
	io_size_end=1048576
	bdi_max_ratio_strt=0
	bdi_max_ratio_end=0
else			    # Big writes cache
	max_write_strt=1048576
	max_write_end=1048576
	iterations_strt=61440
	iterations_end=61440
	io_size_strt=1048576
        io_size_end=1048576
	bdi_max_ratio_strt=0
	bdi_max_ratio_end=0
fi
#MAX ratio fix to 1
#Ranging the I/O size from 1 MB (1048576) to 64MB (67108864)
for (( bdi_max_ratio=$bdi_max_ratio_strt; bdi_max_ratio<=$bdi_max_ratio_end; bdi_max_ratio=bdi_max_ratio+10 ))
do
if [ $bdi_max_ratio -eq 0 ]
then
	bdi_max_ratio=1
fi
#bdi_min_ratio=0
if [ $bdi_max_ratio -eq 100 ]
then
	bdi_max_ratio=99
fi
bdi_min_ratio=$bdi_max_ratio
for (( io_size=$io_size_strt; io_size<=$io_size_end; io_size=io_size*2 ))
do
	#Ranging the MAX WRITES from 32KB (32768) to 64MB (67108864), increasing by factor of 2
	for (( max_write=$max_write_strt; max_write<=$max_write_end; max_write=max_write*2 ))
	do
		if [ $fuse_option -ne 0 ]
		then
			export MAX_WRITE=$max_write
		fi
		export BDI_MIN_RATIO=$bdi_min_ratio
		export BDI_MAX_RATIO=$bdi_max_ratio
		#Ranging the Iterations from 1, 2 ... 32768 (1MB, 2MB to 32 GB)
		for (( iterations=$iterations_strt; iterations<=$iterations_end; iterations=iterations*2 ))
		do
			sz_in_MB=$(( $io_size / 1048576 ))
			for (( runcount=1; runcount<=2; runcount=runcount+1 ))
			do
				echo "Started running experiment with max_write $max_write with $sz_in_MB MB I/O, iterations $iterations, BDI min,max ratio $bdi_min_ratio,$bdi_max_ratio (run : $runcount)"
				#Filebench FileName
				FILE_NAME="seq-write-$io_size-$iterations.f"
				
#				echo "" > /sys/kernel/debug/tracing/trace
				#enable writeback complte tracing
#				echo 1 > /sys/kernel/debug/tracing/events/writeback/writeback_bdi_register/enable
#				echo 1 > /sys/kernel/debug/tracing/events/writeback/balance_dirty_pages_debug/enable
				#enable filemap write getxattr
#				echo 1 > /sys/kernel/debug/tracing/events/filemap/filemap_getxattr_start/enable
#				echo 1 > /sys/kernel/debug/tracing/events/filemap/filemap_getxattr_end/enable

				#enable fuse file write iter
#				echo 1 > /sys/kernel/debug/tracing/events/fuse/fuse_file_write_iter_begin/enable
#				echo 1 > /sys/kernel/debug/tracing/events/fuse/fuse_file_write_iter_end/enable
#				echo 1 > /sys/kernel/debug/tracing/events/fuse/queue_lengths/enable


				#Unmount and format every time we run the experiment
				umount /home/bvangoor/EXT4_FS/
				mkfs.ext4 -F -E  lazy_itable_init=0,lazy_journal_init=0 -O ^uninit_bg /dev/sdb > /dev/null
				mount -t ext4 /dev/sdb /home/bvangoor/EXT4_FS/
				echo "Done Formating"

				#For kernel flusher thread start and end
				echo 1 > /sys/kernel/debug/tracing/events/writeback/writeback_pages_before_written/enable
				echo 1 > /sys/kernel/debug/tracing/events/writeback/writeback_pages_written/enable

				#For write_pages end (no need of start)
				#echo 1 > /sys/kernel/debug/tracing/events/writeback/writeback_single_inode_start/enable
				echo 1 > /sys/kernel/debug/tracing/events/writeback/writeback_single_inode/enable

				cat /sys/kernel/debug/tracing/trace_pipe > /tmp/trace.out &
				PROC_ID_TRACING=$!

				#Run the Filebench script
				filebench -f $WORKLOAD_DIR/$FILE_NAME > filebench.out &
				PROC_ID=$!
				# Removing the statistics logic as I don't need for this experiment
#				sleep 2
#				DEV_ID=`stat --format "%d" $MOUNT_POINT`
#				pid=`ps -ef | grep $MOUNT_POINT | grep -v "grep" | awk '{print $2}'`
#				count=0
	
				#Generate CPU stats using /proc/stat
				bash get_cpu_stats.sh $sleeptime > cpustats.txt &
				CPUSTAT_PID=$!

				#generate Disk stats using iostat (for block device /dev/sdb)
#				iostat -y -d -x -p sdb $sleeptime 100000 > diskstats.txt &
#				DISKSTAT_PID=$!
	
				# generate MemInfo and context switches info
#				sh memstats.sh $sleeptime > memstats.txt &
#				MEMSTAT_PID=$!

#				echo "Device ID $DEV_ID"
#				echo "Fuse User LIB PID $pid"
#				echo "CPU Stats ID $CPUSTAT_PID"
#				echo "Disk Stats ID $DISKSTAT_PID"
#				echo "Memory Stats ID $MEMSTAT_PID"

				#Generate the intermediate statistics
				while kill -0 "$PROC_ID" > /dev/null 2>&1; do
					sleep $sleeptime
#					count=$(expr "$count" + "$sleeptime")
#					outputfolder=$COMMON_FOLDER/Stat-files-$io_size-$max_write-$iterations-$count-$runcount
#					`mkdir -p $outputfolder`
#					cp -r $KERNEL_STATS_FOLDER/$DEV_ID/wbc_flush_pages_ios $outputfolder/
#					cp -r $BDI_STATS_FOLDER/0\:$DEV_ID/stats $outputfolder/bdi-stats.txt
#					echo "Done copying to $outputfolder"
#					if [ $intermediate_results -eq 1 ]
#					then
#						count=$(expr "$count" + "$sleeptime")
#						outputfolder=$COMMON_FOLDER/Stat-files-$io_size-$max_write-$iterations-$count-$runcount
#						`mkdir -p $outputfolder`
#						rm -rf $USER_STATS_FILE
#						kill -s USR1 $pid
#						cp -r $KERNEL_STATS_FOLDER/$DEV_ID/background_queue_requests_timings $outputfolder/
#						cp -r $KERNEL_STATS_FOLDER/$DEV_ID/pending_queue_requests_timings $outputfolder/
#						cp -r $KERNEL_STATS_FOLDER/$DEV_ID/processing_queue_requests_timings $outputfolder/
#						cp -r $KERNEL_STATS_FOLDER/$DEV_ID/queue_lengths $outputfolder/
#						cp -r $KERNEL_STATS_FOLDER/$DEV_ID/write_cache_pages_return $outputfolder/
#						while [ ! -f "$USER_STATS_FILE" ]
#						do
##							echo "$USER_STATS_FILE Not found, waiting"
#							inotifywait -qq -e close_write -t 2 $WATCH_DIR
#						done
#						cp -r $USER_STATS_FILE $outputfolder/
#						echo "Done copying to $outputfolder"
#					fi
				done

				#disable writeback tracing
				echo 0 > /sys/kernel/debug/tracing/events/writeback/enable

				#disable writeback tracing
				#echo 0 > /sys/kernel/debug/tracing/events/writeback/enable
#				echo 0 > /sys/kernel/debug/tracing/events/writeback/writeback_bdi_register/enable
#				echo 0 > /sys/kernel/debug/tracing/events/writeback/balance_dirty_pages_debug/enable
#				echo 0 > /sys/kernel/debug/tracing/events/writeback/balance_dirty_pages_pause_start/enable
#				echo 0 > /sys/kernel/debug/tracing/events/writeback/balance_dirty_pages_pause_end/enable

				#disable filemap traces
#				echo 0 > /sys/kernel/debug/tracing/events/filemap/filemap_getxattr_start/enable
#				echo 0 > /sys/kernel/debug/tracing/events/filemap/filemap_getxattr_end/enable

				#disable fuse traces
#				echo 0 > /sys/kernel/debug/tracing/events/fuse/fuse_file_write_iter_begin/enable
#				echo 0 > /sys/kernel/debug/tracing/events/fuse/fuse_file_write_iter_end/enable
#				echo 0 > /sys/kernel/debug/tracing/events/fuse/queue_lengths/enable

				kill -9 $PROC_ID_TRACING
				#Kill the CPU, DISK, and MEM Stat Procs
	                        kill -9 $CPUSTAT_PID
#	                        kill -9 $DISKSTAT_PID
#       		        kill -9 $MEMSTAT_PID
				DEV_ID=`stat --format "%d" $MOUNT_POINT`
				pid=`ps -ef | grep $MOUNT_POINT | grep -v "grep" | awk '{print $2}'`
				#Generate the stats after the completion
				outputfolder=$COMMON_FOLDER/Stat-files-$io_size-$max_write-$iterations-$bdi_min_ratio-$bdi_max_ratio-Final-$runcount
				`mkdir -p $outputfolder`
				rm -rf $USER_STATS_FILE
				kill -s USR1 $pid
				cp -r $KERNEL_STATS_FOLDER/$DEV_ID/background_queue_requests_timings $outputfolder/
				cp -r $KERNEL_STATS_FOLDER/$DEV_ID/pending_queue_requests_timings $outputfolder/
				cp -r $KERNEL_STATS_FOLDER/$DEV_ID/processing_queue_requests_timings $outputfolder/
#				cp -r $KERNEL_STATS_FOLDER/$DEV_ID/queue_lengths $outputfolder/
#				cp -r $KERNEL_STATS_FOLDER/$DEV_ID/writeback_req_sizes $outputfolder/
#				cp -r $KERNEL_STATS_FOLDER/$DEV_ID/write_cache_pages_return $outputfolder/
#				cp -r $KERNEL_STATS_FOLDER/$DEV_ID/wbc_flush_pages_ios $outputfolder/
#				cp -r $BDI_STATS_FOLDER/0\:$DEV_ID/stats $outputfolder/bdi-stats.txt
				while [ ! -f "$USER_STATS_FILE" ]
				do
					echo "$USER_STATS_FILE Not found, waiting"
					inotifywait -qq -e close_write -t 2 $WATCH_DIR
				done
				cp -r $USER_STATS_FILE $outputfolder/
				if [ -f "$USER_TRACE_FILE" ]
				then
					cp -r $USER_TRACE_FILE $outputfolder/
				fi
				rm -rf $USER_TRACE_FILE
				cp -r filebench.out $outputfolder/
				cp -r cpustats.txt $outputfolder/
#				cp -r diskstats.txt $outputfolder/
#				cp -r memstats.txt $outputfolder/
				cp /tmp/trace.out $outputfolder/

#				grep "fuse_file_write_iter_begin:" $outputfolder/trace.out | awk '{print $4}' | awk '{split($0, a, ":"); print a[1]}' >  $outputfolder/write_iter_begin_times
#				grep "fuse_file_write_iter_end:" $outputfolder/trace.out | awk '{print $4}' | awk '{split($0, a, ":"); print a[1]}' >  $outputfolder/write_iter_end_times

#				grep "filemap_getxattr_start:" $outputfolder/trace.out | awk '{print $4}' | awk '{split($0, a, ":"); print a[1]}' >  $outputfolder/getxattr_begin_times
#				grep "filemap_getxattr_end:" $outputfolder/trace.out | awk '{print $4}' | awk '{split($0, a, ":"); print a[1]}' >  $outputfolder/getxattr_end_times

#				echo "Done copying to $outputfolder"

				#Removing Anything under mount point
				rm -rf /tmp/bigfileset/00000001/00000001
				rm -rf filebench.out
				rm -rf cpustats.txt
#				rm -rf diskstats.txt
#				rm -rf memstats.txt
#				rm -rf /tmp/trace.out

				#Unmount the Fuse F/S
				fusermount -u $MOUNT_POINT
				echo "Completed running experiment with max_write $max_write with $sz_in_MB MB I/O, iterations $iterations, BDI min,max ratio $bdi_min_ratio,$bdi_max_ratio (run : $runcount)"
#				rm -rf wbc_flush_pages_ios
#				rm -rf bdi-stats.txt
#				for (( tempcount=1; tempcount<=$count; tempcount=tempcount+1 ))
#				do
#					tempfilename=$COMMON_FOLDER/Stat-files-$io_size-$max_write-$iterations-$tempcount-$runcount/wbc_flush_pages_ios
#					cat $tempfilename >> wbc_flush_pages_ios
#					tempfilename=$COMMON_FOLDER/Stat-files-$io_size-$max_write-$iterations-$tempcount-$runcount/bdi-stats.txt
#					cat $tempfilename >> bdi-stats.txt
#					rm -rf $COMMON_FOLDER/Stat-files-$io_size-$max_write-$iterations-$tempcount-$runcount
#				done
#				cat $outputfolder/wbc_flush_pages_ios >> wbc_flush_pages_ios
#				cat $outputfolder/bdi-stats.txt >> bdi-stats.txt
#				mv wbc_flush_pages_ios $outputfolder/wbc_flush_pages_ios
#				mv bdi-stats.txt $outputfolder/bdi-stats.txt
			done
		done
	done
done
if [ $bdi_max_ratio -eq 1 ]
then
	bdi_max_ratio=0
fi
done
#Change the Permisions
chmod -R 777 $COMMON_FOLDER/*

ls $COMMON_FOLDER | grep -i "\-Final\-" > temp.txt

filename="temp.txt"
while read -r line
do
	name="$line"
#	echo "$COMMON_FOLDER/$name"
	./parse-output $COMMON_FOLDER/$name
	./parse-tracefile-kernel-flusher $COMMON_FOLDER/$name
#	./parse-bdi-stats $COMMON_FOLDER/$name
#	./parse-tracefile-pause $COMMON_FOLDER/$name
#	echo "Completed Parsing $COMMON_FOLDER/$name"
done < "$filename"
exit 0
