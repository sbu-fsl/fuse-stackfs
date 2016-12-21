set mode quit alldone
set $dir=/home/bvangoor/COM_DIR/FUSE_EXT4_FS/
set $nfiles=1
set $nthreads=1
#Fixing I/O Amount to 60 G
set $memsize=1m
set $iterations=61440

define file name=bigfileset, path=$dir, size=60g, prealloc

define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=$memsize, instances=$nthreads
        {
                flowop openfile name=open1, filesetname=bigfileset, fd=1
                flowop read name=read-file, filesetname=bigfileset, random, iosize=$memsize, iters=$iterations, fd=1
                flowop closefile name=close1, fd=1
                flowop finishoncount name=finish, value=1
        }
}

#prealloc the file on EXT4 F/S (save the time)
system "mkdir -p /home/bvangoor/COM_DIR/FUSE_EXT4_FS"
system "mkdir -p /home/bvangoor/COM_DIR/EXT4_FS"
create files

#Move everything created under FUSE-EXT4 dir to EXT4
system "mv /home/bvangoor/COM_DIR/FUSE_EXT4_FS/* /home/bvangoor/COM_DIR/EXT4_FS/"

#mounting and unmounting for better stable results
system "sync"
system "umount /home/bvangoor/COM_DIR/"
#change accordingly for HDD(sdb) and SSD(sdd)
system "mount -t ext4 /dev/sdb /home/bvangoor/COM_DIR/"

#mount FUSE FS (default) on top of EXT4
system "/home/bvangoor/fuse-playground/StackFS_LowLevel/StackFS_ll --statsdir=/tmp/ -o max_write=131072 -o writeback_cache -o splice_read -o splice_write -o splice_move -r /home/bvangoor/COM_DIR/EXT4_FS/ /home/bvangoor/COM_DIR/FUSE_EXT4_FS/ > /dev/null &"

#warm up the cache (RAM)
system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"
system "dd if=/home/bvangoor/EXT4_FS/bigfileset/00000001/00000001 of=/dev/null bs=4096 count=1048576 &> /dev/null"
system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"
psrun -10
