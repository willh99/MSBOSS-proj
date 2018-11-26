
_prio_test:     file format elf32-i386


Disassembly of section .text:

00000000 <high_prio>:

volatile int sleeping = 0;

void
high_prio(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
	//setprio(10);
	while (1) {
		int i;

		for (i = 0 ; i < 10 ; i++) {
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
   d:	eb 16                	jmp    25 <high_prio+0x25>
			printf(1, "h");
   f:	83 ec 08             	sub    $0x8,%esp
  12:	68 c9 08 00 00       	push   $0x8c9
  17:	6a 01                	push   $0x1
  19:	e8 f5 04 00 00       	call   513 <printf>
  1e:	83 c4 10             	add    $0x10,%esp
{
	//setprio(10);
	while (1) {
		int i;

		for (i = 0 ; i < 10 ; i++) {
  21:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  25:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  29:	7e e4                	jle    f <high_prio+0xf>
			printf(1, "h");
		}
		if (sleeping) sleep(1);
  2b:	a1 74 0b 00 00       	mov    0xb74,%eax
  30:	85 c0                	test   %eax,%eax
  32:	74 d2                	je     6 <high_prio+0x6>
  34:	83 ec 0c             	sub    $0xc,%esp
  37:	6a 01                	push   $0x1
  39:	e8 a6 03 00 00       	call   3e4 <sleep>
  3e:	83 c4 10             	add    $0x10,%esp
	}
  41:	eb c3                	jmp    6 <high_prio+0x6>

00000043 <low_prio>:
}

void
low_prio(void)
{
  43:	55                   	push   %ebp
  44:	89 e5                	mov    %esp,%ebp
  46:	83 ec 08             	sub    $0x8,%esp
	while (1) {
		printf(1, "l");
  49:	83 ec 08             	sub    $0x8,%esp
  4c:	68 cb 08 00 00       	push   $0x8cb
  51:	6a 01                	push   $0x1
  53:	e8 bb 04 00 00       	call   513 <printf>
  58:	83 c4 10             	add    $0x10,%esp
	}
  5b:	eb ec                	jmp    49 <low_prio+0x6>

0000005d <main>:
}

int
main(int argc, char *argv[])
{
  5d:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  61:	83 e4 f0             	and    $0xfffffff0,%esp
  64:	ff 71 fc             	pushl  -0x4(%ecx)
  67:	55                   	push   %ebp
  68:	89 e5                	mov    %esp,%ebp
  6a:	51                   	push   %ecx
  6b:	83 ec 14             	sub    $0x14,%esp
  6e:	89 c8                	mov    %ecx,%eax
	int pidh, pidl;

	if (argc == 2 && !strcmp(argv[1], "-s")) {
  70:	83 38 02             	cmpl   $0x2,(%eax)
  73:	75 27                	jne    9c <main+0x3f>
  75:	8b 40 04             	mov    0x4(%eax),%eax
  78:	83 c0 04             	add    $0x4,%eax
  7b:	8b 00                	mov    (%eax),%eax
  7d:	83 ec 08             	sub    $0x8,%esp
  80:	68 cd 08 00 00       	push   $0x8cd
  85:	50                   	push   %eax
  86:	e8 c8 00 00 00       	call   153 <strcmp>
  8b:	83 c4 10             	add    $0x10,%esp
  8e:	85 c0                	test   %eax,%eax
  90:	75 0a                	jne    9c <main+0x3f>
		sleeping = 1;
  92:	c7 05 74 0b 00 00 01 	movl   $0x1,0xb74
  99:	00 00 00 
	}


	pidh = fork();
  9c:	e8 ab 02 00 00       	call   34c <fork>
  a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (pidh < 0) exit();
  a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  a8:	79 05                	jns    af <main+0x52>
  aa:	e8 a5 02 00 00       	call   354 <exit>
	if (pidh == 0) {
  af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  b3:	75 0c                	jne    c1 <main+0x64>
		high_prio();
  b5:	e8 46 ff ff ff       	call   0 <high_prio>
		return 0;
  ba:	b8 00 00 00 00       	mov    $0x0,%eax
  bf:	eb 34                	jmp    f5 <main+0x98>
	}

	pidl = fork();
  c1:	e8 86 02 00 00       	call   34c <fork>
  c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (pidl < 0) exit();
  c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  cd:	79 05                	jns    d4 <main+0x77>
  cf:	e8 80 02 00 00       	call   354 <exit>
	if (pidl == 0) {
  d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  d8:	75 0c                	jne    e6 <main+0x89>
		low_prio();
  da:	e8 64 ff ff ff       	call   43 <low_prio>
		return 0;
  df:	b8 00 00 00 00       	mov    $0x0,%eax
  e4:	eb 0f                	jmp    f5 <main+0x98>
	}
	wait();
  e6:	e8 71 02 00 00       	call   35c <wait>
	wait();
  eb:	e8 6c 02 00 00       	call   35c <wait>

	return 0;
  f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  f5:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  f8:	c9                   	leave  
  f9:	8d 61 fc             	lea    -0x4(%ecx),%esp
  fc:	c3                   	ret    

000000fd <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  fd:	55                   	push   %ebp
  fe:	89 e5                	mov    %esp,%ebp
 100:	57                   	push   %edi
 101:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 102:	8b 4d 08             	mov    0x8(%ebp),%ecx
 105:	8b 55 10             	mov    0x10(%ebp),%edx
 108:	8b 45 0c             	mov    0xc(%ebp),%eax
 10b:	89 cb                	mov    %ecx,%ebx
 10d:	89 df                	mov    %ebx,%edi
 10f:	89 d1                	mov    %edx,%ecx
 111:	fc                   	cld    
 112:	f3 aa                	rep stos %al,%es:(%edi)
 114:	89 ca                	mov    %ecx,%edx
 116:	89 fb                	mov    %edi,%ebx
 118:	89 5d 08             	mov    %ebx,0x8(%ebp)
 11b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 11e:	90                   	nop
 11f:	5b                   	pop    %ebx
 120:	5f                   	pop    %edi
 121:	5d                   	pop    %ebp
 122:	c3                   	ret    

00000123 <strcpy>:
#include "fcntl.h"
#include "user.h"
#include "x86.h"

char *strcpy(char *s, char *t)
{
 123:	55                   	push   %ebp
 124:	89 e5                	mov    %esp,%ebp
 126:	83 ec 10             	sub    $0x10,%esp
	char *os;

	os = s;
 129:	8b 45 08             	mov    0x8(%ebp),%eax
 12c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*s++ = *t++) != 0) ;
 12f:	90                   	nop
 130:	8b 45 08             	mov    0x8(%ebp),%eax
 133:	8d 50 01             	lea    0x1(%eax),%edx
 136:	89 55 08             	mov    %edx,0x8(%ebp)
 139:	8b 55 0c             	mov    0xc(%ebp),%edx
 13c:	8d 4a 01             	lea    0x1(%edx),%ecx
 13f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 142:	0f b6 12             	movzbl (%edx),%edx
 145:	88 10                	mov    %dl,(%eax)
 147:	0f b6 00             	movzbl (%eax),%eax
 14a:	84 c0                	test   %al,%al
 14c:	75 e2                	jne    130 <strcpy+0xd>
	return os;
 14e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 151:	c9                   	leave  
 152:	c3                   	ret    

00000153 <strcmp>:

int strcmp(const char *p, const char *q)
{
 153:	55                   	push   %ebp
 154:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
 156:	eb 08                	jmp    160 <strcmp+0xd>
		p++, q++;
 158:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 15c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	return os;
}

int strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
 160:	8b 45 08             	mov    0x8(%ebp),%eax
 163:	0f b6 00             	movzbl (%eax),%eax
 166:	84 c0                	test   %al,%al
 168:	74 10                	je     17a <strcmp+0x27>
 16a:	8b 45 08             	mov    0x8(%ebp),%eax
 16d:	0f b6 10             	movzbl (%eax),%edx
 170:	8b 45 0c             	mov    0xc(%ebp),%eax
 173:	0f b6 00             	movzbl (%eax),%eax
 176:	38 c2                	cmp    %al,%dl
 178:	74 de                	je     158 <strcmp+0x5>
		p++, q++;
	return (uchar) * p - (uchar) * q;
 17a:	8b 45 08             	mov    0x8(%ebp),%eax
 17d:	0f b6 00             	movzbl (%eax),%eax
 180:	0f b6 d0             	movzbl %al,%edx
 183:	8b 45 0c             	mov    0xc(%ebp),%eax
 186:	0f b6 00             	movzbl (%eax),%eax
 189:	0f b6 c0             	movzbl %al,%eax
 18c:	29 c2                	sub    %eax,%edx
 18e:	89 d0                	mov    %edx,%eax
}
 190:	5d                   	pop    %ebp
 191:	c3                   	ret    

00000192 <strlen>:

uint strlen(char *s)
{
 192:	55                   	push   %ebp
 193:	89 e5                	mov    %esp,%ebp
 195:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; s[n]; n++) ;
 198:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 19f:	eb 04                	jmp    1a5 <strlen+0x13>
 1a1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1a5:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1a8:	8b 45 08             	mov    0x8(%ebp),%eax
 1ab:	01 d0                	add    %edx,%eax
 1ad:	0f b6 00             	movzbl (%eax),%eax
 1b0:	84 c0                	test   %al,%al
 1b2:	75 ed                	jne    1a1 <strlen+0xf>
	return n;
 1b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1b7:	c9                   	leave  
 1b8:	c3                   	ret    

000001b9 <memset>:

void *memset(void *dst, int c, uint n)
{
 1b9:	55                   	push   %ebp
 1ba:	89 e5                	mov    %esp,%ebp
	stosb(dst, c, n);
 1bc:	8b 45 10             	mov    0x10(%ebp),%eax
 1bf:	50                   	push   %eax
 1c0:	ff 75 0c             	pushl  0xc(%ebp)
 1c3:	ff 75 08             	pushl  0x8(%ebp)
 1c6:	e8 32 ff ff ff       	call   fd <stosb>
 1cb:	83 c4 0c             	add    $0xc,%esp
	return dst;
 1ce:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1d1:	c9                   	leave  
 1d2:	c3                   	ret    

000001d3 <strchr>:

char *strchr(const char *s, char c)
{
 1d3:	55                   	push   %ebp
 1d4:	89 e5                	mov    %esp,%ebp
 1d6:	83 ec 04             	sub    $0x4,%esp
 1d9:	8b 45 0c             	mov    0xc(%ebp),%eax
 1dc:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
 1df:	eb 14                	jmp    1f5 <strchr+0x22>
		if (*s == c)
 1e1:	8b 45 08             	mov    0x8(%ebp),%eax
 1e4:	0f b6 00             	movzbl (%eax),%eax
 1e7:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1ea:	75 05                	jne    1f1 <strchr+0x1e>
			return (char *)s;
 1ec:	8b 45 08             	mov    0x8(%ebp),%eax
 1ef:	eb 13                	jmp    204 <strchr+0x31>
	return dst;
}

char *strchr(const char *s, char c)
{
	for (; *s; s++)
 1f1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1f5:	8b 45 08             	mov    0x8(%ebp),%eax
 1f8:	0f b6 00             	movzbl (%eax),%eax
 1fb:	84 c0                	test   %al,%al
 1fd:	75 e2                	jne    1e1 <strchr+0xe>
		if (*s == c)
			return (char *)s;
	return 0;
 1ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
 204:	c9                   	leave  
 205:	c3                   	ret    

00000206 <gets>:

char *gets(char *buf, int max)
{
 206:	55                   	push   %ebp
 207:	89 e5                	mov    %esp,%ebp
 209:	83 ec 18             	sub    $0x18,%esp
	int i, cc;
	char c;

	for (i = 0; i + 1 < max;) {
 20c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 213:	eb 42                	jmp    257 <gets+0x51>
		cc = read(0, &c, 1);
 215:	83 ec 04             	sub    $0x4,%esp
 218:	6a 01                	push   $0x1
 21a:	8d 45 ef             	lea    -0x11(%ebp),%eax
 21d:	50                   	push   %eax
 21e:	6a 00                	push   $0x0
 220:	e8 47 01 00 00       	call   36c <read>
 225:	83 c4 10             	add    $0x10,%esp
 228:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (cc < 1)
 22b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 22f:	7e 33                	jle    264 <gets+0x5e>
			break;
		buf[i++] = c;
 231:	8b 45 f4             	mov    -0xc(%ebp),%eax
 234:	8d 50 01             	lea    0x1(%eax),%edx
 237:	89 55 f4             	mov    %edx,-0xc(%ebp)
 23a:	89 c2                	mov    %eax,%edx
 23c:	8b 45 08             	mov    0x8(%ebp),%eax
 23f:	01 c2                	add    %eax,%edx
 241:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 245:	88 02                	mov    %al,(%edx)
		if (c == '\n' || c == '\r')
 247:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 24b:	3c 0a                	cmp    $0xa,%al
 24d:	74 16                	je     265 <gets+0x5f>
 24f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 253:	3c 0d                	cmp    $0xd,%al
 255:	74 0e                	je     265 <gets+0x5f>
char *gets(char *buf, int max)
{
	int i, cc;
	char c;

	for (i = 0; i + 1 < max;) {
 257:	8b 45 f4             	mov    -0xc(%ebp),%eax
 25a:	83 c0 01             	add    $0x1,%eax
 25d:	3b 45 0c             	cmp    0xc(%ebp),%eax
 260:	7c b3                	jl     215 <gets+0xf>
 262:	eb 01                	jmp    265 <gets+0x5f>
		cc = read(0, &c, 1);
		if (cc < 1)
			break;
 264:	90                   	nop
		buf[i++] = c;
		if (c == '\n' || c == '\r')
			break;
	}
	buf[i] = '\0';
 265:	8b 55 f4             	mov    -0xc(%ebp),%edx
 268:	8b 45 08             	mov    0x8(%ebp),%eax
 26b:	01 d0                	add    %edx,%eax
 26d:	c6 00 00             	movb   $0x0,(%eax)
	return buf;
 270:	8b 45 08             	mov    0x8(%ebp),%eax
}
 273:	c9                   	leave  
 274:	c3                   	ret    

00000275 <stat>:

int stat(char *n, struct stat *st)
{
 275:	55                   	push   %ebp
 276:	89 e5                	mov    %esp,%ebp
 278:	83 ec 18             	sub    $0x18,%esp
	int fd;
	int r;

	fd = open(n, O_RDONLY);
 27b:	83 ec 08             	sub    $0x8,%esp
 27e:	6a 00                	push   $0x0
 280:	ff 75 08             	pushl  0x8(%ebp)
 283:	e8 0c 01 00 00       	call   394 <open>
 288:	83 c4 10             	add    $0x10,%esp
 28b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (fd < 0)
 28e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 292:	79 07                	jns    29b <stat+0x26>
		return -1;
 294:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 299:	eb 25                	jmp    2c0 <stat+0x4b>
	r = fstat(fd, st);
 29b:	83 ec 08             	sub    $0x8,%esp
 29e:	ff 75 0c             	pushl  0xc(%ebp)
 2a1:	ff 75 f4             	pushl  -0xc(%ebp)
 2a4:	e8 03 01 00 00       	call   3ac <fstat>
 2a9:	83 c4 10             	add    $0x10,%esp
 2ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
	close(fd);
 2af:	83 ec 0c             	sub    $0xc,%esp
 2b2:	ff 75 f4             	pushl  -0xc(%ebp)
 2b5:	e8 c2 00 00 00       	call   37c <close>
 2ba:	83 c4 10             	add    $0x10,%esp
	return r;
 2bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2c0:	c9                   	leave  
 2c1:	c3                   	ret    

000002c2 <atoi>:

int atoi(const char *s)
{
 2c2:	55                   	push   %ebp
 2c3:	89 e5                	mov    %esp,%ebp
 2c5:	83 ec 10             	sub    $0x10,%esp
	int n;

	n = 0;
 2c8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	while ('0' <= *s && *s <= '9')
 2cf:	eb 25                	jmp    2f6 <atoi+0x34>
		n = n * 10 + *s++ - '0';
 2d1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2d4:	89 d0                	mov    %edx,%eax
 2d6:	c1 e0 02             	shl    $0x2,%eax
 2d9:	01 d0                	add    %edx,%eax
 2db:	01 c0                	add    %eax,%eax
 2dd:	89 c1                	mov    %eax,%ecx
 2df:	8b 45 08             	mov    0x8(%ebp),%eax
 2e2:	8d 50 01             	lea    0x1(%eax),%edx
 2e5:	89 55 08             	mov    %edx,0x8(%ebp)
 2e8:	0f b6 00             	movzbl (%eax),%eax
 2eb:	0f be c0             	movsbl %al,%eax
 2ee:	01 c8                	add    %ecx,%eax
 2f0:	83 e8 30             	sub    $0x30,%eax
 2f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
int atoi(const char *s)
{
	int n;

	n = 0;
	while ('0' <= *s && *s <= '9')
 2f6:	8b 45 08             	mov    0x8(%ebp),%eax
 2f9:	0f b6 00             	movzbl (%eax),%eax
 2fc:	3c 2f                	cmp    $0x2f,%al
 2fe:	7e 0a                	jle    30a <atoi+0x48>
 300:	8b 45 08             	mov    0x8(%ebp),%eax
 303:	0f b6 00             	movzbl (%eax),%eax
 306:	3c 39                	cmp    $0x39,%al
 308:	7e c7                	jle    2d1 <atoi+0xf>
		n = n * 10 + *s++ - '0';
	return n;
 30a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 30d:	c9                   	leave  
 30e:	c3                   	ret    

0000030f <memmove>:

void *memmove(void *vdst, void *vsrc, int n)
{
 30f:	55                   	push   %ebp
 310:	89 e5                	mov    %esp,%ebp
 312:	83 ec 10             	sub    $0x10,%esp
	char *dst, *src;

	dst = vdst;
 315:	8b 45 08             	mov    0x8(%ebp),%eax
 318:	89 45 fc             	mov    %eax,-0x4(%ebp)
	src = vsrc;
 31b:	8b 45 0c             	mov    0xc(%ebp),%eax
 31e:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
 321:	eb 17                	jmp    33a <memmove+0x2b>
		*dst++ = *src++;
 323:	8b 45 fc             	mov    -0x4(%ebp),%eax
 326:	8d 50 01             	lea    0x1(%eax),%edx
 329:	89 55 fc             	mov    %edx,-0x4(%ebp)
 32c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 32f:	8d 4a 01             	lea    0x1(%edx),%ecx
 332:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 335:	0f b6 12             	movzbl (%edx),%edx
 338:	88 10                	mov    %dl,(%eax)
{
	char *dst, *src;

	dst = vdst;
	src = vsrc;
	while (n-- > 0)
 33a:	8b 45 10             	mov    0x10(%ebp),%eax
 33d:	8d 50 ff             	lea    -0x1(%eax),%edx
 340:	89 55 10             	mov    %edx,0x10(%ebp)
 343:	85 c0                	test   %eax,%eax
 345:	7f dc                	jg     323 <memmove+0x14>
		*dst++ = *src++;
	return vdst;
 347:	8b 45 08             	mov    0x8(%ebp),%eax
}
 34a:	c9                   	leave  
 34b:	c3                   	ret    

0000034c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 34c:	b8 01 00 00 00       	mov    $0x1,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <exit>:
SYSCALL(exit)
 354:	b8 02 00 00 00       	mov    $0x2,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <wait>:
SYSCALL(wait)
 35c:	b8 03 00 00 00       	mov    $0x3,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <pipe>:
SYSCALL(pipe)
 364:	b8 04 00 00 00       	mov    $0x4,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <read>:
SYSCALL(read)
 36c:	b8 05 00 00 00       	mov    $0x5,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <write>:
SYSCALL(write)
 374:	b8 10 00 00 00       	mov    $0x10,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <close>:
SYSCALL(close)
 37c:	b8 15 00 00 00       	mov    $0x15,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <kill>:
SYSCALL(kill)
 384:	b8 06 00 00 00       	mov    $0x6,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <exec>:
SYSCALL(exec)
 38c:	b8 07 00 00 00       	mov    $0x7,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <open>:
SYSCALL(open)
 394:	b8 0f 00 00 00       	mov    $0xf,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <mknod>:
SYSCALL(mknod)
 39c:	b8 11 00 00 00       	mov    $0x11,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <unlink>:
SYSCALL(unlink)
 3a4:	b8 12 00 00 00       	mov    $0x12,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <fstat>:
SYSCALL(fstat)
 3ac:	b8 08 00 00 00       	mov    $0x8,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <link>:
SYSCALL(link)
 3b4:	b8 13 00 00 00       	mov    $0x13,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <mkdir>:
SYSCALL(mkdir)
 3bc:	b8 14 00 00 00       	mov    $0x14,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <chdir>:
SYSCALL(chdir)
 3c4:	b8 09 00 00 00       	mov    $0x9,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <dup>:
SYSCALL(dup)
 3cc:	b8 0a 00 00 00       	mov    $0xa,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <getpid>:
SYSCALL(getpid)
 3d4:	b8 0b 00 00 00       	mov    $0xb,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <sbrk>:
SYSCALL(sbrk)
 3dc:	b8 0c 00 00 00       	mov    $0xc,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <sleep>:
SYSCALL(sleep)
 3e4:	b8 0d 00 00 00       	mov    $0xd,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <uptime>:
SYSCALL(uptime)
 3ec:	b8 0e 00 00 00       	mov    $0xe,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <shm_get>:
SYSCALL(shm_get) //mod2
 3f4:	b8 1c 00 00 00       	mov    $0x1c,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <shm_rem>:
SYSCALL(shm_rem) //mod2
 3fc:	b8 1d 00 00 00       	mov    $0x1d,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <setHighPrio>:
SYSCALL(setHighPrio) //scheduler
 404:	b8 1e 00 00 00       	mov    $0x1e,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <mutex_create>:
SYSCALL(mutex_create)//mod3
 40c:	b8 16 00 00 00       	mov    $0x16,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <mutex_delete>:
SYSCALL(mutex_delete)
 414:	b8 17 00 00 00       	mov    $0x17,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <mutex_lock>:
SYSCALL(mutex_lock)
 41c:	b8 18 00 00 00       	mov    $0x18,%eax
 421:	cd 40                	int    $0x40
 423:	c3                   	ret    

00000424 <mutex_unlock>:
SYSCALL(mutex_unlock)
 424:	b8 19 00 00 00       	mov    $0x19,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    

0000042c <cv_wait>:
SYSCALL(cv_wait)
 42c:	b8 1a 00 00 00       	mov    $0x1a,%eax
 431:	cd 40                	int    $0x40
 433:	c3                   	ret    

00000434 <cv_signal>:
SYSCALL(cv_signal)
 434:	b8 1b 00 00 00       	mov    $0x1b,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <putc>:
#include "types.h"
#include "stat.h"
#include "user.h"

static void putc(int fd, char c)
{
 43c:	55                   	push   %ebp
 43d:	89 e5                	mov    %esp,%ebp
 43f:	83 ec 18             	sub    $0x18,%esp
 442:	8b 45 0c             	mov    0xc(%ebp),%eax
 445:	88 45 f4             	mov    %al,-0xc(%ebp)
	write(fd, &c, 1);
 448:	83 ec 04             	sub    $0x4,%esp
 44b:	6a 01                	push   $0x1
 44d:	8d 45 f4             	lea    -0xc(%ebp),%eax
 450:	50                   	push   %eax
 451:	ff 75 08             	pushl  0x8(%ebp)
 454:	e8 1b ff ff ff       	call   374 <write>
 459:	83 c4 10             	add    $0x10,%esp
}
 45c:	90                   	nop
 45d:	c9                   	leave  
 45e:	c3                   	ret    

0000045f <printint>:

static void printint(int fd, int xx, int base, int sgn)
{
 45f:	55                   	push   %ebp
 460:	89 e5                	mov    %esp,%ebp
 462:	53                   	push   %ebx
 463:	83 ec 24             	sub    $0x24,%esp
	static char digits[] = "0123456789ABCDEF";
	char buf[16];
	int i, neg;
	uint x;

	neg = 0;
 466:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	if (sgn && xx < 0) {
 46d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 471:	74 17                	je     48a <printint+0x2b>
 473:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 477:	79 11                	jns    48a <printint+0x2b>
		neg = 1;
 479:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
		x = -xx;
 480:	8b 45 0c             	mov    0xc(%ebp),%eax
 483:	f7 d8                	neg    %eax
 485:	89 45 ec             	mov    %eax,-0x14(%ebp)
 488:	eb 06                	jmp    490 <printint+0x31>
	} else {
		x = xx;
 48a:	8b 45 0c             	mov    0xc(%ebp),%eax
 48d:	89 45 ec             	mov    %eax,-0x14(%ebp)
	}

	i = 0;
 490:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	do {
		buf[i++] = digits[x % base];
 497:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 49a:	8d 41 01             	lea    0x1(%ecx),%eax
 49d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4a6:	ba 00 00 00 00       	mov    $0x0,%edx
 4ab:	f7 f3                	div    %ebx
 4ad:	89 d0                	mov    %edx,%eax
 4af:	0f b6 80 60 0b 00 00 	movzbl 0xb60(%eax),%eax
 4b6:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
	} while ((x /= base) != 0);
 4ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4c0:	ba 00 00 00 00       	mov    $0x0,%edx
 4c5:	f7 f3                	div    %ebx
 4c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4ca:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4ce:	75 c7                	jne    497 <printint+0x38>
	if (neg)
 4d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4d4:	74 2d                	je     503 <printint+0xa4>
		buf[i++] = '-';
 4d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4d9:	8d 50 01             	lea    0x1(%eax),%edx
 4dc:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4df:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

	while (--i >= 0)
 4e4:	eb 1d                	jmp    503 <printint+0xa4>
		putc(fd, buf[i]);
 4e6:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ec:	01 d0                	add    %edx,%eax
 4ee:	0f b6 00             	movzbl (%eax),%eax
 4f1:	0f be c0             	movsbl %al,%eax
 4f4:	83 ec 08             	sub    $0x8,%esp
 4f7:	50                   	push   %eax
 4f8:	ff 75 08             	pushl  0x8(%ebp)
 4fb:	e8 3c ff ff ff       	call   43c <putc>
 500:	83 c4 10             	add    $0x10,%esp
		buf[i++] = digits[x % base];
	} while ((x /= base) != 0);
	if (neg)
		buf[i++] = '-';

	while (--i >= 0)
 503:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 507:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 50b:	79 d9                	jns    4e6 <printint+0x87>
		putc(fd, buf[i]);
}
 50d:	90                   	nop
 50e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 511:	c9                   	leave  
 512:	c3                   	ret    

00000513 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void printf(int fd, char *fmt, ...)
{
 513:	55                   	push   %ebp
 514:	89 e5                	mov    %esp,%ebp
 516:	83 ec 28             	sub    $0x28,%esp
	char *s;
	int c, i, state;
	uint *ap;

	state = 0;
 519:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	ap = (uint *) (void *)&fmt + 1;
 520:	8d 45 0c             	lea    0xc(%ebp),%eax
 523:	83 c0 04             	add    $0x4,%eax
 526:	89 45 e8             	mov    %eax,-0x18(%ebp)
	for (i = 0; fmt[i]; i++) {
 529:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 530:	e9 59 01 00 00       	jmp    68e <printf+0x17b>
		c = fmt[i] & 0xff;
 535:	8b 55 0c             	mov    0xc(%ebp),%edx
 538:	8b 45 f0             	mov    -0x10(%ebp),%eax
 53b:	01 d0                	add    %edx,%eax
 53d:	0f b6 00             	movzbl (%eax),%eax
 540:	0f be c0             	movsbl %al,%eax
 543:	25 ff 00 00 00       	and    $0xff,%eax
 548:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (state == 0) {
 54b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 54f:	75 2c                	jne    57d <printf+0x6a>
			if (c == '%') {
 551:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 555:	75 0c                	jne    563 <printf+0x50>
				state = '%';
 557:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 55e:	e9 27 01 00 00       	jmp    68a <printf+0x177>
			} else {
				putc(fd, c);
 563:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 566:	0f be c0             	movsbl %al,%eax
 569:	83 ec 08             	sub    $0x8,%esp
 56c:	50                   	push   %eax
 56d:	ff 75 08             	pushl  0x8(%ebp)
 570:	e8 c7 fe ff ff       	call   43c <putc>
 575:	83 c4 10             	add    $0x10,%esp
 578:	e9 0d 01 00 00       	jmp    68a <printf+0x177>
			}
		} else if (state == '%') {
 57d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 581:	0f 85 03 01 00 00    	jne    68a <printf+0x177>
			if (c == 'd') {
 587:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 58b:	75 1e                	jne    5ab <printf+0x98>
				printint(fd, *ap, 10, 1);
 58d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 590:	8b 00                	mov    (%eax),%eax
 592:	6a 01                	push   $0x1
 594:	6a 0a                	push   $0xa
 596:	50                   	push   %eax
 597:	ff 75 08             	pushl  0x8(%ebp)
 59a:	e8 c0 fe ff ff       	call   45f <printint>
 59f:	83 c4 10             	add    $0x10,%esp
				ap++;
 5a2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a6:	e9 d8 00 00 00       	jmp    683 <printf+0x170>
			} else if (c == 'x' || c == 'p') {
 5ab:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5af:	74 06                	je     5b7 <printf+0xa4>
 5b1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5b5:	75 1e                	jne    5d5 <printf+0xc2>
				printint(fd, *ap, 16, 0);
 5b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ba:	8b 00                	mov    (%eax),%eax
 5bc:	6a 00                	push   $0x0
 5be:	6a 10                	push   $0x10
 5c0:	50                   	push   %eax
 5c1:	ff 75 08             	pushl  0x8(%ebp)
 5c4:	e8 96 fe ff ff       	call   45f <printint>
 5c9:	83 c4 10             	add    $0x10,%esp
				ap++;
 5cc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5d0:	e9 ae 00 00 00       	jmp    683 <printf+0x170>
			} else if (c == 's') {
 5d5:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5d9:	75 43                	jne    61e <printf+0x10b>
				s = (char *)*ap;
 5db:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5de:	8b 00                	mov    (%eax),%eax
 5e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
				ap++;
 5e3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
				if (s == 0)
 5e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5eb:	75 25                	jne    612 <printf+0xff>
					s = "(null)";
 5ed:	c7 45 f4 d0 08 00 00 	movl   $0x8d0,-0xc(%ebp)
				while (*s != 0) {
 5f4:	eb 1c                	jmp    612 <printf+0xff>
					putc(fd, *s);
 5f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f9:	0f b6 00             	movzbl (%eax),%eax
 5fc:	0f be c0             	movsbl %al,%eax
 5ff:	83 ec 08             	sub    $0x8,%esp
 602:	50                   	push   %eax
 603:	ff 75 08             	pushl  0x8(%ebp)
 606:	e8 31 fe ff ff       	call   43c <putc>
 60b:	83 c4 10             	add    $0x10,%esp
					s++;
 60e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
			} else if (c == 's') {
				s = (char *)*ap;
				ap++;
				if (s == 0)
					s = "(null)";
				while (*s != 0) {
 612:	8b 45 f4             	mov    -0xc(%ebp),%eax
 615:	0f b6 00             	movzbl (%eax),%eax
 618:	84 c0                	test   %al,%al
 61a:	75 da                	jne    5f6 <printf+0xe3>
 61c:	eb 65                	jmp    683 <printf+0x170>
					putc(fd, *s);
					s++;
				}
			} else if (c == 'c') {
 61e:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 622:	75 1d                	jne    641 <printf+0x12e>
				putc(fd, *ap);
 624:	8b 45 e8             	mov    -0x18(%ebp),%eax
 627:	8b 00                	mov    (%eax),%eax
 629:	0f be c0             	movsbl %al,%eax
 62c:	83 ec 08             	sub    $0x8,%esp
 62f:	50                   	push   %eax
 630:	ff 75 08             	pushl  0x8(%ebp)
 633:	e8 04 fe ff ff       	call   43c <putc>
 638:	83 c4 10             	add    $0x10,%esp
				ap++;
 63b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 63f:	eb 42                	jmp    683 <printf+0x170>
			} else if (c == '%') {
 641:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 645:	75 17                	jne    65e <printf+0x14b>
				putc(fd, c);
 647:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 64a:	0f be c0             	movsbl %al,%eax
 64d:	83 ec 08             	sub    $0x8,%esp
 650:	50                   	push   %eax
 651:	ff 75 08             	pushl  0x8(%ebp)
 654:	e8 e3 fd ff ff       	call   43c <putc>
 659:	83 c4 10             	add    $0x10,%esp
 65c:	eb 25                	jmp    683 <printf+0x170>
			} else {
				// Unknown % sequence.  Print it to draw attention.
				putc(fd, '%');
 65e:	83 ec 08             	sub    $0x8,%esp
 661:	6a 25                	push   $0x25
 663:	ff 75 08             	pushl  0x8(%ebp)
 666:	e8 d1 fd ff ff       	call   43c <putc>
 66b:	83 c4 10             	add    $0x10,%esp
				putc(fd, c);
 66e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 671:	0f be c0             	movsbl %al,%eax
 674:	83 ec 08             	sub    $0x8,%esp
 677:	50                   	push   %eax
 678:	ff 75 08             	pushl  0x8(%ebp)
 67b:	e8 bc fd ff ff       	call   43c <putc>
 680:	83 c4 10             	add    $0x10,%esp
			}
			state = 0;
 683:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int c, i, state;
	uint *ap;

	state = 0;
	ap = (uint *) (void *)&fmt + 1;
	for (i = 0; fmt[i]; i++) {
 68a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 68e:	8b 55 0c             	mov    0xc(%ebp),%edx
 691:	8b 45 f0             	mov    -0x10(%ebp),%eax
 694:	01 d0                	add    %edx,%eax
 696:	0f b6 00             	movzbl (%eax),%eax
 699:	84 c0                	test   %al,%al
 69b:	0f 85 94 fe ff ff    	jne    535 <printf+0x22>
				putc(fd, c);
			}
			state = 0;
		}
	}
}
 6a1:	90                   	nop
 6a2:	c9                   	leave  
 6a3:	c3                   	ret    

000006a4 <free>:

static Header base;
static Header *freep;

void free(void *ap)
{
 6a4:	55                   	push   %ebp
 6a5:	89 e5                	mov    %esp,%ebp
 6a7:	83 ec 10             	sub    $0x10,%esp
	Header *bp, *p;

	bp = (Header *) ap - 1; //take address of memory -> subtract one size of p to get to header to memeory
 6aa:	8b 45 08             	mov    0x8(%ebp),%eax
 6ad:	83 e8 08             	sub    $0x8,%eax
 6b0:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr) //comparing pointers to headers...maybe ordering spatially...
 6b3:	a1 80 0b 00 00       	mov    0xb80,%eax
 6b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6bb:	eb 24                	jmp    6e1 <free+0x3d>
		if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c0:	8b 00                	mov    (%eax),%eax
 6c2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6c5:	77 12                	ja     6d9 <free+0x35>
 6c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ca:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6cd:	77 24                	ja     6f3 <free+0x4f>
 6cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d2:	8b 00                	mov    (%eax),%eax
 6d4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6d7:	77 1a                	ja     6f3 <free+0x4f>
void free(void *ap)
{
	Header *bp, *p;

	bp = (Header *) ap - 1; //take address of memory -> subtract one size of p to get to header to memeory
	for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr) //comparing pointers to headers...maybe ordering spatially...
 6d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6dc:	8b 00                	mov    (%eax),%eax
 6de:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6e7:	76 d4                	jbe    6bd <free+0x19>
 6e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ec:	8b 00                	mov    (%eax),%eax
 6ee:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6f1:	76 ca                	jbe    6bd <free+0x19>
		if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
			break;
	if (bp + bp->s.size == p->s.ptr) { //checks sizes to merge contiguous freed regions
 6f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f6:	8b 40 04             	mov    0x4(%eax),%eax
 6f9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 700:	8b 45 f8             	mov    -0x8(%ebp),%eax
 703:	01 c2                	add    %eax,%edx
 705:	8b 45 fc             	mov    -0x4(%ebp),%eax
 708:	8b 00                	mov    (%eax),%eax
 70a:	39 c2                	cmp    %eax,%edx
 70c:	75 24                	jne    732 <free+0x8e>
		bp->s.size += p->s.ptr->s.size;
 70e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 711:	8b 50 04             	mov    0x4(%eax),%edx
 714:	8b 45 fc             	mov    -0x4(%ebp),%eax
 717:	8b 00                	mov    (%eax),%eax
 719:	8b 40 04             	mov    0x4(%eax),%eax
 71c:	01 c2                	add    %eax,%edx
 71e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 721:	89 50 04             	mov    %edx,0x4(%eax)
		bp->s.ptr = p->s.ptr->s.ptr;
 724:	8b 45 fc             	mov    -0x4(%ebp),%eax
 727:	8b 00                	mov    (%eax),%eax
 729:	8b 10                	mov    (%eax),%edx
 72b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72e:	89 10                	mov    %edx,(%eax)
 730:	eb 0a                	jmp    73c <free+0x98>
	} else
		bp->s.ptr = p->s.ptr;
 732:	8b 45 fc             	mov    -0x4(%ebp),%eax
 735:	8b 10                	mov    (%eax),%edx
 737:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73a:	89 10                	mov    %edx,(%eax)
	if (p + p->s.size == bp) {
 73c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73f:	8b 40 04             	mov    0x4(%eax),%eax
 742:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 749:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74c:	01 d0                	add    %edx,%eax
 74e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 751:	75 20                	jne    773 <free+0xcf>
		p->s.size += bp->s.size;
 753:	8b 45 fc             	mov    -0x4(%ebp),%eax
 756:	8b 50 04             	mov    0x4(%eax),%edx
 759:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75c:	8b 40 04             	mov    0x4(%eax),%eax
 75f:	01 c2                	add    %eax,%edx
 761:	8b 45 fc             	mov    -0x4(%ebp),%eax
 764:	89 50 04             	mov    %edx,0x4(%eax)
		p->s.ptr = bp->s.ptr;
 767:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76a:	8b 10                	mov    (%eax),%edx
 76c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76f:	89 10                	mov    %edx,(%eax)
 771:	eb 08                	jmp    77b <free+0xd7>
	} else
		p->s.ptr = bp;
 773:	8b 45 fc             	mov    -0x4(%ebp),%eax
 776:	8b 55 f8             	mov    -0x8(%ebp),%edx
 779:	89 10                	mov    %edx,(%eax)
	freep = p;
 77b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77e:	a3 80 0b 00 00       	mov    %eax,0xb80
}
 783:	90                   	nop
 784:	c9                   	leave  
 785:	c3                   	ret    

00000786 <morecore>:

static Header *morecore(uint nu)
{
 786:	55                   	push   %ebp
 787:	89 e5                	mov    %esp,%ebp
 789:	83 ec 18             	sub    $0x18,%esp
	char *p;
	Header *hp;

	if (nu < 4096)
 78c:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 793:	77 07                	ja     79c <morecore+0x16>
		nu = 4096;
 795:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
	p = sbrk(nu * sizeof(Header));
 79c:	8b 45 08             	mov    0x8(%ebp),%eax
 79f:	c1 e0 03             	shl    $0x3,%eax
 7a2:	83 ec 0c             	sub    $0xc,%esp
 7a5:	50                   	push   %eax
 7a6:	e8 31 fc ff ff       	call   3dc <sbrk>
 7ab:	83 c4 10             	add    $0x10,%esp
 7ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (p == (char *)-1)
 7b1:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7b5:	75 07                	jne    7be <morecore+0x38>
		return 0;
 7b7:	b8 00 00 00 00       	mov    $0x0,%eax
 7bc:	eb 26                	jmp    7e4 <morecore+0x5e>
	hp = (Header *) p;
 7be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	hp->s.size = nu;
 7c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c7:	8b 55 08             	mov    0x8(%ebp),%edx
 7ca:	89 50 04             	mov    %edx,0x4(%eax)
	free((void *)(hp + 1));
 7cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d0:	83 c0 08             	add    $0x8,%eax
 7d3:	83 ec 0c             	sub    $0xc,%esp
 7d6:	50                   	push   %eax
 7d7:	e8 c8 fe ff ff       	call   6a4 <free>
 7dc:	83 c4 10             	add    $0x10,%esp
	return freep;
 7df:	a1 80 0b 00 00       	mov    0xb80,%eax
}
 7e4:	c9                   	leave  
 7e5:	c3                   	ret    

000007e6 <malloc>:

void *malloc(uint nbytes)
{
 7e6:	55                   	push   %ebp
 7e7:	89 e5                	mov    %esp,%ebp
 7e9:	83 ec 18             	sub    $0x18,%esp
	Header *p, *prevp;
	uint nunits;

	nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 7ec:	8b 45 08             	mov    0x8(%ebp),%eax
 7ef:	83 c0 07             	add    $0x7,%eax
 7f2:	c1 e8 03             	shr    $0x3,%eax
 7f5:	83 c0 01             	add    $0x1,%eax
 7f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if ((prevp = freep) == 0) {
 7fb:	a1 80 0b 00 00       	mov    0xb80,%eax
 800:	89 45 f0             	mov    %eax,-0x10(%ebp)
 803:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 807:	75 23                	jne    82c <malloc+0x46>
		base.s.ptr = freep = prevp = &base;
 809:	c7 45 f0 78 0b 00 00 	movl   $0xb78,-0x10(%ebp)
 810:	8b 45 f0             	mov    -0x10(%ebp),%eax
 813:	a3 80 0b 00 00       	mov    %eax,0xb80
 818:	a1 80 0b 00 00       	mov    0xb80,%eax
 81d:	a3 78 0b 00 00       	mov    %eax,0xb78
		base.s.size = 0;
 822:	c7 05 7c 0b 00 00 00 	movl   $0x0,0xb7c
 829:	00 00 00 
	}
	for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 82c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 82f:	8b 00                	mov    (%eax),%eax
 831:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if (p->s.size >= nunits) {
 834:	8b 45 f4             	mov    -0xc(%ebp),%eax
 837:	8b 40 04             	mov    0x4(%eax),%eax
 83a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 83d:	72 4d                	jb     88c <malloc+0xa6>
			if (p->s.size == nunits)
 83f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 842:	8b 40 04             	mov    0x4(%eax),%eax
 845:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 848:	75 0c                	jne    856 <malloc+0x70>
				prevp->s.ptr = p->s.ptr;
 84a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84d:	8b 10                	mov    (%eax),%edx
 84f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 852:	89 10                	mov    %edx,(%eax)
 854:	eb 26                	jmp    87c <malloc+0x96>
			else {
				p->s.size -= nunits;
 856:	8b 45 f4             	mov    -0xc(%ebp),%eax
 859:	8b 40 04             	mov    0x4(%eax),%eax
 85c:	2b 45 ec             	sub    -0x14(%ebp),%eax
 85f:	89 c2                	mov    %eax,%edx
 861:	8b 45 f4             	mov    -0xc(%ebp),%eax
 864:	89 50 04             	mov    %edx,0x4(%eax)
				p += p->s.size;
 867:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86a:	8b 40 04             	mov    0x4(%eax),%eax
 86d:	c1 e0 03             	shl    $0x3,%eax
 870:	01 45 f4             	add    %eax,-0xc(%ebp)
				p->s.size = nunits;
 873:	8b 45 f4             	mov    -0xc(%ebp),%eax
 876:	8b 55 ec             	mov    -0x14(%ebp),%edx
 879:	89 50 04             	mov    %edx,0x4(%eax)
			}
			freep = prevp;
 87c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 87f:	a3 80 0b 00 00       	mov    %eax,0xb80
			//printf(0, "\nMalloc Pointer Value = %p\n", p+1);
			return (void *)(p + 1);
 884:	8b 45 f4             	mov    -0xc(%ebp),%eax
 887:	83 c0 08             	add    $0x8,%eax
 88a:	eb 3b                	jmp    8c7 <malloc+0xe1>
		}
		if (p == freep)
 88c:	a1 80 0b 00 00       	mov    0xb80,%eax
 891:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 894:	75 1e                	jne    8b4 <malloc+0xce>
			if ((p = morecore(nunits)) == 0)
 896:	83 ec 0c             	sub    $0xc,%esp
 899:	ff 75 ec             	pushl  -0x14(%ebp)
 89c:	e8 e5 fe ff ff       	call   786 <morecore>
 8a1:	83 c4 10             	add    $0x10,%esp
 8a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8ab:	75 07                	jne    8b4 <malloc+0xce>
				return 0;
 8ad:	b8 00 00 00 00       	mov    $0x0,%eax
 8b2:	eb 13                	jmp    8c7 <malloc+0xe1>
	nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
	if ((prevp = freep) == 0) {
		base.s.ptr = freep = prevp = &base;
		base.s.size = 0;
	}
	for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 8b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8bd:	8b 00                	mov    (%eax),%eax
 8bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
			return (void *)(p + 1);
		}
		if (p == freep)
			if ((p = morecore(nunits)) == 0)
				return 0;
	}
 8c2:	e9 6d ff ff ff       	jmp    834 <malloc+0x4e>
}
 8c7:	c9                   	leave  
 8c8:	c3                   	ret    
