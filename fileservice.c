
#include "types.h"
#include "stat.h"
#include "user.h"
 
//this is a user level process to run an FS using normaal system calls 
/*this is the data passed to the FS*/
/*struct fss_request{
	char operation[7];
	int arg;
	char data[1024];
	int retval1;
	int retval2;
	char retdata[1024];

};*/

int main(void)
{
	if (fork() > 0)
		sleep(5);	// Let child exit before parent.
	exit();
}
