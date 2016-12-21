#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

MOUNT_POINT="/tmp/bigfileset/00000001/"
COMMON_FOLDER="/home/bvangoor/fuse-playground/kernel-statistics/Stat-files/"
KERNEL_STATS_FOLDER="/sys/fs/fuse/connections/"
USER_STATS_FILE="/tmp/user_stats.txt" #HardCoded
USER_TRACE_FILE="/tmp/trace_stackfs.log" #HardCoded
DEV_ID=`stat --format "%d" $MOUNT_POINT`

pid=`ps -ef | grep $MOUNT_POINT | grep -v "grep" | awk '{print $2}'`

#generate the user file stats file at "/tmp/user_stats.txt"
rm -rf $USER_STATS_FILE
kill -s USR1 $pid

#Copy them to kernel stats, user stats to common folder
rm -rf $COMMON_FOLDER/*
cp -r $KERNEL_STATS_FOLDER/$DEV_ID/background_queue_requests_timings $COMMON_FOLDER/
cp -r $KERNEL_STATS_FOLDER/$DEV_ID/pending_queue_requests_timings $COMMON_FOLDER/
cp -r $KERNEL_STATS_FOLDER/$DEV_ID/processing_queue_requests_timings $COMMON_FOLDER/
cp -r $KERNEL_STATS_FOLDER/$DEV_ID/queue_lengths $COMMON_FOLDER/
cp -r $KERNEL_STATS_FOLDER/$DEV_ID/writeback_req_sizes $COMMON_FOLDER/
cp -r $KERNEL_STATS_FOLDER/$DEV_ID/write_cache_pages_return $COMMON_FOLDER/
cp -r $KERNEL_STATS_FOLDER/$DEV_ID/wbc_flush_pages_ios $COMMON_FOLDER/
while [ ! -f "$USER_STATS_FILE" ]
do
	echo "$USER_STATS_FILE Not found, waiting"
	inotifywait -qq -e close_write -t 2 $WATCH_DIR
done
cp -r $USER_STATS_FILE $COMMON_FOLDER/

if [ -f "$USER_TRACE_FILE" ]
then
        cp -r $USER_TRACE_FILE $COMMON_FOLDER/
fi

#Remove the trace file so that next attaempt will have new file generated
rm -rf $USER_TRACE_FILE

chmod -R 777 $COMMON_FOLDER/*

#Call some parse cpp which can write in Human readable form
./parse-output $COMMON_FOLDER/

#Unmount the Fuse F/S
fusermount -u $MOUNT_POINT
