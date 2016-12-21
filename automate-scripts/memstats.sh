#!/bin/bash
while :
do
	egrep 'Mem|Buffers|Cached|Dirty' /proc/meminfo
	grep 'ctxt ' /proc/stat
	sleep $1
done
