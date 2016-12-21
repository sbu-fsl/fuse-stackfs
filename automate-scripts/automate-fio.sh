#!/bin/bash

#Check the user of the script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#Usage Function
Usage () {
        echo "sh automate-fio.sh <outputDir>"
        echo "<outputDir>               : Store the statistics at this location"
        echo "Example                   : sh automate-fio.sh /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/"
        exit 0
}

#Arguments Check
if [ $# -ne 1 ]
then
        Usage
fi

TYPE="SSD"
WORKLOAD_DIR="/home/bvangoor/fuse-playground/workloads/fio-scripts/"
outputDir=$1
COMMON_FOLDER=$outputDir

threads=( 1 2 4 8 16 32 64 )
count=1			# No. of times you are repeating the experiment
run_time=600		# keep run time as 10 mins
filename=rand_read.fio	# filename is constant (as of now)

#Clean up the output directory
rm -rf $COMMON_FOLDER/*

for thrdcnt in "${threads[@]}"
do
	for (( runcount=1; runcount<=$count; runcount=runcount+1 ))
	do
		echo "started running experiment $filename on $TYPE with $thrdcnt threads"
		if [ "$TYPE" == "HDD" ]
		then
			mkfs.ext4 -F -E  lazy_itable_init=0,lazy_journal_init=0 -O ^uninit_bg /dev/sdb > /dev/null
			NUMJOBS=$thrdcnt HD_TYPE=sdb RUN_TIME=$run_time fio $WORKLOAD_DIR/$filename > fio.out &
			PROC_ID=$!
		elif [ "$TYPE" == "SSD" ]
		then
			mkfs.ext4 -F -E  lazy_itable_init=0,lazy_journal_init=0 -O ^uninit_bg /dev/sdd > /dev/null
			NUMJOBS=$thrdcnt HD_TYPE=sdd RUN_TIME=$run_time fio $WORKLOAD_DIR/$filename > fio.out &
			PROC_ID=$!
		fi
		echo "Fio PID : $PROC_ID"
		# wait until the fio process completes
		while kill -0 "$PROC_ID" > /dev/null 2>&1;
		do
			# check whether Fio exited or not
			sleep 1
		done
		# Create the output folder to copy the stats
		outputfolder=$COMMON_FOLDER/Stat-files-rand-read-disk-$thrdcnt-$runcount/
		`mkdir -p $outputfolder`
		cp -r fio.out $outputfolder/

		#Remove the files after copying
		rm -rf fio.out

		echo "completed running experiment $filename on $TYPE with $thrdcnt threads"
	done
done

#Change the Permisions
chmod -R 777 $COMMON_FOLDER/*

ls $COMMON_FOLDER > temp.txt

filename="temp.txt"
while read -r line
do
	name="$line"
	./parse-fio $COMMON_FOLDER/$name
	echo "Completed Parsing $COMMON_FOLDER/$name"
done < "$filename"

exit 0
