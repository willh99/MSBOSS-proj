#include "types.h"
#include "user.h"

int main(void)
{
	printf(0, "Running shmTest\n");
	int pid;
	//int sbrkAddr = 0;
	//char* check = 0;
	int i = 0;

	struct foo{
		int bloop;
		int doop;
	};

	setHighPrio();

		for(i=0; i<10; i++)
		{
			printf(1, "+");
		}

		printf(1,"Response Creation in Parent");

		for(i=0; i<10; i++)
		{
			printf(1, "+");
		}

	struct foo* fssTest = (struct foo*) shm_get("response", 9);
	printf(0, "\nfssTest = %d\n", fssTest);


	//struct foo* check = malloc (10*sizeof(struct foo)); //tests to find what was returned by memory allocation. Answer: VA
	//sbrkAddr = (int)sbrk(4096);
	//struct foo* check = (struct foo*)sbrk(4096);
	//printf(0, "\nSbrk address = %d\n", sbrkAddr);

	//Everything above the fork should be inherited to the child, including SHM access
	pid = fork();

	if(pid == 0) //in child
	{
		for(i=0; i<10; i++)
		{
			printf(1, "-");
		}

		printf(1,"Test Creation in Child");

		for(i=0; i<10; i++)
		{
			printf(1, "-");
		}

		printf(0, "\nStarting Check3\n");
		struct foo* check3 = (struct foo*) shm_get("test", 5);
		if(check3 != 0)
		{
			printf(0, "Pointer to child get test = %d\n", check3);
			printf(0, "Pointer to child get test.bloop = %d\n", &check3->bloop);
			printf(0, "Pointer to child get test.doop = %d\n", &check3->doop);
			printf(1, "bloop before check3 modified = %d\n", check3->bloop); 
			printf(1, "doop before check3 modified = %d\n", check3->doop);
			check3->bloop = 87;
			check3->doop = 29;
			printf(1, "bloop after check3 modified = %d\n", check3->bloop);
			printf(1, "doop after check3 modified = %d\n", check3->doop);
		}

		for(i=0; i<10; i++)
		{
			printf(1, "-");
		}

		printf(1,"Test Remove in Child");

		for(i=0; i<10; i++)
		{
			printf(1, "-");
		}
		
		shm_rem("test", 5);

		for(i=0; i<10; i++)
		{
			printf(1, "-");
		}

		printf(1,"Bloop Creation in Child");

		for(i=0; i<10; i++)
		{
			printf(1, "-");
		}

		printf(0, "\nStarting Check4\n");
		struct foo* check4 = (struct foo*) shm_get("bloop", 6);
		if(check4 != 0)
		{
			printf(0, "Pointer to child get test = %d\n", check4);
			printf(0, "Pointer to child get test.bloop = %d\n", &check4->bloop);
			printf(0, "Pointer to child get test.doop = %d\n", &check4->doop);
			check4->bloop = 200;
			check4->doop = 890;
			printf(1, "bloop = %d\n", check4->bloop);
			printf(1, "doop = %d\n", check4->doop);
		}

		for(i=0; i<10; i++)
		{
			printf(1, "-");
		}

		printf(1,"Bloop Remove in Child");

		for(i=0; i<10; i++)
		{
			printf(1, "-");
		}
		
		shm_rem("bloop", 6);

		exit();
		return 0;
	}

	if(pid > 0) //in parent
	{
		for(i=0; i<10; i++)
		{
			printf(1, "+");
		}

		printf(1,"Test Creation in Parent");

		for(i=0; i<10; i++)
		{
			printf(1, "+");
		}
		
		//Below starred region is for testing SHM made in two separate processes
		
		printf(0, "\nStarting Check1\n");
		struct foo* check = (struct foo*)shm_get("test", 5);
		if(check != 0)
		{
			printf(0, "Pointer to parent get test = %d\n", check);
			printf(0, "Pointer to parent get test.bloop = %d\n", &check->bloop);
			printf(0, "Pointer to parent get test.doop = %d\n", &check->doop);
			check->bloop = 5;
			check->doop = 7;
			printf(1, "Check 1 bloop = %d\n", check->bloop);
			printf(1, "Check 1 doop = %d\n", check->doop);
		}

		for(i=0; i<10; i++)
		{
			printf(1, "+");
		}

		printf(1,"Bloop Creation in Parent");

		for(i=0; i<10; i++)
		{
			printf(1, "+");
		}
	
		printf(0, "\nStarting Check2\n");
		struct foo* check2 = (struct foo*) shm_get("bloop", 6);
		if(check2 != 0)
		{
			printf(0, "Pointer to parent get bloop = %d\n", check2);
			printf(0, "Pointer to parent get bloop.bloop = %d\n", &check2->bloop);
			printf(0, "Pointer to parent get bloop.doop = %d\n", &check2->doop);
			check2->bloop = 23;
			check2->doop = 82;
			printf(1, "Check 2 bloop = %d\n", check2->bloop);
			printf(1, "Check 2 doop = %d\n", check2->doop);
		}
		
		for(i=0; i<10; i++)
		{
			printf(1, "+");
		}

		printf(1,"Test Remove in Parent");

		for(i=0; i<10; i++)
		{
			printf(1, "+");
		}

		shm_rem("test", 5);

		wait(); //waits for children to exit

		//Below checks to see if updates from child can be seen by parent...indicates SHM works.
		//also shows preserving SHM on wait also works

		for(i=0; i<10; i++)
		{
			printf(1, "+");
		}

		printf(1,"Test Creation in Parent");

		for(i=0; i<10; i++)
		{
			printf(1, "+");
		}

		printf(0, "\nStarting Check5\n"); //problem with remapping here. causing errors
		check = (struct foo*)shm_get("test", 5);
		if(check != 0)
		{
			printf(0, "Pointer to parent get test = %d\n", check);
			printf(0, "Pointer to parent get test.bloop = %d\n", &check->bloop);
			printf(0, "Pointer to parent get test.doop = %d\n", &check->doop);
			check->bloop = 5;
			check->doop = 7;
			printf(1, "bloop = %d\n", check->bloop);
			printf(1, "doop = %d\n", check->doop);
		}
	
		for(i=0; i<10; i++)
		{
			printf(1, "+");
		}

		printf(1,"Bloop Creation in Parent");

		for(i=0; i<10; i++)
		{
			printf(1, "+");
		}

		printf(0, "\nStarting Check6\n");
		check2 = (struct foo*) shm_get("bloop", 6);
		if(check2 != 0)
		{
			printf(0, "Pointer to parent get bloop = %d\n", check2);
			printf(0, "Pointer to parent get bloop.bloop = %d\n", check2->bloop);
			printf(0, "Pointer to parent get bloop.doop = %d\n", check2->doop);
			check2->bloop = 23;
			check2->doop = 82;
			printf(1, "bloop = %d\n", check2->bloop);
			printf(1, "doop = %d\n", check2->doop);
		}

		for(i=0; i<10; i++)
		{
			printf(1, "+");
		}

		printf(1,"Test Remove in Parent");

		for(i=0; i<10; i++)
		{
			printf(1, "+");
		}
		shm_rem("test", 5);

		for(i=0; i<10; i++)
		{
			printf(1, "+");
		}

		printf(1,"Response Remove in Parent");

		for(i=0; i<10; i++)
		{
			printf(1, "+");
		}
		shm_rem("response", 9);

		for(i=0; i<10; i++)
		{
			printf(1, "+");
		}

		printf(1,"Bloop Remove in Parent");

		for(i=0; i<10; i++)
		{
			printf(1, "+");
		}

		shm_rem("bloop", 6);

		exit();
		return 0;
	}
	
	exit();
	return 0;
}

