#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
#include "fss.h"

//#include <libgen.h>
# define DIRSIZ 14

//#include "fs.h"

//used for paprsing the path 

//what a request looks like 
/*struct fss_request{
	char operation[7];
	int arg;
	char data[1024];
	int retval1;
	int retval2;
	char retdata[1024];

};*/

char * stored_path[100];//idk about the size 

void r_mkdir(char *path){
//recursively calls till all directories are created
    struct stat info;
	//used to dileminate if directory or file
    char *p = path;

    while (*p != '\0') {
        if (*p == '/') {
            *p = '\0';
		//marks end of direct
            if (stat(path, &info) == -1) {
                mkdir(path);
            }
            *p = '/';
        }
        p++;
    }
}

void parse(char check[], char path[], char dest[])
{
   	char *a = check; //this is to iterate the base direct (original check)
	char *b = dest;
    	while (*a != '\0') {//goes till end of string /checkpoint
		*b = *a;
		a++;
		b++;
    	}
//this adds / to the end of /checkpoint to be /checkpoint/

	//*b = '/'; 
	//b++;

	a = path;//sets a to be the path we want to ad onto checkpoint

	while (*a != '\0') {//goes till end of string path
		*b = *a;
		b++;
		a++;
		
	}

	*b = '\0'; 
	b++;
	
	//*b = '\0';//adds the end
}


int checkpoint(int fd_array, char * dest){
	char * check=stored_path[fd_array];
	printf(1,"now running checkpoint\n");
	char path[1024];
	int nchars;
	int fd;
	int checkfd;
	int fd1;
	printf(1,"opening file %s\n",stored_path[fd_array]);
    if ((fd = open(check, O_RDONLY)) < 0 ) {
        
        return -1;
    }
printf(1,"preparse\n");
    parse(dest, check, path);//returns the path to be used in recursive mkdir

    printf(1, "filename:%s\n", path);

    r_mkdir(path);//all this does is create all the directories leaving the path to just be called


    // delete if prexisting checkpoint
    
    if ((fd1 = open(path, O_RDONLY)) >= 0) {
        close(fd1);
        unlink(path);
    }

    if ( (checkfd = open(path, O_WRONLY|O_CREATE)) < 0 )
        printf(1,"Can not create file\n");

    char *buf = path;
    memset(buf, 0, 1024);

    while ((nchars = read(fd, buf, sizeof(buf))) > 0) {
	//mirrored after CAT
	if (nchars < 0) {
		printf(1, "read error\n");//prints to consol
		exit();
	}
    		write(checkfd, buf, nchars);//creates the backup 
	 	memset(buf, 0, 1024);
    }
	

//checks if close works
    	if (close(fd) == -1 ){
		printf(1,"Can not close origin file\n");
	}	
	if (close(checkfd) == -1){
        	printf(1,"Can not close checkpoint file\n");
	}

    return 0;
}



char *fmtname(char *path)
{
	static char buf[DIRSIZ + 1];
	char *p;

	// Find first character after last slash.
	for (p = path + strlen(path); p >= path && *p != '/'; p--) ;
	p++;

	// Return blank-padded name.
	if (strlen(p) >= DIRSIZ)
		return p;
	memmove(buf, p, strlen(p));
	memset(buf + strlen(p), ' ', DIRSIZ - strlen(p));
	return buf;
}
int restore(char * path){
	printf(1,"restore called\n");
	//needs to be called in a loop and runs recursively
	//this recursively restores the files ans reurses down subdirectoriees doing the same
	//originally called with /checkpoint/
	//path starts with /checkpoint/ but when mkdir we need to strip it of that
	char buf[1024], *p;
	int fd;
	
	int checkfd;
	//int n;
	struct dirent de;
	struct stat st;
	char * parsed_path;
	parsed_path=path+12;//get rid of teh /checkpoint part of the path 
	


	char dir_path [1024];
	//used for recursively creating the directories similar to previous implementation

	printf(1,"parsed path= %s\n",parsed_path);
	printf(1,"test\n");
	if ((fd = open(path, 0)) < 0) {
		printf(2, "restore: cannot open %s\n", path);
		exit();
	}

	if (fstat(fd, &st) < 0) {
		printf(2, "restore: cannot stat %s\n", path);
		close(fd);
		exit();
	}
	switch (st.type) {
	case T_FILE: 
		//printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino,st.size);
		
		



		
		

	case T_DIR:
		if (strlen(path) + 1 + DIRSIZ + 1 > sizeof buf) {
			printf(1, "ls: path too long\n");
			exit();
		}
		
		strcpy(buf, path);
		p = buf + strlen(buf);
		*p++ = '/';
		while (read(fd, &de, sizeof(de)) == sizeof(de)) {
			if (de.inum == 0)
				continue;
			memmove(p, de.name, DIRSIZ);
			p[DIRSIZ] = 0;
			if (stat(buf, &st) < 0) {
				printf(1, "ls: cannot stat %s\n", buf);
				continue;
			}
			//printf(1, "%s %d %d %d\n", fmtname(buf));
			
			if (st.type==1){
				char * cmp= strcpy(cmp,fmtname(buf));
				//printf(1,"cmp =%s\n",cmp);
				//printf(1,"%d",(strcmp(cmp,"..")));
				if ((strcmp(cmp,"."))==32||(strcmp(cmp,".."))==32){
					//just ignore
				//	printf(1,"testme\n");
				}
				else{
				printf(1, "parsed_path = %s\n", parsed_path);
				printf(1,"dir_path is = %s\n",dir_path);
				printf(1,"restored directory %s\n",fmtname(buf));
				parse(parsed_path, fmtname(buf), dir_path);
				
				printf(1, "parsed_path = %s\n", parsed_path);
				printf(1,"dir_path is = %s\n",dir_path);
				printf(1,"restored directory %s\n",fmtname(buf));
				mkdir(dir_path);
				parse(path, dir_path, path);
				printf(1,"path is = %s\n",path);
				restore("path");
				//aka its a directory we need to recurse 
				}
			}
			else{//it is a file or something else might want to be more strict here idk
				 if ((checkfd = open(parsed_path, O_RDONLY)) >= 0) {
					close(checkfd);
					unlink(path);
		   		 }//checks if file still exists in location and deletes that mofo

				
				 if ( (checkfd = open(parsed_path, O_WRONLY|O_CREATE)) < 0 ){

					//creates new file
					printf(1,"Can not create file\n");
				 }
				 
				 strcpy(buf,parsed_path);//might be an isseu here 
				 memset(buf, 0, 1024);
				 int nchars;
				 while ((nchars = read(fd, buf, sizeof(buf))) > 0) {
					//mirrored after CAT
					 if (nchars < 0) {
							printf(1, "read error\n");//prints to consol
							exit();
					 }
				    		write(checkfd, buf, nchars);//creates the backup 
					 	memset(buf, 0, 1024);
				 }
				printf(1,"restored file %s\n",fmtname(buf));
			
			}
			
		
			
		}
		
	}
	close(fd);
		exit();
}
int main(int argc, char *argv[]){
	mkdir("checkpoint");
	setHighPrio();//sets FSS to highest priority

	intialize_mutex();
	while(1){	
		
printf(1,"done blocking test\n");
		//mutex_lock(mutexreq);
printf(1,"done blocking test2\n");
printf(1,"$ ");
		cv_wait(mutexreq);
		printf(1,"signal set\n");

		
struct fss_request * request= (struct fss_request *) shm_get("request",7);
printf(1,"stored path = %s\n",stored_path[request->fd]);
		struct fss_response * response;
	printf(1,"stored path = %s\n",stored_path[request->fd]);
		char * op=request->operation;
		printf(1,"servr received response processing type\n");
		printf(1,"command is %s\n",request->operation);
		if (strcmp(op,"write")==0){	
			printf(1,"writing\n");	
			printf(1,"fd = %d\n",request->fd);
			printf(1,"stored path = %s\n",stored_path[request->fd]);
			mutex_unlock(mutexreq);
			mutex_lock(mutexresp);//double check this stuff
			printf(1,"testing mutex locking inside write\n");
			response = (struct fss_response *) shm_get("response",8);
			
			char check[16];
	
			memset(check, 0, sizeof(check));
			printf(1,"calling checckpoint\n");
			strcpy(check, "/checkpoint/\0");
			printf(1,"stored path = %s\n",stored_path[request->fd]);
			checkpoint(request->fd, check);
			
			
			printf(1,"sending response\n");
			response->res=write(request->fd,request->data,request->arg);
			cv_signal(mutexresp);//signals response is written
			

		}
		else if (strcmp(op,"read")==0){
			//checkpoint(request->fd);
			mutex_unlock(mutexreq);
			mutex_lock(mutexresp);//double check this stuff
			response = (struct fss_response *) shm_get("response",8);
			printf(1,"fd = %d\n",request->fd);

			printf(1,"read data = %s read size %d\n",request->data, request->arg);
			response->res=read(request->fd,request->data,request->arg);
			printf(1,"response was %d\n",response->res);
			cv_signal(mutexresp);//signals response is written
		}
		else if (strcmp(op,"open")==0){
		printf(1,"opening\n");
			//checkpoint(request->fd);
			mutex_unlock(mutexreq);
			mutex_lock(mutexresp);//double check this stuff
			response = (struct fss_response *) shm_get("response",8);
			response->res=open(request->data,request->fd);
			char tempath [1024];
			strcpy(tempath,request->data);
			stored_path[response->res]=&tempath[0];
			printf(1,"testing store to array= %s\n",stored_path[response->res]);
			printf(1,"fd =%d\n",response->res);
			printf(1,"sending response\n");
			cv_signal(mutexresp);//signals response is written
		}
		else if (strcmp(op,"mkdir")==0){
			//checkpoint(request->fd);
			mutex_unlock(mutexreq);
			mutex_lock(mutexresp);//double check this stuff
			response = (struct fss_response *) shm_get("response",8);
			response->res=mkdir(request->data);
			
			cv_signal(mutexresp);//signals response is written
		}
		else if (strcmp(op,"close")==0){
			//checkpoint(request->fd);
			mutex_unlock(mutexreq);
			mutex_lock(mutexresp);//double check this stuff
			response = (struct fss_response *) shm_get("response",8);
			stored_path[request->fd]=NULL;//unmarks path
			response->res=close(request->fd);
			
			cv_signal(mutexresp);//signals response is written
		}
		else if (strcmp(op,"unlink")==0){
			//checkpoint(request->fd);
			mutex_unlock(mutexreq);
			mutex_lock(mutexresp);//double check this stuff
			response = (struct fss_response *) shm_get("response",8);
			char check[16];
			char path[1024];

			memset(check, 0, sizeof(check));
			strcpy(check, "/checkpoint/\0");
			
			parse(check, request->data, path);
			//returns the path to be used in recursive mkdir

    			printf(2, "help me dear lord filename:%s\n", path);

    			r_mkdir(path);//creates checkpoint if just unlink directory
			
			response->res=unlink(request->data);
			cv_signal(mutexresp);//signals response is written
		}
		else if (strcmp(op,"restore")==0){
			restore("/checkpoint/");		
		}
		else{
		printf(1,"didn't catch that\n");
			//error
			exit();
		}
		
	}

	exit();
}
