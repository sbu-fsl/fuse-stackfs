#!/bin/bash

Usage () {
	echo "bash get_cpu_stats.sh <sleeptime>"
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
	previousDate=$(date +%s%N | cut -b1-13)
	previousStats=$(cat /proc/stat)
	echo $previousDate
	sleep $sleepDurationSeconds
	currentDate=$(date +%s%N | cut -b1-13)
	currentStats=$(cat /proc/stat)    
	echo $currentDate

	cpus=$(echo "$currentStats" | grep -P 'cpu' | awk -F " " '{print $1}')

	for cpu in $cpus
	do
		currentLine=$(echo "$currentStats" | grep "$cpu ")
		user=$(echo "$currentLine" | awk -F " " '{print $2}')
		nice=$(echo "$currentLine" | awk -F " " '{print $3}')
		system=$(echo "$currentLine" | awk -F " " '{print $4}')
		idle=$(echo "$currentLine" | awk -F " " '{print $5}')
		iowait=$(echo "$currentLine" | awk -F " " '{print $6}')
		irq=$(echo "$currentLine" | awk -F " " '{print $7}')
		softirq=$(echo "$currentLine" | awk -F " " '{print $8}')
		steal=$(echo "$currentLine" | awk -F " " '{print $9}')
		guest=$(echo "$currentLine" | awk -F " " '{print $10}')
		guest_nice=$(echo "$currentLine" | awk -F " " '{print $11}')

		previousLine=$(echo "$previousStats" | grep "$cpu ")
		prevuser=$(echo "$previousLine" | awk -F " " '{print $2}')
		prevnice=$(echo "$previousLine" | awk -F " " '{print $3}')
		prevsystem=$(echo "$previousLine" | awk -F " " '{print $4}')
		previdle=$(echo "$previousLine" | awk -F " " '{print $5}')
		previowait=$(echo "$previousLine" | awk -F " " '{print $6}')
		previrq=$(echo "$previousLine" | awk -F " " '{print $7}')
		prevsoftirq=$(echo "$previousLine" | awk -F " " '{print $8}')
		prevsteal=$(echo "$previousLine" | awk -F " " '{print $9}')
		prevguest=$(echo "$previousLine" | awk -F " " '{print $10}')
		prevguest_nice=$(echo "$previousLine" | awk -F " " '{print $11}')    

		PrevIdle=$((previdle + previowait))
		Idle=$((idle + iowait))

		PrevNonIdle=$((prevuser + prevnice + prevsystem + previrq + prevsoftirq + prevsteal))
		NonIdle=$((user + nice + system + irq + softirq + steal))

		PrevTotal=$((PrevIdle + PrevNonIdle))
		Total=$((Idle + NonIdle))

		totald=$((Total - PrevTotal))
		idled=$((Idle - PrevIdle))

		CPU_Percentage=$(awk "BEGIN {print ($totald - $idled)/$totald*100}")

		if [[ "$cpu" == "cpu" ]]; then
			echo "total "$CPU_Percentage
		else
			echo $cpu" "$CPU_Percentage
		fi
	done
done
