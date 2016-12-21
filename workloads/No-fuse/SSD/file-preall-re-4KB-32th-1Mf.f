set mode quit alldone
set $dir=/home/bvangoor/EXT4_FS
#combined I/O amount to 1M prealloc (0.3 M) files
set $nfiles=1000000
set $meandirwidth=1000
set $nthreads=32

define fileset name=bigfileset, path=$dir, entries=$nfiles, dirwidth=$meandirwidth, dirgamma=0, size=4k, prealloc

define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=4k, instances=$nthreads
        {
                flowop openfile name=open1, filesetname=bigfileset, fd=1
                flowop readwholefile name=read-file, filesetname=bigfileset, iosize=4k, fd=1
                flowop closefile name=close-file,filesetname=bigfileset, fd=1
                flowop finishoncount name=finish, value=4000000
        }
}
create files
#mounting and unmounting for better stable results
system "sync"
system "umount /home/bvangoor/EXT4_FS/"
#change accordingly for HDD (sdb) and SSD (sdd)
system "mount -t ext4 /dev/sdd /home/bvangoor/EXT4_FS"
system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"
system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"
psrun -10
