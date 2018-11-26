
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
char *argv[] = { "sh", 0 };
char *argv2[] = {"fileserver",0};
int status = 0;

int main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 14             	sub    $0x14,%esp
	int pid, wpid,pid2;

	if (open("console", O_RDWR) < 0) {
  11:	83 ec 08             	sub    $0x8,%esp
  14:	6a 02                	push   $0x2
  16:	68 48 09 00 00       	push   $0x948
  1b:	e8 e5 03 00 00       	call   405 <open>
  20:	83 c4 10             	add    $0x10,%esp
  23:	85 c0                	test   %eax,%eax
  25:	79 26                	jns    4d <main+0x4d>
		mknod("console", 1, 1);
  27:	83 ec 04             	sub    $0x4,%esp
  2a:	6a 01                	push   $0x1
  2c:	6a 01                	push   $0x1
  2e:	68 48 09 00 00       	push   $0x948
  33:	e8 d5 03 00 00       	call   40d <mknod>
  38:	83 c4 10             	add    $0x10,%esp
		open("console", O_RDWR);
  3b:	83 ec 08             	sub    $0x8,%esp
  3e:	6a 02                	push   $0x2
  40:	68 48 09 00 00       	push   $0x948
  45:	e8 bb 03 00 00       	call   405 <open>
  4a:	83 c4 10             	add    $0x10,%esp
	}
	dup(0);			// stdout
  4d:	83 ec 0c             	sub    $0xc,%esp
  50:	6a 00                	push   $0x0
  52:	e8 e6 03 00 00       	call   43d <dup>
  57:	83 c4 10             	add    $0x10,%esp
	dup(0);			// stderr
  5a:	83 ec 0c             	sub    $0xc,%esp
  5d:	6a 00                	push   $0x0
  5f:	e8 d9 03 00 00       	call   43d <dup>
  64:	83 c4 10             	add    $0x10,%esp

	for (;;) {
		printf(1, "init: starting sh\n");
  67:	83 ec 08             	sub    $0x8,%esp
  6a:	68 50 09 00 00       	push   $0x950
  6f:	6a 01                	push   $0x1
  71:	e8 0e 05 00 00       	call   584 <printf>
  76:	83 c4 10             	add    $0x10,%esp
		pid = fork();
  79:	e8 3f 03 00 00       	call   3bd <fork>
  7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if (pid < 0) {
  81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  85:	79 17                	jns    9e <main+0x9e>
			printf(1, "init: fork failed\n");
  87:	83 ec 08             	sub    $0x8,%esp
  8a:	68 63 09 00 00       	push   $0x963
  8f:	6a 01                	push   $0x1
  91:	e8 ee 04 00 00       	call   584 <printf>
  96:	83 c4 10             	add    $0x10,%esp
			exit();
  99:	e8 27 03 00 00       	call   3c5 <exit>
		}
		if (pid == 0) {
  9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  a2:	75 2c                	jne    d0 <main+0xd0>
			exec("sh", argv);
  a4:	83 ec 08             	sub    $0x8,%esp
  a7:	68 fc 0b 00 00       	push   $0xbfc
  ac:	68 3a 09 00 00       	push   $0x93a
  b1:	e8 47 03 00 00       	call   3fd <exec>
  b6:	83 c4 10             	add    $0x10,%esp
			printf(1, "init: exec sh failed\n");
  b9:	83 ec 08             	sub    $0x8,%esp
  bc:	68 76 09 00 00       	push   $0x976
  c1:	6a 01                	push   $0x1
  c3:	e8 bc 04 00 00       	call   584 <printf>
  c8:	83 c4 10             	add    $0x10,%esp
			exit();
  cb:	e8 f5 02 00 00       	call   3c5 <exit>
		}
		pid2 = fork();
  d0:	e8 e8 02 00 00       	call   3bd <fork>
  d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (pid2 < 0) {
  d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  dc:	79 17                	jns    f5 <main+0xf5>
			printf(1, "init: fork failed\n");
  de:	83 ec 08             	sub    $0x8,%esp
  e1:	68 63 09 00 00       	push   $0x963
  e6:	6a 01                	push   $0x1
  e8:	e8 97 04 00 00       	call   584 <printf>
  ed:	83 c4 10             	add    $0x10,%esp
			exit();
  f0:	e8 d0 02 00 00       	call   3c5 <exit>
		}
		if (pid2 == 0 && status == 0) {
  f5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  f9:	75 54                	jne    14f <main+0x14f>
  fb:	a1 20 0c 00 00       	mov    0xc20,%eax
 100:	85 c0                	test   %eax,%eax
 102:	75 4b                	jne    14f <main+0x14f>
			status ++;
 104:	a1 20 0c 00 00       	mov    0xc20,%eax
 109:	83 c0 01             	add    $0x1,%eax
 10c:	a3 20 0c 00 00       	mov    %eax,0xc20
			exec("fileserver", argv2);
 111:	83 ec 08             	sub    $0x8,%esp
 114:	68 04 0c 00 00       	push   $0xc04
 119:	68 3d 09 00 00       	push   $0x93d
 11e:	e8 da 02 00 00       	call   3fd <exec>
 123:	83 c4 10             	add    $0x10,%esp
			printf(1, "init: exec fss failed\n");
 126:	83 ec 08             	sub    $0x8,%esp
 129:	68 8c 09 00 00       	push   $0x98c
 12e:	6a 01                	push   $0x1
 130:	e8 4f 04 00 00       	call   584 <printf>
 135:	83 c4 10             	add    $0x10,%esp
			exit();
 138:	e8 88 02 00 00       	call   3c5 <exit>
		}
		while ((wpid = wait()) >= 0 && wpid != pid)
			printf(1, "zombie!\n");
 13d:	83 ec 08             	sub    $0x8,%esp
 140:	68 a3 09 00 00       	push   $0x9a3
 145:	6a 01                	push   $0x1
 147:	e8 38 04 00 00       	call   584 <printf>
 14c:	83 c4 10             	add    $0x10,%esp
			status ++;
			exec("fileserver", argv2);
			printf(1, "init: exec fss failed\n");
			exit();
		}
		while ((wpid = wait()) >= 0 && wpid != pid)
 14f:	e8 79 02 00 00       	call   3cd <wait>
 154:	89 45 ec             	mov    %eax,-0x14(%ebp)
 157:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 15b:	0f 88 06 ff ff ff    	js     67 <main+0x67>
 161:	8b 45 ec             	mov    -0x14(%ebp),%eax
 164:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 167:	75 d4                	jne    13d <main+0x13d>
			printf(1, "zombie!\n");
	}
 169:	e9 f9 fe ff ff       	jmp    67 <main+0x67>

0000016e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 16e:	55                   	push   %ebp
 16f:	89 e5                	mov    %esp,%ebp
 171:	57                   	push   %edi
 172:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 173:	8b 4d 08             	mov    0x8(%ebp),%ecx
 176:	8b 55 10             	mov    0x10(%ebp),%edx
 179:	8b 45 0c             	mov    0xc(%ebp),%eax
 17c:	89 cb                	mov    %ecx,%ebx
 17e:	89 df                	mov    %ebx,%edi
 180:	89 d1                	mov    %edx,%ecx
 182:	fc                   	cld    
 183:	f3 aa                	rep stos %al,%es:(%edi)
 185:	89 ca                	mov    %ecx,%edx
 187:	89 fb                	mov    %edi,%ebx
 189:	89 5d 08             	mov    %ebx,0x8(%ebp)
 18c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 18f:	90                   	nop
 190:	5b                   	pop    %ebx
 191:	5f                   	pop    %edi
 192:	5d                   	pop    %ebp
 193:	c3                   	ret    

00000194 <strcpy>:
#include "fcntl.h"
#include "user.h"
#include "x86.h"

char *strcpy(char *s, char *t)
{
 194:	55                   	push   %ebp
 195:	89 e5                	mov    %esp,%ebp
 197:	83 ec 10             	sub    $0x10,%esp
	char *os;

	os = s;
 19a:	8b 45 08             	mov    0x8(%ebp),%eax
 19d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*s++ = *t++) != 0) ;
 1a0:	90                   	nop
 1a1:	8b 45 08             	mov    0x8(%ebp),%eax
 1a4:	8d 50 01             	lea    0x1(%eax),%edx
 1a7:	89 55 08             	mov    %edx,0x8(%ebp)
 1aa:	8b 55 0c             	mov    0xc(%ebp),%edx
 1ad:	8d 4a 01             	lea    0x1(%edx),%ecx
 1b0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 1b3:	0f b6 12             	movzbl (%edx),%edx
 1b6:	88 10                	mov    %dl,(%eax)
 1b8:	0f b6 00             	movzbl (%eax),%eax
 1bb:	84 c0                	test   %al,%al
 1bd:	75 e2                	jne    1a1 <strcpy+0xd>
	return os;
 1bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1c2:	c9                   	leave  
 1c3:	c3                   	ret    

000001c4 <strcmp>:

int strcmp(const char *p, const char *q)
{
 1c4:	55                   	push   %ebp
 1c5:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
 1c7:	eb 08                	jmp    1d1 <strcmp+0xd>
		p++, q++;
 1c9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1cd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	return os;
}

int strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
 1d1:	8b 45 08             	mov    0x8(%ebp),%eax
 1d4:	0f b6 00             	movzbl (%eax),%eax
 1d7:	84 c0                	test   %al,%al
 1d9:	74 10                	je     1eb <strcmp+0x27>
 1db:	8b 45 08             	mov    0x8(%ebp),%eax
 1de:	0f b6 10             	movzbl (%eax),%edx
 1e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e4:	0f b6 00             	movzbl (%eax),%eax
 1e7:	38 c2                	cmp    %al,%dl
 1e9:	74 de                	je     1c9 <strcmp+0x5>
		p++, q++;
	return (uchar) * p - (uchar) * q;
 1eb:	8b 45 08             	mov    0x8(%ebp),%eax
 1ee:	0f b6 00             	movzbl (%eax),%eax
 1f1:	0f b6 d0             	movzbl %al,%edx
 1f4:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f7:	0f b6 00             	movzbl (%eax),%eax
 1fa:	0f b6 c0             	movzbl %al,%eax
 1fd:	29 c2                	sub    %eax,%edx
 1ff:	89 d0                	mov    %edx,%eax
}
 201:	5d                   	pop    %ebp
 202:	c3                   	ret    

00000203 <strlen>:

uint strlen(char *s)
{
 203:	55                   	push   %ebp
 204:	89 e5                	mov    %esp,%ebp
 206:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; s[n]; n++) ;
 209:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 210:	eb 04                	jmp    216 <strlen+0x13>
 212:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 216:	8b 55 fc             	mov    -0x4(%ebp),%edx
 219:	8b 45 08             	mov    0x8(%ebp),%eax
 21c:	01 d0                	add    %edx,%eax
 21e:	0f b6 00             	movzbl (%eax),%eax
 221:	84 c0                	test   %al,%al
 223:	75 ed                	jne    212 <strlen+0xf>
	return n;
 225:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 228:	c9                   	leave  
 229:	c3                   	ret    

0000022a <memset>:

void *memset(void *dst, int c, uint n)
{
 22a:	55                   	push   %ebp
 22b:	89 e5                	mov    %esp,%ebp
	stosb(dst, c, n);
 22d:	8b 45 10             	mov    0x10(%ebp),%eax
 230:	50                   	push   %eax
 231:	ff 75 0c             	pushl  0xc(%ebp)
 234:	ff 75 08             	pushl  0x8(%ebp)
 237:	e8 32 ff ff ff       	call   16e <stosb>
 23c:	83 c4 0c             	add    $0xc,%esp
	return dst;
 23f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 242:	c9                   	leave  
 243:	c3                   	ret    

00000244 <strchr>:

char *strchr(const char *s, char c)
{
 244:	55                   	push   %ebp
 245:	89 e5                	mov    %esp,%ebp
 247:	83 ec 04             	sub    $0x4,%esp
 24a:	8b 45 0c             	mov    0xc(%ebp),%eax
 24d:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
 250:	eb 14                	jmp    266 <strchr+0x22>
		if (*s == c)
 252:	8b 45 08             	mov    0x8(%ebp),%eax
 255:	0f b6 00             	movzbl (%eax),%eax
 258:	3a 45 fc             	cmp    -0x4(%ebp),%al
 25b:	75 05                	jne    262 <strchr+0x1e>
			return (char *)s;
 25d:	8b 45 08             	mov    0x8(%ebp),%eax
 260:	eb 13                	jmp    275 <strchr+0x31>
	return dst;
}

char *strchr(const char *s, char c)
{
	for (; *s; s++)
 262:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 266:	8b 45 08             	mov    0x8(%ebp),%eax
 269:	0f b6 00             	movzbl (%eax),%eax
 26c:	84 c0                	test   %al,%al
 26e:	75 e2                	jne    252 <strchr+0xe>
		if (*s == c)
			return (char *)s;
	return 0;
 270:	b8 00 00 00 00       	mov    $0x0,%eax
}
 275:	c9                   	leave  
 276:	c3                   	ret    

00000277 <gets>:

char *gets(char *buf, int max)
{
 277:	55                   	push   %ebp
 278:	89 e5                	mov    %esp,%ebp
 27a:	83 ec 18             	sub    $0x18,%esp
	int i, cc;
	char c;

	for (i = 0; i + 1 < max;) {
 27d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 284:	eb 42                	jmp    2c8 <gets+0x51>
		cc = read(0, &c, 1);
 286:	83 ec 04             	sub    $0x4,%esp
 289:	6a 01                	push   $0x1
 28b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 28e:	50                   	push   %eax
 28f:	6a 00                	push   $0x0
 291:	e8 47 01 00 00       	call   3dd <read>
 296:	83 c4 10             	add    $0x10,%esp
 299:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (cc < 1)
 29c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2a0:	7e 33                	jle    2d5 <gets+0x5e>
			break;
		buf[i++] = c;
 2a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2a5:	8d 50 01             	lea    0x1(%eax),%edx
 2a8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2ab:	89 c2                	mov    %eax,%edx
 2ad:	8b 45 08             	mov    0x8(%ebp),%eax
 2b0:	01 c2                	add    %eax,%edx
 2b2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2b6:	88 02                	mov    %al,(%edx)
		if (c == '\n' || c == '\r')
 2b8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2bc:	3c 0a                	cmp    $0xa,%al
 2be:	74 16                	je     2d6 <gets+0x5f>
 2c0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2c4:	3c 0d                	cmp    $0xd,%al
 2c6:	74 0e                	je     2d6 <gets+0x5f>
char *gets(char *buf, int max)
{
	int i, cc;
	char c;

	for (i = 0; i + 1 < max;) {
 2c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2cb:	83 c0 01             	add    $0x1,%eax
 2ce:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2d1:	7c b3                	jl     286 <gets+0xf>
 2d3:	eb 01                	jmp    2d6 <gets+0x5f>
		cc = read(0, &c, 1);
		if (cc < 1)
			break;
 2d5:	90                   	nop
		buf[i++] = c;
		if (c == '\n' || c == '\r')
			break;
	}
	buf[i] = '\0';
 2d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2d9:	8b 45 08             	mov    0x8(%ebp),%eax
 2dc:	01 d0                	add    %edx,%eax
 2de:	c6 00 00             	movb   $0x0,(%eax)
	return buf;
 2e1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2e4:	c9                   	leave  
 2e5:	c3                   	ret    

000002e6 <stat>:

int stat(char *n, struct stat *st)
{
 2e6:	55                   	push   %ebp
 2e7:	89 e5                	mov    %esp,%ebp
 2e9:	83 ec 18             	sub    $0x18,%esp
	int fd;
	int r;

	fd = open(n, O_RDONLY);
 2ec:	83 ec 08             	sub    $0x8,%esp
 2ef:	6a 00                	push   $0x0
 2f1:	ff 75 08             	pushl  0x8(%ebp)
 2f4:	e8 0c 01 00 00       	call   405 <open>
 2f9:	83 c4 10             	add    $0x10,%esp
 2fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (fd < 0)
 2ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 303:	79 07                	jns    30c <stat+0x26>
		return -1;
 305:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 30a:	eb 25                	jmp    331 <stat+0x4b>
	r = fstat(fd, st);
 30c:	83 ec 08             	sub    $0x8,%esp
 30f:	ff 75 0c             	pushl  0xc(%ebp)
 312:	ff 75 f4             	pushl  -0xc(%ebp)
 315:	e8 03 01 00 00       	call   41d <fstat>
 31a:	83 c4 10             	add    $0x10,%esp
 31d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	close(fd);
 320:	83 ec 0c             	sub    $0xc,%esp
 323:	ff 75 f4             	pushl  -0xc(%ebp)
 326:	e8 c2 00 00 00       	call   3ed <close>
 32b:	83 c4 10             	add    $0x10,%esp
	return r;
 32e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 331:	c9                   	leave  
 332:	c3                   	ret    

00000333 <atoi>:

int atoi(const char *s)
{
 333:	55                   	push   %ebp
 334:	89 e5                	mov    %esp,%ebp
 336:	83 ec 10             	sub    $0x10,%esp
	int n;

	n = 0;
 339:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	while ('0' <= *s && *s <= '9')
 340:	eb 25                	jmp    367 <atoi+0x34>
		n = n * 10 + *s++ - '0';
 342:	8b 55 fc             	mov    -0x4(%ebp),%edx
 345:	89 d0                	mov    %edx,%eax
 347:	c1 e0 02             	shl    $0x2,%eax
 34a:	01 d0                	add    %edx,%eax
 34c:	01 c0                	add    %eax,%eax
 34e:	89 c1                	mov    %eax,%ecx
 350:	8b 45 08             	mov    0x8(%ebp),%eax
 353:	8d 50 01             	lea    0x1(%eax),%edx
 356:	89 55 08             	mov    %edx,0x8(%ebp)
 359:	0f b6 00             	movzbl (%eax),%eax
 35c:	0f be c0             	movsbl %al,%eax
 35f:	01 c8                	add    %ecx,%eax
 361:	83 e8 30             	sub    $0x30,%eax
 364:	89 45 fc             	mov    %eax,-0x4(%ebp)
int atoi(const char *s)
{
	int n;

	n = 0;
	while ('0' <= *s && *s <= '9')
 367:	8b 45 08             	mov    0x8(%ebp),%eax
 36a:	0f b6 00             	movzbl (%eax),%eax
 36d:	3c 2f                	cmp    $0x2f,%al
 36f:	7e 0a                	jle    37b <atoi+0x48>
 371:	8b 45 08             	mov    0x8(%ebp),%eax
 374:	0f b6 00             	movzbl (%eax),%eax
 377:	3c 39                	cmp    $0x39,%al
 379:	7e c7                	jle    342 <atoi+0xf>
		n = n * 10 + *s++ - '0';
	return n;
 37b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 37e:	c9                   	leave  
 37f:	c3                   	ret    

00000380 <memmove>:

void *memmove(void *vdst, void *vsrc, int n)
{
 380:	55                   	push   %ebp
 381:	89 e5                	mov    %esp,%ebp
 383:	83 ec 10             	sub    $0x10,%esp
	char *dst, *src;

	dst = vdst;
 386:	8b 45 08             	mov    0x8(%ebp),%eax
 389:	89 45 fc             	mov    %eax,-0x4(%ebp)
	src = vsrc;
 38c:	8b 45 0c             	mov    0xc(%ebp),%eax
 38f:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
 392:	eb 17                	jmp    3ab <memmove+0x2b>
		*dst++ = *src++;
 394:	8b 45 fc             	mov    -0x4(%ebp),%eax
 397:	8d 50 01             	lea    0x1(%eax),%edx
 39a:	89 55 fc             	mov    %edx,-0x4(%ebp)
 39d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3a0:	8d 4a 01             	lea    0x1(%edx),%ecx
 3a3:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 3a6:	0f b6 12             	movzbl (%edx),%edx
 3a9:	88 10                	mov    %dl,(%eax)
{
	char *dst, *src;

	dst = vdst;
	src = vsrc;
	while (n-- > 0)
 3ab:	8b 45 10             	mov    0x10(%ebp),%eax
 3ae:	8d 50 ff             	lea    -0x1(%eax),%edx
 3b1:	89 55 10             	mov    %edx,0x10(%ebp)
 3b4:	85 c0                	test   %eax,%eax
 3b6:	7f dc                	jg     394 <memmove+0x14>
		*dst++ = *src++;
	return vdst;
 3b8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3bb:	c9                   	leave  
 3bc:	c3                   	ret    

000003bd <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3bd:	b8 01 00 00 00       	mov    $0x1,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret    

000003c5 <exit>:
SYSCALL(exit)
 3c5:	b8 02 00 00 00       	mov    $0x2,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret    

000003cd <wait>:
SYSCALL(wait)
 3cd:	b8 03 00 00 00       	mov    $0x3,%eax
 3d2:	cd 40                	int    $0x40
 3d4:	c3                   	ret    

000003d5 <pipe>:
SYSCALL(pipe)
 3d5:	b8 04 00 00 00       	mov    $0x4,%eax
 3da:	cd 40                	int    $0x40
 3dc:	c3                   	ret    

000003dd <read>:
SYSCALL(read)
 3dd:	b8 05 00 00 00       	mov    $0x5,%eax
 3e2:	cd 40                	int    $0x40
 3e4:	c3                   	ret    

000003e5 <write>:
SYSCALL(write)
 3e5:	b8 10 00 00 00       	mov    $0x10,%eax
 3ea:	cd 40                	int    $0x40
 3ec:	c3                   	ret    

000003ed <close>:
SYSCALL(close)
 3ed:	b8 15 00 00 00       	mov    $0x15,%eax
 3f2:	cd 40                	int    $0x40
 3f4:	c3                   	ret    

000003f5 <kill>:
SYSCALL(kill)
 3f5:	b8 06 00 00 00       	mov    $0x6,%eax
 3fa:	cd 40                	int    $0x40
 3fc:	c3                   	ret    

000003fd <exec>:
SYSCALL(exec)
 3fd:	b8 07 00 00 00       	mov    $0x7,%eax
 402:	cd 40                	int    $0x40
 404:	c3                   	ret    

00000405 <open>:
SYSCALL(open)
 405:	b8 0f 00 00 00       	mov    $0xf,%eax
 40a:	cd 40                	int    $0x40
 40c:	c3                   	ret    

0000040d <mknod>:
SYSCALL(mknod)
 40d:	b8 11 00 00 00       	mov    $0x11,%eax
 412:	cd 40                	int    $0x40
 414:	c3                   	ret    

00000415 <unlink>:
SYSCALL(unlink)
 415:	b8 12 00 00 00       	mov    $0x12,%eax
 41a:	cd 40                	int    $0x40
 41c:	c3                   	ret    

0000041d <fstat>:
SYSCALL(fstat)
 41d:	b8 08 00 00 00       	mov    $0x8,%eax
 422:	cd 40                	int    $0x40
 424:	c3                   	ret    

00000425 <link>:
SYSCALL(link)
 425:	b8 13 00 00 00       	mov    $0x13,%eax
 42a:	cd 40                	int    $0x40
 42c:	c3                   	ret    

0000042d <mkdir>:
SYSCALL(mkdir)
 42d:	b8 14 00 00 00       	mov    $0x14,%eax
 432:	cd 40                	int    $0x40
 434:	c3                   	ret    

00000435 <chdir>:
SYSCALL(chdir)
 435:	b8 09 00 00 00       	mov    $0x9,%eax
 43a:	cd 40                	int    $0x40
 43c:	c3                   	ret    

0000043d <dup>:
SYSCALL(dup)
 43d:	b8 0a 00 00 00       	mov    $0xa,%eax
 442:	cd 40                	int    $0x40
 444:	c3                   	ret    

00000445 <getpid>:
SYSCALL(getpid)
 445:	b8 0b 00 00 00       	mov    $0xb,%eax
 44a:	cd 40                	int    $0x40
 44c:	c3                   	ret    

0000044d <sbrk>:
SYSCALL(sbrk)
 44d:	b8 0c 00 00 00       	mov    $0xc,%eax
 452:	cd 40                	int    $0x40
 454:	c3                   	ret    

00000455 <sleep>:
SYSCALL(sleep)
 455:	b8 0d 00 00 00       	mov    $0xd,%eax
 45a:	cd 40                	int    $0x40
 45c:	c3                   	ret    

0000045d <uptime>:
SYSCALL(uptime)
 45d:	b8 0e 00 00 00       	mov    $0xe,%eax
 462:	cd 40                	int    $0x40
 464:	c3                   	ret    

00000465 <shm_get>:
SYSCALL(shm_get) //mod2
 465:	b8 1c 00 00 00       	mov    $0x1c,%eax
 46a:	cd 40                	int    $0x40
 46c:	c3                   	ret    

0000046d <shm_rem>:
SYSCALL(shm_rem) //mod2
 46d:	b8 1d 00 00 00       	mov    $0x1d,%eax
 472:	cd 40                	int    $0x40
 474:	c3                   	ret    

00000475 <setHighPrio>:
SYSCALL(setHighPrio) //scheduler
 475:	b8 1e 00 00 00       	mov    $0x1e,%eax
 47a:	cd 40                	int    $0x40
 47c:	c3                   	ret    

0000047d <mutex_create>:
SYSCALL(mutex_create)//mod3
 47d:	b8 16 00 00 00       	mov    $0x16,%eax
 482:	cd 40                	int    $0x40
 484:	c3                   	ret    

00000485 <mutex_delete>:
SYSCALL(mutex_delete)
 485:	b8 17 00 00 00       	mov    $0x17,%eax
 48a:	cd 40                	int    $0x40
 48c:	c3                   	ret    

0000048d <mutex_lock>:
SYSCALL(mutex_lock)
 48d:	b8 18 00 00 00       	mov    $0x18,%eax
 492:	cd 40                	int    $0x40
 494:	c3                   	ret    

00000495 <mutex_unlock>:
SYSCALL(mutex_unlock)
 495:	b8 19 00 00 00       	mov    $0x19,%eax
 49a:	cd 40                	int    $0x40
 49c:	c3                   	ret    

0000049d <cv_wait>:
SYSCALL(cv_wait)
 49d:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4a2:	cd 40                	int    $0x40
 4a4:	c3                   	ret    

000004a5 <cv_signal>:
SYSCALL(cv_signal)
 4a5:	b8 1b 00 00 00       	mov    $0x1b,%eax
 4aa:	cd 40                	int    $0x40
 4ac:	c3                   	ret    

000004ad <putc>:
#include "types.h"
#include "stat.h"
#include "user.h"

static void putc(int fd, char c)
{
 4ad:	55                   	push   %ebp
 4ae:	89 e5                	mov    %esp,%ebp
 4b0:	83 ec 18             	sub    $0x18,%esp
 4b3:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b6:	88 45 f4             	mov    %al,-0xc(%ebp)
	write(fd, &c, 1);
 4b9:	83 ec 04             	sub    $0x4,%esp
 4bc:	6a 01                	push   $0x1
 4be:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4c1:	50                   	push   %eax
 4c2:	ff 75 08             	pushl  0x8(%ebp)
 4c5:	e8 1b ff ff ff       	call   3e5 <write>
 4ca:	83 c4 10             	add    $0x10,%esp
}
 4cd:	90                   	nop
 4ce:	c9                   	leave  
 4cf:	c3                   	ret    

000004d0 <printint>:

static void printint(int fd, int xx, int base, int sgn)
{
 4d0:	55                   	push   %ebp
 4d1:	89 e5                	mov    %esp,%ebp
 4d3:	53                   	push   %ebx
 4d4:	83 ec 24             	sub    $0x24,%esp
	static char digits[] = "0123456789ABCDEF";
	char buf[16];
	int i, neg;
	uint x;

	neg = 0;
 4d7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	if (sgn && xx < 0) {
 4de:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4e2:	74 17                	je     4fb <printint+0x2b>
 4e4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4e8:	79 11                	jns    4fb <printint+0x2b>
		neg = 1;
 4ea:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
		x = -xx;
 4f1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f4:	f7 d8                	neg    %eax
 4f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4f9:	eb 06                	jmp    501 <printint+0x31>
	} else {
		x = xx;
 4fb:	8b 45 0c             	mov    0xc(%ebp),%eax
 4fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
	}

	i = 0;
 501:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	do {
		buf[i++] = digits[x % base];
 508:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 50b:	8d 41 01             	lea    0x1(%ecx),%eax
 50e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 511:	8b 5d 10             	mov    0x10(%ebp),%ebx
 514:	8b 45 ec             	mov    -0x14(%ebp),%eax
 517:	ba 00 00 00 00       	mov    $0x0,%edx
 51c:	f7 f3                	div    %ebx
 51e:	89 d0                	mov    %edx,%eax
 520:	0f b6 80 0c 0c 00 00 	movzbl 0xc0c(%eax),%eax
 527:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
	} while ((x /= base) != 0);
 52b:	8b 5d 10             	mov    0x10(%ebp),%ebx
 52e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 531:	ba 00 00 00 00       	mov    $0x0,%edx
 536:	f7 f3                	div    %ebx
 538:	89 45 ec             	mov    %eax,-0x14(%ebp)
 53b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 53f:	75 c7                	jne    508 <printint+0x38>
	if (neg)
 541:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 545:	74 2d                	je     574 <printint+0xa4>
		buf[i++] = '-';
 547:	8b 45 f4             	mov    -0xc(%ebp),%eax
 54a:	8d 50 01             	lea    0x1(%eax),%edx
 54d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 550:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

	while (--i >= 0)
 555:	eb 1d                	jmp    574 <printint+0xa4>
		putc(fd, buf[i]);
 557:	8d 55 dc             	lea    -0x24(%ebp),%edx
 55a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 55d:	01 d0                	add    %edx,%eax
 55f:	0f b6 00             	movzbl (%eax),%eax
 562:	0f be c0             	movsbl %al,%eax
 565:	83 ec 08             	sub    $0x8,%esp
 568:	50                   	push   %eax
 569:	ff 75 08             	pushl  0x8(%ebp)
 56c:	e8 3c ff ff ff       	call   4ad <putc>
 571:	83 c4 10             	add    $0x10,%esp
		buf[i++] = digits[x % base];
	} while ((x /= base) != 0);
	if (neg)
		buf[i++] = '-';

	while (--i >= 0)
 574:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 578:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 57c:	79 d9                	jns    557 <printint+0x87>
		putc(fd, buf[i]);
}
 57e:	90                   	nop
 57f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 582:	c9                   	leave  
 583:	c3                   	ret    

00000584 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void printf(int fd, char *fmt, ...)
{
 584:	55                   	push   %ebp
 585:	89 e5                	mov    %esp,%ebp
 587:	83 ec 28             	sub    $0x28,%esp
	char *s;
	int c, i, state;
	uint *ap;

	state = 0;
 58a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	ap = (uint *) (void *)&fmt + 1;
 591:	8d 45 0c             	lea    0xc(%ebp),%eax
 594:	83 c0 04             	add    $0x4,%eax
 597:	89 45 e8             	mov    %eax,-0x18(%ebp)
	for (i = 0; fmt[i]; i++) {
 59a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5a1:	e9 59 01 00 00       	jmp    6ff <printf+0x17b>
		c = fmt[i] & 0xff;
 5a6:	8b 55 0c             	mov    0xc(%ebp),%edx
 5a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5ac:	01 d0                	add    %edx,%eax
 5ae:	0f b6 00             	movzbl (%eax),%eax
 5b1:	0f be c0             	movsbl %al,%eax
 5b4:	25 ff 00 00 00       	and    $0xff,%eax
 5b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (state == 0) {
 5bc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5c0:	75 2c                	jne    5ee <printf+0x6a>
			if (c == '%') {
 5c2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5c6:	75 0c                	jne    5d4 <printf+0x50>
				state = '%';
 5c8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5cf:	e9 27 01 00 00       	jmp    6fb <printf+0x177>
			} else {
				putc(fd, c);
 5d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5d7:	0f be c0             	movsbl %al,%eax
 5da:	83 ec 08             	sub    $0x8,%esp
 5dd:	50                   	push   %eax
 5de:	ff 75 08             	pushl  0x8(%ebp)
 5e1:	e8 c7 fe ff ff       	call   4ad <putc>
 5e6:	83 c4 10             	add    $0x10,%esp
 5e9:	e9 0d 01 00 00       	jmp    6fb <printf+0x177>
			}
		} else if (state == '%') {
 5ee:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5f2:	0f 85 03 01 00 00    	jne    6fb <printf+0x177>
			if (c == 'd') {
 5f8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5fc:	75 1e                	jne    61c <printf+0x98>
				printint(fd, *ap, 10, 1);
 5fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
 601:	8b 00                	mov    (%eax),%eax
 603:	6a 01                	push   $0x1
 605:	6a 0a                	push   $0xa
 607:	50                   	push   %eax
 608:	ff 75 08             	pushl  0x8(%ebp)
 60b:	e8 c0 fe ff ff       	call   4d0 <printint>
 610:	83 c4 10             	add    $0x10,%esp
				ap++;
 613:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 617:	e9 d8 00 00 00       	jmp    6f4 <printf+0x170>
			} else if (c == 'x' || c == 'p') {
 61c:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 620:	74 06                	je     628 <printf+0xa4>
 622:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 626:	75 1e                	jne    646 <printf+0xc2>
				printint(fd, *ap, 16, 0);
 628:	8b 45 e8             	mov    -0x18(%ebp),%eax
 62b:	8b 00                	mov    (%eax),%eax
 62d:	6a 00                	push   $0x0
 62f:	6a 10                	push   $0x10
 631:	50                   	push   %eax
 632:	ff 75 08             	pushl  0x8(%ebp)
 635:	e8 96 fe ff ff       	call   4d0 <printint>
 63a:	83 c4 10             	add    $0x10,%esp
				ap++;
 63d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 641:	e9 ae 00 00 00       	jmp    6f4 <printf+0x170>
			} else if (c == 's') {
 646:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 64a:	75 43                	jne    68f <printf+0x10b>
				s = (char *)*ap;
 64c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 64f:	8b 00                	mov    (%eax),%eax
 651:	89 45 f4             	mov    %eax,-0xc(%ebp)
				ap++;
 654:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
				if (s == 0)
 658:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 65c:	75 25                	jne    683 <printf+0xff>
					s = "(null)";
 65e:	c7 45 f4 ac 09 00 00 	movl   $0x9ac,-0xc(%ebp)
				while (*s != 0) {
 665:	eb 1c                	jmp    683 <printf+0xff>
					putc(fd, *s);
 667:	8b 45 f4             	mov    -0xc(%ebp),%eax
 66a:	0f b6 00             	movzbl (%eax),%eax
 66d:	0f be c0             	movsbl %al,%eax
 670:	83 ec 08             	sub    $0x8,%esp
 673:	50                   	push   %eax
 674:	ff 75 08             	pushl  0x8(%ebp)
 677:	e8 31 fe ff ff       	call   4ad <putc>
 67c:	83 c4 10             	add    $0x10,%esp
					s++;
 67f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
			} else if (c == 's') {
				s = (char *)*ap;
				ap++;
				if (s == 0)
					s = "(null)";
				while (*s != 0) {
 683:	8b 45 f4             	mov    -0xc(%ebp),%eax
 686:	0f b6 00             	movzbl (%eax),%eax
 689:	84 c0                	test   %al,%al
 68b:	75 da                	jne    667 <printf+0xe3>
 68d:	eb 65                	jmp    6f4 <printf+0x170>
					putc(fd, *s);
					s++;
				}
			} else if (c == 'c') {
 68f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 693:	75 1d                	jne    6b2 <printf+0x12e>
				putc(fd, *ap);
 695:	8b 45 e8             	mov    -0x18(%ebp),%eax
 698:	8b 00                	mov    (%eax),%eax
 69a:	0f be c0             	movsbl %al,%eax
 69d:	83 ec 08             	sub    $0x8,%esp
 6a0:	50                   	push   %eax
 6a1:	ff 75 08             	pushl  0x8(%ebp)
 6a4:	e8 04 fe ff ff       	call   4ad <putc>
 6a9:	83 c4 10             	add    $0x10,%esp
				ap++;
 6ac:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6b0:	eb 42                	jmp    6f4 <printf+0x170>
			} else if (c == '%') {
 6b2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6b6:	75 17                	jne    6cf <printf+0x14b>
				putc(fd, c);
 6b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6bb:	0f be c0             	movsbl %al,%eax
 6be:	83 ec 08             	sub    $0x8,%esp
 6c1:	50                   	push   %eax
 6c2:	ff 75 08             	pushl  0x8(%ebp)
 6c5:	e8 e3 fd ff ff       	call   4ad <putc>
 6ca:	83 c4 10             	add    $0x10,%esp
 6cd:	eb 25                	jmp    6f4 <printf+0x170>
			} else {
				// Unknown % sequence.  Print it to draw attention.
				putc(fd, '%');
 6cf:	83 ec 08             	sub    $0x8,%esp
 6d2:	6a 25                	push   $0x25
 6d4:	ff 75 08             	pushl  0x8(%ebp)
 6d7:	e8 d1 fd ff ff       	call   4ad <putc>
 6dc:	83 c4 10             	add    $0x10,%esp
				putc(fd, c);
 6df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6e2:	0f be c0             	movsbl %al,%eax
 6e5:	83 ec 08             	sub    $0x8,%esp
 6e8:	50                   	push   %eax
 6e9:	ff 75 08             	pushl  0x8(%ebp)
 6ec:	e8 bc fd ff ff       	call   4ad <putc>
 6f1:	83 c4 10             	add    $0x10,%esp
			}
			state = 0;
 6f4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int c, i, state;
	uint *ap;

	state = 0;
	ap = (uint *) (void *)&fmt + 1;
	for (i = 0; fmt[i]; i++) {
 6fb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6ff:	8b 55 0c             	mov    0xc(%ebp),%edx
 702:	8b 45 f0             	mov    -0x10(%ebp),%eax
 705:	01 d0                	add    %edx,%eax
 707:	0f b6 00             	movzbl (%eax),%eax
 70a:	84 c0                	test   %al,%al
 70c:	0f 85 94 fe ff ff    	jne    5a6 <printf+0x22>
				putc(fd, c);
			}
			state = 0;
		}
	}
}
 712:	90                   	nop
 713:	c9                   	leave  
 714:	c3                   	ret    

00000715 <free>:

static Header base;
static Header *freep;

void free(void *ap)
{
 715:	55                   	push   %ebp
 716:	89 e5                	mov    %esp,%ebp
 718:	83 ec 10             	sub    $0x10,%esp
	Header *bp, *p;

	bp = (Header *) ap - 1; //take address of memory -> subtract one size of p to get to header to memeory
 71b:	8b 45 08             	mov    0x8(%ebp),%eax
 71e:	83 e8 08             	sub    $0x8,%eax
 721:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr) //comparing pointers to headers...maybe ordering spatially...
 724:	a1 2c 0c 00 00       	mov    0xc2c,%eax
 729:	89 45 fc             	mov    %eax,-0x4(%ebp)
 72c:	eb 24                	jmp    752 <free+0x3d>
		if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 72e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 731:	8b 00                	mov    (%eax),%eax
 733:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 736:	77 12                	ja     74a <free+0x35>
 738:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 73e:	77 24                	ja     764 <free+0x4f>
 740:	8b 45 fc             	mov    -0x4(%ebp),%eax
 743:	8b 00                	mov    (%eax),%eax
 745:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 748:	77 1a                	ja     764 <free+0x4f>
void free(void *ap)
{
	Header *bp, *p;

	bp = (Header *) ap - 1; //take address of memory -> subtract one size of p to get to header to memeory
	for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr) //comparing pointers to headers...maybe ordering spatially...
 74a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74d:	8b 00                	mov    (%eax),%eax
 74f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 752:	8b 45 f8             	mov    -0x8(%ebp),%eax
 755:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 758:	76 d4                	jbe    72e <free+0x19>
 75a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75d:	8b 00                	mov    (%eax),%eax
 75f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 762:	76 ca                	jbe    72e <free+0x19>
		if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
			break;
	if (bp + bp->s.size == p->s.ptr) { //checks sizes to merge contiguous freed regions
 764:	8b 45 f8             	mov    -0x8(%ebp),%eax
 767:	8b 40 04             	mov    0x4(%eax),%eax
 76a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 771:	8b 45 f8             	mov    -0x8(%ebp),%eax
 774:	01 c2                	add    %eax,%edx
 776:	8b 45 fc             	mov    -0x4(%ebp),%eax
 779:	8b 00                	mov    (%eax),%eax
 77b:	39 c2                	cmp    %eax,%edx
 77d:	75 24                	jne    7a3 <free+0x8e>
		bp->s.size += p->s.ptr->s.size;
 77f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 782:	8b 50 04             	mov    0x4(%eax),%edx
 785:	8b 45 fc             	mov    -0x4(%ebp),%eax
 788:	8b 00                	mov    (%eax),%eax
 78a:	8b 40 04             	mov    0x4(%eax),%eax
 78d:	01 c2                	add    %eax,%edx
 78f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 792:	89 50 04             	mov    %edx,0x4(%eax)
		bp->s.ptr = p->s.ptr->s.ptr;
 795:	8b 45 fc             	mov    -0x4(%ebp),%eax
 798:	8b 00                	mov    (%eax),%eax
 79a:	8b 10                	mov    (%eax),%edx
 79c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79f:	89 10                	mov    %edx,(%eax)
 7a1:	eb 0a                	jmp    7ad <free+0x98>
	} else
		bp->s.ptr = p->s.ptr;
 7a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a6:	8b 10                	mov    (%eax),%edx
 7a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ab:	89 10                	mov    %edx,(%eax)
	if (p + p->s.size == bp) {
 7ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b0:	8b 40 04             	mov    0x4(%eax),%eax
 7b3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bd:	01 d0                	add    %edx,%eax
 7bf:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7c2:	75 20                	jne    7e4 <free+0xcf>
		p->s.size += bp->s.size;
 7c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c7:	8b 50 04             	mov    0x4(%eax),%edx
 7ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7cd:	8b 40 04             	mov    0x4(%eax),%eax
 7d0:	01 c2                	add    %eax,%edx
 7d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d5:	89 50 04             	mov    %edx,0x4(%eax)
		p->s.ptr = bp->s.ptr;
 7d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7db:	8b 10                	mov    (%eax),%edx
 7dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e0:	89 10                	mov    %edx,(%eax)
 7e2:	eb 08                	jmp    7ec <free+0xd7>
	} else
		p->s.ptr = bp;
 7e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e7:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7ea:	89 10                	mov    %edx,(%eax)
	freep = p;
 7ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ef:	a3 2c 0c 00 00       	mov    %eax,0xc2c
}
 7f4:	90                   	nop
 7f5:	c9                   	leave  
 7f6:	c3                   	ret    

000007f7 <morecore>:

static Header *morecore(uint nu)
{
 7f7:	55                   	push   %ebp
 7f8:	89 e5                	mov    %esp,%ebp
 7fa:	83 ec 18             	sub    $0x18,%esp
	char *p;
	Header *hp;

	if (nu < 4096)
 7fd:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 804:	77 07                	ja     80d <morecore+0x16>
		nu = 4096;
 806:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
	p = sbrk(nu * sizeof(Header));
 80d:	8b 45 08             	mov    0x8(%ebp),%eax
 810:	c1 e0 03             	shl    $0x3,%eax
 813:	83 ec 0c             	sub    $0xc,%esp
 816:	50                   	push   %eax
 817:	e8 31 fc ff ff       	call   44d <sbrk>
 81c:	83 c4 10             	add    $0x10,%esp
 81f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (p == (char *)-1)
 822:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 826:	75 07                	jne    82f <morecore+0x38>
		return 0;
 828:	b8 00 00 00 00       	mov    $0x0,%eax
 82d:	eb 26                	jmp    855 <morecore+0x5e>
	hp = (Header *) p;
 82f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 832:	89 45 f0             	mov    %eax,-0x10(%ebp)
	hp->s.size = nu;
 835:	8b 45 f0             	mov    -0x10(%ebp),%eax
 838:	8b 55 08             	mov    0x8(%ebp),%edx
 83b:	89 50 04             	mov    %edx,0x4(%eax)
	free((void *)(hp + 1));
 83e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 841:	83 c0 08             	add    $0x8,%eax
 844:	83 ec 0c             	sub    $0xc,%esp
 847:	50                   	push   %eax
 848:	e8 c8 fe ff ff       	call   715 <free>
 84d:	83 c4 10             	add    $0x10,%esp
	return freep;
 850:	a1 2c 0c 00 00       	mov    0xc2c,%eax
}
 855:	c9                   	leave  
 856:	c3                   	ret    

00000857 <malloc>:

void *malloc(uint nbytes)
{
 857:	55                   	push   %ebp
 858:	89 e5                	mov    %esp,%ebp
 85a:	83 ec 18             	sub    $0x18,%esp
	Header *p, *prevp;
	uint nunits;

	nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 85d:	8b 45 08             	mov    0x8(%ebp),%eax
 860:	83 c0 07             	add    $0x7,%eax
 863:	c1 e8 03             	shr    $0x3,%eax
 866:	83 c0 01             	add    $0x1,%eax
 869:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if ((prevp = freep) == 0) {
 86c:	a1 2c 0c 00 00       	mov    0xc2c,%eax
 871:	89 45 f0             	mov    %eax,-0x10(%ebp)
 874:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 878:	75 23                	jne    89d <malloc+0x46>
		base.s.ptr = freep = prevp = &base;
 87a:	c7 45 f0 24 0c 00 00 	movl   $0xc24,-0x10(%ebp)
 881:	8b 45 f0             	mov    -0x10(%ebp),%eax
 884:	a3 2c 0c 00 00       	mov    %eax,0xc2c
 889:	a1 2c 0c 00 00       	mov    0xc2c,%eax
 88e:	a3 24 0c 00 00       	mov    %eax,0xc24
		base.s.size = 0;
 893:	c7 05 28 0c 00 00 00 	movl   $0x0,0xc28
 89a:	00 00 00 
	}
	for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 89d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a0:	8b 00                	mov    (%eax),%eax
 8a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if (p->s.size >= nunits) {
 8a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a8:	8b 40 04             	mov    0x4(%eax),%eax
 8ab:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8ae:	72 4d                	jb     8fd <malloc+0xa6>
			if (p->s.size == nunits)
 8b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b3:	8b 40 04             	mov    0x4(%eax),%eax
 8b6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8b9:	75 0c                	jne    8c7 <malloc+0x70>
				prevp->s.ptr = p->s.ptr;
 8bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8be:	8b 10                	mov    (%eax),%edx
 8c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c3:	89 10                	mov    %edx,(%eax)
 8c5:	eb 26                	jmp    8ed <malloc+0x96>
			else {
				p->s.size -= nunits;
 8c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ca:	8b 40 04             	mov    0x4(%eax),%eax
 8cd:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8d0:	89 c2                	mov    %eax,%edx
 8d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d5:	89 50 04             	mov    %edx,0x4(%eax)
				p += p->s.size;
 8d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8db:	8b 40 04             	mov    0x4(%eax),%eax
 8de:	c1 e0 03             	shl    $0x3,%eax
 8e1:	01 45 f4             	add    %eax,-0xc(%ebp)
				p->s.size = nunits;
 8e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8ea:	89 50 04             	mov    %edx,0x4(%eax)
			}
			freep = prevp;
 8ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f0:	a3 2c 0c 00 00       	mov    %eax,0xc2c
			//printf(0, "\nMalloc Pointer Value = %p\n", p+1);
			return (void *)(p + 1);
 8f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f8:	83 c0 08             	add    $0x8,%eax
 8fb:	eb 3b                	jmp    938 <malloc+0xe1>
		}
		if (p == freep)
 8fd:	a1 2c 0c 00 00       	mov    0xc2c,%eax
 902:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 905:	75 1e                	jne    925 <malloc+0xce>
			if ((p = morecore(nunits)) == 0)
 907:	83 ec 0c             	sub    $0xc,%esp
 90a:	ff 75 ec             	pushl  -0x14(%ebp)
 90d:	e8 e5 fe ff ff       	call   7f7 <morecore>
 912:	83 c4 10             	add    $0x10,%esp
 915:	89 45 f4             	mov    %eax,-0xc(%ebp)
 918:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 91c:	75 07                	jne    925 <malloc+0xce>
				return 0;
 91e:	b8 00 00 00 00       	mov    $0x0,%eax
 923:	eb 13                	jmp    938 <malloc+0xe1>
	nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
	if ((prevp = freep) == 0) {
		base.s.ptr = freep = prevp = &base;
		base.s.size = 0;
	}
	for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 925:	8b 45 f4             	mov    -0xc(%ebp),%eax
 928:	89 45 f0             	mov    %eax,-0x10(%ebp)
 92b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92e:	8b 00                	mov    (%eax),%eax
 930:	89 45 f4             	mov    %eax,-0xc(%ebp)
			return (void *)(p + 1);
		}
		if (p == freep)
			if ((p = morecore(nunits)) == 0)
				return 0;
	}
 933:	e9 6d ff ff ff       	jmp    8a5 <malloc+0x4e>
}
 938:	c9                   	leave  
 939:	c3                   	ret    
