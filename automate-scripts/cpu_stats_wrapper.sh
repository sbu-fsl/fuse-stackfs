#!/bin/bash

Usage () {
        echo "sh cpu_stats_wrapper.sh <sleeptime>"
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
	cat /proc/stat
	sleep $sleepDurationSeconds
done
