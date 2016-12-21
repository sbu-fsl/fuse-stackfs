#!/bin/bash

COMMON_FOLDER="/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/HDD-FUSE-OPTS-EXT4-Results/"
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
