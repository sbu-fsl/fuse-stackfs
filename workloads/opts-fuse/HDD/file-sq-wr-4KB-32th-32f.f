set mode quit alldone
set $dir=/home/bvangoor/COM_DIR/FUSE_EXT4_FS/
set $nfiles=32
set $meandirwidth=32
set $nthreads=1
#Each thread has an I/O amount of 1.875 G
set $io_size=4k
set $iterations=491520

define fileset name=bigfileset, path=$dir, entries=$nfiles, dirwidth=$meandirwidth,dirgamma=0,size=2g

define process name=filesequentialwrite, instances=1
{
        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create1, filesetname=bigfileset, fd=1, indexed=1
                flowop write name=write-file1, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=1
                flowop closefile name=close1, fd=1, indexed=1
                flowop finishoncount name=finish, value=1
        }
        
        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create2, filesetname=bigfileset, fd=1, indexed=2
                flowop write name=write-file2, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=2
                flowop closefile name=close2, fd=1, indexed=2
                flowop finishoncount name=finish, value=1
        }
        
        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create3, filesetname=bigfileset, fd=1, indexed=3
                flowop write name=write-file3, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=3
                flowop closefile name=close3, fd=1, indexed=3
                flowop finishoncount name=finish, value=1
        }
 
        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create4, filesetname=bigfileset, fd=1, indexed=4
                flowop write name=write-file4, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=4
                flowop closefile name=close4, fd=1, indexed=4
                flowop finishoncount name=finish, value=1
        }
 
        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create5, filesetname=bigfileset, fd=1, indexed=5
                flowop write name=write-file5, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=5
                flowop closefile name=close5, fd=1, indexed=5
                flowop finishoncount name=finish, value=1
        }
        
        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create6, filesetname=bigfileset, fd=1, indexed=6
                flowop write name=write-file6, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=6
                flowop closefile name=close6, fd=1, indexed=6
                flowop finishoncount name=finish, value=1
        }
        
        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create7, filesetname=bigfileset, fd=1, indexed=7
                flowop write name=write-file7, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=7
                flowop closefile name=close7, fd=1, indexed=7
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create8, filesetname=bigfileset, fd=1, indexed=8
                flowop write name=write-file8, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=8
                flowop closefile name=close8, fd=1, indexed=8
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create9, filesetname=bigfileset, fd=1, indexed=9
                flowop write name=write-file9, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=9
                flowop closefile name=close9, fd=1, indexed=9
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create10, filesetname=bigfileset, fd=1, indexed=10
                flowop write name=write-file10, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=10
                flowop closefile name=close10, fd=1, indexed=10
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create11, filesetname=bigfileset, fd=1, indexed=11
                flowop write name=write-file11, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=11
                flowop closefile name=close11, fd=1, indexed=11
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create12, filesetname=bigfileset, fd=1, indexed=12
                flowop write name=write-file12, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=12
                flowop closefile name=close12, fd=1, indexed=12
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create13, filesetname=bigfileset, fd=1, indexed=13
                flowop write name=write-file13, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=13
                flowop closefile name=close13, fd=1, indexed=13
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create14, filesetname=bigfileset, fd=1, indexed=14
                flowop write name=write-file14, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=14
                flowop closefile name=close14, fd=1, indexed=14
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create15, filesetname=bigfileset, fd=1, indexed=15
                flowop write name=write-file15, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=15
                flowop closefile name=close15, fd=1, indexed=15
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create16, filesetname=bigfileset, fd=1, indexed=16
                flowop write name=write-file16, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=16
                flowop closefile name=close16, fd=1, indexed=16
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create17, filesetname=bigfileset, fd=1, indexed=17
                flowop write name=write-file17, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=17
                flowop closefile name=close17, fd=1, indexed=17
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create18, filesetname=bigfileset, fd=1, indexed=18
                flowop write name=write-file18, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=18
                flowop closefile name=close18, fd=1, indexed=18
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create19, filesetname=bigfileset, fd=1, indexed=19
                flowop write name=write-file19, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=19
                flowop closefile name=close19, fd=1, indexed=19
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create20, filesetname=bigfileset, fd=1, indexed=20
                flowop write name=write-file20, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=20
                flowop closefile name=close20, fd=1, indexed=20
                flowop finishoncount name=finish, value=1
        }
        
        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create21, filesetname=bigfileset, fd=1, indexed=21
                flowop write name=write-file21, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=21
                flowop closefile name=close21, fd=1, indexed=21
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create22, filesetname=bigfileset, fd=1, indexed=22
                flowop write name=write-file22, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=22
                flowop closefile name=close22, fd=1, indexed=22
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create23, filesetname=bigfileset, fd=1, indexed=23
                flowop write name=write-file23, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=23
                flowop closefile name=close23, fd=1, indexed=23
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create24, filesetname=bigfileset, fd=1, indexed=24
                flowop write name=write-file24, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=24
                flowop closefile name=close24, fd=1, indexed=24
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create25, filesetname=bigfileset, fd=1, indexed=25
                flowop write name=write-file25, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=25
                flowop closefile name=close25, fd=1, indexed=25
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create26, filesetname=bigfileset, fd=1, indexed=26
                flowop write name=write-file26, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=26
                flowop closefile name=close26, fd=1, indexed=26
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create27, filesetname=bigfileset, fd=1, indexed=27
                flowop write name=write-file27, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=27
                flowop closefile name=close27, fd=1, indexed=27
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create28, filesetname=bigfileset, fd=1, indexed=28
                flowop write name=write-file28, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=28
                flowop closefile name=close28, fd=1, indexed=28
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create29, filesetname=bigfileset, fd=1, indexed=29
                flowop write name=write-file29, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=29
                flowop closefile name=close29, fd=1, indexed=29
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create30, filesetname=bigfileset, fd=1, indexed=30
                flowop write name=write-file30, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=30
                flowop closefile name=close30, fd=1, indexed=30
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create31, filesetname=bigfileset, fd=1, indexed=31
                flowop write name=write-file31, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=31
                flowop closefile name=close31, fd=1, indexed=31
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create32, filesetname=bigfileset, fd=1, indexed=32
                flowop write name=write-file32, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=32
                flowop closefile name=close32, fd=1, indexed=32
                flowop finishoncount name=finish, value=1
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

#mount max_write+wbc+splice FUSE FS (default) on top of EXT4
system "/home/bvangoor/fuse-playground/StackFS_LowLevel/StackFS_ll --statsdir=/tmp/ -o max_write=131072 -o writeback_cache -o splice_read -o splice_write -o splice_move -r /home/bvangoor/COM_DIR/EXT4_FS/ /home/bvangoor/COM_DIR/FUSE_EXT4_FS/ > /dev/null &"

system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"
psrun -10
