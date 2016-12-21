set mode quit alldone
set $dir=/home/bvangoor/EXT4_FS
set $nfiles=1
set $meandirwidth=1
set $nthreads=32
#Fix Combined I/O amount to 60 G
set $memsize=128k
set $iterations=15360

define file name=bigfileset, path=$dir, size=60g, prealloc

define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=$memsize, instances=$nthreads
        {
                flowop openfile name=open1, filesetname=bigfileset, fd=1
                flowop write name=write-file, filesetname=bigfileset, random, iosize=$memsize, iters=$iterations, fd=1
                flowop closefile name=close1, fd=1
                flowop finishoncount name=finish, value=1
        }
}
create files
#mount and unmount for stable results
system "sync"
system "umount /home/bvangoor/EXT4_FS"
#Change accordingly for HDD(sdb) and SSD(sdd)
system "mount -t ext4 /dev/sdb /home/bvangoor/EXT4_FS"
system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"
system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"
psrun -10
