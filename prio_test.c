#include "types.h"
#include "user.h"

volatile int sleeping = 0;

void
high_prio(void)
{
	//setprio(10);
	while (1) {
		int i;

		for (i = 0 ; i < 10 ; i++) {
			printf(1, "h");
		}
		if (sleeping) sleep(1);
	}
}

void
low_prio(void)
{
	while (1) {
		printf(1, "l");
	}
}

int
main(int argc, char *argv[])
{
	int pidh, pidl;

	if (argc == 2 && !strcmp(argv[1], "-s")) {
		sleeping = 1;
	}


	pidh = fork();
	if (pidh < 0) exit();
	if (pidh == 0) {
		high_prio();
		return 0;
	}

	pidl = fork();
	if (pidl < 0) exit();
	if (pidl == 0) {
		low_prio();
		return 0;
	}
	wait();
	wait();

	return 0;
}
