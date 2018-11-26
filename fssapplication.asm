
_fssapplication:     file format elf32-i386


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
       b:	68 54 10 00 00       	push   $0x1054
      10:	e8 81 0b 00 00       	call   b96 <mutex_create>
      15:	83 c4 10             	add    $0x10,%esp
      18:	a3 80 1b 00 00       	mov    %eax,0x1b80
	mutexresp=mutex_create("response_mutex",14);
      1d:	83 ec 08             	sub    $0x8,%esp
      20:	6a 0e                	push   $0xe
      22:	68 62 10 00 00       	push   $0x1062
      27:	e8 6a 0b 00 00       	call   b96 <mutex_create>
      2c:	83 c4 10             	add    $0x10,%esp
      2f:	a3 60 17 00 00       	mov    %eax,0x1760
	printf(1,"mutexes made\n");
      34:	83 ec 08             	sub    $0x8,%esp
      37:	68 71 10 00 00       	push   $0x1071
      3c:	6a 01                	push   $0x1
      3e:	e8 5a 0c 00 00       	call   c9d <printf>
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
      4f:	a1 80 1b 00 00       	mov    0x1b80,%eax
      54:	83 ec 0c             	sub    $0xc,%esp
      57:	50                   	push   %eax
      58:	e8 49 0b 00 00       	call   ba6 <mutex_lock>
      5d:	83 c4 10             	add    $0x10,%esp

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
      60:	83 ec 08             	sub    $0x8,%esp
      63:	6a 07                	push   $0x7
      65:	68 7f 10 00 00       	push   $0x107f
      6a:	e8 0f 0b 00 00       	call   b7e <shm_get>
      6f:	83 c4 10             	add    $0x10,%esp
      72:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"write");
      75:	8b 45 f4             	mov    -0xc(%ebp),%eax
      78:	83 ec 08             	sub    $0x8,%esp
      7b:	68 87 10 00 00       	push   $0x1087
      80:	50                   	push   %eax
      81:	e8 27 08 00 00       	call   8ad <strcpy>
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
      a8:	e8 00 08 00 00       	call   8ad <strcpy>
      ad:	83 c4 10             	add    $0x10,%esp
	printf(1,"operation = %s\n",request->operation);
      b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
      b3:	83 ec 04             	sub    $0x4,%esp
      b6:	50                   	push   %eax
      b7:	68 8d 10 00 00       	push   $0x108d
      bc:	6a 01                	push   $0x1
      be:	e8 da 0b 00 00       	call   c9d <printf>
      c3:	83 c4 10             	add    $0x10,%esp
	printf(1,"data set\n");
      c6:	83 ec 08             	sub    $0x8,%esp
      c9:	68 9d 10 00 00       	push   $0x109d
      ce:	6a 01                	push   $0x1
      d0:	e8 c8 0b 00 00       	call   c9d <printf>
      d5:	83 c4 10             	add    $0x10,%esp
	cv_signal(mutexreq);//signals server to read
      d8:	a1 80 1b 00 00       	mov    0x1b80,%eax
      dd:	83 ec 0c             	sub    $0xc,%esp
      e0:	50                   	push   %eax
      e1:	e8 d8 0a 00 00       	call   bbe <cv_signal>
      e6:	83 c4 10             	add    $0x10,%esp
	
	cv_wait(mutexresp);//waits on server to write	
      e9:	a1 60 17 00 00       	mov    0x1760,%eax
      ee:	83 ec 0c             	sub    $0xc,%esp
      f1:	50                   	push   %eax
      f2:	e8 bf 0a 00 00       	call   bb6 <cv_wait>
      f7:	83 c4 10             	add    $0x10,%esp
	printf(1,"waiting done\n");
      fa:	83 ec 08             	sub    $0x8,%esp
      fd:	68 a7 10 00 00       	push   $0x10a7
     102:	6a 01                	push   $0x1
     104:	e8 94 0b 00 00       	call   c9d <printf>
     109:	83 c4 10             	add    $0x10,%esp
	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     10c:	83 ec 08             	sub    $0x8,%esp
     10f:	6a 08                	push   $0x8
     111:	68 b5 10 00 00       	push   $0x10b5
     116:	e8 63 0a 00 00       	call   b7e <shm_get>
     11b:	83 c4 10             	add    $0x10,%esp
     11e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     121:	a1 60 17 00 00       	mov    0x1760,%eax
     126:	83 ec 0c             	sub    $0xc,%esp
     129:	50                   	push   %eax
     12a:	e8 7f 0a 00 00       	call   bae <mutex_unlock>
     12f:	83 c4 10             	add    $0x10,%esp
	printf(1,"response received\n");
     132:	83 ec 08             	sub    $0x8,%esp
     135:	68 be 10 00 00       	push   $0x10be
     13a:	6a 01                	push   $0x1
     13c:	e8 5c 0b 00 00       	call   c9d <printf>
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
     157:	a1 80 1b 00 00       	mov    0x1b80,%eax
     15c:	83 ec 0c             	sub    $0xc,%esp
     15f:	50                   	push   %eax
     160:	e8 41 0a 00 00       	call   ba6 <mutex_lock>
     165:	83 c4 10             	add    $0x10,%esp

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
     168:	83 ec 08             	sub    $0x8,%esp
     16b:	6a 07                	push   $0x7
     16d:	68 7f 10 00 00       	push   $0x107f
     172:	e8 07 0a 00 00       	call   b7e <shm_get>
     177:	83 c4 10             	add    $0x10,%esp
     17a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"read");
     17d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     180:	83 ec 08             	sub    $0x8,%esp
     183:	68 d1 10 00 00       	push   $0x10d1
     188:	50                   	push   %eax
     189:	e8 1f 07 00 00       	call   8ad <strcpy>
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
     1b0:	e8 f8 06 00 00       	call   8ad <strcpy>
     1b5:	83 c4 10             	add    $0x10,%esp


	cv_signal(mutexreq);//signals server to read
     1b8:	a1 80 1b 00 00       	mov    0x1b80,%eax
     1bd:	83 ec 0c             	sub    $0xc,%esp
     1c0:	50                   	push   %eax
     1c1:	e8 f8 09 00 00       	call   bbe <cv_signal>
     1c6:	83 c4 10             	add    $0x10,%esp
	
	cv_wait(mutexresp);//waits on server to write	
     1c9:	a1 60 17 00 00       	mov    0x1760,%eax
     1ce:	83 ec 0c             	sub    $0xc,%esp
     1d1:	50                   	push   %eax
     1d2:	e8 df 09 00 00       	call   bb6 <cv_wait>
     1d7:	83 c4 10             	add    $0x10,%esp

	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     1da:	83 ec 08             	sub    $0x8,%esp
     1dd:	6a 08                	push   $0x8
     1df:	68 b5 10 00 00       	push   $0x10b5
     1e4:	e8 95 09 00 00       	call   b7e <shm_get>
     1e9:	83 c4 10             	add    $0x10,%esp
     1ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     1ef:	a1 60 17 00 00       	mov    0x1760,%eax
     1f4:	83 ec 0c             	sub    $0xc,%esp
     1f7:	50                   	push   %eax
     1f8:	e8 b1 09 00 00       	call   bae <mutex_unlock>
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
     216:	68 d6 10 00 00       	push   $0x10d6
     21b:	6a 01                	push   $0x1
     21d:	e8 7b 0a 00 00       	call   c9d <printf>
     222:	83 c4 10             	add    $0x10,%esp

    mutex_lock(mutexreq);//acquried mutex when writing to shm
     225:	a1 80 1b 00 00       	mov    0x1b80,%eax
     22a:	83 ec 0c             	sub    $0xc,%esp
     22d:	50                   	push   %eax
     22e:	e8 73 09 00 00       	call   ba6 <mutex_lock>
     233:	83 c4 10             	add    $0x10,%esp

	printf(1,"lock taken\n");
     236:	83 ec 08             	sub    $0x8,%esp
     239:	68 e4 10 00 00       	push   $0x10e4
     23e:	6a 01                	push   $0x1
     240:	e8 58 0a 00 00       	call   c9d <printf>
     245:	83 c4 10             	add    $0x10,%esp
	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
     248:	83 ec 08             	sub    $0x8,%esp
     24b:	6a 07                	push   $0x7
     24d:	68 7f 10 00 00       	push   $0x107f
     252:	e8 27 09 00 00       	call   b7e <shm_get>
     257:	83 c4 10             	add    $0x10,%esp
     25a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"open");
     25d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     260:	83 ec 08             	sub    $0x8,%esp
     263:	68 f0 10 00 00       	push   $0x10f0
     268:	50                   	push   %eax
     269:	e8 3f 06 00 00       	call   8ad <strcpy>
     26e:	83 c4 10             	add    $0x10,%esp
	printf(1,"%s\n",request->operation);
     271:	8b 45 f4             	mov    -0xc(%ebp),%eax
     274:	83 ec 04             	sub    $0x4,%esp
     277:	50                   	push   %eax
     278:	68 f5 10 00 00       	push   $0x10f5
     27d:	6a 01                	push   $0x1
     27f:	e8 19 0a 00 00       	call   c9d <printf>
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
     29d:	e8 0b 06 00 00       	call   8ad <strcpy>
     2a2:	83 c4 10             	add    $0x10,%esp
	printf(1,"operation = %s\n",request->operation);
     2a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     2a8:	83 ec 04             	sub    $0x4,%esp
     2ab:	50                   	push   %eax
     2ac:	68 8d 10 00 00       	push   $0x108d
     2b1:	6a 01                	push   $0x1
     2b3:	e8 e5 09 00 00       	call   c9d <printf>
     2b8:	83 c4 10             	add    $0x10,%esp
	printf(1,"data set\n");
     2bb:	83 ec 08             	sub    $0x8,%esp
     2be:	68 9d 10 00 00       	push   $0x109d
     2c3:	6a 01                	push   $0x1
     2c5:	e8 d3 09 00 00       	call   c9d <printf>
     2ca:	83 c4 10             	add    $0x10,%esp
	cv_signal(mutexreq);//signals server to read
     2cd:	a1 80 1b 00 00       	mov    0x1b80,%eax
     2d2:	83 ec 0c             	sub    $0xc,%esp
     2d5:	50                   	push   %eax
     2d6:	e8 e3 08 00 00       	call   bbe <cv_signal>
     2db:	83 c4 10             	add    $0x10,%esp

	cv_wait(mutexresp);//waits on server to write	
     2de:	a1 60 17 00 00       	mov    0x1760,%eax
     2e3:	83 ec 0c             	sub    $0xc,%esp
     2e6:	50                   	push   %eax
     2e7:	e8 ca 08 00 00       	call   bb6 <cv_wait>
     2ec:	83 c4 10             	add    $0x10,%esp
	printf(1,"waiting done\n");
     2ef:	83 ec 08             	sub    $0x8,%esp
     2f2:	68 a7 10 00 00       	push   $0x10a7
     2f7:	6a 01                	push   $0x1
     2f9:	e8 9f 09 00 00       	call   c9d <printf>
     2fe:	83 c4 10             	add    $0x10,%esp
	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     301:	83 ec 08             	sub    $0x8,%esp
     304:	6a 08                	push   $0x8
     306:	68 b5 10 00 00       	push   $0x10b5
     30b:	e8 6e 08 00 00       	call   b7e <shm_get>
     310:	83 c4 10             	add    $0x10,%esp
     313:	89 45 f0             	mov    %eax,-0x10(%ebp)
	
	printf(1,"response received\n");
     316:	83 ec 08             	sub    $0x8,%esp
     319:	68 be 10 00 00       	push   $0x10be
     31e:	6a 01                	push   $0x1
     320:	e8 78 09 00 00       	call   c9d <printf>
     325:	83 c4 10             	add    $0x10,%esp
	retval=response->res;
     328:	8b 45 f0             	mov    -0x10(%ebp),%eax
     32b:	8b 00                	mov    (%eax),%eax
     32d:	89 45 ec             	mov    %eax,-0x14(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     330:	a1 60 17 00 00       	mov    0x1760,%eax
     335:	83 ec 0c             	sub    $0xc,%esp
     338:	50                   	push   %eax
     339:	e8 70 08 00 00       	call   bae <mutex_unlock>
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
     34c:	a1 80 1b 00 00       	mov    0x1b80,%eax
     351:	83 ec 0c             	sub    $0xc,%esp
     354:	50                   	push   %eax
     355:	e8 4c 08 00 00       	call   ba6 <mutex_lock>
     35a:	83 c4 10             	add    $0x10,%esp

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
     35d:	83 ec 08             	sub    $0x8,%esp
     360:	6a 07                	push   $0x7
     362:	68 7f 10 00 00       	push   $0x107f
     367:	e8 12 08 00 00       	call   b7e <shm_get>
     36c:	83 c4 10             	add    $0x10,%esp
     36f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"close");
     372:	8b 45 f4             	mov    -0xc(%ebp),%eax
     375:	83 ec 08             	sub    $0x8,%esp
     378:	68 f9 10 00 00       	push   $0x10f9
     37d:	50                   	push   %eax
     37e:	e8 2a 05 00 00       	call   8ad <strcpy>
     383:	83 c4 10             	add    $0x10,%esp
	//request->arg=n;
	request->fd=fd1;
     386:	8b 45 f4             	mov    -0xc(%ebp),%eax
     389:	8b 55 08             	mov    0x8(%ebp),%edx
     38c:	89 50 0c             	mov    %edx,0xc(%eax)
	//strcpy(request->data,(char *)ptr);

	cv_signal(mutexreq);//signals server to read
     38f:	a1 80 1b 00 00       	mov    0x1b80,%eax
     394:	83 ec 0c             	sub    $0xc,%esp
     397:	50                   	push   %eax
     398:	e8 21 08 00 00       	call   bbe <cv_signal>
     39d:	83 c4 10             	add    $0x10,%esp
	
	cv_wait(mutexresp);//waits on server to write	
     3a0:	a1 60 17 00 00       	mov    0x1760,%eax
     3a5:	83 ec 0c             	sub    $0xc,%esp
     3a8:	50                   	push   %eax
     3a9:	e8 08 08 00 00       	call   bb6 <cv_wait>
     3ae:	83 c4 10             	add    $0x10,%esp

	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     3b1:	83 ec 08             	sub    $0x8,%esp
     3b4:	6a 08                	push   $0x8
     3b6:	68 b5 10 00 00       	push   $0x10b5
     3bb:	e8 be 07 00 00       	call   b7e <shm_get>
     3c0:	83 c4 10             	add    $0x10,%esp
     3c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     3c6:	a1 60 17 00 00       	mov    0x1760,%eax
     3cb:	83 ec 0c             	sub    $0xc,%esp
     3ce:	50                   	push   %eax
     3cf:	e8 da 07 00 00       	call   bae <mutex_unlock>
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
     3ea:	a1 80 1b 00 00       	mov    0x1b80,%eax
     3ef:	83 ec 0c             	sub    $0xc,%esp
     3f2:	50                   	push   %eax
     3f3:	e8 ae 07 00 00       	call   ba6 <mutex_lock>
     3f8:	83 c4 10             	add    $0x10,%esp

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
     3fb:	83 ec 08             	sub    $0x8,%esp
     3fe:	6a 07                	push   $0x7
     400:	68 7f 10 00 00       	push   $0x107f
     405:	e8 74 07 00 00       	call   b7e <shm_get>
     40a:	83 c4 10             	add    $0x10,%esp
     40d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"mkdir");
     410:	8b 45 f4             	mov    -0xc(%ebp),%eax
     413:	83 ec 08             	sub    $0x8,%esp
     416:	68 ff 10 00 00       	push   $0x10ff
     41b:	50                   	push   %eax
     41c:	e8 8c 04 00 00       	call   8ad <strcpy>
     421:	83 c4 10             	add    $0x10,%esp
	//request->arg=n;
	//request->fd=fd1;
	strcpy(request->data,(char *)path);
     424:	8b 45 f4             	mov    -0xc(%ebp),%eax
     427:	83 c0 10             	add    $0x10,%eax
     42a:	83 ec 08             	sub    $0x8,%esp
     42d:	ff 75 08             	pushl  0x8(%ebp)
     430:	50                   	push   %eax
     431:	e8 77 04 00 00       	call   8ad <strcpy>
     436:	83 c4 10             	add    $0x10,%esp
	printf(1,"mkdir test\n");
     439:	83 ec 08             	sub    $0x8,%esp
     43c:	68 05 11 00 00       	push   $0x1105
     441:	6a 01                	push   $0x1
     443:	e8 55 08 00 00       	call   c9d <printf>
     448:	83 c4 10             	add    $0x10,%esp
	cv_signal(mutexreq);//signals server to read
     44b:	a1 80 1b 00 00       	mov    0x1b80,%eax
     450:	83 ec 0c             	sub    $0xc,%esp
     453:	50                   	push   %eax
     454:	e8 65 07 00 00       	call   bbe <cv_signal>
     459:	83 c4 10             	add    $0x10,%esp
	mutex_lock(mutexresp);
     45c:	a1 60 17 00 00       	mov    0x1760,%eax
     461:	83 ec 0c             	sub    $0xc,%esp
     464:	50                   	push   %eax
     465:	e8 3c 07 00 00       	call   ba6 <mutex_lock>
     46a:	83 c4 10             	add    $0x10,%esp
	cv_wait(mutexresp);//waits on server to write	
     46d:	a1 60 17 00 00       	mov    0x1760,%eax
     472:	83 ec 0c             	sub    $0xc,%esp
     475:	50                   	push   %eax
     476:	e8 3b 07 00 00       	call   bb6 <cv_wait>
     47b:	83 c4 10             	add    $0x10,%esp
	printf(1,"testme\n");
     47e:	83 ec 08             	sub    $0x8,%esp
     481:	68 11 11 00 00       	push   $0x1111
     486:	6a 01                	push   $0x1
     488:	e8 10 08 00 00       	call   c9d <printf>
     48d:	83 c4 10             	add    $0x10,%esp
	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     490:	83 ec 08             	sub    $0x8,%esp
     493:	6a 08                	push   $0x8
     495:	68 b5 10 00 00       	push   $0x10b5
     49a:	e8 df 06 00 00       	call   b7e <shm_get>
     49f:	83 c4 10             	add    $0x10,%esp
     4a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     4a5:	a1 60 17 00 00       	mov    0x1760,%eax
     4aa:	83 ec 0c             	sub    $0xc,%esp
     4ad:	50                   	push   %eax
     4ae:	e8 fb 06 00 00       	call   bae <mutex_unlock>
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
     4c9:	a1 80 1b 00 00       	mov    0x1b80,%eax
     4ce:	83 ec 0c             	sub    $0xc,%esp
     4d1:	50                   	push   %eax
     4d2:	e8 cf 06 00 00       	call   ba6 <mutex_lock>
     4d7:	83 c4 10             	add    $0x10,%esp

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
     4da:	83 ec 08             	sub    $0x8,%esp
     4dd:	6a 07                	push   $0x7
     4df:	68 7f 10 00 00       	push   $0x107f
     4e4:	e8 95 06 00 00       	call   b7e <shm_get>
     4e9:	83 c4 10             	add    $0x10,%esp
     4ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"unlink");
     4ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4f2:	83 ec 08             	sub    $0x8,%esp
     4f5:	68 19 11 00 00       	push   $0x1119
     4fa:	50                   	push   %eax
     4fb:	e8 ad 03 00 00       	call   8ad <strcpy>
     500:	83 c4 10             	add    $0x10,%esp
	//request->arg=n;
	//request->fd=fd1;
	strcpy(request->data,(char *)path);
     503:	8b 45 f4             	mov    -0xc(%ebp),%eax
     506:	83 c0 10             	add    $0x10,%eax
     509:	83 ec 08             	sub    $0x8,%esp
     50c:	ff 75 08             	pushl  0x8(%ebp)
     50f:	50                   	push   %eax
     510:	e8 98 03 00 00       	call   8ad <strcpy>
     515:	83 c4 10             	add    $0x10,%esp

	cv_signal(mutexreq);//signals server to read
     518:	a1 80 1b 00 00       	mov    0x1b80,%eax
     51d:	83 ec 0c             	sub    $0xc,%esp
     520:	50                   	push   %eax
     521:	e8 98 06 00 00       	call   bbe <cv_signal>
     526:	83 c4 10             	add    $0x10,%esp
	
	cv_wait(mutexresp);//waits on server to write	
     529:	a1 60 17 00 00       	mov    0x1760,%eax
     52e:	83 ec 0c             	sub    $0xc,%esp
     531:	50                   	push   %eax
     532:	e8 7f 06 00 00       	call   bb6 <cv_wait>
     537:	83 c4 10             	add    $0x10,%esp

	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     53a:	83 ec 08             	sub    $0x8,%esp
     53d:	6a 08                	push   $0x8
     53f:	68 b5 10 00 00       	push   $0x10b5
     544:	e8 35 06 00 00       	call   b7e <shm_get>
     549:	83 c4 10             	add    $0x10,%esp
     54c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     54f:	a1 60 17 00 00       	mov    0x1760,%eax
     554:	83 ec 0c             	sub    $0xc,%esp
     557:	50                   	push   %eax
     558:	e8 51 06 00 00       	call   bae <mutex_unlock>
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
     573:	a1 80 1b 00 00       	mov    0x1b80,%eax
     578:	83 ec 0c             	sub    $0xc,%esp
     57b:	50                   	push   %eax
     57c:	e8 25 06 00 00       	call   ba6 <mutex_lock>
     581:	83 c4 10             	add    $0x10,%esp

	struct fss_request * request= (struct fss_request *) shm_get("request",7);//shmget
     584:	83 ec 08             	sub    $0x8,%esp
     587:	6a 07                	push   $0x7
     589:	68 7f 10 00 00       	push   $0x107f
     58e:	e8 eb 05 00 00       	call   b7e <shm_get>
     593:	83 c4 10             	add    $0x10,%esp
     596:	89 45 f4             	mov    %eax,-0xc(%ebp)
	strcpy(request->operation,"restore");
     599:	8b 45 f4             	mov    -0xc(%ebp),%eax
     59c:	83 ec 08             	sub    $0x8,%esp
     59f:	68 20 11 00 00       	push   $0x1120
     5a4:	50                   	push   %eax
     5a5:	e8 03 03 00 00       	call   8ad <strcpy>
     5aa:	83 c4 10             	add    $0x10,%esp
	//request->arg=n;
	//request->fd=fd1;
	//strcpy(request->data,(char *)path);

	cv_signal(mutexreq);//signals server to read
     5ad:	a1 80 1b 00 00       	mov    0x1b80,%eax
     5b2:	83 ec 0c             	sub    $0xc,%esp
     5b5:	50                   	push   %eax
     5b6:	e8 03 06 00 00       	call   bbe <cv_signal>
     5bb:	83 c4 10             	add    $0x10,%esp
	
	cv_wait(mutexresp);//waits on server to write	
     5be:	a1 60 17 00 00       	mov    0x1760,%eax
     5c3:	83 ec 0c             	sub    $0xc,%esp
     5c6:	50                   	push   %eax
     5c7:	e8 ea 05 00 00       	call   bb6 <cv_wait>
     5cc:	83 c4 10             	add    $0x10,%esp

	struct fss_response * response = (struct fss_response *) shm_get("response",8);
     5cf:	83 ec 08             	sub    $0x8,%esp
     5d2:	6a 08                	push   $0x8
     5d4:	68 b5 10 00 00       	push   $0x10b5
     5d9:	e8 a0 05 00 00       	call   b7e <shm_get>
     5de:	83 c4 10             	add    $0x10,%esp
     5e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	mutex_unlock(mutexresp);//releases the response mutex
     5e4:	a1 60 17 00 00       	mov    0x1760,%eax
     5e9:	83 ec 0c             	sub    $0xc,%esp
     5ec:	50                   	push   %eax
     5ed:	e8 bc 05 00 00       	call   bae <mutex_unlock>
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
char buf[1024];
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
		printf(1, "unlink dir0 failed\n");
		exit();
	}
	printf(1, "mkdir test ok\n");
*/
printf(1, "stesting checkpoining and restoret\n");
     613:	83 ec 08             	sub    $0x8,%esp
     616:	68 28 11 00 00       	push   $0x1128
     61b:	6a 01                	push   $0x1
     61d:	e8 7b 06 00 00       	call   c9d <printf>
     622:	83 c4 10             	add    $0x10,%esp
i=5;
     625:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
	if (fss_mkdir("dirhier") < 0) {
     62c:	83 ec 0c             	sub    $0xc,%esp
     62f:	68 4c 11 00 00       	push   $0x114c
     634:	e8 ab fd ff ff       	call   3e4 <fss_mkdir>
     639:	83 c4 10             	add    $0x10,%esp
     63c:	85 c0                	test   %eax,%eax
     63e:	79 17                	jns    657 <main+0x55>
		printf(1, "mkdir failed\n");
     640:	83 ec 08             	sub    $0x8,%esp
     643:	68 54 11 00 00       	push   $0x1154
     648:	6a 01                	push   $0x1
     64a:	e8 4e 06 00 00       	call   c9d <printf>
     64f:	83 c4 10             	add    $0x10,%esp
		exit();
     652:	e8 87 04 00 00       	call   ade <exit>
	}
	if (fss_mkdir("dirhier/2ndlevel") < 0) {
     657:	83 ec 0c             	sub    $0xc,%esp
     65a:	68 62 11 00 00       	push   $0x1162
     65f:	e8 80 fd ff ff       	call   3e4 <fss_mkdir>
     664:	83 c4 10             	add    $0x10,%esp
     667:	85 c0                	test   %eax,%eax
     669:	79 17                	jns    682 <main+0x80>
		printf(1, "mkdir failed\n");
     66b:	83 ec 08             	sub    $0x8,%esp
     66e:	68 54 11 00 00       	push   $0x1154
     673:	6a 01                	push   $0x1
     675:	e8 23 06 00 00       	call   c9d <printf>
     67a:	83 c4 10             	add    $0x10,%esp
		exit();
     67d:	e8 5c 04 00 00       	call   ade <exit>
	}
	if (fss_mkdir("dirhier/2ndlevelpart2") < 0) {
     682:	83 ec 0c             	sub    $0xc,%esp
     685:	68 73 11 00 00       	push   $0x1173
     68a:	e8 55 fd ff ff       	call   3e4 <fss_mkdir>
     68f:	83 c4 10             	add    $0x10,%esp
     692:	85 c0                	test   %eax,%eax
     694:	79 17                	jns    6ad <main+0xab>
		printf(1, "mkdir failed\n");
     696:	83 ec 08             	sub    $0x8,%esp
     699:	68 54 11 00 00       	push   $0x1154
     69e:	6a 01                	push   $0x1
     6a0:	e8 f8 05 00 00       	call   c9d <printf>
     6a5:	83 c4 10             	add    $0x10,%esp
		exit();
     6a8:	e8 31 04 00 00       	call   ade <exit>
	}
	if (fss_mkdir("dirhier/2ndlevelpart2/2deep4me") < 0) {
     6ad:	83 ec 0c             	sub    $0xc,%esp
     6b0:	68 8c 11 00 00       	push   $0x118c
     6b5:	e8 2a fd ff ff       	call   3e4 <fss_mkdir>
     6ba:	83 c4 10             	add    $0x10,%esp
     6bd:	85 c0                	test   %eax,%eax
     6bf:	79 17                	jns    6d8 <main+0xd6>
		printf(1, "mkdir failed\n");
     6c1:	83 ec 08             	sub    $0x8,%esp
     6c4:	68 54 11 00 00       	push   $0x1154
     6c9:	6a 01                	push   $0x1
     6cb:	e8 cd 05 00 00       	call   c9d <printf>
     6d0:	83 c4 10             	add    $0x10,%esp
		exit();
     6d3:	e8 06 04 00 00       	call   ade <exit>
	}

	fd = fss_open("dirhier/2ndlevelpart2/2deep4me/small", O_CREATE | O_RDWR);
     6d8:	83 ec 08             	sub    $0x8,%esp
     6db:	68 02 02 00 00       	push   $0x202
     6e0:	68 ac 11 00 00       	push   $0x11ac
     6e5:	e8 23 fb ff ff       	call   20d <fss_open>
     6ea:	83 c4 10             	add    $0x10,%esp
     6ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (fd >= 0) {
     6f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     6f4:	78 43                	js     739 <main+0x137>
		printf(1, "creat small succeeded; ok\n");
     6f6:	83 ec 08             	sub    $0x8,%esp
     6f9:	68 d1 11 00 00       	push   $0x11d1
     6fe:	6a 01                	push   $0x1
     700:	e8 98 05 00 00       	call   c9d <printf>
     705:	83 c4 10             	add    $0x10,%esp
	} else {
		printf(1, "error: creat small failed!\n");
		exit();
	}
	printf(1,"fd = %d\n",fd);
     708:	83 ec 04             	sub    $0x4,%esp
     70b:	ff 75 f0             	pushl  -0x10(%ebp)
     70e:	68 08 12 00 00       	push   $0x1208
     713:	6a 01                	push   $0x1
     715:	e8 83 05 00 00       	call   c9d <printf>
     71a:	83 c4 10             	add    $0x10,%esp
		if (fss_write(fd, "hey I'm testing checkpoint", 27) != 27) {
     71d:	83 ec 04             	sub    $0x4,%esp
     720:	6a 1b                	push   $0x1b
     722:	68 11 12 00 00       	push   $0x1211
     727:	ff 75 f0             	pushl  -0x10(%ebp)
     72a:	e8 1a f9 ff ff       	call   49 <fss_write>
     72f:	83 c4 10             	add    $0x10,%esp
     732:	83 f8 1b             	cmp    $0x1b,%eax
     735:	74 5b                	je     792 <main+0x190>
     737:	eb 17                	jmp    750 <main+0x14e>

	fd = fss_open("dirhier/2ndlevelpart2/2deep4me/small", O_CREATE | O_RDWR);
	if (fd >= 0) {
		printf(1, "creat small succeeded; ok\n");
	} else {
		printf(1, "error: creat small failed!\n");
     739:	83 ec 08             	sub    $0x8,%esp
     73c:	68 ec 11 00 00       	push   $0x11ec
     741:	6a 01                	push   $0x1
     743:	e8 55 05 00 00       	call   c9d <printf>
     748:	83 c4 10             	add    $0x10,%esp
		exit();
     74b:	e8 8e 03 00 00       	call   ade <exit>
	}
	printf(1,"fd = %d\n",fd);
		if (fss_write(fd, "hey I'm testing checkpoint", 27) != 27) {
			printf(1, "error: write aa %d new file failed\n",
     750:	83 ec 04             	sub    $0x4,%esp
     753:	ff 75 f4             	pushl  -0xc(%ebp)
     756:	68 2c 12 00 00       	push   $0x122c
     75b:	6a 01                	push   $0x1
     75d:	e8 3b 05 00 00       	call   c9d <printf>
     762:	83 c4 10             	add    $0x10,%esp
			       i);
			printf(1,"result was %d\n",fss_write(fd, "hey I'm testing checkpoint", 27));
     765:	83 ec 04             	sub    $0x4,%esp
     768:	6a 1b                	push   $0x1b
     76a:	68 11 12 00 00       	push   $0x1211
     76f:	ff 75 f0             	pushl  -0x10(%ebp)
     772:	e8 d2 f8 ff ff       	call   49 <fss_write>
     777:	83 c4 10             	add    $0x10,%esp
     77a:	83 ec 04             	sub    $0x4,%esp
     77d:	50                   	push   %eax
     77e:	68 50 12 00 00       	push   $0x1250
     783:	6a 01                	push   $0x1
     785:	e8 13 05 00 00       	call   c9d <printf>
     78a:	83 c4 10             	add    $0x10,%esp
			exit();
     78d:	e8 4c 03 00 00       	call   ade <exit>
		}
		

	if (fss_write(fd, "you failed to restore bitch", 27) != 27) {
     792:	83 ec 04             	sub    $0x4,%esp
     795:	6a 1b                	push   $0x1b
     797:	68 5f 12 00 00       	push   $0x125f
     79c:	ff 75 f0             	pushl  -0x10(%ebp)
     79f:	e8 a5 f8 ff ff       	call   49 <fss_write>
     7a4:	83 c4 10             	add    $0x10,%esp
     7a7:	83 f8 1b             	cmp    $0x1b,%eax
     7aa:	74 1a                	je     7c6 <main+0x1c4>
			printf(1, "error: write bb %d new file failed\n",
     7ac:	83 ec 04             	sub    $0x4,%esp
     7af:	ff 75 f4             	pushl  -0xc(%ebp)
     7b2:	68 7c 12 00 00       	push   $0x127c
     7b7:	6a 01                	push   $0x1
     7b9:	e8 df 04 00 00       	call   c9d <printf>
     7be:	83 c4 10             	add    $0x10,%esp
			       i);
			exit();
     7c1:	e8 18 03 00 00       	call   ade <exit>
		}
	fd = fss_open("checkpoint/dirhier/2ndlevelpart2/2deep4me/small", 0);
     7c6:	83 ec 08             	sub    $0x8,%esp
     7c9:	6a 00                	push   $0x0
     7cb:	68 a0 12 00 00       	push   $0x12a0
     7d0:	e8 38 fa ff ff       	call   20d <fss_open>
     7d5:	83 c4 10             	add    $0x10,%esp
     7d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (fd >= 0){
     7db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     7df:	78 4f                	js     830 <main+0x22e>
			printf(1, "checkpoint works; ok\n");
     7e1:	83 ec 08             	sub    $0x8,%esp
     7e4:	68 d0 12 00 00       	push   $0x12d0
     7e9:	6a 01                	push   $0x1
     7eb:	e8 ad 04 00 00       	call   c9d <printf>
     7f0:	83 c4 10             	add    $0x10,%esp
		} else {
			printf(1, "error:checkpoint failed!\n");
			exit();
		}
	fss_close(fd);
     7f3:	83 ec 0c             	sub    $0xc,%esp
     7f6:	ff 75 f0             	pushl  -0x10(%ebp)
     7f9:	e8 48 fb ff ff       	call   346 <fss_close>
     7fe:	83 c4 10             	add    $0x10,%esp
	//exit();
printf(0, "/////////////////////////////////////////////////////////////////////////////////////\n");
     801:	83 ec 08             	sub    $0x8,%esp
     804:	68 00 13 00 00       	push   $0x1300
     809:	6a 00                	push   $0x0
     80b:	e8 8d 04 00 00       	call   c9d <printf>
     810:	83 c4 10             	add    $0x10,%esp
	fd = fss_open("dirhier/2ndlevelpart2/2deep4me/small", O_RDONLY);
     813:	83 ec 08             	sub    $0x8,%esp
     816:	6a 00                	push   $0x0
     818:	68 ac 11 00 00       	push   $0x11ac
     81d:	e8 eb f9 ff ff       	call   20d <fss_open>
     822:	83 c4 10             	add    $0x10,%esp
     825:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (fd >= 0) {
     828:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     82c:	78 42                	js     870 <main+0x26e>
     82e:	eb 17                	jmp    847 <main+0x245>
		}
	fd = fss_open("checkpoint/dirhier/2ndlevelpart2/2deep4me/small", 0);
		if (fd >= 0){
			printf(1, "checkpoint works; ok\n");
		} else {
			printf(1, "error:checkpoint failed!\n");
     830:	83 ec 08             	sub    $0x8,%esp
     833:	68 e6 12 00 00       	push   $0x12e6
     838:	6a 01                	push   $0x1
     83a:	e8 5e 04 00 00       	call   c9d <printf>
     83f:	83 c4 10             	add    $0x10,%esp
			exit();
     842:	e8 97 02 00 00       	call   ade <exit>
	fss_close(fd);
	//exit();
printf(0, "/////////////////////////////////////////////////////////////////////////////////////\n");
	fd = fss_open("dirhier/2ndlevelpart2/2deep4me/small", O_RDONLY);
	if (fd >= 0) {
		printf(1, "opening the file baby ok\n");
     847:	83 ec 08             	sub    $0x8,%esp
     84a:	68 57 13 00 00       	push   $0x1357
     84f:	6a 01                	push   $0x1
     851:	e8 47 04 00 00       	call   c9d <printf>
     856:	83 c4 10             	add    $0x10,%esp
		printf(1, "error: open small failed!\n");
		exit();
	}
	//fi = fss_read(fd, buf, 2000);
	//int n;
	printf(1,"checking resotre, response should be hey i'm testing cehckpoint\n");
     859:	83 ec 08             	sub    $0x8,%esp
     85c:	68 8c 13 00 00       	push   $0x138c
     861:	6a 01                	push   $0x1
     863:	e8 35 04 00 00       	call   c9d <printf>
     868:	83 c4 10             	add    $0x10,%esp
	if (n < 0) {
		printf(1, "cat: read error\n");
		exit();
	}*/
	
exit();
     86b:	e8 6e 02 00 00       	call   ade <exit>
printf(0, "/////////////////////////////////////////////////////////////////////////////////////\n");
	fd = fss_open("dirhier/2ndlevelpart2/2deep4me/small", O_RDONLY);
	if (fd >= 0) {
		printf(1, "opening the file baby ok\n");
	} else {
		printf(1, "error: open small failed!\n");
     870:	83 ec 08             	sub    $0x8,%esp
     873:	68 71 13 00 00       	push   $0x1371
     878:	6a 01                	push   $0x1
     87a:	e8 1e 04 00 00       	call   c9d <printf>
     87f:	83 c4 10             	add    $0x10,%esp
		exit();
     882:	e8 57 02 00 00       	call   ade <exit>

00000887 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     887:	55                   	push   %ebp
     888:	89 e5                	mov    %esp,%ebp
     88a:	57                   	push   %edi
     88b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     88c:	8b 4d 08             	mov    0x8(%ebp),%ecx
     88f:	8b 55 10             	mov    0x10(%ebp),%edx
     892:	8b 45 0c             	mov    0xc(%ebp),%eax
     895:	89 cb                	mov    %ecx,%ebx
     897:	89 df                	mov    %ebx,%edi
     899:	89 d1                	mov    %edx,%ecx
     89b:	fc                   	cld    
     89c:	f3 aa                	rep stos %al,%es:(%edi)
     89e:	89 ca                	mov    %ecx,%edx
     8a0:	89 fb                	mov    %edi,%ebx
     8a2:	89 5d 08             	mov    %ebx,0x8(%ebp)
     8a5:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     8a8:	90                   	nop
     8a9:	5b                   	pop    %ebx
     8aa:	5f                   	pop    %edi
     8ab:	5d                   	pop    %ebp
     8ac:	c3                   	ret    

000008ad <strcpy>:
#include "fcntl.h"
#include "user.h"
#include "x86.h"

char *strcpy(char *s, char *t)
{
     8ad:	55                   	push   %ebp
     8ae:	89 e5                	mov    %esp,%ebp
     8b0:	83 ec 10             	sub    $0x10,%esp
	char *os;

	os = s;
     8b3:	8b 45 08             	mov    0x8(%ebp),%eax
     8b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*s++ = *t++) != 0) ;
     8b9:	90                   	nop
     8ba:	8b 45 08             	mov    0x8(%ebp),%eax
     8bd:	8d 50 01             	lea    0x1(%eax),%edx
     8c0:	89 55 08             	mov    %edx,0x8(%ebp)
     8c3:	8b 55 0c             	mov    0xc(%ebp),%edx
     8c6:	8d 4a 01             	lea    0x1(%edx),%ecx
     8c9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     8cc:	0f b6 12             	movzbl (%edx),%edx
     8cf:	88 10                	mov    %dl,(%eax)
     8d1:	0f b6 00             	movzbl (%eax),%eax
     8d4:	84 c0                	test   %al,%al
     8d6:	75 e2                	jne    8ba <strcpy+0xd>
	return os;
     8d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     8db:	c9                   	leave  
     8dc:	c3                   	ret    

000008dd <strcmp>:

int strcmp(const char *p, const char *q)
{
     8dd:	55                   	push   %ebp
     8de:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
     8e0:	eb 08                	jmp    8ea <strcmp+0xd>
		p++, q++;
     8e2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     8e6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	return os;
}

int strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
     8ea:	8b 45 08             	mov    0x8(%ebp),%eax
     8ed:	0f b6 00             	movzbl (%eax),%eax
     8f0:	84 c0                	test   %al,%al
     8f2:	74 10                	je     904 <strcmp+0x27>
     8f4:	8b 45 08             	mov    0x8(%ebp),%eax
     8f7:	0f b6 10             	movzbl (%eax),%edx
     8fa:	8b 45 0c             	mov    0xc(%ebp),%eax
     8fd:	0f b6 00             	movzbl (%eax),%eax
     900:	38 c2                	cmp    %al,%dl
     902:	74 de                	je     8e2 <strcmp+0x5>
		p++, q++;
	return (uchar) * p - (uchar) * q;
     904:	8b 45 08             	mov    0x8(%ebp),%eax
     907:	0f b6 00             	movzbl (%eax),%eax
     90a:	0f b6 d0             	movzbl %al,%edx
     90d:	8b 45 0c             	mov    0xc(%ebp),%eax
     910:	0f b6 00             	movzbl (%eax),%eax
     913:	0f b6 c0             	movzbl %al,%eax
     916:	29 c2                	sub    %eax,%edx
     918:	89 d0                	mov    %edx,%eax
}
     91a:	5d                   	pop    %ebp
     91b:	c3                   	ret    

0000091c <strlen>:

uint strlen(char *s)
{
     91c:	55                   	push   %ebp
     91d:	89 e5                	mov    %esp,%ebp
     91f:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; s[n]; n++) ;
     922:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     929:	eb 04                	jmp    92f <strlen+0x13>
     92b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     92f:	8b 55 fc             	mov    -0x4(%ebp),%edx
     932:	8b 45 08             	mov    0x8(%ebp),%eax
     935:	01 d0                	add    %edx,%eax
     937:	0f b6 00             	movzbl (%eax),%eax
     93a:	84 c0                	test   %al,%al
     93c:	75 ed                	jne    92b <strlen+0xf>
	return n;
     93e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     941:	c9                   	leave  
     942:	c3                   	ret    

00000943 <memset>:

void *memset(void *dst, int c, uint n)
{
     943:	55                   	push   %ebp
     944:	89 e5                	mov    %esp,%ebp
	stosb(dst, c, n);
     946:	8b 45 10             	mov    0x10(%ebp),%eax
     949:	50                   	push   %eax
     94a:	ff 75 0c             	pushl  0xc(%ebp)
     94d:	ff 75 08             	pushl  0x8(%ebp)
     950:	e8 32 ff ff ff       	call   887 <stosb>
     955:	83 c4 0c             	add    $0xc,%esp
	return dst;
     958:	8b 45 08             	mov    0x8(%ebp),%eax
}
     95b:	c9                   	leave  
     95c:	c3                   	ret    

0000095d <strchr>:

char *strchr(const char *s, char c)
{
     95d:	55                   	push   %ebp
     95e:	89 e5                	mov    %esp,%ebp
     960:	83 ec 04             	sub    $0x4,%esp
     963:	8b 45 0c             	mov    0xc(%ebp),%eax
     966:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
     969:	eb 14                	jmp    97f <strchr+0x22>
		if (*s == c)
     96b:	8b 45 08             	mov    0x8(%ebp),%eax
     96e:	0f b6 00             	movzbl (%eax),%eax
     971:	3a 45 fc             	cmp    -0x4(%ebp),%al
     974:	75 05                	jne    97b <strchr+0x1e>
			return (char *)s;
     976:	8b 45 08             	mov    0x8(%ebp),%eax
     979:	eb 13                	jmp    98e <strchr+0x31>
	return dst;
}

char *strchr(const char *s, char c)
{
	for (; *s; s++)
     97b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     97f:	8b 45 08             	mov    0x8(%ebp),%eax
     982:	0f b6 00             	movzbl (%eax),%eax
     985:	84 c0                	test   %al,%al
     987:	75 e2                	jne    96b <strchr+0xe>
		if (*s == c)
			return (char *)s;
	return 0;
     989:	b8 00 00 00 00       	mov    $0x0,%eax
}
     98e:	c9                   	leave  
     98f:	c3                   	ret    

00000990 <gets>:

char *gets(char *buf, int max)
{
     990:	55                   	push   %ebp
     991:	89 e5                	mov    %esp,%ebp
     993:	83 ec 18             	sub    $0x18,%esp
	int i, cc;
	char c;

	for (i = 0; i + 1 < max;) {
     996:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     99d:	eb 42                	jmp    9e1 <gets+0x51>
		cc = read(0, &c, 1);
     99f:	83 ec 04             	sub    $0x4,%esp
     9a2:	6a 01                	push   $0x1
     9a4:	8d 45 ef             	lea    -0x11(%ebp),%eax
     9a7:	50                   	push   %eax
     9a8:	6a 00                	push   $0x0
     9aa:	e8 47 01 00 00       	call   af6 <read>
     9af:	83 c4 10             	add    $0x10,%esp
     9b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (cc < 1)
     9b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     9b9:	7e 33                	jle    9ee <gets+0x5e>
			break;
		buf[i++] = c;
     9bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9be:	8d 50 01             	lea    0x1(%eax),%edx
     9c1:	89 55 f4             	mov    %edx,-0xc(%ebp)
     9c4:	89 c2                	mov    %eax,%edx
     9c6:	8b 45 08             	mov    0x8(%ebp),%eax
     9c9:	01 c2                	add    %eax,%edx
     9cb:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     9cf:	88 02                	mov    %al,(%edx)
		if (c == '\n' || c == '\r')
     9d1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     9d5:	3c 0a                	cmp    $0xa,%al
     9d7:	74 16                	je     9ef <gets+0x5f>
     9d9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     9dd:	3c 0d                	cmp    $0xd,%al
     9df:	74 0e                	je     9ef <gets+0x5f>
char *gets(char *buf, int max)
{
	int i, cc;
	char c;

	for (i = 0; i + 1 < max;) {
     9e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9e4:	83 c0 01             	add    $0x1,%eax
     9e7:	3b 45 0c             	cmp    0xc(%ebp),%eax
     9ea:	7c b3                	jl     99f <gets+0xf>
     9ec:	eb 01                	jmp    9ef <gets+0x5f>
		cc = read(0, &c, 1);
		if (cc < 1)
			break;
     9ee:	90                   	nop
		buf[i++] = c;
		if (c == '\n' || c == '\r')
			break;
	}
	buf[i] = '\0';
     9ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
     9f2:	8b 45 08             	mov    0x8(%ebp),%eax
     9f5:	01 d0                	add    %edx,%eax
     9f7:	c6 00 00             	movb   $0x0,(%eax)
	return buf;
     9fa:	8b 45 08             	mov    0x8(%ebp),%eax
}
     9fd:	c9                   	leave  
     9fe:	c3                   	ret    

000009ff <stat>:

int stat(char *n, struct stat *st)
{
     9ff:	55                   	push   %ebp
     a00:	89 e5                	mov    %esp,%ebp
     a02:	83 ec 18             	sub    $0x18,%esp
	int fd;
	int r;

	fd = open(n, O_RDONLY);
     a05:	83 ec 08             	sub    $0x8,%esp
     a08:	6a 00                	push   $0x0
     a0a:	ff 75 08             	pushl  0x8(%ebp)
     a0d:	e8 0c 01 00 00       	call   b1e <open>
     a12:	83 c4 10             	add    $0x10,%esp
     a15:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (fd < 0)
     a18:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     a1c:	79 07                	jns    a25 <stat+0x26>
		return -1;
     a1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     a23:	eb 25                	jmp    a4a <stat+0x4b>
	r = fstat(fd, st);
     a25:	83 ec 08             	sub    $0x8,%esp
     a28:	ff 75 0c             	pushl  0xc(%ebp)
     a2b:	ff 75 f4             	pushl  -0xc(%ebp)
     a2e:	e8 03 01 00 00       	call   b36 <fstat>
     a33:	83 c4 10             	add    $0x10,%esp
     a36:	89 45 f0             	mov    %eax,-0x10(%ebp)
	close(fd);
     a39:	83 ec 0c             	sub    $0xc,%esp
     a3c:	ff 75 f4             	pushl  -0xc(%ebp)
     a3f:	e8 c2 00 00 00       	call   b06 <close>
     a44:	83 c4 10             	add    $0x10,%esp
	return r;
     a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     a4a:	c9                   	leave  
     a4b:	c3                   	ret    

00000a4c <atoi>:

int atoi(const char *s)
{
     a4c:	55                   	push   %ebp
     a4d:	89 e5                	mov    %esp,%ebp
     a4f:	83 ec 10             	sub    $0x10,%esp
	int n;

	n = 0;
     a52:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	while ('0' <= *s && *s <= '9')
     a59:	eb 25                	jmp    a80 <atoi+0x34>
		n = n * 10 + *s++ - '0';
     a5b:	8b 55 fc             	mov    -0x4(%ebp),%edx
     a5e:	89 d0                	mov    %edx,%eax
     a60:	c1 e0 02             	shl    $0x2,%eax
     a63:	01 d0                	add    %edx,%eax
     a65:	01 c0                	add    %eax,%eax
     a67:	89 c1                	mov    %eax,%ecx
     a69:	8b 45 08             	mov    0x8(%ebp),%eax
     a6c:	8d 50 01             	lea    0x1(%eax),%edx
     a6f:	89 55 08             	mov    %edx,0x8(%ebp)
     a72:	0f b6 00             	movzbl (%eax),%eax
     a75:	0f be c0             	movsbl %al,%eax
     a78:	01 c8                	add    %ecx,%eax
     a7a:	83 e8 30             	sub    $0x30,%eax
     a7d:	89 45 fc             	mov    %eax,-0x4(%ebp)
int atoi(const char *s)
{
	int n;

	n = 0;
	while ('0' <= *s && *s <= '9')
     a80:	8b 45 08             	mov    0x8(%ebp),%eax
     a83:	0f b6 00             	movzbl (%eax),%eax
     a86:	3c 2f                	cmp    $0x2f,%al
     a88:	7e 0a                	jle    a94 <atoi+0x48>
     a8a:	8b 45 08             	mov    0x8(%ebp),%eax
     a8d:	0f b6 00             	movzbl (%eax),%eax
     a90:	3c 39                	cmp    $0x39,%al
     a92:	7e c7                	jle    a5b <atoi+0xf>
		n = n * 10 + *s++ - '0';
	return n;
     a94:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     a97:	c9                   	leave  
     a98:	c3                   	ret    

00000a99 <memmove>:

void *memmove(void *vdst, void *vsrc, int n)
{
     a99:	55                   	push   %ebp
     a9a:	89 e5                	mov    %esp,%ebp
     a9c:	83 ec 10             	sub    $0x10,%esp
	char *dst, *src;

	dst = vdst;
     a9f:	8b 45 08             	mov    0x8(%ebp),%eax
     aa2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	src = vsrc;
     aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
     aa8:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
     aab:	eb 17                	jmp    ac4 <memmove+0x2b>
		*dst++ = *src++;
     aad:	8b 45 fc             	mov    -0x4(%ebp),%eax
     ab0:	8d 50 01             	lea    0x1(%eax),%edx
     ab3:	89 55 fc             	mov    %edx,-0x4(%ebp)
     ab6:	8b 55 f8             	mov    -0x8(%ebp),%edx
     ab9:	8d 4a 01             	lea    0x1(%edx),%ecx
     abc:	89 4d f8             	mov    %ecx,-0x8(%ebp)
     abf:	0f b6 12             	movzbl (%edx),%edx
     ac2:	88 10                	mov    %dl,(%eax)
{
	char *dst, *src;

	dst = vdst;
	src = vsrc;
	while (n-- > 0)
     ac4:	8b 45 10             	mov    0x10(%ebp),%eax
     ac7:	8d 50 ff             	lea    -0x1(%eax),%edx
     aca:	89 55 10             	mov    %edx,0x10(%ebp)
     acd:	85 c0                	test   %eax,%eax
     acf:	7f dc                	jg     aad <memmove+0x14>
		*dst++ = *src++;
	return vdst;
     ad1:	8b 45 08             	mov    0x8(%ebp),%eax
}
     ad4:	c9                   	leave  
     ad5:	c3                   	ret    

00000ad6 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     ad6:	b8 01 00 00 00       	mov    $0x1,%eax
     adb:	cd 40                	int    $0x40
     add:	c3                   	ret    

00000ade <exit>:
SYSCALL(exit)
     ade:	b8 02 00 00 00       	mov    $0x2,%eax
     ae3:	cd 40                	int    $0x40
     ae5:	c3                   	ret    

00000ae6 <wait>:
SYSCALL(wait)
     ae6:	b8 03 00 00 00       	mov    $0x3,%eax
     aeb:	cd 40                	int    $0x40
     aed:	c3                   	ret    

00000aee <pipe>:
SYSCALL(pipe)
     aee:	b8 04 00 00 00       	mov    $0x4,%eax
     af3:	cd 40                	int    $0x40
     af5:	c3                   	ret    

00000af6 <read>:
SYSCALL(read)
     af6:	b8 05 00 00 00       	mov    $0x5,%eax
     afb:	cd 40                	int    $0x40
     afd:	c3                   	ret    

00000afe <write>:
SYSCALL(write)
     afe:	b8 10 00 00 00       	mov    $0x10,%eax
     b03:	cd 40                	int    $0x40
     b05:	c3                   	ret    

00000b06 <close>:
SYSCALL(close)
     b06:	b8 15 00 00 00       	mov    $0x15,%eax
     b0b:	cd 40                	int    $0x40
     b0d:	c3                   	ret    

00000b0e <kill>:
SYSCALL(kill)
     b0e:	b8 06 00 00 00       	mov    $0x6,%eax
     b13:	cd 40                	int    $0x40
     b15:	c3                   	ret    

00000b16 <exec>:
SYSCALL(exec)
     b16:	b8 07 00 00 00       	mov    $0x7,%eax
     b1b:	cd 40                	int    $0x40
     b1d:	c3                   	ret    

00000b1e <open>:
SYSCALL(open)
     b1e:	b8 0f 00 00 00       	mov    $0xf,%eax
     b23:	cd 40                	int    $0x40
     b25:	c3                   	ret    

00000b26 <mknod>:
SYSCALL(mknod)
     b26:	b8 11 00 00 00       	mov    $0x11,%eax
     b2b:	cd 40                	int    $0x40
     b2d:	c3                   	ret    

00000b2e <unlink>:
SYSCALL(unlink)
     b2e:	b8 12 00 00 00       	mov    $0x12,%eax
     b33:	cd 40                	int    $0x40
     b35:	c3                   	ret    

00000b36 <fstat>:
SYSCALL(fstat)
     b36:	b8 08 00 00 00       	mov    $0x8,%eax
     b3b:	cd 40                	int    $0x40
     b3d:	c3                   	ret    

00000b3e <link>:
SYSCALL(link)
     b3e:	b8 13 00 00 00       	mov    $0x13,%eax
     b43:	cd 40                	int    $0x40
     b45:	c3                   	ret    

00000b46 <mkdir>:
SYSCALL(mkdir)
     b46:	b8 14 00 00 00       	mov    $0x14,%eax
     b4b:	cd 40                	int    $0x40
     b4d:	c3                   	ret    

00000b4e <chdir>:
SYSCALL(chdir)
     b4e:	b8 09 00 00 00       	mov    $0x9,%eax
     b53:	cd 40                	int    $0x40
     b55:	c3                   	ret    

00000b56 <dup>:
SYSCALL(dup)
     b56:	b8 0a 00 00 00       	mov    $0xa,%eax
     b5b:	cd 40                	int    $0x40
     b5d:	c3                   	ret    

00000b5e <getpid>:
SYSCALL(getpid)
     b5e:	b8 0b 00 00 00       	mov    $0xb,%eax
     b63:	cd 40                	int    $0x40
     b65:	c3                   	ret    

00000b66 <sbrk>:
SYSCALL(sbrk)
     b66:	b8 0c 00 00 00       	mov    $0xc,%eax
     b6b:	cd 40                	int    $0x40
     b6d:	c3                   	ret    

00000b6e <sleep>:
SYSCALL(sleep)
     b6e:	b8 0d 00 00 00       	mov    $0xd,%eax
     b73:	cd 40                	int    $0x40
     b75:	c3                   	ret    

00000b76 <uptime>:
SYSCALL(uptime)
     b76:	b8 0e 00 00 00       	mov    $0xe,%eax
     b7b:	cd 40                	int    $0x40
     b7d:	c3                   	ret    

00000b7e <shm_get>:
SYSCALL(shm_get) //mod2
     b7e:	b8 1c 00 00 00       	mov    $0x1c,%eax
     b83:	cd 40                	int    $0x40
     b85:	c3                   	ret    

00000b86 <shm_rem>:
SYSCALL(shm_rem) //mod2
     b86:	b8 1d 00 00 00       	mov    $0x1d,%eax
     b8b:	cd 40                	int    $0x40
     b8d:	c3                   	ret    

00000b8e <setHighPrio>:
SYSCALL(setHighPrio) //scheduler
     b8e:	b8 1e 00 00 00       	mov    $0x1e,%eax
     b93:	cd 40                	int    $0x40
     b95:	c3                   	ret    

00000b96 <mutex_create>:
SYSCALL(mutex_create)//mod3
     b96:	b8 16 00 00 00       	mov    $0x16,%eax
     b9b:	cd 40                	int    $0x40
     b9d:	c3                   	ret    

00000b9e <mutex_delete>:
SYSCALL(mutex_delete)
     b9e:	b8 17 00 00 00       	mov    $0x17,%eax
     ba3:	cd 40                	int    $0x40
     ba5:	c3                   	ret    

00000ba6 <mutex_lock>:
SYSCALL(mutex_lock)
     ba6:	b8 18 00 00 00       	mov    $0x18,%eax
     bab:	cd 40                	int    $0x40
     bad:	c3                   	ret    

00000bae <mutex_unlock>:
SYSCALL(mutex_unlock)
     bae:	b8 19 00 00 00       	mov    $0x19,%eax
     bb3:	cd 40                	int    $0x40
     bb5:	c3                   	ret    

00000bb6 <cv_wait>:
SYSCALL(cv_wait)
     bb6:	b8 1a 00 00 00       	mov    $0x1a,%eax
     bbb:	cd 40                	int    $0x40
     bbd:	c3                   	ret    

00000bbe <cv_signal>:
SYSCALL(cv_signal)
     bbe:	b8 1b 00 00 00       	mov    $0x1b,%eax
     bc3:	cd 40                	int    $0x40
     bc5:	c3                   	ret    

00000bc6 <putc>:
#include "types.h"
#include "stat.h"
#include "user.h"

static void putc(int fd, char c)
{
     bc6:	55                   	push   %ebp
     bc7:	89 e5                	mov    %esp,%ebp
     bc9:	83 ec 18             	sub    $0x18,%esp
     bcc:	8b 45 0c             	mov    0xc(%ebp),%eax
     bcf:	88 45 f4             	mov    %al,-0xc(%ebp)
	write(fd, &c, 1);
     bd2:	83 ec 04             	sub    $0x4,%esp
     bd5:	6a 01                	push   $0x1
     bd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
     bda:	50                   	push   %eax
     bdb:	ff 75 08             	pushl  0x8(%ebp)
     bde:	e8 1b ff ff ff       	call   afe <write>
     be3:	83 c4 10             	add    $0x10,%esp
}
     be6:	90                   	nop
     be7:	c9                   	leave  
     be8:	c3                   	ret    

00000be9 <printint>:

static void printint(int fd, int xx, int base, int sgn)
{
     be9:	55                   	push   %ebp
     bea:	89 e5                	mov    %esp,%ebp
     bec:	53                   	push   %ebx
     bed:	83 ec 24             	sub    $0x24,%esp
	static char digits[] = "0123456789ABCDEF";
	char buf[16];
	int i, neg;
	uint x;

	neg = 0;
     bf0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	if (sgn && xx < 0) {
     bf7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     bfb:	74 17                	je     c14 <printint+0x2b>
     bfd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
     c01:	79 11                	jns    c14 <printint+0x2b>
		neg = 1;
     c03:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
		x = -xx;
     c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
     c0d:	f7 d8                	neg    %eax
     c0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
     c12:	eb 06                	jmp    c1a <printint+0x31>
	} else {
		x = xx;
     c14:	8b 45 0c             	mov    0xc(%ebp),%eax
     c17:	89 45 ec             	mov    %eax,-0x14(%ebp)
	}

	i = 0;
     c1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	do {
		buf[i++] = digits[x % base];
     c21:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     c24:	8d 41 01             	lea    0x1(%ecx),%eax
     c27:	89 45 f4             	mov    %eax,-0xc(%ebp)
     c2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
     c2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c30:	ba 00 00 00 00       	mov    $0x0,%edx
     c35:	f7 f3                	div    %ebx
     c37:	89 d0                	mov    %edx,%eax
     c39:	0f b6 80 1c 17 00 00 	movzbl 0x171c(%eax),%eax
     c40:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
	} while ((x /= base) != 0);
     c44:	8b 5d 10             	mov    0x10(%ebp),%ebx
     c47:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c4a:	ba 00 00 00 00       	mov    $0x0,%edx
     c4f:	f7 f3                	div    %ebx
     c51:	89 45 ec             	mov    %eax,-0x14(%ebp)
     c54:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     c58:	75 c7                	jne    c21 <printint+0x38>
	if (neg)
     c5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     c5e:	74 2d                	je     c8d <printint+0xa4>
		buf[i++] = '-';
     c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c63:	8d 50 01             	lea    0x1(%eax),%edx
     c66:	89 55 f4             	mov    %edx,-0xc(%ebp)
     c69:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

	while (--i >= 0)
     c6e:	eb 1d                	jmp    c8d <printint+0xa4>
		putc(fd, buf[i]);
     c70:	8d 55 dc             	lea    -0x24(%ebp),%edx
     c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c76:	01 d0                	add    %edx,%eax
     c78:	0f b6 00             	movzbl (%eax),%eax
     c7b:	0f be c0             	movsbl %al,%eax
     c7e:	83 ec 08             	sub    $0x8,%esp
     c81:	50                   	push   %eax
     c82:	ff 75 08             	pushl  0x8(%ebp)
     c85:	e8 3c ff ff ff       	call   bc6 <putc>
     c8a:	83 c4 10             	add    $0x10,%esp
		buf[i++] = digits[x % base];
	} while ((x /= base) != 0);
	if (neg)
		buf[i++] = '-';

	while (--i >= 0)
     c8d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
     c91:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     c95:	79 d9                	jns    c70 <printint+0x87>
		putc(fd, buf[i]);
}
     c97:	90                   	nop
     c98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     c9b:	c9                   	leave  
     c9c:	c3                   	ret    

00000c9d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void printf(int fd, char *fmt, ...)
{
     c9d:	55                   	push   %ebp
     c9e:	89 e5                	mov    %esp,%ebp
     ca0:	83 ec 28             	sub    $0x28,%esp
	char *s;
	int c, i, state;
	uint *ap;

	state = 0;
     ca3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	ap = (uint *) (void *)&fmt + 1;
     caa:	8d 45 0c             	lea    0xc(%ebp),%eax
     cad:	83 c0 04             	add    $0x4,%eax
     cb0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	for (i = 0; fmt[i]; i++) {
     cb3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     cba:	e9 59 01 00 00       	jmp    e18 <printf+0x17b>
		c = fmt[i] & 0xff;
     cbf:	8b 55 0c             	mov    0xc(%ebp),%edx
     cc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
     cc5:	01 d0                	add    %edx,%eax
     cc7:	0f b6 00             	movzbl (%eax),%eax
     cca:	0f be c0             	movsbl %al,%eax
     ccd:	25 ff 00 00 00       	and    $0xff,%eax
     cd2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (state == 0) {
     cd5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     cd9:	75 2c                	jne    d07 <printf+0x6a>
			if (c == '%') {
     cdb:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
     cdf:	75 0c                	jne    ced <printf+0x50>
				state = '%';
     ce1:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
     ce8:	e9 27 01 00 00       	jmp    e14 <printf+0x177>
			} else {
				putc(fd, c);
     ced:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     cf0:	0f be c0             	movsbl %al,%eax
     cf3:	83 ec 08             	sub    $0x8,%esp
     cf6:	50                   	push   %eax
     cf7:	ff 75 08             	pushl  0x8(%ebp)
     cfa:	e8 c7 fe ff ff       	call   bc6 <putc>
     cff:	83 c4 10             	add    $0x10,%esp
     d02:	e9 0d 01 00 00       	jmp    e14 <printf+0x177>
			}
		} else if (state == '%') {
     d07:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
     d0b:	0f 85 03 01 00 00    	jne    e14 <printf+0x177>
			if (c == 'd') {
     d11:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
     d15:	75 1e                	jne    d35 <printf+0x98>
				printint(fd, *ap, 10, 1);
     d17:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d1a:	8b 00                	mov    (%eax),%eax
     d1c:	6a 01                	push   $0x1
     d1e:	6a 0a                	push   $0xa
     d20:	50                   	push   %eax
     d21:	ff 75 08             	pushl  0x8(%ebp)
     d24:	e8 c0 fe ff ff       	call   be9 <printint>
     d29:	83 c4 10             	add    $0x10,%esp
				ap++;
     d2c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
     d30:	e9 d8 00 00 00       	jmp    e0d <printf+0x170>
			} else if (c == 'x' || c == 'p') {
     d35:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
     d39:	74 06                	je     d41 <printf+0xa4>
     d3b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
     d3f:	75 1e                	jne    d5f <printf+0xc2>
				printint(fd, *ap, 16, 0);
     d41:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d44:	8b 00                	mov    (%eax),%eax
     d46:	6a 00                	push   $0x0
     d48:	6a 10                	push   $0x10
     d4a:	50                   	push   %eax
     d4b:	ff 75 08             	pushl  0x8(%ebp)
     d4e:	e8 96 fe ff ff       	call   be9 <printint>
     d53:	83 c4 10             	add    $0x10,%esp
				ap++;
     d56:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
     d5a:	e9 ae 00 00 00       	jmp    e0d <printf+0x170>
			} else if (c == 's') {
     d5f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
     d63:	75 43                	jne    da8 <printf+0x10b>
				s = (char *)*ap;
     d65:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d68:	8b 00                	mov    (%eax),%eax
     d6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
				ap++;
     d6d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
				if (s == 0)
     d71:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     d75:	75 25                	jne    d9c <printf+0xff>
					s = "(null)";
     d77:	c7 45 f4 cd 13 00 00 	movl   $0x13cd,-0xc(%ebp)
				while (*s != 0) {
     d7e:	eb 1c                	jmp    d9c <printf+0xff>
					putc(fd, *s);
     d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d83:	0f b6 00             	movzbl (%eax),%eax
     d86:	0f be c0             	movsbl %al,%eax
     d89:	83 ec 08             	sub    $0x8,%esp
     d8c:	50                   	push   %eax
     d8d:	ff 75 08             	pushl  0x8(%ebp)
     d90:	e8 31 fe ff ff       	call   bc6 <putc>
     d95:	83 c4 10             	add    $0x10,%esp
					s++;
     d98:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
			} else if (c == 's') {
				s = (char *)*ap;
				ap++;
				if (s == 0)
					s = "(null)";
				while (*s != 0) {
     d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d9f:	0f b6 00             	movzbl (%eax),%eax
     da2:	84 c0                	test   %al,%al
     da4:	75 da                	jne    d80 <printf+0xe3>
     da6:	eb 65                	jmp    e0d <printf+0x170>
					putc(fd, *s);
					s++;
				}
			} else if (c == 'c') {
     da8:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
     dac:	75 1d                	jne    dcb <printf+0x12e>
				putc(fd, *ap);
     dae:	8b 45 e8             	mov    -0x18(%ebp),%eax
     db1:	8b 00                	mov    (%eax),%eax
     db3:	0f be c0             	movsbl %al,%eax
     db6:	83 ec 08             	sub    $0x8,%esp
     db9:	50                   	push   %eax
     dba:	ff 75 08             	pushl  0x8(%ebp)
     dbd:	e8 04 fe ff ff       	call   bc6 <putc>
     dc2:	83 c4 10             	add    $0x10,%esp
				ap++;
     dc5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
     dc9:	eb 42                	jmp    e0d <printf+0x170>
			} else if (c == '%') {
     dcb:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
     dcf:	75 17                	jne    de8 <printf+0x14b>
				putc(fd, c);
     dd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     dd4:	0f be c0             	movsbl %al,%eax
     dd7:	83 ec 08             	sub    $0x8,%esp
     dda:	50                   	push   %eax
     ddb:	ff 75 08             	pushl  0x8(%ebp)
     dde:	e8 e3 fd ff ff       	call   bc6 <putc>
     de3:	83 c4 10             	add    $0x10,%esp
     de6:	eb 25                	jmp    e0d <printf+0x170>
			} else {
				// Unknown % sequence.  Print it to draw attention.
				putc(fd, '%');
     de8:	83 ec 08             	sub    $0x8,%esp
     deb:	6a 25                	push   $0x25
     ded:	ff 75 08             	pushl  0x8(%ebp)
     df0:	e8 d1 fd ff ff       	call   bc6 <putc>
     df5:	83 c4 10             	add    $0x10,%esp
				putc(fd, c);
     df8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     dfb:	0f be c0             	movsbl %al,%eax
     dfe:	83 ec 08             	sub    $0x8,%esp
     e01:	50                   	push   %eax
     e02:	ff 75 08             	pushl  0x8(%ebp)
     e05:	e8 bc fd ff ff       	call   bc6 <putc>
     e0a:	83 c4 10             	add    $0x10,%esp
			}
			state = 0;
     e0d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int c, i, state;
	uint *ap;

	state = 0;
	ap = (uint *) (void *)&fmt + 1;
	for (i = 0; fmt[i]; i++) {
     e14:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     e18:	8b 55 0c             	mov    0xc(%ebp),%edx
     e1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
     e1e:	01 d0                	add    %edx,%eax
     e20:	0f b6 00             	movzbl (%eax),%eax
     e23:	84 c0                	test   %al,%al
     e25:	0f 85 94 fe ff ff    	jne    cbf <printf+0x22>
				putc(fd, c);
			}
			state = 0;
		}
	}
}
     e2b:	90                   	nop
     e2c:	c9                   	leave  
     e2d:	c3                   	ret    

00000e2e <free>:

static Header base;
static Header *freep;

void free(void *ap)
{
     e2e:	55                   	push   %ebp
     e2f:	89 e5                	mov    %esp,%ebp
     e31:	83 ec 10             	sub    $0x10,%esp
	Header *bp, *p;

	bp = (Header *) ap - 1; //take address of memory -> subtract one size of p to get to header to memeory
     e34:	8b 45 08             	mov    0x8(%ebp),%eax
     e37:	83 e8 08             	sub    $0x8,%eax
     e3a:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr) //comparing pointers to headers...maybe ordering spatially...
     e3d:	a1 48 17 00 00       	mov    0x1748,%eax
     e42:	89 45 fc             	mov    %eax,-0x4(%ebp)
     e45:	eb 24                	jmp    e6b <free+0x3d>
		if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     e47:	8b 45 fc             	mov    -0x4(%ebp),%eax
     e4a:	8b 00                	mov    (%eax),%eax
     e4c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
     e4f:	77 12                	ja     e63 <free+0x35>
     e51:	8b 45 f8             	mov    -0x8(%ebp),%eax
     e54:	3b 45 fc             	cmp    -0x4(%ebp),%eax
     e57:	77 24                	ja     e7d <free+0x4f>
     e59:	8b 45 fc             	mov    -0x4(%ebp),%eax
     e5c:	8b 00                	mov    (%eax),%eax
     e5e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
     e61:	77 1a                	ja     e7d <free+0x4f>
void free(void *ap)
{
	Header *bp, *p;

	bp = (Header *) ap - 1; //take address of memory -> subtract one size of p to get to header to memeory
	for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr) //comparing pointers to headers...maybe ordering spatially...
     e63:	8b 45 fc             	mov    -0x4(%ebp),%eax
     e66:	8b 00                	mov    (%eax),%eax
     e68:	89 45 fc             	mov    %eax,-0x4(%ebp)
     e6b:	8b 45 f8             	mov    -0x8(%ebp),%eax
     e6e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
     e71:	76 d4                	jbe    e47 <free+0x19>
     e73:	8b 45 fc             	mov    -0x4(%ebp),%eax
     e76:	8b 00                	mov    (%eax),%eax
     e78:	3b 45 f8             	cmp    -0x8(%ebp),%eax
     e7b:	76 ca                	jbe    e47 <free+0x19>
		if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
			break;
	if (bp + bp->s.size == p->s.ptr) { //checks sizes to merge contiguous freed regions
     e7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
     e80:	8b 40 04             	mov    0x4(%eax),%eax
     e83:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     e8a:	8b 45 f8             	mov    -0x8(%ebp),%eax
     e8d:	01 c2                	add    %eax,%edx
     e8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
     e92:	8b 00                	mov    (%eax),%eax
     e94:	39 c2                	cmp    %eax,%edx
     e96:	75 24                	jne    ebc <free+0x8e>
		bp->s.size += p->s.ptr->s.size;
     e98:	8b 45 f8             	mov    -0x8(%ebp),%eax
     e9b:	8b 50 04             	mov    0x4(%eax),%edx
     e9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
     ea1:	8b 00                	mov    (%eax),%eax
     ea3:	8b 40 04             	mov    0x4(%eax),%eax
     ea6:	01 c2                	add    %eax,%edx
     ea8:	8b 45 f8             	mov    -0x8(%ebp),%eax
     eab:	89 50 04             	mov    %edx,0x4(%eax)
		bp->s.ptr = p->s.ptr->s.ptr;
     eae:	8b 45 fc             	mov    -0x4(%ebp),%eax
     eb1:	8b 00                	mov    (%eax),%eax
     eb3:	8b 10                	mov    (%eax),%edx
     eb5:	8b 45 f8             	mov    -0x8(%ebp),%eax
     eb8:	89 10                	mov    %edx,(%eax)
     eba:	eb 0a                	jmp    ec6 <free+0x98>
	} else
		bp->s.ptr = p->s.ptr;
     ebc:	8b 45 fc             	mov    -0x4(%ebp),%eax
     ebf:	8b 10                	mov    (%eax),%edx
     ec1:	8b 45 f8             	mov    -0x8(%ebp),%eax
     ec4:	89 10                	mov    %edx,(%eax)
	if (p + p->s.size == bp) {
     ec6:	8b 45 fc             	mov    -0x4(%ebp),%eax
     ec9:	8b 40 04             	mov    0x4(%eax),%eax
     ecc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     ed3:	8b 45 fc             	mov    -0x4(%ebp),%eax
     ed6:	01 d0                	add    %edx,%eax
     ed8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
     edb:	75 20                	jne    efd <free+0xcf>
		p->s.size += bp->s.size;
     edd:	8b 45 fc             	mov    -0x4(%ebp),%eax
     ee0:	8b 50 04             	mov    0x4(%eax),%edx
     ee3:	8b 45 f8             	mov    -0x8(%ebp),%eax
     ee6:	8b 40 04             	mov    0x4(%eax),%eax
     ee9:	01 c2                	add    %eax,%edx
     eeb:	8b 45 fc             	mov    -0x4(%ebp),%eax
     eee:	89 50 04             	mov    %edx,0x4(%eax)
		p->s.ptr = bp->s.ptr;
     ef1:	8b 45 f8             	mov    -0x8(%ebp),%eax
     ef4:	8b 10                	mov    (%eax),%edx
     ef6:	8b 45 fc             	mov    -0x4(%ebp),%eax
     ef9:	89 10                	mov    %edx,(%eax)
     efb:	eb 08                	jmp    f05 <free+0xd7>
	} else
		p->s.ptr = bp;
     efd:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f00:	8b 55 f8             	mov    -0x8(%ebp),%edx
     f03:	89 10                	mov    %edx,(%eax)
	freep = p;
     f05:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f08:	a3 48 17 00 00       	mov    %eax,0x1748
}
     f0d:	90                   	nop
     f0e:	c9                   	leave  
     f0f:	c3                   	ret    

00000f10 <morecore>:

static Header *morecore(uint nu)
{
     f10:	55                   	push   %ebp
     f11:	89 e5                	mov    %esp,%ebp
     f13:	83 ec 18             	sub    $0x18,%esp
	char *p;
	Header *hp;

	if (nu < 4096)
     f16:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
     f1d:	77 07                	ja     f26 <morecore+0x16>
		nu = 4096;
     f1f:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
	p = sbrk(nu * sizeof(Header));
     f26:	8b 45 08             	mov    0x8(%ebp),%eax
     f29:	c1 e0 03             	shl    $0x3,%eax
     f2c:	83 ec 0c             	sub    $0xc,%esp
     f2f:	50                   	push   %eax
     f30:	e8 31 fc ff ff       	call   b66 <sbrk>
     f35:	83 c4 10             	add    $0x10,%esp
     f38:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (p == (char *)-1)
     f3b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     f3f:	75 07                	jne    f48 <morecore+0x38>
		return 0;
     f41:	b8 00 00 00 00       	mov    $0x0,%eax
     f46:	eb 26                	jmp    f6e <morecore+0x5e>
	hp = (Header *) p;
     f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	hp->s.size = nu;
     f4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
     f51:	8b 55 08             	mov    0x8(%ebp),%edx
     f54:	89 50 04             	mov    %edx,0x4(%eax)
	free((void *)(hp + 1));
     f57:	8b 45 f0             	mov    -0x10(%ebp),%eax
     f5a:	83 c0 08             	add    $0x8,%eax
     f5d:	83 ec 0c             	sub    $0xc,%esp
     f60:	50                   	push   %eax
     f61:	e8 c8 fe ff ff       	call   e2e <free>
     f66:	83 c4 10             	add    $0x10,%esp
	return freep;
     f69:	a1 48 17 00 00       	mov    0x1748,%eax
}
     f6e:	c9                   	leave  
     f6f:	c3                   	ret    

00000f70 <malloc>:

void *malloc(uint nbytes)
{
     f70:	55                   	push   %ebp
     f71:	89 e5                	mov    %esp,%ebp
     f73:	83 ec 18             	sub    $0x18,%esp
	Header *p, *prevp;
	uint nunits;

	nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
     f76:	8b 45 08             	mov    0x8(%ebp),%eax
     f79:	83 c0 07             	add    $0x7,%eax
     f7c:	c1 e8 03             	shr    $0x3,%eax
     f7f:	83 c0 01             	add    $0x1,%eax
     f82:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if ((prevp = freep) == 0) {
     f85:	a1 48 17 00 00       	mov    0x1748,%eax
     f8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
     f8d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     f91:	75 23                	jne    fb6 <malloc+0x46>
		base.s.ptr = freep = prevp = &base;
     f93:	c7 45 f0 40 17 00 00 	movl   $0x1740,-0x10(%ebp)
     f9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     f9d:	a3 48 17 00 00       	mov    %eax,0x1748
     fa2:	a1 48 17 00 00       	mov    0x1748,%eax
     fa7:	a3 40 17 00 00       	mov    %eax,0x1740
		base.s.size = 0;
     fac:	c7 05 44 17 00 00 00 	movl   $0x0,0x1744
     fb3:	00 00 00 
	}
	for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
     fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
     fb9:	8b 00                	mov    (%eax),%eax
     fbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if (p->s.size >= nunits) {
     fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
     fc1:	8b 40 04             	mov    0x4(%eax),%eax
     fc4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
     fc7:	72 4d                	jb     1016 <malloc+0xa6>
			if (p->s.size == nunits)
     fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     fcc:	8b 40 04             	mov    0x4(%eax),%eax
     fcf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
     fd2:	75 0c                	jne    fe0 <malloc+0x70>
				prevp->s.ptr = p->s.ptr;
     fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     fd7:	8b 10                	mov    (%eax),%edx
     fd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
     fdc:	89 10                	mov    %edx,(%eax)
     fde:	eb 26                	jmp    1006 <malloc+0x96>
			else {
				p->s.size -= nunits;
     fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     fe3:	8b 40 04             	mov    0x4(%eax),%eax
     fe6:	2b 45 ec             	sub    -0x14(%ebp),%eax
     fe9:	89 c2                	mov    %eax,%edx
     feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     fee:	89 50 04             	mov    %edx,0x4(%eax)
				p += p->s.size;
     ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ff4:	8b 40 04             	mov    0x4(%eax),%eax
     ff7:	c1 e0 03             	shl    $0x3,%eax
     ffa:	01 45 f4             	add    %eax,-0xc(%ebp)
				p->s.size = nunits;
     ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1000:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1003:	89 50 04             	mov    %edx,0x4(%eax)
			}
			freep = prevp;
    1006:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1009:	a3 48 17 00 00       	mov    %eax,0x1748
			//printf(0, "\nMalloc Pointer Value = %p\n", p+1);
			return (void *)(p + 1);
    100e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1011:	83 c0 08             	add    $0x8,%eax
    1014:	eb 3b                	jmp    1051 <malloc+0xe1>
		}
		if (p == freep)
    1016:	a1 48 17 00 00       	mov    0x1748,%eax
    101b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    101e:	75 1e                	jne    103e <malloc+0xce>
			if ((p = morecore(nunits)) == 0)
    1020:	83 ec 0c             	sub    $0xc,%esp
    1023:	ff 75 ec             	pushl  -0x14(%ebp)
    1026:	e8 e5 fe ff ff       	call   f10 <morecore>
    102b:	83 c4 10             	add    $0x10,%esp
    102e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1031:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1035:	75 07                	jne    103e <malloc+0xce>
				return 0;
    1037:	b8 00 00 00 00       	mov    $0x0,%eax
    103c:	eb 13                	jmp    1051 <malloc+0xe1>
	nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
	if ((prevp = freep) == 0) {
		base.s.ptr = freep = prevp = &base;
		base.s.size = 0;
	}
	for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
    103e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1041:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1044:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1047:	8b 00                	mov    (%eax),%eax
    1049:	89 45 f4             	mov    %eax,-0xc(%ebp)
			return (void *)(p + 1);
		}
		if (p == freep)
			if ((p = morecore(nunits)) == 0)
				return 0;
	}
    104c:	e9 6d ff ff ff       	jmp    fbe <malloc+0x4e>
}
    1051:	c9                   	leave  
    1052:	c3                   	ret    
