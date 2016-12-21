#!/bin/bash

TYPE="SSD"
WORKLOAD_DIR="/home/bvangoor/fuse-playground/workloads/simple-experiments/$TYPE/"
MOUNT_POINT="/home/bvangoor/COM_DIR/"
outputDir=$1
COMMON_FOLDER=$outputDir

counts=( 1 2 4 8 16 32 64 )             # No. of times you are repeating the experiment

#Clean up the output directory
rm -rf $COMMON_FOLDER/*

for count in "${counts[@]}"
do
	filename="file-sq-re-4KB-${count}th-${count}f.f"
	echo " Running $filename"
	umount $MOUNT_POINT
	if [ "$TYPE" == "HDD" ]
	then
		mkfs.ext4 -F -E  lazy_itable_init=0,lazy_journal_init=0 -O ^uninit_bg /dev/sdb > /dev/null
		mount -t ext4 /dev/sdb $MOUNT_POINT
	elif [ "$TYPE" == "SSD" ]
	then
		mkfs.ext4 -F -E  lazy_itable_init=0,lazy_journal_init=0 -O ^uninit_bg /dev/sdd > /dev/null
		mount -t ext4 /dev/sdd $MOUNT_POINT
	fi

	#Run the Filebench script
	filebench -f $WORKLOAD_DIR/$filename > filebench.out &
	PROC_ID=$!

	echo "File bench PID : $PROC_ID"

	# wait until the filebench process completes
	while kill -0 "$PROC_ID" > /dev/null 2>&1;
	do
		# check whether Filebench exited or not
		sleep 1
	done

	# Create the output folder to copy the stats
	outputfolder=$COMMON_FOLDER/Stat-files-sq-re-4KB-${count}th-${count}f/
	`mkdir -p $outputfolder`

	cp -r filebench.out $outputfolder/

	#Remove the files after copying
	rm -rf filebench.out

	echo "Completed Running experiment sq re 4KB $count threads on $count files"
done

#Change the Permisions
chmod -R 777 $COMMON_FOLDER/*

ls $COMMON_FOLDER > temp.txt

filename="temp.txt"
while read -r line
do
        name="$line"
        ./parse-filebench $COMMON_FOLDER/$name
        echo "Completed Parsing $COMMON_FOLDER/$name"
done < "$filename"

exit 0

