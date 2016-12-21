#!/bin/bash
echo "" > /sys/kernel/debug/tracing/trace

#enable writeback complte tracing
echo 1 > /sys/kernel/debug/tracing/events/writeback/writeback_bdi_register/enable

#For G.D.T and B.B.T etc.
echo 1 > /sys/kernel/debug/tracing/events/writeback/balance_dirty_pages_debug/enable 

#For kernel flusher thread start and end
echo 1 > /sys/kernel/debug/tracing/events/writeback/writeback_pages_before_written/enable
echo 1 > /sys/kernel/debug/tracing/events/writeback/writeback_pages_written/enable

#For write_pages end (no need of start)
#echo 1 > /sys/kernel/debug/tracing/events/writeback/writeback_single_inode_start/enable
echo 1 > /sys/kernel/debug/tracing/events/writeback/writeback_single_inode/enable

#enable fuse file write iter
echo 1 > /sys/kernel/debug/tracing/events/fuse/fuse_file_write_iter_begin/enable
echo 1 > /sys/kernel/debug/tracing/events/fuse/fuse_file_write_iter_end/enable

#enable filemap write getxattr
echo 1 > /sys/kernel/debug/tracing/events/filemap/filemap_getxattr_start/enable
echo 1 > /sys/kernel/debug/tracing/events/filemap/filemap_getxattr_end/enable

#for setattr after write_pages
echo 1 > /sys/kernel/debug/tracing/events/writeback/writeback_write_inode_start/enable
echo 1 > /sys/kernel/debug/tracing/events/writeback/writeback_write_inode/enable

cat /sys/kernel/debug/tracing/trace_pipe > /tmp/trace.out &
PROC_ID=$!

umount /home/bvangoor/EXT4_FS/
mkfs.ext4 -F -E  lazy_itable_init=0,lazy_journal_init=0 -O ^uninit_bg /dev/sdb > /dev/null
mount -t ext4 /dev/sdb /home/bvangoor/EXT4_FS/

filebench -f /home/bvangoor/fuse-playground/workloads/writeback-cache-fuse/seq-write.f

#disable writeback tracing
echo 0 > /sys/kernel/debug/tracing/events/writeback/enable

#disable filemap traces
echo 0 > /sys/kernel/debug/tracing/events/filemap/enable

#disable fuse traces
echo 0 > /sys/kernel/debug/tracing/events/fuse/enable

kill -9 $PROC_ID
sh generate-userstats.sh

cp /tmp/trace.out /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/

#parse the trace
#filebench-12711 [000] ....   943.599138: fuse_file_write_iter_begin: iteration count : 1
#filebench-12711 [000] ....   943.599148: filemap_getxattr_start: I/O starting Position : 0
#filebench-12711 [000] ....   943.599344: filemap_getxattr_end: I/O starting Position : 0
#filebench-12711 [000] ....   943.602038: fuse_file_write_iter_end: iteration count : 1

grep "fuse_file_write_iter_begin:" /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/trace.out | awk '{print $4}' | awk '{split($0, a, ":"); print a[1]}' >  /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/write_iter_begin_times
grep "fuse_file_write_iter_end:" /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/trace.out | awk '{print $4}' | awk '{split($0, a, ":"); print a[1]}' >  /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/write_iter_end_times

grep "filemap_getxattr_start:" /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/trace.out | awk '{print $4}' | awk '{split($0, a, ":"); print a[1]}' >  /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/getxattr_begin_times
grep "filemap_getxattr_end:" /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/trace.out | awk '{print $4}' | awk '{split($0, a, ":"); print a[1]}' >  /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/getxattr_end_times

grep "writeback_write_inode_start:" /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/trace.out | awk '{print $4}' | awk '{split($0, a, ":"); print a[1]}' >  /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/setattr_begin_times
grep "writeback_write_inode:" /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/trace.out | awk '{print $4}' | awk '{split($0, a, ":"); print a[1]}' >  /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/setattr_end_times

/home/bvangoor/fuse-playground/kernel-statistics/parse-tracefile-pause /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/
/home/bvangoor/fuse-playground/kernel-statistics/parse-tracefile-kernel-flusher /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/
/home/bvangoor/fuse-playground/kernel-statistics/parse-tracefile-StackFS /home/bvangoor/fuse-playground/kernel-statistics/Stat-files/
