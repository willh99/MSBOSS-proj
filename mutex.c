#include "types.h"
#include "defs.h"
#include "param.h"
#include "x86.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "mutex.h"

int initmutex(char *name, int name_len)
{
	for(int i=0; i<=MUX_MAXNUM; i++){
		if(i==MUX_MAXNUM)
			return -1;
		if(mxarray[i].name = 0)
			break;
		else if(mxarray[i].name == name)
			mxarray[i].num_proc++;
			return mxarray[i].id;
	}
	mxarray[i].num_proc++;
	mxarray[i].name = name;
	mxarray[i].name_len = name_len;
        mxarray[i].lock = 0;
	return mxarray[i].id;
}

//Acquire the mutex lock
//Blocks until lock is acquired
void mxacquire(int muxid)
{
	if(mxarray[muxid].name == 0)
		return -1;
	if(mxarray[muxid]){
		sleep(mxarray[muxid].chan, /*spinlock*/);
	}

	asm{
		mov eax, 1			//Assign eax register value 1
		xchg eax, mxarray[muxid]->lock	//Use xchg to atomically switch eax and lock
	}

}

//Release mutex lock
void mxrelease(int muxid)
{
	if(mxarray[muxid].lock){
		wakeup(mxarray[muxid].id);
		return;
        }

	asm{
		mov eax, 0		//Assign eax register value 0
		xchg eax, lk->lock	//Use xchg to atomically switch eax and lock
	}

}

void mxdelete(int muxid)
{
	mxarray[muxid].num_proc--;
	
	if(mxarray[muxid].num_proc == 0){
		mxarray[muxid].name = 0;
        	mxarray[muxid].lock = 0;
        	mxarray[muxid].name_len = 0;
        	mxarray[muxid].num_proc = 0;
	}
	
}

void cvwait(int muxid)
{
        if(mxarray[muxid].name == 0)
                return;
        sleep(&mxarray[muxid], &ptable.lock);
}

void cvsignal(int muxid)
{
        if(mxarray[muxid].name == 0)
                return;
        wakeup(&mxarray[muxid]);
}

