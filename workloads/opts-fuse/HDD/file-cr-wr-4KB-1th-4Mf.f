set mode quit alldone
set $dir=/home/bvangoor/COM_DIR/FUSE_EXT4_FS/
#Fixing I/O amount to be 4M files
set $nfiles=4000000
set $meandirwidth=1000
set $nthreads=1

define fileset name=bigfileset, path=$dir, entries=$nfiles, dirgamma=0, dirwidth=$meandirwidth, size=4k
define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=4k, instances=$nthreads
        {
                flowop createfile name=create1, filesetname=bigfileset
                flowop writewholefile name=write-file, filesetname=bigfileset
                flowop closefile name=close-file,filesetname=bigfileset
        }
}
#prealloc the file on EXT4 F/S (save the time)
system "mkdir -p /home/bvangoor/COM_DIR/FUSE_EXT4_FS"
system "mkdir -p /home/bvangoor/COM_DIR/EXT4_FS"

create files

#Move everything created under FUSE-EXT4 dir to EXT4 (Though nothing in this case)
system "mv /home/bvangoor/COM_DIR/FUSE_EXT4_FS/* /home/bvangoor/COM_DIR/EXT4_FS/"

system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"

#mount FUSE FS (default) on top of EXT4
system "/home/bvangoor/fuse-playground/StackFS_LowLevel/StackFS_ll --statsdir=/tmp/ -o max_write=131072 -o writeback_cache -o splice_read -o splice_write -o splice_move -r /home/bvangoor/COM_DIR/EXT4_FS/ /home/bvangoor/COM_DIR/FUSE_EXT4_FS/ > /dev/null &"

system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"
psrun -10
