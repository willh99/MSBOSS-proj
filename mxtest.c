#include "types.h"
#include "user.h"


void mxproc_test(void){

    //Test of per process mutex arrays
    //Results: Success!
    int muxid1, muxid2, muxid3, muxid4;
    muxid1 = mutex_create("mx1", 3);
    muxid2 = mutex_create("mx1", 3);
    muxid3 = mutex_create("mx3", 3);
    muxid4 = mutex_create("mx4", 3);

    printf(0, "muxid1 = %d, muxid2 = %d, muxid3 = %d, muxid4 = %d\n", muxid1, muxid2, muxid3, muxid4);

    mutex_delete(muxid1);
    printf(0, "muxid1 deleted\n");

}





int
main(int args, char** argv)
{
//    int pid, i;
//    pid = fork();

    //mxproc_test();

/*
    if(pid<0){
        printf(0, "Can't Fork try spooning\n");
    }
    else if(pid == 0){
	mutex_lock(muxid);
	cv_wait(muxid);
        for(i=0; i<100; i++){
            printf(0, "+");
        }
	mutex_unlock(muxid);
    }
    else{
	mutex_lock(muxid);
    	for(i=0; i<100; i++){
            printf(0, "-");
    	}
	cv_signal(muxid);
	mutex_unlock(muxid);
    	wait();
    }
*/    

    return 0;
}

