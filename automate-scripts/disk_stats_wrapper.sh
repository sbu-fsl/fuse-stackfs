#!/bin/bash

Usage () {
        echo "sh disk_stats_wrapper.sh <sleeptime>"
        echo "<sleeptime> : Capture the statistics at this period of time interval"
        exit 0
}

if [ $# -ne 1 ]
then
        Usage
fi

sleepDurationSeconds=$1

while true;
do
	echo "======================"
	#Change accordingly for HDD(sdb) and SSD(sdd)
	cat /proc/diskstats | grep -i sdd
	sleep $sleepDurationSeconds
done
