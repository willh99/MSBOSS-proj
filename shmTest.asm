
_shmTest:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "user.h"

int main(void)
{
       0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
       4:	83 e4 f0             	and    $0xfffffff0,%esp
       7:	ff 71 fc             	pushl  -0x4(%ecx)
       a:	55                   	push   %ebp
       b:	89 e5                	mov    %esp,%ebp
       d:	51                   	push   %ecx
       e:	83 ec 24             	sub    $0x24,%esp
	printf(0, "Running shmTest\n");
      11:	83 ec 08             	sub    $0x8,%esp
      14:	68 f8 11 00 00       	push   $0x11f8
      19:	6a 00                	push   $0x0
      1b:	e8 20 0e 00 00       	call   e40 <printf>
      20:	83 c4 10             	add    $0x10,%esp
	int pid;
	//int sbrkAddr = 0;
	//char* check = 0;
	int i = 0;
      23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct foo{
		int bloop;
		int doop;
	};

	setHighPrio();
      2a:	e8 02 0d 00 00       	call   d31 <setHighPrio>

		for(i=0; i<10; i++)
      2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
      36:	eb 16                	jmp    4e <main+0x4e>
		{
			printf(1, "+");
      38:	83 ec 08             	sub    $0x8,%esp
      3b:	68 09 12 00 00       	push   $0x1209
      40:	6a 01                	push   $0x1
      42:	e8 f9 0d 00 00       	call   e40 <printf>
      47:	83 c4 10             	add    $0x10,%esp
		int doop;
	};

	setHighPrio();

		for(i=0; i<10; i++)
      4a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      4e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
      52:	7e e4                	jle    38 <main+0x38>
		{
			printf(1, "+");
		}

		printf(1,"Response Creation in Parent");
      54:	83 ec 08             	sub    $0x8,%esp
      57:	68 0b 12 00 00       	push   $0x120b
      5c:	6a 01                	push   $0x1
      5e:	e8 dd 0d 00 00       	call   e40 <printf>
      63:	83 c4 10             	add    $0x10,%esp

		for(i=0; i<10; i++)
      66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
      6d:	eb 16                	jmp    85 <main+0x85>
		{
			printf(1, "+");
      6f:	83 ec 08             	sub    $0x8,%esp
      72:	68 09 12 00 00       	push   $0x1209
      77:	6a 01                	push   $0x1
      79:	e8 c2 0d 00 00       	call   e40 <printf>
      7e:	83 c4 10             	add    $0x10,%esp
			printf(1, "+");
		}

		printf(1,"Response Creation in Parent");

		for(i=0; i<10; i++)
      81:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      85:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
      89:	7e e4                	jle    6f <main+0x6f>
		{
			printf(1, "+");
		}

	struct foo* fssTest = (struct foo*) shm_get("response", 9);
      8b:	83 ec 08             	sub    $0x8,%esp
      8e:	6a 09                	push   $0x9
      90:	68 27 12 00 00       	push   $0x1227
      95:	e8 87 0c 00 00       	call   d21 <shm_get>
      9a:	83 c4 10             	add    $0x10,%esp
      9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	printf(0, "\nfssTest = %d\n", fssTest);
      a0:	83 ec 04             	sub    $0x4,%esp
      a3:	ff 75 f0             	pushl  -0x10(%ebp)
      a6:	68 30 12 00 00       	push   $0x1230
      ab:	6a 00                	push   $0x0
      ad:	e8 8e 0d 00 00       	call   e40 <printf>
      b2:	83 c4 10             	add    $0x10,%esp
	//sbrkAddr = (int)sbrk(4096);
	//struct foo* check = (struct foo*)sbrk(4096);
	//printf(0, "\nSbrk address = %d\n", sbrkAddr);

	//Everything above the fork should be inherited to the child, including SHM access
	pid = fork();
      b5:	e8 bf 0b 00 00       	call   c79 <fork>
      ba:	89 45 ec             	mov    %eax,-0x14(%ebp)

	if(pid == 0) //in child
      bd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
      c1:	0f 85 3c 03 00 00    	jne    403 <main+0x403>
	{
		for(i=0; i<10; i++)
      c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
      ce:	eb 16                	jmp    e6 <main+0xe6>
		{
			printf(1, "-");
      d0:	83 ec 08             	sub    $0x8,%esp
      d3:	68 3f 12 00 00       	push   $0x123f
      d8:	6a 01                	push   $0x1
      da:	e8 61 0d 00 00       	call   e40 <printf>
      df:	83 c4 10             	add    $0x10,%esp
	//Everything above the fork should be inherited to the child, including SHM access
	pid = fork();

	if(pid == 0) //in child
	{
		for(i=0; i<10; i++)
      e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      e6:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
      ea:	7e e4                	jle    d0 <main+0xd0>
		{
			printf(1, "-");
		}

		printf(1,"Test Creation in Child");
      ec:	83 ec 08             	sub    $0x8,%esp
      ef:	68 41 12 00 00       	push   $0x1241
      f4:	6a 01                	push   $0x1
      f6:	e8 45 0d 00 00       	call   e40 <printf>
      fb:	83 c4 10             	add    $0x10,%esp

		for(i=0; i<10; i++)
      fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     105:	eb 16                	jmp    11d <main+0x11d>
		{
			printf(1, "-");
     107:	83 ec 08             	sub    $0x8,%esp
     10a:	68 3f 12 00 00       	push   $0x123f
     10f:	6a 01                	push   $0x1
     111:	e8 2a 0d 00 00       	call   e40 <printf>
     116:	83 c4 10             	add    $0x10,%esp
			printf(1, "-");
		}

		printf(1,"Test Creation in Child");

		for(i=0; i<10; i++)
     119:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     11d:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     121:	7e e4                	jle    107 <main+0x107>
		{
			printf(1, "-");
		}

		printf(0, "\nStarting Check3\n");
     123:	83 ec 08             	sub    $0x8,%esp
     126:	68 58 12 00 00       	push   $0x1258
     12b:	6a 00                	push   $0x0
     12d:	e8 0e 0d 00 00       	call   e40 <printf>
     132:	83 c4 10             	add    $0x10,%esp
		struct foo* check3 = (struct foo*) shm_get("test", 5);
     135:	83 ec 08             	sub    $0x8,%esp
     138:	6a 05                	push   $0x5
     13a:	68 6a 12 00 00       	push   $0x126a
     13f:	e8 dd 0b 00 00       	call   d21 <shm_get>
     144:	83 c4 10             	add    $0x10,%esp
     147:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if(check3 != 0)
     14a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     14e:	0f 84 b9 00 00 00    	je     20d <main+0x20d>
		{
			printf(0, "Pointer to child get test = %d\n", check3);
     154:	83 ec 04             	sub    $0x4,%esp
     157:	ff 75 e0             	pushl  -0x20(%ebp)
     15a:	68 70 12 00 00       	push   $0x1270
     15f:	6a 00                	push   $0x0
     161:	e8 da 0c 00 00       	call   e40 <printf>
     166:	83 c4 10             	add    $0x10,%esp
			printf(0, "Pointer to child get test.bloop = %d\n", &check3->bloop);
     169:	8b 45 e0             	mov    -0x20(%ebp),%eax
     16c:	83 ec 04             	sub    $0x4,%esp
     16f:	50                   	push   %eax
     170:	68 90 12 00 00       	push   $0x1290
     175:	6a 00                	push   $0x0
     177:	e8 c4 0c 00 00       	call   e40 <printf>
     17c:	83 c4 10             	add    $0x10,%esp
			printf(0, "Pointer to child get test.doop = %d\n", &check3->doop);
     17f:	8b 45 e0             	mov    -0x20(%ebp),%eax
     182:	83 c0 04             	add    $0x4,%eax
     185:	83 ec 04             	sub    $0x4,%esp
     188:	50                   	push   %eax
     189:	68 b8 12 00 00       	push   $0x12b8
     18e:	6a 00                	push   $0x0
     190:	e8 ab 0c 00 00       	call   e40 <printf>
     195:	83 c4 10             	add    $0x10,%esp
			printf(1, "bloop before check3 modified = %d\n", check3->bloop); 
     198:	8b 45 e0             	mov    -0x20(%ebp),%eax
     19b:	8b 00                	mov    (%eax),%eax
     19d:	83 ec 04             	sub    $0x4,%esp
     1a0:	50                   	push   %eax
     1a1:	68 e0 12 00 00       	push   $0x12e0
     1a6:	6a 01                	push   $0x1
     1a8:	e8 93 0c 00 00       	call   e40 <printf>
     1ad:	83 c4 10             	add    $0x10,%esp
			printf(1, "doop before check3 modified = %d\n", check3->doop);
     1b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1b3:	8b 40 04             	mov    0x4(%eax),%eax
     1b6:	83 ec 04             	sub    $0x4,%esp
     1b9:	50                   	push   %eax
     1ba:	68 04 13 00 00       	push   $0x1304
     1bf:	6a 01                	push   $0x1
     1c1:	e8 7a 0c 00 00       	call   e40 <printf>
     1c6:	83 c4 10             	add    $0x10,%esp
			check3->bloop = 87;
     1c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1cc:	c7 00 57 00 00 00    	movl   $0x57,(%eax)
			check3->doop = 29;
     1d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1d5:	c7 40 04 1d 00 00 00 	movl   $0x1d,0x4(%eax)
			printf(1, "bloop after check3 modified = %d\n", check3->bloop);
     1dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1df:	8b 00                	mov    (%eax),%eax
     1e1:	83 ec 04             	sub    $0x4,%esp
     1e4:	50                   	push   %eax
     1e5:	68 28 13 00 00       	push   $0x1328
     1ea:	6a 01                	push   $0x1
     1ec:	e8 4f 0c 00 00       	call   e40 <printf>
     1f1:	83 c4 10             	add    $0x10,%esp
			printf(1, "doop after check3 modified = %d\n", check3->doop);
     1f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1f7:	8b 40 04             	mov    0x4(%eax),%eax
     1fa:	83 ec 04             	sub    $0x4,%esp
     1fd:	50                   	push   %eax
     1fe:	68 4c 13 00 00       	push   $0x134c
     203:	6a 01                	push   $0x1
     205:	e8 36 0c 00 00       	call   e40 <printf>
     20a:	83 c4 10             	add    $0x10,%esp
		}

		for(i=0; i<10; i++)
     20d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     214:	eb 16                	jmp    22c <main+0x22c>
		{
			printf(1, "-");
     216:	83 ec 08             	sub    $0x8,%esp
     219:	68 3f 12 00 00       	push   $0x123f
     21e:	6a 01                	push   $0x1
     220:	e8 1b 0c 00 00       	call   e40 <printf>
     225:	83 c4 10             	add    $0x10,%esp
			check3->doop = 29;
			printf(1, "bloop after check3 modified = %d\n", check3->bloop);
			printf(1, "doop after check3 modified = %d\n", check3->doop);
		}

		for(i=0; i<10; i++)
     228:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     22c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     230:	7e e4                	jle    216 <main+0x216>
		{
			printf(1, "-");
		}

		printf(1,"Test Remove in Child");
     232:	83 ec 08             	sub    $0x8,%esp
     235:	68 6d 13 00 00       	push   $0x136d
     23a:	6a 01                	push   $0x1
     23c:	e8 ff 0b 00 00       	call   e40 <printf>
     241:	83 c4 10             	add    $0x10,%esp

		for(i=0; i<10; i++)
     244:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     24b:	eb 16                	jmp    263 <main+0x263>
		{
			printf(1, "-");
     24d:	83 ec 08             	sub    $0x8,%esp
     250:	68 3f 12 00 00       	push   $0x123f
     255:	6a 01                	push   $0x1
     257:	e8 e4 0b 00 00       	call   e40 <printf>
     25c:	83 c4 10             	add    $0x10,%esp
			printf(1, "-");
		}

		printf(1,"Test Remove in Child");

		for(i=0; i<10; i++)
     25f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     263:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     267:	7e e4                	jle    24d <main+0x24d>
		{
			printf(1, "-");
		}
		
		shm_rem("test", 5);
     269:	83 ec 08             	sub    $0x8,%esp
     26c:	6a 05                	push   $0x5
     26e:	68 6a 12 00 00       	push   $0x126a
     273:	e8 b1 0a 00 00       	call   d29 <shm_rem>
     278:	83 c4 10             	add    $0x10,%esp

		for(i=0; i<10; i++)
     27b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     282:	eb 16                	jmp    29a <main+0x29a>
		{
			printf(1, "-");
     284:	83 ec 08             	sub    $0x8,%esp
     287:	68 3f 12 00 00       	push   $0x123f
     28c:	6a 01                	push   $0x1
     28e:	e8 ad 0b 00 00       	call   e40 <printf>
     293:	83 c4 10             	add    $0x10,%esp
			printf(1, "-");
		}
		
		shm_rem("test", 5);

		for(i=0; i<10; i++)
     296:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     29a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     29e:	7e e4                	jle    284 <main+0x284>
		{
			printf(1, "-");
		}

		printf(1,"Bloop Creation in Child");
     2a0:	83 ec 08             	sub    $0x8,%esp
     2a3:	68 82 13 00 00       	push   $0x1382
     2a8:	6a 01                	push   $0x1
     2aa:	e8 91 0b 00 00       	call   e40 <printf>
     2af:	83 c4 10             	add    $0x10,%esp

		for(i=0; i<10; i++)
     2b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     2b9:	eb 16                	jmp    2d1 <main+0x2d1>
		{
			printf(1, "-");
     2bb:	83 ec 08             	sub    $0x8,%esp
     2be:	68 3f 12 00 00       	push   $0x123f
     2c3:	6a 01                	push   $0x1
     2c5:	e8 76 0b 00 00       	call   e40 <printf>
     2ca:	83 c4 10             	add    $0x10,%esp
			printf(1, "-");
		}

		printf(1,"Bloop Creation in Child");

		for(i=0; i<10; i++)
     2cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     2d1:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     2d5:	7e e4                	jle    2bb <main+0x2bb>
		{
			printf(1, "-");
		}

		printf(0, "\nStarting Check4\n");
     2d7:	83 ec 08             	sub    $0x8,%esp
     2da:	68 9a 13 00 00       	push   $0x139a
     2df:	6a 00                	push   $0x0
     2e1:	e8 5a 0b 00 00       	call   e40 <printf>
     2e6:	83 c4 10             	add    $0x10,%esp
		struct foo* check4 = (struct foo*) shm_get("bloop", 6);
     2e9:	83 ec 08             	sub    $0x8,%esp
     2ec:	6a 06                	push   $0x6
     2ee:	68 ac 13 00 00       	push   $0x13ac
     2f3:	e8 29 0a 00 00       	call   d21 <shm_get>
     2f8:	83 c4 10             	add    $0x10,%esp
     2fb:	89 45 dc             	mov    %eax,-0x24(%ebp)
		if(check4 != 0)
     2fe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
     302:	0f 84 88 00 00 00    	je     390 <main+0x390>
		{
			printf(0, "Pointer to child get test = %d\n", check4);
     308:	83 ec 04             	sub    $0x4,%esp
     30b:	ff 75 dc             	pushl  -0x24(%ebp)
     30e:	68 70 12 00 00       	push   $0x1270
     313:	6a 00                	push   $0x0
     315:	e8 26 0b 00 00       	call   e40 <printf>
     31a:	83 c4 10             	add    $0x10,%esp
			printf(0, "Pointer to child get test.bloop = %d\n", &check4->bloop);
     31d:	8b 45 dc             	mov    -0x24(%ebp),%eax
     320:	83 ec 04             	sub    $0x4,%esp
     323:	50                   	push   %eax
     324:	68 90 12 00 00       	push   $0x1290
     329:	6a 00                	push   $0x0
     32b:	e8 10 0b 00 00       	call   e40 <printf>
     330:	83 c4 10             	add    $0x10,%esp
			printf(0, "Pointer to child get test.doop = %d\n", &check4->doop);
     333:	8b 45 dc             	mov    -0x24(%ebp),%eax
     336:	83 c0 04             	add    $0x4,%eax
     339:	83 ec 04             	sub    $0x4,%esp
     33c:	50                   	push   %eax
     33d:	68 b8 12 00 00       	push   $0x12b8
     342:	6a 00                	push   $0x0
     344:	e8 f7 0a 00 00       	call   e40 <printf>
     349:	83 c4 10             	add    $0x10,%esp
			check4->bloop = 200;
     34c:	8b 45 dc             	mov    -0x24(%ebp),%eax
     34f:	c7 00 c8 00 00 00    	movl   $0xc8,(%eax)
			check4->doop = 890;
     355:	8b 45 dc             	mov    -0x24(%ebp),%eax
     358:	c7 40 04 7a 03 00 00 	movl   $0x37a,0x4(%eax)
			printf(1, "bloop = %d\n", check4->bloop);
     35f:	8b 45 dc             	mov    -0x24(%ebp),%eax
     362:	8b 00                	mov    (%eax),%eax
     364:	83 ec 04             	sub    $0x4,%esp
     367:	50                   	push   %eax
     368:	68 b2 13 00 00       	push   $0x13b2
     36d:	6a 01                	push   $0x1
     36f:	e8 cc 0a 00 00       	call   e40 <printf>
     374:	83 c4 10             	add    $0x10,%esp
			printf(1, "doop = %d\n", check4->doop);
     377:	8b 45 dc             	mov    -0x24(%ebp),%eax
     37a:	8b 40 04             	mov    0x4(%eax),%eax
     37d:	83 ec 04             	sub    $0x4,%esp
     380:	50                   	push   %eax
     381:	68 be 13 00 00       	push   $0x13be
     386:	6a 01                	push   $0x1
     388:	e8 b3 0a 00 00       	call   e40 <printf>
     38d:	83 c4 10             	add    $0x10,%esp
		}

		for(i=0; i<10; i++)
     390:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     397:	eb 16                	jmp    3af <main+0x3af>
		{
			printf(1, "-");
     399:	83 ec 08             	sub    $0x8,%esp
     39c:	68 3f 12 00 00       	push   $0x123f
     3a1:	6a 01                	push   $0x1
     3a3:	e8 98 0a 00 00       	call   e40 <printf>
     3a8:	83 c4 10             	add    $0x10,%esp
			check4->doop = 890;
			printf(1, "bloop = %d\n", check4->bloop);
			printf(1, "doop = %d\n", check4->doop);
		}

		for(i=0; i<10; i++)
     3ab:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     3af:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     3b3:	7e e4                	jle    399 <main+0x399>
		{
			printf(1, "-");
		}

		printf(1,"Bloop Remove in Child");
     3b5:	83 ec 08             	sub    $0x8,%esp
     3b8:	68 c9 13 00 00       	push   $0x13c9
     3bd:	6a 01                	push   $0x1
     3bf:	e8 7c 0a 00 00       	call   e40 <printf>
     3c4:	83 c4 10             	add    $0x10,%esp

		for(i=0; i<10; i++)
     3c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     3ce:	eb 16                	jmp    3e6 <main+0x3e6>
		{
			printf(1, "-");
     3d0:	83 ec 08             	sub    $0x8,%esp
     3d3:	68 3f 12 00 00       	push   $0x123f
     3d8:	6a 01                	push   $0x1
     3da:	e8 61 0a 00 00       	call   e40 <printf>
     3df:	83 c4 10             	add    $0x10,%esp
			printf(1, "-");
		}

		printf(1,"Bloop Remove in Child");

		for(i=0; i<10; i++)
     3e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     3e6:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     3ea:	7e e4                	jle    3d0 <main+0x3d0>
		{
			printf(1, "-");
		}
		
		shm_rem("bloop", 6);
     3ec:	83 ec 08             	sub    $0x8,%esp
     3ef:	6a 06                	push   $0x6
     3f1:	68 ac 13 00 00       	push   $0x13ac
     3f6:	e8 2e 09 00 00       	call   d29 <shm_rem>
     3fb:	83 c4 10             	add    $0x10,%esp

		exit();
     3fe:	e8 7e 08 00 00       	call   c81 <exit>
		return 0;
	}

	if(pid > 0) //in parent
     403:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     407:	0f 8e 18 06 00 00    	jle    a25 <main+0xa25>
	{
		for(i=0; i<10; i++)
     40d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     414:	eb 16                	jmp    42c <main+0x42c>
		{
			printf(1, "+");
     416:	83 ec 08             	sub    $0x8,%esp
     419:	68 09 12 00 00       	push   $0x1209
     41e:	6a 01                	push   $0x1
     420:	e8 1b 0a 00 00       	call   e40 <printf>
     425:	83 c4 10             	add    $0x10,%esp
		return 0;
	}

	if(pid > 0) //in parent
	{
		for(i=0; i<10; i++)
     428:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     42c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     430:	7e e4                	jle    416 <main+0x416>
		{
			printf(1, "+");
		}

		printf(1,"Test Creation in Parent");
     432:	83 ec 08             	sub    $0x8,%esp
     435:	68 df 13 00 00       	push   $0x13df
     43a:	6a 01                	push   $0x1
     43c:	e8 ff 09 00 00       	call   e40 <printf>
     441:	83 c4 10             	add    $0x10,%esp

		for(i=0; i<10; i++)
     444:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     44b:	eb 16                	jmp    463 <main+0x463>
		{
			printf(1, "+");
     44d:	83 ec 08             	sub    $0x8,%esp
     450:	68 09 12 00 00       	push   $0x1209
     455:	6a 01                	push   $0x1
     457:	e8 e4 09 00 00       	call   e40 <printf>
     45c:	83 c4 10             	add    $0x10,%esp
			printf(1, "+");
		}

		printf(1,"Test Creation in Parent");

		for(i=0; i<10; i++)
     45f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     463:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     467:	7e e4                	jle    44d <main+0x44d>
			printf(1, "+");
		}
		
		//Below starred region is for testing SHM made in two separate processes
		
		printf(0, "\nStarting Check1\n");
     469:	83 ec 08             	sub    $0x8,%esp
     46c:	68 f7 13 00 00       	push   $0x13f7
     471:	6a 00                	push   $0x0
     473:	e8 c8 09 00 00       	call   e40 <printf>
     478:	83 c4 10             	add    $0x10,%esp
		struct foo* check = (struct foo*)shm_get("test", 5);
     47b:	83 ec 08             	sub    $0x8,%esp
     47e:	6a 05                	push   $0x5
     480:	68 6a 12 00 00       	push   $0x126a
     485:	e8 97 08 00 00       	call   d21 <shm_get>
     48a:	83 c4 10             	add    $0x10,%esp
     48d:	89 45 e8             	mov    %eax,-0x18(%ebp)
		if(check != 0)
     490:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     494:	0f 84 88 00 00 00    	je     522 <main+0x522>
		{
			printf(0, "Pointer to parent get test = %d\n", check);
     49a:	83 ec 04             	sub    $0x4,%esp
     49d:	ff 75 e8             	pushl  -0x18(%ebp)
     4a0:	68 0c 14 00 00       	push   $0x140c
     4a5:	6a 00                	push   $0x0
     4a7:	e8 94 09 00 00       	call   e40 <printf>
     4ac:	83 c4 10             	add    $0x10,%esp
			printf(0, "Pointer to parent get test.bloop = %d\n", &check->bloop);
     4af:	8b 45 e8             	mov    -0x18(%ebp),%eax
     4b2:	83 ec 04             	sub    $0x4,%esp
     4b5:	50                   	push   %eax
     4b6:	68 30 14 00 00       	push   $0x1430
     4bb:	6a 00                	push   $0x0
     4bd:	e8 7e 09 00 00       	call   e40 <printf>
     4c2:	83 c4 10             	add    $0x10,%esp
			printf(0, "Pointer to parent get test.doop = %d\n", &check->doop);
     4c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
     4c8:	83 c0 04             	add    $0x4,%eax
     4cb:	83 ec 04             	sub    $0x4,%esp
     4ce:	50                   	push   %eax
     4cf:	68 58 14 00 00       	push   $0x1458
     4d4:	6a 00                	push   $0x0
     4d6:	e8 65 09 00 00       	call   e40 <printf>
     4db:	83 c4 10             	add    $0x10,%esp
			check->bloop = 5;
     4de:	8b 45 e8             	mov    -0x18(%ebp),%eax
     4e1:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
			check->doop = 7;
     4e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
     4ea:	c7 40 04 07 00 00 00 	movl   $0x7,0x4(%eax)
			printf(1, "Check 1 bloop = %d\n", check->bloop);
     4f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
     4f4:	8b 00                	mov    (%eax),%eax
     4f6:	83 ec 04             	sub    $0x4,%esp
     4f9:	50                   	push   %eax
     4fa:	68 7e 14 00 00       	push   $0x147e
     4ff:	6a 01                	push   $0x1
     501:	e8 3a 09 00 00       	call   e40 <printf>
     506:	83 c4 10             	add    $0x10,%esp
			printf(1, "Check 1 doop = %d\n", check->doop);
     509:	8b 45 e8             	mov    -0x18(%ebp),%eax
     50c:	8b 40 04             	mov    0x4(%eax),%eax
     50f:	83 ec 04             	sub    $0x4,%esp
     512:	50                   	push   %eax
     513:	68 92 14 00 00       	push   $0x1492
     518:	6a 01                	push   $0x1
     51a:	e8 21 09 00 00       	call   e40 <printf>
     51f:	83 c4 10             	add    $0x10,%esp
		}

		for(i=0; i<10; i++)
     522:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     529:	eb 16                	jmp    541 <main+0x541>
		{
			printf(1, "+");
     52b:	83 ec 08             	sub    $0x8,%esp
     52e:	68 09 12 00 00       	push   $0x1209
     533:	6a 01                	push   $0x1
     535:	e8 06 09 00 00       	call   e40 <printf>
     53a:	83 c4 10             	add    $0x10,%esp
			check->doop = 7;
			printf(1, "Check 1 bloop = %d\n", check->bloop);
			printf(1, "Check 1 doop = %d\n", check->doop);
		}

		for(i=0; i<10; i++)
     53d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     541:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     545:	7e e4                	jle    52b <main+0x52b>
		{
			printf(1, "+");
		}

		printf(1,"Bloop Creation in Parent");
     547:	83 ec 08             	sub    $0x8,%esp
     54a:	68 a5 14 00 00       	push   $0x14a5
     54f:	6a 01                	push   $0x1
     551:	e8 ea 08 00 00       	call   e40 <printf>
     556:	83 c4 10             	add    $0x10,%esp

		for(i=0; i<10; i++)
     559:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     560:	eb 16                	jmp    578 <main+0x578>
		{
			printf(1, "+");
     562:	83 ec 08             	sub    $0x8,%esp
     565:	68 09 12 00 00       	push   $0x1209
     56a:	6a 01                	push   $0x1
     56c:	e8 cf 08 00 00       	call   e40 <printf>
     571:	83 c4 10             	add    $0x10,%esp
			printf(1, "+");
		}

		printf(1,"Bloop Creation in Parent");

		for(i=0; i<10; i++)
     574:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     578:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     57c:	7e e4                	jle    562 <main+0x562>
		{
			printf(1, "+");
		}
	
		printf(0, "\nStarting Check2\n");
     57e:	83 ec 08             	sub    $0x8,%esp
     581:	68 be 14 00 00       	push   $0x14be
     586:	6a 00                	push   $0x0
     588:	e8 b3 08 00 00       	call   e40 <printf>
     58d:	83 c4 10             	add    $0x10,%esp
		struct foo* check2 = (struct foo*) shm_get("bloop", 6);
     590:	83 ec 08             	sub    $0x8,%esp
     593:	6a 06                	push   $0x6
     595:	68 ac 13 00 00       	push   $0x13ac
     59a:	e8 82 07 00 00       	call   d21 <shm_get>
     59f:	83 c4 10             	add    $0x10,%esp
     5a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if(check2 != 0)
     5a5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     5a9:	0f 84 88 00 00 00    	je     637 <main+0x637>
		{
			printf(0, "Pointer to parent get bloop = %d\n", check2);
     5af:	83 ec 04             	sub    $0x4,%esp
     5b2:	ff 75 e4             	pushl  -0x1c(%ebp)
     5b5:	68 d0 14 00 00       	push   $0x14d0
     5ba:	6a 00                	push   $0x0
     5bc:	e8 7f 08 00 00       	call   e40 <printf>
     5c1:	83 c4 10             	add    $0x10,%esp
			printf(0, "Pointer to parent get bloop.bloop = %d\n", &check2->bloop);
     5c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     5c7:	83 ec 04             	sub    $0x4,%esp
     5ca:	50                   	push   %eax
     5cb:	68 f4 14 00 00       	push   $0x14f4
     5d0:	6a 00                	push   $0x0
     5d2:	e8 69 08 00 00       	call   e40 <printf>
     5d7:	83 c4 10             	add    $0x10,%esp
			printf(0, "Pointer to parent get bloop.doop = %d\n", &check2->doop);
     5da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     5dd:	83 c0 04             	add    $0x4,%eax
     5e0:	83 ec 04             	sub    $0x4,%esp
     5e3:	50                   	push   %eax
     5e4:	68 1c 15 00 00       	push   $0x151c
     5e9:	6a 00                	push   $0x0
     5eb:	e8 50 08 00 00       	call   e40 <printf>
     5f0:	83 c4 10             	add    $0x10,%esp
			check2->bloop = 23;
     5f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     5f6:	c7 00 17 00 00 00    	movl   $0x17,(%eax)
			check2->doop = 82;
     5fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     5ff:	c7 40 04 52 00 00 00 	movl   $0x52,0x4(%eax)
			printf(1, "Check 2 bloop = %d\n", check2->bloop);
     606:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     609:	8b 00                	mov    (%eax),%eax
     60b:	83 ec 04             	sub    $0x4,%esp
     60e:	50                   	push   %eax
     60f:	68 43 15 00 00       	push   $0x1543
     614:	6a 01                	push   $0x1
     616:	e8 25 08 00 00       	call   e40 <printf>
     61b:	83 c4 10             	add    $0x10,%esp
			printf(1, "Check 2 doop = %d\n", check2->doop);
     61e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     621:	8b 40 04             	mov    0x4(%eax),%eax
     624:	83 ec 04             	sub    $0x4,%esp
     627:	50                   	push   %eax
     628:	68 57 15 00 00       	push   $0x1557
     62d:	6a 01                	push   $0x1
     62f:	e8 0c 08 00 00       	call   e40 <printf>
     634:	83 c4 10             	add    $0x10,%esp
		}
		
		for(i=0; i<10; i++)
     637:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     63e:	eb 16                	jmp    656 <main+0x656>
		{
			printf(1, "+");
     640:	83 ec 08             	sub    $0x8,%esp
     643:	68 09 12 00 00       	push   $0x1209
     648:	6a 01                	push   $0x1
     64a:	e8 f1 07 00 00       	call   e40 <printf>
     64f:	83 c4 10             	add    $0x10,%esp
			check2->doop = 82;
			printf(1, "Check 2 bloop = %d\n", check2->bloop);
			printf(1, "Check 2 doop = %d\n", check2->doop);
		}
		
		for(i=0; i<10; i++)
     652:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     656:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     65a:	7e e4                	jle    640 <main+0x640>
		{
			printf(1, "+");
		}

		printf(1,"Test Remove in Parent");
     65c:	83 ec 08             	sub    $0x8,%esp
     65f:	68 6a 15 00 00       	push   $0x156a
     664:	6a 01                	push   $0x1
     666:	e8 d5 07 00 00       	call   e40 <printf>
     66b:	83 c4 10             	add    $0x10,%esp

		for(i=0; i<10; i++)
     66e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     675:	eb 16                	jmp    68d <main+0x68d>
		{
			printf(1, "+");
     677:	83 ec 08             	sub    $0x8,%esp
     67a:	68 09 12 00 00       	push   $0x1209
     67f:	6a 01                	push   $0x1
     681:	e8 ba 07 00 00       	call   e40 <printf>
     686:	83 c4 10             	add    $0x10,%esp
			printf(1, "+");
		}

		printf(1,"Test Remove in Parent");

		for(i=0; i<10; i++)
     689:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     68d:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     691:	7e e4                	jle    677 <main+0x677>
		{
			printf(1, "+");
		}

		shm_rem("test", 5);
     693:	83 ec 08             	sub    $0x8,%esp
     696:	6a 05                	push   $0x5
     698:	68 6a 12 00 00       	push   $0x126a
     69d:	e8 87 06 00 00       	call   d29 <shm_rem>
     6a2:	83 c4 10             	add    $0x10,%esp

		wait(); //waits for children to exit
     6a5:	e8 df 05 00 00       	call   c89 <wait>

		//Below checks to see if updates from child can be seen by parent...indicates SHM works.
		//also shows preserving SHM on wait also works

		for(i=0; i<10; i++)
     6aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     6b1:	eb 16                	jmp    6c9 <main+0x6c9>
		{
			printf(1, "+");
     6b3:	83 ec 08             	sub    $0x8,%esp
     6b6:	68 09 12 00 00       	push   $0x1209
     6bb:	6a 01                	push   $0x1
     6bd:	e8 7e 07 00 00       	call   e40 <printf>
     6c2:	83 c4 10             	add    $0x10,%esp
		wait(); //waits for children to exit

		//Below checks to see if updates from child can be seen by parent...indicates SHM works.
		//also shows preserving SHM on wait also works

		for(i=0; i<10; i++)
     6c5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     6c9:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     6cd:	7e e4                	jle    6b3 <main+0x6b3>
		{
			printf(1, "+");
		}

		printf(1,"Test Creation in Parent");
     6cf:	83 ec 08             	sub    $0x8,%esp
     6d2:	68 df 13 00 00       	push   $0x13df
     6d7:	6a 01                	push   $0x1
     6d9:	e8 62 07 00 00       	call   e40 <printf>
     6de:	83 c4 10             	add    $0x10,%esp

		for(i=0; i<10; i++)
     6e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     6e8:	eb 16                	jmp    700 <main+0x700>
		{
			printf(1, "+");
     6ea:	83 ec 08             	sub    $0x8,%esp
     6ed:	68 09 12 00 00       	push   $0x1209
     6f2:	6a 01                	push   $0x1
     6f4:	e8 47 07 00 00       	call   e40 <printf>
     6f9:	83 c4 10             	add    $0x10,%esp
			printf(1, "+");
		}

		printf(1,"Test Creation in Parent");

		for(i=0; i<10; i++)
     6fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     700:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     704:	7e e4                	jle    6ea <main+0x6ea>
		{
			printf(1, "+");
		}

		printf(0, "\nStarting Check5\n"); //problem with remapping here. causing errors
     706:	83 ec 08             	sub    $0x8,%esp
     709:	68 80 15 00 00       	push   $0x1580
     70e:	6a 00                	push   $0x0
     710:	e8 2b 07 00 00       	call   e40 <printf>
     715:	83 c4 10             	add    $0x10,%esp
		check = (struct foo*)shm_get("test", 5);
     718:	83 ec 08             	sub    $0x8,%esp
     71b:	6a 05                	push   $0x5
     71d:	68 6a 12 00 00       	push   $0x126a
     722:	e8 fa 05 00 00       	call   d21 <shm_get>
     727:	83 c4 10             	add    $0x10,%esp
     72a:	89 45 e8             	mov    %eax,-0x18(%ebp)
		if(check != 0)
     72d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     731:	0f 84 88 00 00 00    	je     7bf <main+0x7bf>
		{
			printf(0, "Pointer to parent get test = %d\n", check);
     737:	83 ec 04             	sub    $0x4,%esp
     73a:	ff 75 e8             	pushl  -0x18(%ebp)
     73d:	68 0c 14 00 00       	push   $0x140c
     742:	6a 00                	push   $0x0
     744:	e8 f7 06 00 00       	call   e40 <printf>
     749:	83 c4 10             	add    $0x10,%esp
			printf(0, "Pointer to parent get test.bloop = %d\n", &check->bloop);
     74c:	8b 45 e8             	mov    -0x18(%ebp),%eax
     74f:	83 ec 04             	sub    $0x4,%esp
     752:	50                   	push   %eax
     753:	68 30 14 00 00       	push   $0x1430
     758:	6a 00                	push   $0x0
     75a:	e8 e1 06 00 00       	call   e40 <printf>
     75f:	83 c4 10             	add    $0x10,%esp
			printf(0, "Pointer to parent get test.doop = %d\n", &check->doop);
     762:	8b 45 e8             	mov    -0x18(%ebp),%eax
     765:	83 c0 04             	add    $0x4,%eax
     768:	83 ec 04             	sub    $0x4,%esp
     76b:	50                   	push   %eax
     76c:	68 58 14 00 00       	push   $0x1458
     771:	6a 00                	push   $0x0
     773:	e8 c8 06 00 00       	call   e40 <printf>
     778:	83 c4 10             	add    $0x10,%esp
			check->bloop = 5;
     77b:	8b 45 e8             	mov    -0x18(%ebp),%eax
     77e:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
			check->doop = 7;
     784:	8b 45 e8             	mov    -0x18(%ebp),%eax
     787:	c7 40 04 07 00 00 00 	movl   $0x7,0x4(%eax)
			printf(1, "bloop = %d\n", check->bloop);
     78e:	8b 45 e8             	mov    -0x18(%ebp),%eax
     791:	8b 00                	mov    (%eax),%eax
     793:	83 ec 04             	sub    $0x4,%esp
     796:	50                   	push   %eax
     797:	68 b2 13 00 00       	push   $0x13b2
     79c:	6a 01                	push   $0x1
     79e:	e8 9d 06 00 00       	call   e40 <printf>
     7a3:	83 c4 10             	add    $0x10,%esp
			printf(1, "doop = %d\n", check->doop);
     7a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
     7a9:	8b 40 04             	mov    0x4(%eax),%eax
     7ac:	83 ec 04             	sub    $0x4,%esp
     7af:	50                   	push   %eax
     7b0:	68 be 13 00 00       	push   $0x13be
     7b5:	6a 01                	push   $0x1
     7b7:	e8 84 06 00 00       	call   e40 <printf>
     7bc:	83 c4 10             	add    $0x10,%esp
		}
	
		for(i=0; i<10; i++)
     7bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     7c6:	eb 16                	jmp    7de <main+0x7de>
		{
			printf(1, "+");
     7c8:	83 ec 08             	sub    $0x8,%esp
     7cb:	68 09 12 00 00       	push   $0x1209
     7d0:	6a 01                	push   $0x1
     7d2:	e8 69 06 00 00       	call   e40 <printf>
     7d7:	83 c4 10             	add    $0x10,%esp
			check->doop = 7;
			printf(1, "bloop = %d\n", check->bloop);
			printf(1, "doop = %d\n", check->doop);
		}
	
		for(i=0; i<10; i++)
     7da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     7de:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     7e2:	7e e4                	jle    7c8 <main+0x7c8>
		{
			printf(1, "+");
		}

		printf(1,"Bloop Creation in Parent");
     7e4:	83 ec 08             	sub    $0x8,%esp
     7e7:	68 a5 14 00 00       	push   $0x14a5
     7ec:	6a 01                	push   $0x1
     7ee:	e8 4d 06 00 00       	call   e40 <printf>
     7f3:	83 c4 10             	add    $0x10,%esp

		for(i=0; i<10; i++)
     7f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     7fd:	eb 16                	jmp    815 <main+0x815>
		{
			printf(1, "+");
     7ff:	83 ec 08             	sub    $0x8,%esp
     802:	68 09 12 00 00       	push   $0x1209
     807:	6a 01                	push   $0x1
     809:	e8 32 06 00 00       	call   e40 <printf>
     80e:	83 c4 10             	add    $0x10,%esp
			printf(1, "+");
		}

		printf(1,"Bloop Creation in Parent");

		for(i=0; i<10; i++)
     811:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     815:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     819:	7e e4                	jle    7ff <main+0x7ff>
		{
			printf(1, "+");
		}

		printf(0, "\nStarting Check6\n");
     81b:	83 ec 08             	sub    $0x8,%esp
     81e:	68 92 15 00 00       	push   $0x1592
     823:	6a 00                	push   $0x0
     825:	e8 16 06 00 00       	call   e40 <printf>
     82a:	83 c4 10             	add    $0x10,%esp
		check2 = (struct foo*) shm_get("bloop", 6);
     82d:	83 ec 08             	sub    $0x8,%esp
     830:	6a 06                	push   $0x6
     832:	68 ac 13 00 00       	push   $0x13ac
     837:	e8 e5 04 00 00       	call   d21 <shm_get>
     83c:	83 c4 10             	add    $0x10,%esp
     83f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if(check2 != 0)
     842:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     846:	0f 84 8a 00 00 00    	je     8d6 <main+0x8d6>
		{
			printf(0, "Pointer to parent get bloop = %d\n", check2);
     84c:	83 ec 04             	sub    $0x4,%esp
     84f:	ff 75 e4             	pushl  -0x1c(%ebp)
     852:	68 d0 14 00 00       	push   $0x14d0
     857:	6a 00                	push   $0x0
     859:	e8 e2 05 00 00       	call   e40 <printf>
     85e:	83 c4 10             	add    $0x10,%esp
			printf(0, "Pointer to parent get bloop.bloop = %d\n", check2->bloop);
     861:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     864:	8b 00                	mov    (%eax),%eax
     866:	83 ec 04             	sub    $0x4,%esp
     869:	50                   	push   %eax
     86a:	68 f4 14 00 00       	push   $0x14f4
     86f:	6a 00                	push   $0x0
     871:	e8 ca 05 00 00       	call   e40 <printf>
     876:	83 c4 10             	add    $0x10,%esp
			printf(0, "Pointer to parent get bloop.doop = %d\n", check2->doop);
     879:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     87c:	8b 40 04             	mov    0x4(%eax),%eax
     87f:	83 ec 04             	sub    $0x4,%esp
     882:	50                   	push   %eax
     883:	68 1c 15 00 00       	push   $0x151c
     888:	6a 00                	push   $0x0
     88a:	e8 b1 05 00 00       	call   e40 <printf>
     88f:	83 c4 10             	add    $0x10,%esp
			check2->bloop = 23;
     892:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     895:	c7 00 17 00 00 00    	movl   $0x17,(%eax)
			check2->doop = 82;
     89b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     89e:	c7 40 04 52 00 00 00 	movl   $0x52,0x4(%eax)
			printf(1, "bloop = %d\n", check2->bloop);
     8a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     8a8:	8b 00                	mov    (%eax),%eax
     8aa:	83 ec 04             	sub    $0x4,%esp
     8ad:	50                   	push   %eax
     8ae:	68 b2 13 00 00       	push   $0x13b2
     8b3:	6a 01                	push   $0x1
     8b5:	e8 86 05 00 00       	call   e40 <printf>
     8ba:	83 c4 10             	add    $0x10,%esp
			printf(1, "doop = %d\n", check2->doop);
     8bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     8c0:	8b 40 04             	mov    0x4(%eax),%eax
     8c3:	83 ec 04             	sub    $0x4,%esp
     8c6:	50                   	push   %eax
     8c7:	68 be 13 00 00       	push   $0x13be
     8cc:	6a 01                	push   $0x1
     8ce:	e8 6d 05 00 00       	call   e40 <printf>
     8d3:	83 c4 10             	add    $0x10,%esp
		}

		for(i=0; i<10; i++)
     8d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     8dd:	eb 16                	jmp    8f5 <main+0x8f5>
		{
			printf(1, "+");
     8df:	83 ec 08             	sub    $0x8,%esp
     8e2:	68 09 12 00 00       	push   $0x1209
     8e7:	6a 01                	push   $0x1
     8e9:	e8 52 05 00 00       	call   e40 <printf>
     8ee:	83 c4 10             	add    $0x10,%esp
			check2->doop = 82;
			printf(1, "bloop = %d\n", check2->bloop);
			printf(1, "doop = %d\n", check2->doop);
		}

		for(i=0; i<10; i++)
     8f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     8f5:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     8f9:	7e e4                	jle    8df <main+0x8df>
		{
			printf(1, "+");
		}

		printf(1,"Test Remove in Parent");
     8fb:	83 ec 08             	sub    $0x8,%esp
     8fe:	68 6a 15 00 00       	push   $0x156a
     903:	6a 01                	push   $0x1
     905:	e8 36 05 00 00       	call   e40 <printf>
     90a:	83 c4 10             	add    $0x10,%esp

		for(i=0; i<10; i++)
     90d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     914:	eb 16                	jmp    92c <main+0x92c>
		{
			printf(1, "+");
     916:	83 ec 08             	sub    $0x8,%esp
     919:	68 09 12 00 00       	push   $0x1209
     91e:	6a 01                	push   $0x1
     920:	e8 1b 05 00 00       	call   e40 <printf>
     925:	83 c4 10             	add    $0x10,%esp
			printf(1, "+");
		}

		printf(1,"Test Remove in Parent");

		for(i=0; i<10; i++)
     928:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     92c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     930:	7e e4                	jle    916 <main+0x916>
		{
			printf(1, "+");
		}
		shm_rem("test", 5);
     932:	83 ec 08             	sub    $0x8,%esp
     935:	6a 05                	push   $0x5
     937:	68 6a 12 00 00       	push   $0x126a
     93c:	e8 e8 03 00 00       	call   d29 <shm_rem>
     941:	83 c4 10             	add    $0x10,%esp

		for(i=0; i<10; i++)
     944:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     94b:	eb 16                	jmp    963 <main+0x963>
		{
			printf(1, "+");
     94d:	83 ec 08             	sub    $0x8,%esp
     950:	68 09 12 00 00       	push   $0x1209
     955:	6a 01                	push   $0x1
     957:	e8 e4 04 00 00       	call   e40 <printf>
     95c:	83 c4 10             	add    $0x10,%esp
		{
			printf(1, "+");
		}
		shm_rem("test", 5);

		for(i=0; i<10; i++)
     95f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     963:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     967:	7e e4                	jle    94d <main+0x94d>
		{
			printf(1, "+");
		}

		printf(1,"Response Remove in Parent");
     969:	83 ec 08             	sub    $0x8,%esp
     96c:	68 a4 15 00 00       	push   $0x15a4
     971:	6a 01                	push   $0x1
     973:	e8 c8 04 00 00       	call   e40 <printf>
     978:	83 c4 10             	add    $0x10,%esp

		for(i=0; i<10; i++)
     97b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     982:	eb 16                	jmp    99a <main+0x99a>
		{
			printf(1, "+");
     984:	83 ec 08             	sub    $0x8,%esp
     987:	68 09 12 00 00       	push   $0x1209
     98c:	6a 01                	push   $0x1
     98e:	e8 ad 04 00 00       	call   e40 <printf>
     993:	83 c4 10             	add    $0x10,%esp
			printf(1, "+");
		}

		printf(1,"Response Remove in Parent");

		for(i=0; i<10; i++)
     996:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     99a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     99e:	7e e4                	jle    984 <main+0x984>
		{
			printf(1, "+");
		}
		shm_rem("response", 9);
     9a0:	83 ec 08             	sub    $0x8,%esp
     9a3:	6a 09                	push   $0x9
     9a5:	68 27 12 00 00       	push   $0x1227
     9aa:	e8 7a 03 00 00       	call   d29 <shm_rem>
     9af:	83 c4 10             	add    $0x10,%esp

		for(i=0; i<10; i++)
     9b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     9b9:	eb 16                	jmp    9d1 <main+0x9d1>
		{
			printf(1, "+");
     9bb:	83 ec 08             	sub    $0x8,%esp
     9be:	68 09 12 00 00       	push   $0x1209
     9c3:	6a 01                	push   $0x1
     9c5:	e8 76 04 00 00       	call   e40 <printf>
     9ca:	83 c4 10             	add    $0x10,%esp
		{
			printf(1, "+");
		}
		shm_rem("response", 9);

		for(i=0; i<10; i++)
     9cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     9d1:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     9d5:	7e e4                	jle    9bb <main+0x9bb>
		{
			printf(1, "+");
		}

		printf(1,"Bloop Remove in Parent");
     9d7:	83 ec 08             	sub    $0x8,%esp
     9da:	68 be 15 00 00       	push   $0x15be
     9df:	6a 01                	push   $0x1
     9e1:	e8 5a 04 00 00       	call   e40 <printf>
     9e6:	83 c4 10             	add    $0x10,%esp

		for(i=0; i<10; i++)
     9e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     9f0:	eb 16                	jmp    a08 <main+0xa08>
		{
			printf(1, "+");
     9f2:	83 ec 08             	sub    $0x8,%esp
     9f5:	68 09 12 00 00       	push   $0x1209
     9fa:	6a 01                	push   $0x1
     9fc:	e8 3f 04 00 00       	call   e40 <printf>
     a01:	83 c4 10             	add    $0x10,%esp
			printf(1, "+");
		}

		printf(1,"Bloop Remove in Parent");

		for(i=0; i<10; i++)
     a04:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     a08:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     a0c:	7e e4                	jle    9f2 <main+0x9f2>
		{
			printf(1, "+");
		}

		shm_rem("bloop", 6);
     a0e:	83 ec 08             	sub    $0x8,%esp
     a11:	6a 06                	push   $0x6
     a13:	68 ac 13 00 00       	push   $0x13ac
     a18:	e8 0c 03 00 00       	call   d29 <shm_rem>
     a1d:	83 c4 10             	add    $0x10,%esp

		exit();
     a20:	e8 5c 02 00 00       	call   c81 <exit>
		return 0;
	}
	
	exit();
     a25:	e8 57 02 00 00       	call   c81 <exit>

00000a2a <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     a2a:	55                   	push   %ebp
     a2b:	89 e5                	mov    %esp,%ebp
     a2d:	57                   	push   %edi
     a2e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
     a32:	8b 55 10             	mov    0x10(%ebp),%edx
     a35:	8b 45 0c             	mov    0xc(%ebp),%eax
     a38:	89 cb                	mov    %ecx,%ebx
     a3a:	89 df                	mov    %ebx,%edi
     a3c:	89 d1                	mov    %edx,%ecx
     a3e:	fc                   	cld    
     a3f:	f3 aa                	rep stos %al,%es:(%edi)
     a41:	89 ca                	mov    %ecx,%edx
     a43:	89 fb                	mov    %edi,%ebx
     a45:	89 5d 08             	mov    %ebx,0x8(%ebp)
     a48:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     a4b:	90                   	nop
     a4c:	5b                   	pop    %ebx
     a4d:	5f                   	pop    %edi
     a4e:	5d                   	pop    %ebp
     a4f:	c3                   	ret    

00000a50 <strcpy>:
#include "fcntl.h"
#include "user.h"
#include "x86.h"

char *strcpy(char *s, char *t)
{
     a50:	55                   	push   %ebp
     a51:	89 e5                	mov    %esp,%ebp
     a53:	83 ec 10             	sub    $0x10,%esp
	char *os;

	os = s;
     a56:	8b 45 08             	mov    0x8(%ebp),%eax
     a59:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*s++ = *t++) != 0) ;
     a5c:	90                   	nop
     a5d:	8b 45 08             	mov    0x8(%ebp),%eax
     a60:	8d 50 01             	lea    0x1(%eax),%edx
     a63:	89 55 08             	mov    %edx,0x8(%ebp)
     a66:	8b 55 0c             	mov    0xc(%ebp),%edx
     a69:	8d 4a 01             	lea    0x1(%edx),%ecx
     a6c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     a6f:	0f b6 12             	movzbl (%edx),%edx
     a72:	88 10                	mov    %dl,(%eax)
     a74:	0f b6 00             	movzbl (%eax),%eax
     a77:	84 c0                	test   %al,%al
     a79:	75 e2                	jne    a5d <strcpy+0xd>
	return os;
     a7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     a7e:	c9                   	leave  
     a7f:	c3                   	ret    

00000a80 <strcmp>:

int strcmp(const char *p, const char *q)
{
     a80:	55                   	push   %ebp
     a81:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
     a83:	eb 08                	jmp    a8d <strcmp+0xd>
		p++, q++;
     a85:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     a89:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	return os;
}

int strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
     a8d:	8b 45 08             	mov    0x8(%ebp),%eax
     a90:	0f b6 00             	movzbl (%eax),%eax
     a93:	84 c0                	test   %al,%al
     a95:	74 10                	je     aa7 <strcmp+0x27>
     a97:	8b 45 08             	mov    0x8(%ebp),%eax
     a9a:	0f b6 10             	movzbl (%eax),%edx
     a9d:	8b 45 0c             	mov    0xc(%ebp),%eax
     aa0:	0f b6 00             	movzbl (%eax),%eax
     aa3:	38 c2                	cmp    %al,%dl
     aa5:	74 de                	je     a85 <strcmp+0x5>
		p++, q++;
	return (uchar) * p - (uchar) * q;
     aa7:	8b 45 08             	mov    0x8(%ebp),%eax
     aaa:	0f b6 00             	movzbl (%eax),%eax
     aad:	0f b6 d0             	movzbl %al,%edx
     ab0:	8b 45 0c             	mov    0xc(%ebp),%eax
     ab3:	0f b6 00             	movzbl (%eax),%eax
     ab6:	0f b6 c0             	movzbl %al,%eax
     ab9:	29 c2                	sub    %eax,%edx
     abb:	89 d0                	mov    %edx,%eax
}
     abd:	5d                   	pop    %ebp
     abe:	c3                   	ret    

00000abf <strlen>:

uint strlen(char *s)
{
     abf:	55                   	push   %ebp
     ac0:	89 e5                	mov    %esp,%ebp
     ac2:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; s[n]; n++) ;
     ac5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     acc:	eb 04                	jmp    ad2 <strlen+0x13>
     ace:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     ad2:	8b 55 fc             	mov    -0x4(%ebp),%edx
     ad5:	8b 45 08             	mov    0x8(%ebp),%eax
     ad8:	01 d0                	add    %edx,%eax
     ada:	0f b6 00             	movzbl (%eax),%eax
     add:	84 c0                	test   %al,%al
     adf:	75 ed                	jne    ace <strlen+0xf>
	return n;
     ae1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     ae4:	c9                   	leave  
     ae5:	c3                   	ret    

00000ae6 <memset>:

void *memset(void *dst, int c, uint n)
{
     ae6:	55                   	push   %ebp
     ae7:	89 e5                	mov    %esp,%ebp
	stosb(dst, c, n);
     ae9:	8b 45 10             	mov    0x10(%ebp),%eax
     aec:	50                   	push   %eax
     aed:	ff 75 0c             	pushl  0xc(%ebp)
     af0:	ff 75 08             	pushl  0x8(%ebp)
     af3:	e8 32 ff ff ff       	call   a2a <stosb>
     af8:	83 c4 0c             	add    $0xc,%esp
	return dst;
     afb:	8b 45 08             	mov    0x8(%ebp),%eax
}
     afe:	c9                   	leave  
     aff:	c3                   	ret    

00000b00 <strchr>:

char *strchr(const char *s, char c)
{
     b00:	55                   	push   %ebp
     b01:	89 e5                	mov    %esp,%ebp
     b03:	83 ec 04             	sub    $0x4,%esp
     b06:	8b 45 0c             	mov    0xc(%ebp),%eax
     b09:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
     b0c:	eb 14                	jmp    b22 <strchr+0x22>
		if (*s == c)
     b0e:	8b 45 08             	mov    0x8(%ebp),%eax
     b11:	0f b6 00             	movzbl (%eax),%eax
     b14:	3a 45 fc             	cmp    -0x4(%ebp),%al
     b17:	75 05                	jne    b1e <strchr+0x1e>
			return (char *)s;
     b19:	8b 45 08             	mov    0x8(%ebp),%eax
     b1c:	eb 13                	jmp    b31 <strchr+0x31>
	return dst;
}

char *strchr(const char *s, char c)
{
	for (; *s; s++)
     b1e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     b22:	8b 45 08             	mov    0x8(%ebp),%eax
     b25:	0f b6 00             	movzbl (%eax),%eax
     b28:	84 c0                	test   %al,%al
     b2a:	75 e2                	jne    b0e <strchr+0xe>
		if (*s == c)
			return (char *)s;
	return 0;
     b2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
     b31:	c9                   	leave  
     b32:	c3                   	ret    

00000b33 <gets>:

char *gets(char *buf, int max)
{
     b33:	55                   	push   %ebp
     b34:	89 e5                	mov    %esp,%ebp
     b36:	83 ec 18             	sub    $0x18,%esp
	int i, cc;
	char c;

	for (i = 0; i + 1 < max;) {
     b39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     b40:	eb 42                	jmp    b84 <gets+0x51>
		cc = read(0, &c, 1);
     b42:	83 ec 04             	sub    $0x4,%esp
     b45:	6a 01                	push   $0x1
     b47:	8d 45 ef             	lea    -0x11(%ebp),%eax
     b4a:	50                   	push   %eax
     b4b:	6a 00                	push   $0x0
     b4d:	e8 47 01 00 00       	call   c99 <read>
     b52:	83 c4 10             	add    $0x10,%esp
     b55:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (cc < 1)
     b58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     b5c:	7e 33                	jle    b91 <gets+0x5e>
			break;
		buf[i++] = c;
     b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b61:	8d 50 01             	lea    0x1(%eax),%edx
     b64:	89 55 f4             	mov    %edx,-0xc(%ebp)
     b67:	89 c2                	mov    %eax,%edx
     b69:	8b 45 08             	mov    0x8(%ebp),%eax
     b6c:	01 c2                	add    %eax,%edx
     b6e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     b72:	88 02                	mov    %al,(%edx)
		if (c == '\n' || c == '\r')
     b74:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     b78:	3c 0a                	cmp    $0xa,%al
     b7a:	74 16                	je     b92 <gets+0x5f>
     b7c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     b80:	3c 0d                	cmp    $0xd,%al
     b82:	74 0e                	je     b92 <gets+0x5f>
char *gets(char *buf, int max)
{
	int i, cc;
	char c;

	for (i = 0; i + 1 < max;) {
     b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b87:	83 c0 01             	add    $0x1,%eax
     b8a:	3b 45 0c             	cmp    0xc(%ebp),%eax
     b8d:	7c b3                	jl     b42 <gets+0xf>
     b8f:	eb 01                	jmp    b92 <gets+0x5f>
		cc = read(0, &c, 1);
		if (cc < 1)
			break;
     b91:	90                   	nop
		buf[i++] = c;
		if (c == '\n' || c == '\r')
			break;
	}
	buf[i] = '\0';
     b92:	8b 55 f4             	mov    -0xc(%ebp),%edx
     b95:	8b 45 08             	mov    0x8(%ebp),%eax
     b98:	01 d0                	add    %edx,%eax
     b9a:	c6 00 00             	movb   $0x0,(%eax)
	return buf;
     b9d:	8b 45 08             	mov    0x8(%ebp),%eax
}
     ba0:	c9                   	leave  
     ba1:	c3                   	ret    

00000ba2 <stat>:

int stat(char *n, struct stat *st)
{
     ba2:	55                   	push   %ebp
     ba3:	89 e5                	mov    %esp,%ebp
     ba5:	83 ec 18             	sub    $0x18,%esp
	int fd;
	int r;

	fd = open(n, O_RDONLY);
     ba8:	83 ec 08             	sub    $0x8,%esp
     bab:	6a 00                	push   $0x0
     bad:	ff 75 08             	pushl  0x8(%ebp)
     bb0:	e8 0c 01 00 00       	call   cc1 <open>
     bb5:	83 c4 10             	add    $0x10,%esp
     bb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (fd < 0)
     bbb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     bbf:	79 07                	jns    bc8 <stat+0x26>
		return -1;
     bc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     bc6:	eb 25                	jmp    bed <stat+0x4b>
	r = fstat(fd, st);
     bc8:	83 ec 08             	sub    $0x8,%esp
     bcb:	ff 75 0c             	pushl  0xc(%ebp)
     bce:	ff 75 f4             	pushl  -0xc(%ebp)
     bd1:	e8 03 01 00 00       	call   cd9 <fstat>
     bd6:	83 c4 10             	add    $0x10,%esp
     bd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	close(fd);
     bdc:	83 ec 0c             	sub    $0xc,%esp
     bdf:	ff 75 f4             	pushl  -0xc(%ebp)
     be2:	e8 c2 00 00 00       	call   ca9 <close>
     be7:	83 c4 10             	add    $0x10,%esp
	return r;
     bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     bed:	c9                   	leave  
     bee:	c3                   	ret    

00000bef <atoi>:

int atoi(const char *s)
{
     bef:	55                   	push   %ebp
     bf0:	89 e5                	mov    %esp,%ebp
     bf2:	83 ec 10             	sub    $0x10,%esp
	int n;

	n = 0;
     bf5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	while ('0' <= *s && *s <= '9')
     bfc:	eb 25                	jmp    c23 <atoi+0x34>
		n = n * 10 + *s++ - '0';
     bfe:	8b 55 fc             	mov    -0x4(%ebp),%edx
     c01:	89 d0                	mov    %edx,%eax
     c03:	c1 e0 02             	shl    $0x2,%eax
     c06:	01 d0                	add    %edx,%eax
     c08:	01 c0                	add    %eax,%eax
     c0a:	89 c1                	mov    %eax,%ecx
     c0c:	8b 45 08             	mov    0x8(%ebp),%eax
     c0f:	8d 50 01             	lea    0x1(%eax),%edx
     c12:	89 55 08             	mov    %edx,0x8(%ebp)
     c15:	0f b6 00             	movzbl (%eax),%eax
     c18:	0f be c0             	movsbl %al,%eax
     c1b:	01 c8                	add    %ecx,%eax
     c1d:	83 e8 30             	sub    $0x30,%eax
     c20:	89 45 fc             	mov    %eax,-0x4(%ebp)
int atoi(const char *s)
{
	int n;

	n = 0;
	while ('0' <= *s && *s <= '9')
     c23:	8b 45 08             	mov    0x8(%ebp),%eax
     c26:	0f b6 00             	movzbl (%eax),%eax
     c29:	3c 2f                	cmp    $0x2f,%al
     c2b:	7e 0a                	jle    c37 <atoi+0x48>
     c2d:	8b 45 08             	mov    0x8(%ebp),%eax
     c30:	0f b6 00             	movzbl (%eax),%eax
     c33:	3c 39                	cmp    $0x39,%al
     c35:	7e c7                	jle    bfe <atoi+0xf>
		n = n * 10 + *s++ - '0';
	return n;
     c37:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     c3a:	c9                   	leave  
     c3b:	c3                   	ret    

00000c3c <memmove>:

void *memmove(void *vdst, void *vsrc, int n)
{
     c3c:	55                   	push   %ebp
     c3d:	89 e5                	mov    %esp,%ebp
     c3f:	83 ec 10             	sub    $0x10,%esp
	char *dst, *src;

	dst = vdst;
     c42:	8b 45 08             	mov    0x8(%ebp),%eax
     c45:	89 45 fc             	mov    %eax,-0x4(%ebp)
	src = vsrc;
     c48:	8b 45 0c             	mov    0xc(%ebp),%eax
     c4b:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
     c4e:	eb 17                	jmp    c67 <memmove+0x2b>
		*dst++ = *src++;
     c50:	8b 45 fc             	mov    -0x4(%ebp),%eax
     c53:	8d 50 01             	lea    0x1(%eax),%edx
     c56:	89 55 fc             	mov    %edx,-0x4(%ebp)
     c59:	8b 55 f8             	mov    -0x8(%ebp),%edx
     c5c:	8d 4a 01             	lea    0x1(%edx),%ecx
     c5f:	89 4d f8             	mov    %ecx,-0x8(%ebp)
     c62:	0f b6 12             	movzbl (%edx),%edx
     c65:	88 10                	mov    %dl,(%eax)
{
	char *dst, *src;

	dst = vdst;
	src = vsrc;
	while (n-- > 0)
     c67:	8b 45 10             	mov    0x10(%ebp),%eax
     c6a:	8d 50 ff             	lea    -0x1(%eax),%edx
     c6d:	89 55 10             	mov    %edx,0x10(%ebp)
     c70:	85 c0                	test   %eax,%eax
     c72:	7f dc                	jg     c50 <memmove+0x14>
		*dst++ = *src++;
	return vdst;
     c74:	8b 45 08             	mov    0x8(%ebp),%eax
}
     c77:	c9                   	leave  
     c78:	c3                   	ret    

00000c79 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     c79:	b8 01 00 00 00       	mov    $0x1,%eax
     c7e:	cd 40                	int    $0x40
     c80:	c3                   	ret    

00000c81 <exit>:
SYSCALL(exit)
     c81:	b8 02 00 00 00       	mov    $0x2,%eax
     c86:	cd 40                	int    $0x40
     c88:	c3                   	ret    

00000c89 <wait>:
SYSCALL(wait)
     c89:	b8 03 00 00 00       	mov    $0x3,%eax
     c8e:	cd 40                	int    $0x40
     c90:	c3                   	ret    

00000c91 <pipe>:
SYSCALL(pipe)
     c91:	b8 04 00 00 00       	mov    $0x4,%eax
     c96:	cd 40                	int    $0x40
     c98:	c3                   	ret    

00000c99 <read>:
SYSCALL(read)
     c99:	b8 05 00 00 00       	mov    $0x5,%eax
     c9e:	cd 40                	int    $0x40
     ca0:	c3                   	ret    

00000ca1 <write>:
SYSCALL(write)
     ca1:	b8 10 00 00 00       	mov    $0x10,%eax
     ca6:	cd 40                	int    $0x40
     ca8:	c3                   	ret    

00000ca9 <close>:
SYSCALL(close)
     ca9:	b8 15 00 00 00       	mov    $0x15,%eax
     cae:	cd 40                	int    $0x40
     cb0:	c3                   	ret    

00000cb1 <kill>:
SYSCALL(kill)
     cb1:	b8 06 00 00 00       	mov    $0x6,%eax
     cb6:	cd 40                	int    $0x40
     cb8:	c3                   	ret    

00000cb9 <exec>:
SYSCALL(exec)
     cb9:	b8 07 00 00 00       	mov    $0x7,%eax
     cbe:	cd 40                	int    $0x40
     cc0:	c3                   	ret    

00000cc1 <open>:
SYSCALL(open)
     cc1:	b8 0f 00 00 00       	mov    $0xf,%eax
     cc6:	cd 40                	int    $0x40
     cc8:	c3                   	ret    

00000cc9 <mknod>:
SYSCALL(mknod)
     cc9:	b8 11 00 00 00       	mov    $0x11,%eax
     cce:	cd 40                	int    $0x40
     cd0:	c3                   	ret    

00000cd1 <unlink>:
SYSCALL(unlink)
     cd1:	b8 12 00 00 00       	mov    $0x12,%eax
     cd6:	cd 40                	int    $0x40
     cd8:	c3                   	ret    

00000cd9 <fstat>:
SYSCALL(fstat)
     cd9:	b8 08 00 00 00       	mov    $0x8,%eax
     cde:	cd 40                	int    $0x40
     ce0:	c3                   	ret    

00000ce1 <link>:
SYSCALL(link)
     ce1:	b8 13 00 00 00       	mov    $0x13,%eax
     ce6:	cd 40                	int    $0x40
     ce8:	c3                   	ret    

00000ce9 <mkdir>:
SYSCALL(mkdir)
     ce9:	b8 14 00 00 00       	mov    $0x14,%eax
     cee:	cd 40                	int    $0x40
     cf0:	c3                   	ret    

00000cf1 <chdir>:
SYSCALL(chdir)
     cf1:	b8 09 00 00 00       	mov    $0x9,%eax
     cf6:	cd 40                	int    $0x40
     cf8:	c3                   	ret    

00000cf9 <dup>:
SYSCALL(dup)
     cf9:	b8 0a 00 00 00       	mov    $0xa,%eax
     cfe:	cd 40                	int    $0x40
     d00:	c3                   	ret    

00000d01 <getpid>:
SYSCALL(getpid)
     d01:	b8 0b 00 00 00       	mov    $0xb,%eax
     d06:	cd 40                	int    $0x40
     d08:	c3                   	ret    

00000d09 <sbrk>:
SYSCALL(sbrk)
     d09:	b8 0c 00 00 00       	mov    $0xc,%eax
     d0e:	cd 40                	int    $0x40
     d10:	c3                   	ret    

00000d11 <sleep>:
SYSCALL(sleep)
     d11:	b8 0d 00 00 00       	mov    $0xd,%eax
     d16:	cd 40                	int    $0x40
     d18:	c3                   	ret    

00000d19 <uptime>:
SYSCALL(uptime)
     d19:	b8 0e 00 00 00       	mov    $0xe,%eax
     d1e:	cd 40                	int    $0x40
     d20:	c3                   	ret    

00000d21 <shm_get>:
SYSCALL(shm_get) //mod2
     d21:	b8 1c 00 00 00       	mov    $0x1c,%eax
     d26:	cd 40                	int    $0x40
     d28:	c3                   	ret    

00000d29 <shm_rem>:
SYSCALL(shm_rem) //mod2
     d29:	b8 1d 00 00 00       	mov    $0x1d,%eax
     d2e:	cd 40                	int    $0x40
     d30:	c3                   	ret    

00000d31 <setHighPrio>:
SYSCALL(setHighPrio) //scheduler
     d31:	b8 1e 00 00 00       	mov    $0x1e,%eax
     d36:	cd 40                	int    $0x40
     d38:	c3                   	ret    

00000d39 <mutex_create>:
SYSCALL(mutex_create)//mod3
     d39:	b8 16 00 00 00       	mov    $0x16,%eax
     d3e:	cd 40                	int    $0x40
     d40:	c3                   	ret    

00000d41 <mutex_delete>:
SYSCALL(mutex_delete)
     d41:	b8 17 00 00 00       	mov    $0x17,%eax
     d46:	cd 40                	int    $0x40
     d48:	c3                   	ret    

00000d49 <mutex_lock>:
SYSCALL(mutex_lock)
     d49:	b8 18 00 00 00       	mov    $0x18,%eax
     d4e:	cd 40                	int    $0x40
     d50:	c3                   	ret    

00000d51 <mutex_unlock>:
SYSCALL(mutex_unlock)
     d51:	b8 19 00 00 00       	mov    $0x19,%eax
     d56:	cd 40                	int    $0x40
     d58:	c3                   	ret    

00000d59 <cv_wait>:
SYSCALL(cv_wait)
     d59:	b8 1a 00 00 00       	mov    $0x1a,%eax
     d5e:	cd 40                	int    $0x40
     d60:	c3                   	ret    

00000d61 <cv_signal>:
SYSCALL(cv_signal)
     d61:	b8 1b 00 00 00       	mov    $0x1b,%eax
     d66:	cd 40                	int    $0x40
     d68:	c3                   	ret    

00000d69 <putc>:
#include "types.h"
#include "stat.h"
#include "user.h"

static void putc(int fd, char c)
{
     d69:	55                   	push   %ebp
     d6a:	89 e5                	mov    %esp,%ebp
     d6c:	83 ec 18             	sub    $0x18,%esp
     d6f:	8b 45 0c             	mov    0xc(%ebp),%eax
     d72:	88 45 f4             	mov    %al,-0xc(%ebp)
	write(fd, &c, 1);
     d75:	83 ec 04             	sub    $0x4,%esp
     d78:	6a 01                	push   $0x1
     d7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
     d7d:	50                   	push   %eax
     d7e:	ff 75 08             	pushl  0x8(%ebp)
     d81:	e8 1b ff ff ff       	call   ca1 <write>
     d86:	83 c4 10             	add    $0x10,%esp
}
     d89:	90                   	nop
     d8a:	c9                   	leave  
     d8b:	c3                   	ret    

00000d8c <printint>:

static void printint(int fd, int xx, int base, int sgn)
{
     d8c:	55                   	push   %ebp
     d8d:	89 e5                	mov    %esp,%ebp
     d8f:	53                   	push   %ebx
     d90:	83 ec 24             	sub    $0x24,%esp
	static char digits[] = "0123456789ABCDEF";
	char buf[16];
	int i, neg;
	uint x;

	neg = 0;
     d93:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	if (sgn && xx < 0) {
     d9a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     d9e:	74 17                	je     db7 <printint+0x2b>
     da0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
     da4:	79 11                	jns    db7 <printint+0x2b>
		neg = 1;
     da6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
		x = -xx;
     dad:	8b 45 0c             	mov    0xc(%ebp),%eax
     db0:	f7 d8                	neg    %eax
     db2:	89 45 ec             	mov    %eax,-0x14(%ebp)
     db5:	eb 06                	jmp    dbd <printint+0x31>
	} else {
		x = xx;
     db7:	8b 45 0c             	mov    0xc(%ebp),%eax
     dba:	89 45 ec             	mov    %eax,-0x14(%ebp)
	}

	i = 0;
     dbd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	do {
		buf[i++] = digits[x % base];
     dc4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     dc7:	8d 41 01             	lea    0x1(%ecx),%eax
     dca:	89 45 f4             	mov    %eax,-0xc(%ebp)
     dcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
     dd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
     dd3:	ba 00 00 00 00       	mov    $0x0,%edx
     dd8:	f7 f3                	div    %ebx
     dda:	89 d0                	mov    %edx,%eax
     ddc:	0f b6 80 24 18 00 00 	movzbl 0x1824(%eax),%eax
     de3:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
	} while ((x /= base) != 0);
     de7:	8b 5d 10             	mov    0x10(%ebp),%ebx
     dea:	8b 45 ec             	mov    -0x14(%ebp),%eax
     ded:	ba 00 00 00 00       	mov    $0x0,%edx
     df2:	f7 f3                	div    %ebx
     df4:	89 45 ec             	mov    %eax,-0x14(%ebp)
     df7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     dfb:	75 c7                	jne    dc4 <printint+0x38>
	if (neg)
     dfd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     e01:	74 2d                	je     e30 <printint+0xa4>
		buf[i++] = '-';
     e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e06:	8d 50 01             	lea    0x1(%eax),%edx
     e09:	89 55 f4             	mov    %edx,-0xc(%ebp)
     e0c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

	while (--i >= 0)
     e11:	eb 1d                	jmp    e30 <printint+0xa4>
		putc(fd, buf[i]);
     e13:	8d 55 dc             	lea    -0x24(%ebp),%edx
     e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e19:	01 d0                	add    %edx,%eax
     e1b:	0f b6 00             	movzbl (%eax),%eax
     e1e:	0f be c0             	movsbl %al,%eax
     e21:	83 ec 08             	sub    $0x8,%esp
     e24:	50                   	push   %eax
     e25:	ff 75 08             	pushl  0x8(%ebp)
     e28:	e8 3c ff ff ff       	call   d69 <putc>
     e2d:	83 c4 10             	add    $0x10,%esp
		buf[i++] = digits[x % base];
	} while ((x /= base) != 0);
	if (neg)
		buf[i++] = '-';

	while (--i >= 0)
     e30:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
     e34:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     e38:	79 d9                	jns    e13 <printint+0x87>
		putc(fd, buf[i]);
}
     e3a:	90                   	nop
     e3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     e3e:	c9                   	leave  
     e3f:	c3                   	ret    

00000e40 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void printf(int fd, char *fmt, ...)
{
     e40:	55                   	push   %ebp
     e41:	89 e5                	mov    %esp,%ebp
     e43:	83 ec 28             	sub    $0x28,%esp
	char *s;
	int c, i, state;
	uint *ap;

	state = 0;
     e46:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	ap = (uint *) (void *)&fmt + 1;
     e4d:	8d 45 0c             	lea    0xc(%ebp),%eax
     e50:	83 c0 04             	add    $0x4,%eax
     e53:	89 45 e8             	mov    %eax,-0x18(%ebp)
	for (i = 0; fmt[i]; i++) {
     e56:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     e5d:	e9 59 01 00 00       	jmp    fbb <printf+0x17b>
		c = fmt[i] & 0xff;
     e62:	8b 55 0c             	mov    0xc(%ebp),%edx
     e65:	8b 45 f0             	mov    -0x10(%ebp),%eax
     e68:	01 d0                	add    %edx,%eax
     e6a:	0f b6 00             	movzbl (%eax),%eax
     e6d:	0f be c0             	movsbl %al,%eax
     e70:	25 ff 00 00 00       	and    $0xff,%eax
     e75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (state == 0) {
     e78:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     e7c:	75 2c                	jne    eaa <printf+0x6a>
			if (c == '%') {
     e7e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
     e82:	75 0c                	jne    e90 <printf+0x50>
				state = '%';
     e84:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
     e8b:	e9 27 01 00 00       	jmp    fb7 <printf+0x177>
			} else {
				putc(fd, c);
     e90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     e93:	0f be c0             	movsbl %al,%eax
     e96:	83 ec 08             	sub    $0x8,%esp
     e99:	50                   	push   %eax
     e9a:	ff 75 08             	pushl  0x8(%ebp)
     e9d:	e8 c7 fe ff ff       	call   d69 <putc>
     ea2:	83 c4 10             	add    $0x10,%esp
     ea5:	e9 0d 01 00 00       	jmp    fb7 <printf+0x177>
			}
		} else if (state == '%') {
     eaa:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
     eae:	0f 85 03 01 00 00    	jne    fb7 <printf+0x177>
			if (c == 'd') {
     eb4:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
     eb8:	75 1e                	jne    ed8 <printf+0x98>
				printint(fd, *ap, 10, 1);
     eba:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ebd:	8b 00                	mov    (%eax),%eax
     ebf:	6a 01                	push   $0x1
     ec1:	6a 0a                	push   $0xa
     ec3:	50                   	push   %eax
     ec4:	ff 75 08             	pushl  0x8(%ebp)
     ec7:	e8 c0 fe ff ff       	call   d8c <printint>
     ecc:	83 c4 10             	add    $0x10,%esp
				ap++;
     ecf:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
     ed3:	e9 d8 00 00 00       	jmp    fb0 <printf+0x170>
			} else if (c == 'x' || c == 'p') {
     ed8:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
     edc:	74 06                	je     ee4 <printf+0xa4>
     ede:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
     ee2:	75 1e                	jne    f02 <printf+0xc2>
				printint(fd, *ap, 16, 0);
     ee4:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ee7:	8b 00                	mov    (%eax),%eax
     ee9:	6a 00                	push   $0x0
     eeb:	6a 10                	push   $0x10
     eed:	50                   	push   %eax
     eee:	ff 75 08             	pushl  0x8(%ebp)
     ef1:	e8 96 fe ff ff       	call   d8c <printint>
     ef6:	83 c4 10             	add    $0x10,%esp
				ap++;
     ef9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
     efd:	e9 ae 00 00 00       	jmp    fb0 <printf+0x170>
			} else if (c == 's') {
     f02:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
     f06:	75 43                	jne    f4b <printf+0x10b>
				s = (char *)*ap;
     f08:	8b 45 e8             	mov    -0x18(%ebp),%eax
     f0b:	8b 00                	mov    (%eax),%eax
     f0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
				ap++;
     f10:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
				if (s == 0)
     f14:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     f18:	75 25                	jne    f3f <printf+0xff>
					s = "(null)";
     f1a:	c7 45 f4 d5 15 00 00 	movl   $0x15d5,-0xc(%ebp)
				while (*s != 0) {
     f21:	eb 1c                	jmp    f3f <printf+0xff>
					putc(fd, *s);
     f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f26:	0f b6 00             	movzbl (%eax),%eax
     f29:	0f be c0             	movsbl %al,%eax
     f2c:	83 ec 08             	sub    $0x8,%esp
     f2f:	50                   	push   %eax
     f30:	ff 75 08             	pushl  0x8(%ebp)
     f33:	e8 31 fe ff ff       	call   d69 <putc>
     f38:	83 c4 10             	add    $0x10,%esp
					s++;
     f3b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
			} else if (c == 's') {
				s = (char *)*ap;
				ap++;
				if (s == 0)
					s = "(null)";
				while (*s != 0) {
     f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f42:	0f b6 00             	movzbl (%eax),%eax
     f45:	84 c0                	test   %al,%al
     f47:	75 da                	jne    f23 <printf+0xe3>
     f49:	eb 65                	jmp    fb0 <printf+0x170>
					putc(fd, *s);
					s++;
				}
			} else if (c == 'c') {
     f4b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
     f4f:	75 1d                	jne    f6e <printf+0x12e>
				putc(fd, *ap);
     f51:	8b 45 e8             	mov    -0x18(%ebp),%eax
     f54:	8b 00                	mov    (%eax),%eax
     f56:	0f be c0             	movsbl %al,%eax
     f59:	83 ec 08             	sub    $0x8,%esp
     f5c:	50                   	push   %eax
     f5d:	ff 75 08             	pushl  0x8(%ebp)
     f60:	e8 04 fe ff ff       	call   d69 <putc>
     f65:	83 c4 10             	add    $0x10,%esp
				ap++;
     f68:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
     f6c:	eb 42                	jmp    fb0 <printf+0x170>
			} else if (c == '%') {
     f6e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
     f72:	75 17                	jne    f8b <printf+0x14b>
				putc(fd, c);
     f74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     f77:	0f be c0             	movsbl %al,%eax
     f7a:	83 ec 08             	sub    $0x8,%esp
     f7d:	50                   	push   %eax
     f7e:	ff 75 08             	pushl  0x8(%ebp)
     f81:	e8 e3 fd ff ff       	call   d69 <putc>
     f86:	83 c4 10             	add    $0x10,%esp
     f89:	eb 25                	jmp    fb0 <printf+0x170>
			} else {
				// Unknown % sequence.  Print it to draw attention.
				putc(fd, '%');
     f8b:	83 ec 08             	sub    $0x8,%esp
     f8e:	6a 25                	push   $0x25
     f90:	ff 75 08             	pushl  0x8(%ebp)
     f93:	e8 d1 fd ff ff       	call   d69 <putc>
     f98:	83 c4 10             	add    $0x10,%esp
				putc(fd, c);
     f9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     f9e:	0f be c0             	movsbl %al,%eax
     fa1:	83 ec 08             	sub    $0x8,%esp
     fa4:	50                   	push   %eax
     fa5:	ff 75 08             	pushl  0x8(%ebp)
     fa8:	e8 bc fd ff ff       	call   d69 <putc>
     fad:	83 c4 10             	add    $0x10,%esp
			}
			state = 0;
     fb0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int c, i, state;
	uint *ap;

	state = 0;
	ap = (uint *) (void *)&fmt + 1;
	for (i = 0; fmt[i]; i++) {
     fb7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     fbb:	8b 55 0c             	mov    0xc(%ebp),%edx
     fbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
     fc1:	01 d0                	add    %edx,%eax
     fc3:	0f b6 00             	movzbl (%eax),%eax
     fc6:	84 c0                	test   %al,%al
     fc8:	0f 85 94 fe ff ff    	jne    e62 <printf+0x22>
				putc(fd, c);
			}
			state = 0;
		}
	}
}
     fce:	90                   	nop
     fcf:	c9                   	leave  
     fd0:	c3                   	ret    

00000fd1 <free>:

static Header base;
static Header *freep;

void free(void *ap)
{
     fd1:	55                   	push   %ebp
     fd2:	89 e5                	mov    %esp,%ebp
     fd4:	83 ec 10             	sub    $0x10,%esp
	Header *bp, *p;

	bp = (Header *) ap - 1; //take address of memory -> subtract one size of p to get to header to memeory
     fd7:	8b 45 08             	mov    0x8(%ebp),%eax
     fda:	83 e8 08             	sub    $0x8,%eax
     fdd:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr) //comparing pointers to headers...maybe ordering spatially...
     fe0:	a1 40 18 00 00       	mov    0x1840,%eax
     fe5:	89 45 fc             	mov    %eax,-0x4(%ebp)
     fe8:	eb 24                	jmp    100e <free+0x3d>
		if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     fea:	8b 45 fc             	mov    -0x4(%ebp),%eax
     fed:	8b 00                	mov    (%eax),%eax
     fef:	3b 45 fc             	cmp    -0x4(%ebp),%eax
     ff2:	77 12                	ja     1006 <free+0x35>
     ff4:	8b 45 f8             	mov    -0x8(%ebp),%eax
     ff7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
     ffa:	77 24                	ja     1020 <free+0x4f>
     ffc:	8b 45 fc             	mov    -0x4(%ebp),%eax
     fff:	8b 00                	mov    (%eax),%eax
    1001:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1004:	77 1a                	ja     1020 <free+0x4f>
void free(void *ap)
{
	Header *bp, *p;

	bp = (Header *) ap - 1; //take address of memory -> subtract one size of p to get to header to memeory
	for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr) //comparing pointers to headers...maybe ordering spatially...
    1006:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1009:	8b 00                	mov    (%eax),%eax
    100b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    100e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1011:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1014:	76 d4                	jbe    fea <free+0x19>
    1016:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1019:	8b 00                	mov    (%eax),%eax
    101b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    101e:	76 ca                	jbe    fea <free+0x19>
		if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
			break;
	if (bp + bp->s.size == p->s.ptr) { //checks sizes to merge contiguous freed regions
    1020:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1023:	8b 40 04             	mov    0x4(%eax),%eax
    1026:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    102d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1030:	01 c2                	add    %eax,%edx
    1032:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1035:	8b 00                	mov    (%eax),%eax
    1037:	39 c2                	cmp    %eax,%edx
    1039:	75 24                	jne    105f <free+0x8e>
		bp->s.size += p->s.ptr->s.size;
    103b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    103e:	8b 50 04             	mov    0x4(%eax),%edx
    1041:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1044:	8b 00                	mov    (%eax),%eax
    1046:	8b 40 04             	mov    0x4(%eax),%eax
    1049:	01 c2                	add    %eax,%edx
    104b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    104e:	89 50 04             	mov    %edx,0x4(%eax)
		bp->s.ptr = p->s.ptr->s.ptr;
    1051:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1054:	8b 00                	mov    (%eax),%eax
    1056:	8b 10                	mov    (%eax),%edx
    1058:	8b 45 f8             	mov    -0x8(%ebp),%eax
    105b:	89 10                	mov    %edx,(%eax)
    105d:	eb 0a                	jmp    1069 <free+0x98>
	} else
		bp->s.ptr = p->s.ptr;
    105f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1062:	8b 10                	mov    (%eax),%edx
    1064:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1067:	89 10                	mov    %edx,(%eax)
	if (p + p->s.size == bp) {
    1069:	8b 45 fc             	mov    -0x4(%ebp),%eax
    106c:	8b 40 04             	mov    0x4(%eax),%eax
    106f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1076:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1079:	01 d0                	add    %edx,%eax
    107b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    107e:	75 20                	jne    10a0 <free+0xcf>
		p->s.size += bp->s.size;
    1080:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1083:	8b 50 04             	mov    0x4(%eax),%edx
    1086:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1089:	8b 40 04             	mov    0x4(%eax),%eax
    108c:	01 c2                	add    %eax,%edx
    108e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1091:	89 50 04             	mov    %edx,0x4(%eax)
		p->s.ptr = bp->s.ptr;
    1094:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1097:	8b 10                	mov    (%eax),%edx
    1099:	8b 45 fc             	mov    -0x4(%ebp),%eax
    109c:	89 10                	mov    %edx,(%eax)
    109e:	eb 08                	jmp    10a8 <free+0xd7>
	} else
		p->s.ptr = bp;
    10a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    10a3:	8b 55 f8             	mov    -0x8(%ebp),%edx
    10a6:	89 10                	mov    %edx,(%eax)
	freep = p;
    10a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    10ab:	a3 40 18 00 00       	mov    %eax,0x1840
}
    10b0:	90                   	nop
    10b1:	c9                   	leave  
    10b2:	c3                   	ret    

000010b3 <morecore>:

static Header *morecore(uint nu)
{
    10b3:	55                   	push   %ebp
    10b4:	89 e5                	mov    %esp,%ebp
    10b6:	83 ec 18             	sub    $0x18,%esp
	char *p;
	Header *hp;

	if (nu < 4096)
    10b9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    10c0:	77 07                	ja     10c9 <morecore+0x16>
		nu = 4096;
    10c2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
	p = sbrk(nu * sizeof(Header));
    10c9:	8b 45 08             	mov    0x8(%ebp),%eax
    10cc:	c1 e0 03             	shl    $0x3,%eax
    10cf:	83 ec 0c             	sub    $0xc,%esp
    10d2:	50                   	push   %eax
    10d3:	e8 31 fc ff ff       	call   d09 <sbrk>
    10d8:	83 c4 10             	add    $0x10,%esp
    10db:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (p == (char *)-1)
    10de:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    10e2:	75 07                	jne    10eb <morecore+0x38>
		return 0;
    10e4:	b8 00 00 00 00       	mov    $0x0,%eax
    10e9:	eb 26                	jmp    1111 <morecore+0x5e>
	hp = (Header *) p;
    10eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
	hp->s.size = nu;
    10f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    10f4:	8b 55 08             	mov    0x8(%ebp),%edx
    10f7:	89 50 04             	mov    %edx,0x4(%eax)
	free((void *)(hp + 1));
    10fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
    10fd:	83 c0 08             	add    $0x8,%eax
    1100:	83 ec 0c             	sub    $0xc,%esp
    1103:	50                   	push   %eax
    1104:	e8 c8 fe ff ff       	call   fd1 <free>
    1109:	83 c4 10             	add    $0x10,%esp
	return freep;
    110c:	a1 40 18 00 00       	mov    0x1840,%eax
}
    1111:	c9                   	leave  
    1112:	c3                   	ret    

00001113 <malloc>:

void *malloc(uint nbytes)
{
    1113:	55                   	push   %ebp
    1114:	89 e5                	mov    %esp,%ebp
    1116:	83 ec 18             	sub    $0x18,%esp
	Header *p, *prevp;
	uint nunits;

	nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
    1119:	8b 45 08             	mov    0x8(%ebp),%eax
    111c:	83 c0 07             	add    $0x7,%eax
    111f:	c1 e8 03             	shr    $0x3,%eax
    1122:	83 c0 01             	add    $0x1,%eax
    1125:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if ((prevp = freep) == 0) {
    1128:	a1 40 18 00 00       	mov    0x1840,%eax
    112d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1130:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1134:	75 23                	jne    1159 <malloc+0x46>
		base.s.ptr = freep = prevp = &base;
    1136:	c7 45 f0 38 18 00 00 	movl   $0x1838,-0x10(%ebp)
    113d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1140:	a3 40 18 00 00       	mov    %eax,0x1840
    1145:	a1 40 18 00 00       	mov    0x1840,%eax
    114a:	a3 38 18 00 00       	mov    %eax,0x1838
		base.s.size = 0;
    114f:	c7 05 3c 18 00 00 00 	movl   $0x0,0x183c
    1156:	00 00 00 
	}
	for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
    1159:	8b 45 f0             	mov    -0x10(%ebp),%eax
    115c:	8b 00                	mov    (%eax),%eax
    115e:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if (p->s.size >= nunits) {
    1161:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1164:	8b 40 04             	mov    0x4(%eax),%eax
    1167:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    116a:	72 4d                	jb     11b9 <malloc+0xa6>
			if (p->s.size == nunits)
    116c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    116f:	8b 40 04             	mov    0x4(%eax),%eax
    1172:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1175:	75 0c                	jne    1183 <malloc+0x70>
				prevp->s.ptr = p->s.ptr;
    1177:	8b 45 f4             	mov    -0xc(%ebp),%eax
    117a:	8b 10                	mov    (%eax),%edx
    117c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    117f:	89 10                	mov    %edx,(%eax)
    1181:	eb 26                	jmp    11a9 <malloc+0x96>
			else {
				p->s.size -= nunits;
    1183:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1186:	8b 40 04             	mov    0x4(%eax),%eax
    1189:	2b 45 ec             	sub    -0x14(%ebp),%eax
    118c:	89 c2                	mov    %eax,%edx
    118e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1191:	89 50 04             	mov    %edx,0x4(%eax)
				p += p->s.size;
    1194:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1197:	8b 40 04             	mov    0x4(%eax),%eax
    119a:	c1 e0 03             	shl    $0x3,%eax
    119d:	01 45 f4             	add    %eax,-0xc(%ebp)
				p->s.size = nunits;
    11a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11a3:	8b 55 ec             	mov    -0x14(%ebp),%edx
    11a6:	89 50 04             	mov    %edx,0x4(%eax)
			}
			freep = prevp;
    11a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    11ac:	a3 40 18 00 00       	mov    %eax,0x1840
			//printf(0, "\nMalloc Pointer Value = %p\n", p+1);
			return (void *)(p + 1);
    11b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11b4:	83 c0 08             	add    $0x8,%eax
    11b7:	eb 3b                	jmp    11f4 <malloc+0xe1>
		}
		if (p == freep)
    11b9:	a1 40 18 00 00       	mov    0x1840,%eax
    11be:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    11c1:	75 1e                	jne    11e1 <malloc+0xce>
			if ((p = morecore(nunits)) == 0)
    11c3:	83 ec 0c             	sub    $0xc,%esp
    11c6:	ff 75 ec             	pushl  -0x14(%ebp)
    11c9:	e8 e5 fe ff ff       	call   10b3 <morecore>
    11ce:	83 c4 10             	add    $0x10,%esp
    11d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    11d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    11d8:	75 07                	jne    11e1 <malloc+0xce>
				return 0;
    11da:	b8 00 00 00 00       	mov    $0x0,%eax
    11df:	eb 13                	jmp    11f4 <malloc+0xe1>
	nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
	if ((prevp = freep) == 0) {
		base.s.ptr = freep = prevp = &base;
		base.s.size = 0;
	}
	for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
    11e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    11e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11ea:	8b 00                	mov    (%eax),%eax
    11ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
			return (void *)(p + 1);
		}
		if (p == freep)
			if ((p = morecore(nunits)) == 0)
				return 0;
	}
    11ef:	e9 6d ff ff ff       	jmp    1161 <malloc+0x4e>
}
    11f4:	c9                   	leave  
    11f5:	c3                   	ret    
