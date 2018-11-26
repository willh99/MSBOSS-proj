#include "fss.h"
#include "types.h"
#include "stat.h"
#include "fs.h"
#include "file.h"
#include "fcntl.h"


//test for control cases of non server calls
char buf[8192];
char name[32];
int main(void)
{
	int fd;
	int i;

	printf(1, "small file test\n");
	fd = open("small", O_CREATE | O_RDWR);
	if (fd >= 0) {
		printf(1, "creat small succeeded; ok\n");
	} else {
		printf(1, "error: creat small failed!\n");
		exit();
	}
	for (i = 0; i < 100; i++) {
		if (write(fd, "aaaaaaaaaa", 10) != 10) {
			printf(1, "error: write aa %d new file failed\n",
			       i);
			exit();
		}
		if (write(fd, "bbbbbbbbbb", 10) != 10) {
			printf(1, "error: write bb %d new file failed\n",
			       i);
			exit();
		}
	}
	printf(1, "writes ok\n");
	close(fd);
	fd = open("small", O_RDONLY);
	if (fd >= 0) {
		printf(1, "open small succeeded ok\n");
	} else {
		printf(1, "error: open small failed!\n");
		exit();
	}
	i = read(fd, buf, 2000);
	printf(1,"fd = %d\n",fd);
	if (i == 2000) {
		printf(1, "read succeeded ok\n");
	} else {
		printf(1, "read failed\n");
		exit();
	}
	close(fd);

	if (unlink("small") < 0) {
		printf(1, "unlink small failed\n");
		exit();
	}
	printf(1, "small file test ok\n");


	//testing CAT becacuse its easy to check if its working
printf(0, "cat\n");
	

	//create files test  + unlink 


	printf(1, "many creates, followed by unlink test\n");

	name[0] = 'a';
	name[2] = '\0';
	for (i = 0; i < 52; i++) {
		name[1] = '0' + i;
		fd = open(name, O_CREATE | O_RDWR);
		close(fd);
	}
	name[0] = 'a';
	name[2] = '\0';
	for (i = 0; i < 52; i++) {
		name[1] = '0' + i;
		unlink(name);
	}
	printf(1, "many creates, followed by unlink; ok\n");
	


//mkdir test and unlink 
printf(1, "mkdir test and unlink\n");

	if (mkdir("dir0") < 0) {
		printf(1, "mkdir failed\n");
		exit();
	}
	if (unlink("dir0") < 0) {
		printf(1, "unlink dir0 failed\n");
		exit();
	}
	printf(1, "mkdir test ok\n");
exit();
}
