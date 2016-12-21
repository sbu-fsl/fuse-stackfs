set mode quit alldone
set $dir=/home/bvangoor/COM_DIR/FUSE_EXT4_FS/
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
                flowop finishoncount name=finish, value=8000000
                #so that all the above operations will together complete 8 M(SSD) ops
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
system "mount -t ext4 /dev/sdd /home/bvangoor/COM_DIR/"

#mount FUSE FS (default) on top of EXT4
system "/home/bvangoor/fuse-playground/StackFS_LowLevel/StackFS_ll --statsdir=/tmp/ -o max_write=131072 -o writeback_cache -o splice_read -o splice_write -o splice_move -r /home/bvangoor/COM_DIR/EXT4_FS/ /home/bvangoor/COM_DIR/FUSE_EXT4_FS/ > /dev/null &"

system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"

system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"

psrun -10
