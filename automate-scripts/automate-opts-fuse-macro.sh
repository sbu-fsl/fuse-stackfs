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

file="parse-fuse-stats"
if [ -f $file ]
then
        echo "$file found."
else
        echo "$file not found. Please check and retry."
        exit 1
fi

#Usage Function
Usage () {
        echo "sh automate-opts-fuse-macro.sh <intermediate_results> <Time in secs> <outputDir>"
        echo "<intermediate_results>    : Whether script need to capture statistics at regular intervals specified by time(in secs)"
        echo "<Time in secs>            : Capture the statistics at this period of time"
        echo "<outputDir>               : Store the statistics at this location"
        echo "Example                   : sh automate-opts-fuse-macro.sh 1|0 5 /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/"
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
WORKLOAD_DIR="/home/bvangoor/fuse-playground/workloads/opts-fuse/$TYPE/"
MOUNT_POINT="/home/bvangoor/COM_DIR/"
FUSE_MOUNT_POINT="/home/bvangoor/COM_DIR/FUSE_EXT4_FS/"
COMMON_FOLDER=$outputDir
KERNEL_STATS_FOLDER="/sys/fs/fuse/connections/"
WATCH_DIR="/tmp/" #Hardcoded
USER_STATS_FILE="/tmp/user_stats.txt" #HardCoded
USER_TRACE_FILE="/tmp/trace_stackfs.log" #HardCoded
#KERNEL_TRACE_FILE="/tmp/trace.out"

filenames[0]="Web-server-100th"
filenames[1]="Mail-server-16th"
filenames[2]="File-server-50th"

count=3                         # No. of times you are repeating the experiment

#Clean up the output directory
rm -rf $COMMON_FOLDER/*

: '
multi line 
comments
useful
'

for workfile in "${filenames[@]}"
do
        filename="${workfile}.f"
        for (( runcount=1; runcount<=$count; runcount=runcount+1 ))
        do
                echo "Started Running experiment $workfile : $runcount"
                #Unmount and format every time we run the experiment
                fusermount -u $FUSE_MOUNT_POINT
                rm -rf $USER_TRACE_FILE
                umount $MOUNT_POINT
                #Change accordingly for HDD(sdb) and SSD(sdd)
		
		if [ "$TYPE" == "HDD" ]
		then
			mkfs.ext4 -F -E  lazy_itable_init=0,lazy_journal_init=0 -O ^uninit_bg /dev/sdb > /dev/null
			mount -t ext4 /dev/sdb $MOUNT_POINT
		elif [ "$TYPE" == "SSD" ]
               	then
			mkfs.ext4 -F -E  lazy_itable_init=0,lazy_journal_init=0 -O ^uninit_bg /dev/sdd > /dev/null
			mount -t ext4 /dev/sdd $MOUNT_POINT
		fi


#		echo "" > /sys/kernel/debug/tracing/trace
		#Enable Fuse kernel tracing options
#		echo 1 > /sys/kernel/debug/tracing/events/fuse/fuse_file_write_pages_begin/enable
#		echo 1 > /sys/kernel/debug/tracing/events/fuse/fuse_file_write_pages_end/enable
#		echo 1 > /sys/kernel/debug/tracing/events/fuse/fuse_file_write_pages_flush_amount/enable
#		echo 1 > /sys/kernel/debug/tracing/events/fuse/fuse_file_read_pages_begin/enable
#		echo 1 > /sys/kernel/debug/tracing/events/fuse/fuse_file_read_pages_end/enable
#		echo 1 > /sys/kernel/debug/tracing/events/fuse/fuse_file_read_pages_req_amount/enable

#		cat /sys/kernel/debug/tracing/trace_pipe > /tmp/trace.out &
#		PROC_ID_TRACING=$!

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

		#Disable Fuse kernel tracing options
#		echo 0 > /sys/kernel/debug/tracing/events/fuse/fuse_file_write_pages_begin/enable
#		echo 0 > /sys/kernel/debug/tracing/events/fuse/fuse_file_write_pages_end/enable
#		echo 0 > /sys/kernel/debug/tracing/events/fuse/fuse_file_write_pages_flush_amount/enable
#		echo 0 > /sys/kernel/debug/tracing/events/fuse/fuse_file_read_pages_begin/enable
#		echo 0 > /sys/kernel/debug/tracing/events/fuse/fuse_file_read_pages_end/enable
#		echo 0 > /sys/kernel/debug/tracing/events/fuse/fuse_file_read_pages_req_amount/enable

                # kill the CPU stats generating script
                kill -9 $CPUSTAT_PID
                kill -9 $DISKSTAT_PID
#		kill -9 $PROC_ID_TRACING

                # Create the output folder to copy the stats
                outputfolder=$COMMON_FOLDER/Stat-files-${workfile}-$runcount/
                `mkdir -p $outputfolder`
                #copy the stats
                DEV_ID=`stat --format "%d" $FUSE_MOUNT_POINT`
                pid=`ps -ef | grep $FUSE_MOUNT_POINT | grep -v "grep" | awk '{print $2}'`
                rm -rf $USER_STATS_FILE
                kill -s USR1 $pid

                cp -r $KERNEL_STATS_FOLDER/$DEV_ID/background_queue_requests_timings $outputfolder/
                cp -r $KERNEL_STATS_FOLDER/$DEV_ID/pending_queue_requests_timings $outputfolder/
                cp -r $KERNEL_STATS_FOLDER/$DEV_ID/processing_queue_requests_timings $outputfolder/
		cp -r $KERNEL_STATS_FOLDER/$DEV_ID/writeback_req_sizes $outputfolder/
                while [ ! -f "$USER_STATS_FILE" ]
                do
                        echo "$USER_STATS_FILE Not found, waiting"
                        inotifywait -qq -e close_write -t 2 $WATCH_DIR
                done

                if [ -f "$USER_TRACE_FILE" ]
                then
                        cp -r $USER_TRACE_FILE $outputfolder/
                fi

                cp -r $USER_STATS_FILE $outputfolder/
#		cp -r $KERNEL_TRACE_FILE $outputfolder/
                cp -r filebench.out $outputfolder/
                cp -r cpustats.txt $outputfolder/
                cp -r diskstats.txt $outputfolder/
                #Remove the files after copying
                rm -rf filebench.out
                rm -rf cpustats.txt
                rm -rf diskstats.txt
                rm -rf $USER_STATS_FILE
                rm -rf $USER_TRACE_FILE
#		rm -rf $KERNEL_TRACE_FILE
                echo "Completed Running experiment $workfile : $runcount"
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
        ./parse-fuse-stats $COMMON_FOLDER/$name
        echo "Completed Parsing $COMMON_FOLDER/$name"
done < "$filename"

exit 0
