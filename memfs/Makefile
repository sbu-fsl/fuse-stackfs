all: memfs_ll

memfs_ll:
	gcc -Wall -Werror memfs_lowlevel.c `pkg-config fuse3 --cflags --libs` -o memfs 

clean:
	rm -rf memfs
