#define FUSE_USE_VERSION 31

#include <fuse_lowlevel.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <assert.h>

#define FILE_LEN 10000000

static const char *filename = "00000001";
static char *filecontent;

void init_buff() {
        filecontent = (char *)malloc(FILE_LEN);
        memset(filecontent, 1, FILE_LEN);
	//strcpy(filecontent, "mem");
}


static int mem_stat(fuse_ino_t ino, struct stat *stbuf)
{
	stbuf->st_ino = ino;
	switch (ino) {
	case 1:
		stbuf->st_mode = S_IFDIR | 0755;
		stbuf->st_nlink = 2;
		break;

	case 2:
		//stbuf->st_mode = S_IFREG | 0444;
		stbuf->st_mode = S_IFREG | 0777;
		stbuf->st_nlink = 1;
		stbuf->st_size = strlen(filecontent);
		break;

	default:
		return -1;
	}
	return 0;
}

static void mem_ll_getattr(fuse_req_t req, fuse_ino_t ino,
			     struct fuse_file_info *fi)
{
	struct stat stbuf;

	(void) fi;

	memset(&stbuf, 0, sizeof(stbuf));
	if (mem_stat(ino, &stbuf) == -1)
		fuse_reply_err(req, ENOENT);
	else
		fuse_reply_attr(req, &stbuf, 1.0);
}

static void mem_ll_lookup(fuse_req_t req, fuse_ino_t parent, const char *name)
{
	struct fuse_entry_param e;

	if (parent != 1 || strcmp(name, filename) != 0)
		fuse_reply_err(req, ENOENT);
	else {
		memset(&e, 0, sizeof(e));
		e.ino = 2;
		e.attr_timeout = 1.0;
		e.entry_timeout = 1.0;
		mem_stat(e.ino, &e.attr);

		fuse_reply_entry(req, &e);
	}
}

struct dirbuf {
	char *p;
	size_t size;
};

static void dirbuf_add(fuse_req_t req, struct dirbuf *b, const char *name,
		       fuse_ino_t ino)
{
	struct stat stbuf;
	size_t oldsize = b->size;
	b->size += fuse_add_direntry(req, NULL, 0, name, NULL, 0);
	b->p = (char *) realloc(b->p, b->size);
	memset(&stbuf, 0, sizeof(stbuf));
	stbuf.st_ino = ino;
	fuse_add_direntry(req, b->p + oldsize, b->size - oldsize, name, &stbuf,
			  b->size);
}

#define min(x, y) ((x) < (y) ? (x) : (y))

static int reply_buf_limited(fuse_req_t req, const char *buf, size_t bufsize,
			     off_t off, size_t maxsize)
{
	if (off < bufsize)
		return fuse_reply_buf(req, buf + off,
				      min(bufsize - off, maxsize));
	else
		return fuse_reply_buf(req, NULL, 0);
}

static void mem_ll_readdir(fuse_req_t req, fuse_ino_t ino, size_t size,
			     off_t off, struct fuse_file_info *fi)
{
	(void) fi;

	if (ino != 1)
		fuse_reply_err(req, ENOTDIR);
	else {
		struct dirbuf b;

		memset(&b, 0, sizeof(b));
		dirbuf_add(req, &b, ".", 1);
		dirbuf_add(req, &b, "..", 1);
		dirbuf_add(req, &b, filename, 2);
		reply_buf_limited(req, b.p, b.size, off, size);
		free(b.p);
	}
}

static void mem_ll_open(fuse_req_t req, fuse_ino_t ino,
			  struct fuse_file_info *fi)
{
	if (ino != 2)
		fuse_reply_err(req, EISDIR);
//	else if ((fi->flags & 3) != O_RDONLY)
//		fuse_reply_err(req, EACCES);
	else
		fuse_reply_open(req, fi);
}

static void mem_ll_write(fuse_req_t req, fuse_ino_t ino, const char *buf,
		size_t size, off_t off, struct fuse_file_info *fi) 
{
	//printf("trying to write to %s\n", path);
	(void) ino;

	if (off >= FILE_LEN) 
		return (void) fuse_reply_err(req, errno);
	
	if (off + size > FILE_LEN)
		size = FILE_LEN - off;

	memcpy(filecontent + off, buf, size);
	fuse_reply_write(req, size);
}

static void mem_ll_read(fuse_req_t req, fuse_ino_t ino, size_t size,
			  off_t off, struct fuse_file_info *fi)
{
	(void) fi;
	char *buf;

	assert(ino == 2);
	buf = (char*)malloc(size);
	size_t len = strlen(filecontent);

	if (off >= len) {
		free(buf);
		return (void) fuse_reply_buf(req, NULL, 0);
	}

	if (off + size > len)
		size = len - off;
	memcpy(buf, filecontent + off, size);
	fuse_reply_buf(req, buf, size);
	free(buf);
}


static struct fuse_lowlevel_ops mem_ll_oper = {
	.lookup		= mem_ll_lookup,
	.getattr	= mem_ll_getattr,
	.readdir	= mem_ll_readdir,
	.open		= mem_ll_open,
	.read		= mem_ll_read,	
	.write		= mem_ll_write,
};

int main(int argc, char *argv[])
{
	struct fuse_args args = FUSE_ARGS_INIT(argc, argv);
	struct fuse_session *se;
	struct fuse_cmdline_opts opts;
	int ret = -1;
	
	init_buff();

	if (fuse_parse_cmdline(&args, &opts) != 0)
		return 1;
	if (opts.show_help) {
		printf("usage: %s [options] <mountpoint>\n\n", argv[0]);
		fuse_cmdline_help();
		fuse_lowlevel_help();
		ret = 0;
		goto err_out1;
	} else if (opts.show_version) {
		printf("FUSE library version %s\n", fuse_pkgversion());
		fuse_lowlevel_version();
		ret = 0;
		goto err_out1;
	}

	se = fuse_session_new(&args, &mem_ll_oper,
			      sizeof(mem_ll_oper), NULL);
	if (se == NULL)
	    goto err_out1;

	if (fuse_set_signal_handlers(se) != 0)
	    goto err_out2;

	if (fuse_session_mount(se, opts.mountpoint) != 0)
	    goto err_out3;

	fuse_daemonize(opts.foreground);

	/* Block until ctrl+c or fusermount -u */
	printf("singlethread: %d\n", opts.singlethread);
	if (opts.singlethread)
		ret = fuse_session_loop(se);
	else
		ret = fuse_session_loop_mt(se, opts.clone_fd);

	fuse_session_unmount(se);
err_out3:
	fuse_remove_signal_handlers(se);
err_out2:
	fuse_session_destroy(se);
err_out1:
	free(opts.mountpoint);
	fuse_opt_free_args(&args);

	if (filecontent)	
		free(filecontent);

	return ret ? 1 : 0;
}

