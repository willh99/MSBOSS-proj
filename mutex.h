#include "defs.h"
#include "types.h"
#include "param.h"

struct mutex {
  uint lock;		// lock variable. If held, mutex locked by process
  int id;		// Mutex id
  char *name;		// Name of mutex
  int name_len;		// Length of name
  uint num_proc;	// Number of processes associated with the mutex
};

struct mutex mxarray[MUX_MAXNUM];


//Create the data structure holding mutexes
//Initialized to zero
void mxarray_init(void)
{
    int count;
    for(count=0; count < MUX_MAXNUM; count++){

        mxarray[count].name = 0;
	mxarray[count].name_len = 0;
	mxarray[count].lock = 0;
        mxarray[count].id = count;
	mxarray[count].num_proc = 0;
    }

}


