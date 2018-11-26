#include "types.h"
#include "user.h"

int main(void)
{
	//test file is a little cleaner. Simply checks if addresses are working correctly for alloc and dealloc.
	struct foo
	{
		int flarb;
		int glarf;
	};
	printf(0, "Running shmTest\n");
	struct foo* doop = (struct foo*) shm_get("test", 5);
	printf(1, "\nVA of doop = %d\n", &doop);
	printf(1, "\nVA of doop->flarb = %d\n", &(doop->flarb));
	printf(1, "\nVA of doop->glarf = %d\n", &(doop->glarf));

	int dun = 5;
	int car = 7;
	int gloob = 32;

	printf(1, "\nVA of dun = %d\n", &dun);
	printf(1, "VA of car = %d\n", &car);
	printf(1, "VA of gloob = %d\n", &gloob);

	shm_rem("test", 5);
	
	//printf(1, "\nVA of dun = %d\n", &dun);
	//printf(1, "VA of car = %d\n", &car);

	exit();
	return 0;
}
