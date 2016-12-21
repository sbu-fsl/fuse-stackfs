set mode quit alldone
set $dir=/home/bvangoor/COM_DIR/FUSE_EXT4_FS/
set $nfiles=1
set $meandirwidth=1
set $nthreads=32

define fileset name=bigfileset, path=$dir, entries=$nfiles, dirwidth=$meandirwidth, size=60g, prealloc

define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=32k, instances=$nthreads
        {
                flowop openfile name=open1, filesetname=bigfileset, fd=1
                flowop read name=read-file, filesetname=bigfileset, iosize=32k, iters=1966080, fd=1
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
system "/home/bvangoor/fuse-playground/StackFS_LowLevel/StackFS_ll -s --statsdir=/tmp/ -r /home/bvangoor/COM_DIR/EXT4_FS/ /home/bvangoor/COM_DIR/FUSE_EXT4_FS/ > /dev/null &"

system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"
system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"

psrun -10
