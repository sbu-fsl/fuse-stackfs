set mode quit alldone
set $dir=/home/bvangoor/EXT4_FS/
set $nfiles=1500000
set $meandirwidth=1500000
set $nthreads=16
set $size1=16k

define fileset name=bigfileset, path=$dir, size=$size1, entries=$nfiles, dirwidth=$meandirwidth, prealloc=80

define process name=mailserver,instances=1
{
        thread name=mailserverthread, memsize=10m, instances=$nthreads
        {
                flowop deletefile name=deletefile1,filesetname=bigfileset
                flowop createfile name=createfile2,filesetname=bigfileset,fd=1
                flowop appendfilerand name=appendfilerand2,iosize=16k,fd=1
                flowop fsync name=fsyncfile2,fd=1
                flowop closefile name=closefile2,fd=1
                flowop openfile name=openfile3,filesetname=bigfileset,fd=1
                flowop readwholefile name=readfile3,fd=1,iosize=1m
                flowop appendfilerand name=appendfilerand3,iosize=16k,fd=1
                flowop fsync name=fsyncfile3,fd=1
                flowop closefile name=closefile3,fd=1
                flowop openfile name=openfile4,filesetname=bigfileset,fd=1
                flowop readwholefile name=readfile4,fd=1,iosize=1m
                flowop closefile name=closefile4,fd=1
                flowop finishoncount name=finish, value=1000000
                #so that all the above operations togeteher run 1 M (HDD) ops
        }
}

create files
system "sync"
system "umount /home/bvangoor/EXT4_FS/"
#change accordingly for HDD (sdb) and SSD(sdd)
system "mount -t ext4 /dev/sdb /home/bvangoor/EXT4_FS"

system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"

system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"

psrun -10
