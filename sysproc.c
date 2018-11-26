#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int sys_fork(void)
{
	return fork();
}

int sys_exit(void)
{
	exit();
	return 0;		// not reached
}

int sys_wait(void)
{
	return wait();
}

int sys_kill(void)
{
	int pid;

	if (argint(0, &pid) < 0)
		return -1;
	return kill(pid);
}

int sys_getpid(void)
{
	return proc->pid;
}

int sys_sbrk(void)
{
	int addr;
	int n;

	if (argint(0, &n) < 0)
		return -1;
	addr = proc->sz;
	if (growproc(n) < 0)
		return -1;
	return addr;
}

int sys_sleep(void)
{
	int n;
	uint ticks0;

	if (argint(0, &n) < 0)
		return -1;
	acquire(&tickslock);
	ticks0 = ticks;
	while (ticks - ticks0 < n) {
		if (proc->killed) {
			release(&tickslock);
			return -1;
		}
		sleep(&ticks, &tickslock);
	}
	release(&tickslock);
	return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int sys_uptime(void)
{
	uint xticks;

	acquire(&tickslock);
	xticks = ticks;
	release(&tickslock);
	return xticks;
}

int
sys_setHighPrio(void)//scheduler
{
	setHighPrio();
	return 0;
}


int sys_shm_get(void) //mod2
{
	char *name;
	int length;
	char* result = 0;
	//int addr = 0;
	int check = 0;
	
	if(argint(1, &length) < 0 || argptr(0, &name, length) < 0)
		return 0;

	if(length>16)
	{
		cprintf("SHM Name Too Long! Cannot create SHM Region.");
		return 0;
	}

	check = strncmp(name, "DNE", sizeof(name));
	if(check == 0)
	{
		cprintf("The name 'DNE' is reserved for kernel use only. Please give SHM Region a different name.");
		return 0;
	}

	else
	{
		//cprintf("Character = %s\n", name);
		//addr = proc->sz;
		//cprintf("\nOld Size of process is starting point of SHM = %d\n", addr);
		result = shm_get(name, length);
		
		//cprintf("\nNormal char* result form SysCall = %d\n", result);
		//cprintf("\nTypecasted result form SysCall as int = %d\n", (int)result);
		//return (int)result;
		return (int)result;
	}
	return 0;
}




int sys_shm_rem(void) //mod2
{

	char *name;
	int length;
	int result = 0;
	int check = 0;
	
	if(argint(1, &length) < 0 || argptr(0, &name, length) < 0)
		return 0;
	
	if(length>16)
	{
		cprintf("SHM Name Too Long! No Region Exists with that Length.");
		return 0;
	}

	check = strncmp(name, "DNE", sizeof(name));
	if(check == 0)
	{
		cprintf("The name 'DNE' is reserved for kernel use only. Please give SHM Region a different name.");
		return 0;
	}

	else
	{
		result = shm_rem(name, length);
		return result;
	}
	
	return 0;
}

int sys_mutex_create(void){
	int name_len, muxid;
	char *name;
	

	//Returns -1 if a mutex cannot be created
	//Otherwise, a mutex id is returned to be used for
	//future mutex calls
	if(argint(1,&name_len)<0 || argptr(0, &name, name_len)<0)
		return -1;
	else{
		muxid = initmutex(name, name_len);
		return muxid;
	}
	return 0;
}
int sys_mutex_delete(void){


	int muxid;
	if(argint(0, &muxid)<0)
		return -1;
	mxdelete(muxid);
	return 0;
}
int sys_mutex_lock(void){
	int muxid;
	if(argint(0, &muxid)<0)
                return -1;
	mxacquire(muxid);
	return 0;
}
int sys_mutex_unlock(void)
{
	int muxid;
	if(argint(0, &muxid)<0)
                return -1;

	mxrelease(muxid);
	return 0;
}

int sys_cv_wait(void)
{
	int muxid;
	if(argint(0, &muxid)<0)
		return -1;
	cvwait(muxid);
	return 0;
}

int sys_cv_signal(void)
{
	int muxid;
        if(argint(0, &muxid)<0)
                return -1;
        cvsignal(muxid);
        return 0;


}
