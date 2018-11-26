
_mxtest:     file format elf32-i386


Disassembly of section .text:

00000000 <mxproc_test>:
#include "types.h"
#include "user.h"


void mxproc_test(void){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp

    //Test of per process mutex arrays
    //Results: Success!
    int muxid1, muxid2, muxid3, muxid4;
    muxid1 = mutex_create("mx1", 3);
   6:	83 ec 08             	sub    $0x8,%esp
   9:	6a 03                	push   $0x3
   b:	68 74 08 00 00       	push   $0x874
  10:	e8 9f 03 00 00       	call   3b4 <mutex_create>
  15:	83 c4 10             	add    $0x10,%esp
  18:	89 45 f4             	mov    %eax,-0xc(%ebp)
    muxid2 = mutex_create("mx1", 3);
  1b:	83 ec 08             	sub    $0x8,%esp
  1e:	6a 03                	push   $0x3
  20:	68 74 08 00 00       	push   $0x874
  25:	e8 8a 03 00 00       	call   3b4 <mutex_create>
  2a:	83 c4 10             	add    $0x10,%esp
  2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    muxid3 = mutex_create("mx3", 3);
  30:	83 ec 08             	sub    $0x8,%esp
  33:	6a 03                	push   $0x3
  35:	68 78 08 00 00       	push   $0x878
  3a:	e8 75 03 00 00       	call   3b4 <mutex_create>
  3f:	83 c4 10             	add    $0x10,%esp
  42:	89 45 ec             	mov    %eax,-0x14(%ebp)
    muxid4 = mutex_create("mx4", 3);
  45:	83 ec 08             	sub    $0x8,%esp
  48:	6a 03                	push   $0x3
  4a:	68 7c 08 00 00       	push   $0x87c
  4f:	e8 60 03 00 00       	call   3b4 <mutex_create>
  54:	83 c4 10             	add    $0x10,%esp
  57:	89 45 e8             	mov    %eax,-0x18(%ebp)

    printf(0, "muxid1 = %d, muxid2 = %d, muxid3 = %d, muxid4 = %d\n", muxid1, muxid2, muxid3, muxid4);
  5a:	83 ec 08             	sub    $0x8,%esp
  5d:	ff 75 e8             	pushl  -0x18(%ebp)
  60:	ff 75 ec             	pushl  -0x14(%ebp)
  63:	ff 75 f0             	pushl  -0x10(%ebp)
  66:	ff 75 f4             	pushl  -0xc(%ebp)
  69:	68 80 08 00 00       	push   $0x880
  6e:	6a 00                	push   $0x0
  70:	e8 46 04 00 00       	call   4bb <printf>
  75:	83 c4 20             	add    $0x20,%esp

    mutex_delete(muxid1);
  78:	83 ec 0c             	sub    $0xc,%esp
  7b:	ff 75 f4             	pushl  -0xc(%ebp)
  7e:	e8 39 03 00 00       	call   3bc <mutex_delete>
  83:	83 c4 10             	add    $0x10,%esp
    printf(0, "muxid1 deleted\n");
  86:	83 ec 08             	sub    $0x8,%esp
  89:	68 b4 08 00 00       	push   $0x8b4
  8e:	6a 00                	push   $0x0
  90:	e8 26 04 00 00       	call   4bb <printf>
  95:	83 c4 10             	add    $0x10,%esp

}
  98:	90                   	nop
  99:	c9                   	leave  
  9a:	c3                   	ret    

0000009b <main>:



int
main(int args, char** argv)
{
  9b:	55                   	push   %ebp
  9c:	89 e5                	mov    %esp,%ebp
	mutex_unlock(muxid);
    	wait();
    }
*/    

    return 0;
  9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  a3:	5d                   	pop    %ebp
  a4:	c3                   	ret    

000000a5 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  a5:	55                   	push   %ebp
  a6:	89 e5                	mov    %esp,%ebp
  a8:	57                   	push   %edi
  a9:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  ad:	8b 55 10             	mov    0x10(%ebp),%edx
  b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  b3:	89 cb                	mov    %ecx,%ebx
  b5:	89 df                	mov    %ebx,%edi
  b7:	89 d1                	mov    %edx,%ecx
  b9:	fc                   	cld    
  ba:	f3 aa                	rep stos %al,%es:(%edi)
  bc:	89 ca                	mov    %ecx,%edx
  be:	89 fb                	mov    %edi,%ebx
  c0:	89 5d 08             	mov    %ebx,0x8(%ebp)
  c3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  c6:	90                   	nop
  c7:	5b                   	pop    %ebx
  c8:	5f                   	pop    %edi
  c9:	5d                   	pop    %ebp
  ca:	c3                   	ret    

000000cb <strcpy>:
#include "fcntl.h"
#include "user.h"
#include "x86.h"

char *strcpy(char *s, char *t)
{
  cb:	55                   	push   %ebp
  cc:	89 e5                	mov    %esp,%ebp
  ce:	83 ec 10             	sub    $0x10,%esp
	char *os;

	os = s;
  d1:	8b 45 08             	mov    0x8(%ebp),%eax
  d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*s++ = *t++) != 0) ;
  d7:	90                   	nop
  d8:	8b 45 08             	mov    0x8(%ebp),%eax
  db:	8d 50 01             	lea    0x1(%eax),%edx
  de:	89 55 08             	mov    %edx,0x8(%ebp)
  e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  e4:	8d 4a 01             	lea    0x1(%edx),%ecx
  e7:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  ea:	0f b6 12             	movzbl (%edx),%edx
  ed:	88 10                	mov    %dl,(%eax)
  ef:	0f b6 00             	movzbl (%eax),%eax
  f2:	84 c0                	test   %al,%al
  f4:	75 e2                	jne    d8 <strcpy+0xd>
	return os;
  f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  f9:	c9                   	leave  
  fa:	c3                   	ret    

000000fb <strcmp>:

int strcmp(const char *p, const char *q)
{
  fb:	55                   	push   %ebp
  fc:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  fe:	eb 08                	jmp    108 <strcmp+0xd>
		p++, q++;
 100:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 104:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	return os;
}

int strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
 108:	8b 45 08             	mov    0x8(%ebp),%eax
 10b:	0f b6 00             	movzbl (%eax),%eax
 10e:	84 c0                	test   %al,%al
 110:	74 10                	je     122 <strcmp+0x27>
 112:	8b 45 08             	mov    0x8(%ebp),%eax
 115:	0f b6 10             	movzbl (%eax),%edx
 118:	8b 45 0c             	mov    0xc(%ebp),%eax
 11b:	0f b6 00             	movzbl (%eax),%eax
 11e:	38 c2                	cmp    %al,%dl
 120:	74 de                	je     100 <strcmp+0x5>
		p++, q++;
	return (uchar) * p - (uchar) * q;
 122:	8b 45 08             	mov    0x8(%ebp),%eax
 125:	0f b6 00             	movzbl (%eax),%eax
 128:	0f b6 d0             	movzbl %al,%edx
 12b:	8b 45 0c             	mov    0xc(%ebp),%eax
 12e:	0f b6 00             	movzbl (%eax),%eax
 131:	0f b6 c0             	movzbl %al,%eax
 134:	29 c2                	sub    %eax,%edx
 136:	89 d0                	mov    %edx,%eax
}
 138:	5d                   	pop    %ebp
 139:	c3                   	ret    

0000013a <strlen>:

uint strlen(char *s)
{
 13a:	55                   	push   %ebp
 13b:	89 e5                	mov    %esp,%ebp
 13d:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; s[n]; n++) ;
 140:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 147:	eb 04                	jmp    14d <strlen+0x13>
 149:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 14d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 150:	8b 45 08             	mov    0x8(%ebp),%eax
 153:	01 d0                	add    %edx,%eax
 155:	0f b6 00             	movzbl (%eax),%eax
 158:	84 c0                	test   %al,%al
 15a:	75 ed                	jne    149 <strlen+0xf>
	return n;
 15c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 15f:	c9                   	leave  
 160:	c3                   	ret    

00000161 <memset>:

void *memset(void *dst, int c, uint n)
{
 161:	55                   	push   %ebp
 162:	89 e5                	mov    %esp,%ebp
	stosb(dst, c, n);
 164:	8b 45 10             	mov    0x10(%ebp),%eax
 167:	50                   	push   %eax
 168:	ff 75 0c             	pushl  0xc(%ebp)
 16b:	ff 75 08             	pushl  0x8(%ebp)
 16e:	e8 32 ff ff ff       	call   a5 <stosb>
 173:	83 c4 0c             	add    $0xc,%esp
	return dst;
 176:	8b 45 08             	mov    0x8(%ebp),%eax
}
 179:	c9                   	leave  
 17a:	c3                   	ret    

0000017b <strchr>:

char *strchr(const char *s, char c)
{
 17b:	55                   	push   %ebp
 17c:	89 e5                	mov    %esp,%ebp
 17e:	83 ec 04             	sub    $0x4,%esp
 181:	8b 45 0c             	mov    0xc(%ebp),%eax
 184:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
 187:	eb 14                	jmp    19d <strchr+0x22>
		if (*s == c)
 189:	8b 45 08             	mov    0x8(%ebp),%eax
 18c:	0f b6 00             	movzbl (%eax),%eax
 18f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 192:	75 05                	jne    199 <strchr+0x1e>
			return (char *)s;
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	eb 13                	jmp    1ac <strchr+0x31>
	return dst;
}

char *strchr(const char *s, char c)
{
	for (; *s; s++)
 199:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 19d:	8b 45 08             	mov    0x8(%ebp),%eax
 1a0:	0f b6 00             	movzbl (%eax),%eax
 1a3:	84 c0                	test   %al,%al
 1a5:	75 e2                	jne    189 <strchr+0xe>
		if (*s == c)
			return (char *)s;
	return 0;
 1a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1ac:	c9                   	leave  
 1ad:	c3                   	ret    

000001ae <gets>:

char *gets(char *buf, int max)
{
 1ae:	55                   	push   %ebp
 1af:	89 e5                	mov    %esp,%ebp
 1b1:	83 ec 18             	sub    $0x18,%esp
	int i, cc;
	char c;

	for (i = 0; i + 1 < max;) {
 1b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1bb:	eb 42                	jmp    1ff <gets+0x51>
		cc = read(0, &c, 1);
 1bd:	83 ec 04             	sub    $0x4,%esp
 1c0:	6a 01                	push   $0x1
 1c2:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1c5:	50                   	push   %eax
 1c6:	6a 00                	push   $0x0
 1c8:	e8 47 01 00 00       	call   314 <read>
 1cd:	83 c4 10             	add    $0x10,%esp
 1d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (cc < 1)
 1d3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1d7:	7e 33                	jle    20c <gets+0x5e>
			break;
		buf[i++] = c;
 1d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1dc:	8d 50 01             	lea    0x1(%eax),%edx
 1df:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1e2:	89 c2                	mov    %eax,%edx
 1e4:	8b 45 08             	mov    0x8(%ebp),%eax
 1e7:	01 c2                	add    %eax,%edx
 1e9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ed:	88 02                	mov    %al,(%edx)
		if (c == '\n' || c == '\r')
 1ef:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1f3:	3c 0a                	cmp    $0xa,%al
 1f5:	74 16                	je     20d <gets+0x5f>
 1f7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1fb:	3c 0d                	cmp    $0xd,%al
 1fd:	74 0e                	je     20d <gets+0x5f>
char *gets(char *buf, int max)
{
	int i, cc;
	char c;

	for (i = 0; i + 1 < max;) {
 1ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 202:	83 c0 01             	add    $0x1,%eax
 205:	3b 45 0c             	cmp    0xc(%ebp),%eax
 208:	7c b3                	jl     1bd <gets+0xf>
 20a:	eb 01                	jmp    20d <gets+0x5f>
		cc = read(0, &c, 1);
		if (cc < 1)
			break;
 20c:	90                   	nop
		buf[i++] = c;
		if (c == '\n' || c == '\r')
			break;
	}
	buf[i] = '\0';
 20d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 210:	8b 45 08             	mov    0x8(%ebp),%eax
 213:	01 d0                	add    %edx,%eax
 215:	c6 00 00             	movb   $0x0,(%eax)
	return buf;
 218:	8b 45 08             	mov    0x8(%ebp),%eax
}
 21b:	c9                   	leave  
 21c:	c3                   	ret    

0000021d <stat>:

int stat(char *n, struct stat *st)
{
 21d:	55                   	push   %ebp
 21e:	89 e5                	mov    %esp,%ebp
 220:	83 ec 18             	sub    $0x18,%esp
	int fd;
	int r;

	fd = open(n, O_RDONLY);
 223:	83 ec 08             	sub    $0x8,%esp
 226:	6a 00                	push   $0x0
 228:	ff 75 08             	pushl  0x8(%ebp)
 22b:	e8 0c 01 00 00       	call   33c <open>
 230:	83 c4 10             	add    $0x10,%esp
 233:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (fd < 0)
 236:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 23a:	79 07                	jns    243 <stat+0x26>
		return -1;
 23c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 241:	eb 25                	jmp    268 <stat+0x4b>
	r = fstat(fd, st);
 243:	83 ec 08             	sub    $0x8,%esp
 246:	ff 75 0c             	pushl  0xc(%ebp)
 249:	ff 75 f4             	pushl  -0xc(%ebp)
 24c:	e8 03 01 00 00       	call   354 <fstat>
 251:	83 c4 10             	add    $0x10,%esp
 254:	89 45 f0             	mov    %eax,-0x10(%ebp)
	close(fd);
 257:	83 ec 0c             	sub    $0xc,%esp
 25a:	ff 75 f4             	pushl  -0xc(%ebp)
 25d:	e8 c2 00 00 00       	call   324 <close>
 262:	83 c4 10             	add    $0x10,%esp
	return r;
 265:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 268:	c9                   	leave  
 269:	c3                   	ret    

0000026a <atoi>:

int atoi(const char *s)
{
 26a:	55                   	push   %ebp
 26b:	89 e5                	mov    %esp,%ebp
 26d:	83 ec 10             	sub    $0x10,%esp
	int n;

	n = 0;
 270:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	while ('0' <= *s && *s <= '9')
 277:	eb 25                	jmp    29e <atoi+0x34>
		n = n * 10 + *s++ - '0';
 279:	8b 55 fc             	mov    -0x4(%ebp),%edx
 27c:	89 d0                	mov    %edx,%eax
 27e:	c1 e0 02             	shl    $0x2,%eax
 281:	01 d0                	add    %edx,%eax
 283:	01 c0                	add    %eax,%eax
 285:	89 c1                	mov    %eax,%ecx
 287:	8b 45 08             	mov    0x8(%ebp),%eax
 28a:	8d 50 01             	lea    0x1(%eax),%edx
 28d:	89 55 08             	mov    %edx,0x8(%ebp)
 290:	0f b6 00             	movzbl (%eax),%eax
 293:	0f be c0             	movsbl %al,%eax
 296:	01 c8                	add    %ecx,%eax
 298:	83 e8 30             	sub    $0x30,%eax
 29b:	89 45 fc             	mov    %eax,-0x4(%ebp)
int atoi(const char *s)
{
	int n;

	n = 0;
	while ('0' <= *s && *s <= '9')
 29e:	8b 45 08             	mov    0x8(%ebp),%eax
 2a1:	0f b6 00             	movzbl (%eax),%eax
 2a4:	3c 2f                	cmp    $0x2f,%al
 2a6:	7e 0a                	jle    2b2 <atoi+0x48>
 2a8:	8b 45 08             	mov    0x8(%ebp),%eax
 2ab:	0f b6 00             	movzbl (%eax),%eax
 2ae:	3c 39                	cmp    $0x39,%al
 2b0:	7e c7                	jle    279 <atoi+0xf>
		n = n * 10 + *s++ - '0';
	return n;
 2b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2b5:	c9                   	leave  
 2b6:	c3                   	ret    

000002b7 <memmove>:

void *memmove(void *vdst, void *vsrc, int n)
{
 2b7:	55                   	push   %ebp
 2b8:	89 e5                	mov    %esp,%ebp
 2ba:	83 ec 10             	sub    $0x10,%esp
	char *dst, *src;

	dst = vdst;
 2bd:	8b 45 08             	mov    0x8(%ebp),%eax
 2c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	src = vsrc;
 2c3:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
 2c9:	eb 17                	jmp    2e2 <memmove+0x2b>
		*dst++ = *src++;
 2cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2ce:	8d 50 01             	lea    0x1(%eax),%edx
 2d1:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2d4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2d7:	8d 4a 01             	lea    0x1(%edx),%ecx
 2da:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2dd:	0f b6 12             	movzbl (%edx),%edx
 2e0:	88 10                	mov    %dl,(%eax)
{
	char *dst, *src;

	dst = vdst;
	src = vsrc;
	while (n-- > 0)
 2e2:	8b 45 10             	mov    0x10(%ebp),%eax
 2e5:	8d 50 ff             	lea    -0x1(%eax),%edx
 2e8:	89 55 10             	mov    %edx,0x10(%ebp)
 2eb:	85 c0                	test   %eax,%eax
 2ed:	7f dc                	jg     2cb <memmove+0x14>
		*dst++ = *src++;
	return vdst;
 2ef:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2f2:	c9                   	leave  
 2f3:	c3                   	ret    

000002f4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2f4:	b8 01 00 00 00       	mov    $0x1,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <exit>:
SYSCALL(exit)
 2fc:	b8 02 00 00 00       	mov    $0x2,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <wait>:
SYSCALL(wait)
 304:	b8 03 00 00 00       	mov    $0x3,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <pipe>:
SYSCALL(pipe)
 30c:	b8 04 00 00 00       	mov    $0x4,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <read>:
SYSCALL(read)
 314:	b8 05 00 00 00       	mov    $0x5,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <write>:
SYSCALL(write)
 31c:	b8 10 00 00 00       	mov    $0x10,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <close>:
SYSCALL(close)
 324:	b8 15 00 00 00       	mov    $0x15,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <kill>:
SYSCALL(kill)
 32c:	b8 06 00 00 00       	mov    $0x6,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <exec>:
SYSCALL(exec)
 334:	b8 07 00 00 00       	mov    $0x7,%eax
 339:	cd 40                	int    $0x40
 33b:	c3                   	ret    

0000033c <open>:
SYSCALL(open)
 33c:	b8 0f 00 00 00       	mov    $0xf,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret    

00000344 <mknod>:
SYSCALL(mknod)
 344:	b8 11 00 00 00       	mov    $0x11,%eax
 349:	cd 40                	int    $0x40
 34b:	c3                   	ret    

0000034c <unlink>:
SYSCALL(unlink)
 34c:	b8 12 00 00 00       	mov    $0x12,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <fstat>:
SYSCALL(fstat)
 354:	b8 08 00 00 00       	mov    $0x8,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <link>:
SYSCALL(link)
 35c:	b8 13 00 00 00       	mov    $0x13,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <mkdir>:
SYSCALL(mkdir)
 364:	b8 14 00 00 00       	mov    $0x14,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <chdir>:
SYSCALL(chdir)
 36c:	b8 09 00 00 00       	mov    $0x9,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <dup>:
SYSCALL(dup)
 374:	b8 0a 00 00 00       	mov    $0xa,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <getpid>:
SYSCALL(getpid)
 37c:	b8 0b 00 00 00       	mov    $0xb,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <sbrk>:
SYSCALL(sbrk)
 384:	b8 0c 00 00 00       	mov    $0xc,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <sleep>:
SYSCALL(sleep)
 38c:	b8 0d 00 00 00       	mov    $0xd,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <uptime>:
SYSCALL(uptime)
 394:	b8 0e 00 00 00       	mov    $0xe,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <shm_get>:
SYSCALL(shm_get) //mod2
 39c:	b8 1c 00 00 00       	mov    $0x1c,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <shm_rem>:
SYSCALL(shm_rem) //mod2
 3a4:	b8 1d 00 00 00       	mov    $0x1d,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <setHighPrio>:
SYSCALL(setHighPrio) //scheduler
 3ac:	b8 1e 00 00 00       	mov    $0x1e,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <mutex_create>:
SYSCALL(mutex_create)//mod3
 3b4:	b8 16 00 00 00       	mov    $0x16,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <mutex_delete>:
SYSCALL(mutex_delete)
 3bc:	b8 17 00 00 00       	mov    $0x17,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <mutex_lock>:
SYSCALL(mutex_lock)
 3c4:	b8 18 00 00 00       	mov    $0x18,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <mutex_unlock>:
SYSCALL(mutex_unlock)
 3cc:	b8 19 00 00 00       	mov    $0x19,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <cv_wait>:
SYSCALL(cv_wait)
 3d4:	b8 1a 00 00 00       	mov    $0x1a,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <cv_signal>:
SYSCALL(cv_signal)
 3dc:	b8 1b 00 00 00       	mov    $0x1b,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <putc>:
#include "types.h"
#include "stat.h"
#include "user.h"

static void putc(int fd, char c)
{
 3e4:	55                   	push   %ebp
 3e5:	89 e5                	mov    %esp,%ebp
 3e7:	83 ec 18             	sub    $0x18,%esp
 3ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ed:	88 45 f4             	mov    %al,-0xc(%ebp)
	write(fd, &c, 1);
 3f0:	83 ec 04             	sub    $0x4,%esp
 3f3:	6a 01                	push   $0x1
 3f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3f8:	50                   	push   %eax
 3f9:	ff 75 08             	pushl  0x8(%ebp)
 3fc:	e8 1b ff ff ff       	call   31c <write>
 401:	83 c4 10             	add    $0x10,%esp
}
 404:	90                   	nop
 405:	c9                   	leave  
 406:	c3                   	ret    

00000407 <printint>:

static void printint(int fd, int xx, int base, int sgn)
{
 407:	55                   	push   %ebp
 408:	89 e5                	mov    %esp,%ebp
 40a:	53                   	push   %ebx
 40b:	83 ec 24             	sub    $0x24,%esp
	static char digits[] = "0123456789ABCDEF";
	char buf[16];
	int i, neg;
	uint x;

	neg = 0;
 40e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	if (sgn && xx < 0) {
 415:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 419:	74 17                	je     432 <printint+0x2b>
 41b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 41f:	79 11                	jns    432 <printint+0x2b>
		neg = 1;
 421:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
		x = -xx;
 428:	8b 45 0c             	mov    0xc(%ebp),%eax
 42b:	f7 d8                	neg    %eax
 42d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 430:	eb 06                	jmp    438 <printint+0x31>
	} else {
		x = xx;
 432:	8b 45 0c             	mov    0xc(%ebp),%eax
 435:	89 45 ec             	mov    %eax,-0x14(%ebp)
	}

	i = 0;
 438:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	do {
		buf[i++] = digits[x % base];
 43f:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 442:	8d 41 01             	lea    0x1(%ecx),%eax
 445:	89 45 f4             	mov    %eax,-0xc(%ebp)
 448:	8b 5d 10             	mov    0x10(%ebp),%ebx
 44b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 44e:	ba 00 00 00 00       	mov    $0x0,%edx
 453:	f7 f3                	div    %ebx
 455:	89 d0                	mov    %edx,%eax
 457:	0f b6 80 30 0b 00 00 	movzbl 0xb30(%eax),%eax
 45e:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
	} while ((x /= base) != 0);
 462:	8b 5d 10             	mov    0x10(%ebp),%ebx
 465:	8b 45 ec             	mov    -0x14(%ebp),%eax
 468:	ba 00 00 00 00       	mov    $0x0,%edx
 46d:	f7 f3                	div    %ebx
 46f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 472:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 476:	75 c7                	jne    43f <printint+0x38>
	if (neg)
 478:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 47c:	74 2d                	je     4ab <printint+0xa4>
		buf[i++] = '-';
 47e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 481:	8d 50 01             	lea    0x1(%eax),%edx
 484:	89 55 f4             	mov    %edx,-0xc(%ebp)
 487:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

	while (--i >= 0)
 48c:	eb 1d                	jmp    4ab <printint+0xa4>
		putc(fd, buf[i]);
 48e:	8d 55 dc             	lea    -0x24(%ebp),%edx
 491:	8b 45 f4             	mov    -0xc(%ebp),%eax
 494:	01 d0                	add    %edx,%eax
 496:	0f b6 00             	movzbl (%eax),%eax
 499:	0f be c0             	movsbl %al,%eax
 49c:	83 ec 08             	sub    $0x8,%esp
 49f:	50                   	push   %eax
 4a0:	ff 75 08             	pushl  0x8(%ebp)
 4a3:	e8 3c ff ff ff       	call   3e4 <putc>
 4a8:	83 c4 10             	add    $0x10,%esp
		buf[i++] = digits[x % base];
	} while ((x /= base) != 0);
	if (neg)
		buf[i++] = '-';

	while (--i >= 0)
 4ab:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4b3:	79 d9                	jns    48e <printint+0x87>
		putc(fd, buf[i]);
}
 4b5:	90                   	nop
 4b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 4b9:	c9                   	leave  
 4ba:	c3                   	ret    

000004bb <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void printf(int fd, char *fmt, ...)
{
 4bb:	55                   	push   %ebp
 4bc:	89 e5                	mov    %esp,%ebp
 4be:	83 ec 28             	sub    $0x28,%esp
	char *s;
	int c, i, state;
	uint *ap;

	state = 0;
 4c1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	ap = (uint *) (void *)&fmt + 1;
 4c8:	8d 45 0c             	lea    0xc(%ebp),%eax
 4cb:	83 c0 04             	add    $0x4,%eax
 4ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
	for (i = 0; fmt[i]; i++) {
 4d1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4d8:	e9 59 01 00 00       	jmp    636 <printf+0x17b>
		c = fmt[i] & 0xff;
 4dd:	8b 55 0c             	mov    0xc(%ebp),%edx
 4e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4e3:	01 d0                	add    %edx,%eax
 4e5:	0f b6 00             	movzbl (%eax),%eax
 4e8:	0f be c0             	movsbl %al,%eax
 4eb:	25 ff 00 00 00       	and    $0xff,%eax
 4f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (state == 0) {
 4f3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4f7:	75 2c                	jne    525 <printf+0x6a>
			if (c == '%') {
 4f9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4fd:	75 0c                	jne    50b <printf+0x50>
				state = '%';
 4ff:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 506:	e9 27 01 00 00       	jmp    632 <printf+0x177>
			} else {
				putc(fd, c);
 50b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 50e:	0f be c0             	movsbl %al,%eax
 511:	83 ec 08             	sub    $0x8,%esp
 514:	50                   	push   %eax
 515:	ff 75 08             	pushl  0x8(%ebp)
 518:	e8 c7 fe ff ff       	call   3e4 <putc>
 51d:	83 c4 10             	add    $0x10,%esp
 520:	e9 0d 01 00 00       	jmp    632 <printf+0x177>
			}
		} else if (state == '%') {
 525:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 529:	0f 85 03 01 00 00    	jne    632 <printf+0x177>
			if (c == 'd') {
 52f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 533:	75 1e                	jne    553 <printf+0x98>
				printint(fd, *ap, 10, 1);
 535:	8b 45 e8             	mov    -0x18(%ebp),%eax
 538:	8b 00                	mov    (%eax),%eax
 53a:	6a 01                	push   $0x1
 53c:	6a 0a                	push   $0xa
 53e:	50                   	push   %eax
 53f:	ff 75 08             	pushl  0x8(%ebp)
 542:	e8 c0 fe ff ff       	call   407 <printint>
 547:	83 c4 10             	add    $0x10,%esp
				ap++;
 54a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 54e:	e9 d8 00 00 00       	jmp    62b <printf+0x170>
			} else if (c == 'x' || c == 'p') {
 553:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 557:	74 06                	je     55f <printf+0xa4>
 559:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 55d:	75 1e                	jne    57d <printf+0xc2>
				printint(fd, *ap, 16, 0);
 55f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 562:	8b 00                	mov    (%eax),%eax
 564:	6a 00                	push   $0x0
 566:	6a 10                	push   $0x10
 568:	50                   	push   %eax
 569:	ff 75 08             	pushl  0x8(%ebp)
 56c:	e8 96 fe ff ff       	call   407 <printint>
 571:	83 c4 10             	add    $0x10,%esp
				ap++;
 574:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 578:	e9 ae 00 00 00       	jmp    62b <printf+0x170>
			} else if (c == 's') {
 57d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 581:	75 43                	jne    5c6 <printf+0x10b>
				s = (char *)*ap;
 583:	8b 45 e8             	mov    -0x18(%ebp),%eax
 586:	8b 00                	mov    (%eax),%eax
 588:	89 45 f4             	mov    %eax,-0xc(%ebp)
				ap++;
 58b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
				if (s == 0)
 58f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 593:	75 25                	jne    5ba <printf+0xff>
					s = "(null)";
 595:	c7 45 f4 c4 08 00 00 	movl   $0x8c4,-0xc(%ebp)
				while (*s != 0) {
 59c:	eb 1c                	jmp    5ba <printf+0xff>
					putc(fd, *s);
 59e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a1:	0f b6 00             	movzbl (%eax),%eax
 5a4:	0f be c0             	movsbl %al,%eax
 5a7:	83 ec 08             	sub    $0x8,%esp
 5aa:	50                   	push   %eax
 5ab:	ff 75 08             	pushl  0x8(%ebp)
 5ae:	e8 31 fe ff ff       	call   3e4 <putc>
 5b3:	83 c4 10             	add    $0x10,%esp
					s++;
 5b6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
			} else if (c == 's') {
				s = (char *)*ap;
				ap++;
				if (s == 0)
					s = "(null)";
				while (*s != 0) {
 5ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5bd:	0f b6 00             	movzbl (%eax),%eax
 5c0:	84 c0                	test   %al,%al
 5c2:	75 da                	jne    59e <printf+0xe3>
 5c4:	eb 65                	jmp    62b <printf+0x170>
					putc(fd, *s);
					s++;
				}
			} else if (c == 'c') {
 5c6:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5ca:	75 1d                	jne    5e9 <printf+0x12e>
				putc(fd, *ap);
 5cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5cf:	8b 00                	mov    (%eax),%eax
 5d1:	0f be c0             	movsbl %al,%eax
 5d4:	83 ec 08             	sub    $0x8,%esp
 5d7:	50                   	push   %eax
 5d8:	ff 75 08             	pushl  0x8(%ebp)
 5db:	e8 04 fe ff ff       	call   3e4 <putc>
 5e0:	83 c4 10             	add    $0x10,%esp
				ap++;
 5e3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e7:	eb 42                	jmp    62b <printf+0x170>
			} else if (c == '%') {
 5e9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5ed:	75 17                	jne    606 <printf+0x14b>
				putc(fd, c);
 5ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5f2:	0f be c0             	movsbl %al,%eax
 5f5:	83 ec 08             	sub    $0x8,%esp
 5f8:	50                   	push   %eax
 5f9:	ff 75 08             	pushl  0x8(%ebp)
 5fc:	e8 e3 fd ff ff       	call   3e4 <putc>
 601:	83 c4 10             	add    $0x10,%esp
 604:	eb 25                	jmp    62b <printf+0x170>
			} else {
				// Unknown % sequence.  Print it to draw attention.
				putc(fd, '%');
 606:	83 ec 08             	sub    $0x8,%esp
 609:	6a 25                	push   $0x25
 60b:	ff 75 08             	pushl  0x8(%ebp)
 60e:	e8 d1 fd ff ff       	call   3e4 <putc>
 613:	83 c4 10             	add    $0x10,%esp
				putc(fd, c);
 616:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 619:	0f be c0             	movsbl %al,%eax
 61c:	83 ec 08             	sub    $0x8,%esp
 61f:	50                   	push   %eax
 620:	ff 75 08             	pushl  0x8(%ebp)
 623:	e8 bc fd ff ff       	call   3e4 <putc>
 628:	83 c4 10             	add    $0x10,%esp
			}
			state = 0;
 62b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int c, i, state;
	uint *ap;

	state = 0;
	ap = (uint *) (void *)&fmt + 1;
	for (i = 0; fmt[i]; i++) {
 632:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 636:	8b 55 0c             	mov    0xc(%ebp),%edx
 639:	8b 45 f0             	mov    -0x10(%ebp),%eax
 63c:	01 d0                	add    %edx,%eax
 63e:	0f b6 00             	movzbl (%eax),%eax
 641:	84 c0                	test   %al,%al
 643:	0f 85 94 fe ff ff    	jne    4dd <printf+0x22>
				putc(fd, c);
			}
			state = 0;
		}
	}
}
 649:	90                   	nop
 64a:	c9                   	leave  
 64b:	c3                   	ret    

0000064c <free>:

static Header base;
static Header *freep;

void free(void *ap)
{
 64c:	55                   	push   %ebp
 64d:	89 e5                	mov    %esp,%ebp
 64f:	83 ec 10             	sub    $0x10,%esp
	Header *bp, *p;

	bp = (Header *) ap - 1; //take address of memory -> subtract one size of p to get to header to memeory
 652:	8b 45 08             	mov    0x8(%ebp),%eax
 655:	83 e8 08             	sub    $0x8,%eax
 658:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr) //comparing pointers to headers...maybe ordering spatially...
 65b:	a1 4c 0b 00 00       	mov    0xb4c,%eax
 660:	89 45 fc             	mov    %eax,-0x4(%ebp)
 663:	eb 24                	jmp    689 <free+0x3d>
		if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 665:	8b 45 fc             	mov    -0x4(%ebp),%eax
 668:	8b 00                	mov    (%eax),%eax
 66a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 66d:	77 12                	ja     681 <free+0x35>
 66f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 672:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 675:	77 24                	ja     69b <free+0x4f>
 677:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67a:	8b 00                	mov    (%eax),%eax
 67c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 67f:	77 1a                	ja     69b <free+0x4f>
void free(void *ap)
{
	Header *bp, *p;

	bp = (Header *) ap - 1; //take address of memory -> subtract one size of p to get to header to memeory
	for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr) //comparing pointers to headers...maybe ordering spatially...
 681:	8b 45 fc             	mov    -0x4(%ebp),%eax
 684:	8b 00                	mov    (%eax),%eax
 686:	89 45 fc             	mov    %eax,-0x4(%ebp)
 689:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 68f:	76 d4                	jbe    665 <free+0x19>
 691:	8b 45 fc             	mov    -0x4(%ebp),%eax
 694:	8b 00                	mov    (%eax),%eax
 696:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 699:	76 ca                	jbe    665 <free+0x19>
		if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
			break;
	if (bp + bp->s.size == p->s.ptr) { //checks sizes to merge contiguous freed regions
 69b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69e:	8b 40 04             	mov    0x4(%eax),%eax
 6a1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ab:	01 c2                	add    %eax,%edx
 6ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b0:	8b 00                	mov    (%eax),%eax
 6b2:	39 c2                	cmp    %eax,%edx
 6b4:	75 24                	jne    6da <free+0x8e>
		bp->s.size += p->s.ptr->s.size;
 6b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b9:	8b 50 04             	mov    0x4(%eax),%edx
 6bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bf:	8b 00                	mov    (%eax),%eax
 6c1:	8b 40 04             	mov    0x4(%eax),%eax
 6c4:	01 c2                	add    %eax,%edx
 6c6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c9:	89 50 04             	mov    %edx,0x4(%eax)
		bp->s.ptr = p->s.ptr->s.ptr;
 6cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cf:	8b 00                	mov    (%eax),%eax
 6d1:	8b 10                	mov    (%eax),%edx
 6d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d6:	89 10                	mov    %edx,(%eax)
 6d8:	eb 0a                	jmp    6e4 <free+0x98>
	} else
		bp->s.ptr = p->s.ptr;
 6da:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6dd:	8b 10                	mov    (%eax),%edx
 6df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e2:	89 10                	mov    %edx,(%eax)
	if (p + p->s.size == bp) {
 6e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e7:	8b 40 04             	mov    0x4(%eax),%eax
 6ea:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f4:	01 d0                	add    %edx,%eax
 6f6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6f9:	75 20                	jne    71b <free+0xcf>
		p->s.size += bp->s.size;
 6fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fe:	8b 50 04             	mov    0x4(%eax),%edx
 701:	8b 45 f8             	mov    -0x8(%ebp),%eax
 704:	8b 40 04             	mov    0x4(%eax),%eax
 707:	01 c2                	add    %eax,%edx
 709:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70c:	89 50 04             	mov    %edx,0x4(%eax)
		p->s.ptr = bp->s.ptr;
 70f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 712:	8b 10                	mov    (%eax),%edx
 714:	8b 45 fc             	mov    -0x4(%ebp),%eax
 717:	89 10                	mov    %edx,(%eax)
 719:	eb 08                	jmp    723 <free+0xd7>
	} else
		p->s.ptr = bp;
 71b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 721:	89 10                	mov    %edx,(%eax)
	freep = p;
 723:	8b 45 fc             	mov    -0x4(%ebp),%eax
 726:	a3 4c 0b 00 00       	mov    %eax,0xb4c
}
 72b:	90                   	nop
 72c:	c9                   	leave  
 72d:	c3                   	ret    

0000072e <morecore>:

static Header *morecore(uint nu)
{
 72e:	55                   	push   %ebp
 72f:	89 e5                	mov    %esp,%ebp
 731:	83 ec 18             	sub    $0x18,%esp
	char *p;
	Header *hp;

	if (nu < 4096)
 734:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 73b:	77 07                	ja     744 <morecore+0x16>
		nu = 4096;
 73d:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
	p = sbrk(nu * sizeof(Header));
 744:	8b 45 08             	mov    0x8(%ebp),%eax
 747:	c1 e0 03             	shl    $0x3,%eax
 74a:	83 ec 0c             	sub    $0xc,%esp
 74d:	50                   	push   %eax
 74e:	e8 31 fc ff ff       	call   384 <sbrk>
 753:	83 c4 10             	add    $0x10,%esp
 756:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (p == (char *)-1)
 759:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 75d:	75 07                	jne    766 <morecore+0x38>
		return 0;
 75f:	b8 00 00 00 00       	mov    $0x0,%eax
 764:	eb 26                	jmp    78c <morecore+0x5e>
	hp = (Header *) p;
 766:	8b 45 f4             	mov    -0xc(%ebp),%eax
 769:	89 45 f0             	mov    %eax,-0x10(%ebp)
	hp->s.size = nu;
 76c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76f:	8b 55 08             	mov    0x8(%ebp),%edx
 772:	89 50 04             	mov    %edx,0x4(%eax)
	free((void *)(hp + 1));
 775:	8b 45 f0             	mov    -0x10(%ebp),%eax
 778:	83 c0 08             	add    $0x8,%eax
 77b:	83 ec 0c             	sub    $0xc,%esp
 77e:	50                   	push   %eax
 77f:	e8 c8 fe ff ff       	call   64c <free>
 784:	83 c4 10             	add    $0x10,%esp
	return freep;
 787:	a1 4c 0b 00 00       	mov    0xb4c,%eax
}
 78c:	c9                   	leave  
 78d:	c3                   	ret    

0000078e <malloc>:

void *malloc(uint nbytes)
{
 78e:	55                   	push   %ebp
 78f:	89 e5                	mov    %esp,%ebp
 791:	83 ec 18             	sub    $0x18,%esp
	Header *p, *prevp;
	uint nunits;

	nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 794:	8b 45 08             	mov    0x8(%ebp),%eax
 797:	83 c0 07             	add    $0x7,%eax
 79a:	c1 e8 03             	shr    $0x3,%eax
 79d:	83 c0 01             	add    $0x1,%eax
 7a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if ((prevp = freep) == 0) {
 7a3:	a1 4c 0b 00 00       	mov    0xb4c,%eax
 7a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7af:	75 23                	jne    7d4 <malloc+0x46>
		base.s.ptr = freep = prevp = &base;
 7b1:	c7 45 f0 44 0b 00 00 	movl   $0xb44,-0x10(%ebp)
 7b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7bb:	a3 4c 0b 00 00       	mov    %eax,0xb4c
 7c0:	a1 4c 0b 00 00       	mov    0xb4c,%eax
 7c5:	a3 44 0b 00 00       	mov    %eax,0xb44
		base.s.size = 0;
 7ca:	c7 05 48 0b 00 00 00 	movl   $0x0,0xb48
 7d1:	00 00 00 
	}
	for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 7d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d7:	8b 00                	mov    (%eax),%eax
 7d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if (p->s.size >= nunits) {
 7dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7df:	8b 40 04             	mov    0x4(%eax),%eax
 7e2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7e5:	72 4d                	jb     834 <malloc+0xa6>
			if (p->s.size == nunits)
 7e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ea:	8b 40 04             	mov    0x4(%eax),%eax
 7ed:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7f0:	75 0c                	jne    7fe <malloc+0x70>
				prevp->s.ptr = p->s.ptr;
 7f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f5:	8b 10                	mov    (%eax),%edx
 7f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fa:	89 10                	mov    %edx,(%eax)
 7fc:	eb 26                	jmp    824 <malloc+0x96>
			else {
				p->s.size -= nunits;
 7fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 801:	8b 40 04             	mov    0x4(%eax),%eax
 804:	2b 45 ec             	sub    -0x14(%ebp),%eax
 807:	89 c2                	mov    %eax,%edx
 809:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80c:	89 50 04             	mov    %edx,0x4(%eax)
				p += p->s.size;
 80f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 812:	8b 40 04             	mov    0x4(%eax),%eax
 815:	c1 e0 03             	shl    $0x3,%eax
 818:	01 45 f4             	add    %eax,-0xc(%ebp)
				p->s.size = nunits;
 81b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81e:	8b 55 ec             	mov    -0x14(%ebp),%edx
 821:	89 50 04             	mov    %edx,0x4(%eax)
			}
			freep = prevp;
 824:	8b 45 f0             	mov    -0x10(%ebp),%eax
 827:	a3 4c 0b 00 00       	mov    %eax,0xb4c
			//printf(0, "\nMalloc Pointer Value = %p\n", p+1);
			return (void *)(p + 1);
 82c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82f:	83 c0 08             	add    $0x8,%eax
 832:	eb 3b                	jmp    86f <malloc+0xe1>
		}
		if (p == freep)
 834:	a1 4c 0b 00 00       	mov    0xb4c,%eax
 839:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 83c:	75 1e                	jne    85c <malloc+0xce>
			if ((p = morecore(nunits)) == 0)
 83e:	83 ec 0c             	sub    $0xc,%esp
 841:	ff 75 ec             	pushl  -0x14(%ebp)
 844:	e8 e5 fe ff ff       	call   72e <morecore>
 849:	83 c4 10             	add    $0x10,%esp
 84c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 84f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 853:	75 07                	jne    85c <malloc+0xce>
				return 0;
 855:	b8 00 00 00 00       	mov    $0x0,%eax
 85a:	eb 13                	jmp    86f <malloc+0xe1>
	nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
	if ((prevp = freep) == 0) {
		base.s.ptr = freep = prevp = &base;
		base.s.size = 0;
	}
	for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 85c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 862:	8b 45 f4             	mov    -0xc(%ebp),%eax
 865:	8b 00                	mov    (%eax),%eax
 867:	89 45 f4             	mov    %eax,-0xc(%ebp)
			return (void *)(p + 1);
		}
		if (p == freep)
			if ((p = morecore(nunits)) == 0)
				return 0;
	}
 86a:	e9 6d ff ff ff       	jmp    7dc <malloc+0x4e>
}
 86f:	c9                   	leave  
 870:	c3                   	ret    
