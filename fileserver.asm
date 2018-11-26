
_fileserver:     file format elf32-i386


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
       b:	68 88 1c 00 00       	push   $0x1c88
      10:	e8 b3 17 00 00       	call   17c8 <mutex_create>
      15:	83 c4 10             	add    $0x10,%esp
      18:	a3 50 26 00 00       	mov    %eax,0x2650
	mutexresp=mutex_create("response_mutex",14);
      1d:	83 ec 08             	sub    $0x8,%esp
      20:	6a 0e                	push   $0xe
      22:	68 96 1c 00 00       	push   $0x1c96
      27:	e8 9c 17 00 00       	call   17c8 <mutex_create>
      2c:	83 c4 10             	add    $0x10,%esp
      2f:	a3 a0 24 00 00       	mov    %eax,0x24a0
	printf(1,"mutexes made\n");
      34:	83 ec 08             	sub    $0x8,%esp
      37:	68 a5 1c 00 00       	push   $0x1ca5
      3c:	6a 01                	push   $0x1
      3e:	e8 8c 18 00 00       	call   18cf <printf>
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
      4f:	a1 50 26 00 00       	mov    0x2650,%eax
      54:	83 ec 0c             	sub    $0xc,%esp
      57:	50                   	push   %eax
      58:	e8 7b 17 00 00       	call   17d8 <mutex_lock>
      5d:	83 c4 10             	add    $0x10,%esp

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
      60:	83 ec 08             	sub    $0x8,%esp
      63:	6a 07                	push   $0x7
      65:	68 b3 1c 00 00       	push   $0x1cb3
      6a:	e8 41 17 00 00       	call   17b0 <shm_get>
      6f:	83 c4 10             	add    $0x10,%esp
      72:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"write");
      75:	8b 45 f4             	mov    -0xc(%ebp),%eax
      78:	83 ec 08             	sub    $0x8,%esp
      7b:	68 bb 1c 00 00       	push   $0x1cbb
      80:	50                   	push   %eax
      81:	e8 59 14 00 00       	call   14df <strcpy>
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
      a8:	e8 32 14 00 00       	call   14df <strcpy>
      ad:	83 c4 10             	add    $0x10,%esp
	printf(1,"operation = %s\n",request->operation);
      b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
      b3:	83 ec 04             	sub    $0x4,%esp
      b6:	50                   	push   %eax
      b7:	68 c1 1c 00 00       	push   $0x1cc1
      bc:	6a 01                	push   $0x1
      be:	e8 0c 18 00 00       	call   18cf <printf>
      c3:	83 c4 10             	add    $0x10,%esp
	printf(1,"data set\n");
      c6:	83 ec 08             	sub    $0x8,%esp
      c9:	68 d1 1c 00 00       	push   $0x1cd1
      ce:	6a 01                	push   $0x1
      d0:	e8 fa 17 00 00       	call   18cf <printf>
      d5:	83 c4 10             	add    $0x10,%esp
	cv_signal(mutexreq);//signals server to read
      d8:	a1 50 26 00 00       	mov    0x2650,%eax
      dd:	83 ec 0c             	sub    $0xc,%esp
      e0:	50                   	push   %eax
      e1:	e8 0a 17 00 00       	call   17f0 <cv_signal>
      e6:	83 c4 10             	add    $0x10,%esp
	
	cv_wait(mutexresp);//waits on server to write	
      e9:	a1 a0 24 00 00       	mov    0x24a0,%eax
      ee:	83 ec 0c             	sub    $0xc,%esp
      f1:	50                   	push   %eax
      f2:	e8 f1 16 00 00       	call   17e8 <cv_wait>
      f7:	83 c4 10             	add    $0x10,%esp
	printf(1,"waiting done\n");
      fa:	83 ec 08             	sub    $0x8,%esp
      fd:	68 db 1c 00 00       	push   $0x1cdb
     102:	6a 01                	push   $0x1
     104:	e8 c6 17 00 00       	call   18cf <printf>
     109:	83 c4 10             	add    $0x10,%esp
	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     10c:	83 ec 08             	sub    $0x8,%esp
     10f:	6a 08                	push   $0x8
     111:	68 e9 1c 00 00       	push   $0x1ce9
     116:	e8 95 16 00 00       	call   17b0 <shm_get>
     11b:	83 c4 10             	add    $0x10,%esp
     11e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     121:	a1 a0 24 00 00       	mov    0x24a0,%eax
     126:	83 ec 0c             	sub    $0xc,%esp
     129:	50                   	push   %eax
     12a:	e8 b1 16 00 00       	call   17e0 <mutex_unlock>
     12f:	83 c4 10             	add    $0x10,%esp
	printf(1,"response received\n");
     132:	83 ec 08             	sub    $0x8,%esp
     135:	68 f2 1c 00 00       	push   $0x1cf2
     13a:	6a 01                	push   $0x1
     13c:	e8 8e 17 00 00       	call   18cf <printf>
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
     157:	a1 50 26 00 00       	mov    0x2650,%eax
     15c:	83 ec 0c             	sub    $0xc,%esp
     15f:	50                   	push   %eax
     160:	e8 73 16 00 00       	call   17d8 <mutex_lock>
     165:	83 c4 10             	add    $0x10,%esp

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
     168:	83 ec 08             	sub    $0x8,%esp
     16b:	6a 07                	push   $0x7
     16d:	68 b3 1c 00 00       	push   $0x1cb3
     172:	e8 39 16 00 00       	call   17b0 <shm_get>
     177:	83 c4 10             	add    $0x10,%esp
     17a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"read");
     17d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     180:	83 ec 08             	sub    $0x8,%esp
     183:	68 05 1d 00 00       	push   $0x1d05
     188:	50                   	push   %eax
     189:	e8 51 13 00 00       	call   14df <strcpy>
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
     1b0:	e8 2a 13 00 00       	call   14df <strcpy>
     1b5:	83 c4 10             	add    $0x10,%esp


	cv_signal(mutexreq);//signals server to read
     1b8:	a1 50 26 00 00       	mov    0x2650,%eax
     1bd:	83 ec 0c             	sub    $0xc,%esp
     1c0:	50                   	push   %eax
     1c1:	e8 2a 16 00 00       	call   17f0 <cv_signal>
     1c6:	83 c4 10             	add    $0x10,%esp
	
	cv_wait(mutexresp);//waits on server to write	
     1c9:	a1 a0 24 00 00       	mov    0x24a0,%eax
     1ce:	83 ec 0c             	sub    $0xc,%esp
     1d1:	50                   	push   %eax
     1d2:	e8 11 16 00 00       	call   17e8 <cv_wait>
     1d7:	83 c4 10             	add    $0x10,%esp

	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     1da:	83 ec 08             	sub    $0x8,%esp
     1dd:	6a 08                	push   $0x8
     1df:	68 e9 1c 00 00       	push   $0x1ce9
     1e4:	e8 c7 15 00 00       	call   17b0 <shm_get>
     1e9:	83 c4 10             	add    $0x10,%esp
     1ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     1ef:	a1 a0 24 00 00       	mov    0x24a0,%eax
     1f4:	83 ec 0c             	sub    $0xc,%esp
     1f7:	50                   	push   %eax
     1f8:	e8 e3 15 00 00       	call   17e0 <mutex_unlock>
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
     216:	68 0a 1d 00 00       	push   $0x1d0a
     21b:	6a 01                	push   $0x1
     21d:	e8 ad 16 00 00       	call   18cf <printf>
     222:	83 c4 10             	add    $0x10,%esp

    mutex_lock(mutexreq);//acquried mutex when writing to shm
     225:	a1 50 26 00 00       	mov    0x2650,%eax
     22a:	83 ec 0c             	sub    $0xc,%esp
     22d:	50                   	push   %eax
     22e:	e8 a5 15 00 00       	call   17d8 <mutex_lock>
     233:	83 c4 10             	add    $0x10,%esp

	printf(1,"lock taken\n");
     236:	83 ec 08             	sub    $0x8,%esp
     239:	68 18 1d 00 00       	push   $0x1d18
     23e:	6a 01                	push   $0x1
     240:	e8 8a 16 00 00       	call   18cf <printf>
     245:	83 c4 10             	add    $0x10,%esp
	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
     248:	83 ec 08             	sub    $0x8,%esp
     24b:	6a 07                	push   $0x7
     24d:	68 b3 1c 00 00       	push   $0x1cb3
     252:	e8 59 15 00 00       	call   17b0 <shm_get>
     257:	83 c4 10             	add    $0x10,%esp
     25a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"open");
     25d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     260:	83 ec 08             	sub    $0x8,%esp
     263:	68 24 1d 00 00       	push   $0x1d24
     268:	50                   	push   %eax
     269:	e8 71 12 00 00       	call   14df <strcpy>
     26e:	83 c4 10             	add    $0x10,%esp
	printf(1,"%s\n",request->operation);
     271:	8b 45 f4             	mov    -0xc(%ebp),%eax
     274:	83 ec 04             	sub    $0x4,%esp
     277:	50                   	push   %eax
     278:	68 29 1d 00 00       	push   $0x1d29
     27d:	6a 01                	push   $0x1
     27f:	e8 4b 16 00 00       	call   18cf <printf>
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
     29d:	e8 3d 12 00 00       	call   14df <strcpy>
     2a2:	83 c4 10             	add    $0x10,%esp
	printf(1,"operation = %s\n",request->operation);
     2a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     2a8:	83 ec 04             	sub    $0x4,%esp
     2ab:	50                   	push   %eax
     2ac:	68 c1 1c 00 00       	push   $0x1cc1
     2b1:	6a 01                	push   $0x1
     2b3:	e8 17 16 00 00       	call   18cf <printf>
     2b8:	83 c4 10             	add    $0x10,%esp
	printf(1,"data set\n");
     2bb:	83 ec 08             	sub    $0x8,%esp
     2be:	68 d1 1c 00 00       	push   $0x1cd1
     2c3:	6a 01                	push   $0x1
     2c5:	e8 05 16 00 00       	call   18cf <printf>
     2ca:	83 c4 10             	add    $0x10,%esp
	cv_signal(mutexreq);//signals server to read
     2cd:	a1 50 26 00 00       	mov    0x2650,%eax
     2d2:	83 ec 0c             	sub    $0xc,%esp
     2d5:	50                   	push   %eax
     2d6:	e8 15 15 00 00       	call   17f0 <cv_signal>
     2db:	83 c4 10             	add    $0x10,%esp

	cv_wait(mutexresp);//waits on server to write	
     2de:	a1 a0 24 00 00       	mov    0x24a0,%eax
     2e3:	83 ec 0c             	sub    $0xc,%esp
     2e6:	50                   	push   %eax
     2e7:	e8 fc 14 00 00       	call   17e8 <cv_wait>
     2ec:	83 c4 10             	add    $0x10,%esp
	printf(1,"waiting done\n");
     2ef:	83 ec 08             	sub    $0x8,%esp
     2f2:	68 db 1c 00 00       	push   $0x1cdb
     2f7:	6a 01                	push   $0x1
     2f9:	e8 d1 15 00 00       	call   18cf <printf>
     2fe:	83 c4 10             	add    $0x10,%esp
	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     301:	83 ec 08             	sub    $0x8,%esp
     304:	6a 08                	push   $0x8
     306:	68 e9 1c 00 00       	push   $0x1ce9
     30b:	e8 a0 14 00 00       	call   17b0 <shm_get>
     310:	83 c4 10             	add    $0x10,%esp
     313:	89 45 f0             	mov    %eax,-0x10(%ebp)
	
	printf(1,"response received\n");
     316:	83 ec 08             	sub    $0x8,%esp
     319:	68 f2 1c 00 00       	push   $0x1cf2
     31e:	6a 01                	push   $0x1
     320:	e8 aa 15 00 00       	call   18cf <printf>
     325:	83 c4 10             	add    $0x10,%esp
	retval=response->res;
     328:	8b 45 f0             	mov    -0x10(%ebp),%eax
     32b:	8b 00                	mov    (%eax),%eax
     32d:	89 45 ec             	mov    %eax,-0x14(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     330:	a1 a0 24 00 00       	mov    0x24a0,%eax
     335:	83 ec 0c             	sub    $0xc,%esp
     338:	50                   	push   %eax
     339:	e8 a2 14 00 00       	call   17e0 <mutex_unlock>
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
     34c:	a1 50 26 00 00       	mov    0x2650,%eax
     351:	83 ec 0c             	sub    $0xc,%esp
     354:	50                   	push   %eax
     355:	e8 7e 14 00 00       	call   17d8 <mutex_lock>
     35a:	83 c4 10             	add    $0x10,%esp

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
     35d:	83 ec 08             	sub    $0x8,%esp
     360:	6a 07                	push   $0x7
     362:	68 b3 1c 00 00       	push   $0x1cb3
     367:	e8 44 14 00 00       	call   17b0 <shm_get>
     36c:	83 c4 10             	add    $0x10,%esp
     36f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"close");
     372:	8b 45 f4             	mov    -0xc(%ebp),%eax
     375:	83 ec 08             	sub    $0x8,%esp
     378:	68 2d 1d 00 00       	push   $0x1d2d
     37d:	50                   	push   %eax
     37e:	e8 5c 11 00 00       	call   14df <strcpy>
     383:	83 c4 10             	add    $0x10,%esp
	//request->arg=n;
	request->fd=fd1;
     386:	8b 45 f4             	mov    -0xc(%ebp),%eax
     389:	8b 55 08             	mov    0x8(%ebp),%edx
     38c:	89 50 0c             	mov    %edx,0xc(%eax)
	//strcpy(request->data,(char *)ptr);

	cv_signal(mutexreq);//signals server to read
     38f:	a1 50 26 00 00       	mov    0x2650,%eax
     394:	83 ec 0c             	sub    $0xc,%esp
     397:	50                   	push   %eax
     398:	e8 53 14 00 00       	call   17f0 <cv_signal>
     39d:	83 c4 10             	add    $0x10,%esp
	
	cv_wait(mutexresp);//waits on server to write	
     3a0:	a1 a0 24 00 00       	mov    0x24a0,%eax
     3a5:	83 ec 0c             	sub    $0xc,%esp
     3a8:	50                   	push   %eax
     3a9:	e8 3a 14 00 00       	call   17e8 <cv_wait>
     3ae:	83 c4 10             	add    $0x10,%esp

	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     3b1:	83 ec 08             	sub    $0x8,%esp
     3b4:	6a 08                	push   $0x8
     3b6:	68 e9 1c 00 00       	push   $0x1ce9
     3bb:	e8 f0 13 00 00       	call   17b0 <shm_get>
     3c0:	83 c4 10             	add    $0x10,%esp
     3c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     3c6:	a1 a0 24 00 00       	mov    0x24a0,%eax
     3cb:	83 ec 0c             	sub    $0xc,%esp
     3ce:	50                   	push   %eax
     3cf:	e8 0c 14 00 00       	call   17e0 <mutex_unlock>
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
     3ea:	a1 50 26 00 00       	mov    0x2650,%eax
     3ef:	83 ec 0c             	sub    $0xc,%esp
     3f2:	50                   	push   %eax
     3f3:	e8 e0 13 00 00       	call   17d8 <mutex_lock>
     3f8:	83 c4 10             	add    $0x10,%esp

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
     3fb:	83 ec 08             	sub    $0x8,%esp
     3fe:	6a 07                	push   $0x7
     400:	68 b3 1c 00 00       	push   $0x1cb3
     405:	e8 a6 13 00 00       	call   17b0 <shm_get>
     40a:	83 c4 10             	add    $0x10,%esp
     40d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"mkdir");
     410:	8b 45 f4             	mov    -0xc(%ebp),%eax
     413:	83 ec 08             	sub    $0x8,%esp
     416:	68 33 1d 00 00       	push   $0x1d33
     41b:	50                   	push   %eax
     41c:	e8 be 10 00 00       	call   14df <strcpy>
     421:	83 c4 10             	add    $0x10,%esp
	//request->arg=n;
	//request->fd=fd1;
	strcpy(request->data,(char *)path);
     424:	8b 45 f4             	mov    -0xc(%ebp),%eax
     427:	83 c0 10             	add    $0x10,%eax
     42a:	83 ec 08             	sub    $0x8,%esp
     42d:	ff 75 08             	pushl  0x8(%ebp)
     430:	50                   	push   %eax
     431:	e8 a9 10 00 00       	call   14df <strcpy>
     436:	83 c4 10             	add    $0x10,%esp
	printf(1,"mkdir test\n");
     439:	83 ec 08             	sub    $0x8,%esp
     43c:	68 39 1d 00 00       	push   $0x1d39
     441:	6a 01                	push   $0x1
     443:	e8 87 14 00 00       	call   18cf <printf>
     448:	83 c4 10             	add    $0x10,%esp
	cv_signal(mutexreq);//signals server to read
     44b:	a1 50 26 00 00       	mov    0x2650,%eax
     450:	83 ec 0c             	sub    $0xc,%esp
     453:	50                   	push   %eax
     454:	e8 97 13 00 00       	call   17f0 <cv_signal>
     459:	83 c4 10             	add    $0x10,%esp
	mutex_lock(mutexresp);
     45c:	a1 a0 24 00 00       	mov    0x24a0,%eax
     461:	83 ec 0c             	sub    $0xc,%esp
     464:	50                   	push   %eax
     465:	e8 6e 13 00 00       	call   17d8 <mutex_lock>
     46a:	83 c4 10             	add    $0x10,%esp
	cv_wait(mutexresp);//waits on server to write	
     46d:	a1 a0 24 00 00       	mov    0x24a0,%eax
     472:	83 ec 0c             	sub    $0xc,%esp
     475:	50                   	push   %eax
     476:	e8 6d 13 00 00       	call   17e8 <cv_wait>
     47b:	83 c4 10             	add    $0x10,%esp
	printf(1,"testme\n");
     47e:	83 ec 08             	sub    $0x8,%esp
     481:	68 45 1d 00 00       	push   $0x1d45
     486:	6a 01                	push   $0x1
     488:	e8 42 14 00 00       	call   18cf <printf>
     48d:	83 c4 10             	add    $0x10,%esp
	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     490:	83 ec 08             	sub    $0x8,%esp
     493:	6a 08                	push   $0x8
     495:	68 e9 1c 00 00       	push   $0x1ce9
     49a:	e8 11 13 00 00       	call   17b0 <shm_get>
     49f:	83 c4 10             	add    $0x10,%esp
     4a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     4a5:	a1 a0 24 00 00       	mov    0x24a0,%eax
     4aa:	83 ec 0c             	sub    $0xc,%esp
     4ad:	50                   	push   %eax
     4ae:	e8 2d 13 00 00       	call   17e0 <mutex_unlock>
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
     4c9:	a1 50 26 00 00       	mov    0x2650,%eax
     4ce:	83 ec 0c             	sub    $0xc,%esp
     4d1:	50                   	push   %eax
     4d2:	e8 01 13 00 00       	call   17d8 <mutex_lock>
     4d7:	83 c4 10             	add    $0x10,%esp

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
     4da:	83 ec 08             	sub    $0x8,%esp
     4dd:	6a 07                	push   $0x7
     4df:	68 b3 1c 00 00       	push   $0x1cb3
     4e4:	e8 c7 12 00 00       	call   17b0 <shm_get>
     4e9:	83 c4 10             	add    $0x10,%esp
     4ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"unlink");
     4ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4f2:	83 ec 08             	sub    $0x8,%esp
     4f5:	68 4d 1d 00 00       	push   $0x1d4d
     4fa:	50                   	push   %eax
     4fb:	e8 df 0f 00 00       	call   14df <strcpy>
     500:	83 c4 10             	add    $0x10,%esp
	//request->arg=n;
	//request->fd=fd1;
	strcpy(request->data,(char *)path);
     503:	8b 45 f4             	mov    -0xc(%ebp),%eax
     506:	83 c0 10             	add    $0x10,%eax
     509:	83 ec 08             	sub    $0x8,%esp
     50c:	ff 75 08             	pushl  0x8(%ebp)
     50f:	50                   	push   %eax
     510:	e8 ca 0f 00 00       	call   14df <strcpy>
     515:	83 c4 10             	add    $0x10,%esp

	cv_signal(mutexreq);//signals server to read
     518:	a1 50 26 00 00       	mov    0x2650,%eax
     51d:	83 ec 0c             	sub    $0xc,%esp
     520:	50                   	push   %eax
     521:	e8 ca 12 00 00       	call   17f0 <cv_signal>
     526:	83 c4 10             	add    $0x10,%esp
	
	cv_wait(mutexresp);//waits on server to write	
     529:	a1 a0 24 00 00       	mov    0x24a0,%eax
     52e:	83 ec 0c             	sub    $0xc,%esp
     531:	50                   	push   %eax
     532:	e8 b1 12 00 00       	call   17e8 <cv_wait>
     537:	83 c4 10             	add    $0x10,%esp

	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     53a:	83 ec 08             	sub    $0x8,%esp
     53d:	6a 08                	push   $0x8
     53f:	68 e9 1c 00 00       	push   $0x1ce9
     544:	e8 67 12 00 00       	call   17b0 <shm_get>
     549:	83 c4 10             	add    $0x10,%esp
     54c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     54f:	a1 a0 24 00 00       	mov    0x24a0,%eax
     554:	83 ec 0c             	sub    $0xc,%esp
     557:	50                   	push   %eax
     558:	e8 83 12 00 00       	call   17e0 <mutex_unlock>
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
     573:	a1 50 26 00 00       	mov    0x2650,%eax
     578:	83 ec 0c             	sub    $0xc,%esp
     57b:	50                   	push   %eax
     57c:	e8 57 12 00 00       	call   17d8 <mutex_lock>
     581:	83 c4 10             	add    $0x10,%esp

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
     584:	83 ec 08             	sub    $0x8,%esp
     587:	6a 07                	push   $0x7
     589:	68 b3 1c 00 00       	push   $0x1cb3
     58e:	e8 1d 12 00 00       	call   17b0 <shm_get>
     593:	83 c4 10             	add    $0x10,%esp
     596:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"restore");
     599:	8b 45 f4             	mov    -0xc(%ebp),%eax
     59c:	83 ec 08             	sub    $0x8,%esp
     59f:	68 54 1d 00 00       	push   $0x1d54
     5a4:	50                   	push   %eax
     5a5:	e8 35 0f 00 00       	call   14df <strcpy>
     5aa:	83 c4 10             	add    $0x10,%esp
	//request->arg=n;
	//request->fd=fd1;
	//strcpy(request->data,(char *)path);

	cv_signal(mutexreq);//signals server to read
     5ad:	a1 50 26 00 00       	mov    0x2650,%eax
     5b2:	83 ec 0c             	sub    $0xc,%esp
     5b5:	50                   	push   %eax
     5b6:	e8 35 12 00 00       	call   17f0 <cv_signal>
     5bb:	83 c4 10             	add    $0x10,%esp
	
	cv_wait(mutexresp);//waits on server to write	
     5be:	a1 a0 24 00 00       	mov    0x24a0,%eax
     5c3:	83 ec 0c             	sub    $0xc,%esp
     5c6:	50                   	push   %eax
     5c7:	e8 1c 12 00 00       	call   17e8 <cv_wait>
     5cc:	83 c4 10             	add    $0x10,%esp

	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     5cf:	83 ec 08             	sub    $0x8,%esp
     5d2:	6a 08                	push   $0x8
     5d4:	68 e9 1c 00 00       	push   $0x1ce9
     5d9:	e8 d2 11 00 00       	call   17b0 <shm_get>
     5de:	83 c4 10             	add    $0x10,%esp
     5e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     5e4:	a1 a0 24 00 00       	mov    0x24a0,%eax
     5e9:	83 ec 0c             	sub    $0xc,%esp
     5ec:	50                   	push   %eax
     5ed:	e8 ee 11 00 00       	call   17e0 <mutex_unlock>
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

00000602 <r_mkdir>:

};*/

char * stored_path[100];//idk about the size 

void r_mkdir(char *path){
     602:	55                   	push   %ebp
     603:	89 e5                	mov    %esp,%ebp
     605:	83 ec 28             	sub    $0x28,%esp
//recursively calls till all directories are created
    struct stat info;
	//used to dileminate if directory or file
    char *p = path;
     608:	8b 45 08             	mov    0x8(%ebp),%eax
     60b:	89 45 f4             	mov    %eax,-0xc(%ebp)

    while (*p != '\0') {
     60e:	eb 3f                	jmp    64f <r_mkdir+0x4d>
        if (*p == '/') {
     610:	8b 45 f4             	mov    -0xc(%ebp),%eax
     613:	0f b6 00             	movzbl (%eax),%eax
     616:	3c 2f                	cmp    $0x2f,%al
     618:	75 31                	jne    64b <r_mkdir+0x49>
            *p = '\0';
     61a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     61d:	c6 00 00             	movb   $0x0,(%eax)
		//marks end of direct
            if (stat(path, &info) == -1) {
     620:	83 ec 08             	sub    $0x8,%esp
     623:	8d 45 e0             	lea    -0x20(%ebp),%eax
     626:	50                   	push   %eax
     627:	ff 75 08             	pushl  0x8(%ebp)
     62a:	e8 02 10 00 00       	call   1631 <stat>
     62f:	83 c4 10             	add    $0x10,%esp
     632:	83 f8 ff             	cmp    $0xffffffff,%eax
     635:	75 0e                	jne    645 <r_mkdir+0x43>
                mkdir(path);
     637:	83 ec 0c             	sub    $0xc,%esp
     63a:	ff 75 08             	pushl  0x8(%ebp)
     63d:	e8 36 11 00 00       	call   1778 <mkdir>
     642:	83 c4 10             	add    $0x10,%esp
            }
            *p = '/';
     645:	8b 45 f4             	mov    -0xc(%ebp),%eax
     648:	c6 00 2f             	movb   $0x2f,(%eax)
        }
        p++;
     64b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
//recursively calls till all directories are created
    struct stat info;
	//used to dileminate if directory or file
    char *p = path;

    while (*p != '\0') {
     64f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     652:	0f b6 00             	movzbl (%eax),%eax
     655:	84 c0                	test   %al,%al
     657:	75 b7                	jne    610 <r_mkdir+0xe>
            }
            *p = '/';
        }
        p++;
    }
}
     659:	90                   	nop
     65a:	c9                   	leave  
     65b:	c3                   	ret    

0000065c <parse>:

void parse(char check[], char path[], char dest[])
{
     65c:	55                   	push   %ebp
     65d:	89 e5                	mov    %esp,%ebp
     65f:	83 ec 10             	sub    $0x10,%esp
   	char *a = check; //this is to iterate the base direct (original check)
     662:	8b 45 08             	mov    0x8(%ebp),%eax
     665:	89 45 fc             	mov    %eax,-0x4(%ebp)
	char *b = dest;
     668:	8b 45 10             	mov    0x10(%ebp),%eax
     66b:	89 45 f8             	mov    %eax,-0x8(%ebp)
    	while (*a != '\0') {//goes till end of string /checkpoint
     66e:	eb 13                	jmp    683 <parse+0x27>
		*b = *a;
     670:	8b 45 fc             	mov    -0x4(%ebp),%eax
     673:	0f b6 10             	movzbl (%eax),%edx
     676:	8b 45 f8             	mov    -0x8(%ebp),%eax
     679:	88 10                	mov    %dl,(%eax)
		a++;
     67b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
		b++;
     67f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)

void parse(char check[], char path[], char dest[])
{
   	char *a = check; //this is to iterate the base direct (original check)
	char *b = dest;
    	while (*a != '\0') {//goes till end of string /checkpoint
     683:	8b 45 fc             	mov    -0x4(%ebp),%eax
     686:	0f b6 00             	movzbl (%eax),%eax
     689:	84 c0                	test   %al,%al
     68b:	75 e3                	jne    670 <parse+0x14>
//this adds / to the end of /checkpoint to be /checkpoint/

	//*b = '/'; 
	//b++;

	a = path;//sets a to be the path we want to ad onto checkpoint
     68d:	8b 45 0c             	mov    0xc(%ebp),%eax
     690:	89 45 fc             	mov    %eax,-0x4(%ebp)

	while (*a != '\0') {//goes till end of string path
     693:	eb 13                	jmp    6a8 <parse+0x4c>
		*b = *a;
     695:	8b 45 fc             	mov    -0x4(%ebp),%eax
     698:	0f b6 10             	movzbl (%eax),%edx
     69b:	8b 45 f8             	mov    -0x8(%ebp),%eax
     69e:	88 10                	mov    %dl,(%eax)
		b++;
     6a0:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
		a++;
     6a4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
	//*b = '/'; 
	//b++;

	a = path;//sets a to be the path we want to ad onto checkpoint

	while (*a != '\0') {//goes till end of string path
     6a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
     6ab:	0f b6 00             	movzbl (%eax),%eax
     6ae:	84 c0                	test   %al,%al
     6b0:	75 e3                	jne    695 <parse+0x39>
		b++;
		a++;
		
	}

	*b = '\0'; 
     6b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
     6b5:	c6 00 00             	movb   $0x0,(%eax)
	b++;
     6b8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
	
	//*b = '\0';//adds the end
}
     6bc:	90                   	nop
     6bd:	c9                   	leave  
     6be:	c3                   	ret    

000006bf <checkpoint>:


int checkpoint(int fd_array, char * dest){
     6bf:	55                   	push   %ebp
     6c0:	89 e5                	mov    %esp,%ebp
     6c2:	81 ec 28 04 00 00    	sub    $0x428,%esp
	char * check=stored_path[fd_array];
     6c8:	8b 45 08             	mov    0x8(%ebp),%eax
     6cb:	8b 04 85 c0 24 00 00 	mov    0x24c0(,%eax,4),%eax
     6d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	printf(1,"now running checkpoint\n");
     6d5:	83 ec 08             	sub    $0x8,%esp
     6d8:	68 5c 1d 00 00       	push   $0x1d5c
     6dd:	6a 01                	push   $0x1
     6df:	e8 eb 11 00 00       	call   18cf <printf>
     6e4:	83 c4 10             	add    $0x10,%esp
	char path[1024];
	int nchars;
	int fd;
	int checkfd;
	int fd1;
	printf(1,"opening file %s\n",stored_path[fd_array]);
     6e7:	8b 45 08             	mov    0x8(%ebp),%eax
     6ea:	8b 04 85 c0 24 00 00 	mov    0x24c0(,%eax,4),%eax
     6f1:	83 ec 04             	sub    $0x4,%esp
     6f4:	50                   	push   %eax
     6f5:	68 74 1d 00 00       	push   $0x1d74
     6fa:	6a 01                	push   $0x1
     6fc:	e8 ce 11 00 00       	call   18cf <printf>
     701:	83 c4 10             	add    $0x10,%esp
    if ((fd = open(check, O_RDONLY)) < 0 ) {
     704:	83 ec 08             	sub    $0x8,%esp
     707:	6a 00                	push   $0x0
     709:	ff 75 f4             	pushl  -0xc(%ebp)
     70c:	e8 3f 10 00 00       	call   1750 <open>
     711:	83 c4 10             	add    $0x10,%esp
     714:	89 45 f0             	mov    %eax,-0x10(%ebp)
     717:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     71b:	79 0a                	jns    727 <checkpoint+0x68>
        
        return -1;
     71d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     722:	e9 95 01 00 00       	jmp    8bc <checkpoint+0x1fd>
    }
printf(1,"preparse\n");
     727:	83 ec 08             	sub    $0x8,%esp
     72a:	68 85 1d 00 00       	push   $0x1d85
     72f:	6a 01                	push   $0x1
     731:	e8 99 11 00 00       	call   18cf <printf>
     736:	83 c4 10             	add    $0x10,%esp
    parse(dest, check, path);//returns the path to be used in recursive mkdir
     739:	83 ec 04             	sub    $0x4,%esp
     73c:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     742:	50                   	push   %eax
     743:	ff 75 f4             	pushl  -0xc(%ebp)
     746:	ff 75 0c             	pushl  0xc(%ebp)
     749:	e8 0e ff ff ff       	call   65c <parse>
     74e:	83 c4 10             	add    $0x10,%esp

    printf(1, "filename:%s\n", path);
     751:	83 ec 04             	sub    $0x4,%esp
     754:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     75a:	50                   	push   %eax
     75b:	68 8f 1d 00 00       	push   $0x1d8f
     760:	6a 01                	push   $0x1
     762:	e8 68 11 00 00       	call   18cf <printf>
     767:	83 c4 10             	add    $0x10,%esp

    r_mkdir(path);//all this does is create all the directories leaving the path to just be called
     76a:	83 ec 0c             	sub    $0xc,%esp
     76d:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     773:	50                   	push   %eax
     774:	e8 89 fe ff ff       	call   602 <r_mkdir>
     779:	83 c4 10             	add    $0x10,%esp


    // delete if prexisting checkpoint
    
    if ((fd1 = open(path, O_RDONLY)) >= 0) {
     77c:	83 ec 08             	sub    $0x8,%esp
     77f:	6a 00                	push   $0x0
     781:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     787:	50                   	push   %eax
     788:	e8 c3 0f 00 00       	call   1750 <open>
     78d:	83 c4 10             	add    $0x10,%esp
     790:	89 45 ec             	mov    %eax,-0x14(%ebp)
     793:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     797:	78 20                	js     7b9 <checkpoint+0xfa>
        close(fd1);
     799:	83 ec 0c             	sub    $0xc,%esp
     79c:	ff 75 ec             	pushl  -0x14(%ebp)
     79f:	e8 94 0f 00 00       	call   1738 <close>
     7a4:	83 c4 10             	add    $0x10,%esp
        unlink(path);
     7a7:	83 ec 0c             	sub    $0xc,%esp
     7aa:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     7b0:	50                   	push   %eax
     7b1:	e8 aa 0f 00 00       	call   1760 <unlink>
     7b6:	83 c4 10             	add    $0x10,%esp
    }

    if ( (checkfd = open(path, O_WRONLY|O_CREATE)) < 0 )
     7b9:	83 ec 08             	sub    $0x8,%esp
     7bc:	68 01 02 00 00       	push   $0x201
     7c1:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     7c7:	50                   	push   %eax
     7c8:	e8 83 0f 00 00       	call   1750 <open>
     7cd:	83 c4 10             	add    $0x10,%esp
     7d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
     7d3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     7d7:	79 12                	jns    7eb <checkpoint+0x12c>
        printf(1,"Can not create file\n");
     7d9:	83 ec 08             	sub    $0x8,%esp
     7dc:	68 9c 1d 00 00       	push   $0x1d9c
     7e1:	6a 01                	push   $0x1
     7e3:	e8 e7 10 00 00       	call   18cf <printf>
     7e8:	83 c4 10             	add    $0x10,%esp

    char *buf = path;
     7eb:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     7f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    memset(buf, 0, 1024);
     7f4:	83 ec 04             	sub    $0x4,%esp
     7f7:	68 00 04 00 00       	push   $0x400
     7fc:	6a 00                	push   $0x0
     7fe:	ff 75 e4             	pushl  -0x1c(%ebp)
     801:	e8 6f 0d 00 00       	call   1575 <memset>
     806:	83 c4 10             	add    $0x10,%esp

    while ((nchars = read(fd, buf, sizeof(buf))) > 0) {
     809:	eb 46                	jmp    851 <checkpoint+0x192>
	//mirrored after CAT
	if (nchars < 0) {
     80b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     80f:	79 17                	jns    828 <checkpoint+0x169>
		printf(1, "read error\n");//prints to consol
     811:	83 ec 08             	sub    $0x8,%esp
     814:	68 b1 1d 00 00       	push   $0x1db1
     819:	6a 01                	push   $0x1
     81b:	e8 af 10 00 00       	call   18cf <printf>
     820:	83 c4 10             	add    $0x10,%esp
		exit();
     823:	e8 e8 0e 00 00       	call   1710 <exit>
	}
    		write(checkfd, buf, nchars);//creates the backup 
     828:	83 ec 04             	sub    $0x4,%esp
     82b:	ff 75 e0             	pushl  -0x20(%ebp)
     82e:	ff 75 e4             	pushl  -0x1c(%ebp)
     831:	ff 75 e8             	pushl  -0x18(%ebp)
     834:	e8 f7 0e 00 00       	call   1730 <write>
     839:	83 c4 10             	add    $0x10,%esp
	 	memset(buf, 0, 1024);
     83c:	83 ec 04             	sub    $0x4,%esp
     83f:	68 00 04 00 00       	push   $0x400
     844:	6a 00                	push   $0x0
     846:	ff 75 e4             	pushl  -0x1c(%ebp)
     849:	e8 27 0d 00 00       	call   1575 <memset>
     84e:	83 c4 10             	add    $0x10,%esp
        printf(1,"Can not create file\n");

    char *buf = path;
    memset(buf, 0, 1024);

    while ((nchars = read(fd, buf, sizeof(buf))) > 0) {
     851:	83 ec 04             	sub    $0x4,%esp
     854:	6a 04                	push   $0x4
     856:	ff 75 e4             	pushl  -0x1c(%ebp)
     859:	ff 75 f0             	pushl  -0x10(%ebp)
     85c:	e8 c7 0e 00 00       	call   1728 <read>
     861:	83 c4 10             	add    $0x10,%esp
     864:	89 45 e0             	mov    %eax,-0x20(%ebp)
     867:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     86b:	7f 9e                	jg     80b <checkpoint+0x14c>
	 	memset(buf, 0, 1024);
    }
	

//checks if close works
    	if (close(fd) == -1 ){
     86d:	83 ec 0c             	sub    $0xc,%esp
     870:	ff 75 f0             	pushl  -0x10(%ebp)
     873:	e8 c0 0e 00 00       	call   1738 <close>
     878:	83 c4 10             	add    $0x10,%esp
     87b:	83 f8 ff             	cmp    $0xffffffff,%eax
     87e:	75 12                	jne    892 <checkpoint+0x1d3>
		printf(1,"Can not close origin file\n");
     880:	83 ec 08             	sub    $0x8,%esp
     883:	68 bd 1d 00 00       	push   $0x1dbd
     888:	6a 01                	push   $0x1
     88a:	e8 40 10 00 00       	call   18cf <printf>
     88f:	83 c4 10             	add    $0x10,%esp
	}	
	if (close(checkfd) == -1){
     892:	83 ec 0c             	sub    $0xc,%esp
     895:	ff 75 e8             	pushl  -0x18(%ebp)
     898:	e8 9b 0e 00 00       	call   1738 <close>
     89d:	83 c4 10             	add    $0x10,%esp
     8a0:	83 f8 ff             	cmp    $0xffffffff,%eax
     8a3:	75 12                	jne    8b7 <checkpoint+0x1f8>
        	printf(1,"Can not close checkpoint file\n");
     8a5:	83 ec 08             	sub    $0x8,%esp
     8a8:	68 d8 1d 00 00       	push   $0x1dd8
     8ad:	6a 01                	push   $0x1
     8af:	e8 1b 10 00 00       	call   18cf <printf>
     8b4:	83 c4 10             	add    $0x10,%esp
	}

    return 0;
     8b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
     8bc:	c9                   	leave  
     8bd:	c3                   	ret    

000008be <fmtname>:



char *fmtname(char *path)
{
     8be:	55                   	push   %ebp
     8bf:	89 e5                	mov    %esp,%ebp
     8c1:	53                   	push   %ebx
     8c2:	83 ec 14             	sub    $0x14,%esp
	static char buf[DIRSIZ + 1];
	char *p;

	// Find first character after last slash.
	for (p = path + strlen(path); p >= path && *p != '/'; p--) ;
     8c5:	83 ec 0c             	sub    $0xc,%esp
     8c8:	ff 75 08             	pushl  0x8(%ebp)
     8cb:	e8 7e 0c 00 00       	call   154e <strlen>
     8d0:	83 c4 10             	add    $0x10,%esp
     8d3:	89 c2                	mov    %eax,%edx
     8d5:	8b 45 08             	mov    0x8(%ebp),%eax
     8d8:	01 d0                	add    %edx,%eax
     8da:	89 45 f4             	mov    %eax,-0xc(%ebp)
     8dd:	eb 04                	jmp    8e3 <fmtname+0x25>
     8df:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
     8e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8e6:	3b 45 08             	cmp    0x8(%ebp),%eax
     8e9:	72 0a                	jb     8f5 <fmtname+0x37>
     8eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8ee:	0f b6 00             	movzbl (%eax),%eax
     8f1:	3c 2f                	cmp    $0x2f,%al
     8f3:	75 ea                	jne    8df <fmtname+0x21>
	p++;
     8f5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

	// Return blank-padded name.
	if (strlen(p) >= DIRSIZ)
     8f9:	83 ec 0c             	sub    $0xc,%esp
     8fc:	ff 75 f4             	pushl  -0xc(%ebp)
     8ff:	e8 4a 0c 00 00       	call   154e <strlen>
     904:	83 c4 10             	add    $0x10,%esp
     907:	83 f8 0d             	cmp    $0xd,%eax
     90a:	76 05                	jbe    911 <fmtname+0x53>
		return p;
     90c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     90f:	eb 60                	jmp    971 <fmtname+0xb3>
	memmove(buf, p, strlen(p));
     911:	83 ec 0c             	sub    $0xc,%esp
     914:	ff 75 f4             	pushl  -0xc(%ebp)
     917:	e8 32 0c 00 00       	call   154e <strlen>
     91c:	83 c4 10             	add    $0x10,%esp
     91f:	83 ec 04             	sub    $0x4,%esp
     922:	50                   	push   %eax
     923:	ff 75 f4             	pushl  -0xc(%ebp)
     926:	68 80 24 00 00       	push   $0x2480
     92b:	e8 9b 0d 00 00       	call   16cb <memmove>
     930:	83 c4 10             	add    $0x10,%esp
	memset(buf + strlen(p), ' ', DIRSIZ - strlen(p));
     933:	83 ec 0c             	sub    $0xc,%esp
     936:	ff 75 f4             	pushl  -0xc(%ebp)
     939:	e8 10 0c 00 00       	call   154e <strlen>
     93e:	83 c4 10             	add    $0x10,%esp
     941:	ba 0e 00 00 00       	mov    $0xe,%edx
     946:	89 d3                	mov    %edx,%ebx
     948:	29 c3                	sub    %eax,%ebx
     94a:	83 ec 0c             	sub    $0xc,%esp
     94d:	ff 75 f4             	pushl  -0xc(%ebp)
     950:	e8 f9 0b 00 00       	call   154e <strlen>
     955:	83 c4 10             	add    $0x10,%esp
     958:	05 80 24 00 00       	add    $0x2480,%eax
     95d:	83 ec 04             	sub    $0x4,%esp
     960:	53                   	push   %ebx
     961:	6a 20                	push   $0x20
     963:	50                   	push   %eax
     964:	e8 0c 0c 00 00       	call   1575 <memset>
     969:	83 c4 10             	add    $0x10,%esp
	return buf;
     96c:	b8 80 24 00 00       	mov    $0x2480,%eax
}
     971:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     974:	c9                   	leave  
     975:	c3                   	ret    

00000976 <restore>:
int restore(char * path){
     976:	55                   	push   %ebp
     977:	89 e5                	mov    %esp,%ebp
     979:	81 ec 48 08 00 00    	sub    $0x848,%esp
	printf(1,"restore called\n");
     97f:	83 ec 08             	sub    $0x8,%esp
     982:	68 f7 1d 00 00       	push   $0x1df7
     987:	6a 01                	push   $0x1
     989:	e8 41 0f 00 00       	call   18cf <printf>
     98e:	83 c4 10             	add    $0x10,%esp
	int checkfd;
	//int n;
	struct dirent de;
	struct stat st;
	char * parsed_path;
	parsed_path=path+12;//get rid of teh /checkpoint part of the path 
     991:	8b 45 08             	mov    0x8(%ebp),%eax
     994:	83 c0 0c             	add    $0xc,%eax
     997:	89 45 f0             	mov    %eax,-0x10(%ebp)


	char dir_path [1024];
	//used for recursively creating the directories similar to previous implementation

	printf(1,"parsed path= %s\n",parsed_path);
     99a:	83 ec 04             	sub    $0x4,%esp
     99d:	ff 75 f0             	pushl  -0x10(%ebp)
     9a0:	68 07 1e 00 00       	push   $0x1e07
     9a5:	6a 01                	push   $0x1
     9a7:	e8 23 0f 00 00       	call   18cf <printf>
     9ac:	83 c4 10             	add    $0x10,%esp
	printf(1,"test\n");
     9af:	83 ec 08             	sub    $0x8,%esp
     9b2:	68 18 1e 00 00       	push   $0x1e18
     9b7:	6a 01                	push   $0x1
     9b9:	e8 11 0f 00 00       	call   18cf <printf>
     9be:	83 c4 10             	add    $0x10,%esp
	if ((fd = open(path, 0)) < 0) {
     9c1:	83 ec 08             	sub    $0x8,%esp
     9c4:	6a 00                	push   $0x0
     9c6:	ff 75 08             	pushl  0x8(%ebp)
     9c9:	e8 82 0d 00 00       	call   1750 <open>
     9ce:	83 c4 10             	add    $0x10,%esp
     9d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
     9d4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     9d8:	79 1a                	jns    9f4 <restore+0x7e>
		printf(2, "restore: cannot open %s\n", path);
     9da:	83 ec 04             	sub    $0x4,%esp
     9dd:	ff 75 08             	pushl  0x8(%ebp)
     9e0:	68 1e 1e 00 00       	push   $0x1e1e
     9e5:	6a 02                	push   $0x2
     9e7:	e8 e3 0e 00 00       	call   18cf <printf>
     9ec:	83 c4 10             	add    $0x10,%esp
		exit();
     9ef:	e8 1c 0d 00 00       	call   1710 <exit>
	}

	if (fstat(fd, &st) < 0) {
     9f4:	83 ec 08             	sub    $0x8,%esp
     9f7:	8d 85 bc fb ff ff    	lea    -0x444(%ebp),%eax
     9fd:	50                   	push   %eax
     9fe:	ff 75 ec             	pushl  -0x14(%ebp)
     a01:	e8 62 0d 00 00       	call   1768 <fstat>
     a06:	83 c4 10             	add    $0x10,%esp
     a09:	85 c0                	test   %eax,%eax
     a0b:	79 28                	jns    a35 <restore+0xbf>
		printf(2, "restore: cannot stat %s\n", path);
     a0d:	83 ec 04             	sub    $0x4,%esp
     a10:	ff 75 08             	pushl  0x8(%ebp)
     a13:	68 37 1e 00 00       	push   $0x1e37
     a18:	6a 02                	push   $0x2
     a1a:	e8 b0 0e 00 00       	call   18cf <printf>
     a1f:	83 c4 10             	add    $0x10,%esp
		close(fd);
     a22:	83 ec 0c             	sub    $0xc,%esp
     a25:	ff 75 ec             	pushl  -0x14(%ebp)
     a28:	e8 0b 0d 00 00       	call   1738 <close>
     a2d:	83 c4 10             	add    $0x10,%esp
		exit();
     a30:	e8 db 0c 00 00       	call   1710 <exit>
	}
	switch (st.type) {
     a35:	0f b7 85 bc fb ff ff 	movzwl -0x444(%ebp),%eax
     a3c:	98                   	cwtl   
     a3d:	83 e8 01             	sub    $0x1,%eax
     a40:	83 f8 01             	cmp    $0x1,%eax
     a43:	0f 87 bd 03 00 00    	ja     e06 <restore+0x490>

		
		

	case T_DIR:
		if (strlen(path) + 1 + DIRSIZ + 1 > sizeof buf) {
     a49:	83 ec 0c             	sub    $0xc,%esp
     a4c:	ff 75 08             	pushl  0x8(%ebp)
     a4f:	e8 fa 0a 00 00       	call   154e <strlen>
     a54:	83 c4 10             	add    $0x10,%esp
     a57:	83 c0 10             	add    $0x10,%eax
     a5a:	3d 00 04 00 00       	cmp    $0x400,%eax
     a5f:	76 17                	jbe    a78 <restore+0x102>
			printf(1, "ls: path too long\n");
     a61:	83 ec 08             	sub    $0x8,%esp
     a64:	68 50 1e 00 00       	push   $0x1e50
     a69:	6a 01                	push   $0x1
     a6b:	e8 5f 0e 00 00       	call   18cf <printf>
     a70:	83 c4 10             	add    $0x10,%esp
			exit();
     a73:	e8 98 0c 00 00       	call   1710 <exit>
		}
		
		strcpy(buf, path);
     a78:	83 ec 08             	sub    $0x8,%esp
     a7b:	ff 75 08             	pushl  0x8(%ebp)
     a7e:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     a84:	50                   	push   %eax
     a85:	e8 55 0a 00 00       	call   14df <strcpy>
     a8a:	83 c4 10             	add    $0x10,%esp
		p = buf + strlen(buf);
     a8d:	83 ec 0c             	sub    $0xc,%esp
     a90:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     a96:	50                   	push   %eax
     a97:	e8 b2 0a 00 00       	call   154e <strlen>
     a9c:	83 c4 10             	add    $0x10,%esp
     a9f:	89 c2                	mov    %eax,%edx
     aa1:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     aa7:	01 d0                	add    %edx,%eax
     aa9:	89 45 e8             	mov    %eax,-0x18(%ebp)
		*p++ = '/';
     aac:	8b 45 e8             	mov    -0x18(%ebp),%eax
     aaf:	8d 50 01             	lea    0x1(%eax),%edx
     ab2:	89 55 e8             	mov    %edx,-0x18(%ebp)
     ab5:	c6 00 2f             	movb   $0x2f,(%eax)
		while (read(fd, &de, sizeof(de)) == sizeof(de)) {
     ab8:	e9 29 03 00 00       	jmp    de6 <restore+0x470>
			if (de.inum == 0)
     abd:	0f b7 85 d0 fb ff ff 	movzwl -0x430(%ebp),%eax
     ac4:	66 85 c0             	test   %ax,%ax
     ac7:	75 05                	jne    ace <restore+0x158>
				continue;
     ac9:	e9 18 03 00 00       	jmp    de6 <restore+0x470>
			memmove(p, de.name, DIRSIZ);
     ace:	83 ec 04             	sub    $0x4,%esp
     ad1:	6a 0e                	push   $0xe
     ad3:	8d 85 d0 fb ff ff    	lea    -0x430(%ebp),%eax
     ad9:	83 c0 02             	add    $0x2,%eax
     adc:	50                   	push   %eax
     add:	ff 75 e8             	pushl  -0x18(%ebp)
     ae0:	e8 e6 0b 00 00       	call   16cb <memmove>
     ae5:	83 c4 10             	add    $0x10,%esp
			p[DIRSIZ] = 0;
     ae8:	8b 45 e8             	mov    -0x18(%ebp),%eax
     aeb:	83 c0 0e             	add    $0xe,%eax
     aee:	c6 00 00             	movb   $0x0,(%eax)
			if (stat(buf, &st) < 0) {
     af1:	83 ec 08             	sub    $0x8,%esp
     af4:	8d 85 bc fb ff ff    	lea    -0x444(%ebp),%eax
     afa:	50                   	push   %eax
     afb:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     b01:	50                   	push   %eax
     b02:	e8 2a 0b 00 00       	call   1631 <stat>
     b07:	83 c4 10             	add    $0x10,%esp
     b0a:	85 c0                	test   %eax,%eax
     b0c:	79 1e                	jns    b2c <restore+0x1b6>
				printf(1, "ls: cannot stat %s\n", buf);
     b0e:	83 ec 04             	sub    $0x4,%esp
     b11:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     b17:	50                   	push   %eax
     b18:	68 63 1e 00 00       	push   $0x1e63
     b1d:	6a 01                	push   $0x1
     b1f:	e8 ab 0d 00 00       	call   18cf <printf>
     b24:	83 c4 10             	add    $0x10,%esp
				continue;
     b27:	e9 ba 02 00 00       	jmp    de6 <restore+0x470>
			}
			//printf(1, "%s %d %d %d\n", fmtname(buf));
			
			if (st.type==1){
     b2c:	0f b7 85 bc fb ff ff 	movzwl -0x444(%ebp),%eax
     b33:	66 83 f8 01          	cmp    $0x1,%ax
     b37:	0f 85 80 01 00 00    	jne    cbd <restore+0x347>
				char * cmp= strcpy(cmp,fmtname(buf));
     b3d:	83 ec 0c             	sub    $0xc,%esp
     b40:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     b46:	50                   	push   %eax
     b47:	e8 72 fd ff ff       	call   8be <fmtname>
     b4c:	83 c4 10             	add    $0x10,%esp
     b4f:	83 ec 08             	sub    $0x8,%esp
     b52:	50                   	push   %eax
     b53:	ff 75 f4             	pushl  -0xc(%ebp)
     b56:	e8 84 09 00 00       	call   14df <strcpy>
     b5b:	83 c4 10             	add    $0x10,%esp
     b5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
				//printf(1,"cmp =%s\n",cmp);
				//printf(1,"%d",(strcmp(cmp,"..")));
				if ((strcmp(cmp,"."))==32||(strcmp(cmp,".."))==32){
     b61:	83 ec 08             	sub    $0x8,%esp
     b64:	68 77 1e 00 00       	push   $0x1e77
     b69:	ff 75 f4             	pushl  -0xc(%ebp)
     b6c:	e8 9e 09 00 00       	call   150f <strcmp>
     b71:	83 c4 10             	add    $0x10,%esp
     b74:	83 f8 20             	cmp    $0x20,%eax
     b77:	0f 84 69 02 00 00    	je     de6 <restore+0x470>
     b7d:	83 ec 08             	sub    $0x8,%esp
     b80:	68 79 1e 00 00       	push   $0x1e79
     b85:	ff 75 f4             	pushl  -0xc(%ebp)
     b88:	e8 82 09 00 00       	call   150f <strcmp>
     b8d:	83 c4 10             	add    $0x10,%esp
     b90:	83 f8 20             	cmp    $0x20,%eax
     b93:	0f 84 4d 02 00 00    	je     de6 <restore+0x470>
					//just ignore
				//	printf(1,"testme\n");
				}
				else{
				printf(1, "parsed_path = %s\n", parsed_path);
     b99:	83 ec 04             	sub    $0x4,%esp
     b9c:	ff 75 f0             	pushl  -0x10(%ebp)
     b9f:	68 7c 1e 00 00       	push   $0x1e7c
     ba4:	6a 01                	push   $0x1
     ba6:	e8 24 0d 00 00       	call   18cf <printf>
     bab:	83 c4 10             	add    $0x10,%esp
				printf(1,"dir_path is = %s\n",dir_path);
     bae:	83 ec 04             	sub    $0x4,%esp
     bb1:	8d 85 bc f7 ff ff    	lea    -0x844(%ebp),%eax
     bb7:	50                   	push   %eax
     bb8:	68 8e 1e 00 00       	push   $0x1e8e
     bbd:	6a 01                	push   $0x1
     bbf:	e8 0b 0d 00 00       	call   18cf <printf>
     bc4:	83 c4 10             	add    $0x10,%esp
				printf(1,"restored directory %s\n",fmtname(buf));
     bc7:	83 ec 0c             	sub    $0xc,%esp
     bca:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     bd0:	50                   	push   %eax
     bd1:	e8 e8 fc ff ff       	call   8be <fmtname>
     bd6:	83 c4 10             	add    $0x10,%esp
     bd9:	83 ec 04             	sub    $0x4,%esp
     bdc:	50                   	push   %eax
     bdd:	68 a0 1e 00 00       	push   $0x1ea0
     be2:	6a 01                	push   $0x1
     be4:	e8 e6 0c 00 00       	call   18cf <printf>
     be9:	83 c4 10             	add    $0x10,%esp
				parse(parsed_path, fmtname(buf), dir_path);
     bec:	83 ec 0c             	sub    $0xc,%esp
     bef:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     bf5:	50                   	push   %eax
     bf6:	e8 c3 fc ff ff       	call   8be <fmtname>
     bfb:	83 c4 10             	add    $0x10,%esp
     bfe:	89 c2                	mov    %eax,%edx
     c00:	83 ec 04             	sub    $0x4,%esp
     c03:	8d 85 bc f7 ff ff    	lea    -0x844(%ebp),%eax
     c09:	50                   	push   %eax
     c0a:	52                   	push   %edx
     c0b:	ff 75 f0             	pushl  -0x10(%ebp)
     c0e:	e8 49 fa ff ff       	call   65c <parse>
     c13:	83 c4 10             	add    $0x10,%esp
				
				printf(1, "parsed_path = %s\n", parsed_path);
     c16:	83 ec 04             	sub    $0x4,%esp
     c19:	ff 75 f0             	pushl  -0x10(%ebp)
     c1c:	68 7c 1e 00 00       	push   $0x1e7c
     c21:	6a 01                	push   $0x1
     c23:	e8 a7 0c 00 00       	call   18cf <printf>
     c28:	83 c4 10             	add    $0x10,%esp
				printf(1,"dir_path is = %s\n",dir_path);
     c2b:	83 ec 04             	sub    $0x4,%esp
     c2e:	8d 85 bc f7 ff ff    	lea    -0x844(%ebp),%eax
     c34:	50                   	push   %eax
     c35:	68 8e 1e 00 00       	push   $0x1e8e
     c3a:	6a 01                	push   $0x1
     c3c:	e8 8e 0c 00 00       	call   18cf <printf>
     c41:	83 c4 10             	add    $0x10,%esp
				printf(1,"restored directory %s\n",fmtname(buf));
     c44:	83 ec 0c             	sub    $0xc,%esp
     c47:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     c4d:	50                   	push   %eax
     c4e:	e8 6b fc ff ff       	call   8be <fmtname>
     c53:	83 c4 10             	add    $0x10,%esp
     c56:	83 ec 04             	sub    $0x4,%esp
     c59:	50                   	push   %eax
     c5a:	68 a0 1e 00 00       	push   $0x1ea0
     c5f:	6a 01                	push   $0x1
     c61:	e8 69 0c 00 00       	call   18cf <printf>
     c66:	83 c4 10             	add    $0x10,%esp
				mkdir(dir_path);
     c69:	83 ec 0c             	sub    $0xc,%esp
     c6c:	8d 85 bc f7 ff ff    	lea    -0x844(%ebp),%eax
     c72:	50                   	push   %eax
     c73:	e8 00 0b 00 00       	call   1778 <mkdir>
     c78:	83 c4 10             	add    $0x10,%esp
				parse(path, dir_path, path);
     c7b:	83 ec 04             	sub    $0x4,%esp
     c7e:	ff 75 08             	pushl  0x8(%ebp)
     c81:	8d 85 bc f7 ff ff    	lea    -0x844(%ebp),%eax
     c87:	50                   	push   %eax
     c88:	ff 75 08             	pushl  0x8(%ebp)
     c8b:	e8 cc f9 ff ff       	call   65c <parse>
     c90:	83 c4 10             	add    $0x10,%esp
				printf(1,"path is = %s\n",path);
     c93:	83 ec 04             	sub    $0x4,%esp
     c96:	ff 75 08             	pushl  0x8(%ebp)
     c99:	68 b7 1e 00 00       	push   $0x1eb7
     c9e:	6a 01                	push   $0x1
     ca0:	e8 2a 0c 00 00       	call   18cf <printf>
     ca5:	83 c4 10             	add    $0x10,%esp
				restore("path");
     ca8:	83 ec 0c             	sub    $0xc,%esp
     cab:	68 c5 1e 00 00       	push   $0x1ec5
     cb0:	e8 c1 fc ff ff       	call   976 <restore>
     cb5:	83 c4 10             	add    $0x10,%esp
     cb8:	e9 29 01 00 00       	jmp    de6 <restore+0x470>
				//aka its a directory we need to recurse 
				}
			}
			else{//it is a file or something else might want to be more strict here idk
				 if ((checkfd = open(parsed_path, O_RDONLY)) >= 0) {
     cbd:	83 ec 08             	sub    $0x8,%esp
     cc0:	6a 00                	push   $0x0
     cc2:	ff 75 f0             	pushl  -0x10(%ebp)
     cc5:	e8 86 0a 00 00       	call   1750 <open>
     cca:	83 c4 10             	add    $0x10,%esp
     ccd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     cd0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     cd4:	78 1c                	js     cf2 <restore+0x37c>
					close(checkfd);
     cd6:	83 ec 0c             	sub    $0xc,%esp
     cd9:	ff 75 e4             	pushl  -0x1c(%ebp)
     cdc:	e8 57 0a 00 00       	call   1738 <close>
     ce1:	83 c4 10             	add    $0x10,%esp
					unlink(path);
     ce4:	83 ec 0c             	sub    $0xc,%esp
     ce7:	ff 75 08             	pushl  0x8(%ebp)
     cea:	e8 71 0a 00 00       	call   1760 <unlink>
     cef:	83 c4 10             	add    $0x10,%esp
		   		 }//checks if file still exists in location and deletes that mofo

				
				 if ( (checkfd = open(parsed_path, O_WRONLY|O_CREATE)) < 0 ){
     cf2:	83 ec 08             	sub    $0x8,%esp
     cf5:	68 01 02 00 00       	push   $0x201
     cfa:	ff 75 f0             	pushl  -0x10(%ebp)
     cfd:	e8 4e 0a 00 00       	call   1750 <open>
     d02:	83 c4 10             	add    $0x10,%esp
     d05:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     d08:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     d0c:	79 12                	jns    d20 <restore+0x3aa>

					//creates new file
					printf(1,"Can not create file\n");
     d0e:	83 ec 08             	sub    $0x8,%esp
     d11:	68 9c 1d 00 00       	push   $0x1d9c
     d16:	6a 01                	push   $0x1
     d18:	e8 b2 0b 00 00       	call   18cf <printf>
     d1d:	83 c4 10             	add    $0x10,%esp
				 }
				 
				 strcpy(buf,parsed_path);//might be an isseu here 
     d20:	83 ec 08             	sub    $0x8,%esp
     d23:	ff 75 f0             	pushl  -0x10(%ebp)
     d26:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     d2c:	50                   	push   %eax
     d2d:	e8 ad 07 00 00       	call   14df <strcpy>
     d32:	83 c4 10             	add    $0x10,%esp
				 memset(buf, 0, 1024);
     d35:	83 ec 04             	sub    $0x4,%esp
     d38:	68 00 04 00 00       	push   $0x400
     d3d:	6a 00                	push   $0x0
     d3f:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     d45:	50                   	push   %eax
     d46:	e8 2a 08 00 00       	call   1575 <memset>
     d4b:	83 c4 10             	add    $0x10,%esp
				 int nchars;
				 while ((nchars = read(fd, buf, sizeof(buf))) > 0) {
     d4e:	eb 4e                	jmp    d9e <restore+0x428>
					//mirrored after CAT
					 if (nchars < 0) {
     d50:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     d54:	79 17                	jns    d6d <restore+0x3f7>
							printf(1, "read error\n");//prints to consol
     d56:	83 ec 08             	sub    $0x8,%esp
     d59:	68 b1 1d 00 00       	push   $0x1db1
     d5e:	6a 01                	push   $0x1
     d60:	e8 6a 0b 00 00       	call   18cf <printf>
     d65:	83 c4 10             	add    $0x10,%esp
							exit();
     d68:	e8 a3 09 00 00       	call   1710 <exit>
					 }
				    		write(checkfd, buf, nchars);//creates the backup 
     d6d:	83 ec 04             	sub    $0x4,%esp
     d70:	ff 75 e0             	pushl  -0x20(%ebp)
     d73:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     d79:	50                   	push   %eax
     d7a:	ff 75 e4             	pushl  -0x1c(%ebp)
     d7d:	e8 ae 09 00 00       	call   1730 <write>
     d82:	83 c4 10             	add    $0x10,%esp
					 	memset(buf, 0, 1024);
     d85:	83 ec 04             	sub    $0x4,%esp
     d88:	68 00 04 00 00       	push   $0x400
     d8d:	6a 00                	push   $0x0
     d8f:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     d95:	50                   	push   %eax
     d96:	e8 da 07 00 00       	call   1575 <memset>
     d9b:	83 c4 10             	add    $0x10,%esp
				 }
				 
				 strcpy(buf,parsed_path);//might be an isseu here 
				 memset(buf, 0, 1024);
				 int nchars;
				 while ((nchars = read(fd, buf, sizeof(buf))) > 0) {
     d9e:	83 ec 04             	sub    $0x4,%esp
     da1:	68 00 04 00 00       	push   $0x400
     da6:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     dac:	50                   	push   %eax
     dad:	ff 75 ec             	pushl  -0x14(%ebp)
     db0:	e8 73 09 00 00       	call   1728 <read>
     db5:	83 c4 10             	add    $0x10,%esp
     db8:	89 45 e0             	mov    %eax,-0x20(%ebp)
     dbb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     dbf:	7f 8f                	jg     d50 <restore+0x3da>
							exit();
					 }
				    		write(checkfd, buf, nchars);//creates the backup 
					 	memset(buf, 0, 1024);
				 }
				printf(1,"restored file %s\n",fmtname(buf));
     dc1:	83 ec 0c             	sub    $0xc,%esp
     dc4:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
     dca:	50                   	push   %eax
     dcb:	e8 ee fa ff ff       	call   8be <fmtname>
     dd0:	83 c4 10             	add    $0x10,%esp
     dd3:	83 ec 04             	sub    $0x4,%esp
     dd6:	50                   	push   %eax
     dd7:	68 ca 1e 00 00       	push   $0x1eca
     ddc:	6a 01                	push   $0x1
     dde:	e8 ec 0a 00 00       	call   18cf <printf>
     de3:	83 c4 10             	add    $0x10,%esp
		}
		
		strcpy(buf, path);
		p = buf + strlen(buf);
		*p++ = '/';
		while (read(fd, &de, sizeof(de)) == sizeof(de)) {
     de6:	83 ec 04             	sub    $0x4,%esp
     de9:	6a 10                	push   $0x10
     deb:	8d 85 d0 fb ff ff    	lea    -0x430(%ebp),%eax
     df1:	50                   	push   %eax
     df2:	ff 75 ec             	pushl  -0x14(%ebp)
     df5:	e8 2e 09 00 00       	call   1728 <read>
     dfa:	83 c4 10             	add    $0x10,%esp
     dfd:	83 f8 10             	cmp    $0x10,%eax
     e00:	0f 84 b7 fc ff ff    	je     abd <restore+0x147>
		
			
		}
		
	}
	close(fd);
     e06:	83 ec 0c             	sub    $0xc,%esp
     e09:	ff 75 ec             	pushl  -0x14(%ebp)
     e0c:	e8 27 09 00 00       	call   1738 <close>
     e11:	83 c4 10             	add    $0x10,%esp
		exit();
     e14:	e8 f7 08 00 00       	call   1710 <exit>

00000e19 <main>:
}
int main(int argc, char *argv[]){
     e19:	8d 4c 24 04          	lea    0x4(%esp),%ecx
     e1d:	83 e4 f0             	and    $0xfffffff0,%esp
     e20:	ff 71 fc             	pushl  -0x4(%ecx)
     e23:	55                   	push   %ebp
     e24:	89 e5                	mov    %esp,%ebp
     e26:	51                   	push   %ecx
     e27:	81 ec 34 04 00 00    	sub    $0x434,%esp
	mkdir("checkpoint");
     e2d:	83 ec 0c             	sub    $0xc,%esp
     e30:	68 dc 1e 00 00       	push   $0x1edc
     e35:	e8 3e 09 00 00       	call   1778 <mkdir>
     e3a:	83 c4 10             	add    $0x10,%esp
	setHighPrio();//sets FSS to highest priority
     e3d:	e8 7e 09 00 00       	call   17c0 <setHighPrio>

	intialize_mutex();
     e42:	e8 b9 f1 ff ff       	call   0 <intialize_mutex>
	while(1){	
		
printf(1,"done blocking test\n");
     e47:	83 ec 08             	sub    $0x8,%esp
     e4a:	68 e7 1e 00 00       	push   $0x1ee7
     e4f:	6a 01                	push   $0x1
     e51:	e8 79 0a 00 00       	call   18cf <printf>
     e56:	83 c4 10             	add    $0x10,%esp
		//mutex_lock(mutexreq);
printf(1,"done blocking test2\n");
     e59:	83 ec 08             	sub    $0x8,%esp
     e5c:	68 fb 1e 00 00       	push   $0x1efb
     e61:	6a 01                	push   $0x1
     e63:	e8 67 0a 00 00       	call   18cf <printf>
     e68:	83 c4 10             	add    $0x10,%esp
printf(1,"$ ");
     e6b:	83 ec 08             	sub    $0x8,%esp
     e6e:	68 10 1f 00 00       	push   $0x1f10
     e73:	6a 01                	push   $0x1
     e75:	e8 55 0a 00 00       	call   18cf <printf>
     e7a:	83 c4 10             	add    $0x10,%esp
		cv_wait(mutexreq);
     e7d:	a1 50 26 00 00       	mov    0x2650,%eax
     e82:	83 ec 0c             	sub    $0xc,%esp
     e85:	50                   	push   %eax
     e86:	e8 5d 09 00 00       	call   17e8 <cv_wait>
     e8b:	83 c4 10             	add    $0x10,%esp
		printf(1,"signal set\n");
     e8e:	83 ec 08             	sub    $0x8,%esp
     e91:	68 13 1f 00 00       	push   $0x1f13
     e96:	6a 01                	push   $0x1
     e98:	e8 32 0a 00 00       	call   18cf <printf>
     e9d:	83 c4 10             	add    $0x10,%esp

		
struct fss_request * request= (struct fss_request *) shm_get("request",7);
     ea0:	83 ec 08             	sub    $0x8,%esp
     ea3:	6a 07                	push   $0x7
     ea5:	68 b3 1c 00 00       	push   $0x1cb3
     eaa:	e8 01 09 00 00       	call   17b0 <shm_get>
     eaf:	83 c4 10             	add    $0x10,%esp
     eb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
printf(1,"stored path = %s\n",stored_path[request->fd]);
     eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     eb8:	8b 40 0c             	mov    0xc(%eax),%eax
     ebb:	8b 04 85 c0 24 00 00 	mov    0x24c0(,%eax,4),%eax
     ec2:	83 ec 04             	sub    $0x4,%esp
     ec5:	50                   	push   %eax
     ec6:	68 1f 1f 00 00       	push   $0x1f1f
     ecb:	6a 01                	push   $0x1
     ecd:	e8 fd 09 00 00       	call   18cf <printf>
     ed2:	83 c4 10             	add    $0x10,%esp
		struct fss_response * response;
	printf(1,"stored path = %s\n",stored_path[request->fd]);
     ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ed8:	8b 40 0c             	mov    0xc(%eax),%eax
     edb:	8b 04 85 c0 24 00 00 	mov    0x24c0(,%eax,4),%eax
     ee2:	83 ec 04             	sub    $0x4,%esp
     ee5:	50                   	push   %eax
     ee6:	68 1f 1f 00 00       	push   $0x1f1f
     eeb:	6a 01                	push   $0x1
     eed:	e8 dd 09 00 00       	call   18cf <printf>
     ef2:	83 c4 10             	add    $0x10,%esp
		char * op=request->operation;
     ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ef8:	89 45 f0             	mov    %eax,-0x10(%ebp)
		printf(1,"servr received response processing type\n");
     efb:	83 ec 08             	sub    $0x8,%esp
     efe:	68 34 1f 00 00       	push   $0x1f34
     f03:	6a 01                	push   $0x1
     f05:	e8 c5 09 00 00       	call   18cf <printf>
     f0a:	83 c4 10             	add    $0x10,%esp
		printf(1,"command is %s\n",request->operation);
     f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f10:	83 ec 04             	sub    $0x4,%esp
     f13:	50                   	push   %eax
     f14:	68 5d 1f 00 00       	push   $0x1f5d
     f19:	6a 01                	push   $0x1
     f1b:	e8 af 09 00 00       	call   18cf <printf>
     f20:	83 c4 10             	add    $0x10,%esp
		if (strcmp(op,"write")==0){	
     f23:	83 ec 08             	sub    $0x8,%esp
     f26:	68 bb 1c 00 00       	push   $0x1cbb
     f2b:	ff 75 f0             	pushl  -0x10(%ebp)
     f2e:	e8 dc 05 00 00       	call   150f <strcmp>
     f33:	83 c4 10             	add    $0x10,%esp
     f36:	85 c0                	test   %eax,%eax
     f38:	0f 85 52 01 00 00    	jne    1090 <main+0x277>
			printf(1,"writing\n");	
     f3e:	83 ec 08             	sub    $0x8,%esp
     f41:	68 6c 1f 00 00       	push   $0x1f6c
     f46:	6a 01                	push   $0x1
     f48:	e8 82 09 00 00       	call   18cf <printf>
     f4d:	83 c4 10             	add    $0x10,%esp
			printf(1,"fd = %d\n",request->fd);
     f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f53:	8b 40 0c             	mov    0xc(%eax),%eax
     f56:	83 ec 04             	sub    $0x4,%esp
     f59:	50                   	push   %eax
     f5a:	68 75 1f 00 00       	push   $0x1f75
     f5f:	6a 01                	push   $0x1
     f61:	e8 69 09 00 00       	call   18cf <printf>
     f66:	83 c4 10             	add    $0x10,%esp
			printf(1,"stored path = %s\n",stored_path[request->fd]);
     f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f6c:	8b 40 0c             	mov    0xc(%eax),%eax
     f6f:	8b 04 85 c0 24 00 00 	mov    0x24c0(,%eax,4),%eax
     f76:	83 ec 04             	sub    $0x4,%esp
     f79:	50                   	push   %eax
     f7a:	68 1f 1f 00 00       	push   $0x1f1f
     f7f:	6a 01                	push   $0x1
     f81:	e8 49 09 00 00       	call   18cf <printf>
     f86:	83 c4 10             	add    $0x10,%esp
			mutex_unlock(mutexreq);
     f89:	a1 50 26 00 00       	mov    0x2650,%eax
     f8e:	83 ec 0c             	sub    $0xc,%esp
     f91:	50                   	push   %eax
     f92:	e8 49 08 00 00       	call   17e0 <mutex_unlock>
     f97:	83 c4 10             	add    $0x10,%esp
			mutex_lock(mutexresp);//double check this stuff
     f9a:	a1 a0 24 00 00       	mov    0x24a0,%eax
     f9f:	83 ec 0c             	sub    $0xc,%esp
     fa2:	50                   	push   %eax
     fa3:	e8 30 08 00 00       	call   17d8 <mutex_lock>
     fa8:	83 c4 10             	add    $0x10,%esp
			printf(1,"testing mutex locking inside write\n");
     fab:	83 ec 08             	sub    $0x8,%esp
     fae:	68 80 1f 00 00       	push   $0x1f80
     fb3:	6a 01                	push   $0x1
     fb5:	e8 15 09 00 00       	call   18cf <printf>
     fba:	83 c4 10             	add    $0x10,%esp
			response = (struct fss_response *) shm_get("response",8);
     fbd:	83 ec 08             	sub    $0x8,%esp
     fc0:	6a 08                	push   $0x8
     fc2:	68 e9 1c 00 00       	push   $0x1ce9
     fc7:	e8 e4 07 00 00       	call   17b0 <shm_get>
     fcc:	83 c4 10             	add    $0x10,%esp
     fcf:	89 45 ec             	mov    %eax,-0x14(%ebp)
			
			char check[16];
	
			memset(check, 0, sizeof(check));
     fd2:	83 ec 04             	sub    $0x4,%esp
     fd5:	6a 10                	push   $0x10
     fd7:	6a 00                	push   $0x0
     fd9:	8d 45 dc             	lea    -0x24(%ebp),%eax
     fdc:	50                   	push   %eax
     fdd:	e8 93 05 00 00       	call   1575 <memset>
     fe2:	83 c4 10             	add    $0x10,%esp
			printf(1,"calling checckpoint\n");
     fe5:	83 ec 08             	sub    $0x8,%esp
     fe8:	68 a4 1f 00 00       	push   $0x1fa4
     fed:	6a 01                	push   $0x1
     fef:	e8 db 08 00 00       	call   18cf <printf>
     ff4:	83 c4 10             	add    $0x10,%esp
			strcpy(check, "/checkpoint/\0");
     ff7:	83 ec 08             	sub    $0x8,%esp
     ffa:	68 b9 1f 00 00       	push   $0x1fb9
     fff:	8d 45 dc             	lea    -0x24(%ebp),%eax
    1002:	50                   	push   %eax
    1003:	e8 d7 04 00 00       	call   14df <strcpy>
    1008:	83 c4 10             	add    $0x10,%esp
			printf(1,"stored path = %s\n",stored_path[request->fd]);
    100b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    100e:	8b 40 0c             	mov    0xc(%eax),%eax
    1011:	8b 04 85 c0 24 00 00 	mov    0x24c0(,%eax,4),%eax
    1018:	83 ec 04             	sub    $0x4,%esp
    101b:	50                   	push   %eax
    101c:	68 1f 1f 00 00       	push   $0x1f1f
    1021:	6a 01                	push   $0x1
    1023:	e8 a7 08 00 00       	call   18cf <printf>
    1028:	83 c4 10             	add    $0x10,%esp
			checkpoint(request->fd, check);
    102b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    102e:	8b 40 0c             	mov    0xc(%eax),%eax
    1031:	83 ec 08             	sub    $0x8,%esp
    1034:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1037:	52                   	push   %edx
    1038:	50                   	push   %eax
    1039:	e8 81 f6 ff ff       	call   6bf <checkpoint>
    103e:	83 c4 10             	add    $0x10,%esp
			
			
			printf(1,"sending response\n");
    1041:	83 ec 08             	sub    $0x8,%esp
    1044:	68 c7 1f 00 00       	push   $0x1fc7
    1049:	6a 01                	push   $0x1
    104b:	e8 7f 08 00 00       	call   18cf <printf>
    1050:	83 c4 10             	add    $0x10,%esp
			response->res=write(request->fd,request->data,request->arg);
    1053:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1056:	8b 50 08             	mov    0x8(%eax),%edx
    1059:	8b 45 f4             	mov    -0xc(%ebp),%eax
    105c:	8d 48 10             	lea    0x10(%eax),%ecx
    105f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1062:	8b 40 0c             	mov    0xc(%eax),%eax
    1065:	83 ec 04             	sub    $0x4,%esp
    1068:	52                   	push   %edx
    1069:	51                   	push   %ecx
    106a:	50                   	push   %eax
    106b:	e8 c0 06 00 00       	call   1730 <write>
    1070:	83 c4 10             	add    $0x10,%esp
    1073:	89 c2                	mov    %eax,%edx
    1075:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1078:	89 10                	mov    %edx,(%eax)
			cv_signal(mutexresp);//signals response is written
    107a:	a1 a0 24 00 00       	mov    0x24a0,%eax
    107f:	83 ec 0c             	sub    $0xc,%esp
    1082:	50                   	push   %eax
    1083:	e8 68 07 00 00       	call   17f0 <cv_signal>
    1088:	83 c4 10             	add    $0x10,%esp
    108b:	e9 b7 fd ff ff       	jmp    e47 <main+0x2e>
			

		}
		else if (strcmp(op,"read")==0){
    1090:	83 ec 08             	sub    $0x8,%esp
    1093:	68 05 1d 00 00       	push   $0x1d05
    1098:	ff 75 f0             	pushl  -0x10(%ebp)
    109b:	e8 6f 04 00 00       	call   150f <strcmp>
    10a0:	83 c4 10             	add    $0x10,%esp
    10a3:	85 c0                	test   %eax,%eax
    10a5:	0f 85 c2 00 00 00    	jne    116d <main+0x354>
			//checkpoint(request->fd);
			mutex_unlock(mutexreq);
    10ab:	a1 50 26 00 00       	mov    0x2650,%eax
    10b0:	83 ec 0c             	sub    $0xc,%esp
    10b3:	50                   	push   %eax
    10b4:	e8 27 07 00 00       	call   17e0 <mutex_unlock>
    10b9:	83 c4 10             	add    $0x10,%esp
			mutex_lock(mutexresp);//double check this stuff
    10bc:	a1 a0 24 00 00       	mov    0x24a0,%eax
    10c1:	83 ec 0c             	sub    $0xc,%esp
    10c4:	50                   	push   %eax
    10c5:	e8 0e 07 00 00       	call   17d8 <mutex_lock>
    10ca:	83 c4 10             	add    $0x10,%esp
			response = (struct fss_response *) shm_get("response",8);
    10cd:	83 ec 08             	sub    $0x8,%esp
    10d0:	6a 08                	push   $0x8
    10d2:	68 e9 1c 00 00       	push   $0x1ce9
    10d7:	e8 d4 06 00 00       	call   17b0 <shm_get>
    10dc:	83 c4 10             	add    $0x10,%esp
    10df:	89 45 ec             	mov    %eax,-0x14(%ebp)
			printf(1,"fd = %d\n",request->fd);
    10e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10e5:	8b 40 0c             	mov    0xc(%eax),%eax
    10e8:	83 ec 04             	sub    $0x4,%esp
    10eb:	50                   	push   %eax
    10ec:	68 75 1f 00 00       	push   $0x1f75
    10f1:	6a 01                	push   $0x1
    10f3:	e8 d7 07 00 00       	call   18cf <printf>
    10f8:	83 c4 10             	add    $0x10,%esp

			printf(1,"read data = %s read size %d\n",request->data, request->arg);
    10fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10fe:	8b 40 08             	mov    0x8(%eax),%eax
    1101:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1104:	83 c2 10             	add    $0x10,%edx
    1107:	50                   	push   %eax
    1108:	52                   	push   %edx
    1109:	68 d9 1f 00 00       	push   $0x1fd9
    110e:	6a 01                	push   $0x1
    1110:	e8 ba 07 00 00       	call   18cf <printf>
    1115:	83 c4 10             	add    $0x10,%esp
			response->res=read(request->fd,request->data,request->arg);
    1118:	8b 45 f4             	mov    -0xc(%ebp),%eax
    111b:	8b 50 08             	mov    0x8(%eax),%edx
    111e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1121:	8d 48 10             	lea    0x10(%eax),%ecx
    1124:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1127:	8b 40 0c             	mov    0xc(%eax),%eax
    112a:	83 ec 04             	sub    $0x4,%esp
    112d:	52                   	push   %edx
    112e:	51                   	push   %ecx
    112f:	50                   	push   %eax
    1130:	e8 f3 05 00 00       	call   1728 <read>
    1135:	83 c4 10             	add    $0x10,%esp
    1138:	89 c2                	mov    %eax,%edx
    113a:	8b 45 ec             	mov    -0x14(%ebp),%eax
    113d:	89 10                	mov    %edx,(%eax)
			printf(1,"response was %d\n",response->res);
    113f:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1142:	8b 00                	mov    (%eax),%eax
    1144:	83 ec 04             	sub    $0x4,%esp
    1147:	50                   	push   %eax
    1148:	68 f6 1f 00 00       	push   $0x1ff6
    114d:	6a 01                	push   $0x1
    114f:	e8 7b 07 00 00       	call   18cf <printf>
    1154:	83 c4 10             	add    $0x10,%esp
			cv_signal(mutexresp);//signals response is written
    1157:	a1 a0 24 00 00       	mov    0x24a0,%eax
    115c:	83 ec 0c             	sub    $0xc,%esp
    115f:	50                   	push   %eax
    1160:	e8 8b 06 00 00       	call   17f0 <cv_signal>
    1165:	83 c4 10             	add    $0x10,%esp
    1168:	e9 da fc ff ff       	jmp    e47 <main+0x2e>
		}
		else if (strcmp(op,"open")==0){
    116d:	83 ec 08             	sub    $0x8,%esp
    1170:	68 24 1d 00 00       	push   $0x1d24
    1175:	ff 75 f0             	pushl  -0x10(%ebp)
    1178:	e8 92 03 00 00       	call   150f <strcmp>
    117d:	83 c4 10             	add    $0x10,%esp
    1180:	85 c0                	test   %eax,%eax
    1182:	0f 85 f3 00 00 00    	jne    127b <main+0x462>
		printf(1,"opening\n");
    1188:	83 ec 08             	sub    $0x8,%esp
    118b:	68 07 20 00 00       	push   $0x2007
    1190:	6a 01                	push   $0x1
    1192:	e8 38 07 00 00       	call   18cf <printf>
    1197:	83 c4 10             	add    $0x10,%esp
			//checkpoint(request->fd);
			mutex_unlock(mutexreq);
    119a:	a1 50 26 00 00       	mov    0x2650,%eax
    119f:	83 ec 0c             	sub    $0xc,%esp
    11a2:	50                   	push   %eax
    11a3:	e8 38 06 00 00       	call   17e0 <mutex_unlock>
    11a8:	83 c4 10             	add    $0x10,%esp
			mutex_lock(mutexresp);//double check this stuff
    11ab:	a1 a0 24 00 00       	mov    0x24a0,%eax
    11b0:	83 ec 0c             	sub    $0xc,%esp
    11b3:	50                   	push   %eax
    11b4:	e8 1f 06 00 00       	call   17d8 <mutex_lock>
    11b9:	83 c4 10             	add    $0x10,%esp
			response = (struct fss_response *) shm_get("response",8);
    11bc:	83 ec 08             	sub    $0x8,%esp
    11bf:	6a 08                	push   $0x8
    11c1:	68 e9 1c 00 00       	push   $0x1ce9
    11c6:	e8 e5 05 00 00       	call   17b0 <shm_get>
    11cb:	83 c4 10             	add    $0x10,%esp
    11ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
			response->res=open(request->data,request->fd);
    11d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11d4:	8b 40 0c             	mov    0xc(%eax),%eax
    11d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11da:	83 c2 10             	add    $0x10,%edx
    11dd:	83 ec 08             	sub    $0x8,%esp
    11e0:	50                   	push   %eax
    11e1:	52                   	push   %edx
    11e2:	e8 69 05 00 00       	call   1750 <open>
    11e7:	83 c4 10             	add    $0x10,%esp
    11ea:	89 c2                	mov    %eax,%edx
    11ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
    11ef:	89 10                	mov    %edx,(%eax)
			char tempath [1024];
			strcpy(tempath,request->data);
    11f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11f4:	83 c0 10             	add    $0x10,%eax
    11f7:	83 ec 08             	sub    $0x8,%esp
    11fa:	50                   	push   %eax
    11fb:	8d 85 cc fb ff ff    	lea    -0x434(%ebp),%eax
    1201:	50                   	push   %eax
    1202:	e8 d8 02 00 00       	call   14df <strcpy>
    1207:	83 c4 10             	add    $0x10,%esp
			stored_path[response->res]=&tempath[0];
    120a:	8b 45 ec             	mov    -0x14(%ebp),%eax
    120d:	8b 00                	mov    (%eax),%eax
    120f:	8d 95 cc fb ff ff    	lea    -0x434(%ebp),%edx
    1215:	89 14 85 c0 24 00 00 	mov    %edx,0x24c0(,%eax,4)
			printf(1,"testing store to array= %s\n",stored_path[response->res]);
    121c:	8b 45 ec             	mov    -0x14(%ebp),%eax
    121f:	8b 00                	mov    (%eax),%eax
    1221:	8b 04 85 c0 24 00 00 	mov    0x24c0(,%eax,4),%eax
    1228:	83 ec 04             	sub    $0x4,%esp
    122b:	50                   	push   %eax
    122c:	68 10 20 00 00       	push   $0x2010
    1231:	6a 01                	push   $0x1
    1233:	e8 97 06 00 00       	call   18cf <printf>
    1238:	83 c4 10             	add    $0x10,%esp
			printf(1,"fd =%d\n",response->res);
    123b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    123e:	8b 00                	mov    (%eax),%eax
    1240:	83 ec 04             	sub    $0x4,%esp
    1243:	50                   	push   %eax
    1244:	68 2c 20 00 00       	push   $0x202c
    1249:	6a 01                	push   $0x1
    124b:	e8 7f 06 00 00       	call   18cf <printf>
    1250:	83 c4 10             	add    $0x10,%esp
			printf(1,"sending response\n");
    1253:	83 ec 08             	sub    $0x8,%esp
    1256:	68 c7 1f 00 00       	push   $0x1fc7
    125b:	6a 01                	push   $0x1
    125d:	e8 6d 06 00 00       	call   18cf <printf>
    1262:	83 c4 10             	add    $0x10,%esp
			cv_signal(mutexresp);//signals response is written
    1265:	a1 a0 24 00 00       	mov    0x24a0,%eax
    126a:	83 ec 0c             	sub    $0xc,%esp
    126d:	50                   	push   %eax
    126e:	e8 7d 05 00 00       	call   17f0 <cv_signal>
    1273:	83 c4 10             	add    $0x10,%esp
    1276:	e9 cc fb ff ff       	jmp    e47 <main+0x2e>
		}
		else if (strcmp(op,"mkdir")==0){
    127b:	83 ec 08             	sub    $0x8,%esp
    127e:	68 33 1d 00 00       	push   $0x1d33
    1283:	ff 75 f0             	pushl  -0x10(%ebp)
    1286:	e8 84 02 00 00       	call   150f <strcmp>
    128b:	83 c4 10             	add    $0x10,%esp
    128e:	85 c0                	test   %eax,%eax
    1290:	75 66                	jne    12f8 <main+0x4df>
			//checkpoint(request->fd);
			mutex_unlock(mutexreq);
    1292:	a1 50 26 00 00       	mov    0x2650,%eax
    1297:	83 ec 0c             	sub    $0xc,%esp
    129a:	50                   	push   %eax
    129b:	e8 40 05 00 00       	call   17e0 <mutex_unlock>
    12a0:	83 c4 10             	add    $0x10,%esp
			mutex_lock(mutexresp);//double check this stuff
    12a3:	a1 a0 24 00 00       	mov    0x24a0,%eax
    12a8:	83 ec 0c             	sub    $0xc,%esp
    12ab:	50                   	push   %eax
    12ac:	e8 27 05 00 00       	call   17d8 <mutex_lock>
    12b1:	83 c4 10             	add    $0x10,%esp
			response = (struct fss_response *) shm_get("response",8);
    12b4:	83 ec 08             	sub    $0x8,%esp
    12b7:	6a 08                	push   $0x8
    12b9:	68 e9 1c 00 00       	push   $0x1ce9
    12be:	e8 ed 04 00 00       	call   17b0 <shm_get>
    12c3:	83 c4 10             	add    $0x10,%esp
    12c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
			response->res=mkdir(request->data);
    12c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12cc:	83 c0 10             	add    $0x10,%eax
    12cf:	83 ec 0c             	sub    $0xc,%esp
    12d2:	50                   	push   %eax
    12d3:	e8 a0 04 00 00       	call   1778 <mkdir>
    12d8:	83 c4 10             	add    $0x10,%esp
    12db:	89 c2                	mov    %eax,%edx
    12dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
    12e0:	89 10                	mov    %edx,(%eax)
			
			cv_signal(mutexresp);//signals response is written
    12e2:	a1 a0 24 00 00       	mov    0x24a0,%eax
    12e7:	83 ec 0c             	sub    $0xc,%esp
    12ea:	50                   	push   %eax
    12eb:	e8 00 05 00 00       	call   17f0 <cv_signal>
    12f0:	83 c4 10             	add    $0x10,%esp
    12f3:	e9 4f fb ff ff       	jmp    e47 <main+0x2e>
		}
		else if (strcmp(op,"close")==0){
    12f8:	83 ec 08             	sub    $0x8,%esp
    12fb:	68 2d 1d 00 00       	push   $0x1d2d
    1300:	ff 75 f0             	pushl  -0x10(%ebp)
    1303:	e8 07 02 00 00       	call   150f <strcmp>
    1308:	83 c4 10             	add    $0x10,%esp
    130b:	85 c0                	test   %eax,%eax
    130d:	75 77                	jne    1386 <main+0x56d>
			//checkpoint(request->fd);
			mutex_unlock(mutexreq);
    130f:	a1 50 26 00 00       	mov    0x2650,%eax
    1314:	83 ec 0c             	sub    $0xc,%esp
    1317:	50                   	push   %eax
    1318:	e8 c3 04 00 00       	call   17e0 <mutex_unlock>
    131d:	83 c4 10             	add    $0x10,%esp
			mutex_lock(mutexresp);//double check this stuff
    1320:	a1 a0 24 00 00       	mov    0x24a0,%eax
    1325:	83 ec 0c             	sub    $0xc,%esp
    1328:	50                   	push   %eax
    1329:	e8 aa 04 00 00       	call   17d8 <mutex_lock>
    132e:	83 c4 10             	add    $0x10,%esp
			response = (struct fss_response *) shm_get("response",8);
    1331:	83 ec 08             	sub    $0x8,%esp
    1334:	6a 08                	push   $0x8
    1336:	68 e9 1c 00 00       	push   $0x1ce9
    133b:	e8 70 04 00 00       	call   17b0 <shm_get>
    1340:	83 c4 10             	add    $0x10,%esp
    1343:	89 45 ec             	mov    %eax,-0x14(%ebp)
			stored_path[request->fd]=NULL;//unmarks path
    1346:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1349:	8b 40 0c             	mov    0xc(%eax),%eax
    134c:	c7 04 85 c0 24 00 00 	movl   $0x0,0x24c0(,%eax,4)
    1353:	00 00 00 00 
			response->res=close(request->fd);
    1357:	8b 45 f4             	mov    -0xc(%ebp),%eax
    135a:	8b 40 0c             	mov    0xc(%eax),%eax
    135d:	83 ec 0c             	sub    $0xc,%esp
    1360:	50                   	push   %eax
    1361:	e8 d2 03 00 00       	call   1738 <close>
    1366:	83 c4 10             	add    $0x10,%esp
    1369:	89 c2                	mov    %eax,%edx
    136b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    136e:	89 10                	mov    %edx,(%eax)
			
			cv_signal(mutexresp);//signals response is written
    1370:	a1 a0 24 00 00       	mov    0x24a0,%eax
    1375:	83 ec 0c             	sub    $0xc,%esp
    1378:	50                   	push   %eax
    1379:	e8 72 04 00 00       	call   17f0 <cv_signal>
    137e:	83 c4 10             	add    $0x10,%esp
    1381:	e9 c1 fa ff ff       	jmp    e47 <main+0x2e>
		}
		else if (strcmp(op,"unlink")==0){
    1386:	83 ec 08             	sub    $0x8,%esp
    1389:	68 4d 1d 00 00       	push   $0x1d4d
    138e:	ff 75 f0             	pushl  -0x10(%ebp)
    1391:	e8 79 01 00 00       	call   150f <strcmp>
    1396:	83 c4 10             	add    $0x10,%esp
    1399:	85 c0                	test   %eax,%eax
    139b:	0f 85 d5 00 00 00    	jne    1476 <main+0x65d>
			//checkpoint(request->fd);
			mutex_unlock(mutexreq);
    13a1:	a1 50 26 00 00       	mov    0x2650,%eax
    13a6:	83 ec 0c             	sub    $0xc,%esp
    13a9:	50                   	push   %eax
    13aa:	e8 31 04 00 00       	call   17e0 <mutex_unlock>
    13af:	83 c4 10             	add    $0x10,%esp
			mutex_lock(mutexresp);//double check this stuff
    13b2:	a1 a0 24 00 00       	mov    0x24a0,%eax
    13b7:	83 ec 0c             	sub    $0xc,%esp
    13ba:	50                   	push   %eax
    13bb:	e8 18 04 00 00       	call   17d8 <mutex_lock>
    13c0:	83 c4 10             	add    $0x10,%esp
			response = (struct fss_response *) shm_get("response",8);
    13c3:	83 ec 08             	sub    $0x8,%esp
    13c6:	6a 08                	push   $0x8
    13c8:	68 e9 1c 00 00       	push   $0x1ce9
    13cd:	e8 de 03 00 00       	call   17b0 <shm_get>
    13d2:	83 c4 10             	add    $0x10,%esp
    13d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
			char check[16];
			char path[1024];

			memset(check, 0, sizeof(check));
    13d8:	83 ec 04             	sub    $0x4,%esp
    13db:	6a 10                	push   $0x10
    13dd:	6a 00                	push   $0x0
    13df:	8d 45 cc             	lea    -0x34(%ebp),%eax
    13e2:	50                   	push   %eax
    13e3:	e8 8d 01 00 00       	call   1575 <memset>
    13e8:	83 c4 10             	add    $0x10,%esp
			strcpy(check, "/checkpoint/\0");
    13eb:	83 ec 08             	sub    $0x8,%esp
    13ee:	68 b9 1f 00 00       	push   $0x1fb9
    13f3:	8d 45 cc             	lea    -0x34(%ebp),%eax
    13f6:	50                   	push   %eax
    13f7:	e8 e3 00 00 00       	call   14df <strcpy>
    13fc:	83 c4 10             	add    $0x10,%esp
			
			parse(check, request->data, path);
    13ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1402:	8d 50 10             	lea    0x10(%eax),%edx
    1405:	83 ec 04             	sub    $0x4,%esp
    1408:	8d 85 cc fb ff ff    	lea    -0x434(%ebp),%eax
    140e:	50                   	push   %eax
    140f:	52                   	push   %edx
    1410:	8d 45 cc             	lea    -0x34(%ebp),%eax
    1413:	50                   	push   %eax
    1414:	e8 43 f2 ff ff       	call   65c <parse>
    1419:	83 c4 10             	add    $0x10,%esp
			//returns the path to be used in recursive mkdir

    			printf(2, "help me dear lord filename:%s\n", path);
    141c:	83 ec 04             	sub    $0x4,%esp
    141f:	8d 85 cc fb ff ff    	lea    -0x434(%ebp),%eax
    1425:	50                   	push   %eax
    1426:	68 34 20 00 00       	push   $0x2034
    142b:	6a 02                	push   $0x2
    142d:	e8 9d 04 00 00       	call   18cf <printf>
    1432:	83 c4 10             	add    $0x10,%esp

    			r_mkdir(path);//creates checkpoint if just unlink directory
    1435:	83 ec 0c             	sub    $0xc,%esp
    1438:	8d 85 cc fb ff ff    	lea    -0x434(%ebp),%eax
    143e:	50                   	push   %eax
    143f:	e8 be f1 ff ff       	call   602 <r_mkdir>
    1444:	83 c4 10             	add    $0x10,%esp
			
			response->res=unlink(request->data);
    1447:	8b 45 f4             	mov    -0xc(%ebp),%eax
    144a:	83 c0 10             	add    $0x10,%eax
    144d:	83 ec 0c             	sub    $0xc,%esp
    1450:	50                   	push   %eax
    1451:	e8 0a 03 00 00       	call   1760 <unlink>
    1456:	83 c4 10             	add    $0x10,%esp
    1459:	89 c2                	mov    %eax,%edx
    145b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    145e:	89 10                	mov    %edx,(%eax)
			cv_signal(mutexresp);//signals response is written
    1460:	a1 a0 24 00 00       	mov    0x24a0,%eax
    1465:	83 ec 0c             	sub    $0xc,%esp
    1468:	50                   	push   %eax
    1469:	e8 82 03 00 00       	call   17f0 <cv_signal>
    146e:	83 c4 10             	add    $0x10,%esp
    1471:	e9 d1 f9 ff ff       	jmp    e47 <main+0x2e>
		}
		else if (strcmp(op,"restore")==0){
    1476:	83 ec 08             	sub    $0x8,%esp
    1479:	68 54 1d 00 00       	push   $0x1d54
    147e:	ff 75 f0             	pushl  -0x10(%ebp)
    1481:	e8 89 00 00 00       	call   150f <strcmp>
    1486:	83 c4 10             	add    $0x10,%esp
    1489:	85 c0                	test   %eax,%eax
    148b:	75 15                	jne    14a2 <main+0x689>
			restore("/checkpoint/");		
    148d:	83 ec 0c             	sub    $0xc,%esp
    1490:	68 53 20 00 00       	push   $0x2053
    1495:	e8 dc f4 ff ff       	call   976 <restore>
    149a:	83 c4 10             	add    $0x10,%esp
    149d:	e9 a5 f9 ff ff       	jmp    e47 <main+0x2e>
		}
		else{
		printf(1,"didn't catch that\n");
    14a2:	83 ec 08             	sub    $0x8,%esp
    14a5:	68 60 20 00 00       	push   $0x2060
    14aa:	6a 01                	push   $0x1
    14ac:	e8 1e 04 00 00       	call   18cf <printf>
    14b1:	83 c4 10             	add    $0x10,%esp
			//error
			exit();
    14b4:	e8 57 02 00 00       	call   1710 <exit>

000014b9 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    14b9:	55                   	push   %ebp
    14ba:	89 e5                	mov    %esp,%ebp
    14bc:	57                   	push   %edi
    14bd:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    14be:	8b 4d 08             	mov    0x8(%ebp),%ecx
    14c1:	8b 55 10             	mov    0x10(%ebp),%edx
    14c4:	8b 45 0c             	mov    0xc(%ebp),%eax
    14c7:	89 cb                	mov    %ecx,%ebx
    14c9:	89 df                	mov    %ebx,%edi
    14cb:	89 d1                	mov    %edx,%ecx
    14cd:	fc                   	cld    
    14ce:	f3 aa                	rep stos %al,%es:(%edi)
    14d0:	89 ca                	mov    %ecx,%edx
    14d2:	89 fb                	mov    %edi,%ebx
    14d4:	89 5d 08             	mov    %ebx,0x8(%ebp)
    14d7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    14da:	90                   	nop
    14db:	5b                   	pop    %ebx
    14dc:	5f                   	pop    %edi
    14dd:	5d                   	pop    %ebp
    14de:	c3                   	ret    

000014df <strcpy>:
#include "fcntl.h"
#include "user.h"
#include "x86.h"

char *strcpy(char *s, char *t)
{
    14df:	55                   	push   %ebp
    14e0:	89 e5                	mov    %esp,%ebp
    14e2:	83 ec 10             	sub    $0x10,%esp
	char *os;

	os = s;
    14e5:	8b 45 08             	mov    0x8(%ebp),%eax
    14e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*s++ = *t++) != 0) ;
    14eb:	90                   	nop
    14ec:	8b 45 08             	mov    0x8(%ebp),%eax
    14ef:	8d 50 01             	lea    0x1(%eax),%edx
    14f2:	89 55 08             	mov    %edx,0x8(%ebp)
    14f5:	8b 55 0c             	mov    0xc(%ebp),%edx
    14f8:	8d 4a 01             	lea    0x1(%edx),%ecx
    14fb:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    14fe:	0f b6 12             	movzbl (%edx),%edx
    1501:	88 10                	mov    %dl,(%eax)
    1503:	0f b6 00             	movzbl (%eax),%eax
    1506:	84 c0                	test   %al,%al
    1508:	75 e2                	jne    14ec <strcpy+0xd>
	return os;
    150a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    150d:	c9                   	leave  
    150e:	c3                   	ret    

0000150f <strcmp>:

int strcmp(const char *p, const char *q)
{
    150f:	55                   	push   %ebp
    1510:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
    1512:	eb 08                	jmp    151c <strcmp+0xd>
		p++, q++;
    1514:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1518:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	return os;
}

int strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
    151c:	8b 45 08             	mov    0x8(%ebp),%eax
    151f:	0f b6 00             	movzbl (%eax),%eax
    1522:	84 c0                	test   %al,%al
    1524:	74 10                	je     1536 <strcmp+0x27>
    1526:	8b 45 08             	mov    0x8(%ebp),%eax
    1529:	0f b6 10             	movzbl (%eax),%edx
    152c:	8b 45 0c             	mov    0xc(%ebp),%eax
    152f:	0f b6 00             	movzbl (%eax),%eax
    1532:	38 c2                	cmp    %al,%dl
    1534:	74 de                	je     1514 <strcmp+0x5>
		p++, q++;
	return (uchar) * p - (uchar) * q;
    1536:	8b 45 08             	mov    0x8(%ebp),%eax
    1539:	0f b6 00             	movzbl (%eax),%eax
    153c:	0f b6 d0             	movzbl %al,%edx
    153f:	8b 45 0c             	mov    0xc(%ebp),%eax
    1542:	0f b6 00             	movzbl (%eax),%eax
    1545:	0f b6 c0             	movzbl %al,%eax
    1548:	29 c2                	sub    %eax,%edx
    154a:	89 d0                	mov    %edx,%eax
}
    154c:	5d                   	pop    %ebp
    154d:	c3                   	ret    

0000154e <strlen>:

uint strlen(char *s)
{
    154e:	55                   	push   %ebp
    154f:	89 e5                	mov    %esp,%ebp
    1551:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; s[n]; n++) ;
    1554:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    155b:	eb 04                	jmp    1561 <strlen+0x13>
    155d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    1561:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1564:	8b 45 08             	mov    0x8(%ebp),%eax
    1567:	01 d0                	add    %edx,%eax
    1569:	0f b6 00             	movzbl (%eax),%eax
    156c:	84 c0                	test   %al,%al
    156e:	75 ed                	jne    155d <strlen+0xf>
	return n;
    1570:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1573:	c9                   	leave  
    1574:	c3                   	ret    

00001575 <memset>:

void *memset(void *dst, int c, uint n)
{
    1575:	55                   	push   %ebp
    1576:	89 e5                	mov    %esp,%ebp
	stosb(dst, c, n);
    1578:	8b 45 10             	mov    0x10(%ebp),%eax
    157b:	50                   	push   %eax
    157c:	ff 75 0c             	pushl  0xc(%ebp)
    157f:	ff 75 08             	pushl  0x8(%ebp)
    1582:	e8 32 ff ff ff       	call   14b9 <stosb>
    1587:	83 c4 0c             	add    $0xc,%esp
	return dst;
    158a:	8b 45 08             	mov    0x8(%ebp),%eax
}
    158d:	c9                   	leave  
    158e:	c3                   	ret    

0000158f <strchr>:

char *strchr(const char *s, char c)
{
    158f:	55                   	push   %ebp
    1590:	89 e5                	mov    %esp,%ebp
    1592:	83 ec 04             	sub    $0x4,%esp
    1595:	8b 45 0c             	mov    0xc(%ebp),%eax
    1598:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
    159b:	eb 14                	jmp    15b1 <strchr+0x22>
		if (*s == c)
    159d:	8b 45 08             	mov    0x8(%ebp),%eax
    15a0:	0f b6 00             	movzbl (%eax),%eax
    15a3:	3a 45 fc             	cmp    -0x4(%ebp),%al
    15a6:	75 05                	jne    15ad <strchr+0x1e>
			return (char *)s;
    15a8:	8b 45 08             	mov    0x8(%ebp),%eax
    15ab:	eb 13                	jmp    15c0 <strchr+0x31>
	return dst;
}

char *strchr(const char *s, char c)
{
	for (; *s; s++)
    15ad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    15b1:	8b 45 08             	mov    0x8(%ebp),%eax
    15b4:	0f b6 00             	movzbl (%eax),%eax
    15b7:	84 c0                	test   %al,%al
    15b9:	75 e2                	jne    159d <strchr+0xe>
		if (*s == c)
			return (char *)s;
	return 0;
    15bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
    15c0:	c9                   	leave  
    15c1:	c3                   	ret    

000015c2 <gets>:

char *gets(char *buf, int max)
{
    15c2:	55                   	push   %ebp
    15c3:	89 e5                	mov    %esp,%ebp
    15c5:	83 ec 18             	sub    $0x18,%esp
	int i, cc;
	char c;

	for (i = 0; i + 1 < max;) {
    15c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    15cf:	eb 42                	jmp    1613 <gets+0x51>
		cc = read(0, &c, 1);
    15d1:	83 ec 04             	sub    $0x4,%esp
    15d4:	6a 01                	push   $0x1
    15d6:	8d 45 ef             	lea    -0x11(%ebp),%eax
    15d9:	50                   	push   %eax
    15da:	6a 00                	push   $0x0
    15dc:	e8 47 01 00 00       	call   1728 <read>
    15e1:	83 c4 10             	add    $0x10,%esp
    15e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (cc < 1)
    15e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    15eb:	7e 33                	jle    1620 <gets+0x5e>
			break;
		buf[i++] = c;
    15ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15f0:	8d 50 01             	lea    0x1(%eax),%edx
    15f3:	89 55 f4             	mov    %edx,-0xc(%ebp)
    15f6:	89 c2                	mov    %eax,%edx
    15f8:	8b 45 08             	mov    0x8(%ebp),%eax
    15fb:	01 c2                	add    %eax,%edx
    15fd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1601:	88 02                	mov    %al,(%edx)
		if (c == '\n' || c == '\r')
    1603:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1607:	3c 0a                	cmp    $0xa,%al
    1609:	74 16                	je     1621 <gets+0x5f>
    160b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    160f:	3c 0d                	cmp    $0xd,%al
    1611:	74 0e                	je     1621 <gets+0x5f>
char *gets(char *buf, int max)
{
	int i, cc;
	char c;

	for (i = 0; i + 1 < max;) {
    1613:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1616:	83 c0 01             	add    $0x1,%eax
    1619:	3b 45 0c             	cmp    0xc(%ebp),%eax
    161c:	7c b3                	jl     15d1 <gets+0xf>
    161e:	eb 01                	jmp    1621 <gets+0x5f>
		cc = read(0, &c, 1);
		if (cc < 1)
			break;
    1620:	90                   	nop
		buf[i++] = c;
		if (c == '\n' || c == '\r')
			break;
	}
	buf[i] = '\0';
    1621:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1624:	8b 45 08             	mov    0x8(%ebp),%eax
    1627:	01 d0                	add    %edx,%eax
    1629:	c6 00 00             	movb   $0x0,(%eax)
	return buf;
    162c:	8b 45 08             	mov    0x8(%ebp),%eax
}
    162f:	c9                   	leave  
    1630:	c3                   	ret    

00001631 <stat>:

int stat(char *n, struct stat *st)
{
    1631:	55                   	push   %ebp
    1632:	89 e5                	mov    %esp,%ebp
    1634:	83 ec 18             	sub    $0x18,%esp
	int fd;
	int r;

	fd = open(n, O_RDONLY);
    1637:	83 ec 08             	sub    $0x8,%esp
    163a:	6a 00                	push   $0x0
    163c:	ff 75 08             	pushl  0x8(%ebp)
    163f:	e8 0c 01 00 00       	call   1750 <open>
    1644:	83 c4 10             	add    $0x10,%esp
    1647:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (fd < 0)
    164a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    164e:	79 07                	jns    1657 <stat+0x26>
		return -1;
    1650:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1655:	eb 25                	jmp    167c <stat+0x4b>
	r = fstat(fd, st);
    1657:	83 ec 08             	sub    $0x8,%esp
    165a:	ff 75 0c             	pushl  0xc(%ebp)
    165d:	ff 75 f4             	pushl  -0xc(%ebp)
    1660:	e8 03 01 00 00       	call   1768 <fstat>
    1665:	83 c4 10             	add    $0x10,%esp
    1668:	89 45 f0             	mov    %eax,-0x10(%ebp)
	close(fd);
    166b:	83 ec 0c             	sub    $0xc,%esp
    166e:	ff 75 f4             	pushl  -0xc(%ebp)
    1671:	e8 c2 00 00 00       	call   1738 <close>
    1676:	83 c4 10             	add    $0x10,%esp
	return r;
    1679:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    167c:	c9                   	leave  
    167d:	c3                   	ret    

0000167e <atoi>:

int atoi(const char *s)
{
    167e:	55                   	push   %ebp
    167f:	89 e5                	mov    %esp,%ebp
    1681:	83 ec 10             	sub    $0x10,%esp
	int n;

	n = 0;
    1684:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	while ('0' <= *s && *s <= '9')
    168b:	eb 25                	jmp    16b2 <atoi+0x34>
		n = n * 10 + *s++ - '0';
    168d:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1690:	89 d0                	mov    %edx,%eax
    1692:	c1 e0 02             	shl    $0x2,%eax
    1695:	01 d0                	add    %edx,%eax
    1697:	01 c0                	add    %eax,%eax
    1699:	89 c1                	mov    %eax,%ecx
    169b:	8b 45 08             	mov    0x8(%ebp),%eax
    169e:	8d 50 01             	lea    0x1(%eax),%edx
    16a1:	89 55 08             	mov    %edx,0x8(%ebp)
    16a4:	0f b6 00             	movzbl (%eax),%eax
    16a7:	0f be c0             	movsbl %al,%eax
    16aa:	01 c8                	add    %ecx,%eax
    16ac:	83 e8 30             	sub    $0x30,%eax
    16af:	89 45 fc             	mov    %eax,-0x4(%ebp)
int atoi(const char *s)
{
	int n;

	n = 0;
	while ('0' <= *s && *s <= '9')
    16b2:	8b 45 08             	mov    0x8(%ebp),%eax
    16b5:	0f b6 00             	movzbl (%eax),%eax
    16b8:	3c 2f                	cmp    $0x2f,%al
    16ba:	7e 0a                	jle    16c6 <atoi+0x48>
    16bc:	8b 45 08             	mov    0x8(%ebp),%eax
    16bf:	0f b6 00             	movzbl (%eax),%eax
    16c2:	3c 39                	cmp    $0x39,%al
    16c4:	7e c7                	jle    168d <atoi+0xf>
		n = n * 10 + *s++ - '0';
	return n;
    16c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    16c9:	c9                   	leave  
    16ca:	c3                   	ret    

000016cb <memmove>:

void *memmove(void *vdst, void *vsrc, int n)
{
    16cb:	55                   	push   %ebp
    16cc:	89 e5                	mov    %esp,%ebp
    16ce:	83 ec 10             	sub    $0x10,%esp
	char *dst, *src;

	dst = vdst;
    16d1:	8b 45 08             	mov    0x8(%ebp),%eax
    16d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	src = vsrc;
    16d7:	8b 45 0c             	mov    0xc(%ebp),%eax
    16da:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
    16dd:	eb 17                	jmp    16f6 <memmove+0x2b>
		*dst++ = *src++;
    16df:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16e2:	8d 50 01             	lea    0x1(%eax),%edx
    16e5:	89 55 fc             	mov    %edx,-0x4(%ebp)
    16e8:	8b 55 f8             	mov    -0x8(%ebp),%edx
    16eb:	8d 4a 01             	lea    0x1(%edx),%ecx
    16ee:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    16f1:	0f b6 12             	movzbl (%edx),%edx
    16f4:	88 10                	mov    %dl,(%eax)
{
	char *dst, *src;

	dst = vdst;
	src = vsrc;
	while (n-- > 0)
    16f6:	8b 45 10             	mov    0x10(%ebp),%eax
    16f9:	8d 50 ff             	lea    -0x1(%eax),%edx
    16fc:	89 55 10             	mov    %edx,0x10(%ebp)
    16ff:	85 c0                	test   %eax,%eax
    1701:	7f dc                	jg     16df <memmove+0x14>
		*dst++ = *src++;
	return vdst;
    1703:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1706:	c9                   	leave  
    1707:	c3                   	ret    

00001708 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    1708:	b8 01 00 00 00       	mov    $0x1,%eax
    170d:	cd 40                	int    $0x40
    170f:	c3                   	ret    

00001710 <exit>:
SYSCALL(exit)
    1710:	b8 02 00 00 00       	mov    $0x2,%eax
    1715:	cd 40                	int    $0x40
    1717:	c3                   	ret    

00001718 <wait>:
SYSCALL(wait)
    1718:	b8 03 00 00 00       	mov    $0x3,%eax
    171d:	cd 40                	int    $0x40
    171f:	c3                   	ret    

00001720 <pipe>:
SYSCALL(pipe)
    1720:	b8 04 00 00 00       	mov    $0x4,%eax
    1725:	cd 40                	int    $0x40
    1727:	c3                   	ret    

00001728 <read>:
SYSCALL(read)
    1728:	b8 05 00 00 00       	mov    $0x5,%eax
    172d:	cd 40                	int    $0x40
    172f:	c3                   	ret    

00001730 <write>:
SYSCALL(write)
    1730:	b8 10 00 00 00       	mov    $0x10,%eax
    1735:	cd 40                	int    $0x40
    1737:	c3                   	ret    

00001738 <close>:
SYSCALL(close)
    1738:	b8 15 00 00 00       	mov    $0x15,%eax
    173d:	cd 40                	int    $0x40
    173f:	c3                   	ret    

00001740 <kill>:
SYSCALL(kill)
    1740:	b8 06 00 00 00       	mov    $0x6,%eax
    1745:	cd 40                	int    $0x40
    1747:	c3                   	ret    

00001748 <exec>:
SYSCALL(exec)
    1748:	b8 07 00 00 00       	mov    $0x7,%eax
    174d:	cd 40                	int    $0x40
    174f:	c3                   	ret    

00001750 <open>:
SYSCALL(open)
    1750:	b8 0f 00 00 00       	mov    $0xf,%eax
    1755:	cd 40                	int    $0x40
    1757:	c3                   	ret    

00001758 <mknod>:
SYSCALL(mknod)
    1758:	b8 11 00 00 00       	mov    $0x11,%eax
    175d:	cd 40                	int    $0x40
    175f:	c3                   	ret    

00001760 <unlink>:
SYSCALL(unlink)
    1760:	b8 12 00 00 00       	mov    $0x12,%eax
    1765:	cd 40                	int    $0x40
    1767:	c3                   	ret    

00001768 <fstat>:
SYSCALL(fstat)
    1768:	b8 08 00 00 00       	mov    $0x8,%eax
    176d:	cd 40                	int    $0x40
    176f:	c3                   	ret    

00001770 <link>:
SYSCALL(link)
    1770:	b8 13 00 00 00       	mov    $0x13,%eax
    1775:	cd 40                	int    $0x40
    1777:	c3                   	ret    

00001778 <mkdir>:
SYSCALL(mkdir)
    1778:	b8 14 00 00 00       	mov    $0x14,%eax
    177d:	cd 40                	int    $0x40
    177f:	c3                   	ret    

00001780 <chdir>:
SYSCALL(chdir)
    1780:	b8 09 00 00 00       	mov    $0x9,%eax
    1785:	cd 40                	int    $0x40
    1787:	c3                   	ret    

00001788 <dup>:
SYSCALL(dup)
    1788:	b8 0a 00 00 00       	mov    $0xa,%eax
    178d:	cd 40                	int    $0x40
    178f:	c3                   	ret    

00001790 <getpid>:
SYSCALL(getpid)
    1790:	b8 0b 00 00 00       	mov    $0xb,%eax
    1795:	cd 40                	int    $0x40
    1797:	c3                   	ret    

00001798 <sbrk>:
SYSCALL(sbrk)
    1798:	b8 0c 00 00 00       	mov    $0xc,%eax
    179d:	cd 40                	int    $0x40
    179f:	c3                   	ret    

000017a0 <sleep>:
SYSCALL(sleep)
    17a0:	b8 0d 00 00 00       	mov    $0xd,%eax
    17a5:	cd 40                	int    $0x40
    17a7:	c3                   	ret    

000017a8 <uptime>:
SYSCALL(uptime)
    17a8:	b8 0e 00 00 00       	mov    $0xe,%eax
    17ad:	cd 40                	int    $0x40
    17af:	c3                   	ret    

000017b0 <shm_get>:
SYSCALL(shm_get) //mod2
    17b0:	b8 1c 00 00 00       	mov    $0x1c,%eax
    17b5:	cd 40                	int    $0x40
    17b7:	c3                   	ret    

000017b8 <shm_rem>:
SYSCALL(shm_rem) //mod2
    17b8:	b8 1d 00 00 00       	mov    $0x1d,%eax
    17bd:	cd 40                	int    $0x40
    17bf:	c3                   	ret    

000017c0 <setHighPrio>:
SYSCALL(setHighPrio) //scheduler
    17c0:	b8 1e 00 00 00       	mov    $0x1e,%eax
    17c5:	cd 40                	int    $0x40
    17c7:	c3                   	ret    

000017c8 <mutex_create>:
SYSCALL(mutex_create)//mod3
    17c8:	b8 16 00 00 00       	mov    $0x16,%eax
    17cd:	cd 40                	int    $0x40
    17cf:	c3                   	ret    

000017d0 <mutex_delete>:
SYSCALL(mutex_delete)
    17d0:	b8 17 00 00 00       	mov    $0x17,%eax
    17d5:	cd 40                	int    $0x40
    17d7:	c3                   	ret    

000017d8 <mutex_lock>:
SYSCALL(mutex_lock)
    17d8:	b8 18 00 00 00       	mov    $0x18,%eax
    17dd:	cd 40                	int    $0x40
    17df:	c3                   	ret    

000017e0 <mutex_unlock>:
SYSCALL(mutex_unlock)
    17e0:	b8 19 00 00 00       	mov    $0x19,%eax
    17e5:	cd 40                	int    $0x40
    17e7:	c3                   	ret    

000017e8 <cv_wait>:
SYSCALL(cv_wait)
    17e8:	b8 1a 00 00 00       	mov    $0x1a,%eax
    17ed:	cd 40                	int    $0x40
    17ef:	c3                   	ret    

000017f0 <cv_signal>:
SYSCALL(cv_signal)
    17f0:	b8 1b 00 00 00       	mov    $0x1b,%eax
    17f5:	cd 40                	int    $0x40
    17f7:	c3                   	ret    

000017f8 <putc>:
#include "types.h"
#include "stat.h"
#include "user.h"

static void putc(int fd, char c)
{
    17f8:	55                   	push   %ebp
    17f9:	89 e5                	mov    %esp,%ebp
    17fb:	83 ec 18             	sub    $0x18,%esp
    17fe:	8b 45 0c             	mov    0xc(%ebp),%eax
    1801:	88 45 f4             	mov    %al,-0xc(%ebp)
	write(fd, &c, 1);
    1804:	83 ec 04             	sub    $0x4,%esp
    1807:	6a 01                	push   $0x1
    1809:	8d 45 f4             	lea    -0xc(%ebp),%eax
    180c:	50                   	push   %eax
    180d:	ff 75 08             	pushl  0x8(%ebp)
    1810:	e8 1b ff ff ff       	call   1730 <write>
    1815:	83 c4 10             	add    $0x10,%esp
}
    1818:	90                   	nop
    1819:	c9                   	leave  
    181a:	c3                   	ret    

0000181b <printint>:

static void printint(int fd, int xx, int base, int sgn)
{
    181b:	55                   	push   %ebp
    181c:	89 e5                	mov    %esp,%ebp
    181e:	53                   	push   %ebx
    181f:	83 ec 24             	sub    $0x24,%esp
	static char digits[] = "0123456789ABCDEF";
	char buf[16];
	int i, neg;
	uint x;

	neg = 0;
    1822:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	if (sgn && xx < 0) {
    1829:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    182d:	74 17                	je     1846 <printint+0x2b>
    182f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    1833:	79 11                	jns    1846 <printint+0x2b>
		neg = 1;
    1835:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
		x = -xx;
    183c:	8b 45 0c             	mov    0xc(%ebp),%eax
    183f:	f7 d8                	neg    %eax
    1841:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1844:	eb 06                	jmp    184c <printint+0x31>
	} else {
		x = xx;
    1846:	8b 45 0c             	mov    0xc(%ebp),%eax
    1849:	89 45 ec             	mov    %eax,-0x14(%ebp)
	}

	i = 0;
    184c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	do {
		buf[i++] = digits[x % base];
    1853:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1856:	8d 41 01             	lea    0x1(%ecx),%eax
    1859:	89 45 f4             	mov    %eax,-0xc(%ebp)
    185c:	8b 5d 10             	mov    0x10(%ebp),%ebx
    185f:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1862:	ba 00 00 00 00       	mov    $0x0,%edx
    1867:	f7 f3                	div    %ebx
    1869:	89 d0                	mov    %edx,%eax
    186b:	0f b6 80 64 24 00 00 	movzbl 0x2464(%eax),%eax
    1872:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
	} while ((x /= base) != 0);
    1876:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1879:	8b 45 ec             	mov    -0x14(%ebp),%eax
    187c:	ba 00 00 00 00       	mov    $0x0,%edx
    1881:	f7 f3                	div    %ebx
    1883:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1886:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    188a:	75 c7                	jne    1853 <printint+0x38>
	if (neg)
    188c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1890:	74 2d                	je     18bf <printint+0xa4>
		buf[i++] = '-';
    1892:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1895:	8d 50 01             	lea    0x1(%eax),%edx
    1898:	89 55 f4             	mov    %edx,-0xc(%ebp)
    189b:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

	while (--i >= 0)
    18a0:	eb 1d                	jmp    18bf <printint+0xa4>
		putc(fd, buf[i]);
    18a2:	8d 55 dc             	lea    -0x24(%ebp),%edx
    18a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18a8:	01 d0                	add    %edx,%eax
    18aa:	0f b6 00             	movzbl (%eax),%eax
    18ad:	0f be c0             	movsbl %al,%eax
    18b0:	83 ec 08             	sub    $0x8,%esp
    18b3:	50                   	push   %eax
    18b4:	ff 75 08             	pushl  0x8(%ebp)
    18b7:	e8 3c ff ff ff       	call   17f8 <putc>
    18bc:	83 c4 10             	add    $0x10,%esp
		buf[i++] = digits[x % base];
	} while ((x /= base) != 0);
	if (neg)
		buf[i++] = '-';

	while (--i >= 0)
    18bf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    18c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    18c7:	79 d9                	jns    18a2 <printint+0x87>
		putc(fd, buf[i]);
}
    18c9:	90                   	nop
    18ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    18cd:	c9                   	leave  
    18ce:	c3                   	ret    

000018cf <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void printf(int fd, char *fmt, ...)
{
    18cf:	55                   	push   %ebp
    18d0:	89 e5                	mov    %esp,%ebp
    18d2:	83 ec 28             	sub    $0x28,%esp
	char *s;
	int c, i, state;
	uint *ap;

	state = 0;
    18d5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	ap = (uint *) (void *)&fmt + 1;
    18dc:	8d 45 0c             	lea    0xc(%ebp),%eax
    18df:	83 c0 04             	add    $0x4,%eax
    18e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
	for (i = 0; fmt[i]; i++) {
    18e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    18ec:	e9 59 01 00 00       	jmp    1a4a <printf+0x17b>
		c = fmt[i] & 0xff;
    18f1:	8b 55 0c             	mov    0xc(%ebp),%edx
    18f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    18f7:	01 d0                	add    %edx,%eax
    18f9:	0f b6 00             	movzbl (%eax),%eax
    18fc:	0f be c0             	movsbl %al,%eax
    18ff:	25 ff 00 00 00       	and    $0xff,%eax
    1904:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (state == 0) {
    1907:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    190b:	75 2c                	jne    1939 <printf+0x6a>
			if (c == '%') {
    190d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1911:	75 0c                	jne    191f <printf+0x50>
				state = '%';
    1913:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    191a:	e9 27 01 00 00       	jmp    1a46 <printf+0x177>
			} else {
				putc(fd, c);
    191f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1922:	0f be c0             	movsbl %al,%eax
    1925:	83 ec 08             	sub    $0x8,%esp
    1928:	50                   	push   %eax
    1929:	ff 75 08             	pushl  0x8(%ebp)
    192c:	e8 c7 fe ff ff       	call   17f8 <putc>
    1931:	83 c4 10             	add    $0x10,%esp
    1934:	e9 0d 01 00 00       	jmp    1a46 <printf+0x177>
			}
		} else if (state == '%') {
    1939:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    193d:	0f 85 03 01 00 00    	jne    1a46 <printf+0x177>
			if (c == 'd') {
    1943:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1947:	75 1e                	jne    1967 <printf+0x98>
				printint(fd, *ap, 10, 1);
    1949:	8b 45 e8             	mov    -0x18(%ebp),%eax
    194c:	8b 00                	mov    (%eax),%eax
    194e:	6a 01                	push   $0x1
    1950:	6a 0a                	push   $0xa
    1952:	50                   	push   %eax
    1953:	ff 75 08             	pushl  0x8(%ebp)
    1956:	e8 c0 fe ff ff       	call   181b <printint>
    195b:	83 c4 10             	add    $0x10,%esp
				ap++;
    195e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1962:	e9 d8 00 00 00       	jmp    1a3f <printf+0x170>
			} else if (c == 'x' || c == 'p') {
    1967:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    196b:	74 06                	je     1973 <printf+0xa4>
    196d:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1971:	75 1e                	jne    1991 <printf+0xc2>
				printint(fd, *ap, 16, 0);
    1973:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1976:	8b 00                	mov    (%eax),%eax
    1978:	6a 00                	push   $0x0
    197a:	6a 10                	push   $0x10
    197c:	50                   	push   %eax
    197d:	ff 75 08             	pushl  0x8(%ebp)
    1980:	e8 96 fe ff ff       	call   181b <printint>
    1985:	83 c4 10             	add    $0x10,%esp
				ap++;
    1988:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    198c:	e9 ae 00 00 00       	jmp    1a3f <printf+0x170>
			} else if (c == 's') {
    1991:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1995:	75 43                	jne    19da <printf+0x10b>
				s = (char *)*ap;
    1997:	8b 45 e8             	mov    -0x18(%ebp),%eax
    199a:	8b 00                	mov    (%eax),%eax
    199c:	89 45 f4             	mov    %eax,-0xc(%ebp)
				ap++;
    199f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
				if (s == 0)
    19a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    19a7:	75 25                	jne    19ce <printf+0xff>
					s = "(null)";
    19a9:	c7 45 f4 73 20 00 00 	movl   $0x2073,-0xc(%ebp)
				while (*s != 0) {
    19b0:	eb 1c                	jmp    19ce <printf+0xff>
					putc(fd, *s);
    19b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    19b5:	0f b6 00             	movzbl (%eax),%eax
    19b8:	0f be c0             	movsbl %al,%eax
    19bb:	83 ec 08             	sub    $0x8,%esp
    19be:	50                   	push   %eax
    19bf:	ff 75 08             	pushl  0x8(%ebp)
    19c2:	e8 31 fe ff ff       	call   17f8 <putc>
    19c7:	83 c4 10             	add    $0x10,%esp
					s++;
    19ca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
			} else if (c == 's') {
				s = (char *)*ap;
				ap++;
				if (s == 0)
					s = "(null)";
				while (*s != 0) {
    19ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
    19d1:	0f b6 00             	movzbl (%eax),%eax
    19d4:	84 c0                	test   %al,%al
    19d6:	75 da                	jne    19b2 <printf+0xe3>
    19d8:	eb 65                	jmp    1a3f <printf+0x170>
					putc(fd, *s);
					s++;
				}
			} else if (c == 'c') {
    19da:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    19de:	75 1d                	jne    19fd <printf+0x12e>
				putc(fd, *ap);
    19e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
    19e3:	8b 00                	mov    (%eax),%eax
    19e5:	0f be c0             	movsbl %al,%eax
    19e8:	83 ec 08             	sub    $0x8,%esp
    19eb:	50                   	push   %eax
    19ec:	ff 75 08             	pushl  0x8(%ebp)
    19ef:	e8 04 fe ff ff       	call   17f8 <putc>
    19f4:	83 c4 10             	add    $0x10,%esp
				ap++;
    19f7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    19fb:	eb 42                	jmp    1a3f <printf+0x170>
			} else if (c == '%') {
    19fd:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1a01:	75 17                	jne    1a1a <printf+0x14b>
				putc(fd, c);
    1a03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1a06:	0f be c0             	movsbl %al,%eax
    1a09:	83 ec 08             	sub    $0x8,%esp
    1a0c:	50                   	push   %eax
    1a0d:	ff 75 08             	pushl  0x8(%ebp)
    1a10:	e8 e3 fd ff ff       	call   17f8 <putc>
    1a15:	83 c4 10             	add    $0x10,%esp
    1a18:	eb 25                	jmp    1a3f <printf+0x170>
			} else {
				// Unknown % sequence.  Print it to draw attention.
				putc(fd, '%');
    1a1a:	83 ec 08             	sub    $0x8,%esp
    1a1d:	6a 25                	push   $0x25
    1a1f:	ff 75 08             	pushl  0x8(%ebp)
    1a22:	e8 d1 fd ff ff       	call   17f8 <putc>
    1a27:	83 c4 10             	add    $0x10,%esp
				putc(fd, c);
    1a2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1a2d:	0f be c0             	movsbl %al,%eax
    1a30:	83 ec 08             	sub    $0x8,%esp
    1a33:	50                   	push   %eax
    1a34:	ff 75 08             	pushl  0x8(%ebp)
    1a37:	e8 bc fd ff ff       	call   17f8 <putc>
    1a3c:	83 c4 10             	add    $0x10,%esp
			}
			state = 0;
    1a3f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int c, i, state;
	uint *ap;

	state = 0;
	ap = (uint *) (void *)&fmt + 1;
	for (i = 0; fmt[i]; i++) {
    1a46:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1a4a:	8b 55 0c             	mov    0xc(%ebp),%edx
    1a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1a50:	01 d0                	add    %edx,%eax
    1a52:	0f b6 00             	movzbl (%eax),%eax
    1a55:	84 c0                	test   %al,%al
    1a57:	0f 85 94 fe ff ff    	jne    18f1 <printf+0x22>
				putc(fd, c);
			}
			state = 0;
		}
	}
}
    1a5d:	90                   	nop
    1a5e:	c9                   	leave  
    1a5f:	c3                   	ret    

00001a60 <free>:

static Header base;
static Header *freep;

void free(void *ap)
{
    1a60:	55                   	push   %ebp
    1a61:	89 e5                	mov    %esp,%ebp
    1a63:	83 ec 10             	sub    $0x10,%esp
	Header *bp, *p;

	bp = (Header *) ap - 1; //take address of memory -> subtract one size of p to get to header to memeory
    1a66:	8b 45 08             	mov    0x8(%ebp),%eax
    1a69:	83 e8 08             	sub    $0x8,%eax
    1a6c:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr) //comparing pointers to headers...maybe ordering spatially...
    1a6f:	a1 98 24 00 00       	mov    0x2498,%eax
    1a74:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1a77:	eb 24                	jmp    1a9d <free+0x3d>
		if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1a79:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1a7c:	8b 00                	mov    (%eax),%eax
    1a7e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1a81:	77 12                	ja     1a95 <free+0x35>
    1a83:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1a86:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1a89:	77 24                	ja     1aaf <free+0x4f>
    1a8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1a8e:	8b 00                	mov    (%eax),%eax
    1a90:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1a93:	77 1a                	ja     1aaf <free+0x4f>
void free(void *ap)
{
	Header *bp, *p;

	bp = (Header *) ap - 1; //take address of memory -> subtract one size of p to get to header to memeory
	for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr) //comparing pointers to headers...maybe ordering spatially...
    1a95:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1a98:	8b 00                	mov    (%eax),%eax
    1a9a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1a9d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1aa0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1aa3:	76 d4                	jbe    1a79 <free+0x19>
    1aa5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1aa8:	8b 00                	mov    (%eax),%eax
    1aaa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1aad:	76 ca                	jbe    1a79 <free+0x19>
		if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
			break;
	if (bp + bp->s.size == p->s.ptr) { //checks sizes to merge contiguous freed regions
    1aaf:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1ab2:	8b 40 04             	mov    0x4(%eax),%eax
    1ab5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1abc:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1abf:	01 c2                	add    %eax,%edx
    1ac1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1ac4:	8b 00                	mov    (%eax),%eax
    1ac6:	39 c2                	cmp    %eax,%edx
    1ac8:	75 24                	jne    1aee <free+0x8e>
		bp->s.size += p->s.ptr->s.size;
    1aca:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1acd:	8b 50 04             	mov    0x4(%eax),%edx
    1ad0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1ad3:	8b 00                	mov    (%eax),%eax
    1ad5:	8b 40 04             	mov    0x4(%eax),%eax
    1ad8:	01 c2                	add    %eax,%edx
    1ada:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1add:	89 50 04             	mov    %edx,0x4(%eax)
		bp->s.ptr = p->s.ptr->s.ptr;
    1ae0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1ae3:	8b 00                	mov    (%eax),%eax
    1ae5:	8b 10                	mov    (%eax),%edx
    1ae7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1aea:	89 10                	mov    %edx,(%eax)
    1aec:	eb 0a                	jmp    1af8 <free+0x98>
	} else
		bp->s.ptr = p->s.ptr;
    1aee:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1af1:	8b 10                	mov    (%eax),%edx
    1af3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1af6:	89 10                	mov    %edx,(%eax)
	if (p + p->s.size == bp) {
    1af8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1afb:	8b 40 04             	mov    0x4(%eax),%eax
    1afe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1b05:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1b08:	01 d0                	add    %edx,%eax
    1b0a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1b0d:	75 20                	jne    1b2f <free+0xcf>
		p->s.size += bp->s.size;
    1b0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1b12:	8b 50 04             	mov    0x4(%eax),%edx
    1b15:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1b18:	8b 40 04             	mov    0x4(%eax),%eax
    1b1b:	01 c2                	add    %eax,%edx
    1b1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1b20:	89 50 04             	mov    %edx,0x4(%eax)
		p->s.ptr = bp->s.ptr;
    1b23:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1b26:	8b 10                	mov    (%eax),%edx
    1b28:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1b2b:	89 10                	mov    %edx,(%eax)
    1b2d:	eb 08                	jmp    1b37 <free+0xd7>
	} else
		p->s.ptr = bp;
    1b2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1b32:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1b35:	89 10                	mov    %edx,(%eax)
	freep = p;
    1b37:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1b3a:	a3 98 24 00 00       	mov    %eax,0x2498
}
    1b3f:	90                   	nop
    1b40:	c9                   	leave  
    1b41:	c3                   	ret    

00001b42 <morecore>:

static Header *morecore(uint nu)
{
    1b42:	55                   	push   %ebp
    1b43:	89 e5                	mov    %esp,%ebp
    1b45:	83 ec 18             	sub    $0x18,%esp
	char *p;
	Header *hp;

	if (nu < 4096)
    1b48:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    1b4f:	77 07                	ja     1b58 <morecore+0x16>
		nu = 4096;
    1b51:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
	p = sbrk(nu * sizeof(Header));
    1b58:	8b 45 08             	mov    0x8(%ebp),%eax
    1b5b:	c1 e0 03             	shl    $0x3,%eax
    1b5e:	83 ec 0c             	sub    $0xc,%esp
    1b61:	50                   	push   %eax
    1b62:	e8 31 fc ff ff       	call   1798 <sbrk>
    1b67:	83 c4 10             	add    $0x10,%esp
    1b6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (p == (char *)-1)
    1b6d:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1b71:	75 07                	jne    1b7a <morecore+0x38>
		return 0;
    1b73:	b8 00 00 00 00       	mov    $0x0,%eax
    1b78:	eb 26                	jmp    1ba0 <morecore+0x5e>
	hp = (Header *) p;
    1b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1b7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	hp->s.size = nu;
    1b80:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1b83:	8b 55 08             	mov    0x8(%ebp),%edx
    1b86:	89 50 04             	mov    %edx,0x4(%eax)
	free((void *)(hp + 1));
    1b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1b8c:	83 c0 08             	add    $0x8,%eax
    1b8f:	83 ec 0c             	sub    $0xc,%esp
    1b92:	50                   	push   %eax
    1b93:	e8 c8 fe ff ff       	call   1a60 <free>
    1b98:	83 c4 10             	add    $0x10,%esp
	return freep;
    1b9b:	a1 98 24 00 00       	mov    0x2498,%eax
}
    1ba0:	c9                   	leave  
    1ba1:	c3                   	ret    

00001ba2 <malloc>:

void *malloc(uint nbytes)
{
    1ba2:	55                   	push   %ebp
    1ba3:	89 e5                	mov    %esp,%ebp
    1ba5:	83 ec 18             	sub    $0x18,%esp
	Header *p, *prevp;
	uint nunits;

	nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
    1ba8:	8b 45 08             	mov    0x8(%ebp),%eax
    1bab:	83 c0 07             	add    $0x7,%eax
    1bae:	c1 e8 03             	shr    $0x3,%eax
    1bb1:	83 c0 01             	add    $0x1,%eax
    1bb4:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if ((prevp = freep) == 0) {
    1bb7:	a1 98 24 00 00       	mov    0x2498,%eax
    1bbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1bbf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1bc3:	75 23                	jne    1be8 <malloc+0x46>
		base.s.ptr = freep = prevp = &base;
    1bc5:	c7 45 f0 90 24 00 00 	movl   $0x2490,-0x10(%ebp)
    1bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1bcf:	a3 98 24 00 00       	mov    %eax,0x2498
    1bd4:	a1 98 24 00 00       	mov    0x2498,%eax
    1bd9:	a3 90 24 00 00       	mov    %eax,0x2490
		base.s.size = 0;
    1bde:	c7 05 94 24 00 00 00 	movl   $0x0,0x2494
    1be5:	00 00 00 
	}
	for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
    1be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1beb:	8b 00                	mov    (%eax),%eax
    1bed:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if (p->s.size >= nunits) {
    1bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1bf3:	8b 40 04             	mov    0x4(%eax),%eax
    1bf6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1bf9:	72 4d                	jb     1c48 <malloc+0xa6>
			if (p->s.size == nunits)
    1bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1bfe:	8b 40 04             	mov    0x4(%eax),%eax
    1c01:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1c04:	75 0c                	jne    1c12 <malloc+0x70>
				prevp->s.ptr = p->s.ptr;
    1c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1c09:	8b 10                	mov    (%eax),%edx
    1c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1c0e:	89 10                	mov    %edx,(%eax)
    1c10:	eb 26                	jmp    1c38 <malloc+0x96>
			else {
				p->s.size -= nunits;
    1c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1c15:	8b 40 04             	mov    0x4(%eax),%eax
    1c18:	2b 45 ec             	sub    -0x14(%ebp),%eax
    1c1b:	89 c2                	mov    %eax,%edx
    1c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1c20:	89 50 04             	mov    %edx,0x4(%eax)
				p += p->s.size;
    1c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1c26:	8b 40 04             	mov    0x4(%eax),%eax
    1c29:	c1 e0 03             	shl    $0x3,%eax
    1c2c:	01 45 f4             	add    %eax,-0xc(%ebp)
				p->s.size = nunits;
    1c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1c32:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1c35:	89 50 04             	mov    %edx,0x4(%eax)
			}
			freep = prevp;
    1c38:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1c3b:	a3 98 24 00 00       	mov    %eax,0x2498
			//printf(0, "\nMalloc Pointer Value = %p\n", p+1);
			return (void *)(p + 1);
    1c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1c43:	83 c0 08             	add    $0x8,%eax
    1c46:	eb 3b                	jmp    1c83 <malloc+0xe1>
		}
		if (p == freep)
    1c48:	a1 98 24 00 00       	mov    0x2498,%eax
    1c4d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    1c50:	75 1e                	jne    1c70 <malloc+0xce>
			if ((p = morecore(nunits)) == 0)
    1c52:	83 ec 0c             	sub    $0xc,%esp
    1c55:	ff 75 ec             	pushl  -0x14(%ebp)
    1c58:	e8 e5 fe ff ff       	call   1b42 <morecore>
    1c5d:	83 c4 10             	add    $0x10,%esp
    1c60:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1c63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1c67:	75 07                	jne    1c70 <malloc+0xce>
				return 0;
    1c69:	b8 00 00 00 00       	mov    $0x0,%eax
    1c6e:	eb 13                	jmp    1c83 <malloc+0xe1>
	nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
	if ((prevp = freep) == 0) {
		base.s.ptr = freep = prevp = &base;
		base.s.size = 0;
	}
	for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
    1c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1c73:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1c79:	8b 00                	mov    (%eax),%eax
    1c7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
			return (void *)(p + 1);
		}
		if (p == freep)
			if ((p = morecore(nunits)) == 0)
				return 0;
	}
    1c7e:	e9 6d ff ff ff       	jmp    1bf0 <malloc+0x4e>
}
    1c83:	c9                   	leave  
    1c84:	c3                   	ret    
