
_fsapplication:     file format elf32-i386


Disassembly of section .text:

00000000 <intialize_mutex>:
	int res;
	char msg[1024];//idk why it needs this 
};
//struct fss_request * request;
//struct fss_response * response;
void intialize_mutex(){
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 08             	sub    $0x8,%esp
	mutexreq=mutex_create("request_mutex",14);
       6:	83 ec 08             	sub    $0x8,%esp
       9:	6a 0e                	push   $0xe
       b:	68 10 11 00 00       	push   $0x1110
      10:	e8 3c 0c 00 00       	call   c51 <mutex_create>
      15:	83 c4 10             	add    $0x10,%esp
      18:	a3 80 37 00 00       	mov    %eax,0x3780
	mutexresp=mutex_create("response_mutex",14);
      1d:	83 ec 08             	sub    $0x8,%esp
      20:	6a 0e                	push   $0xe
      22:	68 1e 11 00 00       	push   $0x111e
      27:	e8 25 0c 00 00       	call   c51 <mutex_create>
      2c:	83 c4 10             	add    $0x10,%esp
      2f:	a3 60 17 00 00       	mov    %eax,0x1760
	printf(1,"mutexes made\n");
      34:	83 ec 08             	sub    $0x8,%esp
      37:	68 2d 11 00 00       	push   $0x112d
      3c:	6a 01                	push   $0x1
      3e:	e8 15 0d 00 00       	call   d58 <printf>
      43:	83 c4 10             	add    $0x10,%esp
}
      46:	90                   	nop
      47:	c9                   	leave  
      48:	c3                   	ret    

00000049 <fss_write>:

int fss_write(int fd1, void * ptr, int n){
      49:	55                   	push   %ebp
      4a:	89 e5                	mov    %esp,%ebp
      4c:	83 ec 18             	sub    $0x18,%esp
	int retval;

	mutex_lock(mutexreq);//acquried mutex when writing to shm
      4f:	a1 80 37 00 00       	mov    0x3780,%eax
      54:	83 ec 0c             	sub    $0xc,%esp
      57:	50                   	push   %eax
      58:	e8 04 0c 00 00       	call   c61 <mutex_lock>
      5d:	83 c4 10             	add    $0x10,%esp

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
      60:	83 ec 08             	sub    $0x8,%esp
      63:	6a 07                	push   $0x7
      65:	68 3b 11 00 00       	push   $0x113b
      6a:	e8 ca 0b 00 00       	call   c39 <shm_get>
      6f:	83 c4 10             	add    $0x10,%esp
      72:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"write");
      75:	8b 45 f4             	mov    -0xc(%ebp),%eax
      78:	83 ec 08             	sub    $0x8,%esp
      7b:	68 43 11 00 00       	push   $0x1143
      80:	50                   	push   %eax
      81:	e8 e2 08 00 00       	call   968 <strcpy>
      86:	83 c4 10             	add    $0x10,%esp
	request->arg=n;
      89:	8b 45 f4             	mov    -0xc(%ebp),%eax
      8c:	8b 55 10             	mov    0x10(%ebp),%edx
      8f:	89 50 08             	mov    %edx,0x8(%eax)
	request->fd=fd1;
      92:	8b 45 f4             	mov    -0xc(%ebp),%eax
      95:	8b 55 08             	mov    0x8(%ebp),%edx
      98:	89 50 0c             	mov    %edx,0xc(%eax)
	strcpy(request->data,(char *)ptr);
      9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
      9e:	83 c0 10             	add    $0x10,%eax
      a1:	83 ec 08             	sub    $0x8,%esp
      a4:	ff 75 0c             	pushl  0xc(%ebp)
      a7:	50                   	push   %eax
      a8:	e8 bb 08 00 00       	call   968 <strcpy>
      ad:	83 c4 10             	add    $0x10,%esp
	printf(1,"operation = %s\n",request->operation);
      b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
      b3:	83 ec 04             	sub    $0x4,%esp
      b6:	50                   	push   %eax
      b7:	68 49 11 00 00       	push   $0x1149
      bc:	6a 01                	push   $0x1
      be:	e8 95 0c 00 00       	call   d58 <printf>
      c3:	83 c4 10             	add    $0x10,%esp
	printf(1,"data set\n");
      c6:	83 ec 08             	sub    $0x8,%esp
      c9:	68 59 11 00 00       	push   $0x1159
      ce:	6a 01                	push   $0x1
      d0:	e8 83 0c 00 00       	call   d58 <printf>
      d5:	83 c4 10             	add    $0x10,%esp
	cv_signal(mutexreq);//signals server to read
      d8:	a1 80 37 00 00       	mov    0x3780,%eax
      dd:	83 ec 0c             	sub    $0xc,%esp
      e0:	50                   	push   %eax
      e1:	e8 93 0b 00 00       	call   c79 <cv_signal>
      e6:	83 c4 10             	add    $0x10,%esp
	
	cv_wait(mutexresp);//waits on server to write	
      e9:	a1 60 17 00 00       	mov    0x1760,%eax
      ee:	83 ec 0c             	sub    $0xc,%esp
      f1:	50                   	push   %eax
      f2:	e8 7a 0b 00 00       	call   c71 <cv_wait>
      f7:	83 c4 10             	add    $0x10,%esp
	printf(1,"waiting done\n");
      fa:	83 ec 08             	sub    $0x8,%esp
      fd:	68 63 11 00 00       	push   $0x1163
     102:	6a 01                	push   $0x1
     104:	e8 4f 0c 00 00       	call   d58 <printf>
     109:	83 c4 10             	add    $0x10,%esp
	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     10c:	83 ec 08             	sub    $0x8,%esp
     10f:	6a 08                	push   $0x8
     111:	68 71 11 00 00       	push   $0x1171
     116:	e8 1e 0b 00 00       	call   c39 <shm_get>
     11b:	83 c4 10             	add    $0x10,%esp
     11e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     121:	a1 60 17 00 00       	mov    0x1760,%eax
     126:	83 ec 0c             	sub    $0xc,%esp
     129:	50                   	push   %eax
     12a:	e8 3a 0b 00 00       	call   c69 <mutex_unlock>
     12f:	83 c4 10             	add    $0x10,%esp
	printf(1,"response received\n");
     132:	83 ec 08             	sub    $0x8,%esp
     135:	68 7a 11 00 00       	push   $0x117a
     13a:	6a 01                	push   $0x1
     13c:	e8 17 0c 00 00       	call   d58 <printf>
     141:	83 c4 10             	add    $0x10,%esp
	retval=response->res;
     144:	8b 45 f0             	mov    -0x10(%ebp),%eax
     147:	8b 00                	mov    (%eax),%eax
     149:	89 45 ec             	mov    %eax,-0x14(%ebp)

	return retval;
     14c:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
     14f:	c9                   	leave  
     150:	c3                   	ret    

00000151 <fss_read>:
int fss_read(int fd1, void * ptr, int n){
     151:	55                   	push   %ebp
     152:	89 e5                	mov    %esp,%ebp
     154:	83 ec 18             	sub    $0x18,%esp
	int retval;

	mutex_lock(mutexreq);//acquried mutex when writing to shm
     157:	a1 80 37 00 00       	mov    0x3780,%eax
     15c:	83 ec 0c             	sub    $0xc,%esp
     15f:	50                   	push   %eax
     160:	e8 fc 0a 00 00       	call   c61 <mutex_lock>
     165:	83 c4 10             	add    $0x10,%esp

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
     168:	83 ec 08             	sub    $0x8,%esp
     16b:	6a 07                	push   $0x7
     16d:	68 3b 11 00 00       	push   $0x113b
     172:	e8 c2 0a 00 00       	call   c39 <shm_get>
     177:	83 c4 10             	add    $0x10,%esp
     17a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"read");
     17d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     180:	83 ec 08             	sub    $0x8,%esp
     183:	68 8d 11 00 00       	push   $0x118d
     188:	50                   	push   %eax
     189:	e8 da 07 00 00       	call   968 <strcpy>
     18e:	83 c4 10             	add    $0x10,%esp
	request->arg=n;
     191:	8b 45 f4             	mov    -0xc(%ebp),%eax
     194:	8b 55 10             	mov    0x10(%ebp),%edx
     197:	89 50 08             	mov    %edx,0x8(%eax)
	request->fd=fd1;
     19a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     19d:	8b 55 08             	mov    0x8(%ebp),%edx
     1a0:	89 50 0c             	mov    %edx,0xc(%eax)
	strcpy(request->data,(char *)ptr);
     1a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     1a6:	83 c0 10             	add    $0x10,%eax
     1a9:	83 ec 08             	sub    $0x8,%esp
     1ac:	ff 75 0c             	pushl  0xc(%ebp)
     1af:	50                   	push   %eax
     1b0:	e8 b3 07 00 00       	call   968 <strcpy>
     1b5:	83 c4 10             	add    $0x10,%esp


	cv_signal(mutexreq);//signals server to read
     1b8:	a1 80 37 00 00       	mov    0x3780,%eax
     1bd:	83 ec 0c             	sub    $0xc,%esp
     1c0:	50                   	push   %eax
     1c1:	e8 b3 0a 00 00       	call   c79 <cv_signal>
     1c6:	83 c4 10             	add    $0x10,%esp
	
	cv_wait(mutexresp);//waits on server to write	
     1c9:	a1 60 17 00 00       	mov    0x1760,%eax
     1ce:	83 ec 0c             	sub    $0xc,%esp
     1d1:	50                   	push   %eax
     1d2:	e8 9a 0a 00 00       	call   c71 <cv_wait>
     1d7:	83 c4 10             	add    $0x10,%esp

	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     1da:	83 ec 08             	sub    $0x8,%esp
     1dd:	6a 08                	push   $0x8
     1df:	68 71 11 00 00       	push   $0x1171
     1e4:	e8 50 0a 00 00       	call   c39 <shm_get>
     1e9:	83 c4 10             	add    $0x10,%esp
     1ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     1ef:	a1 60 17 00 00       	mov    0x1760,%eax
     1f4:	83 ec 0c             	sub    $0xc,%esp
     1f7:	50                   	push   %eax
     1f8:	e8 6c 0a 00 00       	call   c69 <mutex_unlock>
     1fd:	83 c4 10             	add    $0x10,%esp

	retval=response->res;
     200:	8b 45 f0             	mov    -0x10(%ebp),%eax
     203:	8b 00                	mov    (%eax),%eax
     205:	89 45 ec             	mov    %eax,-0x14(%ebp)

	return retval;
     208:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
     20b:	c9                   	leave  
     20c:	c3                   	ret    

0000020d <fss_open>:
int fss_open(char* path, int fd1){
     20d:	55                   	push   %ebp
     20e:	89 e5                	mov    %esp,%ebp
     210:	83 ec 18             	sub    $0x18,%esp
	int retval;
	printf(1,"testing open\n");	
     213:	83 ec 08             	sub    $0x8,%esp
     216:	68 92 11 00 00       	push   $0x1192
     21b:	6a 01                	push   $0x1
     21d:	e8 36 0b 00 00       	call   d58 <printf>
     222:	83 c4 10             	add    $0x10,%esp

    mutex_lock(mutexreq);//acquried mutex when writing to shm
     225:	a1 80 37 00 00       	mov    0x3780,%eax
     22a:	83 ec 0c             	sub    $0xc,%esp
     22d:	50                   	push   %eax
     22e:	e8 2e 0a 00 00       	call   c61 <mutex_lock>
     233:	83 c4 10             	add    $0x10,%esp

	printf(1,"lock taken\n");
     236:	83 ec 08             	sub    $0x8,%esp
     239:	68 a0 11 00 00       	push   $0x11a0
     23e:	6a 01                	push   $0x1
     240:	e8 13 0b 00 00       	call   d58 <printf>
     245:	83 c4 10             	add    $0x10,%esp
	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
     248:	83 ec 08             	sub    $0x8,%esp
     24b:	6a 07                	push   $0x7
     24d:	68 3b 11 00 00       	push   $0x113b
     252:	e8 e2 09 00 00       	call   c39 <shm_get>
     257:	83 c4 10             	add    $0x10,%esp
     25a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"open");
     25d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     260:	83 ec 08             	sub    $0x8,%esp
     263:	68 ac 11 00 00       	push   $0x11ac
     268:	50                   	push   %eax
     269:	e8 fa 06 00 00       	call   968 <strcpy>
     26e:	83 c4 10             	add    $0x10,%esp
	printf(1,"%s\n",request->operation);
     271:	8b 45 f4             	mov    -0xc(%ebp),%eax
     274:	83 ec 04             	sub    $0x4,%esp
     277:	50                   	push   %eax
     278:	68 b1 11 00 00       	push   $0x11b1
     27d:	6a 01                	push   $0x1
     27f:	e8 d4 0a 00 00       	call   d58 <printf>
     284:	83 c4 10             	add    $0x10,%esp
	//request->arg=n;
	request->fd=fd1;
     287:	8b 45 f4             	mov    -0xc(%ebp),%eax
     28a:	8b 55 0c             	mov    0xc(%ebp),%edx
     28d:	89 50 0c             	mov    %edx,0xc(%eax)
	strcpy(request->data,(char *)path);
     290:	8b 45 f4             	mov    -0xc(%ebp),%eax
     293:	83 c0 10             	add    $0x10,%eax
     296:	83 ec 08             	sub    $0x8,%esp
     299:	ff 75 08             	pushl  0x8(%ebp)
     29c:	50                   	push   %eax
     29d:	e8 c6 06 00 00       	call   968 <strcpy>
     2a2:	83 c4 10             	add    $0x10,%esp
	printf(1,"operation = %s\n",request->operation);
     2a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     2a8:	83 ec 04             	sub    $0x4,%esp
     2ab:	50                   	push   %eax
     2ac:	68 49 11 00 00       	push   $0x1149
     2b1:	6a 01                	push   $0x1
     2b3:	e8 a0 0a 00 00       	call   d58 <printf>
     2b8:	83 c4 10             	add    $0x10,%esp
	printf(1,"data set\n");
     2bb:	83 ec 08             	sub    $0x8,%esp
     2be:	68 59 11 00 00       	push   $0x1159
     2c3:	6a 01                	push   $0x1
     2c5:	e8 8e 0a 00 00       	call   d58 <printf>
     2ca:	83 c4 10             	add    $0x10,%esp
	cv_signal(mutexreq);//signals server to read
     2cd:	a1 80 37 00 00       	mov    0x3780,%eax
     2d2:	83 ec 0c             	sub    $0xc,%esp
     2d5:	50                   	push   %eax
     2d6:	e8 9e 09 00 00       	call   c79 <cv_signal>
     2db:	83 c4 10             	add    $0x10,%esp

	cv_wait(mutexresp);//waits on server to write	
     2de:	a1 60 17 00 00       	mov    0x1760,%eax
     2e3:	83 ec 0c             	sub    $0xc,%esp
     2e6:	50                   	push   %eax
     2e7:	e8 85 09 00 00       	call   c71 <cv_wait>
     2ec:	83 c4 10             	add    $0x10,%esp
	printf(1,"waiting done\n");
     2ef:	83 ec 08             	sub    $0x8,%esp
     2f2:	68 63 11 00 00       	push   $0x1163
     2f7:	6a 01                	push   $0x1
     2f9:	e8 5a 0a 00 00       	call   d58 <printf>
     2fe:	83 c4 10             	add    $0x10,%esp
	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     301:	83 ec 08             	sub    $0x8,%esp
     304:	6a 08                	push   $0x8
     306:	68 71 11 00 00       	push   $0x1171
     30b:	e8 29 09 00 00       	call   c39 <shm_get>
     310:	83 c4 10             	add    $0x10,%esp
     313:	89 45 f0             	mov    %eax,-0x10(%ebp)
	
	printf(1,"response received\n");
     316:	83 ec 08             	sub    $0x8,%esp
     319:	68 7a 11 00 00       	push   $0x117a
     31e:	6a 01                	push   $0x1
     320:	e8 33 0a 00 00       	call   d58 <printf>
     325:	83 c4 10             	add    $0x10,%esp
	retval=response->res;
     328:	8b 45 f0             	mov    -0x10(%ebp),%eax
     32b:	8b 00                	mov    (%eax),%eax
     32d:	89 45 ec             	mov    %eax,-0x14(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     330:	a1 60 17 00 00       	mov    0x1760,%eax
     335:	83 ec 0c             	sub    $0xc,%esp
     338:	50                   	push   %eax
     339:	e8 2b 09 00 00       	call   c69 <mutex_unlock>
     33e:	83 c4 10             	add    $0x10,%esp
	return retval;
     341:	8b 45 ec             	mov    -0x14(%ebp),%eax
};
     344:	c9                   	leave  
     345:	c3                   	ret    

00000346 <fss_close>:
int fss_close(int fd1){
     346:	55                   	push   %ebp
     347:	89 e5                	mov    %esp,%ebp
     349:	83 ec 18             	sub    $0x18,%esp
	int retval;

	mutex_lock(mutexreq);//acquried mutex when writing to shm
     34c:	a1 80 37 00 00       	mov    0x3780,%eax
     351:	83 ec 0c             	sub    $0xc,%esp
     354:	50                   	push   %eax
     355:	e8 07 09 00 00       	call   c61 <mutex_lock>
     35a:	83 c4 10             	add    $0x10,%esp

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
     35d:	83 ec 08             	sub    $0x8,%esp
     360:	6a 07                	push   $0x7
     362:	68 3b 11 00 00       	push   $0x113b
     367:	e8 cd 08 00 00       	call   c39 <shm_get>
     36c:	83 c4 10             	add    $0x10,%esp
     36f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"close");
     372:	8b 45 f4             	mov    -0xc(%ebp),%eax
     375:	83 ec 08             	sub    $0x8,%esp
     378:	68 b5 11 00 00       	push   $0x11b5
     37d:	50                   	push   %eax
     37e:	e8 e5 05 00 00       	call   968 <strcpy>
     383:	83 c4 10             	add    $0x10,%esp
	//request->arg=n;
	request->fd=fd1;
     386:	8b 45 f4             	mov    -0xc(%ebp),%eax
     389:	8b 55 08             	mov    0x8(%ebp),%edx
     38c:	89 50 0c             	mov    %edx,0xc(%eax)
	//strcpy(request->data,(char *)ptr);

	cv_signal(mutexreq);//signals server to read
     38f:	a1 80 37 00 00       	mov    0x3780,%eax
     394:	83 ec 0c             	sub    $0xc,%esp
     397:	50                   	push   %eax
     398:	e8 dc 08 00 00       	call   c79 <cv_signal>
     39d:	83 c4 10             	add    $0x10,%esp
	
	cv_wait(mutexresp);//waits on server to write	
     3a0:	a1 60 17 00 00       	mov    0x1760,%eax
     3a5:	83 ec 0c             	sub    $0xc,%esp
     3a8:	50                   	push   %eax
     3a9:	e8 c3 08 00 00       	call   c71 <cv_wait>
     3ae:	83 c4 10             	add    $0x10,%esp

	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     3b1:	83 ec 08             	sub    $0x8,%esp
     3b4:	6a 08                	push   $0x8
     3b6:	68 71 11 00 00       	push   $0x1171
     3bb:	e8 79 08 00 00       	call   c39 <shm_get>
     3c0:	83 c4 10             	add    $0x10,%esp
     3c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     3c6:	a1 60 17 00 00       	mov    0x1760,%eax
     3cb:	83 ec 0c             	sub    $0xc,%esp
     3ce:	50                   	push   %eax
     3cf:	e8 95 08 00 00       	call   c69 <mutex_unlock>
     3d4:	83 c4 10             	add    $0x10,%esp

	retval=response->res;
     3d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
     3da:	8b 00                	mov    (%eax),%eax
     3dc:	89 45 ec             	mov    %eax,-0x14(%ebp)

	return retval;
     3df:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
     3e2:	c9                   	leave  
     3e3:	c3                   	ret    

000003e4 <fss_mkdir>:
int fss_mkdir(char * path){
     3e4:	55                   	push   %ebp
     3e5:	89 e5                	mov    %esp,%ebp
     3e7:	83 ec 18             	sub    $0x18,%esp
	int retval;

	mutex_lock(mutexreq);//acquried mutex when writing to shm
     3ea:	a1 80 37 00 00       	mov    0x3780,%eax
     3ef:	83 ec 0c             	sub    $0xc,%esp
     3f2:	50                   	push   %eax
     3f3:	e8 69 08 00 00       	call   c61 <mutex_lock>
     3f8:	83 c4 10             	add    $0x10,%esp

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
     3fb:	83 ec 08             	sub    $0x8,%esp
     3fe:	6a 07                	push   $0x7
     400:	68 3b 11 00 00       	push   $0x113b
     405:	e8 2f 08 00 00       	call   c39 <shm_get>
     40a:	83 c4 10             	add    $0x10,%esp
     40d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"mkdir");
     410:	8b 45 f4             	mov    -0xc(%ebp),%eax
     413:	83 ec 08             	sub    $0x8,%esp
     416:	68 bb 11 00 00       	push   $0x11bb
     41b:	50                   	push   %eax
     41c:	e8 47 05 00 00       	call   968 <strcpy>
     421:	83 c4 10             	add    $0x10,%esp
	//request->arg=n;
	//request->fd=fd1;
	strcpy(request->data,(char *)path);
     424:	8b 45 f4             	mov    -0xc(%ebp),%eax
     427:	83 c0 10             	add    $0x10,%eax
     42a:	83 ec 08             	sub    $0x8,%esp
     42d:	ff 75 08             	pushl  0x8(%ebp)
     430:	50                   	push   %eax
     431:	e8 32 05 00 00       	call   968 <strcpy>
     436:	83 c4 10             	add    $0x10,%esp
	printf(1,"mkdir test\n");
     439:	83 ec 08             	sub    $0x8,%esp
     43c:	68 c1 11 00 00       	push   $0x11c1
     441:	6a 01                	push   $0x1
     443:	e8 10 09 00 00       	call   d58 <printf>
     448:	83 c4 10             	add    $0x10,%esp
	cv_signal(mutexreq);//signals server to read
     44b:	a1 80 37 00 00       	mov    0x3780,%eax
     450:	83 ec 0c             	sub    $0xc,%esp
     453:	50                   	push   %eax
     454:	e8 20 08 00 00       	call   c79 <cv_signal>
     459:	83 c4 10             	add    $0x10,%esp
	mutex_lock(mutexresp);
     45c:	a1 60 17 00 00       	mov    0x1760,%eax
     461:	83 ec 0c             	sub    $0xc,%esp
     464:	50                   	push   %eax
     465:	e8 f7 07 00 00       	call   c61 <mutex_lock>
     46a:	83 c4 10             	add    $0x10,%esp
	cv_wait(mutexresp);//waits on server to write	
     46d:	a1 60 17 00 00       	mov    0x1760,%eax
     472:	83 ec 0c             	sub    $0xc,%esp
     475:	50                   	push   %eax
     476:	e8 f6 07 00 00       	call   c71 <cv_wait>
     47b:	83 c4 10             	add    $0x10,%esp
	printf(1,"testme\n");
     47e:	83 ec 08             	sub    $0x8,%esp
     481:	68 cd 11 00 00       	push   $0x11cd
     486:	6a 01                	push   $0x1
     488:	e8 cb 08 00 00       	call   d58 <printf>
     48d:	83 c4 10             	add    $0x10,%esp
	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     490:	83 ec 08             	sub    $0x8,%esp
     493:	6a 08                	push   $0x8
     495:	68 71 11 00 00       	push   $0x1171
     49a:	e8 9a 07 00 00       	call   c39 <shm_get>
     49f:	83 c4 10             	add    $0x10,%esp
     4a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     4a5:	a1 60 17 00 00       	mov    0x1760,%eax
     4aa:	83 ec 0c             	sub    $0xc,%esp
     4ad:	50                   	push   %eax
     4ae:	e8 b6 07 00 00       	call   c69 <mutex_unlock>
     4b3:	83 c4 10             	add    $0x10,%esp

	retval=response->res;
     4b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
     4b9:	8b 00                	mov    (%eax),%eax
     4bb:	89 45 ec             	mov    %eax,-0x14(%ebp)

	return retval;
     4be:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
     4c1:	c9                   	leave  
     4c2:	c3                   	ret    

000004c3 <fss_unlink>:
int fss_unlink(char * path){
     4c3:	55                   	push   %ebp
     4c4:	89 e5                	mov    %esp,%ebp
     4c6:	83 ec 18             	sub    $0x18,%esp
	int retval;

	mutex_lock(mutexreq);//acquried mutex when writing to shm
     4c9:	a1 80 37 00 00       	mov    0x3780,%eax
     4ce:	83 ec 0c             	sub    $0xc,%esp
     4d1:	50                   	push   %eax
     4d2:	e8 8a 07 00 00       	call   c61 <mutex_lock>
     4d7:	83 c4 10             	add    $0x10,%esp

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
     4da:	83 ec 08             	sub    $0x8,%esp
     4dd:	6a 07                	push   $0x7
     4df:	68 3b 11 00 00       	push   $0x113b
     4e4:	e8 50 07 00 00       	call   c39 <shm_get>
     4e9:	83 c4 10             	add    $0x10,%esp
     4ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"unlink");
     4ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4f2:	83 ec 08             	sub    $0x8,%esp
     4f5:	68 d5 11 00 00       	push   $0x11d5
     4fa:	50                   	push   %eax
     4fb:	e8 68 04 00 00       	call   968 <strcpy>
     500:	83 c4 10             	add    $0x10,%esp
	//request->arg=n;
	//request->fd=fd1;
	strcpy(request->data,(char *)path);
     503:	8b 45 f4             	mov    -0xc(%ebp),%eax
     506:	83 c0 10             	add    $0x10,%eax
     509:	83 ec 08             	sub    $0x8,%esp
     50c:	ff 75 08             	pushl  0x8(%ebp)
     50f:	50                   	push   %eax
     510:	e8 53 04 00 00       	call   968 <strcpy>
     515:	83 c4 10             	add    $0x10,%esp

	cv_signal(mutexreq);//signals server to read
     518:	a1 80 37 00 00       	mov    0x3780,%eax
     51d:	83 ec 0c             	sub    $0xc,%esp
     520:	50                   	push   %eax
     521:	e8 53 07 00 00       	call   c79 <cv_signal>
     526:	83 c4 10             	add    $0x10,%esp
	
	cv_wait(mutexresp);//waits on server to write	
     529:	a1 60 17 00 00       	mov    0x1760,%eax
     52e:	83 ec 0c             	sub    $0xc,%esp
     531:	50                   	push   %eax
     532:	e8 3a 07 00 00       	call   c71 <cv_wait>
     537:	83 c4 10             	add    $0x10,%esp

	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     53a:	83 ec 08             	sub    $0x8,%esp
     53d:	6a 08                	push   $0x8
     53f:	68 71 11 00 00       	push   $0x1171
     544:	e8 f0 06 00 00       	call   c39 <shm_get>
     549:	83 c4 10             	add    $0x10,%esp
     54c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     54f:	a1 60 17 00 00       	mov    0x1760,%eax
     554:	83 ec 0c             	sub    $0xc,%esp
     557:	50                   	push   %eax
     558:	e8 0c 07 00 00       	call   c69 <mutex_unlock>
     55d:	83 c4 10             	add    $0x10,%esp

	retval=response->res;
     560:	8b 45 f0             	mov    -0x10(%ebp),%eax
     563:	8b 00                	mov    (%eax),%eax
     565:	89 45 ec             	mov    %eax,-0x14(%ebp)

	return retval;
     568:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
     56b:	c9                   	leave  
     56c:	c3                   	ret    

0000056d <fss_restore>:
int fss_restore(void){
     56d:	55                   	push   %ebp
     56e:	89 e5                	mov    %esp,%ebp
     570:	83 ec 18             	sub    $0x18,%esp
	int retval;

	mutex_lock(mutexreq);//acquried mutex when writing to shm
     573:	a1 80 37 00 00       	mov    0x3780,%eax
     578:	83 ec 0c             	sub    $0xc,%esp
     57b:	50                   	push   %eax
     57c:	e8 e0 06 00 00       	call   c61 <mutex_lock>
     581:	83 c4 10             	add    $0x10,%esp

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
     584:	83 ec 08             	sub    $0x8,%esp
     587:	6a 07                	push   $0x7
     589:	68 3b 11 00 00       	push   $0x113b
     58e:	e8 a6 06 00 00       	call   c39 <shm_get>
     593:	83 c4 10             	add    $0x10,%esp
     596:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"restore");
     599:	8b 45 f4             	mov    -0xc(%ebp),%eax
     59c:	83 ec 08             	sub    $0x8,%esp
     59f:	68 dc 11 00 00       	push   $0x11dc
     5a4:	50                   	push   %eax
     5a5:	e8 be 03 00 00       	call   968 <strcpy>
     5aa:	83 c4 10             	add    $0x10,%esp
	//request->arg=n;
	//request->fd=fd1;
	//strcpy(request->data,(char *)path);

	cv_signal(mutexreq);//signals server to read
     5ad:	a1 80 37 00 00       	mov    0x3780,%eax
     5b2:	83 ec 0c             	sub    $0xc,%esp
     5b5:	50                   	push   %eax
     5b6:	e8 be 06 00 00       	call   c79 <cv_signal>
     5bb:	83 c4 10             	add    $0x10,%esp
	
	cv_wait(mutexresp);//waits on server to write	
     5be:	a1 60 17 00 00       	mov    0x1760,%eax
     5c3:	83 ec 0c             	sub    $0xc,%esp
     5c6:	50                   	push   %eax
     5c7:	e8 a5 06 00 00       	call   c71 <cv_wait>
     5cc:	83 c4 10             	add    $0x10,%esp

	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     5cf:	83 ec 08             	sub    $0x8,%esp
     5d2:	6a 08                	push   $0x8
     5d4:	68 71 11 00 00       	push   $0x1171
     5d9:	e8 5b 06 00 00       	call   c39 <shm_get>
     5de:	83 c4 10             	add    $0x10,%esp
     5e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     5e4:	a1 60 17 00 00       	mov    0x1760,%eax
     5e9:	83 ec 0c             	sub    $0xc,%esp
     5ec:	50                   	push   %eax
     5ed:	e8 77 06 00 00       	call   c69 <mutex_unlock>
     5f2:	83 c4 10             	add    $0x10,%esp

	retval=response->res;
     5f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
     5f8:	8b 00                	mov    (%eax),%eax
     5fa:	89 45 ec             	mov    %eax,-0x14(%ebp)

	return retval;
     5fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
     600:	c9                   	leave  
     601:	c3                   	ret    

00000602 <main>:

//test for control cases of non server calls
char buf[8192];
char name[32];
int main(void)
{
     602:	8d 4c 24 04          	lea    0x4(%esp),%ecx
     606:	83 e4 f0             	and    $0xfffffff0,%esp
     609:	ff 71 fc             	pushl  -0x4(%ecx)
     60c:	55                   	push   %ebp
     60d:	89 e5                	mov    %esp,%ebp
     60f:	51                   	push   %ecx
     610:	83 ec 14             	sub    $0x14,%esp
	int fd;
	int i;

	printf(1, "small file test\n");
     613:	83 ec 08             	sub    $0x8,%esp
     616:	68 e4 11 00 00       	push   $0x11e4
     61b:	6a 01                	push   $0x1
     61d:	e8 36 07 00 00       	call   d58 <printf>
     622:	83 c4 10             	add    $0x10,%esp
	fd = open("small", O_CREATE | O_RDWR);
     625:	83 ec 08             	sub    $0x8,%esp
     628:	68 02 02 00 00       	push   $0x202
     62d:	68 f5 11 00 00       	push   $0x11f5
     632:	e8 a2 05 00 00       	call   bd9 <open>
     637:	83 c4 10             	add    $0x10,%esp
     63a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (fd >= 0) {
     63d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     641:	78 1e                	js     661 <main+0x5f>
		printf(1, "creat small succeeded; ok\n");
     643:	83 ec 08             	sub    $0x8,%esp
     646:	68 fb 11 00 00       	push   $0x11fb
     64b:	6a 01                	push   $0x1
     64d:	e8 06 07 00 00       	call   d58 <printf>
     652:	83 c4 10             	add    $0x10,%esp
	} else {
		printf(1, "error: creat small failed!\n");
		exit();
	}
	for (i = 0; i < 100; i++) {
     655:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     65c:	e9 83 00 00 00       	jmp    6e4 <main+0xe2>
	printf(1, "small file test\n");
	fd = open("small", O_CREATE | O_RDWR);
	if (fd >= 0) {
		printf(1, "creat small succeeded; ok\n");
	} else {
		printf(1, "error: creat small failed!\n");
     661:	83 ec 08             	sub    $0x8,%esp
     664:	68 16 12 00 00       	push   $0x1216
     669:	6a 01                	push   $0x1
     66b:	e8 e8 06 00 00       	call   d58 <printf>
     670:	83 c4 10             	add    $0x10,%esp
		exit();
     673:	e8 21 05 00 00       	call   b99 <exit>
	}
	for (i = 0; i < 100; i++) {
		if (write(fd, "aaaaaaaaaa", 10) != 10) {
     678:	83 ec 04             	sub    $0x4,%esp
     67b:	6a 0a                	push   $0xa
     67d:	68 32 12 00 00       	push   $0x1232
     682:	ff 75 f0             	pushl  -0x10(%ebp)
     685:	e8 2f 05 00 00       	call   bb9 <write>
     68a:	83 c4 10             	add    $0x10,%esp
     68d:	83 f8 0a             	cmp    $0xa,%eax
     690:	74 1a                	je     6ac <main+0xaa>
			printf(1, "error: write aa %d new file failed\n",
     692:	83 ec 04             	sub    $0x4,%esp
     695:	ff 75 f4             	pushl  -0xc(%ebp)
     698:	68 40 12 00 00       	push   $0x1240
     69d:	6a 01                	push   $0x1
     69f:	e8 b4 06 00 00       	call   d58 <printf>
     6a4:	83 c4 10             	add    $0x10,%esp
			       i);
			exit();
     6a7:	e8 ed 04 00 00       	call   b99 <exit>
		}
		if (write(fd, "bbbbbbbbbb", 10) != 10) {
     6ac:	83 ec 04             	sub    $0x4,%esp
     6af:	6a 0a                	push   $0xa
     6b1:	68 64 12 00 00       	push   $0x1264
     6b6:	ff 75 f0             	pushl  -0x10(%ebp)
     6b9:	e8 fb 04 00 00       	call   bb9 <write>
     6be:	83 c4 10             	add    $0x10,%esp
     6c1:	83 f8 0a             	cmp    $0xa,%eax
     6c4:	74 1a                	je     6e0 <main+0xde>
			printf(1, "error: write bb %d new file failed\n",
     6c6:	83 ec 04             	sub    $0x4,%esp
     6c9:	ff 75 f4             	pushl  -0xc(%ebp)
     6cc:	68 70 12 00 00       	push   $0x1270
     6d1:	6a 01                	push   $0x1
     6d3:	e8 80 06 00 00       	call   d58 <printf>
     6d8:	83 c4 10             	add    $0x10,%esp
			       i);
			exit();
     6db:	e8 b9 04 00 00       	call   b99 <exit>
		printf(1, "creat small succeeded; ok\n");
	} else {
		printf(1, "error: creat small failed!\n");
		exit();
	}
	for (i = 0; i < 100; i++) {
     6e0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     6e4:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
     6e8:	7e 8e                	jle    678 <main+0x76>
			printf(1, "error: write bb %d new file failed\n",
			       i);
			exit();
		}
	}
	printf(1, "writes ok\n");
     6ea:	83 ec 08             	sub    $0x8,%esp
     6ed:	68 94 12 00 00       	push   $0x1294
     6f2:	6a 01                	push   $0x1
     6f4:	e8 5f 06 00 00       	call   d58 <printf>
     6f9:	83 c4 10             	add    $0x10,%esp
	close(fd);
     6fc:	83 ec 0c             	sub    $0xc,%esp
     6ff:	ff 75 f0             	pushl  -0x10(%ebp)
     702:	e8 ba 04 00 00       	call   bc1 <close>
     707:	83 c4 10             	add    $0x10,%esp
	fd = open("small", O_RDONLY);
     70a:	83 ec 08             	sub    $0x8,%esp
     70d:	6a 00                	push   $0x0
     70f:	68 f5 11 00 00       	push   $0x11f5
     714:	e8 c0 04 00 00       	call   bd9 <open>
     719:	83 c4 10             	add    $0x10,%esp
     71c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (fd >= 0) {
     71f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     723:	78 4d                	js     772 <main+0x170>
		printf(1, "open small succeeded ok\n");
     725:	83 ec 08             	sub    $0x8,%esp
     728:	68 9f 12 00 00       	push   $0x129f
     72d:	6a 01                	push   $0x1
     72f:	e8 24 06 00 00       	call   d58 <printf>
     734:	83 c4 10             	add    $0x10,%esp
	} else {
		printf(1, "error: open small failed!\n");
		exit();
	}
	i = read(fd, buf, 2000);
     737:	83 ec 04             	sub    $0x4,%esp
     73a:	68 d0 07 00 00       	push   $0x7d0
     73f:	68 80 17 00 00       	push   $0x1780
     744:	ff 75 f0             	pushl  -0x10(%ebp)
     747:	e8 65 04 00 00       	call   bb1 <read>
     74c:	83 c4 10             	add    $0x10,%esp
     74f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	printf(1,"fd = %d\n",fd);
     752:	83 ec 04             	sub    $0x4,%esp
     755:	ff 75 f0             	pushl  -0x10(%ebp)
     758:	68 d3 12 00 00       	push   $0x12d3
     75d:	6a 01                	push   $0x1
     75f:	e8 f4 05 00 00       	call   d58 <printf>
     764:	83 c4 10             	add    $0x10,%esp
	if (i == 2000) {
     767:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
     76e:	75 4f                	jne    7bf <main+0x1bd>
     770:	eb 17                	jmp    789 <main+0x187>
	close(fd);
	fd = open("small", O_RDONLY);
	if (fd >= 0) {
		printf(1, "open small succeeded ok\n");
	} else {
		printf(1, "error: open small failed!\n");
     772:	83 ec 08             	sub    $0x8,%esp
     775:	68 b8 12 00 00       	push   $0x12b8
     77a:	6a 01                	push   $0x1
     77c:	e8 d7 05 00 00       	call   d58 <printf>
     781:	83 c4 10             	add    $0x10,%esp
		exit();
     784:	e8 10 04 00 00       	call   b99 <exit>
	}
	i = read(fd, buf, 2000);
	printf(1,"fd = %d\n",fd);
	if (i == 2000) {
		printf(1, "read succeeded ok\n");
     789:	83 ec 08             	sub    $0x8,%esp
     78c:	68 dc 12 00 00       	push   $0x12dc
     791:	6a 01                	push   $0x1
     793:	e8 c0 05 00 00       	call   d58 <printf>
     798:	83 c4 10             	add    $0x10,%esp
	} else {
		printf(1, "read failed\n");
		exit();
	}
	close(fd);
     79b:	83 ec 0c             	sub    $0xc,%esp
     79e:	ff 75 f0             	pushl  -0x10(%ebp)
     7a1:	e8 1b 04 00 00       	call   bc1 <close>
     7a6:	83 c4 10             	add    $0x10,%esp

	if (unlink("small") < 0) {
     7a9:	83 ec 0c             	sub    $0xc,%esp
     7ac:	68 f5 11 00 00       	push   $0x11f5
     7b1:	e8 33 04 00 00       	call   be9 <unlink>
     7b6:	83 c4 10             	add    $0x10,%esp
     7b9:	85 c0                	test   %eax,%eax
     7bb:	79 30                	jns    7ed <main+0x1eb>
     7bd:	eb 17                	jmp    7d6 <main+0x1d4>
	i = read(fd, buf, 2000);
	printf(1,"fd = %d\n",fd);
	if (i == 2000) {
		printf(1, "read succeeded ok\n");
	} else {
		printf(1, "read failed\n");
     7bf:	83 ec 08             	sub    $0x8,%esp
     7c2:	68 ef 12 00 00       	push   $0x12ef
     7c7:	6a 01                	push   $0x1
     7c9:	e8 8a 05 00 00       	call   d58 <printf>
     7ce:	83 c4 10             	add    $0x10,%esp
		exit();
     7d1:	e8 c3 03 00 00       	call   b99 <exit>
	}
	close(fd);

	if (unlink("small") < 0) {
		printf(1, "unlink small failed\n");
     7d6:	83 ec 08             	sub    $0x8,%esp
     7d9:	68 fc 12 00 00       	push   $0x12fc
     7de:	6a 01                	push   $0x1
     7e0:	e8 73 05 00 00       	call   d58 <printf>
     7e5:	83 c4 10             	add    $0x10,%esp
		exit();
     7e8:	e8 ac 03 00 00       	call   b99 <exit>
	}
	printf(1, "small file test ok\n");
     7ed:	83 ec 08             	sub    $0x8,%esp
     7f0:	68 11 13 00 00       	push   $0x1311
     7f5:	6a 01                	push   $0x1
     7f7:	e8 5c 05 00 00       	call   d58 <printf>
     7fc:	83 c4 10             	add    $0x10,%esp


	//testing CAT becacuse its easy to check if its working
printf(0, "cat\n");
     7ff:	83 ec 08             	sub    $0x8,%esp
     802:	68 25 13 00 00       	push   $0x1325
     807:	6a 00                	push   $0x0
     809:	e8 4a 05 00 00       	call   d58 <printf>
     80e:	83 c4 10             	add    $0x10,%esp
	

	//create files test  + unlink 


	printf(1, "many creates, followed by unlink test\n");
     811:	83 ec 08             	sub    $0x8,%esp
     814:	68 2c 13 00 00       	push   $0x132c
     819:	6a 01                	push   $0x1
     81b:	e8 38 05 00 00       	call   d58 <printf>
     820:	83 c4 10             	add    $0x10,%esp

	name[0] = 'a';
     823:	c6 05 a0 37 00 00 61 	movb   $0x61,0x37a0
	name[2] = '\0';
     82a:	c6 05 a2 37 00 00 00 	movb   $0x0,0x37a2
	for (i = 0; i < 52; i++) {
     831:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     838:	eb 35                	jmp    86f <main+0x26d>
		name[1] = '0' + i;
     83a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     83d:	83 c0 30             	add    $0x30,%eax
     840:	a2 a1 37 00 00       	mov    %al,0x37a1
		fd = open(name, O_CREATE | O_RDWR);
     845:	83 ec 08             	sub    $0x8,%esp
     848:	68 02 02 00 00       	push   $0x202
     84d:	68 a0 37 00 00       	push   $0x37a0
     852:	e8 82 03 00 00       	call   bd9 <open>
     857:	83 c4 10             	add    $0x10,%esp
     85a:	89 45 f0             	mov    %eax,-0x10(%ebp)
		close(fd);
     85d:	83 ec 0c             	sub    $0xc,%esp
     860:	ff 75 f0             	pushl  -0x10(%ebp)
     863:	e8 59 03 00 00       	call   bc1 <close>
     868:	83 c4 10             	add    $0x10,%esp

	printf(1, "many creates, followed by unlink test\n");

	name[0] = 'a';
	name[2] = '\0';
	for (i = 0; i < 52; i++) {
     86b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     86f:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
     873:	7e c5                	jle    83a <main+0x238>
		name[1] = '0' + i;
		fd = open(name, O_CREATE | O_RDWR);
		close(fd);
	}
	name[0] = 'a';
     875:	c6 05 a0 37 00 00 61 	movb   $0x61,0x37a0
	name[2] = '\0';
     87c:	c6 05 a2 37 00 00 00 	movb   $0x0,0x37a2
	for (i = 0; i < 52; i++) {
     883:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     88a:	eb 1f                	jmp    8ab <main+0x2a9>
		name[1] = '0' + i;
     88c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     88f:	83 c0 30             	add    $0x30,%eax
     892:	a2 a1 37 00 00       	mov    %al,0x37a1
		unlink(name);
     897:	83 ec 0c             	sub    $0xc,%esp
     89a:	68 a0 37 00 00       	push   $0x37a0
     89f:	e8 45 03 00 00       	call   be9 <unlink>
     8a4:	83 c4 10             	add    $0x10,%esp
		fd = open(name, O_CREATE | O_RDWR);
		close(fd);
	}
	name[0] = 'a';
	name[2] = '\0';
	for (i = 0; i < 52; i++) {
     8a7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     8ab:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
     8af:	7e db                	jle    88c <main+0x28a>
		name[1] = '0' + i;
		unlink(name);
	}
	printf(1, "many creates, followed by unlink; ok\n");
     8b1:	83 ec 08             	sub    $0x8,%esp
     8b4:	68 54 13 00 00       	push   $0x1354
     8b9:	6a 01                	push   $0x1
     8bb:	e8 98 04 00 00       	call   d58 <printf>
     8c0:	83 c4 10             	add    $0x10,%esp
	


//mkdir test and unlink 
printf(1, "mkdir test and unlink\n");
     8c3:	83 ec 08             	sub    $0x8,%esp
     8c6:	68 7a 13 00 00       	push   $0x137a
     8cb:	6a 01                	push   $0x1
     8cd:	e8 86 04 00 00       	call   d58 <printf>
     8d2:	83 c4 10             	add    $0x10,%esp

	if (mkdir("dir0") < 0) {
     8d5:	83 ec 0c             	sub    $0xc,%esp
     8d8:	68 91 13 00 00       	push   $0x1391
     8dd:	e8 1f 03 00 00       	call   c01 <mkdir>
     8e2:	83 c4 10             	add    $0x10,%esp
     8e5:	85 c0                	test   %eax,%eax
     8e7:	79 17                	jns    900 <main+0x2fe>
		printf(1, "mkdir failed\n");
     8e9:	83 ec 08             	sub    $0x8,%esp
     8ec:	68 96 13 00 00       	push   $0x1396
     8f1:	6a 01                	push   $0x1
     8f3:	e8 60 04 00 00       	call   d58 <printf>
     8f8:	83 c4 10             	add    $0x10,%esp
		exit();
     8fb:	e8 99 02 00 00       	call   b99 <exit>
	}
	if (unlink("dir0") < 0) {
     900:	83 ec 0c             	sub    $0xc,%esp
     903:	68 91 13 00 00       	push   $0x1391
     908:	e8 dc 02 00 00       	call   be9 <unlink>
     90d:	83 c4 10             	add    $0x10,%esp
     910:	85 c0                	test   %eax,%eax
     912:	79 17                	jns    92b <main+0x329>
		printf(1, "unlink dir0 failed\n");
     914:	83 ec 08             	sub    $0x8,%esp
     917:	68 a4 13 00 00       	push   $0x13a4
     91c:	6a 01                	push   $0x1
     91e:	e8 35 04 00 00       	call   d58 <printf>
     923:	83 c4 10             	add    $0x10,%esp
		exit();
     926:	e8 6e 02 00 00       	call   b99 <exit>
	}
	printf(1, "mkdir test ok\n");
     92b:	83 ec 08             	sub    $0x8,%esp
     92e:	68 b8 13 00 00       	push   $0x13b8
     933:	6a 01                	push   $0x1
     935:	e8 1e 04 00 00       	call   d58 <printf>
     93a:	83 c4 10             	add    $0x10,%esp
exit();
     93d:	e8 57 02 00 00       	call   b99 <exit>

00000942 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     942:	55                   	push   %ebp
     943:	89 e5                	mov    %esp,%ebp
     945:	57                   	push   %edi
     946:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     947:	8b 4d 08             	mov    0x8(%ebp),%ecx
     94a:	8b 55 10             	mov    0x10(%ebp),%edx
     94d:	8b 45 0c             	mov    0xc(%ebp),%eax
     950:	89 cb                	mov    %ecx,%ebx
     952:	89 df                	mov    %ebx,%edi
     954:	89 d1                	mov    %edx,%ecx
     956:	fc                   	cld    
     957:	f3 aa                	rep stos %al,%es:(%edi)
     959:	89 ca                	mov    %ecx,%edx
     95b:	89 fb                	mov    %edi,%ebx
     95d:	89 5d 08             	mov    %ebx,0x8(%ebp)
     960:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     963:	90                   	nop
     964:	5b                   	pop    %ebx
     965:	5f                   	pop    %edi
     966:	5d                   	pop    %ebp
     967:	c3                   	ret    

00000968 <strcpy>:
#include "fcntl.h"
#include "user.h"
#include "x86.h"

char *strcpy(char *s, char *t)
{
     968:	55                   	push   %ebp
     969:	89 e5                	mov    %esp,%ebp
     96b:	83 ec 10             	sub    $0x10,%esp
	char *os;

	os = s;
     96e:	8b 45 08             	mov    0x8(%ebp),%eax
     971:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*s++ = *t++) != 0) ;
     974:	90                   	nop
     975:	8b 45 08             	mov    0x8(%ebp),%eax
     978:	8d 50 01             	lea    0x1(%eax),%edx
     97b:	89 55 08             	mov    %edx,0x8(%ebp)
     97e:	8b 55 0c             	mov    0xc(%ebp),%edx
     981:	8d 4a 01             	lea    0x1(%edx),%ecx
     984:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     987:	0f b6 12             	movzbl (%edx),%edx
     98a:	88 10                	mov    %dl,(%eax)
     98c:	0f b6 00             	movzbl (%eax),%eax
     98f:	84 c0                	test   %al,%al
     991:	75 e2                	jne    975 <strcpy+0xd>
	return os;
     993:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     996:	c9                   	leave  
     997:	c3                   	ret    

00000998 <strcmp>:

int strcmp(const char *p, const char *q)
{
     998:	55                   	push   %ebp
     999:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
     99b:	eb 08                	jmp    9a5 <strcmp+0xd>
		p++, q++;
     99d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     9a1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	return os;
}

int strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
     9a5:	8b 45 08             	mov    0x8(%ebp),%eax
     9a8:	0f b6 00             	movzbl (%eax),%eax
     9ab:	84 c0                	test   %al,%al
     9ad:	74 10                	je     9bf <strcmp+0x27>
     9af:	8b 45 08             	mov    0x8(%ebp),%eax
     9b2:	0f b6 10             	movzbl (%eax),%edx
     9b5:	8b 45 0c             	mov    0xc(%ebp),%eax
     9b8:	0f b6 00             	movzbl (%eax),%eax
     9bb:	38 c2                	cmp    %al,%dl
     9bd:	74 de                	je     99d <strcmp+0x5>
		p++, q++;
	return (uchar) * p - (uchar) * q;
     9bf:	8b 45 08             	mov    0x8(%ebp),%eax
     9c2:	0f b6 00             	movzbl (%eax),%eax
     9c5:	0f b6 d0             	movzbl %al,%edx
     9c8:	8b 45 0c             	mov    0xc(%ebp),%eax
     9cb:	0f b6 00             	movzbl (%eax),%eax
     9ce:	0f b6 c0             	movzbl %al,%eax
     9d1:	29 c2                	sub    %eax,%edx
     9d3:	89 d0                	mov    %edx,%eax
}
     9d5:	5d                   	pop    %ebp
     9d6:	c3                   	ret    

000009d7 <strlen>:

uint strlen(char *s)
{
     9d7:	55                   	push   %ebp
     9d8:	89 e5                	mov    %esp,%ebp
     9da:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; s[n]; n++) ;
     9dd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     9e4:	eb 04                	jmp    9ea <strlen+0x13>
     9e6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     9ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
     9ed:	8b 45 08             	mov    0x8(%ebp),%eax
     9f0:	01 d0                	add    %edx,%eax
     9f2:	0f b6 00             	movzbl (%eax),%eax
     9f5:	84 c0                	test   %al,%al
     9f7:	75 ed                	jne    9e6 <strlen+0xf>
	return n;
     9f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     9fc:	c9                   	leave  
     9fd:	c3                   	ret    

000009fe <memset>:

void *memset(void *dst, int c, uint n)
{
     9fe:	55                   	push   %ebp
     9ff:	89 e5                	mov    %esp,%ebp
	stosb(dst, c, n);
     a01:	8b 45 10             	mov    0x10(%ebp),%eax
     a04:	50                   	push   %eax
     a05:	ff 75 0c             	pushl  0xc(%ebp)
     a08:	ff 75 08             	pushl  0x8(%ebp)
     a0b:	e8 32 ff ff ff       	call   942 <stosb>
     a10:	83 c4 0c             	add    $0xc,%esp
	return dst;
     a13:	8b 45 08             	mov    0x8(%ebp),%eax
}
     a16:	c9                   	leave  
     a17:	c3                   	ret    

00000a18 <strchr>:

char *strchr(const char *s, char c)
{
     a18:	55                   	push   %ebp
     a19:	89 e5                	mov    %esp,%ebp
     a1b:	83 ec 04             	sub    $0x4,%esp
     a1e:	8b 45 0c             	mov    0xc(%ebp),%eax
     a21:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
     a24:	eb 14                	jmp    a3a <strchr+0x22>
		if (*s == c)
     a26:	8b 45 08             	mov    0x8(%ebp),%eax
     a29:	0f b6 00             	movzbl (%eax),%eax
     a2c:	3a 45 fc             	cmp    -0x4(%ebp),%al
     a2f:	75 05                	jne    a36 <strchr+0x1e>
			return (char *)s;
     a31:	8b 45 08             	mov    0x8(%ebp),%eax
     a34:	eb 13                	jmp    a49 <strchr+0x31>
	return dst;
}

char *strchr(const char *s, char c)
{
	for (; *s; s++)
     a36:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     a3a:	8b 45 08             	mov    0x8(%ebp),%eax
     a3d:	0f b6 00             	movzbl (%eax),%eax
     a40:	84 c0                	test   %al,%al
     a42:	75 e2                	jne    a26 <strchr+0xe>
		if (*s == c)
			return (char *)s;
	return 0;
     a44:	b8 00 00 00 00       	mov    $0x0,%eax
}
     a49:	c9                   	leave  
     a4a:	c3                   	ret    

00000a4b <gets>:

char *gets(char *buf, int max)
{
     a4b:	55                   	push   %ebp
     a4c:	89 e5                	mov    %esp,%ebp
     a4e:	83 ec 18             	sub    $0x18,%esp
	int i, cc;
	char c;

	for (i = 0; i + 1 < max;) {
     a51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     a58:	eb 42                	jmp    a9c <gets+0x51>
		cc = read(0, &c, 1);
     a5a:	83 ec 04             	sub    $0x4,%esp
     a5d:	6a 01                	push   $0x1
     a5f:	8d 45 ef             	lea    -0x11(%ebp),%eax
     a62:	50                   	push   %eax
     a63:	6a 00                	push   $0x0
     a65:	e8 47 01 00 00       	call   bb1 <read>
     a6a:	83 c4 10             	add    $0x10,%esp
     a6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (cc < 1)
     a70:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     a74:	7e 33                	jle    aa9 <gets+0x5e>
			break;
		buf[i++] = c;
     a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a79:	8d 50 01             	lea    0x1(%eax),%edx
     a7c:	89 55 f4             	mov    %edx,-0xc(%ebp)
     a7f:	89 c2                	mov    %eax,%edx
     a81:	8b 45 08             	mov    0x8(%ebp),%eax
     a84:	01 c2                	add    %eax,%edx
     a86:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     a8a:	88 02                	mov    %al,(%edx)
		if (c == '\n' || c == '\r')
     a8c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     a90:	3c 0a                	cmp    $0xa,%al
     a92:	74 16                	je     aaa <gets+0x5f>
     a94:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     a98:	3c 0d                	cmp    $0xd,%al
     a9a:	74 0e                	je     aaa <gets+0x5f>
char *gets(char *buf, int max)
{
	int i, cc;
	char c;

	for (i = 0; i + 1 < max;) {
     a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a9f:	83 c0 01             	add    $0x1,%eax
     aa2:	3b 45 0c             	cmp    0xc(%ebp),%eax
     aa5:	7c b3                	jl     a5a <gets+0xf>
     aa7:	eb 01                	jmp    aaa <gets+0x5f>
		cc = read(0, &c, 1);
		if (cc < 1)
			break;
     aa9:	90                   	nop
		buf[i++] = c;
		if (c == '\n' || c == '\r')
			break;
	}
	buf[i] = '\0';
     aaa:	8b 55 f4             	mov    -0xc(%ebp),%edx
     aad:	8b 45 08             	mov    0x8(%ebp),%eax
     ab0:	01 d0                	add    %edx,%eax
     ab2:	c6 00 00             	movb   $0x0,(%eax)
	return buf;
     ab5:	8b 45 08             	mov    0x8(%ebp),%eax
}
     ab8:	c9                   	leave  
     ab9:	c3                   	ret    

00000aba <stat>:

int stat(char *n, struct stat *st)
{
     aba:	55                   	push   %ebp
     abb:	89 e5                	mov    %esp,%ebp
     abd:	83 ec 18             	sub    $0x18,%esp
	int fd;
	int r;

	fd = open(n, O_RDONLY);
     ac0:	83 ec 08             	sub    $0x8,%esp
     ac3:	6a 00                	push   $0x0
     ac5:	ff 75 08             	pushl  0x8(%ebp)
     ac8:	e8 0c 01 00 00       	call   bd9 <open>
     acd:	83 c4 10             	add    $0x10,%esp
     ad0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (fd < 0)
     ad3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     ad7:	79 07                	jns    ae0 <stat+0x26>
		return -1;
     ad9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     ade:	eb 25                	jmp    b05 <stat+0x4b>
	r = fstat(fd, st);
     ae0:	83 ec 08             	sub    $0x8,%esp
     ae3:	ff 75 0c             	pushl  0xc(%ebp)
     ae6:	ff 75 f4             	pushl  -0xc(%ebp)
     ae9:	e8 03 01 00 00       	call   bf1 <fstat>
     aee:	83 c4 10             	add    $0x10,%esp
     af1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	close(fd);
     af4:	83 ec 0c             	sub    $0xc,%esp
     af7:	ff 75 f4             	pushl  -0xc(%ebp)
     afa:	e8 c2 00 00 00       	call   bc1 <close>
     aff:	83 c4 10             	add    $0x10,%esp
	return r;
     b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     b05:	c9                   	leave  
     b06:	c3                   	ret    

00000b07 <atoi>:

int atoi(const char *s)
{
     b07:	55                   	push   %ebp
     b08:	89 e5                	mov    %esp,%ebp
     b0a:	83 ec 10             	sub    $0x10,%esp
	int n;

	n = 0;
     b0d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	while ('0' <= *s && *s <= '9')
     b14:	eb 25                	jmp    b3b <atoi+0x34>
		n = n * 10 + *s++ - '0';
     b16:	8b 55 fc             	mov    -0x4(%ebp),%edx
     b19:	89 d0                	mov    %edx,%eax
     b1b:	c1 e0 02             	shl    $0x2,%eax
     b1e:	01 d0                	add    %edx,%eax
     b20:	01 c0                	add    %eax,%eax
     b22:	89 c1                	mov    %eax,%ecx
     b24:	8b 45 08             	mov    0x8(%ebp),%eax
     b27:	8d 50 01             	lea    0x1(%eax),%edx
     b2a:	89 55 08             	mov    %edx,0x8(%ebp)
     b2d:	0f b6 00             	movzbl (%eax),%eax
     b30:	0f be c0             	movsbl %al,%eax
     b33:	01 c8                	add    %ecx,%eax
     b35:	83 e8 30             	sub    $0x30,%eax
     b38:	89 45 fc             	mov    %eax,-0x4(%ebp)
int atoi(const char *s)
{
	int n;

	n = 0;
	while ('0' <= *s && *s <= '9')
     b3b:	8b 45 08             	mov    0x8(%ebp),%eax
     b3e:	0f b6 00             	movzbl (%eax),%eax
     b41:	3c 2f                	cmp    $0x2f,%al
     b43:	7e 0a                	jle    b4f <atoi+0x48>
     b45:	8b 45 08             	mov    0x8(%ebp),%eax
     b48:	0f b6 00             	movzbl (%eax),%eax
     b4b:	3c 39                	cmp    $0x39,%al
     b4d:	7e c7                	jle    b16 <atoi+0xf>
		n = n * 10 + *s++ - '0';
	return n;
     b4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     b52:	c9                   	leave  
     b53:	c3                   	ret    

00000b54 <memmove>:

void *memmove(void *vdst, void *vsrc, int n)
{
     b54:	55                   	push   %ebp
     b55:	89 e5                	mov    %esp,%ebp
     b57:	83 ec 10             	sub    $0x10,%esp
	char *dst, *src;

	dst = vdst;
     b5a:	8b 45 08             	mov    0x8(%ebp),%eax
     b5d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	src = vsrc;
     b60:	8b 45 0c             	mov    0xc(%ebp),%eax
     b63:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
     b66:	eb 17                	jmp    b7f <memmove+0x2b>
		*dst++ = *src++;
     b68:	8b 45 fc             	mov    -0x4(%ebp),%eax
     b6b:	8d 50 01             	lea    0x1(%eax),%edx
     b6e:	89 55 fc             	mov    %edx,-0x4(%ebp)
     b71:	8b 55 f8             	mov    -0x8(%ebp),%edx
     b74:	8d 4a 01             	lea    0x1(%edx),%ecx
     b77:	89 4d f8             	mov    %ecx,-0x8(%ebp)
     b7a:	0f b6 12             	movzbl (%edx),%edx
     b7d:	88 10                	mov    %dl,(%eax)
{
	char *dst, *src;

	dst = vdst;
	src = vsrc;
	while (n-- > 0)
     b7f:	8b 45 10             	mov    0x10(%ebp),%eax
     b82:	8d 50 ff             	lea    -0x1(%eax),%edx
     b85:	89 55 10             	mov    %edx,0x10(%ebp)
     b88:	85 c0                	test   %eax,%eax
     b8a:	7f dc                	jg     b68 <memmove+0x14>
		*dst++ = *src++;
	return vdst;
     b8c:	8b 45 08             	mov    0x8(%ebp),%eax
}
     b8f:	c9                   	leave  
     b90:	c3                   	ret    

00000b91 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     b91:	b8 01 00 00 00       	mov    $0x1,%eax
     b96:	cd 40                	int    $0x40
     b98:	c3                   	ret    

00000b99 <exit>:
SYSCALL(exit)
     b99:	b8 02 00 00 00       	mov    $0x2,%eax
     b9e:	cd 40                	int    $0x40
     ba0:	c3                   	ret    

00000ba1 <wait>:
SYSCALL(wait)
     ba1:	b8 03 00 00 00       	mov    $0x3,%eax
     ba6:	cd 40                	int    $0x40
     ba8:	c3                   	ret    

00000ba9 <pipe>:
SYSCALL(pipe)
     ba9:	b8 04 00 00 00       	mov    $0x4,%eax
     bae:	cd 40                	int    $0x40
     bb0:	c3                   	ret    

00000bb1 <read>:
SYSCALL(read)
     bb1:	b8 05 00 00 00       	mov    $0x5,%eax
     bb6:	cd 40                	int    $0x40
     bb8:	c3                   	ret    

00000bb9 <write>:
SYSCALL(write)
     bb9:	b8 10 00 00 00       	mov    $0x10,%eax
     bbe:	cd 40                	int    $0x40
     bc0:	c3                   	ret    

00000bc1 <close>:
SYSCALL(close)
     bc1:	b8 15 00 00 00       	mov    $0x15,%eax
     bc6:	cd 40                	int    $0x40
     bc8:	c3                   	ret    

00000bc9 <kill>:
SYSCALL(kill)
     bc9:	b8 06 00 00 00       	mov    $0x6,%eax
     bce:	cd 40                	int    $0x40
     bd0:	c3                   	ret    

00000bd1 <exec>:
SYSCALL(exec)
     bd1:	b8 07 00 00 00       	mov    $0x7,%eax
     bd6:	cd 40                	int    $0x40
     bd8:	c3                   	ret    

00000bd9 <open>:
SYSCALL(open)
     bd9:	b8 0f 00 00 00       	mov    $0xf,%eax
     bde:	cd 40                	int    $0x40
     be0:	c3                   	ret    

00000be1 <mknod>:
SYSCALL(mknod)
     be1:	b8 11 00 00 00       	mov    $0x11,%eax
     be6:	cd 40                	int    $0x40
     be8:	c3                   	ret    

00000be9 <unlink>:
SYSCALL(unlink)
     be9:	b8 12 00 00 00       	mov    $0x12,%eax
     bee:	cd 40                	int    $0x40
     bf0:	c3                   	ret    

00000bf1 <fstat>:
SYSCALL(fstat)
     bf1:	b8 08 00 00 00       	mov    $0x8,%eax
     bf6:	cd 40                	int    $0x40
     bf8:	c3                   	ret    

00000bf9 <link>:
SYSCALL(link)
     bf9:	b8 13 00 00 00       	mov    $0x13,%eax
     bfe:	cd 40                	int    $0x40
     c00:	c3                   	ret    

00000c01 <mkdir>:
SYSCALL(mkdir)
     c01:	b8 14 00 00 00       	mov    $0x14,%eax
     c06:	cd 40                	int    $0x40
     c08:	c3                   	ret    

00000c09 <chdir>:
SYSCALL(chdir)
     c09:	b8 09 00 00 00       	mov    $0x9,%eax
     c0e:	cd 40                	int    $0x40
     c10:	c3                   	ret    

00000c11 <dup>:
SYSCALL(dup)
     c11:	b8 0a 00 00 00       	mov    $0xa,%eax
     c16:	cd 40                	int    $0x40
     c18:	c3                   	ret    

00000c19 <getpid>:
SYSCALL(getpid)
     c19:	b8 0b 00 00 00       	mov    $0xb,%eax
     c1e:	cd 40                	int    $0x40
     c20:	c3                   	ret    

00000c21 <sbrk>:
SYSCALL(sbrk)
     c21:	b8 0c 00 00 00       	mov    $0xc,%eax
     c26:	cd 40                	int    $0x40
     c28:	c3                   	ret    

00000c29 <sleep>:
SYSCALL(sleep)
     c29:	b8 0d 00 00 00       	mov    $0xd,%eax
     c2e:	cd 40                	int    $0x40
     c30:	c3                   	ret    

00000c31 <uptime>:
SYSCALL(uptime)
     c31:	b8 0e 00 00 00       	mov    $0xe,%eax
     c36:	cd 40                	int    $0x40
     c38:	c3                   	ret    

00000c39 <shm_get>:
SYSCALL(shm_get) //mod2
     c39:	b8 1c 00 00 00       	mov    $0x1c,%eax
     c3e:	cd 40                	int    $0x40
     c40:	c3                   	ret    

00000c41 <shm_rem>:
SYSCALL(shm_rem) //mod2
     c41:	b8 1d 00 00 00       	mov    $0x1d,%eax
     c46:	cd 40                	int    $0x40
     c48:	c3                   	ret    

00000c49 <setHighPrio>:
SYSCALL(setHighPrio) //scheduler
     c49:	b8 1e 00 00 00       	mov    $0x1e,%eax
     c4e:	cd 40                	int    $0x40
     c50:	c3                   	ret    

00000c51 <mutex_create>:
SYSCALL(mutex_create)//mod3
     c51:	b8 16 00 00 00       	mov    $0x16,%eax
     c56:	cd 40                	int    $0x40
     c58:	c3                   	ret    

00000c59 <mutex_delete>:
SYSCALL(mutex_delete)
     c59:	b8 17 00 00 00       	mov    $0x17,%eax
     c5e:	cd 40                	int    $0x40
     c60:	c3                   	ret    

00000c61 <mutex_lock>:
SYSCALL(mutex_lock)
     c61:	b8 18 00 00 00       	mov    $0x18,%eax
     c66:	cd 40                	int    $0x40
     c68:	c3                   	ret    

00000c69 <mutex_unlock>:
SYSCALL(mutex_unlock)
     c69:	b8 19 00 00 00       	mov    $0x19,%eax
     c6e:	cd 40                	int    $0x40
     c70:	c3                   	ret    

00000c71 <cv_wait>:
SYSCALL(cv_wait)
     c71:	b8 1a 00 00 00       	mov    $0x1a,%eax
     c76:	cd 40                	int    $0x40
     c78:	c3                   	ret    

00000c79 <cv_signal>:
SYSCALL(cv_signal)
     c79:	b8 1b 00 00 00       	mov    $0x1b,%eax
     c7e:	cd 40                	int    $0x40
     c80:	c3                   	ret    

00000c81 <putc>:
#include "types.h"
#include "stat.h"
#include "user.h"

static void putc(int fd, char c)
{
     c81:	55                   	push   %ebp
     c82:	89 e5                	mov    %esp,%ebp
     c84:	83 ec 18             	sub    $0x18,%esp
     c87:	8b 45 0c             	mov    0xc(%ebp),%eax
     c8a:	88 45 f4             	mov    %al,-0xc(%ebp)
	write(fd, &c, 1);
     c8d:	83 ec 04             	sub    $0x4,%esp
     c90:	6a 01                	push   $0x1
     c92:	8d 45 f4             	lea    -0xc(%ebp),%eax
     c95:	50                   	push   %eax
     c96:	ff 75 08             	pushl  0x8(%ebp)
     c99:	e8 1b ff ff ff       	call   bb9 <write>
     c9e:	83 c4 10             	add    $0x10,%esp
}
     ca1:	90                   	nop
     ca2:	c9                   	leave  
     ca3:	c3                   	ret    

00000ca4 <printint>:

static void printint(int fd, int xx, int base, int sgn)
{
     ca4:	55                   	push   %ebp
     ca5:	89 e5                	mov    %esp,%ebp
     ca7:	53                   	push   %ebx
     ca8:	83 ec 24             	sub    $0x24,%esp
	static char digits[] = "0123456789ABCDEF";
	char buf[16];
	int i, neg;
	uint x;

	neg = 0;
     cab:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	if (sgn && xx < 0) {
     cb2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     cb6:	74 17                	je     ccf <printint+0x2b>
     cb8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
     cbc:	79 11                	jns    ccf <printint+0x2b>
		neg = 1;
     cbe:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
		x = -xx;
     cc5:	8b 45 0c             	mov    0xc(%ebp),%eax
     cc8:	f7 d8                	neg    %eax
     cca:	89 45 ec             	mov    %eax,-0x14(%ebp)
     ccd:	eb 06                	jmp    cd5 <printint+0x31>
	} else {
		x = xx;
     ccf:	8b 45 0c             	mov    0xc(%ebp),%eax
     cd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
	}

	i = 0;
     cd5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	do {
		buf[i++] = digits[x % base];
     cdc:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     cdf:	8d 41 01             	lea    0x1(%ecx),%eax
     ce2:	89 45 f4             	mov    %eax,-0xc(%ebp)
     ce5:	8b 5d 10             	mov    0x10(%ebp),%ebx
     ce8:	8b 45 ec             	mov    -0x14(%ebp),%eax
     ceb:	ba 00 00 00 00       	mov    $0x0,%edx
     cf0:	f7 f3                	div    %ebx
     cf2:	89 d0                	mov    %edx,%eax
     cf4:	0f b6 80 18 17 00 00 	movzbl 0x1718(%eax),%eax
     cfb:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
	} while ((x /= base) != 0);
     cff:	8b 5d 10             	mov    0x10(%ebp),%ebx
     d02:	8b 45 ec             	mov    -0x14(%ebp),%eax
     d05:	ba 00 00 00 00       	mov    $0x0,%edx
     d0a:	f7 f3                	div    %ebx
     d0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
     d0f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     d13:	75 c7                	jne    cdc <printint+0x38>
	if (neg)
     d15:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     d19:	74 2d                	je     d48 <printint+0xa4>
		buf[i++] = '-';
     d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d1e:	8d 50 01             	lea    0x1(%eax),%edx
     d21:	89 55 f4             	mov    %edx,-0xc(%ebp)
     d24:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

	while (--i >= 0)
     d29:	eb 1d                	jmp    d48 <printint+0xa4>
		putc(fd, buf[i]);
     d2b:	8d 55 dc             	lea    -0x24(%ebp),%edx
     d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d31:	01 d0                	add    %edx,%eax
     d33:	0f b6 00             	movzbl (%eax),%eax
     d36:	0f be c0             	movsbl %al,%eax
     d39:	83 ec 08             	sub    $0x8,%esp
     d3c:	50                   	push   %eax
     d3d:	ff 75 08             	pushl  0x8(%ebp)
     d40:	e8 3c ff ff ff       	call   c81 <putc>
     d45:	83 c4 10             	add    $0x10,%esp
		buf[i++] = digits[x % base];
	} while ((x /= base) != 0);
	if (neg)
		buf[i++] = '-';

	while (--i >= 0)
     d48:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
     d4c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     d50:	79 d9                	jns    d2b <printint+0x87>
		putc(fd, buf[i]);
}
     d52:	90                   	nop
     d53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     d56:	c9                   	leave  
     d57:	c3                   	ret    

00000d58 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void printf(int fd, char *fmt, ...)
{
     d58:	55                   	push   %ebp
     d59:	89 e5                	mov    %esp,%ebp
     d5b:	83 ec 28             	sub    $0x28,%esp
	char *s;
	int c, i, state;
	uint *ap;

	state = 0;
     d5e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	ap = (uint *) (void *)&fmt + 1;
     d65:	8d 45 0c             	lea    0xc(%ebp),%eax
     d68:	83 c0 04             	add    $0x4,%eax
     d6b:	89 45 e8             	mov    %eax,-0x18(%ebp)
	for (i = 0; fmt[i]; i++) {
     d6e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     d75:	e9 59 01 00 00       	jmp    ed3 <printf+0x17b>
		c = fmt[i] & 0xff;
     d7a:	8b 55 0c             	mov    0xc(%ebp),%edx
     d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     d80:	01 d0                	add    %edx,%eax
     d82:	0f b6 00             	movzbl (%eax),%eax
     d85:	0f be c0             	movsbl %al,%eax
     d88:	25 ff 00 00 00       	and    $0xff,%eax
     d8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (state == 0) {
     d90:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     d94:	75 2c                	jne    dc2 <printf+0x6a>
			if (c == '%') {
     d96:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
     d9a:	75 0c                	jne    da8 <printf+0x50>
				state = '%';
     d9c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
     da3:	e9 27 01 00 00       	jmp    ecf <printf+0x177>
			} else {
				putc(fd, c);
     da8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     dab:	0f be c0             	movsbl %al,%eax
     dae:	83 ec 08             	sub    $0x8,%esp
     db1:	50                   	push   %eax
     db2:	ff 75 08             	pushl  0x8(%ebp)
     db5:	e8 c7 fe ff ff       	call   c81 <putc>
     dba:	83 c4 10             	add    $0x10,%esp
     dbd:	e9 0d 01 00 00       	jmp    ecf <printf+0x177>
			}
		} else if (state == '%') {
     dc2:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
     dc6:	0f 85 03 01 00 00    	jne    ecf <printf+0x177>
			if (c == 'd') {
     dcc:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
     dd0:	75 1e                	jne    df0 <printf+0x98>
				printint(fd, *ap, 10, 1);
     dd2:	8b 45 e8             	mov    -0x18(%ebp),%eax
     dd5:	8b 00                	mov    (%eax),%eax
     dd7:	6a 01                	push   $0x1
     dd9:	6a 0a                	push   $0xa
     ddb:	50                   	push   %eax
     ddc:	ff 75 08             	pushl  0x8(%ebp)
     ddf:	e8 c0 fe ff ff       	call   ca4 <printint>
     de4:	83 c4 10             	add    $0x10,%esp
				ap++;
     de7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
     deb:	e9 d8 00 00 00       	jmp    ec8 <printf+0x170>
			} else if (c == 'x' || c == 'p') {
     df0:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
     df4:	74 06                	je     dfc <printf+0xa4>
     df6:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
     dfa:	75 1e                	jne    e1a <printf+0xc2>
				printint(fd, *ap, 16, 0);
     dfc:	8b 45 e8             	mov    -0x18(%ebp),%eax
     dff:	8b 00                	mov    (%eax),%eax
     e01:	6a 00                	push   $0x0
     e03:	6a 10                	push   $0x10
     e05:	50                   	push   %eax
     e06:	ff 75 08             	pushl  0x8(%ebp)
     e09:	e8 96 fe ff ff       	call   ca4 <printint>
     e0e:	83 c4 10             	add    $0x10,%esp
				ap++;
     e11:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
     e15:	e9 ae 00 00 00       	jmp    ec8 <printf+0x170>
			} else if (c == 's') {
     e1a:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
     e1e:	75 43                	jne    e63 <printf+0x10b>
				s = (char *)*ap;
     e20:	8b 45 e8             	mov    -0x18(%ebp),%eax
     e23:	8b 00                	mov    (%eax),%eax
     e25:	89 45 f4             	mov    %eax,-0xc(%ebp)
				ap++;
     e28:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
				if (s == 0)
     e2c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     e30:	75 25                	jne    e57 <printf+0xff>
					s = "(null)";
     e32:	c7 45 f4 c7 13 00 00 	movl   $0x13c7,-0xc(%ebp)
				while (*s != 0) {
     e39:	eb 1c                	jmp    e57 <printf+0xff>
					putc(fd, *s);
     e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e3e:	0f b6 00             	movzbl (%eax),%eax
     e41:	0f be c0             	movsbl %al,%eax
     e44:	83 ec 08             	sub    $0x8,%esp
     e47:	50                   	push   %eax
     e48:	ff 75 08             	pushl  0x8(%ebp)
     e4b:	e8 31 fe ff ff       	call   c81 <putc>
     e50:	83 c4 10             	add    $0x10,%esp
					s++;
     e53:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
			} else if (c == 's') {
				s = (char *)*ap;
				ap++;
				if (s == 0)
					s = "(null)";
				while (*s != 0) {
     e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e5a:	0f b6 00             	movzbl (%eax),%eax
     e5d:	84 c0                	test   %al,%al
     e5f:	75 da                	jne    e3b <printf+0xe3>
     e61:	eb 65                	jmp    ec8 <printf+0x170>
					putc(fd, *s);
					s++;
				}
			} else if (c == 'c') {
     e63:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
     e67:	75 1d                	jne    e86 <printf+0x12e>
				putc(fd, *ap);
     e69:	8b 45 e8             	mov    -0x18(%ebp),%eax
     e6c:	8b 00                	mov    (%eax),%eax
     e6e:	0f be c0             	movsbl %al,%eax
     e71:	83 ec 08             	sub    $0x8,%esp
     e74:	50                   	push   %eax
     e75:	ff 75 08             	pushl  0x8(%ebp)
     e78:	e8 04 fe ff ff       	call   c81 <putc>
     e7d:	83 c4 10             	add    $0x10,%esp
				ap++;
     e80:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
     e84:	eb 42                	jmp    ec8 <printf+0x170>
			} else if (c == '%') {
     e86:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
     e8a:	75 17                	jne    ea3 <printf+0x14b>
				putc(fd, c);
     e8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     e8f:	0f be c0             	movsbl %al,%eax
     e92:	83 ec 08             	sub    $0x8,%esp
     e95:	50                   	push   %eax
     e96:	ff 75 08             	pushl  0x8(%ebp)
     e99:	e8 e3 fd ff ff       	call   c81 <putc>
     e9e:	83 c4 10             	add    $0x10,%esp
     ea1:	eb 25                	jmp    ec8 <printf+0x170>
			} else {
				// Unknown % sequence.  Print it to draw attention.
				putc(fd, '%');
     ea3:	83 ec 08             	sub    $0x8,%esp
     ea6:	6a 25                	push   $0x25
     ea8:	ff 75 08             	pushl  0x8(%ebp)
     eab:	e8 d1 fd ff ff       	call   c81 <putc>
     eb0:	83 c4 10             	add    $0x10,%esp
				putc(fd, c);
     eb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     eb6:	0f be c0             	movsbl %al,%eax
     eb9:	83 ec 08             	sub    $0x8,%esp
     ebc:	50                   	push   %eax
     ebd:	ff 75 08             	pushl  0x8(%ebp)
     ec0:	e8 bc fd ff ff       	call   c81 <putc>
     ec5:	83 c4 10             	add    $0x10,%esp
			}
			state = 0;
     ec8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int c, i, state;
	uint *ap;

	state = 0;
	ap = (uint *) (void *)&fmt + 1;
	for (i = 0; fmt[i]; i++) {
     ecf:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     ed3:	8b 55 0c             	mov    0xc(%ebp),%edx
     ed6:	8b 45 f0             	mov    -0x10(%ebp),%eax
     ed9:	01 d0                	add    %edx,%eax
     edb:	0f b6 00             	movzbl (%eax),%eax
     ede:	84 c0                	test   %al,%al
     ee0:	0f 85 94 fe ff ff    	jne    d7a <printf+0x22>
				putc(fd, c);
			}
			state = 0;
		}
	}
}
     ee6:	90                   	nop
     ee7:	c9                   	leave  
     ee8:	c3                   	ret    

00000ee9 <free>:

static Header base;
static Header *freep;

void free(void *ap)
{
     ee9:	55                   	push   %ebp
     eea:	89 e5                	mov    %esp,%ebp
     eec:	83 ec 10             	sub    $0x10,%esp
	Header *bp, *p;

	bp = (Header *) ap - 1; //take address of memory -> subtract one size of p to get to header to memeory
     eef:	8b 45 08             	mov    0x8(%ebp),%eax
     ef2:	83 e8 08             	sub    $0x8,%eax
     ef5:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr) //comparing pointers to headers...maybe ordering spatially...
     ef8:	a1 48 17 00 00       	mov    0x1748,%eax
     efd:	89 45 fc             	mov    %eax,-0x4(%ebp)
     f00:	eb 24                	jmp    f26 <free+0x3d>
		if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     f02:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f05:	8b 00                	mov    (%eax),%eax
     f07:	3b 45 fc             	cmp    -0x4(%ebp),%eax
     f0a:	77 12                	ja     f1e <free+0x35>
     f0c:	8b 45 f8             	mov    -0x8(%ebp),%eax
     f0f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
     f12:	77 24                	ja     f38 <free+0x4f>
     f14:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f17:	8b 00                	mov    (%eax),%eax
     f19:	3b 45 f8             	cmp    -0x8(%ebp),%eax
     f1c:	77 1a                	ja     f38 <free+0x4f>
void free(void *ap)
{
	Header *bp, *p;

	bp = (Header *) ap - 1; //take address of memory -> subtract one size of p to get to header to memeory
	for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr) //comparing pointers to headers...maybe ordering spatially...
     f1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f21:	8b 00                	mov    (%eax),%eax
     f23:	89 45 fc             	mov    %eax,-0x4(%ebp)
     f26:	8b 45 f8             	mov    -0x8(%ebp),%eax
     f29:	3b 45 fc             	cmp    -0x4(%ebp),%eax
     f2c:	76 d4                	jbe    f02 <free+0x19>
     f2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f31:	8b 00                	mov    (%eax),%eax
     f33:	3b 45 f8             	cmp    -0x8(%ebp),%eax
     f36:	76 ca                	jbe    f02 <free+0x19>
		if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
			break;
	if (bp + bp->s.size == p->s.ptr) { //checks sizes to merge contiguous freed regions
     f38:	8b 45 f8             	mov    -0x8(%ebp),%eax
     f3b:	8b 40 04             	mov    0x4(%eax),%eax
     f3e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     f45:	8b 45 f8             	mov    -0x8(%ebp),%eax
     f48:	01 c2                	add    %eax,%edx
     f4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f4d:	8b 00                	mov    (%eax),%eax
     f4f:	39 c2                	cmp    %eax,%edx
     f51:	75 24                	jne    f77 <free+0x8e>
		bp->s.size += p->s.ptr->s.size;
     f53:	8b 45 f8             	mov    -0x8(%ebp),%eax
     f56:	8b 50 04             	mov    0x4(%eax),%edx
     f59:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f5c:	8b 00                	mov    (%eax),%eax
     f5e:	8b 40 04             	mov    0x4(%eax),%eax
     f61:	01 c2                	add    %eax,%edx
     f63:	8b 45 f8             	mov    -0x8(%ebp),%eax
     f66:	89 50 04             	mov    %edx,0x4(%eax)
		bp->s.ptr = p->s.ptr->s.ptr;
     f69:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f6c:	8b 00                	mov    (%eax),%eax
     f6e:	8b 10                	mov    (%eax),%edx
     f70:	8b 45 f8             	mov    -0x8(%ebp),%eax
     f73:	89 10                	mov    %edx,(%eax)
     f75:	eb 0a                	jmp    f81 <free+0x98>
	} else
		bp->s.ptr = p->s.ptr;
     f77:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f7a:	8b 10                	mov    (%eax),%edx
     f7c:	8b 45 f8             	mov    -0x8(%ebp),%eax
     f7f:	89 10                	mov    %edx,(%eax)
	if (p + p->s.size == bp) {
     f81:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f84:	8b 40 04             	mov    0x4(%eax),%eax
     f87:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     f8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f91:	01 d0                	add    %edx,%eax
     f93:	3b 45 f8             	cmp    -0x8(%ebp),%eax
     f96:	75 20                	jne    fb8 <free+0xcf>
		p->s.size += bp->s.size;
     f98:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f9b:	8b 50 04             	mov    0x4(%eax),%edx
     f9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
     fa1:	8b 40 04             	mov    0x4(%eax),%eax
     fa4:	01 c2                	add    %eax,%edx
     fa6:	8b 45 fc             	mov    -0x4(%ebp),%eax
     fa9:	89 50 04             	mov    %edx,0x4(%eax)
		p->s.ptr = bp->s.ptr;
     fac:	8b 45 f8             	mov    -0x8(%ebp),%eax
     faf:	8b 10                	mov    (%eax),%edx
     fb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
     fb4:	89 10                	mov    %edx,(%eax)
     fb6:	eb 08                	jmp    fc0 <free+0xd7>
	} else
		p->s.ptr = bp;
     fb8:	8b 45 fc             	mov    -0x4(%ebp),%eax
     fbb:	8b 55 f8             	mov    -0x8(%ebp),%edx
     fbe:	89 10                	mov    %edx,(%eax)
	freep = p;
     fc0:	8b 45 fc             	mov    -0x4(%ebp),%eax
     fc3:	a3 48 17 00 00       	mov    %eax,0x1748
}
     fc8:	90                   	nop
     fc9:	c9                   	leave  
     fca:	c3                   	ret    

00000fcb <morecore>:

static Header *morecore(uint nu)
{
     fcb:	55                   	push   %ebp
     fcc:	89 e5                	mov    %esp,%ebp
     fce:	83 ec 18             	sub    $0x18,%esp
	char *p;
	Header *hp;

	if (nu < 4096)
     fd1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
     fd8:	77 07                	ja     fe1 <morecore+0x16>
		nu = 4096;
     fda:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
	p = sbrk(nu * sizeof(Header));
     fe1:	8b 45 08             	mov    0x8(%ebp),%eax
     fe4:	c1 e0 03             	shl    $0x3,%eax
     fe7:	83 ec 0c             	sub    $0xc,%esp
     fea:	50                   	push   %eax
     feb:	e8 31 fc ff ff       	call   c21 <sbrk>
     ff0:	83 c4 10             	add    $0x10,%esp
     ff3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (p == (char *)-1)
     ff6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     ffa:	75 07                	jne    1003 <morecore+0x38>
		return 0;
     ffc:	b8 00 00 00 00       	mov    $0x0,%eax
    1001:	eb 26                	jmp    1029 <morecore+0x5e>
	hp = (Header *) p;
    1003:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1006:	89 45 f0             	mov    %eax,-0x10(%ebp)
	hp->s.size = nu;
    1009:	8b 45 f0             	mov    -0x10(%ebp),%eax
    100c:	8b 55 08             	mov    0x8(%ebp),%edx
    100f:	89 50 04             	mov    %edx,0x4(%eax)
	free((void *)(hp + 1));
    1012:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1015:	83 c0 08             	add    $0x8,%eax
    1018:	83 ec 0c             	sub    $0xc,%esp
    101b:	50                   	push   %eax
    101c:	e8 c8 fe ff ff       	call   ee9 <free>
    1021:	83 c4 10             	add    $0x10,%esp
	return freep;
    1024:	a1 48 17 00 00       	mov    0x1748,%eax
}
    1029:	c9                   	leave  
    102a:	c3                   	ret    

0000102b <malloc>:

void *malloc(uint nbytes)
{
    102b:	55                   	push   %ebp
    102c:	89 e5                	mov    %esp,%ebp
    102e:	83 ec 18             	sub    $0x18,%esp
	Header *p, *prevp;
	uint nunits;

	nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
    1031:	8b 45 08             	mov    0x8(%ebp),%eax
    1034:	83 c0 07             	add    $0x7,%eax
    1037:	c1 e8 03             	shr    $0x3,%eax
    103a:	83 c0 01             	add    $0x1,%eax
    103d:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if ((prevp = freep) == 0) {
    1040:	a1 48 17 00 00       	mov    0x1748,%eax
    1045:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1048:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    104c:	75 23                	jne    1071 <malloc+0x46>
		base.s.ptr = freep = prevp = &base;
    104e:	c7 45 f0 40 17 00 00 	movl   $0x1740,-0x10(%ebp)
    1055:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1058:	a3 48 17 00 00       	mov    %eax,0x1748
    105d:	a1 48 17 00 00       	mov    0x1748,%eax
    1062:	a3 40 17 00 00       	mov    %eax,0x1740
		base.s.size = 0;
    1067:	c7 05 44 17 00 00 00 	movl   $0x0,0x1744
    106e:	00 00 00 
	}
	for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
    1071:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1074:	8b 00                	mov    (%eax),%eax
    1076:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if (p->s.size >= nunits) {
    1079:	8b 45 f4             	mov    -0xc(%ebp),%eax
    107c:	8b 40 04             	mov    0x4(%eax),%eax
    107f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1082:	72 4d                	jb     10d1 <malloc+0xa6>
			if (p->s.size == nunits)
    1084:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1087:	8b 40 04             	mov    0x4(%eax),%eax
    108a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    108d:	75 0c                	jne    109b <malloc+0x70>
				prevp->s.ptr = p->s.ptr;
    108f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1092:	8b 10                	mov    (%eax),%edx
    1094:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1097:	89 10                	mov    %edx,(%eax)
    1099:	eb 26                	jmp    10c1 <malloc+0x96>
			else {
				p->s.size -= nunits;
    109b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    109e:	8b 40 04             	mov    0x4(%eax),%eax
    10a1:	2b 45 ec             	sub    -0x14(%ebp),%eax
    10a4:	89 c2                	mov    %eax,%edx
    10a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10a9:	89 50 04             	mov    %edx,0x4(%eax)
				p += p->s.size;
    10ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10af:	8b 40 04             	mov    0x4(%eax),%eax
    10b2:	c1 e0 03             	shl    $0x3,%eax
    10b5:	01 45 f4             	add    %eax,-0xc(%ebp)
				p->s.size = nunits;
    10b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10bb:	8b 55 ec             	mov    -0x14(%ebp),%edx
    10be:	89 50 04             	mov    %edx,0x4(%eax)
			}
			freep = prevp;
    10c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    10c4:	a3 48 17 00 00       	mov    %eax,0x1748
			//printf(0, "\nMalloc Pointer Value = %p\n", p+1);
			return (void *)(p + 1);
    10c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10cc:	83 c0 08             	add    $0x8,%eax
    10cf:	eb 3b                	jmp    110c <malloc+0xe1>
		}
		if (p == freep)
    10d1:	a1 48 17 00 00       	mov    0x1748,%eax
    10d6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    10d9:	75 1e                	jne    10f9 <malloc+0xce>
			if ((p = morecore(nunits)) == 0)
    10db:	83 ec 0c             	sub    $0xc,%esp
    10de:	ff 75 ec             	pushl  -0x14(%ebp)
    10e1:	e8 e5 fe ff ff       	call   fcb <morecore>
    10e6:	83 c4 10             	add    $0x10,%esp
    10e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    10ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    10f0:	75 07                	jne    10f9 <malloc+0xce>
				return 0;
    10f2:	b8 00 00 00 00       	mov    $0x0,%eax
    10f7:	eb 13                	jmp    110c <malloc+0xe1>
	nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
	if ((prevp = freep) == 0) {
		base.s.ptr = freep = prevp = &base;
		base.s.size = 0;
	}
	for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
    10f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    10ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1102:	8b 00                	mov    (%eax),%eax
    1104:	89 45 f4             	mov    %eax,-0xc(%ebp)
			return (void *)(p + 1);
		}
		if (p == freep)
			if ((p = morecore(nunits)) == 0)
				return 0;
	}
    1107:	e9 6d ff ff ff       	jmp    1079 <malloc+0x4e>
}
    110c:	c9                   	leave  
    110d:	c3                   	ret    
