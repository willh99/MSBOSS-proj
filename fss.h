//may need to elminat this
//#include <assert.h> 
#include "types.h"
//#include "defs.h"

#include "user.h"
#define NULL ((void *)0)
int mutexreq;//=mutex_create("request_mutex",14);
int mutexresp;//=mutex_create("response_mutex",14);

struct fss_request{
	char operation[7];
	int arg;
	int fd;
	char data[1024];
	

};
struct fss_response{
	int res;
	char msg[1024];//idk why it needs this 
};
//struct fss_request * request;
//struct fss_response * response;
void intialize_mutex(){
	mutexreq=mutex_create("request_mutex",14);
	mutexresp=mutex_create("response_mutex",14);
	printf(1,"mutexes made\n");
}

int fss_write(int fd1, void * ptr, int n){
	int retval;

	mutex_lock(mutexreq);//acquried mutex when writing to shm

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
	strcpy(request->operation,"write");
	request->arg=n;
	request->fd=fd1;
	strcpy(request->data,(char *)ptr);
	printf(1,"operation = %s\n",request->operation);
	printf(1,"data set\n");
	cv_signal(mutexreq);//signals server to read
	
	cv_wait(mutexresp);//waits on server to write	
	printf(1,"waiting done\n");
	struct fss_response * response = (struct fss_response *) shm_get("response",8);
	mutex_unlock(mutexresp);//releases the response mutex
	printf(1,"response received\n");
	retval=response->res;

	return retval;
}
int fss_read(int fd1, void * ptr, int n){
	int retval;

	mutex_lock(mutexreq);//acquried mutex when writing to shm

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
	strcpy(request->operation,"read");
	request->arg=n;
	request->fd=fd1;
	strcpy(request->data,(char *)ptr);


	cv_signal(mutexreq);//signals server to read
	
	cv_wait(mutexresp);//waits on server to write	

	struct fss_response * response = (struct fss_response *) shm_get("response",8);
	mutex_unlock(mutexresp);//releases the response mutex

	retval=response->res;

	return retval;
}
int fss_open(char* path, int fd1){
	int retval;
	printf(1,"testing open\n");	

    mutex_lock(mutexreq);//acquried mutex when writing to shm

	printf(1,"lock taken\n");
	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
	strcpy(request->operation,"open");
	printf(1,"%s\n",request->operation);
	//request->arg=n;
	request->fd=fd1;
	strcpy(request->data,(char *)path);
	printf(1,"operation = %s\n",request->operation);
	printf(1,"data set\n");
	cv_signal(mutexreq);//signals server to read

	cv_wait(mutexresp);//waits on server to write	
	printf(1,"waiting done\n");
	struct fss_response * response = (struct fss_response *) shm_get("response",8);
	
	printf(1,"response received\n");
	retval=response->res;
	mutex_unlock(mutexresp);//releases the response mutex
	return retval;
};
int fss_close(int fd1){
	int retval;

	mutex_lock(mutexreq);//acquried mutex when writing to shm

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
	strcpy(request->operation,"close");
	//request->arg=n;
	request->fd=fd1;
	//strcpy(request->data,(char *)ptr);

	cv_signal(mutexreq);//signals server to read
	
	cv_wait(mutexresp);//waits on server to write	

	struct fss_response * response = (struct fss_response *) shm_get("response",8);
	mutex_unlock(mutexresp);//releases the response mutex

	retval=response->res;

	return retval;
}
int fss_mkdir(char * path){
	int retval;

	mutex_lock(mutexreq);//acquried mutex when writing to shm

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
	strcpy(request->operation,"mkdir");
	//request->arg=n;
	//request->fd=fd1;
	strcpy(request->data,(char *)path);
	printf(1,"mkdir test\n");
	cv_signal(mutexreq);//signals server to read
	mutex_lock(mutexresp);
	cv_wait(mutexresp);//waits on server to write	
	printf(1,"testme\n");
	struct fss_response * response = (struct fss_response *) shm_get("response",8);
	mutex_unlock(mutexresp);//releases the response mutex

	retval=response->res;

	return retval;
}
int fss_unlink(char * path){
	int retval;

	mutex_lock(mutexreq);//acquried mutex when writing to shm

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
	strcpy(request->operation,"unlink");
	//request->arg=n;
	//request->fd=fd1;
	strcpy(request->data,(char *)path);

	cv_signal(mutexreq);//signals server to read
	
	cv_wait(mutexresp);//waits on server to write	

	struct fss_response * response = (struct fss_response *) shm_get("response",8);
	mutex_unlock(mutexresp);//releases the response mutex

	retval=response->res;

	return retval;
}
int fss_restore(void){
	int retval;

	mutex_lock(mutexreq);//acquried mutex when writing to shm

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
	strcpy(request->operation,"restore");
	//request->arg=n;
	//request->fd=fd1;
	//strcpy(request->data,(char *)path);

	cv_signal(mutexreq);//signals server to read
	
	cv_wait(mutexresp);//waits on server to write	

	struct fss_response * response = (struct fss_response *) shm_get("response",8);
	mutex_unlock(mutexresp);//releases the response mutex

	retval=response->res;

	return retval;
}
