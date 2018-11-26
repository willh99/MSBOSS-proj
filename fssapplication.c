#include "fss.h"
#include "types.h"
#include "stat.h"
#include "fs.h"
#include "file.h"
#include "fcntl.h"


//test for control cases of non server calls
char buf[1024];
char name[32];
int main(void)
{
	int fd;
	int i;
/*
	printf(1, "small file test\n");
	//need locks here 
	fd = fss_open("small", O_CREATE | O_RDWR);
	if (fd >= 0) {
		printf(1, "creat small succeeded; ok\n");
	} else {
		printf(1, "error: creat small failed!\n");
		exit();
	}
	for (i = 0; i < 10; i++) {
		if (fss_write(fd, "aaaaaaaaaa", 10) != 10) {
			printf(1, "error: write aa %d new file failed\n",
			       i);
			exit();
		}
		if (fss_write(fd, "bbbbbbbbbb", 10) != 10) {
			printf(1, "error: write bb %d new file failed\n",
			       i);
			exit();
		}
	}
	printf(1, "writes ok\n");
	fss_close(fd);
	fd = open("small", O_RDONLY);
	if (fd >= 0) {
		printf(1, "open small succeeded ok\n");
	} else {
		printf(1, "error: open small failed!\n");
		exit();
	}
	printf(1,"fd = %d\n",fd);
	i = read(fd, buf, 200);
	printf (1,"fss_read result was %d\n",i);
	if (i == 200) {
		printf(1, "read succeeded ok\n");
	} else {
		printf(1, "read failed\n");
		exit();
	}
	fss_close(fd);

	if (fss_unlink("small") < 0) {
		printf(1, "unlink small failed\n");
		exit();
	}
	printf(1, "small file test ok\n");


	//testing CAT becacuse its easy to check if its working
printf(0, "cat\n");
	
printf(0, "/////////////////////////////////////////////////////////////////////////////////////\n");
	//create files test  + unlink 


	printf(1, "many creates, followed by unlink test\n");

	name[0] = 'a';
	name[2] = '\0';
	for (i = 0; i < 5; i++) {
		name[1] = '0' + i;
		fd = fss_open(name, O_CREATE | O_RDWR);
		close(fd);
	}
	name[0] = 'a';
	name[2] = '\0';
	for (i = 0; i < 5; i++) {
		name[1] = '0' + i;
		fss_unlink(name);
	}
	printf(1, "many creates, followed by unlink; ok\n");
	

printf(0, "/////////////////////////////////////////////////////////////////////////////////////\n");
//mkdir test and unlink 
printf(1, "mkdir test and unlink\n");

	if (fss_mkdir("dir0") < 0) {
		printf(1, "mkdir failed\n");
		exit();
	}
	if (fss_unlink("dir0") < 0) {
		printf(1, "unlink dir0 failed\n");
		exit();
	}
	printf(1, "mkdir test ok\n");
*/
printf(1, "stesting checkpoining and restoret\n");
i=5;
	if (fss_mkdir("dirhier") < 0) {
		printf(1, "mkdir failed\n");
		exit();
	}
	if (fss_mkdir("dirhier/2ndlevel") < 0) {
		printf(1, "mkdir failed\n");
		exit();
	}
	if (fss_mkdir("dirhier/2ndlevelpart2") < 0) {
		printf(1, "mkdir failed\n");
		exit();
	}
	if (fss_mkdir("dirhier/2ndlevelpart2/2deep4me") < 0) {
		printf(1, "mkdir failed\n");
		exit();
	}

	fd = fss_open("dirhier/2ndlevelpart2/2deep4me/small", O_CREATE | O_RDWR);
	if (fd >= 0) {
		printf(1, "creat small succeeded; ok\n");
	} else {
		printf(1, "error: creat small failed!\n");
		exit();
	}
	printf(1,"fd = %d\n",fd);
		if (fss_write(fd, "hey I'm testing checkpoint", 27) != 27) {
			printf(1, "error: write aa %d new file failed\n",
			       i);
			printf(1,"result was %d\n",fss_write(fd, "hey I'm testing checkpoint", 27));
			exit();
		}
		

	if (fss_write(fd, "you failed to restore bitch", 27) != 27) {
			printf(1, "error: write bb %d new file failed\n",
			       i);
			exit();
		}
	fd = fss_open("checkpoint/dirhier/2ndlevelpart2/2deep4me/small", 0);
		if (fd >= 0){
			printf(1, "checkpoint works; ok\n");
		} else {
			printf(1, "error:checkpoint failed!\n");
			exit();
		}
	fss_close(fd);
	//exit();
printf(0, "/////////////////////////////////////////////////////////////////////////////////////\n");
	fd = fss_open("dirhier/2ndlevelpart2/2deep4me/small", O_RDONLY);
	if (fd >= 0) {
		printf(1, "opening the file baby ok\n");
	} else {
		printf(1, "error: open small failed!\n");
		exit();
	}
	//fi = fss_read(fd, buf, 2000);
	//int n;
	printf(1,"checking resotre, response should be hey i'm testing cehckpoint\n");
	//exit();
	/*while ((n = fss_read(fd, buf, sizeof(buf))) > 0)
		//printf(1,"the contents are \n");
		fss_write(1, buf, n);
		printf(1,"cat writing\n");
	if (n < 0) {
		printf(1, "cat: read error\n");
		exit();
	}*/
	
exit();
}
