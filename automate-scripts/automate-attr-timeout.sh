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

#Usage Function
Usage () {
	echo "sh automate-attr-timeout.sh <intermediate_results> <Time in secs> <outputDir>"
	echo "<intermediate_results>	: Whether script need to capture statistics at regular intervals specified by time(in secs)"
	echo "<Time in secs>		: Capture the statistics at this period of time"
	echo "<outputDir>		: Store the statistics at this location"
	echo "Example			: sh automate.sh [1|0] [5] /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/"
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

#HARDCODED (Considering only writeback cache)
WORKLOAD_DIR="/home/bvangoor/fuse-playground/workloads/writeback-cache-fuse"
MOUNT_POINT="/tmp/bigfileset/00000001/"
COMMON_FOLDER="/home/bvangoor/fuse-playground/kernel-statistics/Stat-files/"
KERNEL_STATS_FOLDER="/sys/fs/fuse/connections/"
USER_STATS_FILE="/tmp/user_stats.txt" #HardCoded

#Clean up the output directory
rm -rf $COMMON_FOLDER/*

iterations_strt=61440
iterations_end=61440

max_write=32768

#Ranging the Attr Val times from 0.25 to 128 secs
for attr_val in 0.25 0.50 1 2 4 8 16 32 64 128
do
	export MAX_WRITE=$max_write 
	export ATTR_VAL=$attr_val

	#Ranging the Iterations from 1, 2 ... 32768 (1MB, 2MB to 32 GB)
	for (( iterations=$iterations_strt; iterations<=$iterations_end; iterations=iterations*2 ))
	do
		for (( runcount=1; runcount<=5; runcount=runcount+1 ))
		do
			echo "Started running experiment with max_write $max_write with 1MB iterations $iterations and attr_val $attr_val (run : $runcount)"
			#Filebench FileName
			FILE_NAME="seq-write-attrval-$iterations.f"

			#Run the Filebench script
			filebench -f $WORKLOAD_DIR/$FILE_NAME > filebench.out &
			PROC_ID=$!
			sleep 5 #play safe
			DEV_ID=`stat --format "%d" $MOUNT_POINT`
			pid=`ps -ef | grep $MOUNT_POINT | grep -v "grep" | awk '{print $2}'`
			count=0
	
			echo "Device ID $DEV_ID"
			echo "Fuse User LIB PID $pid"
	
			#Generate the intermediate statistics
			while kill -0 "$PROC_ID" > /dev/null 2>&1; do
				sleep $sleeptime
				if [ $intermediate_results -eq 1 ]
				then
					count=$(expr "$count" + "$sleeptime")
					outputfolder=$COMMON_FOLDER/Stat-files-$max_write-$iterations-$count-$runcount
					`mkdir -p $outputfolder`
					kill -s USR1 $pid
					cp -r $KERNEL_STATS_FOLDER/$DEV_ID/background_queue_requests_timings $outputfolder/
					cp -r $KERNEL_STATS_FOLDER/$DEV_ID/pending_queue_requests_timings $outputfolder/
					cp -r $KERNEL_STATS_FOLDER/$DEV_ID/processing_queue_requests_timings $outputfolder/
					cp -r $KERNEL_STATS_FOLDER/$DEV_ID/queue_lengths $outputfolder/
					cp -r $USER_STATS_FILE $outputfolder/
					echo "Done copying to $outputfolder"
				fi
			done

			#Generate the stats after the completion
			outputfolder=$COMMON_FOLDER/Stat-files-$max_write-$iterations-$attr_val-Final-$runcount
			`mkdir -p $outputfolder`
			kill -s USR1 $pid
			cp -r $KERNEL_STATS_FOLDER/$DEV_ID/background_queue_requests_timings $outputfolder/
			cp -r $KERNEL_STATS_FOLDER/$DEV_ID/pending_queue_requests_timings $outputfolder/
			cp -r $KERNEL_STATS_FOLDER/$DEV_ID/processing_queue_requests_timings $outputfolder/
			cp -r $KERNEL_STATS_FOLDER/$DEV_ID/queue_lengths $outputfolder/
			cp -r $KERNEL_STATS_FOLDER/$DEV_ID/writeback_req_sizes $outputfolder/
			cp -r $USER_STATS_FILE $outputfolder/
			cp -r filebench.out $outputfolder/
			echo "Done copying to $outputfolder"

			#Removing Anything under mount point
			rm -rf /tmp/bigfileset/00000001/00000001
	
			#Unmount the Fuse F/S
			fusermount -u $MOUNT_POINT
			echo "Completed running experiment with max_write $max_write with 1MB iterations $iterations and attr_val $attr_val (run : $runcount)"
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
	./parse-output $COMMON_FOLDER/$name
	echo "Completed Parsing $COMMON_FOLDER/$name"
done < "$filename"

exit 0
