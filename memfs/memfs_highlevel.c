/* 
 * gcc -Wall memfs_highlevel.c `pkg-config fuse3 --cflags --libs` -o memfs_h
 * ./memfs_h -d -f -s /mnt/tmp
 */
#define FUSE_USE_VERSION  31

#include <fuse.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <stddef.h>

//#define FILE_LEN 1048576 
#define FILE_LEN 10000000

/*
static const char *filepath = "/bigfile";
static const char *filename = "bigfile";
*/
static const char *filepath = "/00000001";
static const char *filename = "00000001";
static char *filecontent;

void init_buff() {
	filecontent = (char *)malloc(FILE_LEN);	
	memset(filecontent, 1, FILE_LEN);
}

static int mem_open(const char *path, struct fuse_file_info *fi) {
	return 0;
}

static int mem_read(const char *path, char *buf, size_t size, off_t offset, struct fuse_file_info *fi) {
	if (strcmp(path, filepath) == 0) {
		size_t len = strlen(filecontent);
		if (offset >= len)
			return 0;
		if (offset + size > len) {
			memcpy(buf, filecontent + offset, len - offset);
			return len - offset;	
		}
		memcpy(buf, filecontent + offset, size);
		return size;
	}
	return -ENOENT;
}

static int mem_write(const char *path, const char *buf, size_t size, off_t offset, struct fuse_file_info *fi) {
	printf("trying to write to %s\n", path);
	if (strcmp(path, filepath) == 0) {
		if (offset + size < FILE_LEN) {
			memcpy(filecontent + offset, buf, size);
			return size;
		}

		memcpy(filecontent + offset, buf, FILE_LEN - offset);
		return FILE_LEN - offset;
	}	
	return -ENOSPC;
}

static int mem_readdir(const char *path, void *buf, fuse_fill_dir_t filler, off_t offset, struct fuse_file_info *fi,  enum fuse_readdir_flags flags) {
	//printf("readdir called.. \n");
	(void) offset;
	(void) fi;
	(void) flags;

	filler(buf, ".", NULL, 0, FUSE_FILL_DIR_PLUS);
	filler(buf, "..", NULL, 0, FUSE_FILL_DIR_PLUS);
	filler(buf, filename, NULL, 0, FUSE_FILL_DIR_PLUS);

	return 0;
}

static int mem_getattr(const char *path, struct stat *stbuf, struct fuse_file_info *fi) {
	//printf("getattr called.. \n");
	(void) fi;
	memset(stbuf, 0, sizeof(struct stat));
	if (strcmp(path, "/") == 0) {
		stbuf->st_mode = S_IFDIR | 0755;
		stbuf->st_nlink = 2;
		return 0;
	}
	if (strcmp(path, filepath) == 0) {
		stbuf->st_mode = S_IFREG | 0777;
		stbuf->st_nlink = 1;
		stbuf->st_size = strlen(filecontent);
		return 0;
	}
	return -ENOENT;
}

static struct fuse_operations mem_oper = {
	.getattr = mem_getattr,
	.readdir = mem_readdir,
	.open	 = mem_open,
	.read	 = mem_read,
	.write	 = mem_write,
};

int main(int argc, char *argv[])
{
	int ret;
	struct fuse_args args = FUSE_ARGS_INIT(argc, argv);
	init_buff();

	ret =  fuse_main(args.argc, args.argv, &mem_oper, NULL);
	printf("Shutting down..\n");
	if(filecontent)
		free(filecontent);

	return ret;
}
