set mode quit alldone
set $dir=/home/bvangoor/EXT4_FS/
set $nfiles=1250000
set $meandirwidth=20
set $nthreads=100
set $size1=16k

define fileset name=bigfileset, path=$dir, size=$size1, entries=$nfiles, dirwidth=$meandirwidth, prealloc=100
define fileset name=logfiles, path=$dir, size=$size1, entries=1, dirwidth=$meandirwidth, prealloc

define process name=webserver,instances=1
{
        thread name=webserverthread,memsize=10m,instances=$nthreads
        {
                flowop openfile name=openfile1,filesetname=bigfileset,fd=1
                flowop readwholefile name=readfile1,fd=1,iosize=1m
                flowop closefile name=closefile1,fd=1
                flowop openfile name=openfile2,filesetname=bigfileset,fd=1
                flowop readwholefile name=readfile2,fd=1,iosize=1m
                flowop closefile name=closefile2,fd=1
                flowop openfile name=openfile3,filesetname=bigfileset,fd=1
                flowop readwholefile name=readfile3,fd=1,iosize=1m
                flowop closefile name=closefile3,fd=1
                flowop openfile name=openfile4,filesetname=bigfileset,fd=1
                flowop readwholefile name=readfile4,fd=1,iosize=1m
                flowop closefile name=closefile4,fd=1
                flowop openfile name=openfile5,filesetname=bigfileset,fd=1
                flowop readwholefile name=readfile5,fd=1,iosize=1m
                flowop closefile name=closefile5,fd=1
                flowop openfile name=openfile6,filesetname=bigfileset,fd=1
                flowop readwholefile name=readfile6,fd=1,iosize=1m
                flowop closefile name=closefile6,fd=1
                flowop openfile name=openfile7,filesetname=bigfileset,fd=1
                flowop readwholefile name=readfile7,fd=1,iosize=1m
                flowop closefile name=closefile7,fd=1
                flowop openfile name=openfile8,filesetname=bigfileset,fd=1
                flowop readwholefile name=readfile8,fd=1,iosize=1m
                flowop closefile name=closefile8,fd=1
                flowop openfile name=openfile9,filesetname=bigfileset,fd=1
                flowop readwholefile name=readfile9,fd=1,iosize=1m
                flowop closefile name=closefile9,fd=1
                flowop openfile name=openfile10,filesetname=bigfileset,fd=1
                flowop readwholefile name=readfile10,fd=1,iosize=1m
                flowop closefile name=closefile10,fd=1
                flowop appendfilerand name=appendlog,filesetname=logfiles,iosize=16k,fd=2
                flowop finishoncount name=finish, value=1000000
                #so that all the above operations will together complete 1 M(HDD) ops
        }
}
create files

system "sync"
system "umount /home/bvangoor/EXT4_FS/"
#change accordingly for HDD (sdb) and SSD (sdd)
system "mount -t ext4 /dev/sdb /home/bvangoor/EXT4_FS"

system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"

system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"

psrun -10
