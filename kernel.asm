
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 d0 10 00       	mov    $0x10d000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 f6 10 80       	mov    $0x8010f670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 98 4a 10 80       	mov    $0x80104a98,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
	// head.next is most recently used.
	struct buf head;
} bcache;

void binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
	struct buf *b;

	initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 24 a3 10 80       	push   $0x8010a324
80100042:	68 80 f6 10 80       	push   $0x8010f680
80100047:	e8 1f 6a 00 00       	call   80106a6b <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
	// Create linked list of buffers
	bcache.head.prev = &bcache.head;
8010004f:	c7 05 90 35 11 80 84 	movl   $0x80113584,0x80113590
80100056:	35 11 80 
	bcache.head.next = &bcache.head;
80100059:	c7 05 94 35 11 80 84 	movl   $0x80113584,0x80113594
80100060:	35 11 80 
	for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
80100063:	c7 45 f4 b4 f6 10 80 	movl   $0x8010f6b4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
		b->next = bcache.head.next;
8010006c:	8b 15 94 35 11 80    	mov    0x80113594,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
		b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 84 35 11 80 	movl   $0x80113584,0xc(%eax)
		b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
		bcache.head.next->prev = b;
8010008c:	a1 94 35 11 80       	mov    0x80113594,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
		bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 94 35 11 80       	mov    %eax,0x80113594

//PAGEBREAK!
	// Create linked list of buffers
	bcache.head.prev = &bcache.head;
	bcache.head.next = &bcache.head;
	for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 84 35 11 80       	mov    $0x80113584,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
		b->prev = &bcache.head;
		b->dev = -1;
		bcache.head.next->prev = b;
		bcache.head.next = b;
	}
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:

// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf *bget(uint dev, uint blockno)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
	struct buf *b;

	acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 80 f6 10 80       	push   $0x8010f680
801000c1:	e8 c7 69 00 00       	call   80106a8d <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
	// Is the block already cached?
	for (b = bcache.head.next; b != &bcache.head; b = b->next) {
801000c9:	a1 94 35 11 80       	mov    0x80113594,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
		if (b->dev == dev && b->blockno == blockno) {
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
			if (!(b->flags & B_BUSY)) {
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
				b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
				release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 80 f6 10 80       	push   $0x8010f680
8010010c:	e8 e3 69 00 00       	call   80106af4 <release>
80100111:	83 c4 10             	add    $0x10,%esp
				return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
			}
			sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 f6 10 80       	push   $0x8010f680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 ca 60 00 00       	call   801061f6 <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
			goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

	acquire(&bcache.lock);

 loop:
	// Is the block already cached?
	for (b = bcache.head.next; b != &bcache.head; b = b->next) {
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 84 35 11 80 	cmpl   $0x80113584,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
	}

	// Not cached; recycle some non-busy and clean buffer.
	// "clean" because B_DIRTY and !B_BUSY means log.c
	// hasn't yet committed the changes to the buffer.
	for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
80100143:	a1 90 35 11 80       	mov    0x80113590,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
		if ((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0) {
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
			b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
			b->blockno = blockno;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
			b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
			release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 80 f6 10 80       	push   $0x8010f680
80100188:	e8 67 69 00 00       	call   80106af4 <release>
8010018d:	83 c4 10             	add    $0x10,%esp
			return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
	}

	// Not cached; recycle some non-busy and clean buffer.
	// "clean" because B_DIRTY and !B_BUSY means log.c
	// hasn't yet committed the changes to the buffer.
	for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 84 35 11 80 	cmpl   $0x80113584,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
			b->flags = B_BUSY;
			release(&bcache.lock);
			return b;
		}
	}
	panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 2b a3 10 80       	push   $0x8010a32b
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf *bread(uint dev, uint blockno)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
	struct buf *b;

	b = bget(dev, blockno);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
		iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 2a 27 00 00       	call   80102911 <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
	}
	return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
	if ((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
		panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 3c a3 10 80       	push   $0x8010a33c
80100209:	e8 58 03 00 00       	call   80100566 <panic>
	b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
	iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 e9 26 00 00       	call   80102911 <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
	if ((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
		panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 43 a3 10 80       	push   $0x8010a343
80100248:	e8 19 03 00 00       	call   80100566 <panic>

	acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 f6 10 80       	push   $0x8010f680
80100255:	e8 33 68 00 00       	call   80106a8d <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

	b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
	b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
	b->next = bcache.head.next;
8010027b:	8b 15 94 35 11 80    	mov    0x80113594,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
	b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 84 35 11 80 	movl   $0x80113584,0xc(%eax)
	bcache.head.next->prev = b;
80100291:	a1 94 35 11 80       	mov    0x80113594,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
	bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 94 35 11 80       	mov    %eax,0x80113594

	b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
	wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 26 60 00 00       	call   801062e4 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

	release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 f6 10 80       	push   $0x8010f680
801002c9:	e8 26 68 00 00       	call   80106af4 <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
	struct spinlock lock;
	int locking;
} cons;

static void printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
	static char digits[] = "0123456789abcdef";
	char buf[16];
	int i;
	uint x;

	if (sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
		x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
	else
		x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

	i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	do {
		buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 c0 10 80 	movzbl -0x7fef3ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
	} while ((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

	if (sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
		buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

	while (--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
		consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 df 03 00 00       	call   80100792 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
	} while ((x /= base) != 0);

	if (sign)
		buf[i++] = '-';

	while (--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
		consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:

//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
	int i, c, locking;
	uint *argp;
	char *s;

	locking = cons.locking;
801003cc:	a1 14 e6 10 80       	mov    0x8010e614,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
	if (locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
		acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 e0 e5 10 80       	push   $0x8010e5e0
801003e2:	e8 a6 66 00 00       	call   80106a8d <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

	if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
		panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 4a a3 10 80       	push   $0x8010a34a
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

	argp = (uint *) (void *)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (i = 0; (c = fmt[i] & 0xff) != 0; i++) {
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
		if (c != '%') {
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
			consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 71 03 00 00       	call   80100792 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
			continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
		}
		c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
			break;
		switch (c) {
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
		case 'd':
			printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
			break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
		case 'x':
		case 'p':
			printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
			break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
		case 's':
			if ((s = (char *)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
				s = "(null)";
801004cd:	c7 45 ec 53 a3 10 80 	movl   $0x8010a353,-0x14(%ebp)
			for (; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
				consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 aa 02 00 00       	call   80100792 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
			printint(*argp++, 16, 0);
			break;
		case 's':
			if ((s = (char *)*argp++) == 0)
				s = "(null)";
			for (; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
				consputc(*s);
			break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
		case '%':
			consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 8d 02 00 00       	call   80100792 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
			break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
		default:
			// Print unknown % sequence to draw attention.
			consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 7e 02 00 00       	call   80100792 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
			consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 70 02 00 00       	call   80100792 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
			break;
80100525:	90                   	nop

	if (fmt == 0)
		panic("null fmt");

	argp = (uint *) (void *)(&fmt + 1);
	for (i = 0; (c = fmt[i] & 0xff) != 0; i++) {
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
			consputc(c);
			continue;
		}
		c = fmt[++i] & 0xff;
		if (c == 0)
			break;
8010054c:	90                   	nop
			consputc(c);
			break;
		}
	}

	if (locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
		release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 e0 e5 10 80       	push   $0x8010e5e0
8010055b:	e8 94 65 00 00       	call   80106af4 <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
	int i;
	uint pcs[10];

	cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
	cons.locking = 0;
80100571:	c7 05 14 e6 10 80 00 	movl   $0x0,0x8010e614
80100578:	00 00 00 
	cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 5a a3 10 80       	push   $0x8010a35a
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
	cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
	cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 69 a3 10 80       	push   $0x8010a369
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
	getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 7f 65 00 00       	call   80106b46 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
		cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 6b a3 10 80       	push   $0x8010a36b
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
	cons.locking = 0;
	cprintf("cpu%d: panic: ", cpu->id);
	cprintf(s);
	cprintf("\n");
	getcallerpcs(&s, pcs);
	for (i = 0; i < 10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
		cprintf(" %p", pcs[i]);
	panicked = 1;		// freeze other CPU
801005f5:	c7 05 c0 e5 10 80 01 	movl   $0x1,0x8010e5c0
801005fc:	00 00 00 
	for (;;) ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define BACKSPACE 0x100
#define CRTPORT 0x3d4
static ushort *crt = (ushort *) P2V(0xb8000);	// CGA memory

static void cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
	int pos;

	// Cursor position: col + 80*row.
	outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
	pos = inb(CRTPORT + 1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
	outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
	pos |= inb(CRTPORT + 1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

	if (c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
		pos += 80 - pos % 80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
	else if (c == BACKSPACE) {
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
		if (pos > 0)
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
			--pos;
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
	} else
		crt[pos++] = (c & 0xff) | 0x0700;	// black on white
80100699:	8b 0d 00 c0 10 80    	mov    0x8010c000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)

	if (pos < 0 || pos > 25 * 80)
801006b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006bc:	78 09                	js     801006c7 <cgaputc+0xc6>
801006be:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006c5:	7e 0d                	jle    801006d4 <cgaputc+0xd3>
		panic("pos under/overflow");
801006c7:	83 ec 0c             	sub    $0xc,%esp
801006ca:	68 6f a3 10 80       	push   $0x8010a36f
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>

	if ((pos / 80) >= 24) {	// Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
		memmove(crt, crt + 80, sizeof(crt[0]) * 23 * 80);
801006dd:	a1 00 c0 10 80       	mov    0x8010c000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 c0 10 80       	mov    0x8010c000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 b3 66 00 00       	call   80106daf <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
		pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
		memset(crt + pos, 0, sizeof(crt[0]) * (24 * 80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 ca 65 00 00       	call   80106cf0 <memset>
80100726:	83 c4 10             	add    $0x10,%esp
	}

	outb(CRTPORT, 14);
80100729:	83 ec 08             	sub    $0x8,%esp
8010072c:	6a 0e                	push   $0xe
8010072e:	68 d4 03 00 00       	push   $0x3d4
80100733:	e8 b9 fb ff ff       	call   801002f1 <outb>
80100738:	83 c4 10             	add    $0x10,%esp
	outb(CRTPORT + 1, pos >> 8);
8010073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010073e:	c1 f8 08             	sar    $0x8,%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	83 ec 08             	sub    $0x8,%esp
80100747:	50                   	push   %eax
80100748:	68 d5 03 00 00       	push   $0x3d5
8010074d:	e8 9f fb ff ff       	call   801002f1 <outb>
80100752:	83 c4 10             	add    $0x10,%esp
	outb(CRTPORT, 15);
80100755:	83 ec 08             	sub    $0x8,%esp
80100758:	6a 0f                	push   $0xf
8010075a:	68 d4 03 00 00       	push   $0x3d4
8010075f:	e8 8d fb ff ff       	call   801002f1 <outb>
80100764:	83 c4 10             	add    $0x10,%esp
	outb(CRTPORT + 1, pos);
80100767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010076a:	0f b6 c0             	movzbl %al,%eax
8010076d:	83 ec 08             	sub    $0x8,%esp
80100770:	50                   	push   %eax
80100771:	68 d5 03 00 00       	push   $0x3d5
80100776:	e8 76 fb ff ff       	call   801002f1 <outb>
8010077b:	83 c4 10             	add    $0x10,%esp
	crt[pos] = ' ' | 0x0700;
8010077e:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80100783:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100786:	01 d2                	add    %edx,%edx
80100788:	01 d0                	add    %edx,%eax
8010078a:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010078f:	90                   	nop
80100790:	c9                   	leave  
80100791:	c3                   	ret    

80100792 <consputc>:

void consputc(int c)
{
80100792:	55                   	push   %ebp
80100793:	89 e5                	mov    %esp,%ebp
80100795:	83 ec 08             	sub    $0x8,%esp
	if (panicked) {
80100798:	a1 c0 e5 10 80       	mov    0x8010e5c0,%eax
8010079d:	85 c0                	test   %eax,%eax
8010079f:	74 07                	je     801007a8 <consputc+0x16>
		cli();
801007a1:	e8 6a fb ff ff       	call   80100310 <cli>
		for (;;) ;
801007a6:	eb fe                	jmp    801007a6 <consputc+0x14>
	}

	if (c == BACKSPACE) {
801007a8:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007af:	75 29                	jne    801007da <consputc+0x48>
		uartputc('\b');
801007b1:	83 ec 0c             	sub    $0xc,%esp
801007b4:	6a 08                	push   $0x8
801007b6:	e8 71 81 00 00       	call   8010892c <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
		uartputc(' ');
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 64 81 00 00       	call   8010892c <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
		uartputc('\b');
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 57 81 00 00       	call   8010892c <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
	} else
		uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 47 81 00 00       	call   8010892c <uartputc>
801007e5:	83 c4 10             	add    $0x10,%esp
	cgaputc(c);
801007e8:	83 ec 0c             	sub    $0xc,%esp
801007eb:	ff 75 08             	pushl  0x8(%ebp)
801007ee:	e8 0e fe ff ff       	call   80100601 <cgaputc>
801007f3:	83 c4 10             	add    $0x10,%esp
}
801007f6:	90                   	nop
801007f7:	c9                   	leave  
801007f8:	c3                   	ret    

801007f9 <consoleintr>:
} input;

#define C(x)  ((x)-'@')		// Control-x

void consoleintr(int (*getc) (void))
{
801007f9:	55                   	push   %ebp
801007fa:	89 e5                	mov    %esp,%ebp
801007fc:	83 ec 18             	sub    $0x18,%esp
	int c, doprocdump = 0;
801007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	acquire(&cons.lock);
80100806:	83 ec 0c             	sub    $0xc,%esp
80100809:	68 e0 e5 10 80       	push   $0x8010e5e0
8010080e:	e8 7a 62 00 00       	call   80106a8d <acquire>
80100813:	83 c4 10             	add    $0x10,%esp
	while ((c = getc()) >= 0) {
80100816:	e9 44 01 00 00       	jmp    8010095f <consoleintr+0x166>
		switch (c) {
8010081b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010081e:	83 f8 10             	cmp    $0x10,%eax
80100821:	74 1e                	je     80100841 <consoleintr+0x48>
80100823:	83 f8 10             	cmp    $0x10,%eax
80100826:	7f 0a                	jg     80100832 <consoleintr+0x39>
80100828:	83 f8 08             	cmp    $0x8,%eax
8010082b:	74 6b                	je     80100898 <consoleintr+0x9f>
8010082d:	e9 9b 00 00 00       	jmp    801008cd <consoleintr+0xd4>
80100832:	83 f8 15             	cmp    $0x15,%eax
80100835:	74 33                	je     8010086a <consoleintr+0x71>
80100837:	83 f8 7f             	cmp    $0x7f,%eax
8010083a:	74 5c                	je     80100898 <consoleintr+0x9f>
8010083c:	e9 8c 00 00 00       	jmp    801008cd <consoleintr+0xd4>
		case C('P'):	// Process listing.
			doprocdump = 1;	// procdump() locks cons.lock indirectly; invoke later
80100841:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
			break;
80100848:	e9 12 01 00 00       	jmp    8010095f <consoleintr+0x166>
		case C('U'):	// Kill line.
			while (input.e != input.w &&
			       input.buf[(input.e - 1) % INPUT_BUF] != '\n') {
				input.e--;
8010084d:	a1 28 38 11 80       	mov    0x80113828,%eax
80100852:	83 e8 01             	sub    $0x1,%eax
80100855:	a3 28 38 11 80       	mov    %eax,0x80113828
				consputc(BACKSPACE);
8010085a:	83 ec 0c             	sub    $0xc,%esp
8010085d:	68 00 01 00 00       	push   $0x100
80100862:	e8 2b ff ff ff       	call   80100792 <consputc>
80100867:	83 c4 10             	add    $0x10,%esp
		switch (c) {
		case C('P'):	// Process listing.
			doprocdump = 1;	// procdump() locks cons.lock indirectly; invoke later
			break;
		case C('U'):	// Kill line.
			while (input.e != input.w &&
8010086a:	8b 15 28 38 11 80    	mov    0x80113828,%edx
80100870:	a1 24 38 11 80       	mov    0x80113824,%eax
80100875:	39 c2                	cmp    %eax,%edx
80100877:	0f 84 e2 00 00 00    	je     8010095f <consoleintr+0x166>
			       input.buf[(input.e - 1) % INPUT_BUF] != '\n') {
8010087d:	a1 28 38 11 80       	mov    0x80113828,%eax
80100882:	83 e8 01             	sub    $0x1,%eax
80100885:	83 e0 7f             	and    $0x7f,%eax
80100888:	0f b6 80 a0 37 11 80 	movzbl -0x7feec860(%eax),%eax
		switch (c) {
		case C('P'):	// Process listing.
			doprocdump = 1;	// procdump() locks cons.lock indirectly; invoke later
			break;
		case C('U'):	// Kill line.
			while (input.e != input.w &&
8010088f:	3c 0a                	cmp    $0xa,%al
80100891:	75 ba                	jne    8010084d <consoleintr+0x54>
			       input.buf[(input.e - 1) % INPUT_BUF] != '\n') {
				input.e--;
				consputc(BACKSPACE);
			}
			break;
80100893:	e9 c7 00 00 00       	jmp    8010095f <consoleintr+0x166>
		case C('H'):
		case '\x7f':	// Backspace
			if (input.e != input.w) {
80100898:	8b 15 28 38 11 80    	mov    0x80113828,%edx
8010089e:	a1 24 38 11 80       	mov    0x80113824,%eax
801008a3:	39 c2                	cmp    %eax,%edx
801008a5:	0f 84 b4 00 00 00    	je     8010095f <consoleintr+0x166>
				input.e--;
801008ab:	a1 28 38 11 80       	mov    0x80113828,%eax
801008b0:	83 e8 01             	sub    $0x1,%eax
801008b3:	a3 28 38 11 80       	mov    %eax,0x80113828
				consputc(BACKSPACE);
801008b8:	83 ec 0c             	sub    $0xc,%esp
801008bb:	68 00 01 00 00       	push   $0x100
801008c0:	e8 cd fe ff ff       	call   80100792 <consputc>
801008c5:	83 c4 10             	add    $0x10,%esp
			}
			break;
801008c8:	e9 92 00 00 00       	jmp    8010095f <consoleintr+0x166>
		default:
			if (c != 0 && input.e - input.r < INPUT_BUF) {
801008cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008d1:	0f 84 87 00 00 00    	je     8010095e <consoleintr+0x165>
801008d7:	8b 15 28 38 11 80    	mov    0x80113828,%edx
801008dd:	a1 20 38 11 80       	mov    0x80113820,%eax
801008e2:	29 c2                	sub    %eax,%edx
801008e4:	89 d0                	mov    %edx,%eax
801008e6:	83 f8 7f             	cmp    $0x7f,%eax
801008e9:	77 73                	ja     8010095e <consoleintr+0x165>
				c = (c == '\r') ? '\n' : c;
801008eb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008ef:	74 05                	je     801008f6 <consoleintr+0xfd>
801008f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008f4:	eb 05                	jmp    801008fb <consoleintr+0x102>
801008f6:	b8 0a 00 00 00       	mov    $0xa,%eax
801008fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
				input.buf[input.e++ % INPUT_BUF] = c;
801008fe:	a1 28 38 11 80       	mov    0x80113828,%eax
80100903:	8d 50 01             	lea    0x1(%eax),%edx
80100906:	89 15 28 38 11 80    	mov    %edx,0x80113828
8010090c:	83 e0 7f             	and    $0x7f,%eax
8010090f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100912:	88 90 a0 37 11 80    	mov    %dl,-0x7feec860(%eax)
				consputc(c);
80100918:	83 ec 0c             	sub    $0xc,%esp
8010091b:	ff 75 f0             	pushl  -0x10(%ebp)
8010091e:	e8 6f fe ff ff       	call   80100792 <consputc>
80100923:	83 c4 10             	add    $0x10,%esp
				if (c == '\n' || c == C('D')
80100926:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010092a:	74 18                	je     80100944 <consoleintr+0x14b>
8010092c:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100930:	74 12                	je     80100944 <consoleintr+0x14b>
				    || input.e == input.r + INPUT_BUF) {
80100932:	a1 28 38 11 80       	mov    0x80113828,%eax
80100937:	8b 15 20 38 11 80    	mov    0x80113820,%edx
8010093d:	83 ea 80             	sub    $0xffffff80,%edx
80100940:	39 d0                	cmp    %edx,%eax
80100942:	75 1a                	jne    8010095e <consoleintr+0x165>
					input.w = input.e;
80100944:	a1 28 38 11 80       	mov    0x80113828,%eax
80100949:	a3 24 38 11 80       	mov    %eax,0x80113824
					wakeup(&input.r);
8010094e:	83 ec 0c             	sub    $0xc,%esp
80100951:	68 20 38 11 80       	push   $0x80113820
80100956:	e8 89 59 00 00       	call   801062e4 <wakeup>
8010095b:	83 c4 10             	add    $0x10,%esp
				}
			}
			break;
8010095e:	90                   	nop
void consoleintr(int (*getc) (void))
{
	int c, doprocdump = 0;

	acquire(&cons.lock);
	while ((c = getc()) >= 0) {
8010095f:	8b 45 08             	mov    0x8(%ebp),%eax
80100962:	ff d0                	call   *%eax
80100964:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100967:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010096b:	0f 89 aa fe ff ff    	jns    8010081b <consoleintr+0x22>
				}
			}
			break;
		}
	}
	release(&cons.lock);
80100971:	83 ec 0c             	sub    $0xc,%esp
80100974:	68 e0 e5 10 80       	push   $0x8010e5e0
80100979:	e8 76 61 00 00       	call   80106af4 <release>
8010097e:	83 c4 10             	add    $0x10,%esp
	if (doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
		procdump();	// now call procdump() wo. cons.lock held
80100987:	e8 16 5a 00 00       	call   801063a2 <procdump>
	}
}
8010098c:	90                   	nop
8010098d:	c9                   	leave  
8010098e:	c3                   	ret    

8010098f <consoleread>:

int consoleread(struct inode *ip, char *dst, int n)
{
8010098f:	55                   	push   %ebp
80100990:	89 e5                	mov    %esp,%ebp
80100992:	83 ec 18             	sub    $0x18,%esp
	uint target;
	int c;

	iunlock(ip);
80100995:	83 ec 0c             	sub    $0xc,%esp
80100998:	ff 75 08             	pushl  0x8(%ebp)
8010099b:	e8 2c 11 00 00       	call   80101acc <iunlock>
801009a0:	83 c4 10             	add    $0x10,%esp
	target = n;
801009a3:	8b 45 10             	mov    0x10(%ebp),%eax
801009a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	acquire(&cons.lock);
801009a9:	83 ec 0c             	sub    $0xc,%esp
801009ac:	68 e0 e5 10 80       	push   $0x8010e5e0
801009b1:	e8 d7 60 00 00       	call   80106a8d <acquire>
801009b6:	83 c4 10             	add    $0x10,%esp
	while (n > 0) {
801009b9:	e9 ac 00 00 00       	jmp    80100a6a <consoleread+0xdb>
		while (input.r == input.w) {
			if (proc->killed) {
801009be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801009c4:	8b 40 24             	mov    0x24(%eax),%eax
801009c7:	85 c0                	test   %eax,%eax
801009c9:	74 28                	je     801009f3 <consoleread+0x64>
				release(&cons.lock);
801009cb:	83 ec 0c             	sub    $0xc,%esp
801009ce:	68 e0 e5 10 80       	push   $0x8010e5e0
801009d3:	e8 1c 61 00 00       	call   80106af4 <release>
801009d8:	83 c4 10             	add    $0x10,%esp
				ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	pushl  0x8(%ebp)
801009e1:	e8 88 0f 00 00       	call   8010196e <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
				return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 ab 00 00 00       	jmp    80100a9e <consoleread+0x10f>
			}
			sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 e0 e5 10 80       	push   $0x8010e5e0
801009fb:	68 20 38 11 80       	push   $0x80113820
80100a00:	e8 f1 57 00 00       	call   801061f6 <sleep>
80100a05:	83 c4 10             	add    $0x10,%esp

	iunlock(ip);
	target = n;
	acquire(&cons.lock);
	while (n > 0) {
		while (input.r == input.w) {
80100a08:	8b 15 20 38 11 80    	mov    0x80113820,%edx
80100a0e:	a1 24 38 11 80       	mov    0x80113824,%eax
80100a13:	39 c2                	cmp    %eax,%edx
80100a15:	74 a7                	je     801009be <consoleread+0x2f>
				ilock(ip);
				return -1;
			}
			sleep(&input.r, &cons.lock);
		}
		c = input.buf[input.r++ % INPUT_BUF];
80100a17:	a1 20 38 11 80       	mov    0x80113820,%eax
80100a1c:	8d 50 01             	lea    0x1(%eax),%edx
80100a1f:	89 15 20 38 11 80    	mov    %edx,0x80113820
80100a25:	83 e0 7f             	and    $0x7f,%eax
80100a28:	0f b6 80 a0 37 11 80 	movzbl -0x7feec860(%eax),%eax
80100a2f:	0f be c0             	movsbl %al,%eax
80100a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (c == C('D')) {	// EOF
80100a35:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a39:	75 17                	jne    80100a52 <consoleread+0xc3>
			if (n < target) {
80100a3b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a3e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a41:	73 2f                	jae    80100a72 <consoleread+0xe3>
				// Save ^D for next time, to make sure
				// caller gets a 0-byte result.
				input.r--;
80100a43:	a1 20 38 11 80       	mov    0x80113820,%eax
80100a48:	83 e8 01             	sub    $0x1,%eax
80100a4b:	a3 20 38 11 80       	mov    %eax,0x80113820
			}
			break;
80100a50:	eb 20                	jmp    80100a72 <consoleread+0xe3>
		}
		*dst++ = c;
80100a52:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a55:	8d 50 01             	lea    0x1(%eax),%edx
80100a58:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a5e:	88 10                	mov    %dl,(%eax)
		--n;
80100a60:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
		if (c == '\n')
80100a64:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a68:	74 0b                	je     80100a75 <consoleread+0xe6>
	int c;

	iunlock(ip);
	target = n;
	acquire(&cons.lock);
	while (n > 0) {
80100a6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a6e:	7f 98                	jg     80100a08 <consoleread+0x79>
80100a70:	eb 04                	jmp    80100a76 <consoleread+0xe7>
			if (n < target) {
				// Save ^D for next time, to make sure
				// caller gets a 0-byte result.
				input.r--;
			}
			break;
80100a72:	90                   	nop
80100a73:	eb 01                	jmp    80100a76 <consoleread+0xe7>
		}
		*dst++ = c;
		--n;
		if (c == '\n')
			break;
80100a75:	90                   	nop
	}
	release(&cons.lock);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	68 e0 e5 10 80       	push   $0x8010e5e0
80100a7e:	e8 71 60 00 00       	call   80106af4 <release>
80100a83:	83 c4 10             	add    $0x10,%esp
	ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	pushl  0x8(%ebp)
80100a8c:	e8 dd 0e 00 00       	call   8010196e <ilock>
80100a91:	83 c4 10             	add    $0x10,%esp

	return target - n;
80100a94:	8b 45 10             	mov    0x10(%ebp),%eax
80100a97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a9a:	29 c2                	sub    %eax,%edx
80100a9c:	89 d0                	mov    %edx,%eax
}
80100a9e:	c9                   	leave  
80100a9f:	c3                   	ret    

80100aa0 <consolewrite>:

int consolewrite(struct inode *ip, char *buf, int n)
{
80100aa0:	55                   	push   %ebp
80100aa1:	89 e5                	mov    %esp,%ebp
80100aa3:	83 ec 18             	sub    $0x18,%esp
	int i;

	iunlock(ip);
80100aa6:	83 ec 0c             	sub    $0xc,%esp
80100aa9:	ff 75 08             	pushl  0x8(%ebp)
80100aac:	e8 1b 10 00 00       	call   80101acc <iunlock>
80100ab1:	83 c4 10             	add    $0x10,%esp
	acquire(&cons.lock);
80100ab4:	83 ec 0c             	sub    $0xc,%esp
80100ab7:	68 e0 e5 10 80       	push   $0x8010e5e0
80100abc:	e8 cc 5f 00 00       	call   80106a8d <acquire>
80100ac1:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i++)
80100ac4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100acb:	eb 21                	jmp    80100aee <consolewrite+0x4e>
		consputc(buf[i] & 0xff);
80100acd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ad3:	01 d0                	add    %edx,%eax
80100ad5:	0f b6 00             	movzbl (%eax),%eax
80100ad8:	0f be c0             	movsbl %al,%eax
80100adb:	0f b6 c0             	movzbl %al,%eax
80100ade:	83 ec 0c             	sub    $0xc,%esp
80100ae1:	50                   	push   %eax
80100ae2:	e8 ab fc ff ff       	call   80100792 <consputc>
80100ae7:	83 c4 10             	add    $0x10,%esp
{
	int i;

	iunlock(ip);
	acquire(&cons.lock);
	for (i = 0; i < n; i++)
80100aea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100af1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100af4:	7c d7                	jl     80100acd <consolewrite+0x2d>
		consputc(buf[i] & 0xff);
	release(&cons.lock);
80100af6:	83 ec 0c             	sub    $0xc,%esp
80100af9:	68 e0 e5 10 80       	push   $0x8010e5e0
80100afe:	e8 f1 5f 00 00       	call   80106af4 <release>
80100b03:	83 c4 10             	add    $0x10,%esp
	ilock(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	ff 75 08             	pushl  0x8(%ebp)
80100b0c:	e8 5d 0e 00 00       	call   8010196e <ilock>
80100b11:	83 c4 10             	add    $0x10,%esp

	return n;
80100b14:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b17:	c9                   	leave  
80100b18:	c3                   	ret    

80100b19 <consoleinit>:

void consoleinit(void)
{
80100b19:	55                   	push   %ebp
80100b1a:	89 e5                	mov    %esp,%ebp
80100b1c:	83 ec 08             	sub    $0x8,%esp
	initlock(&cons.lock, "console");
80100b1f:	83 ec 08             	sub    $0x8,%esp
80100b22:	68 82 a3 10 80       	push   $0x8010a382
80100b27:	68 e0 e5 10 80       	push   $0x8010e5e0
80100b2c:	e8 3a 5f 00 00       	call   80106a6b <initlock>
80100b31:	83 c4 10             	add    $0x10,%esp

	devsw[CONSOLE].write = consolewrite;
80100b34:	c7 05 ec 41 11 80 a0 	movl   $0x80100aa0,0x801141ec
80100b3b:	0a 10 80 
	devsw[CONSOLE].read = consoleread;
80100b3e:	c7 05 e8 41 11 80 8f 	movl   $0x8010098f,0x801141e8
80100b45:	09 10 80 
	cons.locking = 1;
80100b48:	c7 05 14 e6 10 80 01 	movl   $0x1,0x8010e614
80100b4f:	00 00 00 

	picenable(IRQ_KBD);
80100b52:	83 ec 0c             	sub    $0xc,%esp
80100b55:	6a 01                	push   $0x1
80100b57:	e8 e2 45 00 00       	call   8010513e <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
	ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 73 1f 00 00       	call   80102ade <ioapicenable>
80100b6b:	83 c4 10             	add    $0x10,%esp
}
80100b6e:	90                   	nop
80100b6f:	c9                   	leave  
80100b70:	c3                   	ret    

80100b71 <exec>:
#include "defs.h"
#include "x86.h"
#include "elf.h"

int exec(char *path, char **argv)
{
80100b71:	55                   	push   %ebp
80100b72:	89 e5                	mov    %esp,%ebp
80100b74:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct elfhdr elf;
	struct inode *ip;
	struct proghdr ph;
	pde_t *pgdir, *oldpgdir;

	begin_op();
80100b7a:	e8 d2 29 00 00       	call   80103551 <begin_op>
	if ((ip = namei(path)) == 0) {
80100b7f:	83 ec 0c             	sub    $0xc,%esp
80100b82:	ff 75 08             	pushl  0x8(%ebp)
80100b85:	e8 a2 19 00 00       	call   8010252c <namei>
80100b8a:	83 c4 10             	add    $0x10,%esp
80100b8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b90:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b94:	75 0f                	jne    80100ba5 <exec+0x34>
		end_op();
80100b96:	e8 42 2a 00 00       	call   801035dd <end_op>
		return -1;
80100b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ba0:	e9 d2 03 00 00       	jmp    80100f77 <exec+0x406>
	}
	ilock(ip);
80100ba5:	83 ec 0c             	sub    $0xc,%esp
80100ba8:	ff 75 d8             	pushl  -0x28(%ebp)
80100bab:	e8 be 0d 00 00       	call   8010196e <ilock>
80100bb0:	83 c4 10             	add    $0x10,%esp
	pgdir = 0;
80100bb3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

	// Check ELF header
	if (readi(ip, (char *)&elf, 0, sizeof(elf)) < sizeof(elf))
80100bba:	6a 34                	push   $0x34
80100bbc:	6a 00                	push   $0x0
80100bbe:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100bc4:	50                   	push   %eax
80100bc5:	ff 75 d8             	pushl  -0x28(%ebp)
80100bc8:	e8 0f 13 00 00       	call   80101edc <readi>
80100bcd:	83 c4 10             	add    $0x10,%esp
80100bd0:	83 f8 33             	cmp    $0x33,%eax
80100bd3:	0f 86 4b 03 00 00    	jbe    80100f24 <exec+0x3b3>
		goto bad;
	if (elf.magic != ELF_MAGIC)
80100bd9:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bdf:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100be4:	0f 85 3d 03 00 00    	jne    80100f27 <exec+0x3b6>
		goto bad;

	if ((pgdir = setupkvm()) == 0)
80100bea:	e8 92 8e 00 00       	call   80109a81 <setupkvm>
80100bef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bf2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bf6:	0f 84 2e 03 00 00    	je     80100f2a <exec+0x3b9>
		goto bad;

	// Load program into memory.
	sz = 0;
80100bfc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
80100c03:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c0a:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c10:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c13:	e9 ab 00 00 00       	jmp    80100cc3 <exec+0x152>
		if (readi(ip, (char *)&ph, off, sizeof(ph)) != sizeof(ph))
80100c18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c1b:	6a 20                	push   $0x20
80100c1d:	50                   	push   %eax
80100c1e:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c24:	50                   	push   %eax
80100c25:	ff 75 d8             	pushl  -0x28(%ebp)
80100c28:	e8 af 12 00 00       	call   80101edc <readi>
80100c2d:	83 c4 10             	add    $0x10,%esp
80100c30:	83 f8 20             	cmp    $0x20,%eax
80100c33:	0f 85 f4 02 00 00    	jne    80100f2d <exec+0x3bc>
			goto bad;
		if (ph.type != ELF_PROG_LOAD)
80100c39:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c3f:	83 f8 01             	cmp    $0x1,%eax
80100c42:	75 71                	jne    80100cb5 <exec+0x144>
			continue;
		if (ph.memsz < ph.filesz)
80100c44:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c4a:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c50:	39 c2                	cmp    %eax,%edx
80100c52:	0f 82 d8 02 00 00    	jb     80100f30 <exec+0x3bf>
			goto bad;
		if ((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c58:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c5e:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c64:	01 d0                	add    %edx,%eax
80100c66:	83 ec 04             	sub    $0x4,%esp
80100c69:	50                   	push   %eax
80100c6a:	ff 75 e0             	pushl  -0x20(%ebp)
80100c6d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c70:	e8 b3 91 00 00       	call   80109e28 <allocuvm>
80100c75:	83 c4 10             	add    $0x10,%esp
80100c78:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c7b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c7f:	0f 84 ae 02 00 00    	je     80100f33 <exec+0x3c2>
			goto bad;
		if (loaduvm(pgdir, (char *)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c85:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c8b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c91:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c97:	83 ec 0c             	sub    $0xc,%esp
80100c9a:	52                   	push   %edx
80100c9b:	50                   	push   %eax
80100c9c:	ff 75 d8             	pushl  -0x28(%ebp)
80100c9f:	51                   	push   %ecx
80100ca0:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ca3:	e8 a9 90 00 00       	call   80109d51 <loaduvm>
80100ca8:	83 c4 20             	add    $0x20,%esp
80100cab:	85 c0                	test   %eax,%eax
80100cad:	0f 88 83 02 00 00    	js     80100f36 <exec+0x3c5>
80100cb3:	eb 01                	jmp    80100cb6 <exec+0x145>
	sz = 0;
	for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
		if (readi(ip, (char *)&ph, off, sizeof(ph)) != sizeof(ph))
			goto bad;
		if (ph.type != ELF_PROG_LOAD)
			continue;
80100cb5:	90                   	nop
	if ((pgdir = setupkvm()) == 0)
		goto bad;

	// Load program into memory.
	sz = 0;
	for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
80100cb6:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100cba:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cbd:	83 c0 20             	add    $0x20,%eax
80100cc0:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cc3:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100cca:	0f b7 c0             	movzwl %ax,%eax
80100ccd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cd0:	0f 8f 42 ff ff ff    	jg     80100c18 <exec+0xa7>
		if ((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
			goto bad;
		if (loaduvm(pgdir, (char *)ph.vaddr, ip, ph.off, ph.filesz) < 0)
			goto bad;
	}
	iunlockput(ip);
80100cd6:	83 ec 0c             	sub    $0xc,%esp
80100cd9:	ff 75 d8             	pushl  -0x28(%ebp)
80100cdc:	e8 4d 0f 00 00       	call   80101c2e <iunlockput>
80100ce1:	83 c4 10             	add    $0x10,%esp
	end_op();
80100ce4:	e8 f4 28 00 00       	call   801035dd <end_op>
	ip = 0;
80100ce9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

	// Allocate two pages at the next page boundary.
	// Make the first inaccessible.  Use the second as the user stack.
	sz = PGROUNDUP(sz);
80100cf0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf3:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cf8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cfd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if ((sz = allocuvm(pgdir, sz, sz + 2 * PGSIZE)) == 0)
80100d00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d03:	05 00 20 00 00       	add    $0x2000,%eax
80100d08:	83 ec 04             	sub    $0x4,%esp
80100d0b:	50                   	push   %eax
80100d0c:	ff 75 e0             	pushl  -0x20(%ebp)
80100d0f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d12:	e8 11 91 00 00       	call   80109e28 <allocuvm>
80100d17:	83 c4 10             	add    $0x10,%esp
80100d1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d1d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d21:	0f 84 12 02 00 00    	je     80100f39 <exec+0x3c8>
		goto bad;
	clearpteu(pgdir, (char *)(sz - 2 * PGSIZE));
80100d27:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d2a:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d2f:	83 ec 08             	sub    $0x8,%esp
80100d32:	50                   	push   %eax
80100d33:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d36:	e8 4b 93 00 00       	call   8010a086 <clearpteu>
80100d3b:	83 c4 10             	add    $0x10,%esp
	sp = sz;
80100d3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d41:	89 45 dc             	mov    %eax,-0x24(%ebp)

	// Push argument strings, prepare rest of stack in ustack.
	for (argc = 0; argv[argc]; argc++) {
80100d44:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d4b:	e9 96 00 00 00       	jmp    80100de6 <exec+0x275>
		if (argc >= MAXARG)
80100d50:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d54:	0f 87 e2 01 00 00    	ja     80100f3c <exec+0x3cb>
			goto bad;
		sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d5d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d64:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d67:	01 d0                	add    %edx,%eax
80100d69:	8b 00                	mov    (%eax),%eax
80100d6b:	83 ec 0c             	sub    $0xc,%esp
80100d6e:	50                   	push   %eax
80100d6f:	e8 c9 61 00 00       	call   80106f3d <strlen>
80100d74:	83 c4 10             	add    $0x10,%esp
80100d77:	89 c2                	mov    %eax,%edx
80100d79:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d7c:	29 d0                	sub    %edx,%eax
80100d7e:	83 e8 01             	sub    $0x1,%eax
80100d81:	83 e0 fc             	and    $0xfffffffc,%eax
80100d84:	89 45 dc             	mov    %eax,-0x24(%ebp)
		if (copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d94:	01 d0                	add    %edx,%eax
80100d96:	8b 00                	mov    (%eax),%eax
80100d98:	83 ec 0c             	sub    $0xc,%esp
80100d9b:	50                   	push   %eax
80100d9c:	e8 9c 61 00 00       	call   80106f3d <strlen>
80100da1:	83 c4 10             	add    $0x10,%esp
80100da4:	83 c0 01             	add    $0x1,%eax
80100da7:	89 c1                	mov    %eax,%ecx
80100da9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100db3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100db6:	01 d0                	add    %edx,%eax
80100db8:	8b 00                	mov    (%eax),%eax
80100dba:	51                   	push   %ecx
80100dbb:	50                   	push   %eax
80100dbc:	ff 75 dc             	pushl  -0x24(%ebp)
80100dbf:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dc2:	e8 bc 94 00 00       	call   8010a283 <copyout>
80100dc7:	83 c4 10             	add    $0x10,%esp
80100dca:	85 c0                	test   %eax,%eax
80100dcc:	0f 88 6d 01 00 00    	js     80100f3f <exec+0x3ce>
			goto bad;
		ustack[3 + argc] = sp;
80100dd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd5:	8d 50 03             	lea    0x3(%eax),%edx
80100dd8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ddb:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
		goto bad;
	clearpteu(pgdir, (char *)(sz - 2 * PGSIZE));
	sp = sz;

	// Push argument strings, prepare rest of stack in ustack.
	for (argc = 0; argv[argc]; argc++) {
80100de2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100de6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df3:	01 d0                	add    %edx,%eax
80100df5:	8b 00                	mov    (%eax),%eax
80100df7:	85 c0                	test   %eax,%eax
80100df9:	0f 85 51 ff ff ff    	jne    80100d50 <exec+0x1df>
		sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
		if (copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
			goto bad;
		ustack[3 + argc] = sp;
	}
	ustack[3 + argc] = 0;
80100dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e02:	83 c0 03             	add    $0x3,%eax
80100e05:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e0c:	00 00 00 00 

	ustack[0] = 0xffffffff;	// fake return PC
80100e10:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e17:	ff ff ff 
	ustack[1] = argc;
80100e1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e1d:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
	ustack[2] = sp - (argc + 1) * 4;	// argv pointer
80100e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e26:	83 c0 01             	add    $0x1,%eax
80100e29:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e30:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e33:	29 d0                	sub    %edx,%eax
80100e35:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

	sp -= (3 + argc + 1) * 4;
80100e3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3e:	83 c0 04             	add    $0x4,%eax
80100e41:	c1 e0 02             	shl    $0x2,%eax
80100e44:	29 45 dc             	sub    %eax,-0x24(%ebp)
	if (copyout(pgdir, sp, ustack, (3 + argc + 1) * 4) < 0)
80100e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4a:	83 c0 04             	add    $0x4,%eax
80100e4d:	c1 e0 02             	shl    $0x2,%eax
80100e50:	50                   	push   %eax
80100e51:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e57:	50                   	push   %eax
80100e58:	ff 75 dc             	pushl  -0x24(%ebp)
80100e5b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e5e:	e8 20 94 00 00       	call   8010a283 <copyout>
80100e63:	83 c4 10             	add    $0x10,%esp
80100e66:	85 c0                	test   %eax,%eax
80100e68:	0f 88 d4 00 00 00    	js     80100f42 <exec+0x3d1>
		goto bad;

	// Save program name for debugging.
	for (last = s = path; *s; s++)
80100e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80100e71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e77:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e7a:	eb 17                	jmp    80100e93 <exec+0x322>
		if (*s == '/')
80100e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e7f:	0f b6 00             	movzbl (%eax),%eax
80100e82:	3c 2f                	cmp    $0x2f,%al
80100e84:	75 09                	jne    80100e8f <exec+0x31e>
			last = s + 1;
80100e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e89:	83 c0 01             	add    $0x1,%eax
80100e8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	sp -= (3 + argc + 1) * 4;
	if (copyout(pgdir, sp, ustack, (3 + argc + 1) * 4) < 0)
		goto bad;

	// Save program name for debugging.
	for (last = s = path; *s; s++)
80100e8f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e96:	0f b6 00             	movzbl (%eax),%eax
80100e99:	84 c0                	test   %al,%al
80100e9b:	75 df                	jne    80100e7c <exec+0x30b>
		if (*s == '/')
			last = s + 1;
	safestrcpy(proc->name, last, sizeof(proc->name));
80100e9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea3:	83 c0 6c             	add    $0x6c,%eax
80100ea6:	83 ec 04             	sub    $0x4,%esp
80100ea9:	6a 10                	push   $0x10
80100eab:	ff 75 f0             	pushl  -0x10(%ebp)
80100eae:	50                   	push   %eax
80100eaf:	e8 3f 60 00 00       	call   80106ef3 <safestrcpy>
80100eb4:	83 c4 10             	add    $0x10,%esp

	// Commit to the user image.
	oldpgdir = proc->pgdir;
80100eb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebd:	8b 40 04             	mov    0x4(%eax),%eax
80100ec0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	proc->pgdir = pgdir;
80100ec3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ecc:	89 50 04             	mov    %edx,0x4(%eax)
	proc->sz = sz;
80100ecf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed5:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ed8:	89 10                	mov    %edx,(%eax)
	proc->tf->eip = elf.entry;	// main
80100eda:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee0:	8b 40 18             	mov    0x18(%eax),%eax
80100ee3:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ee9:	89 50 38             	mov    %edx,0x38(%eax)
	proc->tf->esp = sp;
80100eec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ef2:	8b 40 18             	mov    0x18(%eax),%eax
80100ef5:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ef8:	89 50 44             	mov    %edx,0x44(%eax)
	switchuvm(proc);
80100efb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f01:	83 ec 0c             	sub    $0xc,%esp
80100f04:	50                   	push   %eax
80100f05:	e8 5e 8c 00 00       	call   80109b68 <switchuvm>
80100f0a:	83 c4 10             	add    $0x10,%esp
	freevm(oldpgdir, 0); //freevm modified for SHM...sending in 0 because exec simply starts executing another program. 
80100f0d:	83 ec 08             	sub    $0x8,%esp
80100f10:	6a 00                	push   $0x0
80100f12:	ff 75 d0             	pushl  -0x30(%ebp)
80100f15:	e8 cc 90 00 00       	call   80109fe6 <freevm>
80100f1a:	83 c4 10             	add    $0x10,%esp
	return 0;
80100f1d:	b8 00 00 00 00       	mov    $0x0,%eax
80100f22:	eb 53                	jmp    80100f77 <exec+0x406>
	ilock(ip);
	pgdir = 0;

	// Check ELF header
	if (readi(ip, (char *)&elf, 0, sizeof(elf)) < sizeof(elf))
		goto bad;
80100f24:	90                   	nop
80100f25:	eb 1c                	jmp    80100f43 <exec+0x3d2>
	if (elf.magic != ELF_MAGIC)
		goto bad;
80100f27:	90                   	nop
80100f28:	eb 19                	jmp    80100f43 <exec+0x3d2>

	if ((pgdir = setupkvm()) == 0)
		goto bad;
80100f2a:	90                   	nop
80100f2b:	eb 16                	jmp    80100f43 <exec+0x3d2>

	// Load program into memory.
	sz = 0;
	for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
		if (readi(ip, (char *)&ph, off, sizeof(ph)) != sizeof(ph))
			goto bad;
80100f2d:	90                   	nop
80100f2e:	eb 13                	jmp    80100f43 <exec+0x3d2>
		if (ph.type != ELF_PROG_LOAD)
			continue;
		if (ph.memsz < ph.filesz)
			goto bad;
80100f30:	90                   	nop
80100f31:	eb 10                	jmp    80100f43 <exec+0x3d2>
		if ((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
			goto bad;
80100f33:	90                   	nop
80100f34:	eb 0d                	jmp    80100f43 <exec+0x3d2>
		if (loaduvm(pgdir, (char *)ph.vaddr, ip, ph.off, ph.filesz) < 0)
			goto bad;
80100f36:	90                   	nop
80100f37:	eb 0a                	jmp    80100f43 <exec+0x3d2>

	// Allocate two pages at the next page boundary.
	// Make the first inaccessible.  Use the second as the user stack.
	sz = PGROUNDUP(sz);
	if ((sz = allocuvm(pgdir, sz, sz + 2 * PGSIZE)) == 0)
		goto bad;
80100f39:	90                   	nop
80100f3a:	eb 07                	jmp    80100f43 <exec+0x3d2>
	sp = sz;

	// Push argument strings, prepare rest of stack in ustack.
	for (argc = 0; argv[argc]; argc++) {
		if (argc >= MAXARG)
			goto bad;
80100f3c:	90                   	nop
80100f3d:	eb 04                	jmp    80100f43 <exec+0x3d2>
		sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
		if (copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
			goto bad;
80100f3f:	90                   	nop
80100f40:	eb 01                	jmp    80100f43 <exec+0x3d2>
	ustack[1] = argc;
	ustack[2] = sp - (argc + 1) * 4;	// argv pointer

	sp -= (3 + argc + 1) * 4;
	if (copyout(pgdir, sp, ustack, (3 + argc + 1) * 4) < 0)
		goto bad;
80100f42:	90                   	nop
	switchuvm(proc);
	freevm(oldpgdir, 0); //freevm modified for SHM...sending in 0 because exec simply starts executing another program. 
	return 0;

 bad:
	if (pgdir)
80100f43:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f47:	74 10                	je     80100f59 <exec+0x3e8>
		freevm(pgdir, 0); //freevm modified for SHM
80100f49:	83 ec 08             	sub    $0x8,%esp
80100f4c:	6a 00                	push   $0x0
80100f4e:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f51:	e8 90 90 00 00       	call   80109fe6 <freevm>
80100f56:	83 c4 10             	add    $0x10,%esp
	if (ip) {
80100f59:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f5d:	74 13                	je     80100f72 <exec+0x401>
		iunlockput(ip);
80100f5f:	83 ec 0c             	sub    $0xc,%esp
80100f62:	ff 75 d8             	pushl  -0x28(%ebp)
80100f65:	e8 c4 0c 00 00       	call   80101c2e <iunlockput>
80100f6a:	83 c4 10             	add    $0x10,%esp
		end_op();
80100f6d:	e8 6b 26 00 00       	call   801035dd <end_op>
	}
	return -1;
80100f72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f77:	c9                   	leave  
80100f78:	c3                   	ret    

80100f79 <fileinit>:
	struct spinlock lock;
	struct file file[NFILE];
} ftable;

void fileinit(void)
{
80100f79:	55                   	push   %ebp
80100f7a:	89 e5                	mov    %esp,%ebp
80100f7c:	83 ec 08             	sub    $0x8,%esp
	initlock(&ftable.lock, "ftable");
80100f7f:	83 ec 08             	sub    $0x8,%esp
80100f82:	68 8a a3 10 80       	push   $0x8010a38a
80100f87:	68 40 38 11 80       	push   $0x80113840
80100f8c:	e8 da 5a 00 00       	call   80106a6b <initlock>
80100f91:	83 c4 10             	add    $0x10,%esp
}
80100f94:	90                   	nop
80100f95:	c9                   	leave  
80100f96:	c3                   	ret    

80100f97 <filealloc>:

// Allocate a file structure.
struct file *filealloc(void)
{
80100f97:	55                   	push   %ebp
80100f98:	89 e5                	mov    %esp,%ebp
80100f9a:	83 ec 18             	sub    $0x18,%esp
	struct file *f;

	acquire(&ftable.lock);
80100f9d:	83 ec 0c             	sub    $0xc,%esp
80100fa0:	68 40 38 11 80       	push   $0x80113840
80100fa5:	e8 e3 5a 00 00       	call   80106a8d <acquire>
80100faa:	83 c4 10             	add    $0x10,%esp
	for (f = ftable.file; f < ftable.file + NFILE; f++) {
80100fad:	c7 45 f4 74 38 11 80 	movl   $0x80113874,-0xc(%ebp)
80100fb4:	eb 2d                	jmp    80100fe3 <filealloc+0x4c>
		if (f->ref == 0) {
80100fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fb9:	8b 40 04             	mov    0x4(%eax),%eax
80100fbc:	85 c0                	test   %eax,%eax
80100fbe:	75 1f                	jne    80100fdf <filealloc+0x48>
			f->ref = 1;
80100fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fc3:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
			release(&ftable.lock);
80100fca:	83 ec 0c             	sub    $0xc,%esp
80100fcd:	68 40 38 11 80       	push   $0x80113840
80100fd2:	e8 1d 5b 00 00       	call   80106af4 <release>
80100fd7:	83 c4 10             	add    $0x10,%esp
			return f;
80100fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fdd:	eb 23                	jmp    80101002 <filealloc+0x6b>
struct file *filealloc(void)
{
	struct file *f;

	acquire(&ftable.lock);
	for (f = ftable.file; f < ftable.file + NFILE; f++) {
80100fdf:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fe3:	b8 d4 41 11 80       	mov    $0x801141d4,%eax
80100fe8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100feb:	72 c9                	jb     80100fb6 <filealloc+0x1f>
			f->ref = 1;
			release(&ftable.lock);
			return f;
		}
	}
	release(&ftable.lock);
80100fed:	83 ec 0c             	sub    $0xc,%esp
80100ff0:	68 40 38 11 80       	push   $0x80113840
80100ff5:	e8 fa 5a 00 00       	call   80106af4 <release>
80100ffa:	83 c4 10             	add    $0x10,%esp
	return 0;
80100ffd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101002:	c9                   	leave  
80101003:	c3                   	ret    

80101004 <filedup>:

// Increment ref count for file f.
struct file *filedup(struct file *f)
{
80101004:	55                   	push   %ebp
80101005:	89 e5                	mov    %esp,%ebp
80101007:	83 ec 08             	sub    $0x8,%esp
	acquire(&ftable.lock);
8010100a:	83 ec 0c             	sub    $0xc,%esp
8010100d:	68 40 38 11 80       	push   $0x80113840
80101012:	e8 76 5a 00 00       	call   80106a8d <acquire>
80101017:	83 c4 10             	add    $0x10,%esp
	if (f->ref < 1)
8010101a:	8b 45 08             	mov    0x8(%ebp),%eax
8010101d:	8b 40 04             	mov    0x4(%eax),%eax
80101020:	85 c0                	test   %eax,%eax
80101022:	7f 0d                	jg     80101031 <filedup+0x2d>
		panic("filedup");
80101024:	83 ec 0c             	sub    $0xc,%esp
80101027:	68 91 a3 10 80       	push   $0x8010a391
8010102c:	e8 35 f5 ff ff       	call   80100566 <panic>
	f->ref++;
80101031:	8b 45 08             	mov    0x8(%ebp),%eax
80101034:	8b 40 04             	mov    0x4(%eax),%eax
80101037:	8d 50 01             	lea    0x1(%eax),%edx
8010103a:	8b 45 08             	mov    0x8(%ebp),%eax
8010103d:	89 50 04             	mov    %edx,0x4(%eax)
	release(&ftable.lock);
80101040:	83 ec 0c             	sub    $0xc,%esp
80101043:	68 40 38 11 80       	push   $0x80113840
80101048:	e8 a7 5a 00 00       	call   80106af4 <release>
8010104d:	83 c4 10             	add    $0x10,%esp
	return f;
80101050:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101053:	c9                   	leave  
80101054:	c3                   	ret    

80101055 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void fileclose(struct file *f)
{
80101055:	55                   	push   %ebp
80101056:	89 e5                	mov    %esp,%ebp
80101058:	83 ec 28             	sub    $0x28,%esp
	struct file ff;

	acquire(&ftable.lock);
8010105b:	83 ec 0c             	sub    $0xc,%esp
8010105e:	68 40 38 11 80       	push   $0x80113840
80101063:	e8 25 5a 00 00       	call   80106a8d <acquire>
80101068:	83 c4 10             	add    $0x10,%esp
	if (f->ref < 1)
8010106b:	8b 45 08             	mov    0x8(%ebp),%eax
8010106e:	8b 40 04             	mov    0x4(%eax),%eax
80101071:	85 c0                	test   %eax,%eax
80101073:	7f 0d                	jg     80101082 <fileclose+0x2d>
		panic("fileclose");
80101075:	83 ec 0c             	sub    $0xc,%esp
80101078:	68 99 a3 10 80       	push   $0x8010a399
8010107d:	e8 e4 f4 ff ff       	call   80100566 <panic>
	if (--f->ref > 0) {
80101082:	8b 45 08             	mov    0x8(%ebp),%eax
80101085:	8b 40 04             	mov    0x4(%eax),%eax
80101088:	8d 50 ff             	lea    -0x1(%eax),%edx
8010108b:	8b 45 08             	mov    0x8(%ebp),%eax
8010108e:	89 50 04             	mov    %edx,0x4(%eax)
80101091:	8b 45 08             	mov    0x8(%ebp),%eax
80101094:	8b 40 04             	mov    0x4(%eax),%eax
80101097:	85 c0                	test   %eax,%eax
80101099:	7e 15                	jle    801010b0 <fileclose+0x5b>
		release(&ftable.lock);
8010109b:	83 ec 0c             	sub    $0xc,%esp
8010109e:	68 40 38 11 80       	push   $0x80113840
801010a3:	e8 4c 5a 00 00       	call   80106af4 <release>
801010a8:	83 c4 10             	add    $0x10,%esp
801010ab:	e9 8b 00 00 00       	jmp    8010113b <fileclose+0xe6>
		return;
	}
	ff = *f;
801010b0:	8b 45 08             	mov    0x8(%ebp),%eax
801010b3:	8b 10                	mov    (%eax),%edx
801010b5:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010b8:	8b 50 04             	mov    0x4(%eax),%edx
801010bb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010be:	8b 50 08             	mov    0x8(%eax),%edx
801010c1:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010c4:	8b 50 0c             	mov    0xc(%eax),%edx
801010c7:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010ca:	8b 50 10             	mov    0x10(%eax),%edx
801010cd:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010d0:	8b 40 14             	mov    0x14(%eax),%eax
801010d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	f->ref = 0;
801010d6:	8b 45 08             	mov    0x8(%ebp),%eax
801010d9:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	f->type = FD_NONE;
801010e0:	8b 45 08             	mov    0x8(%ebp),%eax
801010e3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	release(&ftable.lock);
801010e9:	83 ec 0c             	sub    $0xc,%esp
801010ec:	68 40 38 11 80       	push   $0x80113840
801010f1:	e8 fe 59 00 00       	call   80106af4 <release>
801010f6:	83 c4 10             	add    $0x10,%esp

	if (ff.type == FD_PIPE)
801010f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010fc:	83 f8 01             	cmp    $0x1,%eax
801010ff:	75 19                	jne    8010111a <fileclose+0xc5>
		pipeclose(ff.pipe, ff.writable);
80101101:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101105:	0f be d0             	movsbl %al,%edx
80101108:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010110b:	83 ec 08             	sub    $0x8,%esp
8010110e:	52                   	push   %edx
8010110f:	50                   	push   %eax
80101110:	e8 92 42 00 00       	call   801053a7 <pipeclose>
80101115:	83 c4 10             	add    $0x10,%esp
80101118:	eb 21                	jmp    8010113b <fileclose+0xe6>
	else if (ff.type == FD_INODE) {
8010111a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010111d:	83 f8 02             	cmp    $0x2,%eax
80101120:	75 19                	jne    8010113b <fileclose+0xe6>
		begin_op();
80101122:	e8 2a 24 00 00       	call   80103551 <begin_op>
		iput(ff.ip);
80101127:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010112a:	83 ec 0c             	sub    $0xc,%esp
8010112d:	50                   	push   %eax
8010112e:	e8 0b 0a 00 00       	call   80101b3e <iput>
80101133:	83 c4 10             	add    $0x10,%esp
		end_op();
80101136:	e8 a2 24 00 00       	call   801035dd <end_op>
	}
}
8010113b:	c9                   	leave  
8010113c:	c3                   	ret    

8010113d <filestat>:

// Get metadata about file f.
int filestat(struct file *f, struct stat *st)
{
8010113d:	55                   	push   %ebp
8010113e:	89 e5                	mov    %esp,%ebp
80101140:	83 ec 08             	sub    $0x8,%esp
	if (f->type == FD_INODE) {
80101143:	8b 45 08             	mov    0x8(%ebp),%eax
80101146:	8b 00                	mov    (%eax),%eax
80101148:	83 f8 02             	cmp    $0x2,%eax
8010114b:	75 40                	jne    8010118d <filestat+0x50>
		ilock(f->ip);
8010114d:	8b 45 08             	mov    0x8(%ebp),%eax
80101150:	8b 40 10             	mov    0x10(%eax),%eax
80101153:	83 ec 0c             	sub    $0xc,%esp
80101156:	50                   	push   %eax
80101157:	e8 12 08 00 00       	call   8010196e <ilock>
8010115c:	83 c4 10             	add    $0x10,%esp
		stati(f->ip, st);
8010115f:	8b 45 08             	mov    0x8(%ebp),%eax
80101162:	8b 40 10             	mov    0x10(%eax),%eax
80101165:	83 ec 08             	sub    $0x8,%esp
80101168:	ff 75 0c             	pushl  0xc(%ebp)
8010116b:	50                   	push   %eax
8010116c:	e8 25 0d 00 00       	call   80101e96 <stati>
80101171:	83 c4 10             	add    $0x10,%esp
		iunlock(f->ip);
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	8b 40 10             	mov    0x10(%eax),%eax
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	50                   	push   %eax
8010117e:	e8 49 09 00 00       	call   80101acc <iunlock>
80101183:	83 c4 10             	add    $0x10,%esp
		return 0;
80101186:	b8 00 00 00 00       	mov    $0x0,%eax
8010118b:	eb 05                	jmp    80101192 <filestat+0x55>
	}
	return -1;
8010118d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101192:	c9                   	leave  
80101193:	c3                   	ret    

80101194 <fileread>:

// Read from file f.
int fileread(struct file *f, char *addr, int n)
{
80101194:	55                   	push   %ebp
80101195:	89 e5                	mov    %esp,%ebp
80101197:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (f->readable == 0)
8010119a:	8b 45 08             	mov    0x8(%ebp),%eax
8010119d:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011a1:	84 c0                	test   %al,%al
801011a3:	75 0a                	jne    801011af <fileread+0x1b>
		return -1;
801011a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011aa:	e9 9b 00 00 00       	jmp    8010124a <fileread+0xb6>
	if (f->type == FD_PIPE)
801011af:	8b 45 08             	mov    0x8(%ebp),%eax
801011b2:	8b 00                	mov    (%eax),%eax
801011b4:	83 f8 01             	cmp    $0x1,%eax
801011b7:	75 1a                	jne    801011d3 <fileread+0x3f>
		return piperead(f->pipe, addr, n);
801011b9:	8b 45 08             	mov    0x8(%ebp),%eax
801011bc:	8b 40 0c             	mov    0xc(%eax),%eax
801011bf:	83 ec 04             	sub    $0x4,%esp
801011c2:	ff 75 10             	pushl  0x10(%ebp)
801011c5:	ff 75 0c             	pushl  0xc(%ebp)
801011c8:	50                   	push   %eax
801011c9:	e8 81 43 00 00       	call   8010554f <piperead>
801011ce:	83 c4 10             	add    $0x10,%esp
801011d1:	eb 77                	jmp    8010124a <fileread+0xb6>
	if (f->type == FD_INODE) {
801011d3:	8b 45 08             	mov    0x8(%ebp),%eax
801011d6:	8b 00                	mov    (%eax),%eax
801011d8:	83 f8 02             	cmp    $0x2,%eax
801011db:	75 60                	jne    8010123d <fileread+0xa9>
		ilock(f->ip);
801011dd:	8b 45 08             	mov    0x8(%ebp),%eax
801011e0:	8b 40 10             	mov    0x10(%eax),%eax
801011e3:	83 ec 0c             	sub    $0xc,%esp
801011e6:	50                   	push   %eax
801011e7:	e8 82 07 00 00       	call   8010196e <ilock>
801011ec:	83 c4 10             	add    $0x10,%esp
		if ((r = readi(f->ip, addr, f->off, n)) > 0)
801011ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011f2:	8b 45 08             	mov    0x8(%ebp),%eax
801011f5:	8b 50 14             	mov    0x14(%eax),%edx
801011f8:	8b 45 08             	mov    0x8(%ebp),%eax
801011fb:	8b 40 10             	mov    0x10(%eax),%eax
801011fe:	51                   	push   %ecx
801011ff:	52                   	push   %edx
80101200:	ff 75 0c             	pushl  0xc(%ebp)
80101203:	50                   	push   %eax
80101204:	e8 d3 0c 00 00       	call   80101edc <readi>
80101209:	83 c4 10             	add    $0x10,%esp
8010120c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010120f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101213:	7e 11                	jle    80101226 <fileread+0x92>
			f->off += r;
80101215:	8b 45 08             	mov    0x8(%ebp),%eax
80101218:	8b 50 14             	mov    0x14(%eax),%edx
8010121b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010121e:	01 c2                	add    %eax,%edx
80101220:	8b 45 08             	mov    0x8(%ebp),%eax
80101223:	89 50 14             	mov    %edx,0x14(%eax)
		iunlock(f->ip);
80101226:	8b 45 08             	mov    0x8(%ebp),%eax
80101229:	8b 40 10             	mov    0x10(%eax),%eax
8010122c:	83 ec 0c             	sub    $0xc,%esp
8010122f:	50                   	push   %eax
80101230:	e8 97 08 00 00       	call   80101acc <iunlock>
80101235:	83 c4 10             	add    $0x10,%esp
		return r;
80101238:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010123b:	eb 0d                	jmp    8010124a <fileread+0xb6>
	}
	panic("fileread");
8010123d:	83 ec 0c             	sub    $0xc,%esp
80101240:	68 a3 a3 10 80       	push   $0x8010a3a3
80101245:	e8 1c f3 ff ff       	call   80100566 <panic>
}
8010124a:	c9                   	leave  
8010124b:	c3                   	ret    

8010124c <filewrite>:

//PAGEBREAK!
// Write to file f.
int filewrite(struct file *f, char *addr, int n)
{
8010124c:	55                   	push   %ebp
8010124d:	89 e5                	mov    %esp,%ebp
8010124f:	53                   	push   %ebx
80101250:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (f->writable == 0)
80101253:	8b 45 08             	mov    0x8(%ebp),%eax
80101256:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010125a:	84 c0                	test   %al,%al
8010125c:	75 0a                	jne    80101268 <filewrite+0x1c>
		return -1;
8010125e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101263:	e9 1b 01 00 00       	jmp    80101383 <filewrite+0x137>
	if (f->type == FD_PIPE)
80101268:	8b 45 08             	mov    0x8(%ebp),%eax
8010126b:	8b 00                	mov    (%eax),%eax
8010126d:	83 f8 01             	cmp    $0x1,%eax
80101270:	75 1d                	jne    8010128f <filewrite+0x43>
		return pipewrite(f->pipe, addr, n);
80101272:	8b 45 08             	mov    0x8(%ebp),%eax
80101275:	8b 40 0c             	mov    0xc(%eax),%eax
80101278:	83 ec 04             	sub    $0x4,%esp
8010127b:	ff 75 10             	pushl  0x10(%ebp)
8010127e:	ff 75 0c             	pushl  0xc(%ebp)
80101281:	50                   	push   %eax
80101282:	e8 ca 41 00 00       	call   80105451 <pipewrite>
80101287:	83 c4 10             	add    $0x10,%esp
8010128a:	e9 f4 00 00 00       	jmp    80101383 <filewrite+0x137>
	if (f->type == FD_INODE) {
8010128f:	8b 45 08             	mov    0x8(%ebp),%eax
80101292:	8b 00                	mov    (%eax),%eax
80101294:	83 f8 02             	cmp    $0x2,%eax
80101297:	0f 85 d9 00 00 00    	jne    80101376 <filewrite+0x12a>
		// the maximum log transaction size, including
		// i-node, indirect block, allocation blocks,
		// and 2 blocks of slop for non-aligned writes.
		// this really belongs lower down, since writei()
		// might be writing a device like the console.
		int max = ((LOGSIZE - 1 - 1 - 2) / 2) * 512;
8010129d:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
		int i = 0;
801012a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
		while (i < n) {
801012ab:	e9 a3 00 00 00       	jmp    80101353 <filewrite+0x107>
			int n1 = n - i;
801012b0:	8b 45 10             	mov    0x10(%ebp),%eax
801012b3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (n1 > max)
801012b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012bc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012bf:	7e 06                	jle    801012c7 <filewrite+0x7b>
				n1 = max;
801012c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012c4:	89 45 f0             	mov    %eax,-0x10(%ebp)

			begin_op();
801012c7:	e8 85 22 00 00       	call   80103551 <begin_op>
			ilock(f->ip);
801012cc:	8b 45 08             	mov    0x8(%ebp),%eax
801012cf:	8b 40 10             	mov    0x10(%eax),%eax
801012d2:	83 ec 0c             	sub    $0xc,%esp
801012d5:	50                   	push   %eax
801012d6:	e8 93 06 00 00       	call   8010196e <ilock>
801012db:	83 c4 10             	add    $0x10,%esp
			if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012de:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012e1:	8b 45 08             	mov    0x8(%ebp),%eax
801012e4:	8b 50 14             	mov    0x14(%eax),%edx
801012e7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801012ed:	01 c3                	add    %eax,%ebx
801012ef:	8b 45 08             	mov    0x8(%ebp),%eax
801012f2:	8b 40 10             	mov    0x10(%eax),%eax
801012f5:	51                   	push   %ecx
801012f6:	52                   	push   %edx
801012f7:	53                   	push   %ebx
801012f8:	50                   	push   %eax
801012f9:	e8 35 0d 00 00       	call   80102033 <writei>
801012fe:	83 c4 10             	add    $0x10,%esp
80101301:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101304:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101308:	7e 11                	jle    8010131b <filewrite+0xcf>
				f->off += r;
8010130a:	8b 45 08             	mov    0x8(%ebp),%eax
8010130d:	8b 50 14             	mov    0x14(%eax),%edx
80101310:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101313:	01 c2                	add    %eax,%edx
80101315:	8b 45 08             	mov    0x8(%ebp),%eax
80101318:	89 50 14             	mov    %edx,0x14(%eax)
			iunlock(f->ip);
8010131b:	8b 45 08             	mov    0x8(%ebp),%eax
8010131e:	8b 40 10             	mov    0x10(%eax),%eax
80101321:	83 ec 0c             	sub    $0xc,%esp
80101324:	50                   	push   %eax
80101325:	e8 a2 07 00 00       	call   80101acc <iunlock>
8010132a:	83 c4 10             	add    $0x10,%esp
			end_op();
8010132d:	e8 ab 22 00 00       	call   801035dd <end_op>

			if (r < 0)
80101332:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101336:	78 29                	js     80101361 <filewrite+0x115>
				break;
			if (r != n1)
80101338:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010133b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010133e:	74 0d                	je     8010134d <filewrite+0x101>
				panic("short filewrite");
80101340:	83 ec 0c             	sub    $0xc,%esp
80101343:	68 ac a3 10 80       	push   $0x8010a3ac
80101348:	e8 19 f2 ff ff       	call   80100566 <panic>
			i += r;
8010134d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101350:	01 45 f4             	add    %eax,-0xc(%ebp)
		// and 2 blocks of slop for non-aligned writes.
		// this really belongs lower down, since writei()
		// might be writing a device like the console.
		int max = ((LOGSIZE - 1 - 1 - 2) / 2) * 512;
		int i = 0;
		while (i < n) {
80101353:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101356:	3b 45 10             	cmp    0x10(%ebp),%eax
80101359:	0f 8c 51 ff ff ff    	jl     801012b0 <filewrite+0x64>
8010135f:	eb 01                	jmp    80101362 <filewrite+0x116>
				f->off += r;
			iunlock(f->ip);
			end_op();

			if (r < 0)
				break;
80101361:	90                   	nop
			if (r != n1)
				panic("short filewrite");
			i += r;
		}
		return i == n ? n : -1;
80101362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101365:	3b 45 10             	cmp    0x10(%ebp),%eax
80101368:	75 05                	jne    8010136f <filewrite+0x123>
8010136a:	8b 45 10             	mov    0x10(%ebp),%eax
8010136d:	eb 14                	jmp    80101383 <filewrite+0x137>
8010136f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101374:	eb 0d                	jmp    80101383 <filewrite+0x137>
	}
	panic("filewrite");
80101376:	83 ec 0c             	sub    $0xc,%esp
80101379:	68 bc a3 10 80       	push   $0x8010a3bc
8010137e:	e8 e3 f1 ff ff       	call   80100566 <panic>
}
80101383:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101386:	c9                   	leave  
80101387:	c3                   	ret    

80101388 <readsb>:
static void itrunc(struct inode *);
struct superblock sb;		// there should be one per dev, but we run with one dev

// Read the super block.
void readsb(int dev, struct superblock *sb)
{
80101388:	55                   	push   %ebp
80101389:	89 e5                	mov    %esp,%ebp
8010138b:	83 ec 18             	sub    $0x18,%esp
	struct buf *bp;

	bp = bread(dev, 1);
8010138e:	8b 45 08             	mov    0x8(%ebp),%eax
80101391:	83 ec 08             	sub    $0x8,%esp
80101394:	6a 01                	push   $0x1
80101396:	50                   	push   %eax
80101397:	e8 1a ee ff ff       	call   801001b6 <bread>
8010139c:	83 c4 10             	add    $0x10,%esp
8010139f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	memmove(sb, bp->data, sizeof(*sb));
801013a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a5:	83 c0 18             	add    $0x18,%eax
801013a8:	83 ec 04             	sub    $0x4,%esp
801013ab:	6a 1c                	push   $0x1c
801013ad:	50                   	push   %eax
801013ae:	ff 75 0c             	pushl  0xc(%ebp)
801013b1:	e8 f9 59 00 00       	call   80106daf <memmove>
801013b6:	83 c4 10             	add    $0x10,%esp
	brelse(bp);
801013b9:	83 ec 0c             	sub    $0xc,%esp
801013bc:	ff 75 f4             	pushl  -0xc(%ebp)
801013bf:	e8 6a ee ff ff       	call   8010022e <brelse>
801013c4:	83 c4 10             	add    $0x10,%esp
}
801013c7:	90                   	nop
801013c8:	c9                   	leave  
801013c9:	c3                   	ret    

801013ca <bzero>:

// Zero a block.
static void bzero(int dev, int bno)
{
801013ca:	55                   	push   %ebp
801013cb:	89 e5                	mov    %esp,%ebp
801013cd:	83 ec 18             	sub    $0x18,%esp
	struct buf *bp;

	bp = bread(dev, bno);
801013d0:	8b 55 0c             	mov    0xc(%ebp),%edx
801013d3:	8b 45 08             	mov    0x8(%ebp),%eax
801013d6:	83 ec 08             	sub    $0x8,%esp
801013d9:	52                   	push   %edx
801013da:	50                   	push   %eax
801013db:	e8 d6 ed ff ff       	call   801001b6 <bread>
801013e0:	83 c4 10             	add    $0x10,%esp
801013e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	memset(bp->data, 0, BSIZE);
801013e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e9:	83 c0 18             	add    $0x18,%eax
801013ec:	83 ec 04             	sub    $0x4,%esp
801013ef:	68 00 02 00 00       	push   $0x200
801013f4:	6a 00                	push   $0x0
801013f6:	50                   	push   %eax
801013f7:	e8 f4 58 00 00       	call   80106cf0 <memset>
801013fc:	83 c4 10             	add    $0x10,%esp
	log_write(bp);
801013ff:	83 ec 0c             	sub    $0xc,%esp
80101402:	ff 75 f4             	pushl  -0xc(%ebp)
80101405:	e8 7f 23 00 00       	call   80103789 <log_write>
8010140a:	83 c4 10             	add    $0x10,%esp
	brelse(bp);
8010140d:	83 ec 0c             	sub    $0xc,%esp
80101410:	ff 75 f4             	pushl  -0xc(%ebp)
80101413:	e8 16 ee ff ff       	call   8010022e <brelse>
80101418:	83 c4 10             	add    $0x10,%esp
}
8010141b:	90                   	nop
8010141c:	c9                   	leave  
8010141d:	c3                   	ret    

8010141e <balloc>:

// Blocks. 

// Allocate a zeroed disk block.
static uint balloc(uint dev)
{
8010141e:	55                   	push   %ebp
8010141f:	89 e5                	mov    %esp,%ebp
80101421:	83 ec 18             	sub    $0x18,%esp
	int b, bi, m;
	struct buf *bp;

	bp = 0;
80101424:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	for (b = 0; b < sb.size; b += BPB) {
8010142b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101432:	e9 13 01 00 00       	jmp    8010154a <balloc+0x12c>
		bp = bread(dev, BBLOCK(b, sb));
80101437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010143a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101440:	85 c0                	test   %eax,%eax
80101442:	0f 48 c2             	cmovs  %edx,%eax
80101445:	c1 f8 0c             	sar    $0xc,%eax
80101448:	89 c2                	mov    %eax,%edx
8010144a:	a1 58 42 11 80       	mov    0x80114258,%eax
8010144f:	01 d0                	add    %edx,%eax
80101451:	83 ec 08             	sub    $0x8,%esp
80101454:	50                   	push   %eax
80101455:	ff 75 08             	pushl  0x8(%ebp)
80101458:	e8 59 ed ff ff       	call   801001b6 <bread>
8010145d:	83 c4 10             	add    $0x10,%esp
80101460:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
80101463:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010146a:	e9 a6 00 00 00       	jmp    80101515 <balloc+0xf7>
			m = 1 << (bi % 8);
8010146f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101472:	99                   	cltd   
80101473:	c1 ea 1d             	shr    $0x1d,%edx
80101476:	01 d0                	add    %edx,%eax
80101478:	83 e0 07             	and    $0x7,%eax
8010147b:	29 d0                	sub    %edx,%eax
8010147d:	ba 01 00 00 00       	mov    $0x1,%edx
80101482:	89 c1                	mov    %eax,%ecx
80101484:	d3 e2                	shl    %cl,%edx
80101486:	89 d0                	mov    %edx,%eax
80101488:	89 45 e8             	mov    %eax,-0x18(%ebp)
			if ((bp->data[bi / 8] & m) == 0) {	// Is block free?
8010148b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010148e:	8d 50 07             	lea    0x7(%eax),%edx
80101491:	85 c0                	test   %eax,%eax
80101493:	0f 48 c2             	cmovs  %edx,%eax
80101496:	c1 f8 03             	sar    $0x3,%eax
80101499:	89 c2                	mov    %eax,%edx
8010149b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010149e:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801014a3:	0f b6 c0             	movzbl %al,%eax
801014a6:	23 45 e8             	and    -0x18(%ebp),%eax
801014a9:	85 c0                	test   %eax,%eax
801014ab:	75 64                	jne    80101511 <balloc+0xf3>
				bp->data[bi / 8] |= m;	// Mark block in use.
801014ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b0:	8d 50 07             	lea    0x7(%eax),%edx
801014b3:	85 c0                	test   %eax,%eax
801014b5:	0f 48 c2             	cmovs  %edx,%eax
801014b8:	c1 f8 03             	sar    $0x3,%eax
801014bb:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014be:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014c3:	89 d1                	mov    %edx,%ecx
801014c5:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014c8:	09 ca                	or     %ecx,%edx
801014ca:	89 d1                	mov    %edx,%ecx
801014cc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014cf:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
				log_write(bp);
801014d3:	83 ec 0c             	sub    $0xc,%esp
801014d6:	ff 75 ec             	pushl  -0x14(%ebp)
801014d9:	e8 ab 22 00 00       	call   80103789 <log_write>
801014de:	83 c4 10             	add    $0x10,%esp
				brelse(bp);
801014e1:	83 ec 0c             	sub    $0xc,%esp
801014e4:	ff 75 ec             	pushl  -0x14(%ebp)
801014e7:	e8 42 ed ff ff       	call   8010022e <brelse>
801014ec:	83 c4 10             	add    $0x10,%esp
				bzero(dev, b + bi);
801014ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f5:	01 c2                	add    %eax,%edx
801014f7:	8b 45 08             	mov    0x8(%ebp),%eax
801014fa:	83 ec 08             	sub    $0x8,%esp
801014fd:	52                   	push   %edx
801014fe:	50                   	push   %eax
801014ff:	e8 c6 fe ff ff       	call   801013ca <bzero>
80101504:	83 c4 10             	add    $0x10,%esp
				return b + bi;
80101507:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010150a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010150d:	01 d0                	add    %edx,%eax
8010150f:	eb 57                	jmp    80101568 <balloc+0x14a>
	struct buf *bp;

	bp = 0;
	for (b = 0; b < sb.size; b += BPB) {
		bp = bread(dev, BBLOCK(b, sb));
		for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
80101511:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101515:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010151c:	7f 17                	jg     80101535 <balloc+0x117>
8010151e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101521:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101524:	01 d0                	add    %edx,%eax
80101526:	89 c2                	mov    %eax,%edx
80101528:	a1 40 42 11 80       	mov    0x80114240,%eax
8010152d:	39 c2                	cmp    %eax,%edx
8010152f:	0f 82 3a ff ff ff    	jb     8010146f <balloc+0x51>
				brelse(bp);
				bzero(dev, b + bi);
				return b + bi;
			}
		}
		brelse(bp);
80101535:	83 ec 0c             	sub    $0xc,%esp
80101538:	ff 75 ec             	pushl  -0x14(%ebp)
8010153b:	e8 ee ec ff ff       	call   8010022e <brelse>
80101540:	83 c4 10             	add    $0x10,%esp
{
	int b, bi, m;
	struct buf *bp;

	bp = 0;
	for (b = 0; b < sb.size; b += BPB) {
80101543:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010154a:	8b 15 40 42 11 80    	mov    0x80114240,%edx
80101550:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101553:	39 c2                	cmp    %eax,%edx
80101555:	0f 87 dc fe ff ff    	ja     80101437 <balloc+0x19>
				return b + bi;
			}
		}
		brelse(bp);
	}
	panic("balloc: out of blocks");
8010155b:	83 ec 0c             	sub    $0xc,%esp
8010155e:	68 c8 a3 10 80       	push   $0x8010a3c8
80101563:	e8 fe ef ff ff       	call   80100566 <panic>
}
80101568:	c9                   	leave  
80101569:	c3                   	ret    

8010156a <bfree>:

// Free a disk block.
static void bfree(int dev, uint b)
{
8010156a:	55                   	push   %ebp
8010156b:	89 e5                	mov    %esp,%ebp
8010156d:	83 ec 18             	sub    $0x18,%esp
	struct buf *bp;
	int bi, m;

	readsb(dev, &sb);
80101570:	83 ec 08             	sub    $0x8,%esp
80101573:	68 40 42 11 80       	push   $0x80114240
80101578:	ff 75 08             	pushl  0x8(%ebp)
8010157b:	e8 08 fe ff ff       	call   80101388 <readsb>
80101580:	83 c4 10             	add    $0x10,%esp
	bp = bread(dev, BBLOCK(b, sb));
80101583:	8b 45 0c             	mov    0xc(%ebp),%eax
80101586:	c1 e8 0c             	shr    $0xc,%eax
80101589:	89 c2                	mov    %eax,%edx
8010158b:	a1 58 42 11 80       	mov    0x80114258,%eax
80101590:	01 c2                	add    %eax,%edx
80101592:	8b 45 08             	mov    0x8(%ebp),%eax
80101595:	83 ec 08             	sub    $0x8,%esp
80101598:	52                   	push   %edx
80101599:	50                   	push   %eax
8010159a:	e8 17 ec ff ff       	call   801001b6 <bread>
8010159f:	83 c4 10             	add    $0x10,%esp
801015a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	bi = b % BPB;
801015a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801015a8:	25 ff 0f 00 00       	and    $0xfff,%eax
801015ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
	m = 1 << (bi % 8);
801015b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b3:	99                   	cltd   
801015b4:	c1 ea 1d             	shr    $0x1d,%edx
801015b7:	01 d0                	add    %edx,%eax
801015b9:	83 e0 07             	and    $0x7,%eax
801015bc:	29 d0                	sub    %edx,%eax
801015be:	ba 01 00 00 00       	mov    $0x1,%edx
801015c3:	89 c1                	mov    %eax,%ecx
801015c5:	d3 e2                	shl    %cl,%edx
801015c7:	89 d0                	mov    %edx,%eax
801015c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if ((bp->data[bi / 8] & m) == 0)
801015cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015cf:	8d 50 07             	lea    0x7(%eax),%edx
801015d2:	85 c0                	test   %eax,%eax
801015d4:	0f 48 c2             	cmovs  %edx,%eax
801015d7:	c1 f8 03             	sar    $0x3,%eax
801015da:	89 c2                	mov    %eax,%edx
801015dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015df:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015e4:	0f b6 c0             	movzbl %al,%eax
801015e7:	23 45 ec             	and    -0x14(%ebp),%eax
801015ea:	85 c0                	test   %eax,%eax
801015ec:	75 0d                	jne    801015fb <bfree+0x91>
		panic("freeing free block");
801015ee:	83 ec 0c             	sub    $0xc,%esp
801015f1:	68 de a3 10 80       	push   $0x8010a3de
801015f6:	e8 6b ef ff ff       	call   80100566 <panic>
	bp->data[bi / 8] &= ~m;
801015fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fe:	8d 50 07             	lea    0x7(%eax),%edx
80101601:	85 c0                	test   %eax,%eax
80101603:	0f 48 c2             	cmovs  %edx,%eax
80101606:	c1 f8 03             	sar    $0x3,%eax
80101609:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010160c:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101611:	89 d1                	mov    %edx,%ecx
80101613:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101616:	f7 d2                	not    %edx
80101618:	21 ca                	and    %ecx,%edx
8010161a:	89 d1                	mov    %edx,%ecx
8010161c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010161f:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
	log_write(bp);
80101623:	83 ec 0c             	sub    $0xc,%esp
80101626:	ff 75 f4             	pushl  -0xc(%ebp)
80101629:	e8 5b 21 00 00       	call   80103789 <log_write>
8010162e:	83 c4 10             	add    $0x10,%esp
	brelse(bp);
80101631:	83 ec 0c             	sub    $0xc,%esp
80101634:	ff 75 f4             	pushl  -0xc(%ebp)
80101637:	e8 f2 eb ff ff       	call   8010022e <brelse>
8010163c:	83 c4 10             	add    $0x10,%esp
}
8010163f:	90                   	nop
80101640:	c9                   	leave  
80101641:	c3                   	ret    

80101642 <iinit>:
	struct spinlock lock;
	struct inode inode[NINODE];
} icache;

void iinit(int dev)
{
80101642:	55                   	push   %ebp
80101643:	89 e5                	mov    %esp,%ebp
80101645:	57                   	push   %edi
80101646:	56                   	push   %esi
80101647:	53                   	push   %ebx
80101648:	83 ec 1c             	sub    $0x1c,%esp
	initlock(&icache.lock, "icache");
8010164b:	83 ec 08             	sub    $0x8,%esp
8010164e:	68 f1 a3 10 80       	push   $0x8010a3f1
80101653:	68 60 42 11 80       	push   $0x80114260
80101658:	e8 0e 54 00 00       	call   80106a6b <initlock>
8010165d:	83 c4 10             	add    $0x10,%esp
	readsb(dev, &sb);
80101660:	83 ec 08             	sub    $0x8,%esp
80101663:	68 40 42 11 80       	push   $0x80114240
80101668:	ff 75 08             	pushl  0x8(%ebp)
8010166b:	e8 18 fd ff ff       	call   80101388 <readsb>
80101670:	83 c4 10             	add    $0x10,%esp
	cprintf
80101673:	a1 58 42 11 80       	mov    0x80114258,%eax
80101678:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010167b:	8b 3d 54 42 11 80    	mov    0x80114254,%edi
80101681:	8b 35 50 42 11 80    	mov    0x80114250,%esi
80101687:	8b 1d 4c 42 11 80    	mov    0x8011424c,%ebx
8010168d:	8b 0d 48 42 11 80    	mov    0x80114248,%ecx
80101693:	8b 15 44 42 11 80    	mov    0x80114244,%edx
80101699:	a1 40 42 11 80       	mov    0x80114240,%eax
8010169e:	ff 75 e4             	pushl  -0x1c(%ebp)
801016a1:	57                   	push   %edi
801016a2:	56                   	push   %esi
801016a3:	53                   	push   %ebx
801016a4:	51                   	push   %ecx
801016a5:	52                   	push   %edx
801016a6:	50                   	push   %eax
801016a7:	68 f8 a3 10 80       	push   $0x8010a3f8
801016ac:	e8 15 ed ff ff       	call   801003c6 <cprintf>
801016b1:	83 c4 20             	add    $0x20,%esp
	    ("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n",
	     sb.size, sb.nblocks, sb.ninodes, sb.nlog, sb.logstart,
	     sb.inodestart, sb.bmapstart);
}
801016b4:	90                   	nop
801016b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016b8:	5b                   	pop    %ebx
801016b9:	5e                   	pop    %esi
801016ba:	5f                   	pop    %edi
801016bb:	5d                   	pop    %ebp
801016bc:	c3                   	ret    

801016bd <ialloc>:

//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode *ialloc(uint dev, short type)
{
801016bd:	55                   	push   %ebp
801016be:	89 e5                	mov    %esp,%ebp
801016c0:	83 ec 28             	sub    $0x28,%esp
801016c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801016c6:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
	int inum;
	struct buf *bp;
	struct dinode *dip;

	for (inum = 1; inum < sb.ninodes; inum++) {
801016ca:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016d1:	e9 9e 00 00 00       	jmp    80101774 <ialloc+0xb7>
		bp = bread(dev, IBLOCK(inum, sb));
801016d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d9:	c1 e8 03             	shr    $0x3,%eax
801016dc:	89 c2                	mov    %eax,%edx
801016de:	a1 54 42 11 80       	mov    0x80114254,%eax
801016e3:	01 d0                	add    %edx,%eax
801016e5:	83 ec 08             	sub    $0x8,%esp
801016e8:	50                   	push   %eax
801016e9:	ff 75 08             	pushl  0x8(%ebp)
801016ec:	e8 c5 ea ff ff       	call   801001b6 <bread>
801016f1:	83 c4 10             	add    $0x10,%esp
801016f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
		dip = (struct dinode *)bp->data + inum % IPB;
801016f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016fa:	8d 50 18             	lea    0x18(%eax),%edx
801016fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101700:	83 e0 07             	and    $0x7,%eax
80101703:	c1 e0 06             	shl    $0x6,%eax
80101706:	01 d0                	add    %edx,%eax
80101708:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if (dip->type == 0) {	// a free inode
8010170b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010170e:	0f b7 00             	movzwl (%eax),%eax
80101711:	66 85 c0             	test   %ax,%ax
80101714:	75 4c                	jne    80101762 <ialloc+0xa5>
			memset(dip, 0, sizeof(*dip));
80101716:	83 ec 04             	sub    $0x4,%esp
80101719:	6a 40                	push   $0x40
8010171b:	6a 00                	push   $0x0
8010171d:	ff 75 ec             	pushl  -0x14(%ebp)
80101720:	e8 cb 55 00 00       	call   80106cf0 <memset>
80101725:	83 c4 10             	add    $0x10,%esp
			dip->type = type;
80101728:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010172b:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010172f:	66 89 10             	mov    %dx,(%eax)
			log_write(bp);	// mark it allocated on the disk
80101732:	83 ec 0c             	sub    $0xc,%esp
80101735:	ff 75 f0             	pushl  -0x10(%ebp)
80101738:	e8 4c 20 00 00       	call   80103789 <log_write>
8010173d:	83 c4 10             	add    $0x10,%esp
			brelse(bp);
80101740:	83 ec 0c             	sub    $0xc,%esp
80101743:	ff 75 f0             	pushl  -0x10(%ebp)
80101746:	e8 e3 ea ff ff       	call   8010022e <brelse>
8010174b:	83 c4 10             	add    $0x10,%esp
			return iget(dev, inum);
8010174e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101751:	83 ec 08             	sub    $0x8,%esp
80101754:	50                   	push   %eax
80101755:	ff 75 08             	pushl  0x8(%ebp)
80101758:	e8 f8 00 00 00       	call   80101855 <iget>
8010175d:	83 c4 10             	add    $0x10,%esp
80101760:	eb 30                	jmp    80101792 <ialloc+0xd5>
		}
		brelse(bp);
80101762:	83 ec 0c             	sub    $0xc,%esp
80101765:	ff 75 f0             	pushl  -0x10(%ebp)
80101768:	e8 c1 ea ff ff       	call   8010022e <brelse>
8010176d:	83 c4 10             	add    $0x10,%esp
{
	int inum;
	struct buf *bp;
	struct dinode *dip;

	for (inum = 1; inum < sb.ninodes; inum++) {
80101770:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101774:	8b 15 48 42 11 80    	mov    0x80114248,%edx
8010177a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010177d:	39 c2                	cmp    %eax,%edx
8010177f:	0f 87 51 ff ff ff    	ja     801016d6 <ialloc+0x19>
			brelse(bp);
			return iget(dev, inum);
		}
		brelse(bp);
	}
	panic("ialloc: no inodes");
80101785:	83 ec 0c             	sub    $0xc,%esp
80101788:	68 4b a4 10 80       	push   $0x8010a44b
8010178d:	e8 d4 ed ff ff       	call   80100566 <panic>
}
80101792:	c9                   	leave  
80101793:	c3                   	ret    

80101794 <iupdate>:

// Copy a modified in-memory inode to disk.
void iupdate(struct inode *ip)
{
80101794:	55                   	push   %ebp
80101795:	89 e5                	mov    %esp,%ebp
80101797:	83 ec 18             	sub    $0x18,%esp
	struct buf *bp;
	struct dinode *dip;

	bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010179a:	8b 45 08             	mov    0x8(%ebp),%eax
8010179d:	8b 40 04             	mov    0x4(%eax),%eax
801017a0:	c1 e8 03             	shr    $0x3,%eax
801017a3:	89 c2                	mov    %eax,%edx
801017a5:	a1 54 42 11 80       	mov    0x80114254,%eax
801017aa:	01 c2                	add    %eax,%edx
801017ac:	8b 45 08             	mov    0x8(%ebp),%eax
801017af:	8b 00                	mov    (%eax),%eax
801017b1:	83 ec 08             	sub    $0x8,%esp
801017b4:	52                   	push   %edx
801017b5:	50                   	push   %eax
801017b6:	e8 fb e9 ff ff       	call   801001b6 <bread>
801017bb:	83 c4 10             	add    $0x10,%esp
801017be:	89 45 f4             	mov    %eax,-0xc(%ebp)
	dip = (struct dinode *)bp->data + ip->inum % IPB;
801017c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c4:	8d 50 18             	lea    0x18(%eax),%edx
801017c7:	8b 45 08             	mov    0x8(%ebp),%eax
801017ca:	8b 40 04             	mov    0x4(%eax),%eax
801017cd:	83 e0 07             	and    $0x7,%eax
801017d0:	c1 e0 06             	shl    $0x6,%eax
801017d3:	01 d0                	add    %edx,%eax
801017d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	dip->type = ip->type;
801017d8:	8b 45 08             	mov    0x8(%ebp),%eax
801017db:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801017df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017e2:	66 89 10             	mov    %dx,(%eax)
	dip->major = ip->major;
801017e5:	8b 45 08             	mov    0x8(%ebp),%eax
801017e8:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801017ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017ef:	66 89 50 02          	mov    %dx,0x2(%eax)
	dip->minor = ip->minor;
801017f3:	8b 45 08             	mov    0x8(%ebp),%eax
801017f6:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801017fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017fd:	66 89 50 04          	mov    %dx,0x4(%eax)
	dip->nlink = ip->nlink;
80101801:	8b 45 08             	mov    0x8(%ebp),%eax
80101804:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101808:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010180b:	66 89 50 06          	mov    %dx,0x6(%eax)
	dip->size = ip->size;
8010180f:	8b 45 08             	mov    0x8(%ebp),%eax
80101812:	8b 50 18             	mov    0x18(%eax),%edx
80101815:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101818:	89 50 08             	mov    %edx,0x8(%eax)
	memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010181b:	8b 45 08             	mov    0x8(%ebp),%eax
8010181e:	8d 50 1c             	lea    0x1c(%eax),%edx
80101821:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101824:	83 c0 0c             	add    $0xc,%eax
80101827:	83 ec 04             	sub    $0x4,%esp
8010182a:	6a 34                	push   $0x34
8010182c:	52                   	push   %edx
8010182d:	50                   	push   %eax
8010182e:	e8 7c 55 00 00       	call   80106daf <memmove>
80101833:	83 c4 10             	add    $0x10,%esp
	log_write(bp);
80101836:	83 ec 0c             	sub    $0xc,%esp
80101839:	ff 75 f4             	pushl  -0xc(%ebp)
8010183c:	e8 48 1f 00 00       	call   80103789 <log_write>
80101841:	83 c4 10             	add    $0x10,%esp
	brelse(bp);
80101844:	83 ec 0c             	sub    $0xc,%esp
80101847:	ff 75 f4             	pushl  -0xc(%ebp)
8010184a:	e8 df e9 ff ff       	call   8010022e <brelse>
8010184f:	83 c4 10             	add    $0x10,%esp
}
80101852:	90                   	nop
80101853:	c9                   	leave  
80101854:	c3                   	ret    

80101855 <iget>:

// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode *iget(uint dev, uint inum)
{
80101855:	55                   	push   %ebp
80101856:	89 e5                	mov    %esp,%ebp
80101858:	83 ec 18             	sub    $0x18,%esp
	struct inode *ip, *empty;

	acquire(&icache.lock);
8010185b:	83 ec 0c             	sub    $0xc,%esp
8010185e:	68 60 42 11 80       	push   $0x80114260
80101863:	e8 25 52 00 00       	call   80106a8d <acquire>
80101868:	83 c4 10             	add    $0x10,%esp

	// Is the inode already cached?
	empty = 0;
8010186b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	for (ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++) {
80101872:	c7 45 f4 94 42 11 80 	movl   $0x80114294,-0xc(%ebp)
80101879:	eb 5d                	jmp    801018d8 <iget+0x83>
		if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
8010187b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187e:	8b 40 08             	mov    0x8(%eax),%eax
80101881:	85 c0                	test   %eax,%eax
80101883:	7e 39                	jle    801018be <iget+0x69>
80101885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101888:	8b 00                	mov    (%eax),%eax
8010188a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010188d:	75 2f                	jne    801018be <iget+0x69>
8010188f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101892:	8b 40 04             	mov    0x4(%eax),%eax
80101895:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101898:	75 24                	jne    801018be <iget+0x69>
			ip->ref++;
8010189a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010189d:	8b 40 08             	mov    0x8(%eax),%eax
801018a0:	8d 50 01             	lea    0x1(%eax),%edx
801018a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a6:	89 50 08             	mov    %edx,0x8(%eax)
			release(&icache.lock);
801018a9:	83 ec 0c             	sub    $0xc,%esp
801018ac:	68 60 42 11 80       	push   $0x80114260
801018b1:	e8 3e 52 00 00       	call   80106af4 <release>
801018b6:	83 c4 10             	add    $0x10,%esp
			return ip;
801018b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018bc:	eb 74                	jmp    80101932 <iget+0xdd>
		}
		if (empty == 0 && ip->ref == 0)	// Remember empty slot.
801018be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018c2:	75 10                	jne    801018d4 <iget+0x7f>
801018c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c7:	8b 40 08             	mov    0x8(%eax),%eax
801018ca:	85 c0                	test   %eax,%eax
801018cc:	75 06                	jne    801018d4 <iget+0x7f>
			empty = ip;
801018ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d1:	89 45 f0             	mov    %eax,-0x10(%ebp)

	acquire(&icache.lock);

	// Is the inode already cached?
	empty = 0;
	for (ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++) {
801018d4:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801018d8:	81 7d f4 34 52 11 80 	cmpl   $0x80115234,-0xc(%ebp)
801018df:	72 9a                	jb     8010187b <iget+0x26>
		if (empty == 0 && ip->ref == 0)	// Remember empty slot.
			empty = ip;
	}

	// Recycle an inode cache entry.
	if (empty == 0)
801018e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018e5:	75 0d                	jne    801018f4 <iget+0x9f>
		panic("iget: no inodes");
801018e7:	83 ec 0c             	sub    $0xc,%esp
801018ea:	68 5d a4 10 80       	push   $0x8010a45d
801018ef:	e8 72 ec ff ff       	call   80100566 <panic>

	ip = empty;
801018f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	ip->dev = dev;
801018fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fd:	8b 55 08             	mov    0x8(%ebp),%edx
80101900:	89 10                	mov    %edx,(%eax)
	ip->inum = inum;
80101902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101905:	8b 55 0c             	mov    0xc(%ebp),%edx
80101908:	89 50 04             	mov    %edx,0x4(%eax)
	ip->ref = 1;
8010190b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	ip->flags = 0;
80101915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101918:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	release(&icache.lock);
8010191f:	83 ec 0c             	sub    $0xc,%esp
80101922:	68 60 42 11 80       	push   $0x80114260
80101927:	e8 c8 51 00 00       	call   80106af4 <release>
8010192c:	83 c4 10             	add    $0x10,%esp

	return ip;
8010192f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101932:	c9                   	leave  
80101933:	c3                   	ret    

80101934 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode *idup(struct inode *ip)
{
80101934:	55                   	push   %ebp
80101935:	89 e5                	mov    %esp,%ebp
80101937:	83 ec 08             	sub    $0x8,%esp
	acquire(&icache.lock);
8010193a:	83 ec 0c             	sub    $0xc,%esp
8010193d:	68 60 42 11 80       	push   $0x80114260
80101942:	e8 46 51 00 00       	call   80106a8d <acquire>
80101947:	83 c4 10             	add    $0x10,%esp
	ip->ref++;
8010194a:	8b 45 08             	mov    0x8(%ebp),%eax
8010194d:	8b 40 08             	mov    0x8(%eax),%eax
80101950:	8d 50 01             	lea    0x1(%eax),%edx
80101953:	8b 45 08             	mov    0x8(%ebp),%eax
80101956:	89 50 08             	mov    %edx,0x8(%eax)
	release(&icache.lock);
80101959:	83 ec 0c             	sub    $0xc,%esp
8010195c:	68 60 42 11 80       	push   $0x80114260
80101961:	e8 8e 51 00 00       	call   80106af4 <release>
80101966:	83 c4 10             	add    $0x10,%esp
	return ip;
80101969:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010196c:	c9                   	leave  
8010196d:	c3                   	ret    

8010196e <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void ilock(struct inode *ip)
{
8010196e:	55                   	push   %ebp
8010196f:	89 e5                	mov    %esp,%ebp
80101971:	83 ec 18             	sub    $0x18,%esp
	struct buf *bp;
	struct dinode *dip;

	if (ip == 0 || ip->ref < 1)
80101974:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101978:	74 0a                	je     80101984 <ilock+0x16>
8010197a:	8b 45 08             	mov    0x8(%ebp),%eax
8010197d:	8b 40 08             	mov    0x8(%eax),%eax
80101980:	85 c0                	test   %eax,%eax
80101982:	7f 0d                	jg     80101991 <ilock+0x23>
		panic("ilock");
80101984:	83 ec 0c             	sub    $0xc,%esp
80101987:	68 6d a4 10 80       	push   $0x8010a46d
8010198c:	e8 d5 eb ff ff       	call   80100566 <panic>

	acquire(&icache.lock);
80101991:	83 ec 0c             	sub    $0xc,%esp
80101994:	68 60 42 11 80       	push   $0x80114260
80101999:	e8 ef 50 00 00       	call   80106a8d <acquire>
8010199e:	83 c4 10             	add    $0x10,%esp
	while (ip->flags & I_BUSY)
801019a1:	eb 13                	jmp    801019b6 <ilock+0x48>
		sleep(ip, &icache.lock);
801019a3:	83 ec 08             	sub    $0x8,%esp
801019a6:	68 60 42 11 80       	push   $0x80114260
801019ab:	ff 75 08             	pushl  0x8(%ebp)
801019ae:	e8 43 48 00 00       	call   801061f6 <sleep>
801019b3:	83 c4 10             	add    $0x10,%esp

	if (ip == 0 || ip->ref < 1)
		panic("ilock");

	acquire(&icache.lock);
	while (ip->flags & I_BUSY)
801019b6:	8b 45 08             	mov    0x8(%ebp),%eax
801019b9:	8b 40 0c             	mov    0xc(%eax),%eax
801019bc:	83 e0 01             	and    $0x1,%eax
801019bf:	85 c0                	test   %eax,%eax
801019c1:	75 e0                	jne    801019a3 <ilock+0x35>
		sleep(ip, &icache.lock);
	ip->flags |= I_BUSY;
801019c3:	8b 45 08             	mov    0x8(%ebp),%eax
801019c6:	8b 40 0c             	mov    0xc(%eax),%eax
801019c9:	83 c8 01             	or     $0x1,%eax
801019cc:	89 c2                	mov    %eax,%edx
801019ce:	8b 45 08             	mov    0x8(%ebp),%eax
801019d1:	89 50 0c             	mov    %edx,0xc(%eax)
	release(&icache.lock);
801019d4:	83 ec 0c             	sub    $0xc,%esp
801019d7:	68 60 42 11 80       	push   $0x80114260
801019dc:	e8 13 51 00 00       	call   80106af4 <release>
801019e1:	83 c4 10             	add    $0x10,%esp

	if (!(ip->flags & I_VALID)) {
801019e4:	8b 45 08             	mov    0x8(%ebp),%eax
801019e7:	8b 40 0c             	mov    0xc(%eax),%eax
801019ea:	83 e0 02             	and    $0x2,%eax
801019ed:	85 c0                	test   %eax,%eax
801019ef:	0f 85 d4 00 00 00    	jne    80101ac9 <ilock+0x15b>
		bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801019f5:	8b 45 08             	mov    0x8(%ebp),%eax
801019f8:	8b 40 04             	mov    0x4(%eax),%eax
801019fb:	c1 e8 03             	shr    $0x3,%eax
801019fe:	89 c2                	mov    %eax,%edx
80101a00:	a1 54 42 11 80       	mov    0x80114254,%eax
80101a05:	01 c2                	add    %eax,%edx
80101a07:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0a:	8b 00                	mov    (%eax),%eax
80101a0c:	83 ec 08             	sub    $0x8,%esp
80101a0f:	52                   	push   %edx
80101a10:	50                   	push   %eax
80101a11:	e8 a0 e7 ff ff       	call   801001b6 <bread>
80101a16:	83 c4 10             	add    $0x10,%esp
80101a19:	89 45 f4             	mov    %eax,-0xc(%ebp)
		dip = (struct dinode *)bp->data + ip->inum % IPB;
80101a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1f:	8d 50 18             	lea    0x18(%eax),%edx
80101a22:	8b 45 08             	mov    0x8(%ebp),%eax
80101a25:	8b 40 04             	mov    0x4(%eax),%eax
80101a28:	83 e0 07             	and    $0x7,%eax
80101a2b:	c1 e0 06             	shl    $0x6,%eax
80101a2e:	01 d0                	add    %edx,%eax
80101a30:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ip->type = dip->type;
80101a33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a36:	0f b7 10             	movzwl (%eax),%edx
80101a39:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3c:	66 89 50 10          	mov    %dx,0x10(%eax)
		ip->major = dip->major;
80101a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a43:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a47:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4a:	66 89 50 12          	mov    %dx,0x12(%eax)
		ip->minor = dip->minor;
80101a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a51:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a55:	8b 45 08             	mov    0x8(%ebp),%eax
80101a58:	66 89 50 14          	mov    %dx,0x14(%eax)
		ip->nlink = dip->nlink;
80101a5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5f:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a63:	8b 45 08             	mov    0x8(%ebp),%eax
80101a66:	66 89 50 16          	mov    %dx,0x16(%eax)
		ip->size = dip->size;
80101a6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6d:	8b 50 08             	mov    0x8(%eax),%edx
80101a70:	8b 45 08             	mov    0x8(%ebp),%eax
80101a73:	89 50 18             	mov    %edx,0x18(%eax)
		memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a79:	8d 50 0c             	lea    0xc(%eax),%edx
80101a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7f:	83 c0 1c             	add    $0x1c,%eax
80101a82:	83 ec 04             	sub    $0x4,%esp
80101a85:	6a 34                	push   $0x34
80101a87:	52                   	push   %edx
80101a88:	50                   	push   %eax
80101a89:	e8 21 53 00 00       	call   80106daf <memmove>
80101a8e:	83 c4 10             	add    $0x10,%esp
		brelse(bp);
80101a91:	83 ec 0c             	sub    $0xc,%esp
80101a94:	ff 75 f4             	pushl  -0xc(%ebp)
80101a97:	e8 92 e7 ff ff       	call   8010022e <brelse>
80101a9c:	83 c4 10             	add    $0x10,%esp
		ip->flags |= I_VALID;
80101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa2:	8b 40 0c             	mov    0xc(%eax),%eax
80101aa5:	83 c8 02             	or     $0x2,%eax
80101aa8:	89 c2                	mov    %eax,%edx
80101aaa:	8b 45 08             	mov    0x8(%ebp),%eax
80101aad:	89 50 0c             	mov    %edx,0xc(%eax)
		if (ip->type == 0)
80101ab0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ab7:	66 85 c0             	test   %ax,%ax
80101aba:	75 0d                	jne    80101ac9 <ilock+0x15b>
			panic("ilock: no type");
80101abc:	83 ec 0c             	sub    $0xc,%esp
80101abf:	68 73 a4 10 80       	push   $0x8010a473
80101ac4:	e8 9d ea ff ff       	call   80100566 <panic>
	}
}
80101ac9:	90                   	nop
80101aca:	c9                   	leave  
80101acb:	c3                   	ret    

80101acc <iunlock>:

// Unlock the given inode.
void iunlock(struct inode *ip)
{
80101acc:	55                   	push   %ebp
80101acd:	89 e5                	mov    %esp,%ebp
80101acf:	83 ec 08             	sub    $0x8,%esp
	if (ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101ad2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ad6:	74 17                	je     80101aef <iunlock+0x23>
80101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80101adb:	8b 40 0c             	mov    0xc(%eax),%eax
80101ade:	83 e0 01             	and    $0x1,%eax
80101ae1:	85 c0                	test   %eax,%eax
80101ae3:	74 0a                	je     80101aef <iunlock+0x23>
80101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae8:	8b 40 08             	mov    0x8(%eax),%eax
80101aeb:	85 c0                	test   %eax,%eax
80101aed:	7f 0d                	jg     80101afc <iunlock+0x30>
		panic("iunlock");
80101aef:	83 ec 0c             	sub    $0xc,%esp
80101af2:	68 82 a4 10 80       	push   $0x8010a482
80101af7:	e8 6a ea ff ff       	call   80100566 <panic>

	acquire(&icache.lock);
80101afc:	83 ec 0c             	sub    $0xc,%esp
80101aff:	68 60 42 11 80       	push   $0x80114260
80101b04:	e8 84 4f 00 00       	call   80106a8d <acquire>
80101b09:	83 c4 10             	add    $0x10,%esp
	ip->flags &= ~I_BUSY;
80101b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0f:	8b 40 0c             	mov    0xc(%eax),%eax
80101b12:	83 e0 fe             	and    $0xfffffffe,%eax
80101b15:	89 c2                	mov    %eax,%edx
80101b17:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1a:	89 50 0c             	mov    %edx,0xc(%eax)
	wakeup(ip);
80101b1d:	83 ec 0c             	sub    $0xc,%esp
80101b20:	ff 75 08             	pushl  0x8(%ebp)
80101b23:	e8 bc 47 00 00       	call   801062e4 <wakeup>
80101b28:	83 c4 10             	add    $0x10,%esp
	release(&icache.lock);
80101b2b:	83 ec 0c             	sub    $0xc,%esp
80101b2e:	68 60 42 11 80       	push   $0x80114260
80101b33:	e8 bc 4f 00 00       	call   80106af4 <release>
80101b38:	83 c4 10             	add    $0x10,%esp
}
80101b3b:	90                   	nop
80101b3c:	c9                   	leave  
80101b3d:	c3                   	ret    

80101b3e <iput>:
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void iput(struct inode *ip)
{
80101b3e:	55                   	push   %ebp
80101b3f:	89 e5                	mov    %esp,%ebp
80101b41:	83 ec 08             	sub    $0x8,%esp
	acquire(&icache.lock);
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	68 60 42 11 80       	push   $0x80114260
80101b4c:	e8 3c 4f 00 00       	call   80106a8d <acquire>
80101b51:	83 c4 10             	add    $0x10,%esp
	if (ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0) {
80101b54:	8b 45 08             	mov    0x8(%ebp),%eax
80101b57:	8b 40 08             	mov    0x8(%eax),%eax
80101b5a:	83 f8 01             	cmp    $0x1,%eax
80101b5d:	0f 85 a9 00 00 00    	jne    80101c0c <iput+0xce>
80101b63:	8b 45 08             	mov    0x8(%ebp),%eax
80101b66:	8b 40 0c             	mov    0xc(%eax),%eax
80101b69:	83 e0 02             	and    $0x2,%eax
80101b6c:	85 c0                	test   %eax,%eax
80101b6e:	0f 84 98 00 00 00    	je     80101c0c <iput+0xce>
80101b74:	8b 45 08             	mov    0x8(%ebp),%eax
80101b77:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b7b:	66 85 c0             	test   %ax,%ax
80101b7e:	0f 85 88 00 00 00    	jne    80101c0c <iput+0xce>
		// inode has no links and no other references: truncate and free.
		if (ip->flags & I_BUSY)
80101b84:	8b 45 08             	mov    0x8(%ebp),%eax
80101b87:	8b 40 0c             	mov    0xc(%eax),%eax
80101b8a:	83 e0 01             	and    $0x1,%eax
80101b8d:	85 c0                	test   %eax,%eax
80101b8f:	74 0d                	je     80101b9e <iput+0x60>
			panic("iput busy");
80101b91:	83 ec 0c             	sub    $0xc,%esp
80101b94:	68 8a a4 10 80       	push   $0x8010a48a
80101b99:	e8 c8 e9 ff ff       	call   80100566 <panic>
		ip->flags |= I_BUSY;
80101b9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba1:	8b 40 0c             	mov    0xc(%eax),%eax
80101ba4:	83 c8 01             	or     $0x1,%eax
80101ba7:	89 c2                	mov    %eax,%edx
80101ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bac:	89 50 0c             	mov    %edx,0xc(%eax)
		release(&icache.lock);
80101baf:	83 ec 0c             	sub    $0xc,%esp
80101bb2:	68 60 42 11 80       	push   $0x80114260
80101bb7:	e8 38 4f 00 00       	call   80106af4 <release>
80101bbc:	83 c4 10             	add    $0x10,%esp
		itrunc(ip);
80101bbf:	83 ec 0c             	sub    $0xc,%esp
80101bc2:	ff 75 08             	pushl  0x8(%ebp)
80101bc5:	e8 a8 01 00 00       	call   80101d72 <itrunc>
80101bca:	83 c4 10             	add    $0x10,%esp
		ip->type = 0;
80101bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd0:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
		iupdate(ip);
80101bd6:	83 ec 0c             	sub    $0xc,%esp
80101bd9:	ff 75 08             	pushl  0x8(%ebp)
80101bdc:	e8 b3 fb ff ff       	call   80101794 <iupdate>
80101be1:	83 c4 10             	add    $0x10,%esp
		acquire(&icache.lock);
80101be4:	83 ec 0c             	sub    $0xc,%esp
80101be7:	68 60 42 11 80       	push   $0x80114260
80101bec:	e8 9c 4e 00 00       	call   80106a8d <acquire>
80101bf1:	83 c4 10             	add    $0x10,%esp
		ip->flags = 0;
80101bf4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
		wakeup(ip);
80101bfe:	83 ec 0c             	sub    $0xc,%esp
80101c01:	ff 75 08             	pushl  0x8(%ebp)
80101c04:	e8 db 46 00 00       	call   801062e4 <wakeup>
80101c09:	83 c4 10             	add    $0x10,%esp
	}
	ip->ref--;
80101c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0f:	8b 40 08             	mov    0x8(%eax),%eax
80101c12:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c15:	8b 45 08             	mov    0x8(%ebp),%eax
80101c18:	89 50 08             	mov    %edx,0x8(%eax)
	release(&icache.lock);
80101c1b:	83 ec 0c             	sub    $0xc,%esp
80101c1e:	68 60 42 11 80       	push   $0x80114260
80101c23:	e8 cc 4e 00 00       	call   80106af4 <release>
80101c28:	83 c4 10             	add    $0x10,%esp
}
80101c2b:	90                   	nop
80101c2c:	c9                   	leave  
80101c2d:	c3                   	ret    

80101c2e <iunlockput>:

// Common idiom: unlock, then put.
void iunlockput(struct inode *ip)
{
80101c2e:	55                   	push   %ebp
80101c2f:	89 e5                	mov    %esp,%ebp
80101c31:	83 ec 08             	sub    $0x8,%esp
	iunlock(ip);
80101c34:	83 ec 0c             	sub    $0xc,%esp
80101c37:	ff 75 08             	pushl  0x8(%ebp)
80101c3a:	e8 8d fe ff ff       	call   80101acc <iunlock>
80101c3f:	83 c4 10             	add    $0x10,%esp
	iput(ip);
80101c42:	83 ec 0c             	sub    $0xc,%esp
80101c45:	ff 75 08             	pushl  0x8(%ebp)
80101c48:	e8 f1 fe ff ff       	call   80101b3e <iput>
80101c4d:	83 c4 10             	add    $0x10,%esp
}
80101c50:	90                   	nop
80101c51:	c9                   	leave  
80101c52:	c3                   	ret    

80101c53 <bmap>:
// listed in block ip->addrs[NDIRECT].

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint bmap(struct inode *ip, uint bn)
{
80101c53:	55                   	push   %ebp
80101c54:	89 e5                	mov    %esp,%ebp
80101c56:	53                   	push   %ebx
80101c57:	83 ec 14             	sub    $0x14,%esp
	uint addr, *a;
	struct buf *bp;

	if (bn < NDIRECT) {
80101c5a:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c5e:	77 42                	ja     80101ca2 <bmap+0x4f>
		if ((addr = ip->addrs[bn]) == 0)
80101c60:	8b 45 08             	mov    0x8(%ebp),%eax
80101c63:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c66:	83 c2 04             	add    $0x4,%edx
80101c69:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c74:	75 24                	jne    80101c9a <bmap+0x47>
			ip->addrs[bn] = addr = balloc(ip->dev);
80101c76:	8b 45 08             	mov    0x8(%ebp),%eax
80101c79:	8b 00                	mov    (%eax),%eax
80101c7b:	83 ec 0c             	sub    $0xc,%esp
80101c7e:	50                   	push   %eax
80101c7f:	e8 9a f7 ff ff       	call   8010141e <balloc>
80101c84:	83 c4 10             	add    $0x10,%esp
80101c87:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c90:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c93:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c96:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
		return addr;
80101c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c9d:	e9 cb 00 00 00       	jmp    80101d6d <bmap+0x11a>
	}
	bn -= NDIRECT;
80101ca2:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

	if (bn < NINDIRECT) {
80101ca6:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101caa:	0f 87 b0 00 00 00    	ja     80101d60 <bmap+0x10d>
		// Load indirect block, allocating if necessary.
		if ((addr = ip->addrs[NDIRECT]) == 0)
80101cb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb3:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cbd:	75 1d                	jne    80101cdc <bmap+0x89>
			ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc2:	8b 00                	mov    (%eax),%eax
80101cc4:	83 ec 0c             	sub    $0xc,%esp
80101cc7:	50                   	push   %eax
80101cc8:	e8 51 f7 ff ff       	call   8010141e <balloc>
80101ccd:	83 c4 10             	add    $0x10,%esp
80101cd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cd9:	89 50 4c             	mov    %edx,0x4c(%eax)
		bp = bread(ip->dev, addr);
80101cdc:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdf:	8b 00                	mov    (%eax),%eax
80101ce1:	83 ec 08             	sub    $0x8,%esp
80101ce4:	ff 75 f4             	pushl  -0xc(%ebp)
80101ce7:	50                   	push   %eax
80101ce8:	e8 c9 e4 ff ff       	call   801001b6 <bread>
80101ced:	83 c4 10             	add    $0x10,%esp
80101cf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
		a = (uint *) bp->data;
80101cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cf6:	83 c0 18             	add    $0x18,%eax
80101cf9:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if ((addr = a[bn]) == 0) {
80101cfc:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d06:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d09:	01 d0                	add    %edx,%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d14:	75 37                	jne    80101d4d <bmap+0xfa>
			a[bn] = addr = balloc(ip->dev);
80101d16:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d19:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d23:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101d26:	8b 45 08             	mov    0x8(%ebp),%eax
80101d29:	8b 00                	mov    (%eax),%eax
80101d2b:	83 ec 0c             	sub    $0xc,%esp
80101d2e:	50                   	push   %eax
80101d2f:	e8 ea f6 ff ff       	call   8010141e <balloc>
80101d34:	83 c4 10             	add    $0x10,%esp
80101d37:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d3d:	89 03                	mov    %eax,(%ebx)
			log_write(bp);
80101d3f:	83 ec 0c             	sub    $0xc,%esp
80101d42:	ff 75 f0             	pushl  -0x10(%ebp)
80101d45:	e8 3f 1a 00 00       	call   80103789 <log_write>
80101d4a:	83 c4 10             	add    $0x10,%esp
		}
		brelse(bp);
80101d4d:	83 ec 0c             	sub    $0xc,%esp
80101d50:	ff 75 f0             	pushl  -0x10(%ebp)
80101d53:	e8 d6 e4 ff ff       	call   8010022e <brelse>
80101d58:	83 c4 10             	add    $0x10,%esp
		return addr;
80101d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d5e:	eb 0d                	jmp    80101d6d <bmap+0x11a>
	}

	panic("bmap: out of range");
80101d60:	83 ec 0c             	sub    $0xc,%esp
80101d63:	68 94 a4 10 80       	push   $0x8010a494
80101d68:	e8 f9 e7 ff ff       	call   80100566 <panic>
}
80101d6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101d70:	c9                   	leave  
80101d71:	c3                   	ret    

80101d72 <itrunc>:
// Only called when the inode has no links
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void itrunc(struct inode *ip)
{
80101d72:	55                   	push   %ebp
80101d73:	89 e5                	mov    %esp,%ebp
80101d75:	83 ec 18             	sub    $0x18,%esp
	int i, j;
	struct buf *bp;
	uint *a;

	for (i = 0; i < NDIRECT; i++) {
80101d78:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d7f:	eb 45                	jmp    80101dc6 <itrunc+0x54>
		if (ip->addrs[i]) {
80101d81:	8b 45 08             	mov    0x8(%ebp),%eax
80101d84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d87:	83 c2 04             	add    $0x4,%edx
80101d8a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8e:	85 c0                	test   %eax,%eax
80101d90:	74 30                	je     80101dc2 <itrunc+0x50>
			bfree(ip->dev, ip->addrs[i]);
80101d92:	8b 45 08             	mov    0x8(%ebp),%eax
80101d95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d98:	83 c2 04             	add    $0x4,%edx
80101d9b:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d9f:	8b 55 08             	mov    0x8(%ebp),%edx
80101da2:	8b 12                	mov    (%edx),%edx
80101da4:	83 ec 08             	sub    $0x8,%esp
80101da7:	50                   	push   %eax
80101da8:	52                   	push   %edx
80101da9:	e8 bc f7 ff ff       	call   8010156a <bfree>
80101dae:	83 c4 10             	add    $0x10,%esp
			ip->addrs[i] = 0;
80101db1:	8b 45 08             	mov    0x8(%ebp),%eax
80101db4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101db7:	83 c2 04             	add    $0x4,%edx
80101dba:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101dc1:	00 
{
	int i, j;
	struct buf *bp;
	uint *a;

	for (i = 0; i < NDIRECT; i++) {
80101dc2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dc6:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dca:	7e b5                	jle    80101d81 <itrunc+0xf>
			bfree(ip->dev, ip->addrs[i]);
			ip->addrs[i] = 0;
		}
	}

	if (ip->addrs[NDIRECT]) {
80101dcc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcf:	8b 40 4c             	mov    0x4c(%eax),%eax
80101dd2:	85 c0                	test   %eax,%eax
80101dd4:	0f 84 a1 00 00 00    	je     80101e7b <itrunc+0x109>
		bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dda:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddd:	8b 50 4c             	mov    0x4c(%eax),%edx
80101de0:	8b 45 08             	mov    0x8(%ebp),%eax
80101de3:	8b 00                	mov    (%eax),%eax
80101de5:	83 ec 08             	sub    $0x8,%esp
80101de8:	52                   	push   %edx
80101de9:	50                   	push   %eax
80101dea:	e8 c7 e3 ff ff       	call   801001b6 <bread>
80101def:	83 c4 10             	add    $0x10,%esp
80101df2:	89 45 ec             	mov    %eax,-0x14(%ebp)
		a = (uint *) bp->data;
80101df5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101df8:	83 c0 18             	add    $0x18,%eax
80101dfb:	89 45 e8             	mov    %eax,-0x18(%ebp)
		for (j = 0; j < NINDIRECT; j++) {
80101dfe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e05:	eb 3c                	jmp    80101e43 <itrunc+0xd1>
			if (a[j])
80101e07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e0a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e11:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e14:	01 d0                	add    %edx,%eax
80101e16:	8b 00                	mov    (%eax),%eax
80101e18:	85 c0                	test   %eax,%eax
80101e1a:	74 23                	je     80101e3f <itrunc+0xcd>
				bfree(ip->dev, a[j]);
80101e1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e26:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e29:	01 d0                	add    %edx,%eax
80101e2b:	8b 00                	mov    (%eax),%eax
80101e2d:	8b 55 08             	mov    0x8(%ebp),%edx
80101e30:	8b 12                	mov    (%edx),%edx
80101e32:	83 ec 08             	sub    $0x8,%esp
80101e35:	50                   	push   %eax
80101e36:	52                   	push   %edx
80101e37:	e8 2e f7 ff ff       	call   8010156a <bfree>
80101e3c:	83 c4 10             	add    $0x10,%esp
	}

	if (ip->addrs[NDIRECT]) {
		bp = bread(ip->dev, ip->addrs[NDIRECT]);
		a = (uint *) bp->data;
		for (j = 0; j < NINDIRECT; j++) {
80101e3f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e46:	83 f8 7f             	cmp    $0x7f,%eax
80101e49:	76 bc                	jbe    80101e07 <itrunc+0x95>
			if (a[j])
				bfree(ip->dev, a[j]);
		}
		brelse(bp);
80101e4b:	83 ec 0c             	sub    $0xc,%esp
80101e4e:	ff 75 ec             	pushl  -0x14(%ebp)
80101e51:	e8 d8 e3 ff ff       	call   8010022e <brelse>
80101e56:	83 c4 10             	add    $0x10,%esp
		bfree(ip->dev, ip->addrs[NDIRECT]);
80101e59:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5c:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e5f:	8b 55 08             	mov    0x8(%ebp),%edx
80101e62:	8b 12                	mov    (%edx),%edx
80101e64:	83 ec 08             	sub    $0x8,%esp
80101e67:	50                   	push   %eax
80101e68:	52                   	push   %edx
80101e69:	e8 fc f6 ff ff       	call   8010156a <bfree>
80101e6e:	83 c4 10             	add    $0x10,%esp
		ip->addrs[NDIRECT] = 0;
80101e71:	8b 45 08             	mov    0x8(%ebp),%eax
80101e74:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
	}

	ip->size = 0;
80101e7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7e:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
	iupdate(ip);
80101e85:	83 ec 0c             	sub    $0xc,%esp
80101e88:	ff 75 08             	pushl  0x8(%ebp)
80101e8b:	e8 04 f9 ff ff       	call   80101794 <iupdate>
80101e90:	83 c4 10             	add    $0x10,%esp
}
80101e93:	90                   	nop
80101e94:	c9                   	leave  
80101e95:	c3                   	ret    

80101e96 <stati>:

// Copy stat information from inode.
void stati(struct inode *ip, struct stat *st)
{
80101e96:	55                   	push   %ebp
80101e97:	89 e5                	mov    %esp,%ebp
	st->dev = ip->dev;
80101e99:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9c:	8b 00                	mov    (%eax),%eax
80101e9e:	89 c2                	mov    %eax,%edx
80101ea0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea3:	89 50 04             	mov    %edx,0x4(%eax)
	st->ino = ip->inum;
80101ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea9:	8b 50 04             	mov    0x4(%eax),%edx
80101eac:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eaf:	89 50 08             	mov    %edx,0x8(%eax)
	st->type = ip->type;
80101eb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb5:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ebc:	66 89 10             	mov    %dx,(%eax)
	st->nlink = ip->nlink;
80101ebf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec2:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101ec6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec9:	66 89 50 0c          	mov    %dx,0xc(%eax)
	st->size = ip->size;
80101ecd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed0:	8b 50 18             	mov    0x18(%eax),%edx
80101ed3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed6:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed9:	90                   	nop
80101eda:	5d                   	pop    %ebp
80101edb:	c3                   	ret    

80101edc <readi>:

//PAGEBREAK!
// Read data from inode.
int readi(struct inode *ip, char *dst, uint off, uint n)
{
80101edc:	55                   	push   %ebp
80101edd:	89 e5                	mov    %esp,%ebp
80101edf:	83 ec 18             	sub    $0x18,%esp
	uint tot, m;
	struct buf *bp;

	if (ip->type == T_DEV) {
80101ee2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ee9:	66 83 f8 03          	cmp    $0x3,%ax
80101eed:	75 5c                	jne    80101f4b <readi+0x6f>
		if (ip->major < 0 || ip->major >= NDEV
80101eef:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef6:	66 85 c0             	test   %ax,%ax
80101ef9:	78 20                	js     80101f1b <readi+0x3f>
80101efb:	8b 45 08             	mov    0x8(%ebp),%eax
80101efe:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f02:	66 83 f8 09          	cmp    $0x9,%ax
80101f06:	7f 13                	jg     80101f1b <readi+0x3f>
		    || !devsw[ip->major].read)
80101f08:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f0f:	98                   	cwtl   
80101f10:	8b 04 c5 e0 41 11 80 	mov    -0x7feebe20(,%eax,8),%eax
80101f17:	85 c0                	test   %eax,%eax
80101f19:	75 0a                	jne    80101f25 <readi+0x49>
			return -1;
80101f1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f20:	e9 0c 01 00 00       	jmp    80102031 <readi+0x155>
		return devsw[ip->major].read(ip, dst, n);
80101f25:	8b 45 08             	mov    0x8(%ebp),%eax
80101f28:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f2c:	98                   	cwtl   
80101f2d:	8b 04 c5 e0 41 11 80 	mov    -0x7feebe20(,%eax,8),%eax
80101f34:	8b 55 14             	mov    0x14(%ebp),%edx
80101f37:	83 ec 04             	sub    $0x4,%esp
80101f3a:	52                   	push   %edx
80101f3b:	ff 75 0c             	pushl  0xc(%ebp)
80101f3e:	ff 75 08             	pushl  0x8(%ebp)
80101f41:	ff d0                	call   *%eax
80101f43:	83 c4 10             	add    $0x10,%esp
80101f46:	e9 e6 00 00 00       	jmp    80102031 <readi+0x155>
	}

	if (off > ip->size || off + n < off)
80101f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4e:	8b 40 18             	mov    0x18(%eax),%eax
80101f51:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f54:	72 0d                	jb     80101f63 <readi+0x87>
80101f56:	8b 55 10             	mov    0x10(%ebp),%edx
80101f59:	8b 45 14             	mov    0x14(%ebp),%eax
80101f5c:	01 d0                	add    %edx,%eax
80101f5e:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f61:	73 0a                	jae    80101f6d <readi+0x91>
		return -1;
80101f63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f68:	e9 c4 00 00 00       	jmp    80102031 <readi+0x155>
	if (off + n > ip->size)
80101f6d:	8b 55 10             	mov    0x10(%ebp),%edx
80101f70:	8b 45 14             	mov    0x14(%ebp),%eax
80101f73:	01 c2                	add    %eax,%edx
80101f75:	8b 45 08             	mov    0x8(%ebp),%eax
80101f78:	8b 40 18             	mov    0x18(%eax),%eax
80101f7b:	39 c2                	cmp    %eax,%edx
80101f7d:	76 0c                	jbe    80101f8b <readi+0xaf>
		n = ip->size - off;
80101f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f82:	8b 40 18             	mov    0x18(%eax),%eax
80101f85:	2b 45 10             	sub    0x10(%ebp),%eax
80101f88:	89 45 14             	mov    %eax,0x14(%ebp)

	for (tot = 0; tot < n; tot += m, off += m, dst += m) {
80101f8b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f92:	e9 8b 00 00 00       	jmp    80102022 <readi+0x146>
		bp = bread(ip->dev, bmap(ip, off / BSIZE));
80101f97:	8b 45 10             	mov    0x10(%ebp),%eax
80101f9a:	c1 e8 09             	shr    $0x9,%eax
80101f9d:	83 ec 08             	sub    $0x8,%esp
80101fa0:	50                   	push   %eax
80101fa1:	ff 75 08             	pushl  0x8(%ebp)
80101fa4:	e8 aa fc ff ff       	call   80101c53 <bmap>
80101fa9:	83 c4 10             	add    $0x10,%esp
80101fac:	89 c2                	mov    %eax,%edx
80101fae:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb1:	8b 00                	mov    (%eax),%eax
80101fb3:	83 ec 08             	sub    $0x8,%esp
80101fb6:	52                   	push   %edx
80101fb7:	50                   	push   %eax
80101fb8:	e8 f9 e1 ff ff       	call   801001b6 <bread>
80101fbd:	83 c4 10             	add    $0x10,%esp
80101fc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
		m = min(n - tot, BSIZE - off % BSIZE);
80101fc3:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc6:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fcb:	ba 00 02 00 00       	mov    $0x200,%edx
80101fd0:	29 c2                	sub    %eax,%edx
80101fd2:	8b 45 14             	mov    0x14(%ebp),%eax
80101fd5:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd8:	39 c2                	cmp    %eax,%edx
80101fda:	0f 46 c2             	cmovbe %edx,%eax
80101fdd:	89 45 ec             	mov    %eax,-0x14(%ebp)
		memmove(dst, bp->data + off % BSIZE, m);
80101fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe3:	8d 50 18             	lea    0x18(%eax),%edx
80101fe6:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe9:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fee:	01 d0                	add    %edx,%eax
80101ff0:	83 ec 04             	sub    $0x4,%esp
80101ff3:	ff 75 ec             	pushl  -0x14(%ebp)
80101ff6:	50                   	push   %eax
80101ff7:	ff 75 0c             	pushl  0xc(%ebp)
80101ffa:	e8 b0 4d 00 00       	call   80106daf <memmove>
80101fff:	83 c4 10             	add    $0x10,%esp
		brelse(bp);
80102002:	83 ec 0c             	sub    $0xc,%esp
80102005:	ff 75 f0             	pushl  -0x10(%ebp)
80102008:	e8 21 e2 ff ff       	call   8010022e <brelse>
8010200d:	83 c4 10             	add    $0x10,%esp
	if (off > ip->size || off + n < off)
		return -1;
	if (off + n > ip->size)
		n = ip->size - off;

	for (tot = 0; tot < n; tot += m, off += m, dst += m) {
80102010:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102013:	01 45 f4             	add    %eax,-0xc(%ebp)
80102016:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102019:	01 45 10             	add    %eax,0x10(%ebp)
8010201c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201f:	01 45 0c             	add    %eax,0xc(%ebp)
80102022:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102025:	3b 45 14             	cmp    0x14(%ebp),%eax
80102028:	0f 82 69 ff ff ff    	jb     80101f97 <readi+0xbb>
		bp = bread(ip->dev, bmap(ip, off / BSIZE));
		m = min(n - tot, BSIZE - off % BSIZE);
		memmove(dst, bp->data + off % BSIZE, m);
		brelse(bp);
	}
	return n;
8010202e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102031:	c9                   	leave  
80102032:	c3                   	ret    

80102033 <writei>:

// PAGEBREAK!
// Write data to inode.
int writei(struct inode *ip, char *src, uint off, uint n)
{
80102033:	55                   	push   %ebp
80102034:	89 e5                	mov    %esp,%ebp
80102036:	83 ec 18             	sub    $0x18,%esp
	uint tot, m;
	struct buf *bp;

	if (ip->type == T_DEV) {
80102039:	8b 45 08             	mov    0x8(%ebp),%eax
8010203c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102040:	66 83 f8 03          	cmp    $0x3,%ax
80102044:	75 5c                	jne    801020a2 <writei+0x6f>
		if (ip->major < 0 || ip->major >= NDEV
80102046:	8b 45 08             	mov    0x8(%ebp),%eax
80102049:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010204d:	66 85 c0             	test   %ax,%ax
80102050:	78 20                	js     80102072 <writei+0x3f>
80102052:	8b 45 08             	mov    0x8(%ebp),%eax
80102055:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102059:	66 83 f8 09          	cmp    $0x9,%ax
8010205d:	7f 13                	jg     80102072 <writei+0x3f>
		    || !devsw[ip->major].write)
8010205f:	8b 45 08             	mov    0x8(%ebp),%eax
80102062:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102066:	98                   	cwtl   
80102067:	8b 04 c5 e4 41 11 80 	mov    -0x7feebe1c(,%eax,8),%eax
8010206e:	85 c0                	test   %eax,%eax
80102070:	75 0a                	jne    8010207c <writei+0x49>
			return -1;
80102072:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102077:	e9 3d 01 00 00       	jmp    801021b9 <writei+0x186>
		return devsw[ip->major].write(ip, src, n);
8010207c:	8b 45 08             	mov    0x8(%ebp),%eax
8010207f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102083:	98                   	cwtl   
80102084:	8b 04 c5 e4 41 11 80 	mov    -0x7feebe1c(,%eax,8),%eax
8010208b:	8b 55 14             	mov    0x14(%ebp),%edx
8010208e:	83 ec 04             	sub    $0x4,%esp
80102091:	52                   	push   %edx
80102092:	ff 75 0c             	pushl  0xc(%ebp)
80102095:	ff 75 08             	pushl  0x8(%ebp)
80102098:	ff d0                	call   *%eax
8010209a:	83 c4 10             	add    $0x10,%esp
8010209d:	e9 17 01 00 00       	jmp    801021b9 <writei+0x186>
	}

	if (off > ip->size || off + n < off)
801020a2:	8b 45 08             	mov    0x8(%ebp),%eax
801020a5:	8b 40 18             	mov    0x18(%eax),%eax
801020a8:	3b 45 10             	cmp    0x10(%ebp),%eax
801020ab:	72 0d                	jb     801020ba <writei+0x87>
801020ad:	8b 55 10             	mov    0x10(%ebp),%edx
801020b0:	8b 45 14             	mov    0x14(%ebp),%eax
801020b3:	01 d0                	add    %edx,%eax
801020b5:	3b 45 10             	cmp    0x10(%ebp),%eax
801020b8:	73 0a                	jae    801020c4 <writei+0x91>
		return -1;
801020ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020bf:	e9 f5 00 00 00       	jmp    801021b9 <writei+0x186>
	if (off + n > MAXFILE * BSIZE)
801020c4:	8b 55 10             	mov    0x10(%ebp),%edx
801020c7:	8b 45 14             	mov    0x14(%ebp),%eax
801020ca:	01 d0                	add    %edx,%eax
801020cc:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020d1:	76 0a                	jbe    801020dd <writei+0xaa>
		return -1;
801020d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d8:	e9 dc 00 00 00       	jmp    801021b9 <writei+0x186>

	for (tot = 0; tot < n; tot += m, off += m, src += m) {
801020dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020e4:	e9 99 00 00 00       	jmp    80102182 <writei+0x14f>
		bp = bread(ip->dev, bmap(ip, off / BSIZE));
801020e9:	8b 45 10             	mov    0x10(%ebp),%eax
801020ec:	c1 e8 09             	shr    $0x9,%eax
801020ef:	83 ec 08             	sub    $0x8,%esp
801020f2:	50                   	push   %eax
801020f3:	ff 75 08             	pushl  0x8(%ebp)
801020f6:	e8 58 fb ff ff       	call   80101c53 <bmap>
801020fb:	83 c4 10             	add    $0x10,%esp
801020fe:	89 c2                	mov    %eax,%edx
80102100:	8b 45 08             	mov    0x8(%ebp),%eax
80102103:	8b 00                	mov    (%eax),%eax
80102105:	83 ec 08             	sub    $0x8,%esp
80102108:	52                   	push   %edx
80102109:	50                   	push   %eax
8010210a:	e8 a7 e0 ff ff       	call   801001b6 <bread>
8010210f:	83 c4 10             	add    $0x10,%esp
80102112:	89 45 f0             	mov    %eax,-0x10(%ebp)
		m = min(n - tot, BSIZE - off % BSIZE);
80102115:	8b 45 10             	mov    0x10(%ebp),%eax
80102118:	25 ff 01 00 00       	and    $0x1ff,%eax
8010211d:	ba 00 02 00 00       	mov    $0x200,%edx
80102122:	29 c2                	sub    %eax,%edx
80102124:	8b 45 14             	mov    0x14(%ebp),%eax
80102127:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010212a:	39 c2                	cmp    %eax,%edx
8010212c:	0f 46 c2             	cmovbe %edx,%eax
8010212f:	89 45 ec             	mov    %eax,-0x14(%ebp)
		memmove(bp->data + off % BSIZE, src, m);
80102132:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102135:	8d 50 18             	lea    0x18(%eax),%edx
80102138:	8b 45 10             	mov    0x10(%ebp),%eax
8010213b:	25 ff 01 00 00       	and    $0x1ff,%eax
80102140:	01 d0                	add    %edx,%eax
80102142:	83 ec 04             	sub    $0x4,%esp
80102145:	ff 75 ec             	pushl  -0x14(%ebp)
80102148:	ff 75 0c             	pushl  0xc(%ebp)
8010214b:	50                   	push   %eax
8010214c:	e8 5e 4c 00 00       	call   80106daf <memmove>
80102151:	83 c4 10             	add    $0x10,%esp
		log_write(bp);
80102154:	83 ec 0c             	sub    $0xc,%esp
80102157:	ff 75 f0             	pushl  -0x10(%ebp)
8010215a:	e8 2a 16 00 00       	call   80103789 <log_write>
8010215f:	83 c4 10             	add    $0x10,%esp
		brelse(bp);
80102162:	83 ec 0c             	sub    $0xc,%esp
80102165:	ff 75 f0             	pushl  -0x10(%ebp)
80102168:	e8 c1 e0 ff ff       	call   8010022e <brelse>
8010216d:	83 c4 10             	add    $0x10,%esp
	if (off > ip->size || off + n < off)
		return -1;
	if (off + n > MAXFILE * BSIZE)
		return -1;

	for (tot = 0; tot < n; tot += m, off += m, src += m) {
80102170:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102173:	01 45 f4             	add    %eax,-0xc(%ebp)
80102176:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102179:	01 45 10             	add    %eax,0x10(%ebp)
8010217c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010217f:	01 45 0c             	add    %eax,0xc(%ebp)
80102182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102185:	3b 45 14             	cmp    0x14(%ebp),%eax
80102188:	0f 82 5b ff ff ff    	jb     801020e9 <writei+0xb6>
		memmove(bp->data + off % BSIZE, src, m);
		log_write(bp);
		brelse(bp);
	}

	if (n > 0 && off > ip->size) {
8010218e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102192:	74 22                	je     801021b6 <writei+0x183>
80102194:	8b 45 08             	mov    0x8(%ebp),%eax
80102197:	8b 40 18             	mov    0x18(%eax),%eax
8010219a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010219d:	73 17                	jae    801021b6 <writei+0x183>
		ip->size = off;
8010219f:	8b 45 08             	mov    0x8(%ebp),%eax
801021a2:	8b 55 10             	mov    0x10(%ebp),%edx
801021a5:	89 50 18             	mov    %edx,0x18(%eax)
		iupdate(ip);
801021a8:	83 ec 0c             	sub    $0xc,%esp
801021ab:	ff 75 08             	pushl  0x8(%ebp)
801021ae:	e8 e1 f5 ff ff       	call   80101794 <iupdate>
801021b3:	83 c4 10             	add    $0x10,%esp
	}
	return n;
801021b6:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021b9:	c9                   	leave  
801021ba:	c3                   	ret    

801021bb <namecmp>:

//PAGEBREAK!
// Directories

int namecmp(const char *s, const char *t)
{
801021bb:	55                   	push   %ebp
801021bc:	89 e5                	mov    %esp,%ebp
801021be:	83 ec 08             	sub    $0x8,%esp
	return strncmp(s, t, DIRSIZ);
801021c1:	83 ec 04             	sub    $0x4,%esp
801021c4:	6a 0e                	push   $0xe
801021c6:	ff 75 0c             	pushl  0xc(%ebp)
801021c9:	ff 75 08             	pushl  0x8(%ebp)
801021cc:	e8 74 4c 00 00       	call   80106e45 <strncmp>
801021d1:	83 c4 10             	add    $0x10,%esp
}
801021d4:	c9                   	leave  
801021d5:	c3                   	ret    

801021d6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *dirlookup(struct inode *dp, char *name, uint * poff)
{
801021d6:	55                   	push   %ebp
801021d7:	89 e5                	mov    %esp,%ebp
801021d9:	83 ec 28             	sub    $0x28,%esp
	uint off, inum;
	struct dirent de;

	if (dp->type != T_DIR)
801021dc:	8b 45 08             	mov    0x8(%ebp),%eax
801021df:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021e3:	66 83 f8 01          	cmp    $0x1,%ax
801021e7:	74 0d                	je     801021f6 <dirlookup+0x20>
		panic("dirlookup not DIR");
801021e9:	83 ec 0c             	sub    $0xc,%esp
801021ec:	68 a7 a4 10 80       	push   $0x8010a4a7
801021f1:	e8 70 e3 ff ff       	call   80100566 <panic>

	for (off = 0; off < dp->size; off += sizeof(de)) {
801021f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021fd:	eb 7b                	jmp    8010227a <dirlookup+0xa4>
		if (readi(dp, (char *)&de, off, sizeof(de)) != sizeof(de))
801021ff:	6a 10                	push   $0x10
80102201:	ff 75 f4             	pushl  -0xc(%ebp)
80102204:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102207:	50                   	push   %eax
80102208:	ff 75 08             	pushl  0x8(%ebp)
8010220b:	e8 cc fc ff ff       	call   80101edc <readi>
80102210:	83 c4 10             	add    $0x10,%esp
80102213:	83 f8 10             	cmp    $0x10,%eax
80102216:	74 0d                	je     80102225 <dirlookup+0x4f>
			panic("dirlink read");
80102218:	83 ec 0c             	sub    $0xc,%esp
8010221b:	68 b9 a4 10 80       	push   $0x8010a4b9
80102220:	e8 41 e3 ff ff       	call   80100566 <panic>
		if (de.inum == 0)
80102225:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102229:	66 85 c0             	test   %ax,%ax
8010222c:	74 47                	je     80102275 <dirlookup+0x9f>
			continue;
		if (namecmp(name, de.name) == 0) {
8010222e:	83 ec 08             	sub    $0x8,%esp
80102231:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102234:	83 c0 02             	add    $0x2,%eax
80102237:	50                   	push   %eax
80102238:	ff 75 0c             	pushl  0xc(%ebp)
8010223b:	e8 7b ff ff ff       	call   801021bb <namecmp>
80102240:	83 c4 10             	add    $0x10,%esp
80102243:	85 c0                	test   %eax,%eax
80102245:	75 2f                	jne    80102276 <dirlookup+0xa0>
			// entry matches path element
			if (poff)
80102247:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010224b:	74 08                	je     80102255 <dirlookup+0x7f>
				*poff = off;
8010224d:	8b 45 10             	mov    0x10(%ebp),%eax
80102250:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102253:	89 10                	mov    %edx,(%eax)
			inum = de.inum;
80102255:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102259:	0f b7 c0             	movzwl %ax,%eax
8010225c:	89 45 f0             	mov    %eax,-0x10(%ebp)
			return iget(dp->dev, inum);
8010225f:	8b 45 08             	mov    0x8(%ebp),%eax
80102262:	8b 00                	mov    (%eax),%eax
80102264:	83 ec 08             	sub    $0x8,%esp
80102267:	ff 75 f0             	pushl  -0x10(%ebp)
8010226a:	50                   	push   %eax
8010226b:	e8 e5 f5 ff ff       	call   80101855 <iget>
80102270:	83 c4 10             	add    $0x10,%esp
80102273:	eb 19                	jmp    8010228e <dirlookup+0xb8>

	for (off = 0; off < dp->size; off += sizeof(de)) {
		if (readi(dp, (char *)&de, off, sizeof(de)) != sizeof(de))
			panic("dirlink read");
		if (de.inum == 0)
			continue;
80102275:	90                   	nop
	struct dirent de;

	if (dp->type != T_DIR)
		panic("dirlookup not DIR");

	for (off = 0; off < dp->size; off += sizeof(de)) {
80102276:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010227a:	8b 45 08             	mov    0x8(%ebp),%eax
8010227d:	8b 40 18             	mov    0x18(%eax),%eax
80102280:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102283:	0f 87 76 ff ff ff    	ja     801021ff <dirlookup+0x29>
			inum = de.inum;
			return iget(dp->dev, inum);
		}
	}

	return 0;
80102289:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010228e:	c9                   	leave  
8010228f:	c3                   	ret    

80102290 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int dirlink(struct inode *dp, char *name, uint inum)
{
80102290:	55                   	push   %ebp
80102291:	89 e5                	mov    %esp,%ebp
80102293:	83 ec 28             	sub    $0x28,%esp
	int off;
	struct dirent de;
	struct inode *ip;

	// Check that name is not present.
	if ((ip = dirlookup(dp, name, 0)) != 0) {
80102296:	83 ec 04             	sub    $0x4,%esp
80102299:	6a 00                	push   $0x0
8010229b:	ff 75 0c             	pushl  0xc(%ebp)
8010229e:	ff 75 08             	pushl  0x8(%ebp)
801022a1:	e8 30 ff ff ff       	call   801021d6 <dirlookup>
801022a6:	83 c4 10             	add    $0x10,%esp
801022a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022b0:	74 18                	je     801022ca <dirlink+0x3a>
		iput(ip);
801022b2:	83 ec 0c             	sub    $0xc,%esp
801022b5:	ff 75 f0             	pushl  -0x10(%ebp)
801022b8:	e8 81 f8 ff ff       	call   80101b3e <iput>
801022bd:	83 c4 10             	add    $0x10,%esp
		return -1;
801022c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c5:	e9 9c 00 00 00       	jmp    80102366 <dirlink+0xd6>
	}
	// Look for an empty dirent.
	for (off = 0; off < dp->size; off += sizeof(de)) {
801022ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022d1:	eb 39                	jmp    8010230c <dirlink+0x7c>
		if (readi(dp, (char *)&de, off, sizeof(de)) != sizeof(de))
801022d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d6:	6a 10                	push   $0x10
801022d8:	50                   	push   %eax
801022d9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022dc:	50                   	push   %eax
801022dd:	ff 75 08             	pushl  0x8(%ebp)
801022e0:	e8 f7 fb ff ff       	call   80101edc <readi>
801022e5:	83 c4 10             	add    $0x10,%esp
801022e8:	83 f8 10             	cmp    $0x10,%eax
801022eb:	74 0d                	je     801022fa <dirlink+0x6a>
			panic("dirlink read");
801022ed:	83 ec 0c             	sub    $0xc,%esp
801022f0:	68 b9 a4 10 80       	push   $0x8010a4b9
801022f5:	e8 6c e2 ff ff       	call   80100566 <panic>
		if (de.inum == 0)
801022fa:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022fe:	66 85 c0             	test   %ax,%ax
80102301:	74 18                	je     8010231b <dirlink+0x8b>
	if ((ip = dirlookup(dp, name, 0)) != 0) {
		iput(ip);
		return -1;
	}
	// Look for an empty dirent.
	for (off = 0; off < dp->size; off += sizeof(de)) {
80102303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102306:	83 c0 10             	add    $0x10,%eax
80102309:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010230c:	8b 45 08             	mov    0x8(%ebp),%eax
8010230f:	8b 50 18             	mov    0x18(%eax),%edx
80102312:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102315:	39 c2                	cmp    %eax,%edx
80102317:	77 ba                	ja     801022d3 <dirlink+0x43>
80102319:	eb 01                	jmp    8010231c <dirlink+0x8c>
		if (readi(dp, (char *)&de, off, sizeof(de)) != sizeof(de))
			panic("dirlink read");
		if (de.inum == 0)
			break;
8010231b:	90                   	nop
	}

	strncpy(de.name, name, DIRSIZ);
8010231c:	83 ec 04             	sub    $0x4,%esp
8010231f:	6a 0e                	push   $0xe
80102321:	ff 75 0c             	pushl  0xc(%ebp)
80102324:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102327:	83 c0 02             	add    $0x2,%eax
8010232a:	50                   	push   %eax
8010232b:	e8 6b 4b 00 00       	call   80106e9b <strncpy>
80102330:	83 c4 10             	add    $0x10,%esp
	de.inum = inum;
80102333:	8b 45 10             	mov    0x10(%ebp),%eax
80102336:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
	if (writei(dp, (char *)&de, off, sizeof(de)) != sizeof(de))
8010233a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233d:	6a 10                	push   $0x10
8010233f:	50                   	push   %eax
80102340:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102343:	50                   	push   %eax
80102344:	ff 75 08             	pushl  0x8(%ebp)
80102347:	e8 e7 fc ff ff       	call   80102033 <writei>
8010234c:	83 c4 10             	add    $0x10,%esp
8010234f:	83 f8 10             	cmp    $0x10,%eax
80102352:	74 0d                	je     80102361 <dirlink+0xd1>
		panic("dirlink");
80102354:	83 ec 0c             	sub    $0xc,%esp
80102357:	68 c6 a4 10 80       	push   $0x8010a4c6
8010235c:	e8 05 e2 ff ff       	call   80100566 <panic>

	return 0;
80102361:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102366:	c9                   	leave  
80102367:	c3                   	ret    

80102368 <skipelem>:
//   skipelem("///a//bb", name) = "bb", setting name = "a"
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char *skipelem(char *path, char *name)
{
80102368:	55                   	push   %ebp
80102369:	89 e5                	mov    %esp,%ebp
8010236b:	83 ec 18             	sub    $0x18,%esp
	char *s;
	int len;

	while (*path == '/')
8010236e:	eb 04                	jmp    80102374 <skipelem+0xc>
		path++;
80102370:	83 45 08 01          	addl   $0x1,0x8(%ebp)
static char *skipelem(char *path, char *name)
{
	char *s;
	int len;

	while (*path == '/')
80102374:	8b 45 08             	mov    0x8(%ebp),%eax
80102377:	0f b6 00             	movzbl (%eax),%eax
8010237a:	3c 2f                	cmp    $0x2f,%al
8010237c:	74 f2                	je     80102370 <skipelem+0x8>
		path++;
	if (*path == 0)
8010237e:	8b 45 08             	mov    0x8(%ebp),%eax
80102381:	0f b6 00             	movzbl (%eax),%eax
80102384:	84 c0                	test   %al,%al
80102386:	75 07                	jne    8010238f <skipelem+0x27>
		return 0;
80102388:	b8 00 00 00 00       	mov    $0x0,%eax
8010238d:	eb 7b                	jmp    8010240a <skipelem+0xa2>
	s = path;
8010238f:	8b 45 08             	mov    0x8(%ebp),%eax
80102392:	89 45 f4             	mov    %eax,-0xc(%ebp)
	while (*path != '/' && *path != 0)
80102395:	eb 04                	jmp    8010239b <skipelem+0x33>
		path++;
80102397:	83 45 08 01          	addl   $0x1,0x8(%ebp)
	while (*path == '/')
		path++;
	if (*path == 0)
		return 0;
	s = path;
	while (*path != '/' && *path != 0)
8010239b:	8b 45 08             	mov    0x8(%ebp),%eax
8010239e:	0f b6 00             	movzbl (%eax),%eax
801023a1:	3c 2f                	cmp    $0x2f,%al
801023a3:	74 0a                	je     801023af <skipelem+0x47>
801023a5:	8b 45 08             	mov    0x8(%ebp),%eax
801023a8:	0f b6 00             	movzbl (%eax),%eax
801023ab:	84 c0                	test   %al,%al
801023ad:	75 e8                	jne    80102397 <skipelem+0x2f>
		path++;
	len = path - s;
801023af:	8b 55 08             	mov    0x8(%ebp),%edx
801023b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b5:	29 c2                	sub    %eax,%edx
801023b7:	89 d0                	mov    %edx,%eax
801023b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (len >= DIRSIZ)
801023bc:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023c0:	7e 15                	jle    801023d7 <skipelem+0x6f>
		memmove(name, s, DIRSIZ);
801023c2:	83 ec 04             	sub    $0x4,%esp
801023c5:	6a 0e                	push   $0xe
801023c7:	ff 75 f4             	pushl  -0xc(%ebp)
801023ca:	ff 75 0c             	pushl  0xc(%ebp)
801023cd:	e8 dd 49 00 00       	call   80106daf <memmove>
801023d2:	83 c4 10             	add    $0x10,%esp
801023d5:	eb 26                	jmp    801023fd <skipelem+0x95>
	else {
		memmove(name, s, len);
801023d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023da:	83 ec 04             	sub    $0x4,%esp
801023dd:	50                   	push   %eax
801023de:	ff 75 f4             	pushl  -0xc(%ebp)
801023e1:	ff 75 0c             	pushl  0xc(%ebp)
801023e4:	e8 c6 49 00 00       	call   80106daf <memmove>
801023e9:	83 c4 10             	add    $0x10,%esp
		name[len] = 0;
801023ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801023f2:	01 d0                	add    %edx,%eax
801023f4:	c6 00 00             	movb   $0x0,(%eax)
	}
	while (*path == '/')
801023f7:	eb 04                	jmp    801023fd <skipelem+0x95>
		path++;
801023f9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
		memmove(name, s, DIRSIZ);
	else {
		memmove(name, s, len);
		name[len] = 0;
	}
	while (*path == '/')
801023fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102400:	0f b6 00             	movzbl (%eax),%eax
80102403:	3c 2f                	cmp    $0x2f,%al
80102405:	74 f2                	je     801023f9 <skipelem+0x91>
		path++;
	return path;
80102407:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010240a:	c9                   	leave  
8010240b:	c3                   	ret    

8010240c <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *namex(char *path, int nameiparent, char *name)
{
8010240c:	55                   	push   %ebp
8010240d:	89 e5                	mov    %esp,%ebp
8010240f:	83 ec 18             	sub    $0x18,%esp
	struct inode *ip, *next;

	if (*path == '/')
80102412:	8b 45 08             	mov    0x8(%ebp),%eax
80102415:	0f b6 00             	movzbl (%eax),%eax
80102418:	3c 2f                	cmp    $0x2f,%al
8010241a:	75 17                	jne    80102433 <namex+0x27>
		ip = iget(ROOTDEV, ROOTINO);
8010241c:	83 ec 08             	sub    $0x8,%esp
8010241f:	6a 01                	push   $0x1
80102421:	6a 01                	push   $0x1
80102423:	e8 2d f4 ff ff       	call   80101855 <iget>
80102428:	83 c4 10             	add    $0x10,%esp
8010242b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010242e:	e9 bb 00 00 00       	jmp    801024ee <namex+0xe2>
	else
		ip = idup(proc->cwd);
80102433:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102439:	8b 40 68             	mov    0x68(%eax),%eax
8010243c:	83 ec 0c             	sub    $0xc,%esp
8010243f:	50                   	push   %eax
80102440:	e8 ef f4 ff ff       	call   80101934 <idup>
80102445:	83 c4 10             	add    $0x10,%esp
80102448:	89 45 f4             	mov    %eax,-0xc(%ebp)

	while ((path = skipelem(path, name)) != 0) {
8010244b:	e9 9e 00 00 00       	jmp    801024ee <namex+0xe2>
		ilock(ip);
80102450:	83 ec 0c             	sub    $0xc,%esp
80102453:	ff 75 f4             	pushl  -0xc(%ebp)
80102456:	e8 13 f5 ff ff       	call   8010196e <ilock>
8010245b:	83 c4 10             	add    $0x10,%esp
		if (ip->type != T_DIR) {
8010245e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102461:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102465:	66 83 f8 01          	cmp    $0x1,%ax
80102469:	74 18                	je     80102483 <namex+0x77>
			iunlockput(ip);
8010246b:	83 ec 0c             	sub    $0xc,%esp
8010246e:	ff 75 f4             	pushl  -0xc(%ebp)
80102471:	e8 b8 f7 ff ff       	call   80101c2e <iunlockput>
80102476:	83 c4 10             	add    $0x10,%esp
			return 0;
80102479:	b8 00 00 00 00       	mov    $0x0,%eax
8010247e:	e9 a7 00 00 00       	jmp    8010252a <namex+0x11e>
		}
		if (nameiparent && *path == '\0') {
80102483:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102487:	74 20                	je     801024a9 <namex+0x9d>
80102489:	8b 45 08             	mov    0x8(%ebp),%eax
8010248c:	0f b6 00             	movzbl (%eax),%eax
8010248f:	84 c0                	test   %al,%al
80102491:	75 16                	jne    801024a9 <namex+0x9d>
			// Stop one level early.
			iunlock(ip);
80102493:	83 ec 0c             	sub    $0xc,%esp
80102496:	ff 75 f4             	pushl  -0xc(%ebp)
80102499:	e8 2e f6 ff ff       	call   80101acc <iunlock>
8010249e:	83 c4 10             	add    $0x10,%esp
			return ip;
801024a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024a4:	e9 81 00 00 00       	jmp    8010252a <namex+0x11e>
		}
		if ((next = dirlookup(ip, name, 0)) == 0) {
801024a9:	83 ec 04             	sub    $0x4,%esp
801024ac:	6a 00                	push   $0x0
801024ae:	ff 75 10             	pushl  0x10(%ebp)
801024b1:	ff 75 f4             	pushl  -0xc(%ebp)
801024b4:	e8 1d fd ff ff       	call   801021d6 <dirlookup>
801024b9:	83 c4 10             	add    $0x10,%esp
801024bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024c3:	75 15                	jne    801024da <namex+0xce>
			iunlockput(ip);
801024c5:	83 ec 0c             	sub    $0xc,%esp
801024c8:	ff 75 f4             	pushl  -0xc(%ebp)
801024cb:	e8 5e f7 ff ff       	call   80101c2e <iunlockput>
801024d0:	83 c4 10             	add    $0x10,%esp
			return 0;
801024d3:	b8 00 00 00 00       	mov    $0x0,%eax
801024d8:	eb 50                	jmp    8010252a <namex+0x11e>
		}
		iunlockput(ip);
801024da:	83 ec 0c             	sub    $0xc,%esp
801024dd:	ff 75 f4             	pushl  -0xc(%ebp)
801024e0:	e8 49 f7 ff ff       	call   80101c2e <iunlockput>
801024e5:	83 c4 10             	add    $0x10,%esp
		ip = next;
801024e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (*path == '/')
		ip = iget(ROOTDEV, ROOTINO);
	else
		ip = idup(proc->cwd);

	while ((path = skipelem(path, name)) != 0) {
801024ee:	83 ec 08             	sub    $0x8,%esp
801024f1:	ff 75 10             	pushl  0x10(%ebp)
801024f4:	ff 75 08             	pushl  0x8(%ebp)
801024f7:	e8 6c fe ff ff       	call   80102368 <skipelem>
801024fc:	83 c4 10             	add    $0x10,%esp
801024ff:	89 45 08             	mov    %eax,0x8(%ebp)
80102502:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102506:	0f 85 44 ff ff ff    	jne    80102450 <namex+0x44>
			return 0;
		}
		iunlockput(ip);
		ip = next;
	}
	if (nameiparent) {
8010250c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102510:	74 15                	je     80102527 <namex+0x11b>
		iput(ip);
80102512:	83 ec 0c             	sub    $0xc,%esp
80102515:	ff 75 f4             	pushl  -0xc(%ebp)
80102518:	e8 21 f6 ff ff       	call   80101b3e <iput>
8010251d:	83 c4 10             	add    $0x10,%esp
		return 0;
80102520:	b8 00 00 00 00       	mov    $0x0,%eax
80102525:	eb 03                	jmp    8010252a <namex+0x11e>
	}
	return ip;
80102527:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010252a:	c9                   	leave  
8010252b:	c3                   	ret    

8010252c <namei>:

struct inode *namei(char *path)
{
8010252c:	55                   	push   %ebp
8010252d:	89 e5                	mov    %esp,%ebp
8010252f:	83 ec 18             	sub    $0x18,%esp
	char name[DIRSIZ];
	return namex(path, 0, name);
80102532:	83 ec 04             	sub    $0x4,%esp
80102535:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102538:	50                   	push   %eax
80102539:	6a 00                	push   $0x0
8010253b:	ff 75 08             	pushl  0x8(%ebp)
8010253e:	e8 c9 fe ff ff       	call   8010240c <namex>
80102543:	83 c4 10             	add    $0x10,%esp
}
80102546:	c9                   	leave  
80102547:	c3                   	ret    

80102548 <nameiparent>:

struct inode *nameiparent(char *path, char *name)
{
80102548:	55                   	push   %ebp
80102549:	89 e5                	mov    %esp,%ebp
8010254b:	83 ec 08             	sub    $0x8,%esp
	return namex(path, 1, name);
8010254e:	83 ec 04             	sub    $0x4,%esp
80102551:	ff 75 0c             	pushl  0xc(%ebp)
80102554:	6a 01                	push   $0x1
80102556:	ff 75 08             	pushl  0x8(%ebp)
80102559:	e8 ae fe ff ff       	call   8010240c <namex>
8010255e:	83 c4 10             	add    $0x10,%esp
}
80102561:	c9                   	leave  
80102562:	c3                   	ret    

80102563 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102563:	55                   	push   %ebp
80102564:	89 e5                	mov    %esp,%ebp
80102566:	83 ec 14             	sub    $0x14,%esp
80102569:	8b 45 08             	mov    0x8(%ebp),%eax
8010256c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102570:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102574:	89 c2                	mov    %eax,%edx
80102576:	ec                   	in     (%dx),%al
80102577:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010257a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010257e:	c9                   	leave  
8010257f:	c3                   	ret    

80102580 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102580:	55                   	push   %ebp
80102581:	89 e5                	mov    %esp,%ebp
80102583:	57                   	push   %edi
80102584:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102585:	8b 55 08             	mov    0x8(%ebp),%edx
80102588:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010258b:	8b 45 10             	mov    0x10(%ebp),%eax
8010258e:	89 cb                	mov    %ecx,%ebx
80102590:	89 df                	mov    %ebx,%edi
80102592:	89 c1                	mov    %eax,%ecx
80102594:	fc                   	cld    
80102595:	f3 6d                	rep insl (%dx),%es:(%edi)
80102597:	89 c8                	mov    %ecx,%eax
80102599:	89 fb                	mov    %edi,%ebx
8010259b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010259e:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801025a1:	90                   	nop
801025a2:	5b                   	pop    %ebx
801025a3:	5f                   	pop    %edi
801025a4:	5d                   	pop    %ebp
801025a5:	c3                   	ret    

801025a6 <outb>:

static inline void
outb(ushort port, uchar data)
{
801025a6:	55                   	push   %ebp
801025a7:	89 e5                	mov    %esp,%ebp
801025a9:	83 ec 08             	sub    $0x8,%esp
801025ac:	8b 55 08             	mov    0x8(%ebp),%edx
801025af:	8b 45 0c             	mov    0xc(%ebp),%eax
801025b2:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801025b6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025b9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025bd:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025c1:	ee                   	out    %al,(%dx)
}
801025c2:	90                   	nop
801025c3:	c9                   	leave  
801025c4:	c3                   	ret    

801025c5 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801025c5:	55                   	push   %ebp
801025c6:	89 e5                	mov    %esp,%ebp
801025c8:	56                   	push   %esi
801025c9:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025ca:	8b 55 08             	mov    0x8(%ebp),%edx
801025cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025d0:	8b 45 10             	mov    0x10(%ebp),%eax
801025d3:	89 cb                	mov    %ecx,%ebx
801025d5:	89 de                	mov    %ebx,%esi
801025d7:	89 c1                	mov    %eax,%ecx
801025d9:	fc                   	cld    
801025da:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025dc:	89 c8                	mov    %ecx,%eax
801025de:	89 f3                	mov    %esi,%ebx
801025e0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025e3:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801025e6:	90                   	nop
801025e7:	5b                   	pop    %ebx
801025e8:	5e                   	pop    %esi
801025e9:	5d                   	pop    %ebp
801025ea:	c3                   	ret    

801025eb <idewait>:
static int havedisk1;
static void idestart(struct buf *);

// Wait for IDE disk to become ready.
static int idewait(int checkerr)
{
801025eb:	55                   	push   %ebp
801025ec:	89 e5                	mov    %esp,%ebp
801025ee:	83 ec 10             	sub    $0x10,%esp
	int r;

	while (((r = inb(0x1f7)) & (IDE_BSY | IDE_DRDY)) != IDE_DRDY) ;
801025f1:	90                   	nop
801025f2:	68 f7 01 00 00       	push   $0x1f7
801025f7:	e8 67 ff ff ff       	call   80102563 <inb>
801025fc:	83 c4 04             	add    $0x4,%esp
801025ff:	0f b6 c0             	movzbl %al,%eax
80102602:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102605:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102608:	25 c0 00 00 00       	and    $0xc0,%eax
8010260d:	83 f8 40             	cmp    $0x40,%eax
80102610:	75 e0                	jne    801025f2 <idewait+0x7>
	if (checkerr && (r & (IDE_DF | IDE_ERR)) != 0)
80102612:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102616:	74 11                	je     80102629 <idewait+0x3e>
80102618:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010261b:	83 e0 21             	and    $0x21,%eax
8010261e:	85 c0                	test   %eax,%eax
80102620:	74 07                	je     80102629 <idewait+0x3e>
		return -1;
80102622:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102627:	eb 05                	jmp    8010262e <idewait+0x43>
	return 0;
80102629:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010262e:	c9                   	leave  
8010262f:	c3                   	ret    

80102630 <ideinit>:

void ideinit(void)
{
80102630:	55                   	push   %ebp
80102631:	89 e5                	mov    %esp,%ebp
80102633:	83 ec 18             	sub    $0x18,%esp
	int i;

	initlock(&idelock, "ide");
80102636:	83 ec 08             	sub    $0x8,%esp
80102639:	68 ce a4 10 80       	push   $0x8010a4ce
8010263e:	68 20 e6 10 80       	push   $0x8010e620
80102643:	e8 23 44 00 00       	call   80106a6b <initlock>
80102648:	83 c4 10             	add    $0x10,%esp
	picenable(IRQ_IDE);
8010264b:	83 ec 0c             	sub    $0xc,%esp
8010264e:	6a 0e                	push   $0xe
80102650:	e8 e9 2a 00 00       	call   8010513e <picenable>
80102655:	83 c4 10             	add    $0x10,%esp
	ioapicenable(IRQ_IDE, ncpu - 1);
80102658:	a1 00 5d 11 80       	mov    0x80115d00,%eax
8010265d:	83 e8 01             	sub    $0x1,%eax
80102660:	83 ec 08             	sub    $0x8,%esp
80102663:	50                   	push   %eax
80102664:	6a 0e                	push   $0xe
80102666:	e8 73 04 00 00       	call   80102ade <ioapicenable>
8010266b:	83 c4 10             	add    $0x10,%esp
	idewait(0);
8010266e:	83 ec 0c             	sub    $0xc,%esp
80102671:	6a 00                	push   $0x0
80102673:	e8 73 ff ff ff       	call   801025eb <idewait>
80102678:	83 c4 10             	add    $0x10,%esp

	// Check if disk 1 is present
	outb(0x1f6, 0xe0 | (1 << 4));
8010267b:	83 ec 08             	sub    $0x8,%esp
8010267e:	68 f0 00 00 00       	push   $0xf0
80102683:	68 f6 01 00 00       	push   $0x1f6
80102688:	e8 19 ff ff ff       	call   801025a6 <outb>
8010268d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 1000; i++) {
80102690:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102697:	eb 24                	jmp    801026bd <ideinit+0x8d>
		if (inb(0x1f7) != 0) {
80102699:	83 ec 0c             	sub    $0xc,%esp
8010269c:	68 f7 01 00 00       	push   $0x1f7
801026a1:	e8 bd fe ff ff       	call   80102563 <inb>
801026a6:	83 c4 10             	add    $0x10,%esp
801026a9:	84 c0                	test   %al,%al
801026ab:	74 0c                	je     801026b9 <ideinit+0x89>
			havedisk1 = 1;
801026ad:	c7 05 58 e6 10 80 01 	movl   $0x1,0x8010e658
801026b4:	00 00 00 
			break;
801026b7:	eb 0d                	jmp    801026c6 <ideinit+0x96>
	ioapicenable(IRQ_IDE, ncpu - 1);
	idewait(0);

	// Check if disk 1 is present
	outb(0x1f6, 0xe0 | (1 << 4));
	for (i = 0; i < 1000; i++) {
801026b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026bd:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026c4:	7e d3                	jle    80102699 <ideinit+0x69>
			break;
		}
	}

	// Switch back to disk 0.
	outb(0x1f6, 0xe0 | (0 << 4));
801026c6:	83 ec 08             	sub    $0x8,%esp
801026c9:	68 e0 00 00 00       	push   $0xe0
801026ce:	68 f6 01 00 00       	push   $0x1f6
801026d3:	e8 ce fe ff ff       	call   801025a6 <outb>
801026d8:	83 c4 10             	add    $0x10,%esp
}
801026db:	90                   	nop
801026dc:	c9                   	leave  
801026dd:	c3                   	ret    

801026de <idestart>:

// Start the request for b.  Caller must hold idelock.
static void idestart(struct buf *b)
{
801026de:	55                   	push   %ebp
801026df:	89 e5                	mov    %esp,%ebp
801026e1:	83 ec 18             	sub    $0x18,%esp
	if (b == 0)
801026e4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026e8:	75 0d                	jne    801026f7 <idestart+0x19>
		panic("idestart");
801026ea:	83 ec 0c             	sub    $0xc,%esp
801026ed:	68 d2 a4 10 80       	push   $0x8010a4d2
801026f2:	e8 6f de ff ff       	call   80100566 <panic>
	if (b->blockno >= FSSIZE)
801026f7:	8b 45 08             	mov    0x8(%ebp),%eax
801026fa:	8b 40 08             	mov    0x8(%eax),%eax
801026fd:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102702:	76 0d                	jbe    80102711 <idestart+0x33>
		panic("incorrect blockno");
80102704:	83 ec 0c             	sub    $0xc,%esp
80102707:	68 db a4 10 80       	push   $0x8010a4db
8010270c:	e8 55 de ff ff       	call   80100566 <panic>
	int sector_per_block = BSIZE / SECTOR_SIZE;
80102711:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	int sector = b->blockno * sector_per_block;
80102718:	8b 45 08             	mov    0x8(%ebp),%eax
8010271b:	8b 50 08             	mov    0x8(%eax),%edx
8010271e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102721:	0f af c2             	imul   %edx,%eax
80102724:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (sector_per_block > 7)
80102727:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010272b:	7e 0d                	jle    8010273a <idestart+0x5c>
		panic("idestart");
8010272d:	83 ec 0c             	sub    $0xc,%esp
80102730:	68 d2 a4 10 80       	push   $0x8010a4d2
80102735:	e8 2c de ff ff       	call   80100566 <panic>

	idewait(0);
8010273a:	83 ec 0c             	sub    $0xc,%esp
8010273d:	6a 00                	push   $0x0
8010273f:	e8 a7 fe ff ff       	call   801025eb <idewait>
80102744:	83 c4 10             	add    $0x10,%esp
	outb(0x3f6, 0);		// generate interrupt
80102747:	83 ec 08             	sub    $0x8,%esp
8010274a:	6a 00                	push   $0x0
8010274c:	68 f6 03 00 00       	push   $0x3f6
80102751:	e8 50 fe ff ff       	call   801025a6 <outb>
80102756:	83 c4 10             	add    $0x10,%esp
	outb(0x1f2, sector_per_block);	// number of sectors
80102759:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010275c:	0f b6 c0             	movzbl %al,%eax
8010275f:	83 ec 08             	sub    $0x8,%esp
80102762:	50                   	push   %eax
80102763:	68 f2 01 00 00       	push   $0x1f2
80102768:	e8 39 fe ff ff       	call   801025a6 <outb>
8010276d:	83 c4 10             	add    $0x10,%esp
	outb(0x1f3, sector & 0xff);
80102770:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102773:	0f b6 c0             	movzbl %al,%eax
80102776:	83 ec 08             	sub    $0x8,%esp
80102779:	50                   	push   %eax
8010277a:	68 f3 01 00 00       	push   $0x1f3
8010277f:	e8 22 fe ff ff       	call   801025a6 <outb>
80102784:	83 c4 10             	add    $0x10,%esp
	outb(0x1f4, (sector >> 8) & 0xff);
80102787:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010278a:	c1 f8 08             	sar    $0x8,%eax
8010278d:	0f b6 c0             	movzbl %al,%eax
80102790:	83 ec 08             	sub    $0x8,%esp
80102793:	50                   	push   %eax
80102794:	68 f4 01 00 00       	push   $0x1f4
80102799:	e8 08 fe ff ff       	call   801025a6 <outb>
8010279e:	83 c4 10             	add    $0x10,%esp
	outb(0x1f5, (sector >> 16) & 0xff);
801027a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027a4:	c1 f8 10             	sar    $0x10,%eax
801027a7:	0f b6 c0             	movzbl %al,%eax
801027aa:	83 ec 08             	sub    $0x8,%esp
801027ad:	50                   	push   %eax
801027ae:	68 f5 01 00 00       	push   $0x1f5
801027b3:	e8 ee fd ff ff       	call   801025a6 <outb>
801027b8:	83 c4 10             	add    $0x10,%esp
	outb(0x1f6, 0xe0 | ((b->dev & 1) << 4) | ((sector >> 24) & 0x0f));
801027bb:	8b 45 08             	mov    0x8(%ebp),%eax
801027be:	8b 40 04             	mov    0x4(%eax),%eax
801027c1:	83 e0 01             	and    $0x1,%eax
801027c4:	c1 e0 04             	shl    $0x4,%eax
801027c7:	89 c2                	mov    %eax,%edx
801027c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027cc:	c1 f8 18             	sar    $0x18,%eax
801027cf:	83 e0 0f             	and    $0xf,%eax
801027d2:	09 d0                	or     %edx,%eax
801027d4:	83 c8 e0             	or     $0xffffffe0,%eax
801027d7:	0f b6 c0             	movzbl %al,%eax
801027da:	83 ec 08             	sub    $0x8,%esp
801027dd:	50                   	push   %eax
801027de:	68 f6 01 00 00       	push   $0x1f6
801027e3:	e8 be fd ff ff       	call   801025a6 <outb>
801027e8:	83 c4 10             	add    $0x10,%esp
	if (b->flags & B_DIRTY) {
801027eb:	8b 45 08             	mov    0x8(%ebp),%eax
801027ee:	8b 00                	mov    (%eax),%eax
801027f0:	83 e0 04             	and    $0x4,%eax
801027f3:	85 c0                	test   %eax,%eax
801027f5:	74 30                	je     80102827 <idestart+0x149>
		outb(0x1f7, IDE_CMD_WRITE);
801027f7:	83 ec 08             	sub    $0x8,%esp
801027fa:	6a 30                	push   $0x30
801027fc:	68 f7 01 00 00       	push   $0x1f7
80102801:	e8 a0 fd ff ff       	call   801025a6 <outb>
80102806:	83 c4 10             	add    $0x10,%esp
		outsl(0x1f0, b->data, BSIZE / 4);
80102809:	8b 45 08             	mov    0x8(%ebp),%eax
8010280c:	83 c0 18             	add    $0x18,%eax
8010280f:	83 ec 04             	sub    $0x4,%esp
80102812:	68 80 00 00 00       	push   $0x80
80102817:	50                   	push   %eax
80102818:	68 f0 01 00 00       	push   $0x1f0
8010281d:	e8 a3 fd ff ff       	call   801025c5 <outsl>
80102822:	83 c4 10             	add    $0x10,%esp
	} else {
		outb(0x1f7, IDE_CMD_READ);
	}
}
80102825:	eb 12                	jmp    80102839 <idestart+0x15b>
	outb(0x1f6, 0xe0 | ((b->dev & 1) << 4) | ((sector >> 24) & 0x0f));
	if (b->flags & B_DIRTY) {
		outb(0x1f7, IDE_CMD_WRITE);
		outsl(0x1f0, b->data, BSIZE / 4);
	} else {
		outb(0x1f7, IDE_CMD_READ);
80102827:	83 ec 08             	sub    $0x8,%esp
8010282a:	6a 20                	push   $0x20
8010282c:	68 f7 01 00 00       	push   $0x1f7
80102831:	e8 70 fd ff ff       	call   801025a6 <outb>
80102836:	83 c4 10             	add    $0x10,%esp
	}
}
80102839:	90                   	nop
8010283a:	c9                   	leave  
8010283b:	c3                   	ret    

8010283c <ideintr>:

// Interrupt handler.
void ideintr(void)
{
8010283c:	55                   	push   %ebp
8010283d:	89 e5                	mov    %esp,%ebp
8010283f:	83 ec 18             	sub    $0x18,%esp
	struct buf *b;

	// First queued buffer is the active request.
	acquire(&idelock);
80102842:	83 ec 0c             	sub    $0xc,%esp
80102845:	68 20 e6 10 80       	push   $0x8010e620
8010284a:	e8 3e 42 00 00       	call   80106a8d <acquire>
8010284f:	83 c4 10             	add    $0x10,%esp
	if ((b = idequeue) == 0) {
80102852:	a1 54 e6 10 80       	mov    0x8010e654,%eax
80102857:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010285a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010285e:	75 15                	jne    80102875 <ideintr+0x39>
		release(&idelock);
80102860:	83 ec 0c             	sub    $0xc,%esp
80102863:	68 20 e6 10 80       	push   $0x8010e620
80102868:	e8 87 42 00 00       	call   80106af4 <release>
8010286d:	83 c4 10             	add    $0x10,%esp
		// cprintf("spurious IDE interrupt\n");
		return;
80102870:	e9 9a 00 00 00       	jmp    8010290f <ideintr+0xd3>
	}
	idequeue = b->qnext;
80102875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102878:	8b 40 14             	mov    0x14(%eax),%eax
8010287b:	a3 54 e6 10 80       	mov    %eax,0x8010e654

	// Read data if needed.
	if (!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102880:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102883:	8b 00                	mov    (%eax),%eax
80102885:	83 e0 04             	and    $0x4,%eax
80102888:	85 c0                	test   %eax,%eax
8010288a:	75 2d                	jne    801028b9 <ideintr+0x7d>
8010288c:	83 ec 0c             	sub    $0xc,%esp
8010288f:	6a 01                	push   $0x1
80102891:	e8 55 fd ff ff       	call   801025eb <idewait>
80102896:	83 c4 10             	add    $0x10,%esp
80102899:	85 c0                	test   %eax,%eax
8010289b:	78 1c                	js     801028b9 <ideintr+0x7d>
		insl(0x1f0, b->data, BSIZE / 4);
8010289d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028a0:	83 c0 18             	add    $0x18,%eax
801028a3:	83 ec 04             	sub    $0x4,%esp
801028a6:	68 80 00 00 00       	push   $0x80
801028ab:	50                   	push   %eax
801028ac:	68 f0 01 00 00       	push   $0x1f0
801028b1:	e8 ca fc ff ff       	call   80102580 <insl>
801028b6:	83 c4 10             	add    $0x10,%esp

	// Wake process waiting for this buf.
	b->flags |= B_VALID;
801028b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028bc:	8b 00                	mov    (%eax),%eax
801028be:	83 c8 02             	or     $0x2,%eax
801028c1:	89 c2                	mov    %eax,%edx
801028c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c6:	89 10                	mov    %edx,(%eax)
	b->flags &= ~B_DIRTY;
801028c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028cb:	8b 00                	mov    (%eax),%eax
801028cd:	83 e0 fb             	and    $0xfffffffb,%eax
801028d0:	89 c2                	mov    %eax,%edx
801028d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d5:	89 10                	mov    %edx,(%eax)
	wakeup(b);
801028d7:	83 ec 0c             	sub    $0xc,%esp
801028da:	ff 75 f4             	pushl  -0xc(%ebp)
801028dd:	e8 02 3a 00 00       	call   801062e4 <wakeup>
801028e2:	83 c4 10             	add    $0x10,%esp

	// Start disk on next buf in queue.
	if (idequeue != 0)
801028e5:	a1 54 e6 10 80       	mov    0x8010e654,%eax
801028ea:	85 c0                	test   %eax,%eax
801028ec:	74 11                	je     801028ff <ideintr+0xc3>
		idestart(idequeue);
801028ee:	a1 54 e6 10 80       	mov    0x8010e654,%eax
801028f3:	83 ec 0c             	sub    $0xc,%esp
801028f6:	50                   	push   %eax
801028f7:	e8 e2 fd ff ff       	call   801026de <idestart>
801028fc:	83 c4 10             	add    $0x10,%esp

	release(&idelock);
801028ff:	83 ec 0c             	sub    $0xc,%esp
80102902:	68 20 e6 10 80       	push   $0x8010e620
80102907:	e8 e8 41 00 00       	call   80106af4 <release>
8010290c:	83 c4 10             	add    $0x10,%esp
}
8010290f:	c9                   	leave  
80102910:	c3                   	ret    

80102911 <iderw>:
//PAGEBREAK!
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void iderw(struct buf *b)
{
80102911:	55                   	push   %ebp
80102912:	89 e5                	mov    %esp,%ebp
80102914:	83 ec 18             	sub    $0x18,%esp
	struct buf **pp;

	if (!(b->flags & B_BUSY))
80102917:	8b 45 08             	mov    0x8(%ebp),%eax
8010291a:	8b 00                	mov    (%eax),%eax
8010291c:	83 e0 01             	and    $0x1,%eax
8010291f:	85 c0                	test   %eax,%eax
80102921:	75 0d                	jne    80102930 <iderw+0x1f>
		panic("iderw: buf not busy");
80102923:	83 ec 0c             	sub    $0xc,%esp
80102926:	68 ed a4 10 80       	push   $0x8010a4ed
8010292b:	e8 36 dc ff ff       	call   80100566 <panic>
	if ((b->flags & (B_VALID | B_DIRTY)) == B_VALID)
80102930:	8b 45 08             	mov    0x8(%ebp),%eax
80102933:	8b 00                	mov    (%eax),%eax
80102935:	83 e0 06             	and    $0x6,%eax
80102938:	83 f8 02             	cmp    $0x2,%eax
8010293b:	75 0d                	jne    8010294a <iderw+0x39>
		panic("iderw: nothing to do");
8010293d:	83 ec 0c             	sub    $0xc,%esp
80102940:	68 01 a5 10 80       	push   $0x8010a501
80102945:	e8 1c dc ff ff       	call   80100566 <panic>
	if (b->dev != 0 && !havedisk1)
8010294a:	8b 45 08             	mov    0x8(%ebp),%eax
8010294d:	8b 40 04             	mov    0x4(%eax),%eax
80102950:	85 c0                	test   %eax,%eax
80102952:	74 16                	je     8010296a <iderw+0x59>
80102954:	a1 58 e6 10 80       	mov    0x8010e658,%eax
80102959:	85 c0                	test   %eax,%eax
8010295b:	75 0d                	jne    8010296a <iderw+0x59>
		panic("iderw: ide disk 1 not present");
8010295d:	83 ec 0c             	sub    $0xc,%esp
80102960:	68 16 a5 10 80       	push   $0x8010a516
80102965:	e8 fc db ff ff       	call   80100566 <panic>

	acquire(&idelock);	//DOC:acquire-lock
8010296a:	83 ec 0c             	sub    $0xc,%esp
8010296d:	68 20 e6 10 80       	push   $0x8010e620
80102972:	e8 16 41 00 00       	call   80106a8d <acquire>
80102977:	83 c4 10             	add    $0x10,%esp

	// Append b to idequeue.
	b->qnext = 0;
8010297a:	8b 45 08             	mov    0x8(%ebp),%eax
8010297d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
	for (pp = &idequeue; *pp; pp = &(*pp)->qnext)	//DOC:insert-queue
80102984:	c7 45 f4 54 e6 10 80 	movl   $0x8010e654,-0xc(%ebp)
8010298b:	eb 0b                	jmp    80102998 <iderw+0x87>
8010298d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102990:	8b 00                	mov    (%eax),%eax
80102992:	83 c0 14             	add    $0x14,%eax
80102995:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102998:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010299b:	8b 00                	mov    (%eax),%eax
8010299d:	85 c0                	test   %eax,%eax
8010299f:	75 ec                	jne    8010298d <iderw+0x7c>
		;
	*pp = b;
801029a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a4:	8b 55 08             	mov    0x8(%ebp),%edx
801029a7:	89 10                	mov    %edx,(%eax)

	// Start disk if necessary.
	if (idequeue == b)
801029a9:	a1 54 e6 10 80       	mov    0x8010e654,%eax
801029ae:	3b 45 08             	cmp    0x8(%ebp),%eax
801029b1:	75 23                	jne    801029d6 <iderw+0xc5>
		idestart(b);
801029b3:	83 ec 0c             	sub    $0xc,%esp
801029b6:	ff 75 08             	pushl  0x8(%ebp)
801029b9:	e8 20 fd ff ff       	call   801026de <idestart>
801029be:	83 c4 10             	add    $0x10,%esp

	// Wait for request to finish.
	while ((b->flags & (B_VALID | B_DIRTY)) != B_VALID) {
801029c1:	eb 13                	jmp    801029d6 <iderw+0xc5>
		sleep(b, &idelock);
801029c3:	83 ec 08             	sub    $0x8,%esp
801029c6:	68 20 e6 10 80       	push   $0x8010e620
801029cb:	ff 75 08             	pushl  0x8(%ebp)
801029ce:	e8 23 38 00 00       	call   801061f6 <sleep>
801029d3:	83 c4 10             	add    $0x10,%esp
	// Start disk if necessary.
	if (idequeue == b)
		idestart(b);

	// Wait for request to finish.
	while ((b->flags & (B_VALID | B_DIRTY)) != B_VALID) {
801029d6:	8b 45 08             	mov    0x8(%ebp),%eax
801029d9:	8b 00                	mov    (%eax),%eax
801029db:	83 e0 06             	and    $0x6,%eax
801029de:	83 f8 02             	cmp    $0x2,%eax
801029e1:	75 e0                	jne    801029c3 <iderw+0xb2>
		sleep(b, &idelock);
	}

	release(&idelock);
801029e3:	83 ec 0c             	sub    $0xc,%esp
801029e6:	68 20 e6 10 80       	push   $0x8010e620
801029eb:	e8 04 41 00 00       	call   80106af4 <release>
801029f0:	83 c4 10             	add    $0x10,%esp
}
801029f3:	90                   	nop
801029f4:	c9                   	leave  
801029f5:	c3                   	ret    

801029f6 <ioapicread>:
	uint pad[3];
	uint data;
};

static uint ioapicread(int reg)
{
801029f6:	55                   	push   %ebp
801029f7:	89 e5                	mov    %esp,%ebp
	ioapic->reg = reg;
801029f9:	a1 34 52 11 80       	mov    0x80115234,%eax
801029fe:	8b 55 08             	mov    0x8(%ebp),%edx
80102a01:	89 10                	mov    %edx,(%eax)
	return ioapic->data;
80102a03:	a1 34 52 11 80       	mov    0x80115234,%eax
80102a08:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a0b:	5d                   	pop    %ebp
80102a0c:	c3                   	ret    

80102a0d <ioapicwrite>:

static void ioapicwrite(int reg, uint data)
{
80102a0d:	55                   	push   %ebp
80102a0e:	89 e5                	mov    %esp,%ebp
	ioapic->reg = reg;
80102a10:	a1 34 52 11 80       	mov    0x80115234,%eax
80102a15:	8b 55 08             	mov    0x8(%ebp),%edx
80102a18:	89 10                	mov    %edx,(%eax)
	ioapic->data = data;
80102a1a:	a1 34 52 11 80       	mov    0x80115234,%eax
80102a1f:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a22:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a25:	90                   	nop
80102a26:	5d                   	pop    %ebp
80102a27:	c3                   	ret    

80102a28 <ioapicinit>:

void ioapicinit(void)
{
80102a28:	55                   	push   %ebp
80102a29:	89 e5                	mov    %esp,%ebp
80102a2b:	83 ec 18             	sub    $0x18,%esp
	int i, id, maxintr;

	if (!ismp)
80102a2e:	a1 04 57 11 80       	mov    0x80115704,%eax
80102a33:	85 c0                	test   %eax,%eax
80102a35:	0f 84 a0 00 00 00    	je     80102adb <ioapicinit+0xb3>
		return;

	ioapic = (volatile struct ioapic *)IOAPIC;
80102a3b:	c7 05 34 52 11 80 00 	movl   $0xfec00000,0x80115234
80102a42:	00 c0 fe 
	maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a45:	6a 01                	push   $0x1
80102a47:	e8 aa ff ff ff       	call   801029f6 <ioapicread>
80102a4c:	83 c4 04             	add    $0x4,%esp
80102a4f:	c1 e8 10             	shr    $0x10,%eax
80102a52:	25 ff 00 00 00       	and    $0xff,%eax
80102a57:	89 45 f0             	mov    %eax,-0x10(%ebp)
	id = ioapicread(REG_ID) >> 24;
80102a5a:	6a 00                	push   $0x0
80102a5c:	e8 95 ff ff ff       	call   801029f6 <ioapicread>
80102a61:	83 c4 04             	add    $0x4,%esp
80102a64:	c1 e8 18             	shr    $0x18,%eax
80102a67:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (id != ioapicid)
80102a6a:	0f b6 05 00 57 11 80 	movzbl 0x80115700,%eax
80102a71:	0f b6 c0             	movzbl %al,%eax
80102a74:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102a77:	74 10                	je     80102a89 <ioapicinit+0x61>
		cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a79:	83 ec 0c             	sub    $0xc,%esp
80102a7c:	68 34 a5 10 80       	push   $0x8010a534
80102a81:	e8 40 d9 ff ff       	call   801003c6 <cprintf>
80102a86:	83 c4 10             	add    $0x10,%esp

	// Mark all interrupts edge-triggered, active high, disabled,
	// and not routed to any CPUs.
	for (i = 0; i <= maxintr; i++) {
80102a89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a90:	eb 3f                	jmp    80102ad1 <ioapicinit+0xa9>
		ioapicwrite(REG_TABLE + 2 * i, INT_DISABLED | (T_IRQ0 + i));
80102a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a95:	83 c0 20             	add    $0x20,%eax
80102a98:	0d 00 00 01 00       	or     $0x10000,%eax
80102a9d:	89 c2                	mov    %eax,%edx
80102a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa2:	83 c0 08             	add    $0x8,%eax
80102aa5:	01 c0                	add    %eax,%eax
80102aa7:	83 ec 08             	sub    $0x8,%esp
80102aaa:	52                   	push   %edx
80102aab:	50                   	push   %eax
80102aac:	e8 5c ff ff ff       	call   80102a0d <ioapicwrite>
80102ab1:	83 c4 10             	add    $0x10,%esp
		ioapicwrite(REG_TABLE + 2 * i + 1, 0);
80102ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab7:	83 c0 08             	add    $0x8,%eax
80102aba:	01 c0                	add    %eax,%eax
80102abc:	83 c0 01             	add    $0x1,%eax
80102abf:	83 ec 08             	sub    $0x8,%esp
80102ac2:	6a 00                	push   $0x0
80102ac4:	50                   	push   %eax
80102ac5:	e8 43 ff ff ff       	call   80102a0d <ioapicwrite>
80102aca:	83 c4 10             	add    $0x10,%esp
	if (id != ioapicid)
		cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

	// Mark all interrupts edge-triggered, active high, disabled,
	// and not routed to any CPUs.
	for (i = 0; i <= maxintr; i++) {
80102acd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ad7:	7e b9                	jle    80102a92 <ioapicinit+0x6a>
80102ad9:	eb 01                	jmp    80102adc <ioapicinit+0xb4>
void ioapicinit(void)
{
	int i, id, maxintr;

	if (!ismp)
		return;
80102adb:	90                   	nop
	// and not routed to any CPUs.
	for (i = 0; i <= maxintr; i++) {
		ioapicwrite(REG_TABLE + 2 * i, INT_DISABLED | (T_IRQ0 + i));
		ioapicwrite(REG_TABLE + 2 * i + 1, 0);
	}
}
80102adc:	c9                   	leave  
80102add:	c3                   	ret    

80102ade <ioapicenable>:

void ioapicenable(int irq, int cpunum)
{
80102ade:	55                   	push   %ebp
80102adf:	89 e5                	mov    %esp,%ebp
	if (!ismp)
80102ae1:	a1 04 57 11 80       	mov    0x80115704,%eax
80102ae6:	85 c0                	test   %eax,%eax
80102ae8:	74 39                	je     80102b23 <ioapicenable+0x45>
		return;

	// Mark interrupt edge-triggered, active high,
	// enabled, and routed to the given cpunum,
	// which happens to be that cpu's APIC ID.
	ioapicwrite(REG_TABLE + 2 * irq, T_IRQ0 + irq);
80102aea:	8b 45 08             	mov    0x8(%ebp),%eax
80102aed:	83 c0 20             	add    $0x20,%eax
80102af0:	89 c2                	mov    %eax,%edx
80102af2:	8b 45 08             	mov    0x8(%ebp),%eax
80102af5:	83 c0 08             	add    $0x8,%eax
80102af8:	01 c0                	add    %eax,%eax
80102afa:	52                   	push   %edx
80102afb:	50                   	push   %eax
80102afc:	e8 0c ff ff ff       	call   80102a0d <ioapicwrite>
80102b01:	83 c4 08             	add    $0x8,%esp
	ioapicwrite(REG_TABLE + 2 * irq + 1, cpunum << 24);
80102b04:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b07:	c1 e0 18             	shl    $0x18,%eax
80102b0a:	89 c2                	mov    %eax,%edx
80102b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0f:	83 c0 08             	add    $0x8,%eax
80102b12:	01 c0                	add    %eax,%eax
80102b14:	83 c0 01             	add    $0x1,%eax
80102b17:	52                   	push   %edx
80102b18:	50                   	push   %eax
80102b19:	e8 ef fe ff ff       	call   80102a0d <ioapicwrite>
80102b1e:	83 c4 08             	add    $0x8,%esp
80102b21:	eb 01                	jmp    80102b24 <ioapicenable+0x46>
}

void ioapicenable(int irq, int cpunum)
{
	if (!ismp)
		return;
80102b23:	90                   	nop
	// Mark interrupt edge-triggered, active high,
	// enabled, and routed to the given cpunum,
	// which happens to be that cpu's APIC ID.
	ioapicwrite(REG_TABLE + 2 * irq, T_IRQ0 + irq);
	ioapicwrite(REG_TABLE + 2 * irq + 1, cpunum << 24);
}
80102b24:	c9                   	leave  
80102b25:	c3                   	ret    

80102b26 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102b26:	55                   	push   %ebp
80102b27:	89 e5                	mov    %esp,%ebp
80102b29:	8b 45 08             	mov    0x8(%ebp),%eax
80102b2c:	05 00 00 00 80       	add    $0x80000000,%eax
80102b31:	5d                   	pop    %ebp
80102b32:	c3                   	ret    

80102b33 <kinit1>:
// 1. main() calls kinit1() while still using entrypgdir to place just
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void kinit1(void *vstart, void *vend)
{
80102b33:	55                   	push   %ebp
80102b34:	89 e5                	mov    %esp,%ebp
80102b36:	83 ec 08             	sub    $0x8,%esp
	initlock(&kmem.lock, "kmem");
80102b39:	83 ec 08             	sub    $0x8,%esp
80102b3c:	68 66 a5 10 80       	push   $0x8010a566
80102b41:	68 40 52 11 80       	push   $0x80115240
80102b46:	e8 20 3f 00 00       	call   80106a6b <initlock>
80102b4b:	83 c4 10             	add    $0x10,%esp
	kmem.use_lock = 0;
80102b4e:	c7 05 74 52 11 80 00 	movl   $0x0,0x80115274
80102b55:	00 00 00 
	freerange(vstart, vend);
80102b58:	83 ec 08             	sub    $0x8,%esp
80102b5b:	ff 75 0c             	pushl  0xc(%ebp)
80102b5e:	ff 75 08             	pushl  0x8(%ebp)
80102b61:	e8 2a 00 00 00       	call   80102b90 <freerange>
80102b66:	83 c4 10             	add    $0x10,%esp
}
80102b69:	90                   	nop
80102b6a:	c9                   	leave  
80102b6b:	c3                   	ret    

80102b6c <kinit2>:

void kinit2(void *vstart, void *vend)
{
80102b6c:	55                   	push   %ebp
80102b6d:	89 e5                	mov    %esp,%ebp
80102b6f:	83 ec 08             	sub    $0x8,%esp
	freerange(vstart, vend);
80102b72:	83 ec 08             	sub    $0x8,%esp
80102b75:	ff 75 0c             	pushl  0xc(%ebp)
80102b78:	ff 75 08             	pushl  0x8(%ebp)
80102b7b:	e8 10 00 00 00       	call   80102b90 <freerange>
80102b80:	83 c4 10             	add    $0x10,%esp
	kmem.use_lock = 1;
80102b83:	c7 05 74 52 11 80 01 	movl   $0x1,0x80115274
80102b8a:	00 00 00 
}
80102b8d:	90                   	nop
80102b8e:	c9                   	leave  
80102b8f:	c3                   	ret    

80102b90 <freerange>:

void freerange(void *vstart, void *vend)
{
80102b90:	55                   	push   %ebp
80102b91:	89 e5                	mov    %esp,%ebp
80102b93:	83 ec 18             	sub    $0x18,%esp
	char *p;
	p = (char *)PGROUNDUP((uint) vstart);
80102b96:	8b 45 08             	mov    0x8(%ebp),%eax
80102b99:	05 ff 0f 00 00       	add    $0xfff,%eax
80102b9e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102ba3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (; p + PGSIZE <= (char *)vend; p += PGSIZE)
80102ba6:	eb 15                	jmp    80102bbd <freerange+0x2d>
		kfree(p);
80102ba8:	83 ec 0c             	sub    $0xc,%esp
80102bab:	ff 75 f4             	pushl  -0xc(%ebp)
80102bae:	e8 1a 00 00 00       	call   80102bcd <kfree>
80102bb3:	83 c4 10             	add    $0x10,%esp

void freerange(void *vstart, void *vend)
{
	char *p;
	p = (char *)PGROUNDUP((uint) vstart);
	for (; p + PGSIZE <= (char *)vend; p += PGSIZE)
80102bb6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bc0:	05 00 10 00 00       	add    $0x1000,%eax
80102bc5:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102bc8:	76 de                	jbe    80102ba8 <freerange+0x18>
		kfree(p);
}
80102bca:	90                   	nop
80102bcb:	c9                   	leave  
80102bcc:	c3                   	ret    

80102bcd <kfree>:
// Free the page of physical memory pointed at by v,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(char *v)
{
80102bcd:	55                   	push   %ebp
80102bce:	89 e5                	mov    %esp,%ebp
80102bd0:	83 ec 18             	sub    $0x18,%esp
	struct run *r;

	if ((uint) v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd6:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bdb:	85 c0                	test   %eax,%eax
80102bdd:	75 1b                	jne    80102bfa <kfree+0x2d>
80102bdf:	81 7d 08 dc 4f 12 80 	cmpl   $0x80124fdc,0x8(%ebp)
80102be6:	72 12                	jb     80102bfa <kfree+0x2d>
80102be8:	ff 75 08             	pushl  0x8(%ebp)
80102beb:	e8 36 ff ff ff       	call   80102b26 <v2p>
80102bf0:	83 c4 04             	add    $0x4,%esp
80102bf3:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102bf8:	76 0d                	jbe    80102c07 <kfree+0x3a>
		panic("kfree");
80102bfa:	83 ec 0c             	sub    $0xc,%esp
80102bfd:	68 6b a5 10 80       	push   $0x8010a56b
80102c02:	e8 5f d9 ff ff       	call   80100566 <panic>

	// Fill with junk to catch dangling refs.
	memset(v, 1, PGSIZE);
80102c07:	83 ec 04             	sub    $0x4,%esp
80102c0a:	68 00 10 00 00       	push   $0x1000
80102c0f:	6a 01                	push   $0x1
80102c11:	ff 75 08             	pushl  0x8(%ebp)
80102c14:	e8 d7 40 00 00       	call   80106cf0 <memset>
80102c19:	83 c4 10             	add    $0x10,%esp

	if (kmem.use_lock)
80102c1c:	a1 74 52 11 80       	mov    0x80115274,%eax
80102c21:	85 c0                	test   %eax,%eax
80102c23:	74 10                	je     80102c35 <kfree+0x68>
		acquire(&kmem.lock);
80102c25:	83 ec 0c             	sub    $0xc,%esp
80102c28:	68 40 52 11 80       	push   $0x80115240
80102c2d:	e8 5b 3e 00 00       	call   80106a8d <acquire>
80102c32:	83 c4 10             	add    $0x10,%esp
	r = (struct run *)v;
80102c35:	8b 45 08             	mov    0x8(%ebp),%eax
80102c38:	89 45 f4             	mov    %eax,-0xc(%ebp)
	r->next = kmem.freelist;
80102c3b:	8b 15 78 52 11 80    	mov    0x80115278,%edx
80102c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c44:	89 10                	mov    %edx,(%eax)
	kmem.freelist = r;
80102c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c49:	a3 78 52 11 80       	mov    %eax,0x80115278
	if (kmem.use_lock)
80102c4e:	a1 74 52 11 80       	mov    0x80115274,%eax
80102c53:	85 c0                	test   %eax,%eax
80102c55:	74 10                	je     80102c67 <kfree+0x9a>
		release(&kmem.lock);
80102c57:	83 ec 0c             	sub    $0xc,%esp
80102c5a:	68 40 52 11 80       	push   $0x80115240
80102c5f:	e8 90 3e 00 00       	call   80106af4 <release>
80102c64:	83 c4 10             	add    $0x10,%esp
}
80102c67:	90                   	nop
80102c68:	c9                   	leave  
80102c69:	c3                   	ret    

80102c6a <kalloc>:

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char *kalloc(void)
{
80102c6a:	55                   	push   %ebp
80102c6b:	89 e5                	mov    %esp,%ebp
80102c6d:	83 ec 18             	sub    $0x18,%esp
	struct run *r;

	if (kmem.use_lock)
80102c70:	a1 74 52 11 80       	mov    0x80115274,%eax
80102c75:	85 c0                	test   %eax,%eax
80102c77:	74 10                	je     80102c89 <kalloc+0x1f>
		acquire(&kmem.lock);
80102c79:	83 ec 0c             	sub    $0xc,%esp
80102c7c:	68 40 52 11 80       	push   $0x80115240
80102c81:	e8 07 3e 00 00       	call   80106a8d <acquire>
80102c86:	83 c4 10             	add    $0x10,%esp
	r = kmem.freelist;
80102c89:	a1 78 52 11 80       	mov    0x80115278,%eax
80102c8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (r)
80102c91:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c95:	74 0a                	je     80102ca1 <kalloc+0x37>
		kmem.freelist = r->next;
80102c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c9a:	8b 00                	mov    (%eax),%eax
80102c9c:	a3 78 52 11 80       	mov    %eax,0x80115278
	if (kmem.use_lock)
80102ca1:	a1 74 52 11 80       	mov    0x80115274,%eax
80102ca6:	85 c0                	test   %eax,%eax
80102ca8:	74 10                	je     80102cba <kalloc+0x50>
		release(&kmem.lock);
80102caa:	83 ec 0c             	sub    $0xc,%esp
80102cad:	68 40 52 11 80       	push   $0x80115240
80102cb2:	e8 3d 3e 00 00       	call   80106af4 <release>
80102cb7:	83 c4 10             	add    $0x10,%esp
	return (char *)r;
80102cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cbd:	c9                   	leave  
80102cbe:	c3                   	ret    

80102cbf <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102cbf:	55                   	push   %ebp
80102cc0:	89 e5                	mov    %esp,%ebp
80102cc2:	83 ec 14             	sub    $0x14,%esp
80102cc5:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ccc:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cd0:	89 c2                	mov    %eax,%edx
80102cd2:	ec                   	in     (%dx),%al
80102cd3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cd6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cda:	c9                   	leave  
80102cdb:	c3                   	ret    

80102cdc <kbdgetc>:
#include "x86.h"
#include "defs.h"
#include "kbd.h"

int kbdgetc(void)
{
80102cdc:	55                   	push   %ebp
80102cdd:	89 e5                	mov    %esp,%ebp
80102cdf:	83 ec 10             	sub    $0x10,%esp
	static uchar *charcode[4] = {
		normalmap, shiftmap, ctlmap, ctlmap
	};
	uint st, data, c;

	st = inb(KBSTATP);
80102ce2:	6a 64                	push   $0x64
80102ce4:	e8 d6 ff ff ff       	call   80102cbf <inb>
80102ce9:	83 c4 04             	add    $0x4,%esp
80102cec:	0f b6 c0             	movzbl %al,%eax
80102cef:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if ((st & KBS_DIB) == 0)
80102cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cf5:	83 e0 01             	and    $0x1,%eax
80102cf8:	85 c0                	test   %eax,%eax
80102cfa:	75 0a                	jne    80102d06 <kbdgetc+0x2a>
		return -1;
80102cfc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d01:	e9 23 01 00 00       	jmp    80102e29 <kbdgetc+0x14d>
	data = inb(KBDATAP);
80102d06:	6a 60                	push   $0x60
80102d08:	e8 b2 ff ff ff       	call   80102cbf <inb>
80102d0d:	83 c4 04             	add    $0x4,%esp
80102d10:	0f b6 c0             	movzbl %al,%eax
80102d13:	89 45 fc             	mov    %eax,-0x4(%ebp)

	if (data == 0xE0) {
80102d16:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d1d:	75 17                	jne    80102d36 <kbdgetc+0x5a>
		shift |= E0ESC;
80102d1f:	a1 5c e6 10 80       	mov    0x8010e65c,%eax
80102d24:	83 c8 40             	or     $0x40,%eax
80102d27:	a3 5c e6 10 80       	mov    %eax,0x8010e65c
		return 0;
80102d2c:	b8 00 00 00 00       	mov    $0x0,%eax
80102d31:	e9 f3 00 00 00       	jmp    80102e29 <kbdgetc+0x14d>
	} else if (data & 0x80) {
80102d36:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d39:	25 80 00 00 00       	and    $0x80,%eax
80102d3e:	85 c0                	test   %eax,%eax
80102d40:	74 45                	je     80102d87 <kbdgetc+0xab>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
80102d42:	a1 5c e6 10 80       	mov    0x8010e65c,%eax
80102d47:	83 e0 40             	and    $0x40,%eax
80102d4a:	85 c0                	test   %eax,%eax
80102d4c:	75 08                	jne    80102d56 <kbdgetc+0x7a>
80102d4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d51:	83 e0 7f             	and    $0x7f,%eax
80102d54:	eb 03                	jmp    80102d59 <kbdgetc+0x7d>
80102d56:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d59:	89 45 fc             	mov    %eax,-0x4(%ebp)
		shift &= ~(shiftcode[data] | E0ESC);
80102d5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d5f:	05 20 c0 10 80       	add    $0x8010c020,%eax
80102d64:	0f b6 00             	movzbl (%eax),%eax
80102d67:	83 c8 40             	or     $0x40,%eax
80102d6a:	0f b6 c0             	movzbl %al,%eax
80102d6d:	f7 d0                	not    %eax
80102d6f:	89 c2                	mov    %eax,%edx
80102d71:	a1 5c e6 10 80       	mov    0x8010e65c,%eax
80102d76:	21 d0                	and    %edx,%eax
80102d78:	a3 5c e6 10 80       	mov    %eax,0x8010e65c
		return 0;
80102d7d:	b8 00 00 00 00       	mov    $0x0,%eax
80102d82:	e9 a2 00 00 00       	jmp    80102e29 <kbdgetc+0x14d>
	} else if (shift & E0ESC) {
80102d87:	a1 5c e6 10 80       	mov    0x8010e65c,%eax
80102d8c:	83 e0 40             	and    $0x40,%eax
80102d8f:	85 c0                	test   %eax,%eax
80102d91:	74 14                	je     80102da7 <kbdgetc+0xcb>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
80102d93:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
		shift &= ~E0ESC;
80102d9a:	a1 5c e6 10 80       	mov    0x8010e65c,%eax
80102d9f:	83 e0 bf             	and    $0xffffffbf,%eax
80102da2:	a3 5c e6 10 80       	mov    %eax,0x8010e65c
	}

	shift |= shiftcode[data];
80102da7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102daa:	05 20 c0 10 80       	add    $0x8010c020,%eax
80102daf:	0f b6 00             	movzbl (%eax),%eax
80102db2:	0f b6 d0             	movzbl %al,%edx
80102db5:	a1 5c e6 10 80       	mov    0x8010e65c,%eax
80102dba:	09 d0                	or     %edx,%eax
80102dbc:	a3 5c e6 10 80       	mov    %eax,0x8010e65c
	shift ^= togglecode[data];
80102dc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc4:	05 20 c1 10 80       	add    $0x8010c120,%eax
80102dc9:	0f b6 00             	movzbl (%eax),%eax
80102dcc:	0f b6 d0             	movzbl %al,%edx
80102dcf:	a1 5c e6 10 80       	mov    0x8010e65c,%eax
80102dd4:	31 d0                	xor    %edx,%eax
80102dd6:	a3 5c e6 10 80       	mov    %eax,0x8010e65c
	c = charcode[shift & (CTL | SHIFT)][data];
80102ddb:	a1 5c e6 10 80       	mov    0x8010e65c,%eax
80102de0:	83 e0 03             	and    $0x3,%eax
80102de3:	8b 14 85 20 c5 10 80 	mov    -0x7fef3ae0(,%eax,4),%edx
80102dea:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ded:	01 d0                	add    %edx,%eax
80102def:	0f b6 00             	movzbl (%eax),%eax
80102df2:	0f b6 c0             	movzbl %al,%eax
80102df5:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (shift & CAPSLOCK) {
80102df8:	a1 5c e6 10 80       	mov    0x8010e65c,%eax
80102dfd:	83 e0 08             	and    $0x8,%eax
80102e00:	85 c0                	test   %eax,%eax
80102e02:	74 22                	je     80102e26 <kbdgetc+0x14a>
		if ('a' <= c && c <= 'z')
80102e04:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e08:	76 0c                	jbe    80102e16 <kbdgetc+0x13a>
80102e0a:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e0e:	77 06                	ja     80102e16 <kbdgetc+0x13a>
			c += 'A' - 'a';
80102e10:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e14:	eb 10                	jmp    80102e26 <kbdgetc+0x14a>
		else if ('A' <= c && c <= 'Z')
80102e16:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e1a:	76 0a                	jbe    80102e26 <kbdgetc+0x14a>
80102e1c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e20:	77 04                	ja     80102e26 <kbdgetc+0x14a>
			c += 'a' - 'A';
80102e22:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
	}
	return c;
80102e26:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e29:	c9                   	leave  
80102e2a:	c3                   	ret    

80102e2b <kbdintr>:

void kbdintr(void)
{
80102e2b:	55                   	push   %ebp
80102e2c:	89 e5                	mov    %esp,%ebp
80102e2e:	83 ec 08             	sub    $0x8,%esp
	consoleintr(kbdgetc);
80102e31:	83 ec 0c             	sub    $0xc,%esp
80102e34:	68 dc 2c 10 80       	push   $0x80102cdc
80102e39:	e8 bb d9 ff ff       	call   801007f9 <consoleintr>
80102e3e:	83 c4 10             	add    $0x10,%esp
}
80102e41:	90                   	nop
80102e42:	c9                   	leave  
80102e43:	c3                   	ret    

80102e44 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e44:	55                   	push   %ebp
80102e45:	89 e5                	mov    %esp,%ebp
80102e47:	83 ec 14             	sub    $0x14,%esp
80102e4a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e4d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e51:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e55:	89 c2                	mov    %eax,%edx
80102e57:	ec                   	in     (%dx),%al
80102e58:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e5b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e5f:	c9                   	leave  
80102e60:	c3                   	ret    

80102e61 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102e61:	55                   	push   %ebp
80102e62:	89 e5                	mov    %esp,%ebp
80102e64:	83 ec 08             	sub    $0x8,%esp
80102e67:	8b 55 08             	mov    0x8(%ebp),%edx
80102e6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e6d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e71:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e74:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e78:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e7c:	ee                   	out    %al,(%dx)
}
80102e7d:	90                   	nop
80102e7e:	c9                   	leave  
80102e7f:	c3                   	ret    

80102e80 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102e80:	55                   	push   %ebp
80102e81:	89 e5                	mov    %esp,%ebp
80102e83:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102e86:	9c                   	pushf  
80102e87:	58                   	pop    %eax
80102e88:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102e8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102e8e:	c9                   	leave  
80102e8f:	c3                   	ret    

80102e90 <lapicw>:
#define TDCR    (0x03E0/4)	// Timer Divide Configuration

volatile uint *lapic;		// Initialized in mp.c

static void lapicw(int index, int value)
{
80102e90:	55                   	push   %ebp
80102e91:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
80102e93:	a1 7c 52 11 80       	mov    0x8011527c,%eax
80102e98:	8b 55 08             	mov    0x8(%ebp),%edx
80102e9b:	c1 e2 02             	shl    $0x2,%edx
80102e9e:	01 c2                	add    %eax,%edx
80102ea0:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ea3:	89 02                	mov    %eax,(%edx)
	lapic[ID];		// wait for write to finish, by reading
80102ea5:	a1 7c 52 11 80       	mov    0x8011527c,%eax
80102eaa:	83 c0 20             	add    $0x20,%eax
80102ead:	8b 00                	mov    (%eax),%eax
}
80102eaf:	90                   	nop
80102eb0:	5d                   	pop    %ebp
80102eb1:	c3                   	ret    

80102eb2 <lapicinit>:

//PAGEBREAK!

void lapicinit(void)
{
80102eb2:	55                   	push   %ebp
80102eb3:	89 e5                	mov    %esp,%ebp
	if (!lapic)
80102eb5:	a1 7c 52 11 80       	mov    0x8011527c,%eax
80102eba:	85 c0                	test   %eax,%eax
80102ebc:	0f 84 0b 01 00 00    	je     80102fcd <lapicinit+0x11b>
		return;

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ec2:	68 3f 01 00 00       	push   $0x13f
80102ec7:	6a 3c                	push   $0x3c
80102ec9:	e8 c2 ff ff ff       	call   80102e90 <lapicw>
80102ece:	83 c4 08             	add    $0x8,%esp

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If xv6 cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
80102ed1:	6a 0b                	push   $0xb
80102ed3:	68 f8 00 00 00       	push   $0xf8
80102ed8:	e8 b3 ff ff ff       	call   80102e90 <lapicw>
80102edd:	83 c4 08             	add    $0x8,%esp
	lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102ee0:	68 20 00 02 00       	push   $0x20020
80102ee5:	68 c8 00 00 00       	push   $0xc8
80102eea:	e8 a1 ff ff ff       	call   80102e90 <lapicw>
80102eef:	83 c4 08             	add    $0x8,%esp
	lapicw(TICR, 10000000);
80102ef2:	68 80 96 98 00       	push   $0x989680
80102ef7:	68 e0 00 00 00       	push   $0xe0
80102efc:	e8 8f ff ff ff       	call   80102e90 <lapicw>
80102f01:	83 c4 08             	add    $0x8,%esp

	// Disable logical interrupt lines.
	lapicw(LINT0, MASKED);
80102f04:	68 00 00 01 00       	push   $0x10000
80102f09:	68 d4 00 00 00       	push   $0xd4
80102f0e:	e8 7d ff ff ff       	call   80102e90 <lapicw>
80102f13:	83 c4 08             	add    $0x8,%esp
	lapicw(LINT1, MASKED);
80102f16:	68 00 00 01 00       	push   $0x10000
80102f1b:	68 d8 00 00 00       	push   $0xd8
80102f20:	e8 6b ff ff ff       	call   80102e90 <lapicw>
80102f25:	83 c4 08             	add    $0x8,%esp

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER] >> 16) & 0xFF) >= 4)
80102f28:	a1 7c 52 11 80       	mov    0x8011527c,%eax
80102f2d:	83 c0 30             	add    $0x30,%eax
80102f30:	8b 00                	mov    (%eax),%eax
80102f32:	c1 e8 10             	shr    $0x10,%eax
80102f35:	0f b6 c0             	movzbl %al,%eax
80102f38:	83 f8 03             	cmp    $0x3,%eax
80102f3b:	76 12                	jbe    80102f4f <lapicinit+0x9d>
		lapicw(PCINT, MASKED);
80102f3d:	68 00 00 01 00       	push   $0x10000
80102f42:	68 d0 00 00 00       	push   $0xd0
80102f47:	e8 44 ff ff ff       	call   80102e90 <lapicw>
80102f4c:	83 c4 08             	add    $0x8,%esp

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f4f:	6a 33                	push   $0x33
80102f51:	68 dc 00 00 00       	push   $0xdc
80102f56:	e8 35 ff ff ff       	call   80102e90 <lapicw>
80102f5b:	83 c4 08             	add    $0x8,%esp

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
80102f5e:	6a 00                	push   $0x0
80102f60:	68 a0 00 00 00       	push   $0xa0
80102f65:	e8 26 ff ff ff       	call   80102e90 <lapicw>
80102f6a:	83 c4 08             	add    $0x8,%esp
	lapicw(ESR, 0);
80102f6d:	6a 00                	push   $0x0
80102f6f:	68 a0 00 00 00       	push   $0xa0
80102f74:	e8 17 ff ff ff       	call   80102e90 <lapicw>
80102f79:	83 c4 08             	add    $0x8,%esp

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
80102f7c:	6a 00                	push   $0x0
80102f7e:	6a 2c                	push   $0x2c
80102f80:	e8 0b ff ff ff       	call   80102e90 <lapicw>
80102f85:	83 c4 08             	add    $0x8,%esp

	// Send an Init Level De-Assert to synchronise arbitration ID's.
	lapicw(ICRHI, 0);
80102f88:	6a 00                	push   $0x0
80102f8a:	68 c4 00 00 00       	push   $0xc4
80102f8f:	e8 fc fe ff ff       	call   80102e90 <lapicw>
80102f94:	83 c4 08             	add    $0x8,%esp
	lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f97:	68 00 85 08 00       	push   $0x88500
80102f9c:	68 c0 00 00 00       	push   $0xc0
80102fa1:	e8 ea fe ff ff       	call   80102e90 <lapicw>
80102fa6:	83 c4 08             	add    $0x8,%esp
	while (lapic[ICRLO] & DELIVS) ;
80102fa9:	90                   	nop
80102faa:	a1 7c 52 11 80       	mov    0x8011527c,%eax
80102faf:	05 00 03 00 00       	add    $0x300,%eax
80102fb4:	8b 00                	mov    (%eax),%eax
80102fb6:	25 00 10 00 00       	and    $0x1000,%eax
80102fbb:	85 c0                	test   %eax,%eax
80102fbd:	75 eb                	jne    80102faa <lapicinit+0xf8>

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
80102fbf:	6a 00                	push   $0x0
80102fc1:	6a 20                	push   $0x20
80102fc3:	e8 c8 fe ff ff       	call   80102e90 <lapicw>
80102fc8:	83 c4 08             	add    $0x8,%esp
80102fcb:	eb 01                	jmp    80102fce <lapicinit+0x11c>
//PAGEBREAK!

void lapicinit(void)
{
	if (!lapic)
		return;
80102fcd:	90                   	nop
	lapicw(ICRLO, BCAST | INIT | LEVEL);
	while (lapic[ICRLO] & DELIVS) ;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
}
80102fce:	c9                   	leave  
80102fcf:	c3                   	ret    

80102fd0 <cpunum>:

int cpunum(void)
{
80102fd0:	55                   	push   %ebp
80102fd1:	89 e5                	mov    %esp,%ebp
80102fd3:	83 ec 08             	sub    $0x8,%esp
	// Cannot call cpu when interrupts are enabled:
	// result not guaranteed to last long enough to be used!
	// Would prefer to panic but even printing is chancy here:
	// almost everything, including cprintf and panic, calls cpu,
	// often indirectly through acquire and release.
	if (readeflags() & FL_IF) {
80102fd6:	e8 a5 fe ff ff       	call   80102e80 <readeflags>
80102fdb:	25 00 02 00 00       	and    $0x200,%eax
80102fe0:	85 c0                	test   %eax,%eax
80102fe2:	74 26                	je     8010300a <cpunum+0x3a>
		static int n;
		if (n++ == 0)
80102fe4:	a1 60 e6 10 80       	mov    0x8010e660,%eax
80102fe9:	8d 50 01             	lea    0x1(%eax),%edx
80102fec:	89 15 60 e6 10 80    	mov    %edx,0x8010e660
80102ff2:	85 c0                	test   %eax,%eax
80102ff4:	75 14                	jne    8010300a <cpunum+0x3a>
			cprintf("cpu called from %x with interrupts enabled\n",
80102ff6:	8b 45 04             	mov    0x4(%ebp),%eax
80102ff9:	83 ec 08             	sub    $0x8,%esp
80102ffc:	50                   	push   %eax
80102ffd:	68 74 a5 10 80       	push   $0x8010a574
80103002:	e8 bf d3 ff ff       	call   801003c6 <cprintf>
80103007:	83 c4 10             	add    $0x10,%esp
				__builtin_return_address(0));
	}

	if (lapic)
8010300a:	a1 7c 52 11 80       	mov    0x8011527c,%eax
8010300f:	85 c0                	test   %eax,%eax
80103011:	74 0f                	je     80103022 <cpunum+0x52>
		return lapic[ID] >> 24;
80103013:	a1 7c 52 11 80       	mov    0x8011527c,%eax
80103018:	83 c0 20             	add    $0x20,%eax
8010301b:	8b 00                	mov    (%eax),%eax
8010301d:	c1 e8 18             	shr    $0x18,%eax
80103020:	eb 05                	jmp    80103027 <cpunum+0x57>
	return 0;
80103022:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103027:	c9                   	leave  
80103028:	c3                   	ret    

80103029 <lapiceoi>:

// Acknowledge interrupt.
void lapiceoi(void)
{
80103029:	55                   	push   %ebp
8010302a:	89 e5                	mov    %esp,%ebp
	if (lapic)
8010302c:	a1 7c 52 11 80       	mov    0x8011527c,%eax
80103031:	85 c0                	test   %eax,%eax
80103033:	74 0c                	je     80103041 <lapiceoi+0x18>
		lapicw(EOI, 0);
80103035:	6a 00                	push   $0x0
80103037:	6a 2c                	push   $0x2c
80103039:	e8 52 fe ff ff       	call   80102e90 <lapicw>
8010303e:	83 c4 08             	add    $0x8,%esp
}
80103041:	90                   	nop
80103042:	c9                   	leave  
80103043:	c3                   	ret    

80103044 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void microdelay(int us)
{
80103044:	55                   	push   %ebp
80103045:	89 e5                	mov    %esp,%ebp
}
80103047:	90                   	nop
80103048:	5d                   	pop    %ebp
80103049:	c3                   	ret    

8010304a <lapicstartap>:
#define CMOS_RETURN  0x71

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void lapicstartap(uchar apicid, uint addr)
{
8010304a:	55                   	push   %ebp
8010304b:	89 e5                	mov    %esp,%ebp
8010304d:	83 ec 14             	sub    $0x14,%esp
80103050:	8b 45 08             	mov    0x8(%ebp),%eax
80103053:	88 45 ec             	mov    %al,-0x14(%ebp)
	ushort *wrv;

	// "The BSP must initialize CMOS shutdown code to 0AH
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(CMOS_PORT, 0xF);	// offset 0xF is shutdown code
80103056:	6a 0f                	push   $0xf
80103058:	6a 70                	push   $0x70
8010305a:	e8 02 fe ff ff       	call   80102e61 <outb>
8010305f:	83 c4 08             	add    $0x8,%esp
	outb(CMOS_PORT + 1, 0x0A);
80103062:	6a 0a                	push   $0xa
80103064:	6a 71                	push   $0x71
80103066:	e8 f6 fd ff ff       	call   80102e61 <outb>
8010306b:	83 c4 08             	add    $0x8,%esp
	wrv = (ushort *) P2V((0x40 << 4 | 0x67));	// Warm reset vector
8010306e:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
	wrv[0] = 0;
80103075:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103078:	66 c7 00 00 00       	movw   $0x0,(%eax)
	wrv[1] = addr >> 4;
8010307d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103080:	83 c0 02             	add    $0x2,%eax
80103083:	8b 55 0c             	mov    0xc(%ebp),%edx
80103086:	c1 ea 04             	shr    $0x4,%edx
80103089:	66 89 10             	mov    %dx,(%eax)

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
8010308c:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103090:	c1 e0 18             	shl    $0x18,%eax
80103093:	50                   	push   %eax
80103094:	68 c4 00 00 00       	push   $0xc4
80103099:	e8 f2 fd ff ff       	call   80102e90 <lapicw>
8010309e:	83 c4 08             	add    $0x8,%esp
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
801030a1:	68 00 c5 00 00       	push   $0xc500
801030a6:	68 c0 00 00 00       	push   $0xc0
801030ab:	e8 e0 fd ff ff       	call   80102e90 <lapicw>
801030b0:	83 c4 08             	add    $0x8,%esp
	microdelay(200);
801030b3:	68 c8 00 00 00       	push   $0xc8
801030b8:	e8 87 ff ff ff       	call   80103044 <microdelay>
801030bd:	83 c4 04             	add    $0x4,%esp
	lapicw(ICRLO, INIT | LEVEL);
801030c0:	68 00 85 00 00       	push   $0x8500
801030c5:	68 c0 00 00 00       	push   $0xc0
801030ca:	e8 c1 fd ff ff       	call   80102e90 <lapicw>
801030cf:	83 c4 08             	add    $0x8,%esp
	microdelay(100);	// should be 10ms, but too slow in Bochs!
801030d2:	6a 64                	push   $0x64
801030d4:	e8 6b ff ff ff       	call   80103044 <microdelay>
801030d9:	83 c4 04             	add    $0x4,%esp
	// Send startup IPI (twice!) to enter code.
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
801030dc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030e3:	eb 3d                	jmp    80103122 <lapicstartap+0xd8>
		lapicw(ICRHI, apicid << 24);
801030e5:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030e9:	c1 e0 18             	shl    $0x18,%eax
801030ec:	50                   	push   %eax
801030ed:	68 c4 00 00 00       	push   $0xc4
801030f2:	e8 99 fd ff ff       	call   80102e90 <lapicw>
801030f7:	83 c4 08             	add    $0x8,%esp
		lapicw(ICRLO, STARTUP | (addr >> 12));
801030fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801030fd:	c1 e8 0c             	shr    $0xc,%eax
80103100:	80 cc 06             	or     $0x6,%ah
80103103:	50                   	push   %eax
80103104:	68 c0 00 00 00       	push   $0xc0
80103109:	e8 82 fd ff ff       	call   80102e90 <lapicw>
8010310e:	83 c4 08             	add    $0x8,%esp
		microdelay(200);
80103111:	68 c8 00 00 00       	push   $0xc8
80103116:	e8 29 ff ff ff       	call   80103044 <microdelay>
8010311b:	83 c4 04             	add    $0x4,%esp
	// Send startup IPI (twice!) to enter code.
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
8010311e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103122:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103126:	7e bd                	jle    801030e5 <lapicstartap+0x9b>
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
		microdelay(200);
	}
}
80103128:	90                   	nop
80103129:	c9                   	leave  
8010312a:	c3                   	ret    

8010312b <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010312b:	55                   	push   %ebp
8010312c:	89 e5                	mov    %esp,%ebp
	outb(CMOS_PORT, reg);
8010312e:	8b 45 08             	mov    0x8(%ebp),%eax
80103131:	0f b6 c0             	movzbl %al,%eax
80103134:	50                   	push   %eax
80103135:	6a 70                	push   $0x70
80103137:	e8 25 fd ff ff       	call   80102e61 <outb>
8010313c:	83 c4 08             	add    $0x8,%esp
	microdelay(200);
8010313f:	68 c8 00 00 00       	push   $0xc8
80103144:	e8 fb fe ff ff       	call   80103044 <microdelay>
80103149:	83 c4 04             	add    $0x4,%esp

	return inb(CMOS_RETURN);
8010314c:	6a 71                	push   $0x71
8010314e:	e8 f1 fc ff ff       	call   80102e44 <inb>
80103153:	83 c4 04             	add    $0x4,%esp
80103156:	0f b6 c0             	movzbl %al,%eax
}
80103159:	c9                   	leave  
8010315a:	c3                   	ret    

8010315b <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010315b:	55                   	push   %ebp
8010315c:	89 e5                	mov    %esp,%ebp
	r->second = cmos_read(SECS);
8010315e:	6a 00                	push   $0x0
80103160:	e8 c6 ff ff ff       	call   8010312b <cmos_read>
80103165:	83 c4 04             	add    $0x4,%esp
80103168:	89 c2                	mov    %eax,%edx
8010316a:	8b 45 08             	mov    0x8(%ebp),%eax
8010316d:	89 10                	mov    %edx,(%eax)
	r->minute = cmos_read(MINS);
8010316f:	6a 02                	push   $0x2
80103171:	e8 b5 ff ff ff       	call   8010312b <cmos_read>
80103176:	83 c4 04             	add    $0x4,%esp
80103179:	89 c2                	mov    %eax,%edx
8010317b:	8b 45 08             	mov    0x8(%ebp),%eax
8010317e:	89 50 04             	mov    %edx,0x4(%eax)
	r->hour = cmos_read(HOURS);
80103181:	6a 04                	push   $0x4
80103183:	e8 a3 ff ff ff       	call   8010312b <cmos_read>
80103188:	83 c4 04             	add    $0x4,%esp
8010318b:	89 c2                	mov    %eax,%edx
8010318d:	8b 45 08             	mov    0x8(%ebp),%eax
80103190:	89 50 08             	mov    %edx,0x8(%eax)
	r->day = cmos_read(DAY);
80103193:	6a 07                	push   $0x7
80103195:	e8 91 ff ff ff       	call   8010312b <cmos_read>
8010319a:	83 c4 04             	add    $0x4,%esp
8010319d:	89 c2                	mov    %eax,%edx
8010319f:	8b 45 08             	mov    0x8(%ebp),%eax
801031a2:	89 50 0c             	mov    %edx,0xc(%eax)
	r->month = cmos_read(MONTH);
801031a5:	6a 08                	push   $0x8
801031a7:	e8 7f ff ff ff       	call   8010312b <cmos_read>
801031ac:	83 c4 04             	add    $0x4,%esp
801031af:	89 c2                	mov    %eax,%edx
801031b1:	8b 45 08             	mov    0x8(%ebp),%eax
801031b4:	89 50 10             	mov    %edx,0x10(%eax)
	r->year = cmos_read(YEAR);
801031b7:	6a 09                	push   $0x9
801031b9:	e8 6d ff ff ff       	call   8010312b <cmos_read>
801031be:	83 c4 04             	add    $0x4,%esp
801031c1:	89 c2                	mov    %eax,%edx
801031c3:	8b 45 08             	mov    0x8(%ebp),%eax
801031c6:	89 50 14             	mov    %edx,0x14(%eax)
}
801031c9:	90                   	nop
801031ca:	c9                   	leave  
801031cb:	c3                   	ret    

801031cc <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031cc:	55                   	push   %ebp
801031cd:	89 e5                	mov    %esp,%ebp
801031cf:	83 ec 48             	sub    $0x48,%esp
	struct rtcdate t1, t2;
	int sb, bcd;

	sb = cmos_read(CMOS_STATB);
801031d2:	6a 0b                	push   $0xb
801031d4:	e8 52 ff ff ff       	call   8010312b <cmos_read>
801031d9:	83 c4 04             	add    $0x4,%esp
801031dc:	89 45 f4             	mov    %eax,-0xc(%ebp)

	bcd = (sb & (1 << 2)) == 0;
801031df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031e2:	83 e0 04             	and    $0x4,%eax
801031e5:	85 c0                	test   %eax,%eax
801031e7:	0f 94 c0             	sete   %al
801031ea:	0f b6 c0             	movzbl %al,%eax
801031ed:	89 45 f0             	mov    %eax,-0x10(%ebp)

	// make sure CMOS doesn't modify time while we read it
	for (;;) {
		fill_rtcdate(&t1);
801031f0:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031f3:	50                   	push   %eax
801031f4:	e8 62 ff ff ff       	call   8010315b <fill_rtcdate>
801031f9:	83 c4 04             	add    $0x4,%esp
		if (cmos_read(CMOS_STATA) & CMOS_UIP)
801031fc:	6a 0a                	push   $0xa
801031fe:	e8 28 ff ff ff       	call   8010312b <cmos_read>
80103203:	83 c4 04             	add    $0x4,%esp
80103206:	25 80 00 00 00       	and    $0x80,%eax
8010320b:	85 c0                	test   %eax,%eax
8010320d:	75 27                	jne    80103236 <cmostime+0x6a>
			continue;
		fill_rtcdate(&t2);
8010320f:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103212:	50                   	push   %eax
80103213:	e8 43 ff ff ff       	call   8010315b <fill_rtcdate>
80103218:	83 c4 04             	add    $0x4,%esp
		if (memcmp(&t1, &t2, sizeof(t1)) == 0)
8010321b:	83 ec 04             	sub    $0x4,%esp
8010321e:	6a 18                	push   $0x18
80103220:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103223:	50                   	push   %eax
80103224:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103227:	50                   	push   %eax
80103228:	e8 2a 3b 00 00       	call   80106d57 <memcmp>
8010322d:	83 c4 10             	add    $0x10,%esp
80103230:	85 c0                	test   %eax,%eax
80103232:	74 05                	je     80103239 <cmostime+0x6d>
80103234:	eb ba                	jmp    801031f0 <cmostime+0x24>

	// make sure CMOS doesn't modify time while we read it
	for (;;) {
		fill_rtcdate(&t1);
		if (cmos_read(CMOS_STATA) & CMOS_UIP)
			continue;
80103236:	90                   	nop
		fill_rtcdate(&t2);
		if (memcmp(&t1, &t2, sizeof(t1)) == 0)
			break;
	}
80103237:	eb b7                	jmp    801031f0 <cmostime+0x24>
		fill_rtcdate(&t1);
		if (cmos_read(CMOS_STATA) & CMOS_UIP)
			continue;
		fill_rtcdate(&t2);
		if (memcmp(&t1, &t2, sizeof(t1)) == 0)
			break;
80103239:	90                   	nop
	}

	// convert
	if (bcd) {
8010323a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010323e:	0f 84 b4 00 00 00    	je     801032f8 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
		CONV(second);
80103244:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103247:	c1 e8 04             	shr    $0x4,%eax
8010324a:	89 c2                	mov    %eax,%edx
8010324c:	89 d0                	mov    %edx,%eax
8010324e:	c1 e0 02             	shl    $0x2,%eax
80103251:	01 d0                	add    %edx,%eax
80103253:	01 c0                	add    %eax,%eax
80103255:	89 c2                	mov    %eax,%edx
80103257:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010325a:	83 e0 0f             	and    $0xf,%eax
8010325d:	01 d0                	add    %edx,%eax
8010325f:	89 45 d8             	mov    %eax,-0x28(%ebp)
		CONV(minute);
80103262:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103265:	c1 e8 04             	shr    $0x4,%eax
80103268:	89 c2                	mov    %eax,%edx
8010326a:	89 d0                	mov    %edx,%eax
8010326c:	c1 e0 02             	shl    $0x2,%eax
8010326f:	01 d0                	add    %edx,%eax
80103271:	01 c0                	add    %eax,%eax
80103273:	89 c2                	mov    %eax,%edx
80103275:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103278:	83 e0 0f             	and    $0xf,%eax
8010327b:	01 d0                	add    %edx,%eax
8010327d:	89 45 dc             	mov    %eax,-0x24(%ebp)
		CONV(hour);
80103280:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103283:	c1 e8 04             	shr    $0x4,%eax
80103286:	89 c2                	mov    %eax,%edx
80103288:	89 d0                	mov    %edx,%eax
8010328a:	c1 e0 02             	shl    $0x2,%eax
8010328d:	01 d0                	add    %edx,%eax
8010328f:	01 c0                	add    %eax,%eax
80103291:	89 c2                	mov    %eax,%edx
80103293:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103296:	83 e0 0f             	and    $0xf,%eax
80103299:	01 d0                	add    %edx,%eax
8010329b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		CONV(day);
8010329e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032a1:	c1 e8 04             	shr    $0x4,%eax
801032a4:	89 c2                	mov    %eax,%edx
801032a6:	89 d0                	mov    %edx,%eax
801032a8:	c1 e0 02             	shl    $0x2,%eax
801032ab:	01 d0                	add    %edx,%eax
801032ad:	01 c0                	add    %eax,%eax
801032af:	89 c2                	mov    %eax,%edx
801032b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032b4:	83 e0 0f             	and    $0xf,%eax
801032b7:	01 d0                	add    %edx,%eax
801032b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		CONV(month);
801032bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032bf:	c1 e8 04             	shr    $0x4,%eax
801032c2:	89 c2                	mov    %eax,%edx
801032c4:	89 d0                	mov    %edx,%eax
801032c6:	c1 e0 02             	shl    $0x2,%eax
801032c9:	01 d0                	add    %edx,%eax
801032cb:	01 c0                	add    %eax,%eax
801032cd:	89 c2                	mov    %eax,%edx
801032cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032d2:	83 e0 0f             	and    $0xf,%eax
801032d5:	01 d0                	add    %edx,%eax
801032d7:	89 45 e8             	mov    %eax,-0x18(%ebp)
		CONV(year);
801032da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032dd:	c1 e8 04             	shr    $0x4,%eax
801032e0:	89 c2                	mov    %eax,%edx
801032e2:	89 d0                	mov    %edx,%eax
801032e4:	c1 e0 02             	shl    $0x2,%eax
801032e7:	01 d0                	add    %edx,%eax
801032e9:	01 c0                	add    %eax,%eax
801032eb:	89 c2                	mov    %eax,%edx
801032ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032f0:	83 e0 0f             	and    $0xf,%eax
801032f3:	01 d0                	add    %edx,%eax
801032f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
	}

	*r = t1;
801032f8:	8b 45 08             	mov    0x8(%ebp),%eax
801032fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032fe:	89 10                	mov    %edx,(%eax)
80103300:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103303:	89 50 04             	mov    %edx,0x4(%eax)
80103306:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103309:	89 50 08             	mov    %edx,0x8(%eax)
8010330c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010330f:	89 50 0c             	mov    %edx,0xc(%eax)
80103312:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103315:	89 50 10             	mov    %edx,0x10(%eax)
80103318:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010331b:	89 50 14             	mov    %edx,0x14(%eax)
	r->year += 2000;
8010331e:	8b 45 08             	mov    0x8(%ebp),%eax
80103321:	8b 40 14             	mov    0x14(%eax),%eax
80103324:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010332a:	8b 45 08             	mov    0x8(%ebp),%eax
8010332d:	89 50 14             	mov    %edx,0x14(%eax)
}
80103330:	90                   	nop
80103331:	c9                   	leave  
80103332:	c3                   	ret    

80103333 <initlog>:

static void recover_from_log(void);
static void commit();

void initlog(int dev)
{
80103333:	55                   	push   %ebp
80103334:	89 e5                	mov    %esp,%ebp
80103336:	83 ec 28             	sub    $0x28,%esp
	if (sizeof(struct logheader) >= BSIZE)
		panic("initlog: too big logheader");

	struct superblock sb;
	initlock(&log.lock, "log");
80103339:	83 ec 08             	sub    $0x8,%esp
8010333c:	68 a0 a5 10 80       	push   $0x8010a5a0
80103341:	68 80 52 11 80       	push   $0x80115280
80103346:	e8 20 37 00 00       	call   80106a6b <initlock>
8010334b:	83 c4 10             	add    $0x10,%esp
	readsb(dev, &sb);
8010334e:	83 ec 08             	sub    $0x8,%esp
80103351:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103354:	50                   	push   %eax
80103355:	ff 75 08             	pushl  0x8(%ebp)
80103358:	e8 2b e0 ff ff       	call   80101388 <readsb>
8010335d:	83 c4 10             	add    $0x10,%esp
	log.start = sb.logstart;
80103360:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103363:	a3 b4 52 11 80       	mov    %eax,0x801152b4
	log.size = sb.nlog;
80103368:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010336b:	a3 b8 52 11 80       	mov    %eax,0x801152b8
	log.dev = dev;
80103370:	8b 45 08             	mov    0x8(%ebp),%eax
80103373:	a3 c4 52 11 80       	mov    %eax,0x801152c4
	recover_from_log();
80103378:	e8 b2 01 00 00       	call   8010352f <recover_from_log>
}
8010337d:	90                   	nop
8010337e:	c9                   	leave  
8010337f:	c3                   	ret    

80103380 <install_trans>:

// Copy committed blocks from log to their home location
static void install_trans(void)
{
80103380:	55                   	push   %ebp
80103381:	89 e5                	mov    %esp,%ebp
80103383:	83 ec 18             	sub    $0x18,%esp
	int tail;

	for (tail = 0; tail < log.lh.n; tail++) {
80103386:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010338d:	e9 95 00 00 00       	jmp    80103427 <install_trans+0xa7>
		struct buf *lbuf = bread(log.dev, log.start + tail + 1);	// read log block
80103392:	8b 15 b4 52 11 80    	mov    0x801152b4,%edx
80103398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010339b:	01 d0                	add    %edx,%eax
8010339d:	83 c0 01             	add    $0x1,%eax
801033a0:	89 c2                	mov    %eax,%edx
801033a2:	a1 c4 52 11 80       	mov    0x801152c4,%eax
801033a7:	83 ec 08             	sub    $0x8,%esp
801033aa:	52                   	push   %edx
801033ab:	50                   	push   %eax
801033ac:	e8 05 ce ff ff       	call   801001b6 <bread>
801033b1:	83 c4 10             	add    $0x10,%esp
801033b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
		struct buf *dbuf = bread(log.dev, log.lh.block[tail]);	// read dst
801033b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033ba:	83 c0 10             	add    $0x10,%eax
801033bd:	8b 04 85 8c 52 11 80 	mov    -0x7feead74(,%eax,4),%eax
801033c4:	89 c2                	mov    %eax,%edx
801033c6:	a1 c4 52 11 80       	mov    0x801152c4,%eax
801033cb:	83 ec 08             	sub    $0x8,%esp
801033ce:	52                   	push   %edx
801033cf:	50                   	push   %eax
801033d0:	e8 e1 cd ff ff       	call   801001b6 <bread>
801033d5:	83 c4 10             	add    $0x10,%esp
801033d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
		memmove(dbuf->data, lbuf->data, BSIZE);	// copy block to dst
801033db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033de:	8d 50 18             	lea    0x18(%eax),%edx
801033e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033e4:	83 c0 18             	add    $0x18,%eax
801033e7:	83 ec 04             	sub    $0x4,%esp
801033ea:	68 00 02 00 00       	push   $0x200
801033ef:	52                   	push   %edx
801033f0:	50                   	push   %eax
801033f1:	e8 b9 39 00 00       	call   80106daf <memmove>
801033f6:	83 c4 10             	add    $0x10,%esp
		bwrite(dbuf);	// write dst to disk
801033f9:	83 ec 0c             	sub    $0xc,%esp
801033fc:	ff 75 ec             	pushl  -0x14(%ebp)
801033ff:	e8 eb cd ff ff       	call   801001ef <bwrite>
80103404:	83 c4 10             	add    $0x10,%esp
		brelse(lbuf);
80103407:	83 ec 0c             	sub    $0xc,%esp
8010340a:	ff 75 f0             	pushl  -0x10(%ebp)
8010340d:	e8 1c ce ff ff       	call   8010022e <brelse>
80103412:	83 c4 10             	add    $0x10,%esp
		brelse(dbuf);
80103415:	83 ec 0c             	sub    $0xc,%esp
80103418:	ff 75 ec             	pushl  -0x14(%ebp)
8010341b:	e8 0e ce ff ff       	call   8010022e <brelse>
80103420:	83 c4 10             	add    $0x10,%esp
// Copy committed blocks from log to their home location
static void install_trans(void)
{
	int tail;

	for (tail = 0; tail < log.lh.n; tail++) {
80103423:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103427:	a1 c8 52 11 80       	mov    0x801152c8,%eax
8010342c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010342f:	0f 8f 5d ff ff ff    	jg     80103392 <install_trans+0x12>
		memmove(dbuf->data, lbuf->data, BSIZE);	// copy block to dst
		bwrite(dbuf);	// write dst to disk
		brelse(lbuf);
		brelse(dbuf);
	}
}
80103435:	90                   	nop
80103436:	c9                   	leave  
80103437:	c3                   	ret    

80103438 <read_head>:

// Read the log header from disk into the in-memory log header
static void read_head(void)
{
80103438:	55                   	push   %ebp
80103439:	89 e5                	mov    %esp,%ebp
8010343b:	83 ec 18             	sub    $0x18,%esp
	struct buf *buf = bread(log.dev, log.start);
8010343e:	a1 b4 52 11 80       	mov    0x801152b4,%eax
80103443:	89 c2                	mov    %eax,%edx
80103445:	a1 c4 52 11 80       	mov    0x801152c4,%eax
8010344a:	83 ec 08             	sub    $0x8,%esp
8010344d:	52                   	push   %edx
8010344e:	50                   	push   %eax
8010344f:	e8 62 cd ff ff       	call   801001b6 <bread>
80103454:	83 c4 10             	add    $0x10,%esp
80103457:	89 45 f0             	mov    %eax,-0x10(%ebp)
	struct logheader *lh = (struct logheader *)(buf->data);
8010345a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010345d:	83 c0 18             	add    $0x18,%eax
80103460:	89 45 ec             	mov    %eax,-0x14(%ebp)
	int i;
	log.lh.n = lh->n;
80103463:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103466:	8b 00                	mov    (%eax),%eax
80103468:	a3 c8 52 11 80       	mov    %eax,0x801152c8
	for (i = 0; i < log.lh.n; i++) {
8010346d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103474:	eb 1b                	jmp    80103491 <read_head+0x59>
		log.lh.block[i] = lh->block[i];
80103476:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103479:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010347c:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103480:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103483:	83 c2 10             	add    $0x10,%edx
80103486:	89 04 95 8c 52 11 80 	mov    %eax,-0x7feead74(,%edx,4)
{
	struct buf *buf = bread(log.dev, log.start);
	struct logheader *lh = (struct logheader *)(buf->data);
	int i;
	log.lh.n = lh->n;
	for (i = 0; i < log.lh.n; i++) {
8010348d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103491:	a1 c8 52 11 80       	mov    0x801152c8,%eax
80103496:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103499:	7f db                	jg     80103476 <read_head+0x3e>
		log.lh.block[i] = lh->block[i];
	}
	brelse(buf);
8010349b:	83 ec 0c             	sub    $0xc,%esp
8010349e:	ff 75 f0             	pushl  -0x10(%ebp)
801034a1:	e8 88 cd ff ff       	call   8010022e <brelse>
801034a6:	83 c4 10             	add    $0x10,%esp
}
801034a9:	90                   	nop
801034aa:	c9                   	leave  
801034ab:	c3                   	ret    

801034ac <write_head>:

// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void write_head(void)
{
801034ac:	55                   	push   %ebp
801034ad:	89 e5                	mov    %esp,%ebp
801034af:	83 ec 18             	sub    $0x18,%esp
	struct buf *buf = bread(log.dev, log.start);
801034b2:	a1 b4 52 11 80       	mov    0x801152b4,%eax
801034b7:	89 c2                	mov    %eax,%edx
801034b9:	a1 c4 52 11 80       	mov    0x801152c4,%eax
801034be:	83 ec 08             	sub    $0x8,%esp
801034c1:	52                   	push   %edx
801034c2:	50                   	push   %eax
801034c3:	e8 ee cc ff ff       	call   801001b6 <bread>
801034c8:	83 c4 10             	add    $0x10,%esp
801034cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
	struct logheader *hb = (struct logheader *)(buf->data);
801034ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d1:	83 c0 18             	add    $0x18,%eax
801034d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
	int i;
	hb->n = log.lh.n;
801034d7:	8b 15 c8 52 11 80    	mov    0x801152c8,%edx
801034dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034e0:	89 10                	mov    %edx,(%eax)
	for (i = 0; i < log.lh.n; i++) {
801034e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034e9:	eb 1b                	jmp    80103506 <write_head+0x5a>
		hb->block[i] = log.lh.block[i];
801034eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034ee:	83 c0 10             	add    $0x10,%eax
801034f1:	8b 0c 85 8c 52 11 80 	mov    -0x7feead74(,%eax,4),%ecx
801034f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034fe:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
	struct buf *buf = bread(log.dev, log.start);
	struct logheader *hb = (struct logheader *)(buf->data);
	int i;
	hb->n = log.lh.n;
	for (i = 0; i < log.lh.n; i++) {
80103502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103506:	a1 c8 52 11 80       	mov    0x801152c8,%eax
8010350b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010350e:	7f db                	jg     801034eb <write_head+0x3f>
		hb->block[i] = log.lh.block[i];
	}
	bwrite(buf);
80103510:	83 ec 0c             	sub    $0xc,%esp
80103513:	ff 75 f0             	pushl  -0x10(%ebp)
80103516:	e8 d4 cc ff ff       	call   801001ef <bwrite>
8010351b:	83 c4 10             	add    $0x10,%esp
	brelse(buf);
8010351e:	83 ec 0c             	sub    $0xc,%esp
80103521:	ff 75 f0             	pushl  -0x10(%ebp)
80103524:	e8 05 cd ff ff       	call   8010022e <brelse>
80103529:	83 c4 10             	add    $0x10,%esp
}
8010352c:	90                   	nop
8010352d:	c9                   	leave  
8010352e:	c3                   	ret    

8010352f <recover_from_log>:

static void recover_from_log(void)
{
8010352f:	55                   	push   %ebp
80103530:	89 e5                	mov    %esp,%ebp
80103532:	83 ec 08             	sub    $0x8,%esp
	read_head();
80103535:	e8 fe fe ff ff       	call   80103438 <read_head>
	install_trans();	// if committed, copy from log to disk
8010353a:	e8 41 fe ff ff       	call   80103380 <install_trans>
	log.lh.n = 0;
8010353f:	c7 05 c8 52 11 80 00 	movl   $0x0,0x801152c8
80103546:	00 00 00 
	write_head();		// clear the log
80103549:	e8 5e ff ff ff       	call   801034ac <write_head>
}
8010354e:	90                   	nop
8010354f:	c9                   	leave  
80103550:	c3                   	ret    

80103551 <begin_op>:

// called at the start of each FS system call.
void begin_op(void)
{
80103551:	55                   	push   %ebp
80103552:	89 e5                	mov    %esp,%ebp
80103554:	83 ec 08             	sub    $0x8,%esp
	acquire(&log.lock);
80103557:	83 ec 0c             	sub    $0xc,%esp
8010355a:	68 80 52 11 80       	push   $0x80115280
8010355f:	e8 29 35 00 00       	call   80106a8d <acquire>
80103564:	83 c4 10             	add    $0x10,%esp
	while (1) {
		if (log.committing) {
80103567:	a1 c0 52 11 80       	mov    0x801152c0,%eax
8010356c:	85 c0                	test   %eax,%eax
8010356e:	74 17                	je     80103587 <begin_op+0x36>
			sleep(&log, &log.lock);
80103570:	83 ec 08             	sub    $0x8,%esp
80103573:	68 80 52 11 80       	push   $0x80115280
80103578:	68 80 52 11 80       	push   $0x80115280
8010357d:	e8 74 2c 00 00       	call   801061f6 <sleep>
80103582:	83 c4 10             	add    $0x10,%esp
80103585:	eb e0                	jmp    80103567 <begin_op+0x16>
		} else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS >
80103587:	8b 0d c8 52 11 80    	mov    0x801152c8,%ecx
8010358d:	a1 bc 52 11 80       	mov    0x801152bc,%eax
80103592:	8d 50 01             	lea    0x1(%eax),%edx
80103595:	89 d0                	mov    %edx,%eax
80103597:	c1 e0 02             	shl    $0x2,%eax
8010359a:	01 d0                	add    %edx,%eax
8010359c:	01 c0                	add    %eax,%eax
8010359e:	01 c8                	add    %ecx,%eax
801035a0:	83 f8 1e             	cmp    $0x1e,%eax
801035a3:	7e 17                	jle    801035bc <begin_op+0x6b>
			   LOGSIZE) {
			// this op might exhaust log space; wait for commit.
			sleep(&log, &log.lock);
801035a5:	83 ec 08             	sub    $0x8,%esp
801035a8:	68 80 52 11 80       	push   $0x80115280
801035ad:	68 80 52 11 80       	push   $0x80115280
801035b2:	e8 3f 2c 00 00       	call   801061f6 <sleep>
801035b7:	83 c4 10             	add    $0x10,%esp
801035ba:	eb ab                	jmp    80103567 <begin_op+0x16>
		} else {
			log.outstanding += 1;
801035bc:	a1 bc 52 11 80       	mov    0x801152bc,%eax
801035c1:	83 c0 01             	add    $0x1,%eax
801035c4:	a3 bc 52 11 80       	mov    %eax,0x801152bc
			release(&log.lock);
801035c9:	83 ec 0c             	sub    $0xc,%esp
801035cc:	68 80 52 11 80       	push   $0x80115280
801035d1:	e8 1e 35 00 00       	call   80106af4 <release>
801035d6:	83 c4 10             	add    $0x10,%esp
			break;
801035d9:	90                   	nop
		}
	}
}
801035da:	90                   	nop
801035db:	c9                   	leave  
801035dc:	c3                   	ret    

801035dd <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void end_op(void)
{
801035dd:	55                   	push   %ebp
801035de:	89 e5                	mov    %esp,%ebp
801035e0:	83 ec 18             	sub    $0x18,%esp
	int do_commit = 0;
801035e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	acquire(&log.lock);
801035ea:	83 ec 0c             	sub    $0xc,%esp
801035ed:	68 80 52 11 80       	push   $0x80115280
801035f2:	e8 96 34 00 00       	call   80106a8d <acquire>
801035f7:	83 c4 10             	add    $0x10,%esp
	log.outstanding -= 1;
801035fa:	a1 bc 52 11 80       	mov    0x801152bc,%eax
801035ff:	83 e8 01             	sub    $0x1,%eax
80103602:	a3 bc 52 11 80       	mov    %eax,0x801152bc
	if (log.committing)
80103607:	a1 c0 52 11 80       	mov    0x801152c0,%eax
8010360c:	85 c0                	test   %eax,%eax
8010360e:	74 0d                	je     8010361d <end_op+0x40>
		panic("log.committing");
80103610:	83 ec 0c             	sub    $0xc,%esp
80103613:	68 a4 a5 10 80       	push   $0x8010a5a4
80103618:	e8 49 cf ff ff       	call   80100566 <panic>
	if (log.outstanding == 0) {
8010361d:	a1 bc 52 11 80       	mov    0x801152bc,%eax
80103622:	85 c0                	test   %eax,%eax
80103624:	75 13                	jne    80103639 <end_op+0x5c>
		do_commit = 1;
80103626:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
		log.committing = 1;
8010362d:	c7 05 c0 52 11 80 01 	movl   $0x1,0x801152c0
80103634:	00 00 00 
80103637:	eb 10                	jmp    80103649 <end_op+0x6c>
	} else {
		// begin_op() may be waiting for log space.
		wakeup(&log);
80103639:	83 ec 0c             	sub    $0xc,%esp
8010363c:	68 80 52 11 80       	push   $0x80115280
80103641:	e8 9e 2c 00 00       	call   801062e4 <wakeup>
80103646:	83 c4 10             	add    $0x10,%esp
	}
	release(&log.lock);
80103649:	83 ec 0c             	sub    $0xc,%esp
8010364c:	68 80 52 11 80       	push   $0x80115280
80103651:	e8 9e 34 00 00       	call   80106af4 <release>
80103656:	83 c4 10             	add    $0x10,%esp

	if (do_commit) {
80103659:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010365d:	74 3f                	je     8010369e <end_op+0xc1>
		// call commit w/o holding locks, since not allowed
		// to sleep with locks.
		commit();
8010365f:	e8 f5 00 00 00       	call   80103759 <commit>
		acquire(&log.lock);
80103664:	83 ec 0c             	sub    $0xc,%esp
80103667:	68 80 52 11 80       	push   $0x80115280
8010366c:	e8 1c 34 00 00       	call   80106a8d <acquire>
80103671:	83 c4 10             	add    $0x10,%esp
		log.committing = 0;
80103674:	c7 05 c0 52 11 80 00 	movl   $0x0,0x801152c0
8010367b:	00 00 00 
		wakeup(&log);
8010367e:	83 ec 0c             	sub    $0xc,%esp
80103681:	68 80 52 11 80       	push   $0x80115280
80103686:	e8 59 2c 00 00       	call   801062e4 <wakeup>
8010368b:	83 c4 10             	add    $0x10,%esp
		release(&log.lock);
8010368e:	83 ec 0c             	sub    $0xc,%esp
80103691:	68 80 52 11 80       	push   $0x80115280
80103696:	e8 59 34 00 00       	call   80106af4 <release>
8010369b:	83 c4 10             	add    $0x10,%esp
	}
}
8010369e:	90                   	nop
8010369f:	c9                   	leave  
801036a0:	c3                   	ret    

801036a1 <write_log>:

// Copy modified blocks from cache to log.
static void write_log(void)
{
801036a1:	55                   	push   %ebp
801036a2:	89 e5                	mov    %esp,%ebp
801036a4:	83 ec 18             	sub    $0x18,%esp
	int tail;

	for (tail = 0; tail < log.lh.n; tail++) {
801036a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036ae:	e9 95 00 00 00       	jmp    80103748 <write_log+0xa7>
		struct buf *to = bread(log.dev, log.start + tail + 1);	// log block
801036b3:	8b 15 b4 52 11 80    	mov    0x801152b4,%edx
801036b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036bc:	01 d0                	add    %edx,%eax
801036be:	83 c0 01             	add    $0x1,%eax
801036c1:	89 c2                	mov    %eax,%edx
801036c3:	a1 c4 52 11 80       	mov    0x801152c4,%eax
801036c8:	83 ec 08             	sub    $0x8,%esp
801036cb:	52                   	push   %edx
801036cc:	50                   	push   %eax
801036cd:	e8 e4 ca ff ff       	call   801001b6 <bread>
801036d2:	83 c4 10             	add    $0x10,%esp
801036d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
		struct buf *from = bread(log.dev, log.lh.block[tail]);	// cache block
801036d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036db:	83 c0 10             	add    $0x10,%eax
801036de:	8b 04 85 8c 52 11 80 	mov    -0x7feead74(,%eax,4),%eax
801036e5:	89 c2                	mov    %eax,%edx
801036e7:	a1 c4 52 11 80       	mov    0x801152c4,%eax
801036ec:	83 ec 08             	sub    $0x8,%esp
801036ef:	52                   	push   %edx
801036f0:	50                   	push   %eax
801036f1:	e8 c0 ca ff ff       	call   801001b6 <bread>
801036f6:	83 c4 10             	add    $0x10,%esp
801036f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
		memmove(to->data, from->data, BSIZE);
801036fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036ff:	8d 50 18             	lea    0x18(%eax),%edx
80103702:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103705:	83 c0 18             	add    $0x18,%eax
80103708:	83 ec 04             	sub    $0x4,%esp
8010370b:	68 00 02 00 00       	push   $0x200
80103710:	52                   	push   %edx
80103711:	50                   	push   %eax
80103712:	e8 98 36 00 00       	call   80106daf <memmove>
80103717:	83 c4 10             	add    $0x10,%esp
		bwrite(to);	// write the log
8010371a:	83 ec 0c             	sub    $0xc,%esp
8010371d:	ff 75 f0             	pushl  -0x10(%ebp)
80103720:	e8 ca ca ff ff       	call   801001ef <bwrite>
80103725:	83 c4 10             	add    $0x10,%esp
		brelse(from);
80103728:	83 ec 0c             	sub    $0xc,%esp
8010372b:	ff 75 ec             	pushl  -0x14(%ebp)
8010372e:	e8 fb ca ff ff       	call   8010022e <brelse>
80103733:	83 c4 10             	add    $0x10,%esp
		brelse(to);
80103736:	83 ec 0c             	sub    $0xc,%esp
80103739:	ff 75 f0             	pushl  -0x10(%ebp)
8010373c:	e8 ed ca ff ff       	call   8010022e <brelse>
80103741:	83 c4 10             	add    $0x10,%esp
// Copy modified blocks from cache to log.
static void write_log(void)
{
	int tail;

	for (tail = 0; tail < log.lh.n; tail++) {
80103744:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103748:	a1 c8 52 11 80       	mov    0x801152c8,%eax
8010374d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103750:	0f 8f 5d ff ff ff    	jg     801036b3 <write_log+0x12>
		memmove(to->data, from->data, BSIZE);
		bwrite(to);	// write the log
		brelse(from);
		brelse(to);
	}
}
80103756:	90                   	nop
80103757:	c9                   	leave  
80103758:	c3                   	ret    

80103759 <commit>:

static void commit()
{
80103759:	55                   	push   %ebp
8010375a:	89 e5                	mov    %esp,%ebp
8010375c:	83 ec 08             	sub    $0x8,%esp
	if (log.lh.n > 0) {
8010375f:	a1 c8 52 11 80       	mov    0x801152c8,%eax
80103764:	85 c0                	test   %eax,%eax
80103766:	7e 1e                	jle    80103786 <commit+0x2d>
		write_log();	// Write modified blocks from cache to log
80103768:	e8 34 ff ff ff       	call   801036a1 <write_log>
		write_head();	// Write header to disk -- the real commit
8010376d:	e8 3a fd ff ff       	call   801034ac <write_head>
		install_trans();	// Now install writes to home locations
80103772:	e8 09 fc ff ff       	call   80103380 <install_trans>
		log.lh.n = 0;
80103777:	c7 05 c8 52 11 80 00 	movl   $0x0,0x801152c8
8010377e:	00 00 00 
		write_head();	// Erase the transaction from the log
80103781:	e8 26 fd ff ff       	call   801034ac <write_head>
	}
}
80103786:	90                   	nop
80103787:	c9                   	leave  
80103788:	c3                   	ret    

80103789 <log_write>:
//   bp = bread(...)
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void log_write(struct buf *b)
{
80103789:	55                   	push   %ebp
8010378a:	89 e5                	mov    %esp,%ebp
8010378c:	83 ec 18             	sub    $0x18,%esp
	int i;

	if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010378f:	a1 c8 52 11 80       	mov    0x801152c8,%eax
80103794:	83 f8 1d             	cmp    $0x1d,%eax
80103797:	7f 12                	jg     801037ab <log_write+0x22>
80103799:	a1 c8 52 11 80       	mov    0x801152c8,%eax
8010379e:	8b 15 b8 52 11 80    	mov    0x801152b8,%edx
801037a4:	83 ea 01             	sub    $0x1,%edx
801037a7:	39 d0                	cmp    %edx,%eax
801037a9:	7c 0d                	jl     801037b8 <log_write+0x2f>
		panic("too big a transaction");
801037ab:	83 ec 0c             	sub    $0xc,%esp
801037ae:	68 b3 a5 10 80       	push   $0x8010a5b3
801037b3:	e8 ae cd ff ff       	call   80100566 <panic>
	if (log.outstanding < 1)
801037b8:	a1 bc 52 11 80       	mov    0x801152bc,%eax
801037bd:	85 c0                	test   %eax,%eax
801037bf:	7f 0d                	jg     801037ce <log_write+0x45>
		panic("log_write outside of trans");
801037c1:	83 ec 0c             	sub    $0xc,%esp
801037c4:	68 c9 a5 10 80       	push   $0x8010a5c9
801037c9:	e8 98 cd ff ff       	call   80100566 <panic>

	acquire(&log.lock);
801037ce:	83 ec 0c             	sub    $0xc,%esp
801037d1:	68 80 52 11 80       	push   $0x80115280
801037d6:	e8 b2 32 00 00       	call   80106a8d <acquire>
801037db:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < log.lh.n; i++) {
801037de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037e5:	eb 1d                	jmp    80103804 <log_write+0x7b>
		if (log.lh.block[i] == b->blockno)	// log absorbtion
801037e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ea:	83 c0 10             	add    $0x10,%eax
801037ed:	8b 04 85 8c 52 11 80 	mov    -0x7feead74(,%eax,4),%eax
801037f4:	89 c2                	mov    %eax,%edx
801037f6:	8b 45 08             	mov    0x8(%ebp),%eax
801037f9:	8b 40 08             	mov    0x8(%eax),%eax
801037fc:	39 c2                	cmp    %eax,%edx
801037fe:	74 10                	je     80103810 <log_write+0x87>
		panic("too big a transaction");
	if (log.outstanding < 1)
		panic("log_write outside of trans");

	acquire(&log.lock);
	for (i = 0; i < log.lh.n; i++) {
80103800:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103804:	a1 c8 52 11 80       	mov    0x801152c8,%eax
80103809:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010380c:	7f d9                	jg     801037e7 <log_write+0x5e>
8010380e:	eb 01                	jmp    80103811 <log_write+0x88>
		if (log.lh.block[i] == b->blockno)	// log absorbtion
			break;
80103810:	90                   	nop
	}
	log.lh.block[i] = b->blockno;
80103811:	8b 45 08             	mov    0x8(%ebp),%eax
80103814:	8b 40 08             	mov    0x8(%eax),%eax
80103817:	89 c2                	mov    %eax,%edx
80103819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010381c:	83 c0 10             	add    $0x10,%eax
8010381f:	89 14 85 8c 52 11 80 	mov    %edx,-0x7feead74(,%eax,4)
	if (i == log.lh.n)
80103826:	a1 c8 52 11 80       	mov    0x801152c8,%eax
8010382b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010382e:	75 0d                	jne    8010383d <log_write+0xb4>
		log.lh.n++;
80103830:	a1 c8 52 11 80       	mov    0x801152c8,%eax
80103835:	83 c0 01             	add    $0x1,%eax
80103838:	a3 c8 52 11 80       	mov    %eax,0x801152c8
	b->flags |= B_DIRTY;	// prevent eviction
8010383d:	8b 45 08             	mov    0x8(%ebp),%eax
80103840:	8b 00                	mov    (%eax),%eax
80103842:	83 c8 04             	or     $0x4,%eax
80103845:	89 c2                	mov    %eax,%edx
80103847:	8b 45 08             	mov    0x8(%ebp),%eax
8010384a:	89 10                	mov    %edx,(%eax)
	release(&log.lock);
8010384c:	83 ec 0c             	sub    $0xc,%esp
8010384f:	68 80 52 11 80       	push   $0x80115280
80103854:	e8 9b 32 00 00       	call   80106af4 <release>
80103859:	83 c4 10             	add    $0x10,%esp
}
8010385c:	90                   	nop
8010385d:	c9                   	leave  
8010385e:	c3                   	ret    

8010385f <v2p>:
8010385f:	55                   	push   %ebp
80103860:	89 e5                	mov    %esp,%ebp
80103862:	8b 45 08             	mov    0x8(%ebp),%eax
80103865:	05 00 00 00 80       	add    $0x80000000,%eax
8010386a:	5d                   	pop    %ebp
8010386b:	c3                   	ret    

8010386c <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010386c:	55                   	push   %ebp
8010386d:	89 e5                	mov    %esp,%ebp
8010386f:	8b 45 08             	mov    0x8(%ebp),%eax
80103872:	05 00 00 00 80       	add    $0x80000000,%eax
80103877:	5d                   	pop    %ebp
80103878:	c3                   	ret    

80103879 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103879:	55                   	push   %ebp
8010387a:	89 e5                	mov    %esp,%ebp
8010387c:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010387f:	8b 55 08             	mov    0x8(%ebp),%edx
80103882:	8b 45 0c             	mov    0xc(%ebp),%eax
80103885:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103888:	f0 87 02             	lock xchg %eax,(%edx)
8010388b:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010388e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103891:	c9                   	leave  
80103892:	c3                   	ret    

80103893 <shm_init>:
struct shm shm_arr[SHM_MAXNUM];

int used;

char* shm_init()
{
80103893:	55                   	push   %ebp
80103894:	89 e5                	mov    %esp,%ebp
80103896:	83 ec 18             	sub    $0x18,%esp
	used = 0;
80103899:	c7 05 60 53 11 80 00 	movl   $0x0,0x80115360
801038a0:	00 00 00 
	int count = 0;
801038a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(count<SHM_MAXNUM)
801038aa:	e9 8a 00 00 00       	jmp    80103939 <shm_init+0xa6>
	{
		shm_arr[count].name_length = 0;
801038af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038b2:	c1 e0 02             	shl    $0x2,%eax
801038b5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801038bc:	29 c2                	sub    %eax,%edx
801038be:	89 d0                	mov    %edx,%eax
801038c0:	05 80 53 11 80       	add    $0x80115380,%eax
801038c5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		safestrcpy(shm_arr[count].name, "DNE", sizeof(shm_arr[count].name)); 
801038cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038ce:	89 c2                	mov    %eax,%edx
801038d0:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
801038d7:	89 c2                	mov    %eax,%edx
801038d9:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
801038e0:	29 d0                	sub    %edx,%eax
801038e2:	05 80 53 11 80       	add    $0x80115380,%eax
801038e7:	83 c0 04             	add    $0x4,%eax
801038ea:	83 ec 04             	sub    $0x4,%esp
801038ed:	6a 10                	push   $0x10
801038ef:	68 e4 a5 10 80       	push   $0x8010a5e4
801038f4:	50                   	push   %eax
801038f5:	e8 f9 35 00 00       	call   80106ef3 <safestrcpy>
801038fa:	83 c4 10             	add    $0x10,%esp
		//cprintf("Initialize SHM: %s\n", &(shm_arr[count].name[0]));
		shm_arr[count].numAccess = 0;
801038fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103900:	c1 e0 02             	shl    $0x2,%eax
80103903:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010390a:	29 c2                	sub    %eax,%edx
8010390c:	89 d0                	mov    %edx,%eax
8010390e:	05 94 53 11 80       	add    $0x80115394,%eax
80103913:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		shm_arr[count].shmPhys = 0;
80103919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010391c:	c1 e0 02             	shl    $0x2,%eax
8010391f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80103926:	29 c2                	sub    %eax,%edx
80103928:	89 d0                	mov    %edx,%eax
8010392a:	05 98 53 11 80       	add    $0x80115398,%eax
8010392f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		count++;
80103935:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

char* shm_init()
{
	used = 0;
	int count = 0;
	while(count<SHM_MAXNUM)
80103939:	83 7d f4 1f          	cmpl   $0x1f,-0xc(%ebp)
8010393d:	0f 8e 6c ff ff ff    	jle    801038af <shm_init+0x1c>
		//cprintf("Initialize SHM: %s\n", &(shm_arr[count].name[0]));
		shm_arr[count].numAccess = 0;
		shm_arr[count].shmPhys = 0;
		count++;
	}
	return 0;
80103943:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103948:	c9                   	leave  
80103949:	c3                   	ret    

8010394a <shm_find>:

//Searches for matching shm string in array of shm and returns array index if found
//Returns -1 if no matching string was found
int shm_find(const char* str)
{
8010394a:	55                   	push   %ebp
8010394b:	89 e5                	mov    %esp,%ebp
8010394d:	83 ec 18             	sub    $0x18,%esp
	int i = 0;
80103950:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int check = 0;
80103957:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	for(i = 0; i<SHM_MAXNUM; i++)
8010395e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103965:	eb 42                	jmp    801039a9 <shm_find+0x5f>
	{
		check = strncmp(&(shm_arr[i].name[0]), str, sizeof(shm_arr[i].name));
80103967:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010396a:	89 c2                	mov    %eax,%edx
8010396c:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
80103973:	89 c2                	mov    %eax,%edx
80103975:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
8010397c:	29 d0                	sub    %edx,%eax
8010397e:	05 80 53 11 80       	add    $0x80115380,%eax
80103983:	83 c0 04             	add    $0x4,%eax
80103986:	83 ec 04             	sub    $0x4,%esp
80103989:	6a 10                	push   $0x10
8010398b:	ff 75 08             	pushl  0x8(%ebp)
8010398e:	50                   	push   %eax
8010398f:	e8 b1 34 00 00       	call   80106e45 <strncmp>
80103994:	83 c4 10             	add    $0x10,%esp
80103997:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if(check == 0)
8010399a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010399e:	75 05                	jne    801039a5 <shm_find+0x5b>
			return i;
801039a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039a3:	eb 0f                	jmp    801039b4 <shm_find+0x6a>
int shm_find(const char* str)
{
	int i = 0;
	int check = 0;

	for(i = 0; i<SHM_MAXNUM; i++)
801039a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039a9:	83 7d f4 1f          	cmpl   $0x1f,-0xc(%ebp)
801039ad:	7e b8                	jle    80103967 <shm_find+0x1d>
	{
		check = strncmp(&(shm_arr[i].name[0]), str, sizeof(shm_arr[i].name));
		if(check == 0)
			return i;
	}
	return -1;
801039af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801039b4:	c9                   	leave  
801039b5:	c3                   	ret    

801039b6 <shm_findFree>:

//finds first free block in shm_arr
int shm_findFree()
{
801039b6:	55                   	push   %ebp
801039b7:	89 e5                	mov    %esp,%ebp
801039b9:	83 ec 18             	sub    $0x18,%esp
	int i = 0;
801039bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	char* tempSearch = "DNE";
801039c3:	c7 45 f0 e4 a5 10 80 	movl   $0x8010a5e4,-0x10(%ebp)
	int check = 0;
801039ca:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	for(i = 0; i<SHM_MAXNUM; i++)
801039d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039d8:	eb 42                	jmp    80103a1c <shm_findFree+0x66>
	{
		check = strncmp(&(shm_arr[i].name[0]), tempSearch, sizeof(shm_arr[i].name));
801039da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039dd:	89 c2                	mov    %eax,%edx
801039df:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
801039e6:	89 c2                	mov    %eax,%edx
801039e8:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
801039ef:	29 d0                	sub    %edx,%eax
801039f1:	05 80 53 11 80       	add    $0x80115380,%eax
801039f6:	83 c0 04             	add    $0x4,%eax
801039f9:	83 ec 04             	sub    $0x4,%esp
801039fc:	6a 10                	push   $0x10
801039fe:	ff 75 f0             	pushl  -0x10(%ebp)
80103a01:	50                   	push   %eax
80103a02:	e8 3e 34 00 00       	call   80106e45 <strncmp>
80103a07:	83 c4 10             	add    $0x10,%esp
80103a0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if(check == 0)
80103a0d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103a11:	75 05                	jne    80103a18 <shm_findFree+0x62>
			return i;
80103a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a16:	eb 0f                	jmp    80103a27 <shm_findFree+0x71>
{
	int i = 0;
	char* tempSearch = "DNE";
	int check = 0;

	for(i = 0; i<SHM_MAXNUM; i++)
80103a18:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a1c:	83 7d f4 1f          	cmpl   $0x1f,-0xc(%ebp)
80103a20:	7e b8                	jle    801039da <shm_findFree+0x24>
	{
		check = strncmp(&(shm_arr[i].name[0]), tempSearch, sizeof(shm_arr[i].name));
		if(check == 0)
			return i;
	}
	return -1;
80103a22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103a27:	c9                   	leave  
80103a28:	c3                   	ret    

80103a29 <procSHM_nameFind>:
//Each process stores SHM name, PA, and VA of SHM for each process in individual arrays. The indicies of these arrays correspond to
//each other. For example, The name for proc->shm_name[i] has a physical address that corresponds to proc->shm_phys[i], and a virtual
//address that corresponds to proc->shm_vir[i]. Therefore, if the name is found in one array, we can use that index that it was found
//at to get the physical address and virtual address for the corresponding name by simply using the same index value.
int procSHM_nameFind(const char* str)
{
80103a29:	55                   	push   %ebp
80103a2a:	89 e5                	mov    %esp,%ebp
80103a2c:	83 ec 18             	sub    $0x18,%esp
	int i = 0;
80103a2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int check = 0;
80103a36:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	for(i = 0; i<SHM_MAXNUM; i++)
80103a3d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a44:	eb 37                	jmp    80103a7d <procSHM_nameFind+0x54>
	{
		check = strncmp(&(proc->shm_name[i].name[0]), str, sizeof(proc->shm_name[i].name));
80103a46:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103a4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a4f:	83 c2 07             	add    $0x7,%edx
80103a52:	c1 e2 04             	shl    $0x4,%edx
80103a55:	01 d0                	add    %edx,%eax
80103a57:	83 c0 0c             	add    $0xc,%eax
80103a5a:	83 ec 04             	sub    $0x4,%esp
80103a5d:	6a 10                	push   $0x10
80103a5f:	ff 75 08             	pushl  0x8(%ebp)
80103a62:	50                   	push   %eax
80103a63:	e8 dd 33 00 00       	call   80106e45 <strncmp>
80103a68:	83 c4 10             	add    $0x10,%esp
80103a6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if(check == 0)
80103a6e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a72:	75 05                	jne    80103a79 <procSHM_nameFind+0x50>
			return i;
80103a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a77:	eb 0f                	jmp    80103a88 <procSHM_nameFind+0x5f>
int procSHM_nameFind(const char* str)
{
	int i = 0;
	int check = 0;

	for(i = 0; i<SHM_MAXNUM; i++)
80103a79:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a7d:	83 7d f4 1f          	cmpl   $0x1f,-0xc(%ebp)
80103a81:	7e c3                	jle    80103a46 <procSHM_nameFind+0x1d>
	{
		check = strncmp(&(proc->shm_name[i].name[0]), str, sizeof(proc->shm_name[i].name));
		if(check == 0)
			return i;
	}
	return -1;
80103a83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103a88:	c9                   	leave  
80103a89:	c3                   	ret    

80103a8a <procSHM_findFree>:

//finds first free block in specified the proc->shm_name[] array. Used when giving a process access to an SHM
//returns index value to be used by caller to place SHM info for the process's mapped SHM Name, SHM PA, and SHM VA
//in that index
int procSHM_findFree()
{
80103a8a:	55                   	push   %ebp
80103a8b:	89 e5                	mov    %esp,%ebp
80103a8d:	83 ec 18             	sub    $0x18,%esp
	int i = 0;
80103a90:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	char* tempSearch = "DNE";
80103a97:	c7 45 f0 e4 a5 10 80 	movl   $0x8010a5e4,-0x10(%ebp)
	int check = 0;
80103a9e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	for(i = 0; i<SHM_MAXNUM; i++)
80103aa5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103aac:	eb 37                	jmp    80103ae5 <procSHM_findFree+0x5b>
	{
		check = strncmp(&(proc->shm_name[i].name[0]), tempSearch, sizeof(proc->shm_name[i].name));
80103aae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103ab4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ab7:	83 c2 07             	add    $0x7,%edx
80103aba:	c1 e2 04             	shl    $0x4,%edx
80103abd:	01 d0                	add    %edx,%eax
80103abf:	83 c0 0c             	add    $0xc,%eax
80103ac2:	83 ec 04             	sub    $0x4,%esp
80103ac5:	6a 10                	push   $0x10
80103ac7:	ff 75 f0             	pushl  -0x10(%ebp)
80103aca:	50                   	push   %eax
80103acb:	e8 75 33 00 00       	call   80106e45 <strncmp>
80103ad0:	83 c4 10             	add    $0x10,%esp
80103ad3:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if(check == 0)
80103ad6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ada:	75 05                	jne    80103ae1 <procSHM_findFree+0x57>
			return i;
80103adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103adf:	eb 0f                	jmp    80103af0 <procSHM_findFree+0x66>
{
	int i = 0;
	char* tempSearch = "DNE";
	int check = 0;

	for(i = 0; i<SHM_MAXNUM; i++)
80103ae1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ae5:	83 7d f4 1f          	cmpl   $0x1f,-0xc(%ebp)
80103ae9:	7e c3                	jle    80103aae <procSHM_findFree+0x24>
	{
		check = strncmp(&(proc->shm_name[i].name[0]), tempSearch, sizeof(proc->shm_name[i].name));
		if(check == 0)
			return i;
	}
	return -1;
80103aeb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103af0:	c9                   	leave  
80103af1:	c3                   	ret    

80103af2 <deallocshm>:
//If the SHM was at the end of the calling process, the process size would simply shrink after dereference.
//If the SHM was somewhere in the middle of the calling process, all of the virtual address spaces would be remapped to exclude the 
//SHM region, and the process size would shrink.
//Remapping causes random problems that would need more time for debugging.
int deallocshm(pde_t * pgdir, uint oldsz, uint newsz, int ref, uint shmMap)
{
80103af2:	55                   	push   %ebp
80103af3:	89 e5                	mov    %esp,%ebp
80103af5:	83 ec 28             	sub    $0x28,%esp
		return 0;
	}
	return -1
*/

	pte_t *pte = 0, *SHMpte = 0;
80103af8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103aff:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	uint pa;
	int a = 0;
80103b06:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	
	if (newsz >= oldsz)
80103b0d:	8b 45 10             	mov    0x10(%ebp),%eax
80103b10:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b13:	72 08                	jb     80103b1d <deallocshm+0x2b>
		return oldsz;
80103b15:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b18:	e9 0a 03 00 00       	jmp    80103e27 <deallocshm+0x335>

	SHMpte = walkpgdir(pgdir, (char*)proc->shm_vir[ref], 0); //finds PTE for SHM region in page table
80103b1d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103b23:	8b 55 14             	mov    0x14(%ebp),%edx
80103b26:	81 c2 9c 00 00 00    	add    $0x9c,%edx
80103b2c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80103b30:	83 ec 04             	sub    $0x4,%esp
80103b33:	6a 00                	push   $0x0
80103b35:	50                   	push   %eax
80103b36:	ff 75 08             	pushl  0x8(%ebp)
80103b39:	e8 2a 0e 00 00       	call   80104968 <walkpgdir>
80103b3e:	83 c4 10             	add    $0x10,%esp
80103b41:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(!SHMpte)
80103b44:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b48:	75 1a                	jne    80103b64 <deallocshm+0x72>
	{
		cprintf("\nCannot Deallocate Region. PTE Reference doesn't exist\n");
80103b4a:	83 ec 0c             	sub    $0xc,%esp
80103b4d:	68 e8 a5 10 80       	push   $0x8010a5e8
80103b52:	e8 6f c8 ff ff       	call   801003c6 <cprintf>
80103b57:	83 c4 10             	add    $0x10,%esp
		return -1;
80103b5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103b5f:	e9 c3 02 00 00       	jmp    80103e27 <deallocshm+0x335>
	}

	if(shmMap == 0) //if only process is dereferencing, physical memory still stays
80103b64:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
80103b68:	0f 85 c3 01 00 00    	jne    80103d31 <deallocshm+0x23f>
	{			
		if(proc->shm_vir[ref] == (proc->sz - PGSIZE)) //if last page of process
80103b6e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103b74:	8b 55 14             	mov    0x14(%ebp),%edx
80103b77:	81 c2 9c 00 00 00    	add    $0x9c,%edx
80103b7d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80103b81:	89 c2                	mov    %eax,%edx
80103b83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103b89:	8b 00                	mov    (%eax),%eax
80103b8b:	2d 00 10 00 00       	sub    $0x1000,%eax
80103b90:	39 c2                	cmp    %eax,%edx
80103b92:	0f 85 8a 00 00 00    	jne    80103c22 <deallocshm+0x130>
		{
			cprintf("\nOnly removing reference from end of process and remapping VM.\n");
80103b98:	83 ec 0c             	sub    $0xc,%esp
80103b9b:	68 20 a6 10 80       	push   $0x8010a620
80103ba0:	e8 21 c8 ff ff       	call   801003c6 <cprintf>
80103ba5:	83 c4 10             	add    $0x10,%esp

			*SHMpte = 0;
80103ba8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

			proc->shm_vir[ref]  = 0;
80103bb1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103bb7:	8b 55 14             	mov    0x14(%ebp),%edx
80103bba:	81 c2 9c 00 00 00    	add    $0x9c,%edx
80103bc0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80103bc7:	00 
			proc->shm_phys[ref] = 0;
80103bc8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103bce:	8b 55 14             	mov    0x14(%ebp),%edx
80103bd1:	81 c2 bc 00 00 00    	add    $0xbc,%edx
80103bd7:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80103bde:	00 
			safestrcpy(proc->shm_name[ref].name, "DNE", sizeof(proc->shm_name[ref].name));
80103bdf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103be5:	8b 55 14             	mov    0x14(%ebp),%edx
80103be8:	83 c2 07             	add    $0x7,%edx
80103beb:	c1 e2 04             	shl    $0x4,%edx
80103bee:	01 d0                	add    %edx,%eax
80103bf0:	83 c0 0c             	add    $0xc,%eax
80103bf3:	83 ec 04             	sub    $0x4,%esp
80103bf6:	6a 10                	push   $0x10
80103bf8:	68 e4 a5 10 80       	push   $0x8010a5e4
80103bfd:	50                   	push   %eax
80103bfe:	e8 f0 32 00 00       	call   80106ef3 <safestrcpy>
80103c03:	83 c4 10             	add    $0x10,%esp
			proc->sz = (proc->sz) - PGSIZE;
80103c06:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103c0c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103c13:	8b 12                	mov    (%edx),%edx
80103c15:	81 ea 00 10 00 00    	sub    $0x1000,%edx
80103c1b:	89 10                	mov    %edx,(%eax)
80103c1d:	e9 02 02 00 00       	jmp    80103e24 <deallocshm+0x332>
		}

		else //if SHM is in middle of process
		{	
			//virtual addresses after SHM are going to be updated to overwrite the VA of the SHM Region...moving VA up a page
			cprintf("\nOnly removing reference from middle of process and remapping VM.\n");
80103c22:	83 ec 0c             	sub    $0xc,%esp
80103c25:	68 60 a6 10 80       	push   $0x8010a660
80103c2a:	e8 97 c7 ff ff       	call   801003c6 <cprintf>
80103c2f:	83 c4 10             	add    $0x10,%esp
			
			*SHMpte = 0;
80103c32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c35:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

			for(a = proc->shm_vir[ref]+PGSIZE ; a < proc->sz ; a += PGSIZE)
80103c3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103c41:	8b 55 14             	mov    0x14(%ebp),%edx
80103c44:	81 c2 9c 00 00 00    	add    $0x9c,%edx
80103c4a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80103c4e:	05 00 10 00 00       	add    $0x1000,%eax
80103c53:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c56:	eb 59                	jmp    80103cb1 <deallocshm+0x1bf>
			{
				pte = walkpgdir(pgdir, (char*)a, 0);
80103c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5b:	83 ec 04             	sub    $0x4,%esp
80103c5e:	6a 00                	push   $0x0
80103c60:	50                   	push   %eax
80103c61:	ff 75 08             	pushl  0x8(%ebp)
80103c64:	e8 ff 0c 00 00       	call   80104968 <walkpgdir>
80103c69:	83 c4 10             	add    $0x10,%esp
80103c6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
				if (!pte)
80103c6f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c73:	75 07                	jne    80103c7c <deallocshm+0x18a>
					a += (NPTENTRIES - 1) * PGSIZE;
80103c75:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
				pa = PTE_ADDR(*pte);
80103c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c7f:	8b 00                	mov    (%eax),%eax
80103c81:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80103c86:	89 45 e8             	mov    %eax,-0x18(%ebp)

				mappages(pgdir, (char*)(a-PGSIZE), PGSIZE, pa, PTE_W | PTE_U);
80103c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c8c:	2d 00 10 00 00       	sub    $0x1000,%eax
80103c91:	83 ec 0c             	sub    $0xc,%esp
80103c94:	6a 06                	push   $0x6
80103c96:	ff 75 e8             	pushl  -0x18(%ebp)
80103c99:	68 00 10 00 00       	push   $0x1000
80103c9e:	50                   	push   %eax
80103c9f:	ff 75 08             	pushl  0x8(%ebp)
80103ca2:	e8 61 0d 00 00       	call   80104a08 <mappages>
80103ca7:	83 c4 20             	add    $0x20,%esp
			//virtual addresses after SHM are going to be updated to overwrite the VA of the SHM Region...moving VA up a page
			cprintf("\nOnly removing reference from middle of process and remapping VM.\n");
			
			*SHMpte = 0;

			for(a = proc->shm_vir[ref]+PGSIZE ; a < proc->sz ; a += PGSIZE)
80103caa:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80103cb1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103cb7:	8b 10                	mov    (%eax),%edx
80103cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cbc:	39 c2                	cmp    %eax,%edx
80103cbe:	77 98                	ja     80103c58 <deallocshm+0x166>
					a += (NPTENTRIES - 1) * PGSIZE;
				pa = PTE_ADDR(*pte);

				mappages(pgdir, (char*)(a-PGSIZE), PGSIZE, pa, PTE_W | PTE_U);
			}
			proc->sz = ((proc->sz) - PGSIZE);
80103cc0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103cc6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103ccd:	8b 12                	mov    (%edx),%edx
80103ccf:	81 ea 00 10 00 00    	sub    $0x1000,%edx
80103cd5:	89 10                	mov    %edx,(%eax)

			proc->shm_vir[ref] = 0;
80103cd7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103cdd:	8b 55 14             	mov    0x14(%ebp),%edx
80103ce0:	81 c2 9c 00 00 00    	add    $0x9c,%edx
80103ce6:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80103ced:	00 
			proc->shm_phys[ref] = 0;
80103cee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103cf4:	8b 55 14             	mov    0x14(%ebp),%edx
80103cf7:	81 c2 bc 00 00 00    	add    $0xbc,%edx
80103cfd:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80103d04:	00 
			safestrcpy(proc->shm_name[ref].name, "DNE", sizeof(proc->shm_name[ref].name));
80103d05:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103d0b:	8b 55 14             	mov    0x14(%ebp),%edx
80103d0e:	83 c2 07             	add    $0x7,%edx
80103d11:	c1 e2 04             	shl    $0x4,%edx
80103d14:	01 d0                	add    %edx,%eax
80103d16:	83 c0 0c             	add    $0xc,%eax
80103d19:	83 ec 04             	sub    $0x4,%esp
80103d1c:	6a 10                	push   $0x10
80103d1e:	68 e4 a5 10 80       	push   $0x8010a5e4
80103d23:	50                   	push   %eax
80103d24:	e8 ca 31 00 00       	call   80106ef3 <safestrcpy>
80103d29:	83 c4 10             	add    $0x10,%esp
80103d2c:	e9 f3 00 00 00       	jmp    80103e24 <deallocshm+0x332>
		}
	}

	else if (((*pte & PTE_P) != 0) && (shmMap != 0)) //if last reference and removing physical memory
80103d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d34:	8b 00                	mov    (%eax),%eax
80103d36:	83 e0 01             	and    $0x1,%eax
80103d39:	85 c0                	test   %eax,%eax
80103d3b:	0f 84 e3 00 00 00    	je     80103e24 <deallocshm+0x332>
80103d41:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
80103d45:	0f 84 d9 00 00 00    	je     80103e24 <deallocshm+0x332>
	{
		cprintf("\nRemoving Physical Memory given to SHM\n");
80103d4b:	83 ec 0c             	sub    $0xc,%esp
80103d4e:	68 a4 a6 10 80       	push   $0x8010a6a4
80103d53:	e8 6e c6 ff ff       	call   801003c6 <cprintf>
80103d58:	83 c4 10             	add    $0x10,%esp
		if(proc->shm_vir[ref] == (proc->sz - PGSIZE)) //if last page of process
80103d5b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103d61:	8b 55 14             	mov    0x14(%ebp),%edx
80103d64:	81 c2 9c 00 00 00    	add    $0x9c,%edx
80103d6a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80103d6e:	89 c2                	mov    %eax,%edx
80103d70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103d76:	8b 00                	mov    (%eax),%eax
80103d78:	2d 00 10 00 00       	sub    $0x1000,%eax
80103d7d:	39 c2                	cmp    %eax,%edx
80103d7f:	0f 85 8f 00 00 00    	jne    80103e14 <deallocshm+0x322>
		{
			cprintf("\nRemoving Physical Mapping and reference from end process.\n");
80103d85:	83 ec 0c             	sub    $0xc,%esp
80103d88:	68 cc a6 10 80       	push   $0x8010a6cc
80103d8d:	e8 34 c6 ff ff       	call   801003c6 <cprintf>
80103d92:	83 c4 10             	add    $0x10,%esp
			
			*SHMpte = 0;
80103d95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

			char *v = p2v(shmMap); //changes PA to a VA that kernel can read. different VA from process VA
80103d9e:	83 ec 0c             	sub    $0xc,%esp
80103da1:	ff 75 18             	pushl  0x18(%ebp)
80103da4:	e8 c3 fa ff ff       	call   8010386c <p2v>
80103da9:	83 c4 10             	add    $0x10,%esp
80103dac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			kfree(v);//frees memory
80103daf:	83 ec 0c             	sub    $0xc,%esp
80103db2:	ff 75 e4             	pushl  -0x1c(%ebp)
80103db5:	e8 13 ee ff ff       	call   80102bcd <kfree>
80103dba:	83 c4 10             	add    $0x10,%esp

			proc->shm_vir[ref] = 0;
80103dbd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103dc3:	8b 55 14             	mov    0x14(%ebp),%edx
80103dc6:	81 c2 9c 00 00 00    	add    $0x9c,%edx
80103dcc:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80103dd3:	00 
			proc->shm_phys[ref] = 0;
80103dd4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103dda:	8b 55 14             	mov    0x14(%ebp),%edx
80103ddd:	81 c2 bc 00 00 00    	add    $0xbc,%edx
80103de3:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80103dea:	00 
			safestrcpy(proc->shm_name[ref].name, "DNE", sizeof(proc->shm_name[ref].name));
80103deb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103df1:	8b 55 14             	mov    0x14(%ebp),%edx
80103df4:	83 c2 07             	add    $0x7,%edx
80103df7:	c1 e2 04             	shl    $0x4,%edx
80103dfa:	01 d0                	add    %edx,%eax
80103dfc:	83 c0 0c             	add    $0xc,%eax
80103dff:	83 ec 04             	sub    $0x4,%esp
80103e02:	6a 10                	push   $0x10
80103e04:	68 e4 a5 10 80       	push   $0x8010a5e4
80103e09:	50                   	push   %eax
80103e0a:	e8 e4 30 00 00       	call   80106ef3 <safestrcpy>
80103e0f:	83 c4 10             	add    $0x10,%esp
80103e12:	eb 10                	jmp    80103e24 <deallocshm+0x332>
		}

		else//if SHM is in middle of process
		{
			cprintf("\nRemoving Physical Mapping and reference from middle process.\n");
80103e14:	83 ec 0c             	sub    $0xc,%esp
80103e17:	68 08 a7 10 80       	push   $0x8010a708
80103e1c:	e8 a5 c5 ff ff       	call   801003c6 <cprintf>
80103e21:	83 c4 10             	add    $0x10,%esp
		}
	}
	return newsz;
80103e24:	8b 45 10             	mov    0x10(%ebp),%eax

}
80103e27:	c9                   	leave  
80103e28:	c3                   	ret    

80103e29 <allocshm>:
//it also updates an array within the calling process that stores the virtual and 
//physical addresses within it that correspond to shared memory regions
//mapType is used to specify which type of allocation is wanted. If shmMap==0, map to new physical address.
//If shmMap != 0, the mapType will be the value of the physical location of SHM being passed into function
int allocshm(pde_t * pgdir, uint oldsz, uint newsz, int ref, uint shmMap)
{
80103e29:	55                   	push   %ebp
80103e2a:	89 e5                	mov    %esp,%ebp
80103e2c:	53                   	push   %ebx
80103e2d:	83 ec 14             	sub    $0x14,%esp
	char *mem;
	uint a;

	if (newsz >= KERNBASE)
80103e30:	8b 45 10             	mov    0x10(%ebp),%eax
80103e33:	85 c0                	test   %eax,%eax
80103e35:	79 0a                	jns    80103e41 <allocshm+0x18>
		return 0;
80103e37:	b8 00 00 00 00       	mov    $0x0,%eax
80103e3c:	e9 3a 01 00 00       	jmp    80103f7b <allocshm+0x152>
	if (newsz < oldsz)
80103e41:	8b 45 10             	mov    0x10(%ebp),%eax
80103e44:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103e47:	73 08                	jae    80103e51 <allocshm+0x28>
		return oldsz;
80103e49:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e4c:	e9 2a 01 00 00       	jmp    80103f7b <allocshm+0x152>

	a = PGROUNDUP(oldsz); //sets a to top of page
80103e51:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e54:	05 ff 0f 00 00       	add    $0xfff,%eax
80103e59:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80103e5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cprintf("\nStarting Point of Grown Region = %d\n", a);
80103e61:	83 ec 08             	sub    $0x8,%esp
80103e64:	ff 75 f0             	pushl  -0x10(%ebp)
80103e67:	68 48 a7 10 80       	push   $0x8010a748
80103e6c:	e8 55 c5 ff ff       	call   801003c6 <cprintf>
80103e71:	83 c4 10             	add    $0x10,%esp
	//loops mapping va space to pa until the wanted new size is achieved
	for (; a < newsz; a += PGSIZE) 
80103e74:	e9 ae 00 00 00       	jmp    80103f27 <allocshm+0xfe>
	{
		if(shmMap == 0)
80103e79:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
80103e7d:	75 7f                	jne    80103efe <allocshm+0xd5>
		{
			mem = kalloc(); //allocates a page of unmapped data and returns pointer to physical address of page
80103e7f:	e8 e6 ed ff ff       	call   80102c6a <kalloc>
80103e84:	89 45 f4             	mov    %eax,-0xc(%ebp)
			if (mem == 0) 
80103e87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e8b:	75 32                	jne    80103ebf <allocshm+0x96>
			{
				cprintf("allocuvm out of memory\n");
80103e8d:	83 ec 0c             	sub    $0xc,%esp
80103e90:	68 6e a7 10 80       	push   $0x8010a76e
80103e95:	e8 2c c5 ff ff       	call   801003c6 <cprintf>
80103e9a:	83 c4 10             	add    $0x10,%esp
				deallocshm(pgdir, newsz, oldsz, 0, 0);
80103e9d:	83 ec 0c             	sub    $0xc,%esp
80103ea0:	6a 00                	push   $0x0
80103ea2:	6a 00                	push   $0x0
80103ea4:	ff 75 0c             	pushl  0xc(%ebp)
80103ea7:	ff 75 10             	pushl  0x10(%ebp)
80103eaa:	ff 75 08             	pushl  0x8(%ebp)
80103ead:	e8 40 fc ff ff       	call   80103af2 <deallocshm>
80103eb2:	83 c4 20             	add    $0x20,%esp
				return 0;
80103eb5:	b8 00 00 00 00       	mov    $0x0,%eax
80103eba:	e9 bc 00 00 00       	jmp    80103f7b <allocshm+0x152>
			}
			memset(mem, 0, PGSIZE);
80103ebf:	83 ec 04             	sub    $0x4,%esp
80103ec2:	68 00 10 00 00       	push   $0x1000
80103ec7:	6a 00                	push   $0x0
80103ec9:	ff 75 f4             	pushl  -0xc(%ebp)
80103ecc:	e8 1f 2e 00 00       	call   80106cf0 <memset>
80103ed1:	83 c4 10             	add    $0x10,%esp
			mappages(pgdir, (char *)a, PGSIZE, v2p(mem), PTE_W | PTE_U); 
80103ed4:	83 ec 0c             	sub    $0xc,%esp
80103ed7:	ff 75 f4             	pushl  -0xc(%ebp)
80103eda:	e8 80 f9 ff ff       	call   8010385f <v2p>
80103edf:	83 c4 10             	add    $0x10,%esp
80103ee2:	89 c2                	mov    %eax,%edx
80103ee4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ee7:	83 ec 0c             	sub    $0xc,%esp
80103eea:	6a 06                	push   $0x6
80103eec:	52                   	push   %edx
80103eed:	68 00 10 00 00       	push   $0x1000
80103ef2:	50                   	push   %eax
80103ef3:	ff 75 08             	pushl  0x8(%ebp)
80103ef6:	e8 0d 0b 00 00       	call   80104a08 <mappages>
80103efb:	83 c4 20             	add    $0x20,%esp
			//maps virtual address of new pages to physical address just allocated
		}

		if(shmMap !=0)
80103efe:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
80103f02:	74 1c                	je     80103f20 <allocshm+0xf7>
		{
			mappages(pgdir, (char*)a, PGSIZE, shmMap, PTE_W | PTE_U); //mapping range of VA to previously existing PA, creating SHM
80103f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f07:	83 ec 0c             	sub    $0xc,%esp
80103f0a:	6a 06                	push   $0x6
80103f0c:	ff 75 18             	pushl  0x18(%ebp)
80103f0f:	68 00 10 00 00       	push   $0x1000
80103f14:	50                   	push   %eax
80103f15:	ff 75 08             	pushl  0x8(%ebp)
80103f18:	e8 eb 0a 00 00       	call   80104a08 <mappages>
80103f1d:	83 c4 20             	add    $0x20,%esp
		return oldsz;

	a = PGROUNDUP(oldsz); //sets a to top of page
	cprintf("\nStarting Point of Grown Region = %d\n", a);
	//loops mapping va space to pa until the wanted new size is achieved
	for (; a < newsz; a += PGSIZE) 
80103f20:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
80103f27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f2a:	3b 45 10             	cmp    0x10(%ebp),%eax
80103f2d:	0f 82 46 ff ff ff    	jb     80103e79 <allocshm+0x50>
			mappages(pgdir, (char*)a, PGSIZE, shmMap, PTE_W | PTE_U); //mapping range of VA to previously existing PA, creating SHM
		}
	}

	//proc->shm_vir[ref] = (char*)(a-PGSIZE); //works, but want to try something else
	proc->shm_vir[ref] = (a - (newsz - oldsz));
80103f33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103f39:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f3c:	89 d1                	mov    %edx,%ecx
80103f3e:	2b 4d 10             	sub    0x10(%ebp),%ecx
80103f41:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f44:	01 ca                	add    %ecx,%edx
80103f46:	89 d1                	mov    %edx,%ecx
80103f48:	8b 55 14             	mov    0x14(%ebp),%edx
80103f4b:	81 c2 9c 00 00 00    	add    $0x9c,%edx
80103f51:	89 4c 90 0c          	mov    %ecx,0xc(%eax,%edx,4)

	//we want count number for va
	//pgsize added already after for loop ended
	//need to subtract pgsize for proper va pointer to top of SHM page
	proc->shm_phys[ref] = v2p(mem);
80103f55:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80103f5c:	83 ec 0c             	sub    $0xc,%esp
80103f5f:	ff 75 f4             	pushl  -0xc(%ebp)
80103f62:	e8 f8 f8 ff ff       	call   8010385f <v2p>
80103f67:	83 c4 10             	add    $0x10,%esp
80103f6a:	89 c2                	mov    %eax,%edx
80103f6c:	8b 45 14             	mov    0x14(%ebp),%eax
80103f6f:	05 bc 00 00 00       	add    $0xbc,%eax
80103f74:	89 54 83 0c          	mov    %edx,0xc(%ebx,%eax,4)
	//cprintf("Process SHM Num = %d\n", ref);
	//cprintf("SHM pgdir = %p\n", pgdir);
	//cprintf("SHM Physical Address = %p\n", proc->shm_phys[ref]);
	//cprintf("SHM Virtual Address = %p\n", proc->shm_vir[ref]);

	return newsz;
80103f78:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103f7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103f7e:	c9                   	leave  
80103f7f:	c3                   	ret    

80103f80 <shm_alloc>:
//picks the appropriate function to call based on whether it wants to grow the
//process or shrink it. Ref is used to pass in the array value of the SHM tracking
//within the process so that it can update the proper values for the processes's
//future reference
int shm_alloc(int n, int ref, uint shmMap)
{
80103f80:	55                   	push   %ebp
80103f81:	89 e5                	mov    %esp,%ebp
80103f83:	83 ec 18             	sub    $0x18,%esp
	uint sz;

	sz = proc->sz;
80103f86:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103f8c:	8b 00                	mov    (%eax),%eax
80103f8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	//cprintf("\nOriginal Process Size = %d\n", sz);
	if (n > 0) 
80103f91:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103f95:	7e 37                	jle    80103fce <shm_alloc+0x4e>
	{
		if ((sz = allocshm(proc->pgdir, sz, sz + n, ref, shmMap)) == 0)
80103f97:	8b 55 08             	mov    0x8(%ebp),%edx
80103f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f9d:	01 c2                	add    %eax,%edx
80103f9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103fa5:	8b 40 04             	mov    0x4(%eax),%eax
80103fa8:	83 ec 0c             	sub    $0xc,%esp
80103fab:	ff 75 10             	pushl  0x10(%ebp)
80103fae:	ff 75 0c             	pushl  0xc(%ebp)
80103fb1:	52                   	push   %edx
80103fb2:	ff 75 f4             	pushl  -0xc(%ebp)
80103fb5:	50                   	push   %eax
80103fb6:	e8 6e fe ff ff       	call   80103e29 <allocshm>
80103fbb:	83 c4 20             	add    $0x20,%esp
80103fbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103fc1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103fc5:	75 44                	jne    8010400b <shm_alloc+0x8b>
			return -1;
80103fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fcc:	eb 5f                	jmp    8010402d <shm_alloc+0xad>
	} 
	else if (n < 0) 
80103fce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103fd2:	79 37                	jns    8010400b <shm_alloc+0x8b>
	{
		if ((sz = deallocshm(proc->pgdir, sz, sz + n, ref, shmMap)) == -1)
80103fd4:	8b 55 08             	mov    0x8(%ebp),%edx
80103fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fda:	01 c2                	add    %eax,%edx
80103fdc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103fe2:	8b 40 04             	mov    0x4(%eax),%eax
80103fe5:	83 ec 0c             	sub    $0xc,%esp
80103fe8:	ff 75 10             	pushl  0x10(%ebp)
80103feb:	ff 75 0c             	pushl  0xc(%ebp)
80103fee:	52                   	push   %edx
80103fef:	ff 75 f4             	pushl  -0xc(%ebp)
80103ff2:	50                   	push   %eax
80103ff3:	e8 fa fa ff ff       	call   80103af2 <deallocshm>
80103ff8:	83 c4 20             	add    $0x20,%esp
80103ffb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ffe:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
80104002:	75 07                	jne    8010400b <shm_alloc+0x8b>
			return -1;
80104004:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104009:	eb 22                	jmp    8010402d <shm_alloc+0xad>
	}
	proc->sz = sz;
8010400b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104011:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104014:	89 10                	mov    %edx,(%eax)
	//cprintf("New Process Size = %d\n", sz);
	switchuvm(proc);
80104016:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010401c:	83 ec 0c             	sub    $0xc,%esp
8010401f:	50                   	push   %eax
80104020:	e8 43 5b 00 00       	call   80109b68 <switchuvm>
80104025:	83 c4 10             	add    $0x10,%esp
	return 0;
80104028:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010402d:	c9                   	leave  
8010402e:	c3                   	ret    

8010402f <shm_assign>:

//assigns an already existing SHM to a calling process. It searches through the page directory
//that was sent in and trys to find the matching VA location of the PA sent in.
//the VA is then assigned to that PA 
int shm_assign(pde_t* pgdir, uint sz, uint physLoc) //really only used in fork() maybe rename shm_inherit()
{
8010402f:	55                   	push   %ebp
80104030:	89 e5                	mov    %esp,%ebp
80104032:	83 ec 18             	sub    $0x18,%esp
	pte_t * pte;
	uint pa;
	//char* virLoc = 0;
	int found = 0;
80104035:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	int i = 0;
8010403c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	for(i = 0; i<sz; i += PGSIZE)
80104043:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010404a:	eb 3c                	jmp    80104088 <shm_assign+0x59>
	{
		pte = walkpgdir(pgdir, (void*)i, 0);
8010404c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010404f:	83 ec 04             	sub    $0x4,%esp
80104052:	6a 00                	push   $0x0
80104054:	50                   	push   %eax
80104055:	ff 75 08             	pushl  0x8(%ebp)
80104058:	e8 0b 09 00 00       	call   80104968 <walkpgdir>
8010405d:	83 c4 10             	add    $0x10,%esp
80104060:	89 45 ec             	mov    %eax,-0x14(%ebp)
		pa = PTE_ADDR(*pte);
80104063:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104066:	8b 00                	mov    (%eax),%eax
80104068:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010406d:	89 45 e8             	mov    %eax,-0x18(%ebp)
		if(pa == physLoc)
80104070:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104073:	3b 45 10             	cmp    0x10(%ebp),%eax
80104076:	75 09                	jne    80104081 <shm_assign+0x52>
		{
			found = 1;
80104078:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
			break;
8010407f:	eb 0f                	jmp    80104090 <shm_assign+0x61>
	uint pa;
	//char* virLoc = 0;
	int found = 0;

	int i = 0;
	for(i = 0; i<sz; i += PGSIZE)
80104081:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
80104088:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010408b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010408e:	72 bc                	jb     8010404c <shm_assign+0x1d>
			found = 1;
			break;
		}
	}
	
	if(found == 1)
80104090:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80104094:	75 15                	jne    801040ab <shm_assign+0x7c>
	{	
		cprintf("\nFound SHM Phys in Mapping...making VA\n");
80104096:	83 ec 0c             	sub    $0xc,%esp
80104099:	68 88 a7 10 80       	push   $0x8010a788
8010409e:	e8 23 c3 ff ff       	call   801003c6 <cprintf>
801040a3:	83 c4 10             	add    $0x10,%esp
		//cprintf("SHM Proc PA = %d\n", pa);
		//cprintf("SHM Proc VA = %d\n", i);
		//not finding because fork is making new physical mem for SHM within child...Needs fixing
		
		return i;
801040a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040a9:	eb 05                	jmp    801040b0 <shm_assign+0x81>
	}

	//cprintf("\nSHM Phys in NOT Found Mapping\n");
	return -1;
801040ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801040b0:	c9                   	leave  
801040b1:	c3                   	ret    

801040b2 <shm_arr_findPA>:
//a new page for the process. Instead, it will map the following virtual address spaces to the SHM Region.
//used in deallocuvm to skip freeing physical addresses of SHM regions
//added functionality to either add or subtract refrence count when using function because functions calling this function
//don't have access to the shm tracking array
uint shm_arr_findPA(uint pa, int refChange)
{
801040b2:	55                   	push   %ebp
801040b3:	89 e5                	mov    %esp,%ebp
801040b5:	83 ec 10             	sub    $0x10,%esp
	int i = 0;
801040b8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for(i = 0; i<SHM_MAXNUM; i++)
801040bf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801040c6:	eb 70                	jmp    80104138 <shm_arr_findPA+0x86>
	{
		if(pa == shm_arr[i].shmPhys)
801040c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801040cb:	c1 e0 02             	shl    $0x2,%eax
801040ce:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801040d5:	29 c2                	sub    %eax,%edx
801040d7:	89 d0                	mov    %edx,%eax
801040d9:	05 98 53 11 80       	add    $0x80115398,%eax
801040de:	8b 00                	mov    (%eax),%eax
801040e0:	3b 45 08             	cmp    0x8(%ebp),%eax
801040e3:	75 4f                	jne    80104134 <shm_arr_findPA+0x82>
		{
			//if the process is mapping to this region, we also have to increment the numAccess count
			shm_arr[i].numAccess = (shm_arr[i].numAccess) + refChange;
801040e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801040e8:	c1 e0 02             	shl    $0x2,%eax
801040eb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801040f2:	29 c2                	sub    %eax,%edx
801040f4:	89 d0                	mov    %edx,%eax
801040f6:	05 94 53 11 80       	add    $0x80115394,%eax
801040fb:	8b 10                	mov    (%eax),%edx
801040fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104100:	01 c2                	add    %eax,%edx
80104102:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104105:	c1 e0 02             	shl    $0x2,%eax
80104108:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
8010410f:	29 c1                	sub    %eax,%ecx
80104111:	89 c8                	mov    %ecx,%eax
80104113:	05 94 53 11 80       	add    $0x80115394,%eax
80104118:	89 10                	mov    %edx,(%eax)
			return shm_arr[i].shmPhys;
8010411a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010411d:	c1 e0 02             	shl    $0x2,%eax
80104120:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80104127:	29 c2                	sub    %eax,%edx
80104129:	89 d0                	mov    %edx,%eax
8010412b:	05 98 53 11 80       	add    $0x80115398,%eax
80104130:	8b 00                	mov    (%eax),%eax
80104132:	eb 0f                	jmp    80104143 <shm_arr_findPA+0x91>
//added functionality to either add or subtract refrence count when using function because functions calling this function
//don't have access to the shm tracking array
uint shm_arr_findPA(uint pa, int refChange)
{
	int i = 0;
	for(i = 0; i<SHM_MAXNUM; i++)
80104134:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104138:	83 7d fc 1f          	cmpl   $0x1f,-0x4(%ebp)
8010413c:	7e 8a                	jle    801040c8 <shm_arr_findPA+0x16>
			shm_arr[i].numAccess = (shm_arr[i].numAccess) + refChange;
			return shm_arr[i].shmPhys;
			//fix exit dealloc here...
		}
	}
	return -1;
8010413e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104143:	c9                   	leave  
80104144:	c3                   	ret    

80104145 <shmExitClean>:
//BAD CODE: Never gets called by exit
//Called by exit(). Supposed to check for any single-referenced SHM regions in the process so that it can clean them up and free
//them.
int shmExitClean()
{
80104145:	55                   	push   %ebp
80104146:	89 e5                	mov    %esp,%ebp
80104148:	83 ec 18             	sub    $0x18,%esp
	cprintf("\nEntering Exit Clean.\n");
8010414b:	83 ec 0c             	sub    $0xc,%esp
8010414e:	68 b0 a7 10 80       	push   $0x8010a7b0
80104153:	e8 6e c2 ff ff       	call   801003c6 <cprintf>
80104158:	83 c4 10             	add    $0x10,%esp
	int i = 0;
8010415b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int check = 0;
80104162:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	int findSHMarr = 0;
80104169:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	for(i=0; i<SHM_MAXNUM; i++)
80104170:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104177:	e9 15 01 00 00       	jmp    80104291 <shmExitClean+0x14c>
	{
		check = strncmp(&(proc->shm_name[i].name[0]), "DNE", sizeof(proc->shm_name[i].name));
8010417c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104182:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104185:	83 c2 07             	add    $0x7,%edx
80104188:	c1 e2 04             	shl    $0x4,%edx
8010418b:	01 d0                	add    %edx,%eax
8010418d:	83 c0 0c             	add    $0xc,%eax
80104190:	83 ec 04             	sub    $0x4,%esp
80104193:	6a 10                	push   $0x10
80104195:	68 e4 a5 10 80       	push   $0x8010a5e4
8010419a:	50                   	push   %eax
8010419b:	e8 a5 2c 00 00       	call   80106e45 <strncmp>
801041a0:	83 c4 10             	add    $0x10,%esp
801041a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if(check != 0)
801041a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801041aa:	0f 84 d6 00 00 00    	je     80104286 <shmExitClean+0x141>
		{
			cprintf("\nExit: SHM in Process found\n");
801041b0:	83 ec 0c             	sub    $0xc,%esp
801041b3:	68 c7 a7 10 80       	push   $0x8010a7c7
801041b8:	e8 09 c2 ff ff       	call   801003c6 <cprintf>
801041bd:	83 c4 10             	add    $0x10,%esp
			findSHMarr = shm_find(&(proc->shm_name[i].name[0]));
801041c0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041c9:	83 c2 07             	add    $0x7,%edx
801041cc:	c1 e2 04             	shl    $0x4,%edx
801041cf:	01 d0                	add    %edx,%eax
801041d1:	83 c0 0c             	add    $0xc,%eax
801041d4:	83 ec 0c             	sub    $0xc,%esp
801041d7:	50                   	push   %eax
801041d8:	e8 6d f7 ff ff       	call   8010394a <shm_find>
801041dd:	83 c4 10             	add    $0x10,%esp
801041e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
			if(findSHMarr != -1)
801041e3:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
801041e7:	0f 84 99 00 00 00    	je     80104286 <shmExitClean+0x141>
			{
				if(shm_arr[findSHMarr].numAccess == 1) //you are the only process using this, so it can be deleted
801041ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041f0:	c1 e0 02             	shl    $0x2,%eax
801041f3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801041fa:	29 c2                	sub    %eax,%edx
801041fc:	89 d0                	mov    %edx,%eax
801041fe:	05 94 53 11 80       	add    $0x80115394,%eax
80104203:	8b 00                	mov    (%eax),%eax
80104205:	83 f8 01             	cmp    $0x1,%eax
80104208:	75 7c                	jne    80104286 <shmExitClean+0x141>
				{
					cprintf("\nExit: Removing SHM Region [%p]", shm_arr[findSHMarr].shmPhys);
8010420a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010420d:	c1 e0 02             	shl    $0x2,%eax
80104210:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80104217:	29 c2                	sub    %eax,%edx
80104219:	89 d0                	mov    %edx,%eax
8010421b:	05 98 53 11 80       	add    $0x80115398,%eax
80104220:	8b 00                	mov    (%eax),%eax
80104222:	83 ec 08             	sub    $0x8,%esp
80104225:	50                   	push   %eax
80104226:	68 e4 a7 10 80       	push   $0x8010a7e4
8010422b:	e8 96 c1 ff ff       	call   801003c6 <cprintf>
80104230:	83 c4 10             	add    $0x10,%esp
					check = shm_alloc(-4096, i, shm_arr[findSHMarr].shmPhys);
80104233:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104236:	c1 e0 02             	shl    $0x2,%eax
80104239:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80104240:	29 c2                	sub    %eax,%edx
80104242:	89 d0                	mov    %edx,%eax
80104244:	05 98 53 11 80       	add    $0x80115398,%eax
80104249:	8b 00                	mov    (%eax),%eax
8010424b:	83 ec 04             	sub    $0x4,%esp
8010424e:	50                   	push   %eax
8010424f:	ff 75 f4             	pushl  -0xc(%ebp)
80104252:	68 00 f0 ff ff       	push   $0xfffff000
80104257:	e8 24 fd ff ff       	call   80103f80 <shm_alloc>
8010425c:	83 c4 10             	add    $0x10,%esp
8010425f:	89 45 f0             	mov    %eax,-0x10(%ebp)
					if(check == -1)
80104262:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80104266:	75 17                	jne    8010427f <shmExitClean+0x13a>
					{
						cprintf("Error Deleting SHM Region on Exit\n");
80104268:	83 ec 0c             	sub    $0xc,%esp
8010426b:	68 04 a8 10 80       	push   $0x8010a804
80104270:	e8 51 c1 ff ff       	call   801003c6 <cprintf>
80104275:	83 c4 10             	add    $0x10,%esp
						return -1;
80104278:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010427d:	eb 21                	jmp    801042a0 <shmExitClean+0x15b>
					}
					else
						return 0;
8010427f:	b8 00 00 00 00       	mov    $0x0,%eax
80104284:	eb 1a                	jmp    801042a0 <shmExitClean+0x15b>
				}
			}
		}
		check = 0;	
80104286:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	cprintf("\nEntering Exit Clean.\n");
	int i = 0;
	int check = 0;
	int findSHMarr = 0;

	for(i=0; i<SHM_MAXNUM; i++)
8010428d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104291:	83 7d f4 1f          	cmpl   $0x1f,-0xc(%ebp)
80104295:	0f 8e e1 fe ff ff    	jle    8010417c <shmExitClean+0x37>
				}
			}
		}
		check = 0;	
	}
	return -1;
8010429b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801042a0:	c9                   	leave  
801042a1:	c3                   	ret    

801042a2 <print_shmNames>:

void print_shmNames()
{
801042a2:	55                   	push   %ebp
801042a3:	89 e5                	mov    %esp,%ebp
801042a5:	53                   	push   %ebx
801042a6:	83 ec 14             	sub    $0x14,%esp
	int i = 0;
801042a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	cprintf("\n");
801042b0:	83 ec 0c             	sub    $0xc,%esp
801042b3:	68 27 a8 10 80       	push   $0x8010a827
801042b8:	e8 09 c1 ff ff       	call   801003c6 <cprintf>
801042bd:	83 c4 10             	add    $0x10,%esp
	for(i=0; i<5; i++)
801042c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042c7:	eb 63                	jmp    8010432c <print_shmNames+0x8a>
	{
		cprintf("shm_get: SHM i = %s, %d, %p\n", &(shm_arr[i].name[0]), shm_arr[i].numAccess, shm_arr[i].shmPhys);
801042c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042cc:	c1 e0 02             	shl    $0x2,%eax
801042cf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801042d6:	29 c2                	sub    %eax,%edx
801042d8:	89 d0                	mov    %edx,%eax
801042da:	05 98 53 11 80       	add    $0x80115398,%eax
801042df:	8b 18                	mov    (%eax),%ebx
801042e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e4:	c1 e0 02             	shl    $0x2,%eax
801042e7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801042ee:	29 c2                	sub    %eax,%edx
801042f0:	89 d0                	mov    %edx,%eax
801042f2:	05 94 53 11 80       	add    $0x80115394,%eax
801042f7:	8b 08                	mov    (%eax),%ecx
801042f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fc:	89 c2                	mov    %eax,%edx
801042fe:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
80104305:	89 c2                	mov    %eax,%edx
80104307:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
8010430e:	29 d0                	sub    %edx,%eax
80104310:	05 80 53 11 80       	add    $0x80115380,%eax
80104315:	83 c0 04             	add    $0x4,%eax
80104318:	53                   	push   %ebx
80104319:	51                   	push   %ecx
8010431a:	50                   	push   %eax
8010431b:	68 29 a8 10 80       	push   $0x8010a829
80104320:	e8 a1 c0 ff ff       	call   801003c6 <cprintf>
80104325:	83 c4 10             	add    $0x10,%esp

void print_shmNames()
{
	int i = 0;
	cprintf("\n");
	for(i=0; i<5; i++)
80104328:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010432c:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
80104330:	7e 97                	jle    801042c9 <print_shmNames+0x27>
	{
		cprintf("shm_get: SHM i = %s, %d, %p\n", &(shm_arr[i].name[0]), shm_arr[i].numAccess, shm_arr[i].shmPhys);
	}
	cprintf("\n");
80104332:	83 ec 0c             	sub    $0xc,%esp
80104335:	68 27 a8 10 80       	push   $0x8010a827
8010433a:	e8 87 c0 ff ff       	call   801003c6 <cprintf>
8010433f:	83 c4 10             	add    $0x10,%esp
}
80104342:	90                   	nop
80104343:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104346:	c9                   	leave  
80104347:	c3                   	ret    

80104348 <shm_get>:

//checks shared memory tracking array to see if that region already exists. If it does, then it returns 
//the location of that region. If it doesn't exist, then it grows the current process the size of a 
//page table and returns the location of the new thing.
char* shm_get(char *name, int name_length)
{
80104348:	55                   	push   %ebp
80104349:	89 e5                	mov    %esp,%ebp
8010434b:	83 ec 28             	sub    $0x28,%esp
	int check = 0;
8010434e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int found = 0;
80104355:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	int firstFree = 0;
8010435c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int procfirstFree = 0; //returns first free block in SHM array for process
80104363:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
	int procFound = 0; //retuns index of found name in process array
8010436a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	//cprintf("Character = %s", name);

	procFound = procSHM_nameFind(name);
80104371:	83 ec 0c             	sub    $0xc,%esp
80104374:	ff 75 08             	pushl  0x8(%ebp)
80104377:	e8 ad f6 ff ff       	call   80103a29 <procSHM_nameFind>
8010437c:	83 c4 10             	add    $0x10,%esp
8010437f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if(procFound != -1)
80104382:	83 7d e4 ff          	cmpl   $0xffffffff,-0x1c(%ebp)
80104386:	0f 84 c7 00 00 00    	je     80104453 <shm_get+0x10b>
	{
		cprintf("\nSHM Region Already Mapped to Calling Process. Mapping previous VA to variable\n");
8010438c:	83 ec 0c             	sub    $0xc,%esp
8010438f:	68 48 a8 10 80       	push   $0x8010a848
80104394:	e8 2d c0 ff ff       	call   801003c6 <cprintf>
80104399:	83 c4 10             	add    $0x10,%esp

		//return value of virtual address of the already mapped SHM Region
		//this might be where mutexes would come into play in SHM Test
		//multiple variables being mapped to same location
		
		cprintf("\nProcess pgdir = %p\n", proc->pgdir);
8010439c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043a2:	8b 40 04             	mov    0x4(%eax),%eax
801043a5:	83 ec 08             	sub    $0x8,%esp
801043a8:	50                   	push   %eax
801043a9:	68 98 a8 10 80       	push   $0x8010a898
801043ae:	e8 13 c0 ff ff       	call   801003c6 <cprintf>
801043b3:	83 c4 10             	add    $0x10,%esp
		cprintf("SHM Proc Found Index = %d\n", procFound);
801043b6:	83 ec 08             	sub    $0x8,%esp
801043b9:	ff 75 e4             	pushl  -0x1c(%ebp)
801043bc:	68 ad a8 10 80       	push   $0x8010a8ad
801043c1:	e8 00 c0 ff ff       	call   801003c6 <cprintf>
801043c6:	83 c4 10             	add    $0x10,%esp
		cprintf("SHM Proc Name = %s\n", &(proc->shm_name[procFound].name[0]));
801043c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801043d2:	83 c2 07             	add    $0x7,%edx
801043d5:	c1 e2 04             	shl    $0x4,%edx
801043d8:	01 d0                	add    %edx,%eax
801043da:	83 c0 0c             	add    $0xc,%eax
801043dd:	83 ec 08             	sub    $0x8,%esp
801043e0:	50                   	push   %eax
801043e1:	68 c8 a8 10 80       	push   $0x8010a8c8
801043e6:	e8 db bf ff ff       	call   801003c6 <cprintf>
801043eb:	83 c4 10             	add    $0x10,%esp
		cprintf("SHM Proc PA = %p\n", proc->shm_phys[procFound]);
801043ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801043f7:	81 c2 bc 00 00 00    	add    $0xbc,%edx
801043fd:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104401:	83 ec 08             	sub    $0x8,%esp
80104404:	50                   	push   %eax
80104405:	68 dc a8 10 80       	push   $0x8010a8dc
8010440a:	e8 b7 bf ff ff       	call   801003c6 <cprintf>
8010440f:	83 c4 10             	add    $0x10,%esp
		cprintf("SHM Proc VA = %d\n", proc->shm_vir[procFound]);
80104412:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104418:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010441b:	81 c2 9c 00 00 00    	add    $0x9c,%edx
80104421:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104425:	83 ec 08             	sub    $0x8,%esp
80104428:	50                   	push   %eax
80104429:	68 ee a8 10 80       	push   $0x8010a8ee
8010442e:	e8 93 bf ff ff       	call   801003c6 <cprintf>
80104433:	83 c4 10             	add    $0x10,%esp

		print_shmNames();
80104436:	e8 67 fe ff ff       	call   801042a2 <print_shmNames>
		return (char*)proc->shm_vir[procFound];
8010443b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104441:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104444:	81 c2 9c 00 00 00    	add    $0x9c,%edx
8010444a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010444e:	e9 8f 02 00 00       	jmp    801046e2 <shm_get+0x39a>
	}

	procfirstFree = procSHM_findFree(); //searches process shm indexes for first free index
80104453:	e8 32 f6 ff ff       	call   80103a8a <procSHM_findFree>
80104458:	89 45 e8             	mov    %eax,-0x18(%ebp)
	if(procfirstFree == -1)
8010445b:	83 7d e8 ff          	cmpl   $0xffffffff,-0x18(%ebp)
8010445f:	75 1f                	jne    80104480 <shm_get+0x138>
	{
		cprintf("\nMax Number of Shared Regions used by Process\n");
80104461:	83 ec 0c             	sub    $0xc,%esp
80104464:	68 00 a9 10 80       	push   $0x8010a900
80104469:	e8 58 bf ff ff       	call   801003c6 <cprintf>
8010446e:	83 c4 10             	add    $0x10,%esp
		print_shmNames();
80104471:	e8 2c fe ff ff       	call   801042a2 <print_shmNames>
		return 0;
80104476:	b8 00 00 00 00       	mov    $0x0,%eax
8010447b:	e9 62 02 00 00       	jmp    801046e2 <shm_get+0x39a>
	}

	//below if statement is activated if shm_find cannot find a matching name and if the number of shared memory spaces hasn't
	//reached the max number the system can have
	found = shm_find(name);
80104480:	83 ec 0c             	sub    $0xc,%esp
80104483:	ff 75 08             	pushl  0x8(%ebp)
80104486:	e8 bf f4 ff ff       	call   8010394a <shm_find>
8010448b:	83 c4 10             	add    $0x10,%esp
8010448e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cprintf("\nFound Value = %d\n", found);
80104491:	83 ec 08             	sub    $0x8,%esp
80104494:	ff 75 f0             	pushl  -0x10(%ebp)
80104497:	68 2f a9 10 80       	push   $0x8010a92f
8010449c:	e8 25 bf ff ff       	call   801003c6 <cprintf>
801044a1:	83 c4 10             	add    $0x10,%esp

	if((found == -1) && (used < SHM_MAXNUM))
801044a4:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801044a8:	0f 85 67 01 00 00    	jne    80104615 <shm_get+0x2cd>
801044ae:	a1 60 53 11 80       	mov    0x80115360,%eax
801044b3:	83 f8 1f             	cmp    $0x1f,%eax
801044b6:	0f 8f 59 01 00 00    	jg     80104615 <shm_get+0x2cd>
	{
		cprintf("\nName Not found...Making new SHM Space\n");
801044bc:	83 ec 0c             	sub    $0xc,%esp
801044bf:	68 44 a9 10 80       	push   $0x8010a944
801044c4:	e8 fd be ff ff       	call   801003c6 <cprintf>
801044c9:	83 c4 10             	add    $0x10,%esp
		
		check = shm_alloc(4096, procfirstFree, 0);
801044cc:	83 ec 04             	sub    $0x4,%esp
801044cf:	6a 00                	push   $0x0
801044d1:	ff 75 e8             	pushl  -0x18(%ebp)
801044d4:	68 00 10 00 00       	push   $0x1000
801044d9:	e8 a2 fa ff ff       	call   80103f80 <shm_alloc>
801044de:	83 c4 10             	add    $0x10,%esp
801044e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(check == -1)
801044e4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
801044e8:	75 0a                	jne    801044f4 <shm_get+0x1ac>
			return 0;
801044ea:	b8 00 00 00 00       	mov    $0x0,%eax
801044ef:	e9 ee 01 00 00       	jmp    801046e2 <shm_get+0x39a>

		cprintf("\nProcess pgdir = %p\n", proc->pgdir);
801044f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044fa:	8b 40 04             	mov    0x4(%eax),%eax
801044fd:	83 ec 08             	sub    $0x8,%esp
80104500:	50                   	push   %eax
80104501:	68 98 a8 10 80       	push   $0x8010a898
80104506:	e8 bb be ff ff       	call   801003c6 <cprintf>
8010450b:	83 c4 10             	add    $0x10,%esp
		
		safestrcpy(proc->shm_name[procfirstFree].name, name, sizeof(proc->shm_name[procfirstFree].name));
8010450e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104514:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104517:	83 c2 07             	add    $0x7,%edx
8010451a:	c1 e2 04             	shl    $0x4,%edx
8010451d:	01 d0                	add    %edx,%eax
8010451f:	83 c0 0c             	add    $0xc,%eax
80104522:	83 ec 04             	sub    $0x4,%esp
80104525:	6a 10                	push   $0x10
80104527:	ff 75 08             	pushl  0x8(%ebp)
8010452a:	50                   	push   %eax
8010452b:	e8 c3 29 00 00       	call   80106ef3 <safestrcpy>
80104530:	83 c4 10             	add    $0x10,%esp

		firstFree = shm_findFree();
80104533:	e8 7e f4 ff ff       	call   801039b6 <shm_findFree>
80104538:	89 45 ec             	mov    %eax,-0x14(%ebp)
		
		shm_arr[firstFree].name_length = name_length;
8010453b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010453e:	c1 e0 02             	shl    $0x2,%eax
80104541:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80104548:	29 c2                	sub    %eax,%edx
8010454a:	89 d0                	mov    %edx,%eax
8010454c:	8d 90 80 53 11 80    	lea    -0x7feeac80(%eax),%edx
80104552:	8b 45 0c             	mov    0xc(%ebp),%eax
80104555:	89 02                	mov    %eax,(%edx)
		strncpy(shm_arr[firstFree].name, name, sizeof(shm_arr[firstFree].name));
80104557:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010455a:	89 c2                	mov    %eax,%edx
8010455c:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
80104563:	89 c2                	mov    %eax,%edx
80104565:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
8010456c:	29 d0                	sub    %edx,%eax
8010456e:	05 80 53 11 80       	add    $0x80115380,%eax
80104573:	83 c0 04             	add    $0x4,%eax
80104576:	83 ec 04             	sub    $0x4,%esp
80104579:	6a 10                	push   $0x10
8010457b:	ff 75 08             	pushl  0x8(%ebp)
8010457e:	50                   	push   %eax
8010457f:	e8 17 29 00 00       	call   80106e9b <strncpy>
80104584:	83 c4 10             	add    $0x10,%esp
		shm_arr[firstFree].numAccess = (shm_arr[firstFree].numAccess) + 1;
80104587:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010458a:	c1 e0 02             	shl    $0x2,%eax
8010458d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80104594:	29 c2                	sub    %eax,%edx
80104596:	89 d0                	mov    %edx,%eax
80104598:	05 94 53 11 80       	add    $0x80115394,%eax
8010459d:	8b 00                	mov    (%eax),%eax
8010459f:	8d 50 01             	lea    0x1(%eax),%edx
801045a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045a5:	c1 e0 02             	shl    $0x2,%eax
801045a8:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801045af:	29 c1                	sub    %eax,%ecx
801045b1:	89 c8                	mov    %ecx,%eax
801045b3:	05 94 53 11 80       	add    $0x80115394,%eax
801045b8:	89 10                	mov    %edx,(%eax)
		shm_arr[firstFree].shmPhys = proc->shm_phys[procfirstFree];
801045ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045c0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801045c3:	81 c2 bc 00 00 00    	add    $0xbc,%edx
801045c9:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
801045cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045d0:	c1 e0 02             	shl    $0x2,%eax
801045d3:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801045da:	29 c1                	sub    %eax,%ecx
801045dc:	89 c8                	mov    %ecx,%eax
801045de:	05 98 53 11 80       	add    $0x80115398,%eax
801045e3:	89 10                	mov    %edx,(%eax)
		used++;
801045e5:	a1 60 53 11 80       	mov    0x80115360,%eax
801045ea:	83 c0 01             	add    $0x1,%eax
801045ed:	a3 60 53 11 80       	mov    %eax,0x80115360

		char* retVal = (char*) proc->shm_vir[procfirstFree];
801045f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045f8:	8b 55 e8             	mov    -0x18(%ebp),%edx
801045fb:	81 c2 9c 00 00 00    	add    $0x9c,%edx
80104601:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104605:	89 45 e0             	mov    %eax,-0x20(%ebp)
		//changing mapping to physical, user still interacting with virtual address.

		print_shmNames();
80104608:	e8 95 fc ff ff       	call   801042a2 <print_shmNames>
		return retVal;
8010460d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104610:	e9 cd 00 00 00       	jmp    801046e2 <shm_get+0x39a>
	}

	if(found != -1)
80104615:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80104619:	0f 84 be 00 00 00    	je     801046dd <shm_get+0x395>
	{
		//would only be in here if SHM is being asking for access to an SHM that it hasn't inherited
		//Requires mapping to current process

		cprintf("SHM_GET: SHM Region Already Exists. Mapping SHM to Calling Process\n");
8010461f:	83 ec 0c             	sub    $0xc,%esp
80104622:	68 6c a9 10 80       	push   $0x8010a96c
80104627:	e8 9a bd ff ff       	call   801003c6 <cprintf>
8010462c:	83 c4 10             	add    $0x10,%esp

		check = shm_alloc(4096, procfirstFree, shm_arr[found].shmPhys);
8010462f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104632:	c1 e0 02             	shl    $0x2,%eax
80104635:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010463c:	29 c2                	sub    %eax,%edx
8010463e:	89 d0                	mov    %edx,%eax
80104640:	05 98 53 11 80       	add    $0x80115398,%eax
80104645:	8b 00                	mov    (%eax),%eax
80104647:	83 ec 04             	sub    $0x4,%esp
8010464a:	50                   	push   %eax
8010464b:	ff 75 e8             	pushl  -0x18(%ebp)
8010464e:	68 00 10 00 00       	push   $0x1000
80104653:	e8 28 f9 ff ff       	call   80103f80 <shm_alloc>
80104658:	83 c4 10             	add    $0x10,%esp
8010465b:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(check == -1)
8010465e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
80104662:	75 07                	jne    8010466b <shm_get+0x323>
			return 0;
80104664:	b8 00 00 00 00       	mov    $0x0,%eax
80104669:	eb 77                	jmp    801046e2 <shm_get+0x39a>

		strncpy(&(proc->shm_name[procfirstFree].name[0]), name, sizeof(proc->shm_name[procfirstFree].name));
8010466b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104671:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104674:	83 c2 07             	add    $0x7,%edx
80104677:	c1 e2 04             	shl    $0x4,%edx
8010467a:	01 d0                	add    %edx,%eax
8010467c:	83 c0 0c             	add    $0xc,%eax
8010467f:	83 ec 04             	sub    $0x4,%esp
80104682:	6a 10                	push   $0x10
80104684:	ff 75 08             	pushl  0x8(%ebp)
80104687:	50                   	push   %eax
80104688:	e8 0e 28 00 00       	call   80106e9b <strncpy>
8010468d:	83 c4 10             	add    $0x10,%esp
		shm_arr[found].numAccess = (shm_arr[found].numAccess) + 1;
80104690:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104693:	c1 e0 02             	shl    $0x2,%eax
80104696:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010469d:	29 c2                	sub    %eax,%edx
8010469f:	89 d0                	mov    %edx,%eax
801046a1:	05 94 53 11 80       	add    $0x80115394,%eax
801046a6:	8b 00                	mov    (%eax),%eax
801046a8:	8d 50 01             	lea    0x1(%eax),%edx
801046ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046ae:	c1 e0 02             	shl    $0x2,%eax
801046b1:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801046b8:	29 c1                	sub    %eax,%ecx
801046ba:	89 c8                	mov    %ecx,%eax
801046bc:	05 94 53 11 80       	add    $0x80115394,%eax
801046c1:	89 10                	mov    %edx,(%eax)
		
		print_shmNames();
801046c3:	e8 da fb ff ff       	call   801042a2 <print_shmNames>
		return (char*) proc->shm_vir[procfirstFree]; 
801046c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046ce:	8b 55 e8             	mov    -0x18(%ebp),%edx
801046d1:	81 c2 9c 00 00 00    	add    $0x9c,%edx
801046d7:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801046db:	eb 05                	jmp    801046e2 <shm_get+0x39a>
	}
	return 0;
801046dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046e2:	c9                   	leave  
801046e3:	c3                   	ret    

801046e4 <shm_rem>:
//******************************************************************************

//******************************************************************************
//******************************************************************************
int shm_rem(char *name, int name_length)
{
801046e4:	55                   	push   %ebp
801046e5:	89 e5                	mov    %esp,%ebp
801046e7:	83 ec 18             	sub    $0x18,%esp
	int check = 0;
801046ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	int found = 0;
801046f1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int procFound = 0;
801046f8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
	int i = 0;
801046ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	found = shm_find(name);
80104706:	83 ec 0c             	sub    $0xc,%esp
80104709:	ff 75 08             	pushl  0x8(%ebp)
8010470c:	e8 39 f2 ff ff       	call   8010394a <shm_find>
80104711:	83 c4 10             	add    $0x10,%esp
80104714:	89 45 ec             	mov    %eax,-0x14(%ebp)
	procFound = procSHM_nameFind(name);
80104717:	83 ec 0c             	sub    $0xc,%esp
8010471a:	ff 75 08             	pushl  0x8(%ebp)
8010471d:	e8 07 f3 ff ff       	call   80103a29 <procSHM_nameFind>
80104722:	83 c4 10             	add    $0x10,%esp
80104725:	89 45 e8             	mov    %eax,-0x18(%ebp)

	if(found == -1)
80104728:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
8010472c:	75 1a                	jne    80104748 <shm_rem+0x64>
	{
		cprintf("\nA SHM Region with the specified name doesn't exist.\n"); 
8010472e:	83 ec 0c             	sub    $0xc,%esp
80104731:	68 b0 a9 10 80       	push   $0x8010a9b0
80104736:	e8 8b bc ff ff       	call   801003c6 <cprintf>
8010473b:	83 c4 10             	add    $0x10,%esp
		return -1;
8010473e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104743:	e9 1e 02 00 00       	jmp    80104966 <shm_rem+0x282>
	}
	else if(procFound == -1)
80104748:	83 7d e8 ff          	cmpl   $0xffffffff,-0x18(%ebp)
8010474c:	0f 85 8b 00 00 00    	jne    801047dd <shm_rem+0xf9>
	{
		cprintf("\nThis Process doesn't have access to the SHM Region specified.\n");
80104752:	83 ec 0c             	sub    $0xc,%esp
80104755:	68 e8 a9 10 80       	push   $0x8010a9e8
8010475a:	e8 67 bc ff ff       	call   801003c6 <cprintf>
8010475f:	83 c4 10             	add    $0x10,%esp
		cprintf("Process only has access to the following: ");
80104762:	83 ec 0c             	sub    $0xc,%esp
80104765:	68 28 aa 10 80       	push   $0x8010aa28
8010476a:	e8 57 bc ff ff       	call   801003c6 <cprintf>
8010476f:	83 c4 10             	add    $0x10,%esp
		for(i=0; i<5; i++)
80104772:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104779:	eb 42                	jmp    801047bd <shm_rem+0xd9>
		{
			cprintf(", [SHM %d = %s, %p]", i+1, &(proc->shm_name[i].name[0]), proc->shm_phys[i]);
8010477b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104781:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104784:	81 c2 bc 00 00 00    	add    $0xbc,%edx
8010478a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010478e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104795:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104798:	83 c1 07             	add    $0x7,%ecx
8010479b:	c1 e1 04             	shl    $0x4,%ecx
8010479e:	01 ca                	add    %ecx,%edx
801047a0:	8d 4a 0c             	lea    0xc(%edx),%ecx
801047a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047a6:	83 c2 01             	add    $0x1,%edx
801047a9:	50                   	push   %eax
801047aa:	51                   	push   %ecx
801047ab:	52                   	push   %edx
801047ac:	68 53 aa 10 80       	push   $0x8010aa53
801047b1:	e8 10 bc ff ff       	call   801003c6 <cprintf>
801047b6:	83 c4 10             	add    $0x10,%esp
	}
	else if(procFound == -1)
	{
		cprintf("\nThis Process doesn't have access to the SHM Region specified.\n");
		cprintf("Process only has access to the following: ");
		for(i=0; i<5; i++)
801047b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801047bd:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801047c1:	7e b8                	jle    8010477b <shm_rem+0x97>
		{
			cprintf(", [SHM %d = %s, %p]", i+1, &(proc->shm_name[i].name[0]), proc->shm_phys[i]);
		}
		cprintf("\n");
801047c3:	83 ec 0c             	sub    $0xc,%esp
801047c6:	68 27 a8 10 80       	push   $0x8010a827
801047cb:	e8 f6 bb ff ff       	call   801003c6 <cprintf>
801047d0:	83 c4 10             	add    $0x10,%esp
		return -1;
801047d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047d8:	e9 89 01 00 00       	jmp    80104966 <shm_rem+0x282>
	}

	//still need to fix this
	else if(shm_arr[found].numAccess > 1) //still in use by other processes, remove mapping for current proc only
801047dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047e0:	c1 e0 02             	shl    $0x2,%eax
801047e3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801047ea:	29 c2                	sub    %eax,%edx
801047ec:	89 d0                	mov    %edx,%eax
801047ee:	05 94 53 11 80       	add    $0x80115394,%eax
801047f3:	8b 00                	mov    (%eax),%eax
801047f5:	83 f8 01             	cmp    $0x1,%eax
801047f8:	7e 75                	jle    8010486f <shm_rem+0x18b>
	{
		cprintf("\nThis SHM Region is still in use by other processes.\n");
801047fa:	83 ec 0c             	sub    $0xc,%esp
801047fd:	68 68 aa 10 80       	push   $0x8010aa68
80104802:	e8 bf bb ff ff       	call   801003c6 <cprintf>
80104807:	83 c4 10             	add    $0x10,%esp

		if((check = shm_alloc(-4096, procFound, 0)) == -1)
8010480a:	83 ec 04             	sub    $0x4,%esp
8010480d:	6a 00                	push   $0x0
8010480f:	ff 75 e8             	pushl  -0x18(%ebp)
80104812:	68 00 f0 ff ff       	push   $0xfffff000
80104817:	e8 64 f7 ff ff       	call   80103f80 <shm_alloc>
8010481c:	83 c4 10             	add    $0x10,%esp
8010481f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104822:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80104826:	75 0a                	jne    80104832 <shm_rem+0x14e>
			return -1;
80104828:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010482d:	e9 34 01 00 00       	jmp    80104966 <shm_rem+0x282>

		shm_arr[found].numAccess = (shm_arr[found].numAccess) - 1;
80104832:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104835:	c1 e0 02             	shl    $0x2,%eax
80104838:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010483f:	29 c2                	sub    %eax,%edx
80104841:	89 d0                	mov    %edx,%eax
80104843:	05 94 53 11 80       	add    $0x80115394,%eax
80104848:	8b 00                	mov    (%eax),%eax
8010484a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010484d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104850:	c1 e0 02             	shl    $0x2,%eax
80104853:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
8010485a:	29 c1                	sub    %eax,%ecx
8010485c:	89 c8                	mov    %ecx,%eax
8010485e:	05 94 53 11 80       	add    $0x80115394,%eax
80104863:	89 10                	mov    %edx,(%eax)

		return 1;
80104865:	b8 01 00 00 00       	mov    $0x1,%eax
8010486a:	e9 f7 00 00 00       	jmp    80104966 <shm_rem+0x282>
	}
	//stil need to fix this
	else
	{
		//removing traces of SHM Region
		cprintf("\nSHM Region Physical Memory is Safe to Derefence...Removing SHM Region\n");
8010486f:	83 ec 0c             	sub    $0xc,%esp
80104872:	68 a0 aa 10 80       	push   $0x8010aaa0
80104877:	e8 4a bb ff ff       	call   801003c6 <cprintf>
8010487c:	83 c4 10             	add    $0x10,%esp
		check = shm_alloc(-4096, procFound, shm_arr[found].shmPhys);
8010487f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104882:	c1 e0 02             	shl    $0x2,%eax
80104885:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010488c:	29 c2                	sub    %eax,%edx
8010488e:	89 d0                	mov    %edx,%eax
80104890:	05 98 53 11 80       	add    $0x80115398,%eax
80104895:	8b 00                	mov    (%eax),%eax
80104897:	83 ec 04             	sub    $0x4,%esp
8010489a:	50                   	push   %eax
8010489b:	ff 75 e8             	pushl  -0x18(%ebp)
8010489e:	68 00 f0 ff ff       	push   $0xfffff000
801048a3:	e8 d8 f6 ff ff       	call   80103f80 <shm_alloc>
801048a8:	83 c4 10             	add    $0x10,%esp
801048ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if(check == -1)
801048ae:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801048b2:	75 1a                	jne    801048ce <shm_rem+0x1ea>
		{
			cprintf("DEALLOCATION: FAILED\n");
801048b4:	83 ec 0c             	sub    $0xc,%esp
801048b7:	68 e8 aa 10 80       	push   $0x8010aae8
801048bc:	e8 05 bb ff ff       	call   801003c6 <cprintf>
801048c1:	83 c4 10             	add    $0x10,%esp
			return 0;
801048c4:	b8 00 00 00 00       	mov    $0x0,%eax
801048c9:	e9 98 00 00 00       	jmp    80104966 <shm_rem+0x282>
		}

		shm_arr[found].name_length = 0;
801048ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048d1:	c1 e0 02             	shl    $0x2,%eax
801048d4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801048db:	29 c2                	sub    %eax,%edx
801048dd:	89 d0                	mov    %edx,%eax
801048df:	05 80 53 11 80       	add    $0x80115380,%eax
801048e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		safestrcpy(shm_arr[found].name, "DNE", sizeof(shm_arr[found].name)); 
801048ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048ed:	89 c2                	mov    %eax,%edx
801048ef:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
801048f6:	89 c2                	mov    %eax,%edx
801048f8:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
801048ff:	29 d0                	sub    %edx,%eax
80104901:	05 80 53 11 80       	add    $0x80115380,%eax
80104906:	83 c0 04             	add    $0x4,%eax
80104909:	83 ec 04             	sub    $0x4,%esp
8010490c:	6a 10                	push   $0x10
8010490e:	68 e4 a5 10 80       	push   $0x8010a5e4
80104913:	50                   	push   %eax
80104914:	e8 da 25 00 00       	call   80106ef3 <safestrcpy>
80104919:	83 c4 10             	add    $0x10,%esp
		shm_arr[found].numAccess = 0;
8010491c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010491f:	c1 e0 02             	shl    $0x2,%eax
80104922:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80104929:	29 c2                	sub    %eax,%edx
8010492b:	89 d0                	mov    %edx,%eax
8010492d:	05 94 53 11 80       	add    $0x80115394,%eax
80104932:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		shm_arr[found].shmPhys = 0;
80104938:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010493b:	c1 e0 02             	shl    $0x2,%eax
8010493e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80104945:	29 c2                	sub    %eax,%edx
80104947:	89 d0                	mov    %edx,%eax
80104949:	05 98 53 11 80       	add    $0x80115398,%eax
8010494e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		used--;	
80104954:	a1 60 53 11 80       	mov    0x80115360,%eax
80104959:	83 e8 01             	sub    $0x1,%eax
8010495c:	a3 60 53 11 80       	mov    %eax,0x80115360
		
		return 1;
80104961:	b8 01 00 00 00       	mov    $0x1,%eax
	}	
}
80104966:	c9                   	leave  
80104967:	c3                   	ret    

80104968 <walkpgdir>:

// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *walkpgdir(pde_t * pgdir, const void *va, int alloc)
{
80104968:	55                   	push   %ebp
80104969:	89 e5                	mov    %esp,%ebp
8010496b:	83 ec 18             	sub    $0x18,%esp
	pde_t *pde;
	pte_t *pgtab;

	pde = &pgdir[PDX(va)]; //finds page directory corresponding to virtual address
8010496e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104971:	c1 e8 16             	shr    $0x16,%eax
80104974:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010497b:	8b 45 08             	mov    0x8(%ebp),%eax
8010497e:	01 d0                	add    %edx,%eax
80104980:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (*pde & PTE_P) //if virtual address exists in mapping
80104983:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104986:	8b 00                	mov    (%eax),%eax
80104988:	83 e0 01             	and    $0x1,%eax
8010498b:	85 c0                	test   %eax,%eax
8010498d:	74 18                	je     801049a7 <walkpgdir+0x3f>
	{
		pgtab = (pte_t *) p2v(PTE_ADDR(*pde));
8010498f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104992:	8b 00                	mov    (%eax),%eax
80104994:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104999:	50                   	push   %eax
8010499a:	e8 cd ee ff ff       	call   8010386c <p2v>
8010499f:	83 c4 04             	add    $0x4,%esp
801049a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801049a5:	eb 48                	jmp    801049ef <walkpgdir+0x87>
	} 

	else //if virtual address doesn't exist in mapping
	{
		if (!alloc || (pgtab = (pte_t *) kalloc()) == 0)
801049a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801049ab:	74 0e                	je     801049bb <walkpgdir+0x53>
801049ad:	e8 b8 e2 ff ff       	call   80102c6a <kalloc>
801049b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801049b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801049b9:	75 07                	jne    801049c2 <walkpgdir+0x5a>
			return 0;
801049bb:	b8 00 00 00 00       	mov    $0x0,%eax
801049c0:	eb 44                	jmp    80104a06 <walkpgdir+0x9e>
		// Make sure all those PTE_P bits are zero.
		memset(pgtab, 0, PGSIZE);
801049c2:	83 ec 04             	sub    $0x4,%esp
801049c5:	68 00 10 00 00       	push   $0x1000
801049ca:	6a 00                	push   $0x0
801049cc:	ff 75 f4             	pushl  -0xc(%ebp)
801049cf:	e8 1c 23 00 00       	call   80106cf0 <memset>
801049d4:	83 c4 10             	add    $0x10,%esp
		// The permissions here are overly generous, but they can
		// be further restricted by the permissions in the page table 
		// entries, if necessary.
		*pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
801049d7:	83 ec 0c             	sub    $0xc,%esp
801049da:	ff 75 f4             	pushl  -0xc(%ebp)
801049dd:	e8 7d ee ff ff       	call   8010385f <v2p>
801049e2:	83 c4 10             	add    $0x10,%esp
801049e5:	83 c8 07             	or     $0x7,%eax
801049e8:	89 c2                	mov    %eax,%edx
801049ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049ed:	89 10                	mov    %edx,(%eax)
	}
	return &pgtab[PTX(va)]; //returns page location
801049ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801049f2:	c1 e8 0c             	shr    $0xc,%eax
801049f5:	25 ff 03 00 00       	and    $0x3ff,%eax
801049fa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a04:	01 d0                	add    %edx,%eax
}
80104a06:	c9                   	leave  
80104a07:	c3                   	ret    

80104a08 <mappages>:

// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int mappages(pde_t * pgdir, void *va, uint size, uint pa, int perm)
{
80104a08:	55                   	push   %ebp
80104a09:	89 e5                	mov    %esp,%ebp
80104a0b:	83 ec 18             	sub    $0x18,%esp
	char *a, *last;
	pte_t *pte;

	a = (char *)PGROUNDDOWN((uint) va);
80104a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104a16:	89 45 f4             	mov    %eax,-0xc(%ebp)
	last = (char *)PGROUNDDOWN(((uint) va) + size - 1);
80104a19:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a1c:	8b 45 10             	mov    0x10(%ebp),%eax
80104a1f:	01 d0                	add    %edx,%eax
80104a21:	83 e8 01             	sub    $0x1,%eax
80104a24:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104a29:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (;;) {
		if ((pte = walkpgdir(pgdir, a, 1)) == 0)
80104a2c:	83 ec 04             	sub    $0x4,%esp
80104a2f:	6a 01                	push   $0x1
80104a31:	ff 75 f4             	pushl  -0xc(%ebp)
80104a34:	ff 75 08             	pushl  0x8(%ebp)
80104a37:	e8 2c ff ff ff       	call   80104968 <walkpgdir>
80104a3c:	83 c4 10             	add    $0x10,%esp
80104a3f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104a42:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104a46:	75 07                	jne    80104a4f <mappages+0x47>
			return -1;
80104a48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a4d:	eb 47                	jmp    80104a96 <mappages+0x8e>
		if (*pte & PTE_P)
80104a4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a52:	8b 00                	mov    (%eax),%eax
80104a54:	83 e0 01             	and    $0x1,%eax
80104a57:	85 c0                	test   %eax,%eax
80104a59:	74 0d                	je     80104a68 <mappages+0x60>
			panic("remap");
80104a5b:	83 ec 0c             	sub    $0xc,%esp
80104a5e:	68 fe aa 10 80       	push   $0x8010aafe
80104a63:	e8 fe ba ff ff       	call   80100566 <panic>
		*pte = pa | perm | PTE_P;
80104a68:	8b 45 18             	mov    0x18(%ebp),%eax
80104a6b:	0b 45 14             	or     0x14(%ebp),%eax
80104a6e:	83 c8 01             	or     $0x1,%eax
80104a71:	89 c2                	mov    %eax,%edx
80104a73:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a76:	89 10                	mov    %edx,(%eax)
		if (a == last)
80104a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104a7e:	74 10                	je     80104a90 <mappages+0x88>
			break;
		a += PGSIZE;
80104a80:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
		pa += PGSIZE;
80104a87:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
	}
80104a8e:	eb 9c                	jmp    80104a2c <mappages+0x24>
			return -1;
		if (*pte & PTE_P)
			panic("remap");
		*pte = pa | perm | PTE_P;
		if (a == last)
			break;
80104a90:	90                   	nop
		a += PGSIZE;
		pa += PGSIZE;
	}
	return 0;
80104a91:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a96:	c9                   	leave  
80104a97:	c3                   	ret    

80104a98 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.

int main(void)
{
80104a98:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80104a9c:	83 e4 f0             	and    $0xfffffff0,%esp
80104a9f:	ff 71 fc             	pushl  -0x4(%ecx)
80104aa2:	55                   	push   %ebp
80104aa3:	89 e5                	mov    %esp,%ebp
80104aa5:	51                   	push   %ecx
80104aa6:	83 ec 04             	sub    $0x4,%esp
	kinit1(end, P2V(4 * 1024 * 1024));	// phys page allocator
80104aa9:	83 ec 08             	sub    $0x8,%esp
80104aac:	68 00 00 40 80       	push   $0x80400000
80104ab1:	68 dc 4f 12 80       	push   $0x80124fdc
80104ab6:	e8 78 e0 ff ff       	call   80102b33 <kinit1>
80104abb:	83 c4 10             	add    $0x10,%esp
	kvmalloc();		// kernel page table
80104abe:	e8 70 50 00 00       	call   80109b33 <kvmalloc>
	mpinit();		// collect info about this machine
80104ac3:	e8 4d 04 00 00       	call   80104f15 <mpinit>
	lapicinit();
80104ac8:	e8 e5 e3 ff ff       	call   80102eb2 <lapicinit>
	seginit();		// set up segments
80104acd:	e8 0a 4a 00 00       	call   801094dc <seginit>
	cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80104ad2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ad8:	0f b6 00             	movzbl (%eax),%eax
80104adb:	0f b6 c0             	movzbl %al,%eax
80104ade:	83 ec 08             	sub    $0x8,%esp
80104ae1:	50                   	push   %eax
80104ae2:	68 04 ab 10 80       	push   $0x8010ab04
80104ae7:	e8 da b8 ff ff       	call   801003c6 <cprintf>
80104aec:	83 c4 10             	add    $0x10,%esp
	picinit();		// interrupt controller
80104aef:	e8 77 06 00 00       	call   8010516b <picinit>
	ioapicinit();		// another interrupt controller
80104af4:	e8 2f df ff ff       	call   80102a28 <ioapicinit>
	consoleinit();		// I/O devices & their interrupts
80104af9:	e8 1b c0 ff ff       	call   80100b19 <consoleinit>
	uartinit();		// serial port
80104afe:	e8 35 3d 00 00       	call   80108838 <uartinit>
	pinit();		// process table
80104b03:	e8 12 0c 00 00       	call   8010571a <pinit>
	tvinit();		// trap vectors
80104b08:	e8 f5 38 00 00       	call   80108402 <tvinit>
	binit();		// buffer cache
80104b0d:	e8 22 b5 ff ff       	call   80100034 <binit>
	fileinit();		// file table
80104b12:	e8 62 c4 ff ff       	call   80100f79 <fileinit>
	ideinit();		// disk
80104b17:	e8 14 db ff ff       	call   80102630 <ideinit>
	if (!ismp)
80104b1c:	a1 04 57 11 80       	mov    0x80115704,%eax
80104b21:	85 c0                	test   %eax,%eax
80104b23:	75 05                	jne    80104b2a <main+0x92>
		timerinit();	// uniprocessor timer
80104b25:	e8 35 38 00 00       	call   8010835f <timerinit>
	startothers();		// start other processors
80104b2a:	e8 89 00 00 00       	call   80104bb8 <startothers>
	kinit2(P2V(4 * 1024 * 1024), P2V(PHYSTOP));	// must come after startothers()
80104b2f:	83 ec 08             	sub    $0x8,%esp
80104b32:	68 00 00 00 8e       	push   $0x8e000000
80104b37:	68 00 00 40 80       	push   $0x80400000
80104b3c:	e8 2b e0 ff ff       	call   80102b6c <kinit2>
80104b41:	83 c4 10             	add    $0x10,%esp
	userinit();		// first user process
80104b44:	e8 29 0d 00 00       	call   80105872 <userinit>

	//cprintf("\nInitializing Shared Memory...\n");
	shm_init(); //mod2	
80104b49:	e8 45 ed ff ff       	call   80103893 <shm_init>
	mxarray_init(); //mod3
80104b4e:	e8 2f 0b 00 00       	call   80105682 <mxarray_init>

	// Finish setting up this processor in mpmain.
	mpmain();
80104b53:	e8 1a 00 00 00       	call   80104b72 <mpmain>

80104b58 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void mpenter(void)
{
80104b58:	55                   	push   %ebp
80104b59:	89 e5                	mov    %esp,%ebp
80104b5b:	83 ec 08             	sub    $0x8,%esp
	switchkvm();
80104b5e:	e8 e8 4f 00 00       	call   80109b4b <switchkvm>
	seginit();
80104b63:	e8 74 49 00 00       	call   801094dc <seginit>
	lapicinit();
80104b68:	e8 45 e3 ff ff       	call   80102eb2 <lapicinit>
	mpmain();
80104b6d:	e8 00 00 00 00       	call   80104b72 <mpmain>

80104b72 <mpmain>:
}

// Common CPU setup code.
static void mpmain(void)
{
80104b72:	55                   	push   %ebp
80104b73:	89 e5                	mov    %esp,%ebp
80104b75:	83 ec 08             	sub    $0x8,%esp
	cprintf("cpu%d: starting\n", cpu->id);
80104b78:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b7e:	0f b6 00             	movzbl (%eax),%eax
80104b81:	0f b6 c0             	movzbl %al,%eax
80104b84:	83 ec 08             	sub    $0x8,%esp
80104b87:	50                   	push   %eax
80104b88:	68 1b ab 10 80       	push   $0x8010ab1b
80104b8d:	e8 34 b8 ff ff       	call   801003c6 <cprintf>
80104b92:	83 c4 10             	add    $0x10,%esp
	idtinit();		// load idt register
80104b95:	e8 de 39 00 00       	call   80108578 <idtinit>
	xchg(&cpu->started, 1);	// tell startothers() we're up
80104b9a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ba0:	05 a8 00 00 00       	add    $0xa8,%eax
80104ba5:	83 ec 08             	sub    $0x8,%esp
80104ba8:	6a 01                	push   $0x1
80104baa:	50                   	push   %eax
80104bab:	e8 c9 ec ff ff       	call   80103879 <xchg>
80104bb0:	83 c4 10             	add    $0x10,%esp
	scheduler();		// start running processes
80104bb3:	e8 ba 13 00 00       	call   80105f72 <scheduler>

80104bb8 <startothers>:

pde_t entrypgdir[];		// For entry.S

// Start the non-boot (AP) processors.
static void startothers(void)
{
80104bb8:	55                   	push   %ebp
80104bb9:	89 e5                	mov    %esp,%ebp
80104bbb:	53                   	push   %ebx
80104bbc:	83 ec 14             	sub    $0x14,%esp
	char *stack;

	// Write entry code to unused memory at 0x7000.
	// The linker has placed the image of entryother.S in
	// _binary_entryother_start.
	code = p2v(0x7000);
80104bbf:	68 00 70 00 00       	push   $0x7000
80104bc4:	e8 a3 ec ff ff       	call   8010386c <p2v>
80104bc9:	83 c4 04             	add    $0x4,%esp
80104bcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
	memmove(code, _binary_entryother_start, (uint) _binary_entryother_size);
80104bcf:	b8 8a 00 00 00       	mov    $0x8a,%eax
80104bd4:	83 ec 04             	sub    $0x4,%esp
80104bd7:	50                   	push   %eax
80104bd8:	68 2c e5 10 80       	push   $0x8010e52c
80104bdd:	ff 75 f0             	pushl  -0x10(%ebp)
80104be0:	e8 ca 21 00 00       	call   80106daf <memmove>
80104be5:	83 c4 10             	add    $0x10,%esp

	for (c = cpus; c < cpus + ncpu; c++) {
80104be8:	c7 45 f4 20 57 11 80 	movl   $0x80115720,-0xc(%ebp)
80104bef:	e9 90 00 00 00       	jmp    80104c84 <startothers+0xcc>
		if (c == cpus + cpunum())	// We've started already.
80104bf4:	e8 d7 e3 ff ff       	call   80102fd0 <cpunum>
80104bf9:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104bff:	05 20 57 11 80       	add    $0x80115720,%eax
80104c04:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104c07:	74 73                	je     80104c7c <startothers+0xc4>
			continue;

		// Tell entryother.S what stack to use, where to enter, and what 
		// pgdir to use. We cannot use kpgdir yet, because the AP processor
		// is running in low  memory, so we use entrypgdir for the APs too.
		stack = kalloc();
80104c09:	e8 5c e0 ff ff       	call   80102c6a <kalloc>
80104c0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
		*(void **)(code - 4) = stack + KSTACKSIZE;
80104c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c14:	83 e8 04             	sub    $0x4,%eax
80104c17:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104c1a:	81 c2 00 10 00 00    	add    $0x1000,%edx
80104c20:	89 10                	mov    %edx,(%eax)
		*(void **)(code - 8) = mpenter;
80104c22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c25:	83 e8 08             	sub    $0x8,%eax
80104c28:	c7 00 58 4b 10 80    	movl   $0x80104b58,(%eax)
		*(int **)(code - 12) = (void *)v2p(entrypgdir);
80104c2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c31:	8d 58 f4             	lea    -0xc(%eax),%ebx
80104c34:	83 ec 0c             	sub    $0xc,%esp
80104c37:	68 00 d0 10 80       	push   $0x8010d000
80104c3c:	e8 1e ec ff ff       	call   8010385f <v2p>
80104c41:	83 c4 10             	add    $0x10,%esp
80104c44:	89 03                	mov    %eax,(%ebx)

		lapicstartap(c->id, v2p(code));
80104c46:	83 ec 0c             	sub    $0xc,%esp
80104c49:	ff 75 f0             	pushl  -0x10(%ebp)
80104c4c:	e8 0e ec ff ff       	call   8010385f <v2p>
80104c51:	83 c4 10             	add    $0x10,%esp
80104c54:	89 c2                	mov    %eax,%edx
80104c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c59:	0f b6 00             	movzbl (%eax),%eax
80104c5c:	0f b6 c0             	movzbl %al,%eax
80104c5f:	83 ec 08             	sub    $0x8,%esp
80104c62:	52                   	push   %edx
80104c63:	50                   	push   %eax
80104c64:	e8 e1 e3 ff ff       	call   8010304a <lapicstartap>
80104c69:	83 c4 10             	add    $0x10,%esp

		// wait for cpu to finish mpmain()
		while (c->started == 0) ;
80104c6c:	90                   	nop
80104c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c70:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104c76:	85 c0                	test   %eax,%eax
80104c78:	74 f3                	je     80104c6d <startothers+0xb5>
80104c7a:	eb 01                	jmp    80104c7d <startothers+0xc5>
	code = p2v(0x7000);
	memmove(code, _binary_entryother_start, (uint) _binary_entryother_size);

	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())	// We've started already.
			continue;
80104c7c:	90                   	nop
	// The linker has placed the image of entryother.S in
	// _binary_entryother_start.
	code = p2v(0x7000);
	memmove(code, _binary_entryother_start, (uint) _binary_entryother_size);

	for (c = cpus; c < cpus + ncpu; c++) {
80104c7d:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80104c84:	a1 00 5d 11 80       	mov    0x80115d00,%eax
80104c89:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104c8f:	05 20 57 11 80       	add    $0x80115720,%eax
80104c94:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104c97:	0f 87 57 ff ff ff    	ja     80104bf4 <startothers+0x3c>
		lapicstartap(c->id, v2p(code));

		// wait for cpu to finish mpmain()
		while (c->started == 0) ;
	}
}
80104c9d:	90                   	nop
80104c9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ca1:	c9                   	leave  
80104ca2:	c3                   	ret    

80104ca3 <p2v>:
80104ca3:	55                   	push   %ebp
80104ca4:	89 e5                	mov    %esp,%ebp
80104ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca9:	05 00 00 00 80       	add    $0x80000000,%eax
80104cae:	5d                   	pop    %ebp
80104caf:	c3                   	ret    

80104cb0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80104cb0:	55                   	push   %ebp
80104cb1:	89 e5                	mov    %esp,%ebp
80104cb3:	83 ec 14             	sub    $0x14,%esp
80104cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80104cb9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80104cbd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80104cc1:	89 c2                	mov    %eax,%edx
80104cc3:	ec                   	in     (%dx),%al
80104cc4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80104cc7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80104ccb:	c9                   	leave  
80104ccc:	c3                   	ret    

80104ccd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80104ccd:	55                   	push   %ebp
80104cce:	89 e5                	mov    %esp,%ebp
80104cd0:	83 ec 08             	sub    $0x8,%esp
80104cd3:	8b 55 08             	mov    0x8(%ebp),%edx
80104cd6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cd9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80104cdd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80104ce0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104ce4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104ce8:	ee                   	out    %al,(%dx)
}
80104ce9:	90                   	nop
80104cea:	c9                   	leave  
80104ceb:	c3                   	ret    

80104cec <mpbcpu>:
int ismp;
int ncpu;
uchar ioapicid;

int mpbcpu(void)
{
80104cec:	55                   	push   %ebp
80104ced:	89 e5                	mov    %esp,%ebp
	return bcpu - cpus;
80104cef:	a1 64 e6 10 80       	mov    0x8010e664,%eax
80104cf4:	89 c2                	mov    %eax,%edx
80104cf6:	b8 20 57 11 80       	mov    $0x80115720,%eax
80104cfb:	29 c2                	sub    %eax,%edx
80104cfd:	89 d0                	mov    %edx,%eax
80104cff:	c1 f8 02             	sar    $0x2,%eax
80104d02:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80104d08:	5d                   	pop    %ebp
80104d09:	c3                   	ret    

80104d0a <sum>:

static uchar sum(uchar * addr, int len)
{
80104d0a:	55                   	push   %ebp
80104d0b:	89 e5                	mov    %esp,%ebp
80104d0d:	83 ec 10             	sub    $0x10,%esp
	int i, sum;

	sum = 0;
80104d10:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (i = 0; i < len; i++)
80104d17:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104d1e:	eb 15                	jmp    80104d35 <sum+0x2b>
		sum += addr[i];
80104d20:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104d23:	8b 45 08             	mov    0x8(%ebp),%eax
80104d26:	01 d0                	add    %edx,%eax
80104d28:	0f b6 00             	movzbl (%eax),%eax
80104d2b:	0f b6 c0             	movzbl %al,%eax
80104d2e:	01 45 f8             	add    %eax,-0x8(%ebp)
static uchar sum(uchar * addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
80104d31:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104d35:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d38:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104d3b:	7c e3                	jl     80104d20 <sum+0x16>
		sum += addr[i];
	return sum;
80104d3d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104d40:	c9                   	leave  
80104d41:	c3                   	ret    

80104d42 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp *mpsearch1(uint a, int len)
{
80104d42:	55                   	push   %ebp
80104d43:	89 e5                	mov    %esp,%ebp
80104d45:	83 ec 18             	sub    $0x18,%esp
	uchar *e, *p, *addr;

	addr = p2v(a);
80104d48:	ff 75 08             	pushl  0x8(%ebp)
80104d4b:	e8 53 ff ff ff       	call   80104ca3 <p2v>
80104d50:	83 c4 04             	add    $0x4,%esp
80104d53:	89 45 f0             	mov    %eax,-0x10(%ebp)
	e = addr + len;
80104d56:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d5c:	01 d0                	add    %edx,%eax
80104d5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (p = addr; p < e; p += sizeof(struct mp))
80104d61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d64:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104d67:	eb 36                	jmp    80104d9f <mpsearch1+0x5d>
		if (memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80104d69:	83 ec 04             	sub    $0x4,%esp
80104d6c:	6a 04                	push   $0x4
80104d6e:	68 2c ab 10 80       	push   $0x8010ab2c
80104d73:	ff 75 f4             	pushl  -0xc(%ebp)
80104d76:	e8 dc 1f 00 00       	call   80106d57 <memcmp>
80104d7b:	83 c4 10             	add    $0x10,%esp
80104d7e:	85 c0                	test   %eax,%eax
80104d80:	75 19                	jne    80104d9b <mpsearch1+0x59>
80104d82:	83 ec 08             	sub    $0x8,%esp
80104d85:	6a 10                	push   $0x10
80104d87:	ff 75 f4             	pushl  -0xc(%ebp)
80104d8a:	e8 7b ff ff ff       	call   80104d0a <sum>
80104d8f:	83 c4 10             	add    $0x10,%esp
80104d92:	84 c0                	test   %al,%al
80104d94:	75 05                	jne    80104d9b <mpsearch1+0x59>
			return (struct mp *)p;
80104d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d99:	eb 11                	jmp    80104dac <mpsearch1+0x6a>
{
	uchar *e, *p, *addr;

	addr = p2v(a);
	e = addr + len;
	for (p = addr; p < e; p += sizeof(struct mp))
80104d9b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80104d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104da5:	72 c2                	jb     80104d69 <mpsearch1+0x27>
		if (memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
			return (struct mp *)p;
	return 0;
80104da7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104dac:	c9                   	leave  
80104dad:	c3                   	ret    

80104dae <mpsearch>:
// spec is in one of the following three locations:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp *mpsearch(void)
{
80104dae:	55                   	push   %ebp
80104daf:	89 e5                	mov    %esp,%ebp
80104db1:	83 ec 18             	sub    $0x18,%esp
	uchar *bda;
	uint p;
	struct mp *mp;

	bda = (uchar *) P2V(0x400);
80104db4:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
	if ((p = ((bda[0x0F] << 8) | bda[0x0E]) << 4)) {
80104dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dbe:	83 c0 0f             	add    $0xf,%eax
80104dc1:	0f b6 00             	movzbl (%eax),%eax
80104dc4:	0f b6 c0             	movzbl %al,%eax
80104dc7:	c1 e0 08             	shl    $0x8,%eax
80104dca:	89 c2                	mov    %eax,%edx
80104dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dcf:	83 c0 0e             	add    $0xe,%eax
80104dd2:	0f b6 00             	movzbl (%eax),%eax
80104dd5:	0f b6 c0             	movzbl %al,%eax
80104dd8:	09 d0                	or     %edx,%eax
80104dda:	c1 e0 04             	shl    $0x4,%eax
80104ddd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104de0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104de4:	74 21                	je     80104e07 <mpsearch+0x59>
		if ((mp = mpsearch1(p, 1024)))
80104de6:	83 ec 08             	sub    $0x8,%esp
80104de9:	68 00 04 00 00       	push   $0x400
80104dee:	ff 75 f0             	pushl  -0x10(%ebp)
80104df1:	e8 4c ff ff ff       	call   80104d42 <mpsearch1>
80104df6:	83 c4 10             	add    $0x10,%esp
80104df9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104dfc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104e00:	74 51                	je     80104e53 <mpsearch+0xa5>
			return mp;
80104e02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e05:	eb 61                	jmp    80104e68 <mpsearch+0xba>
	} else {
		p = ((bda[0x14] << 8) | bda[0x13]) * 1024;
80104e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e0a:	83 c0 14             	add    $0x14,%eax
80104e0d:	0f b6 00             	movzbl (%eax),%eax
80104e10:	0f b6 c0             	movzbl %al,%eax
80104e13:	c1 e0 08             	shl    $0x8,%eax
80104e16:	89 c2                	mov    %eax,%edx
80104e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e1b:	83 c0 13             	add    $0x13,%eax
80104e1e:	0f b6 00             	movzbl (%eax),%eax
80104e21:	0f b6 c0             	movzbl %al,%eax
80104e24:	09 d0                	or     %edx,%eax
80104e26:	c1 e0 0a             	shl    $0xa,%eax
80104e29:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if ((mp = mpsearch1(p - 1024, 1024)))
80104e2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e2f:	2d 00 04 00 00       	sub    $0x400,%eax
80104e34:	83 ec 08             	sub    $0x8,%esp
80104e37:	68 00 04 00 00       	push   $0x400
80104e3c:	50                   	push   %eax
80104e3d:	e8 00 ff ff ff       	call   80104d42 <mpsearch1>
80104e42:	83 c4 10             	add    $0x10,%esp
80104e45:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104e48:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104e4c:	74 05                	je     80104e53 <mpsearch+0xa5>
			return mp;
80104e4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e51:	eb 15                	jmp    80104e68 <mpsearch+0xba>
	}
	return mpsearch1(0xF0000, 0x10000);
80104e53:	83 ec 08             	sub    $0x8,%esp
80104e56:	68 00 00 01 00       	push   $0x10000
80104e5b:	68 00 00 0f 00       	push   $0xf0000
80104e60:	e8 dd fe ff ff       	call   80104d42 <mpsearch1>
80104e65:	83 c4 10             	add    $0x10,%esp
}
80104e68:	c9                   	leave  
80104e69:	c3                   	ret    

80104e6a <mpconfig>:
// don't accept the default configurations (physaddr == 0).
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf *mpconfig(struct mp **pmp)
{
80104e6a:	55                   	push   %ebp
80104e6b:	89 e5                	mov    %esp,%ebp
80104e6d:	83 ec 18             	sub    $0x18,%esp
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0 || mp->physaddr == 0)
80104e70:	e8 39 ff ff ff       	call   80104dae <mpsearch>
80104e75:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e78:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e7c:	74 0a                	je     80104e88 <mpconfig+0x1e>
80104e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e81:	8b 40 04             	mov    0x4(%eax),%eax
80104e84:	85 c0                	test   %eax,%eax
80104e86:	75 0a                	jne    80104e92 <mpconfig+0x28>
		return 0;
80104e88:	b8 00 00 00 00       	mov    $0x0,%eax
80104e8d:	e9 81 00 00 00       	jmp    80104f13 <mpconfig+0xa9>
	conf = (struct mpconf *)p2v((uint) mp->physaddr);
80104e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e95:	8b 40 04             	mov    0x4(%eax),%eax
80104e98:	83 ec 0c             	sub    $0xc,%esp
80104e9b:	50                   	push   %eax
80104e9c:	e8 02 fe ff ff       	call   80104ca3 <p2v>
80104ea1:	83 c4 10             	add    $0x10,%esp
80104ea4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (memcmp(conf, "PCMP", 4) != 0)
80104ea7:	83 ec 04             	sub    $0x4,%esp
80104eaa:	6a 04                	push   $0x4
80104eac:	68 31 ab 10 80       	push   $0x8010ab31
80104eb1:	ff 75 f0             	pushl  -0x10(%ebp)
80104eb4:	e8 9e 1e 00 00       	call   80106d57 <memcmp>
80104eb9:	83 c4 10             	add    $0x10,%esp
80104ebc:	85 c0                	test   %eax,%eax
80104ebe:	74 07                	je     80104ec7 <mpconfig+0x5d>
		return 0;
80104ec0:	b8 00 00 00 00       	mov    $0x0,%eax
80104ec5:	eb 4c                	jmp    80104f13 <mpconfig+0xa9>
	if (conf->version != 1 && conf->version != 4)
80104ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eca:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80104ece:	3c 01                	cmp    $0x1,%al
80104ed0:	74 12                	je     80104ee4 <mpconfig+0x7a>
80104ed2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ed5:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80104ed9:	3c 04                	cmp    $0x4,%al
80104edb:	74 07                	je     80104ee4 <mpconfig+0x7a>
		return 0;
80104edd:	b8 00 00 00 00       	mov    $0x0,%eax
80104ee2:	eb 2f                	jmp    80104f13 <mpconfig+0xa9>
	if (sum((uchar *) conf, conf->length) != 0)
80104ee4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ee7:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104eeb:	0f b7 c0             	movzwl %ax,%eax
80104eee:	83 ec 08             	sub    $0x8,%esp
80104ef1:	50                   	push   %eax
80104ef2:	ff 75 f0             	pushl  -0x10(%ebp)
80104ef5:	e8 10 fe ff ff       	call   80104d0a <sum>
80104efa:	83 c4 10             	add    $0x10,%esp
80104efd:	84 c0                	test   %al,%al
80104eff:	74 07                	je     80104f08 <mpconfig+0x9e>
		return 0;
80104f01:	b8 00 00 00 00       	mov    $0x0,%eax
80104f06:	eb 0b                	jmp    80104f13 <mpconfig+0xa9>
	*pmp = mp;
80104f08:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f0e:	89 10                	mov    %edx,(%eax)
	return conf;
80104f10:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104f13:	c9                   	leave  
80104f14:	c3                   	ret    

80104f15 <mpinit>:

void mpinit(void)
{
80104f15:	55                   	push   %ebp
80104f16:	89 e5                	mov    %esp,%ebp
80104f18:	83 ec 28             	sub    $0x28,%esp
	struct mp *mp;
	struct mpconf *conf;
	struct mpproc *proc;
	struct mpioapic *ioapic;

	bcpu = &cpus[0];
80104f1b:	c7 05 64 e6 10 80 20 	movl   $0x80115720,0x8010e664
80104f22:	57 11 80 
	if ((conf = mpconfig(&mp)) == 0)
80104f25:	83 ec 0c             	sub    $0xc,%esp
80104f28:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104f2b:	50                   	push   %eax
80104f2c:	e8 39 ff ff ff       	call   80104e6a <mpconfig>
80104f31:	83 c4 10             	add    $0x10,%esp
80104f34:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104f37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104f3b:	0f 84 96 01 00 00    	je     801050d7 <mpinit+0x1c2>
		return;
	ismp = 1;
80104f41:	c7 05 04 57 11 80 01 	movl   $0x1,0x80115704
80104f48:	00 00 00 
	lapic = (uint *) conf->lapicaddr;
80104f4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f4e:	8b 40 24             	mov    0x24(%eax),%eax
80104f51:	a3 7c 52 11 80       	mov    %eax,0x8011527c
	for (p = (uchar *) (conf + 1), e = (uchar *) conf + conf->length;
80104f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f59:	83 c0 2c             	add    $0x2c,%eax
80104f5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f62:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104f66:	0f b7 d0             	movzwl %ax,%edx
80104f69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f6c:	01 d0                	add    %edx,%eax
80104f6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f71:	e9 f2 00 00 00       	jmp    80105068 <mpinit+0x153>
	     p < e;) {
		switch (*p) {
80104f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f79:	0f b6 00             	movzbl (%eax),%eax
80104f7c:	0f b6 c0             	movzbl %al,%eax
80104f7f:	83 f8 04             	cmp    $0x4,%eax
80104f82:	0f 87 bc 00 00 00    	ja     80105044 <mpinit+0x12f>
80104f88:	8b 04 85 74 ab 10 80 	mov    -0x7fef548c(,%eax,4),%eax
80104f8f:	ff e0                	jmp    *%eax
		case MPPROC:
			proc = (struct mpproc *)p;
80104f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f94:	89 45 e8             	mov    %eax,-0x18(%ebp)
			if (ncpu != proc->apicid) {
80104f97:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104f9a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104f9e:	0f b6 d0             	movzbl %al,%edx
80104fa1:	a1 00 5d 11 80       	mov    0x80115d00,%eax
80104fa6:	39 c2                	cmp    %eax,%edx
80104fa8:	74 2b                	je     80104fd5 <mpinit+0xc0>
				cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu,
					proc->apicid);
80104faa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104fad:	0f b6 40 01          	movzbl 0x1(%eax),%eax
	     p < e;) {
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (ncpu != proc->apicid) {
				cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu,
80104fb1:	0f b6 d0             	movzbl %al,%edx
80104fb4:	a1 00 5d 11 80       	mov    0x80115d00,%eax
80104fb9:	83 ec 04             	sub    $0x4,%esp
80104fbc:	52                   	push   %edx
80104fbd:	50                   	push   %eax
80104fbe:	68 36 ab 10 80       	push   $0x8010ab36
80104fc3:	e8 fe b3 ff ff       	call   801003c6 <cprintf>
80104fc8:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
				ismp = 0;
80104fcb:	c7 05 04 57 11 80 00 	movl   $0x0,0x80115704
80104fd2:	00 00 00 
			}
			if (proc->flags & MPBOOT)
80104fd5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104fd8:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80104fdc:	0f b6 c0             	movzbl %al,%eax
80104fdf:	83 e0 02             	and    $0x2,%eax
80104fe2:	85 c0                	test   %eax,%eax
80104fe4:	74 15                	je     80104ffb <mpinit+0xe6>
				bcpu = &cpus[ncpu];
80104fe6:	a1 00 5d 11 80       	mov    0x80115d00,%eax
80104feb:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104ff1:	05 20 57 11 80       	add    $0x80115720,%eax
80104ff6:	a3 64 e6 10 80       	mov    %eax,0x8010e664
			cpus[ncpu].id = ncpu;
80104ffb:	a1 00 5d 11 80       	mov    0x80115d00,%eax
80105000:	8b 15 00 5d 11 80    	mov    0x80115d00,%edx
80105006:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010500c:	05 20 57 11 80       	add    $0x80115720,%eax
80105011:	88 10                	mov    %dl,(%eax)
			ncpu++;
80105013:	a1 00 5d 11 80       	mov    0x80115d00,%eax
80105018:	83 c0 01             	add    $0x1,%eax
8010501b:	a3 00 5d 11 80       	mov    %eax,0x80115d00
			p += sizeof(struct mpproc);
80105020:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
			continue;
80105024:	eb 42                	jmp    80105068 <mpinit+0x153>
		case MPIOAPIC:
			ioapic = (struct mpioapic *)p;
80105026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105029:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			ioapicid = ioapic->apicno;
8010502c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010502f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80105033:	a2 00 57 11 80       	mov    %al,0x80115700
			p += sizeof(struct mpioapic);
80105038:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
			continue;
8010503c:	eb 2a                	jmp    80105068 <mpinit+0x153>
		case MPBUS:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
8010503e:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
			continue;
80105042:	eb 24                	jmp    80105068 <mpinit+0x153>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
80105044:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105047:	0f b6 00             	movzbl (%eax),%eax
8010504a:	0f b6 c0             	movzbl %al,%eax
8010504d:	83 ec 08             	sub    $0x8,%esp
80105050:	50                   	push   %eax
80105051:	68 54 ab 10 80       	push   $0x8010ab54
80105056:	e8 6b b3 ff ff       	call   801003c6 <cprintf>
8010505b:	83 c4 10             	add    $0x10,%esp
			ismp = 0;
8010505e:	c7 05 04 57 11 80 00 	movl   $0x0,0x80115704
80105065:	00 00 00 
	bcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapic = (uint *) conf->lapicaddr;
	for (p = (uchar *) (conf + 1), e = (uchar *) conf + conf->length;
80105068:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010506b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010506e:	0f 82 02 ff ff ff    	jb     80104f76 <mpinit+0x61>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
			ismp = 0;
		}
	}
	if (!ismp) {
80105074:	a1 04 57 11 80       	mov    0x80115704,%eax
80105079:	85 c0                	test   %eax,%eax
8010507b:	75 1d                	jne    8010509a <mpinit+0x185>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
8010507d:	c7 05 00 5d 11 80 01 	movl   $0x1,0x80115d00
80105084:	00 00 00 
		lapic = 0;
80105087:	c7 05 7c 52 11 80 00 	movl   $0x0,0x8011527c
8010508e:	00 00 00 
		ioapicid = 0;
80105091:	c6 05 00 57 11 80 00 	movb   $0x0,0x80115700
		return;
80105098:	eb 3e                	jmp    801050d8 <mpinit+0x1c3>
	}

	if (mp->imcrp) {
8010509a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010509d:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801050a1:	84 c0                	test   %al,%al
801050a3:	74 33                	je     801050d8 <mpinit+0x1c3>
		// Bochs doesn't support IMCR, so this doesn't run on Bochs.
		// But it would on real hardware.
		outb(0x22, 0x70);	// Select IMCR
801050a5:	83 ec 08             	sub    $0x8,%esp
801050a8:	6a 70                	push   $0x70
801050aa:	6a 22                	push   $0x22
801050ac:	e8 1c fc ff ff       	call   80104ccd <outb>
801050b1:	83 c4 10             	add    $0x10,%esp
		outb(0x23, inb(0x23) | 1);	// Mask external interrupts.
801050b4:	83 ec 0c             	sub    $0xc,%esp
801050b7:	6a 23                	push   $0x23
801050b9:	e8 f2 fb ff ff       	call   80104cb0 <inb>
801050be:	83 c4 10             	add    $0x10,%esp
801050c1:	83 c8 01             	or     $0x1,%eax
801050c4:	0f b6 c0             	movzbl %al,%eax
801050c7:	83 ec 08             	sub    $0x8,%esp
801050ca:	50                   	push   %eax
801050cb:	6a 23                	push   $0x23
801050cd:	e8 fb fb ff ff       	call   80104ccd <outb>
801050d2:	83 c4 10             	add    $0x10,%esp
801050d5:	eb 01                	jmp    801050d8 <mpinit+0x1c3>
	struct mpproc *proc;
	struct mpioapic *ioapic;

	bcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
		return;
801050d7:	90                   	nop
		// Bochs doesn't support IMCR, so this doesn't run on Bochs.
		// But it would on real hardware.
		outb(0x22, 0x70);	// Select IMCR
		outb(0x23, inb(0x23) | 1);	// Mask external interrupts.
	}
}
801050d8:	c9                   	leave  
801050d9:	c3                   	ret    

801050da <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801050da:	55                   	push   %ebp
801050db:	89 e5                	mov    %esp,%ebp
801050dd:	83 ec 08             	sub    $0x8,%esp
801050e0:	8b 55 08             	mov    0x8(%ebp),%edx
801050e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801050e6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801050ea:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801050ed:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801050f1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801050f5:	ee                   	out    %al,(%dx)
}
801050f6:	90                   	nop
801050f7:	c9                   	leave  
801050f8:	c3                   	ret    

801050f9 <picsetmask>:
// Current IRQ mask.
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1 << IRQ_SLAVE);

static void picsetmask(ushort mask)
{
801050f9:	55                   	push   %ebp
801050fa:	89 e5                	mov    %esp,%ebp
801050fc:	83 ec 04             	sub    $0x4,%esp
801050ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105102:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
	irqmask = mask;
80105106:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010510a:	66 a3 00 e0 10 80    	mov    %ax,0x8010e000
	outb(IO_PIC1 + 1, mask);
80105110:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80105114:	0f b6 c0             	movzbl %al,%eax
80105117:	50                   	push   %eax
80105118:	6a 21                	push   $0x21
8010511a:	e8 bb ff ff ff       	call   801050da <outb>
8010511f:	83 c4 08             	add    $0x8,%esp
	outb(IO_PIC2 + 1, mask >> 8);
80105122:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80105126:	66 c1 e8 08          	shr    $0x8,%ax
8010512a:	0f b6 c0             	movzbl %al,%eax
8010512d:	50                   	push   %eax
8010512e:	68 a1 00 00 00       	push   $0xa1
80105133:	e8 a2 ff ff ff       	call   801050da <outb>
80105138:	83 c4 08             	add    $0x8,%esp
}
8010513b:	90                   	nop
8010513c:	c9                   	leave  
8010513d:	c3                   	ret    

8010513e <picenable>:

void picenable(int irq)
{
8010513e:	55                   	push   %ebp
8010513f:	89 e5                	mov    %esp,%ebp
	picsetmask(irqmask & ~(1 << irq));
80105141:	8b 45 08             	mov    0x8(%ebp),%eax
80105144:	ba 01 00 00 00       	mov    $0x1,%edx
80105149:	89 c1                	mov    %eax,%ecx
8010514b:	d3 e2                	shl    %cl,%edx
8010514d:	89 d0                	mov    %edx,%eax
8010514f:	f7 d0                	not    %eax
80105151:	89 c2                	mov    %eax,%edx
80105153:	0f b7 05 00 e0 10 80 	movzwl 0x8010e000,%eax
8010515a:	21 d0                	and    %edx,%eax
8010515c:	0f b7 c0             	movzwl %ax,%eax
8010515f:	50                   	push   %eax
80105160:	e8 94 ff ff ff       	call   801050f9 <picsetmask>
80105165:	83 c4 04             	add    $0x4,%esp
}
80105168:	90                   	nop
80105169:	c9                   	leave  
8010516a:	c3                   	ret    

8010516b <picinit>:

// Initialize the 8259A interrupt controllers.
void picinit(void)
{
8010516b:	55                   	push   %ebp
8010516c:	89 e5                	mov    %esp,%ebp
	// mask all interrupts
	outb(IO_PIC1 + 1, 0xFF);
8010516e:	68 ff 00 00 00       	push   $0xff
80105173:	6a 21                	push   $0x21
80105175:	e8 60 ff ff ff       	call   801050da <outb>
8010517a:	83 c4 08             	add    $0x8,%esp
	outb(IO_PIC2 + 1, 0xFF);
8010517d:	68 ff 00 00 00       	push   $0xff
80105182:	68 a1 00 00 00       	push   $0xa1
80105187:	e8 4e ff ff ff       	call   801050da <outb>
8010518c:	83 c4 08             	add    $0x8,%esp

	// ICW1:  0001g0hi
	//    g:  0 = edge triggering, 1 = level triggering
	//    h:  0 = cascaded PICs, 1 = master only
	//    i:  0 = no ICW4, 1 = ICW4 required
	outb(IO_PIC1, 0x11);
8010518f:	6a 11                	push   $0x11
80105191:	6a 20                	push   $0x20
80105193:	e8 42 ff ff ff       	call   801050da <outb>
80105198:	83 c4 08             	add    $0x8,%esp

	// ICW2:  Vector offset
	outb(IO_PIC1 + 1, T_IRQ0);
8010519b:	6a 20                	push   $0x20
8010519d:	6a 21                	push   $0x21
8010519f:	e8 36 ff ff ff       	call   801050da <outb>
801051a4:	83 c4 08             	add    $0x8,%esp

	// ICW3:  (master PIC) bit mask of IR lines connected to slaves
	//        (slave PIC) 3-bit # of slave's connection to master
	outb(IO_PIC1 + 1, 1 << IRQ_SLAVE);
801051a7:	6a 04                	push   $0x4
801051a9:	6a 21                	push   $0x21
801051ab:	e8 2a ff ff ff       	call   801050da <outb>
801051b0:	83 c4 08             	add    $0x8,%esp
	//    m:  0 = slave PIC, 1 = master PIC
	//      (ignored when b is 0, as the master/slave role
	//      can be hardwired).
	//    a:  1 = Automatic EOI mode
	//    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
	outb(IO_PIC1 + 1, 0x3);
801051b3:	6a 03                	push   $0x3
801051b5:	6a 21                	push   $0x21
801051b7:	e8 1e ff ff ff       	call   801050da <outb>
801051bc:	83 c4 08             	add    $0x8,%esp

	// Set up slave (8259A-2)
	outb(IO_PIC2, 0x11);	// ICW1
801051bf:	6a 11                	push   $0x11
801051c1:	68 a0 00 00 00       	push   $0xa0
801051c6:	e8 0f ff ff ff       	call   801050da <outb>
801051cb:	83 c4 08             	add    $0x8,%esp
	outb(IO_PIC2 + 1, T_IRQ0 + 8);	// ICW2
801051ce:	6a 28                	push   $0x28
801051d0:	68 a1 00 00 00       	push   $0xa1
801051d5:	e8 00 ff ff ff       	call   801050da <outb>
801051da:	83 c4 08             	add    $0x8,%esp
	outb(IO_PIC2 + 1, IRQ_SLAVE);	// ICW3
801051dd:	6a 02                	push   $0x2
801051df:	68 a1 00 00 00       	push   $0xa1
801051e4:	e8 f1 fe ff ff       	call   801050da <outb>
801051e9:	83 c4 08             	add    $0x8,%esp
	// NB Automatic EOI mode doesn't tend to work on the slave.
	// Linux source code says it's "to be investigated".
	outb(IO_PIC2 + 1, 0x3);	// ICW4
801051ec:	6a 03                	push   $0x3
801051ee:	68 a1 00 00 00       	push   $0xa1
801051f3:	e8 e2 fe ff ff       	call   801050da <outb>
801051f8:	83 c4 08             	add    $0x8,%esp

	// OCW3:  0ef01prs
	//   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
	//    p:  0 = no polling, 1 = polling mode
	//   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
	outb(IO_PIC1, 0x68);	// clear specific mask
801051fb:	6a 68                	push   $0x68
801051fd:	6a 20                	push   $0x20
801051ff:	e8 d6 fe ff ff       	call   801050da <outb>
80105204:	83 c4 08             	add    $0x8,%esp
	outb(IO_PIC1, 0x0a);	// read IRR by default
80105207:	6a 0a                	push   $0xa
80105209:	6a 20                	push   $0x20
8010520b:	e8 ca fe ff ff       	call   801050da <outb>
80105210:	83 c4 08             	add    $0x8,%esp

	outb(IO_PIC2, 0x68);	// OCW3
80105213:	6a 68                	push   $0x68
80105215:	68 a0 00 00 00       	push   $0xa0
8010521a:	e8 bb fe ff ff       	call   801050da <outb>
8010521f:	83 c4 08             	add    $0x8,%esp
	outb(IO_PIC2, 0x0a);	// OCW3
80105222:	6a 0a                	push   $0xa
80105224:	68 a0 00 00 00       	push   $0xa0
80105229:	e8 ac fe ff ff       	call   801050da <outb>
8010522e:	83 c4 08             	add    $0x8,%esp

	if (irqmask != 0xFFFF)
80105231:	0f b7 05 00 e0 10 80 	movzwl 0x8010e000,%eax
80105238:	66 83 f8 ff          	cmp    $0xffff,%ax
8010523c:	74 13                	je     80105251 <picinit+0xe6>
		picsetmask(irqmask);
8010523e:	0f b7 05 00 e0 10 80 	movzwl 0x8010e000,%eax
80105245:	0f b7 c0             	movzwl %ax,%eax
80105248:	50                   	push   %eax
80105249:	e8 ab fe ff ff       	call   801050f9 <picsetmask>
8010524e:	83 c4 04             	add    $0x4,%esp
}
80105251:	90                   	nop
80105252:	c9                   	leave  
80105253:	c3                   	ret    

80105254 <pipealloc>:
	int readopen;		// read fd is still open
	int writeopen;		// write fd is still open
};

int pipealloc(struct file **f0, struct file **f1)
{
80105254:	55                   	push   %ebp
80105255:	89 e5                	mov    %esp,%ebp
80105257:	83 ec 18             	sub    $0x18,%esp
	struct pipe *p;

	p = 0;
8010525a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	*f0 = *f1 = 0;
80105261:	8b 45 0c             	mov    0xc(%ebp),%eax
80105264:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010526a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010526d:	8b 10                	mov    (%eax),%edx
8010526f:	8b 45 08             	mov    0x8(%ebp),%eax
80105272:	89 10                	mov    %edx,(%eax)
	if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80105274:	e8 1e bd ff ff       	call   80100f97 <filealloc>
80105279:	89 c2                	mov    %eax,%edx
8010527b:	8b 45 08             	mov    0x8(%ebp),%eax
8010527e:	89 10                	mov    %edx,(%eax)
80105280:	8b 45 08             	mov    0x8(%ebp),%eax
80105283:	8b 00                	mov    (%eax),%eax
80105285:	85 c0                	test   %eax,%eax
80105287:	0f 84 cb 00 00 00    	je     80105358 <pipealloc+0x104>
8010528d:	e8 05 bd ff ff       	call   80100f97 <filealloc>
80105292:	89 c2                	mov    %eax,%edx
80105294:	8b 45 0c             	mov    0xc(%ebp),%eax
80105297:	89 10                	mov    %edx,(%eax)
80105299:	8b 45 0c             	mov    0xc(%ebp),%eax
8010529c:	8b 00                	mov    (%eax),%eax
8010529e:	85 c0                	test   %eax,%eax
801052a0:	0f 84 b2 00 00 00    	je     80105358 <pipealloc+0x104>
		goto bad;
	if ((p = (struct pipe *)kalloc()) == 0)
801052a6:	e8 bf d9 ff ff       	call   80102c6a <kalloc>
801052ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052b2:	0f 84 9f 00 00 00    	je     80105357 <pipealloc+0x103>
		goto bad;
	p->readopen = 1;
801052b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052bb:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801052c2:	00 00 00 
	p->writeopen = 1;
801052c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052c8:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801052cf:	00 00 00 
	p->nwrite = 0;
801052d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052d5:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801052dc:	00 00 00 
	p->nread = 0;
801052df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e2:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801052e9:	00 00 00 
	initlock(&p->lock, "pipe");
801052ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ef:	83 ec 08             	sub    $0x8,%esp
801052f2:	68 88 ab 10 80       	push   $0x8010ab88
801052f7:	50                   	push   %eax
801052f8:	e8 6e 17 00 00       	call   80106a6b <initlock>
801052fd:	83 c4 10             	add    $0x10,%esp
	(*f0)->type = FD_PIPE;
80105300:	8b 45 08             	mov    0x8(%ebp),%eax
80105303:	8b 00                	mov    (%eax),%eax
80105305:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
	(*f0)->readable = 1;
8010530b:	8b 45 08             	mov    0x8(%ebp),%eax
8010530e:	8b 00                	mov    (%eax),%eax
80105310:	c6 40 08 01          	movb   $0x1,0x8(%eax)
	(*f0)->writable = 0;
80105314:	8b 45 08             	mov    0x8(%ebp),%eax
80105317:	8b 00                	mov    (%eax),%eax
80105319:	c6 40 09 00          	movb   $0x0,0x9(%eax)
	(*f0)->pipe = p;
8010531d:	8b 45 08             	mov    0x8(%ebp),%eax
80105320:	8b 00                	mov    (%eax),%eax
80105322:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105325:	89 50 0c             	mov    %edx,0xc(%eax)
	(*f1)->type = FD_PIPE;
80105328:	8b 45 0c             	mov    0xc(%ebp),%eax
8010532b:	8b 00                	mov    (%eax),%eax
8010532d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
	(*f1)->readable = 0;
80105333:	8b 45 0c             	mov    0xc(%ebp),%eax
80105336:	8b 00                	mov    (%eax),%eax
80105338:	c6 40 08 00          	movb   $0x0,0x8(%eax)
	(*f1)->writable = 1;
8010533c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010533f:	8b 00                	mov    (%eax),%eax
80105341:	c6 40 09 01          	movb   $0x1,0x9(%eax)
	(*f1)->pipe = p;
80105345:	8b 45 0c             	mov    0xc(%ebp),%eax
80105348:	8b 00                	mov    (%eax),%eax
8010534a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010534d:	89 50 0c             	mov    %edx,0xc(%eax)
	return 0;
80105350:	b8 00 00 00 00       	mov    $0x0,%eax
80105355:	eb 4e                	jmp    801053a5 <pipealloc+0x151>
	p = 0;
	*f0 = *f1 = 0;
	if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
		goto bad;
	if ((p = (struct pipe *)kalloc()) == 0)
		goto bad;
80105357:	90                   	nop
	(*f1)->pipe = p;
	return 0;

//PAGEBREAK: 20
 bad:
	if (p)
80105358:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010535c:	74 0e                	je     8010536c <pipealloc+0x118>
		kfree((char *)p);
8010535e:	83 ec 0c             	sub    $0xc,%esp
80105361:	ff 75 f4             	pushl  -0xc(%ebp)
80105364:	e8 64 d8 ff ff       	call   80102bcd <kfree>
80105369:	83 c4 10             	add    $0x10,%esp
	if (*f0)
8010536c:	8b 45 08             	mov    0x8(%ebp),%eax
8010536f:	8b 00                	mov    (%eax),%eax
80105371:	85 c0                	test   %eax,%eax
80105373:	74 11                	je     80105386 <pipealloc+0x132>
		fileclose(*f0);
80105375:	8b 45 08             	mov    0x8(%ebp),%eax
80105378:	8b 00                	mov    (%eax),%eax
8010537a:	83 ec 0c             	sub    $0xc,%esp
8010537d:	50                   	push   %eax
8010537e:	e8 d2 bc ff ff       	call   80101055 <fileclose>
80105383:	83 c4 10             	add    $0x10,%esp
	if (*f1)
80105386:	8b 45 0c             	mov    0xc(%ebp),%eax
80105389:	8b 00                	mov    (%eax),%eax
8010538b:	85 c0                	test   %eax,%eax
8010538d:	74 11                	je     801053a0 <pipealloc+0x14c>
		fileclose(*f1);
8010538f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105392:	8b 00                	mov    (%eax),%eax
80105394:	83 ec 0c             	sub    $0xc,%esp
80105397:	50                   	push   %eax
80105398:	e8 b8 bc ff ff       	call   80101055 <fileclose>
8010539d:	83 c4 10             	add    $0x10,%esp
	return -1;
801053a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801053a5:	c9                   	leave  
801053a6:	c3                   	ret    

801053a7 <pipeclose>:

void pipeclose(struct pipe *p, int writable)
{
801053a7:	55                   	push   %ebp
801053a8:	89 e5                	mov    %esp,%ebp
801053aa:	83 ec 08             	sub    $0x8,%esp
	acquire(&p->lock);
801053ad:	8b 45 08             	mov    0x8(%ebp),%eax
801053b0:	83 ec 0c             	sub    $0xc,%esp
801053b3:	50                   	push   %eax
801053b4:	e8 d4 16 00 00       	call   80106a8d <acquire>
801053b9:	83 c4 10             	add    $0x10,%esp
	if (writable) {
801053bc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801053c0:	74 23                	je     801053e5 <pipeclose+0x3e>
		p->writeopen = 0;
801053c2:	8b 45 08             	mov    0x8(%ebp),%eax
801053c5:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801053cc:	00 00 00 
		wakeup(&p->nread);
801053cf:	8b 45 08             	mov    0x8(%ebp),%eax
801053d2:	05 34 02 00 00       	add    $0x234,%eax
801053d7:	83 ec 0c             	sub    $0xc,%esp
801053da:	50                   	push   %eax
801053db:	e8 04 0f 00 00       	call   801062e4 <wakeup>
801053e0:	83 c4 10             	add    $0x10,%esp
801053e3:	eb 21                	jmp    80105406 <pipeclose+0x5f>
	} else {
		p->readopen = 0;
801053e5:	8b 45 08             	mov    0x8(%ebp),%eax
801053e8:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801053ef:	00 00 00 
		wakeup(&p->nwrite);
801053f2:	8b 45 08             	mov    0x8(%ebp),%eax
801053f5:	05 38 02 00 00       	add    $0x238,%eax
801053fa:	83 ec 0c             	sub    $0xc,%esp
801053fd:	50                   	push   %eax
801053fe:	e8 e1 0e 00 00       	call   801062e4 <wakeup>
80105403:	83 c4 10             	add    $0x10,%esp
	}
	if (p->readopen == 0 && p->writeopen == 0) {
80105406:	8b 45 08             	mov    0x8(%ebp),%eax
80105409:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010540f:	85 c0                	test   %eax,%eax
80105411:	75 2c                	jne    8010543f <pipeclose+0x98>
80105413:	8b 45 08             	mov    0x8(%ebp),%eax
80105416:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010541c:	85 c0                	test   %eax,%eax
8010541e:	75 1f                	jne    8010543f <pipeclose+0x98>
		release(&p->lock);
80105420:	8b 45 08             	mov    0x8(%ebp),%eax
80105423:	83 ec 0c             	sub    $0xc,%esp
80105426:	50                   	push   %eax
80105427:	e8 c8 16 00 00       	call   80106af4 <release>
8010542c:	83 c4 10             	add    $0x10,%esp
		kfree((char *)p);
8010542f:	83 ec 0c             	sub    $0xc,%esp
80105432:	ff 75 08             	pushl  0x8(%ebp)
80105435:	e8 93 d7 ff ff       	call   80102bcd <kfree>
8010543a:	83 c4 10             	add    $0x10,%esp
8010543d:	eb 0f                	jmp    8010544e <pipeclose+0xa7>
	} else
		release(&p->lock);
8010543f:	8b 45 08             	mov    0x8(%ebp),%eax
80105442:	83 ec 0c             	sub    $0xc,%esp
80105445:	50                   	push   %eax
80105446:	e8 a9 16 00 00       	call   80106af4 <release>
8010544b:	83 c4 10             	add    $0x10,%esp
}
8010544e:	90                   	nop
8010544f:	c9                   	leave  
80105450:	c3                   	ret    

80105451 <pipewrite>:

//PAGEBREAK: 40
int pipewrite(struct pipe *p, char *addr, int n)
{
80105451:	55                   	push   %ebp
80105452:	89 e5                	mov    %esp,%ebp
80105454:	83 ec 18             	sub    $0x18,%esp
	int i;

	acquire(&p->lock);
80105457:	8b 45 08             	mov    0x8(%ebp),%eax
8010545a:	83 ec 0c             	sub    $0xc,%esp
8010545d:	50                   	push   %eax
8010545e:	e8 2a 16 00 00       	call   80106a8d <acquire>
80105463:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i++) {
80105466:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010546d:	e9 ad 00 00 00       	jmp    8010551f <pipewrite+0xce>
		while (p->nwrite == p->nread + PIPESIZE) {	//DOC: pipewrite-full
			if (p->readopen == 0 || proc->killed) {
80105472:	8b 45 08             	mov    0x8(%ebp),%eax
80105475:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010547b:	85 c0                	test   %eax,%eax
8010547d:	74 0d                	je     8010548c <pipewrite+0x3b>
8010547f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105485:	8b 40 24             	mov    0x24(%eax),%eax
80105488:	85 c0                	test   %eax,%eax
8010548a:	74 19                	je     801054a5 <pipewrite+0x54>
				release(&p->lock);
8010548c:	8b 45 08             	mov    0x8(%ebp),%eax
8010548f:	83 ec 0c             	sub    $0xc,%esp
80105492:	50                   	push   %eax
80105493:	e8 5c 16 00 00       	call   80106af4 <release>
80105498:	83 c4 10             	add    $0x10,%esp
				return -1;
8010549b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054a0:	e9 a8 00 00 00       	jmp    8010554d <pipewrite+0xfc>
			}
			wakeup(&p->nread);
801054a5:	8b 45 08             	mov    0x8(%ebp),%eax
801054a8:	05 34 02 00 00       	add    $0x234,%eax
801054ad:	83 ec 0c             	sub    $0xc,%esp
801054b0:	50                   	push   %eax
801054b1:	e8 2e 0e 00 00       	call   801062e4 <wakeup>
801054b6:	83 c4 10             	add    $0x10,%esp
			sleep(&p->nwrite, &p->lock);	//DOC: pipewrite-sleep
801054b9:	8b 45 08             	mov    0x8(%ebp),%eax
801054bc:	8b 55 08             	mov    0x8(%ebp),%edx
801054bf:	81 c2 38 02 00 00    	add    $0x238,%edx
801054c5:	83 ec 08             	sub    $0x8,%esp
801054c8:	50                   	push   %eax
801054c9:	52                   	push   %edx
801054ca:	e8 27 0d 00 00       	call   801061f6 <sleep>
801054cf:	83 c4 10             	add    $0x10,%esp
{
	int i;

	acquire(&p->lock);
	for (i = 0; i < n; i++) {
		while (p->nwrite == p->nread + PIPESIZE) {	//DOC: pipewrite-full
801054d2:	8b 45 08             	mov    0x8(%ebp),%eax
801054d5:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801054db:	8b 45 08             	mov    0x8(%ebp),%eax
801054de:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801054e4:	05 00 02 00 00       	add    $0x200,%eax
801054e9:	39 c2                	cmp    %eax,%edx
801054eb:	74 85                	je     80105472 <pipewrite+0x21>
				return -1;
			}
			wakeup(&p->nread);
			sleep(&p->nwrite, &p->lock);	//DOC: pipewrite-sleep
		}
		p->data[p->nwrite++ % PIPESIZE] = addr[i];
801054ed:	8b 45 08             	mov    0x8(%ebp),%eax
801054f0:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801054f6:	8d 48 01             	lea    0x1(%eax),%ecx
801054f9:	8b 55 08             	mov    0x8(%ebp),%edx
801054fc:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80105502:	25 ff 01 00 00       	and    $0x1ff,%eax
80105507:	89 c1                	mov    %eax,%ecx
80105509:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010550c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010550f:	01 d0                	add    %edx,%eax
80105511:	0f b6 10             	movzbl (%eax),%edx
80105514:	8b 45 08             	mov    0x8(%ebp),%eax
80105517:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
int pipewrite(struct pipe *p, char *addr, int n)
{
	int i;

	acquire(&p->lock);
	for (i = 0; i < n; i++) {
8010551b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010551f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105522:	3b 45 10             	cmp    0x10(%ebp),%eax
80105525:	7c ab                	jl     801054d2 <pipewrite+0x81>
			wakeup(&p->nread);
			sleep(&p->nwrite, &p->lock);	//DOC: pipewrite-sleep
		}
		p->data[p->nwrite++ % PIPESIZE] = addr[i];
	}
	wakeup(&p->nread);	//DOC: pipewrite-wakeup1
80105527:	8b 45 08             	mov    0x8(%ebp),%eax
8010552a:	05 34 02 00 00       	add    $0x234,%eax
8010552f:	83 ec 0c             	sub    $0xc,%esp
80105532:	50                   	push   %eax
80105533:	e8 ac 0d 00 00       	call   801062e4 <wakeup>
80105538:	83 c4 10             	add    $0x10,%esp
	release(&p->lock);
8010553b:	8b 45 08             	mov    0x8(%ebp),%eax
8010553e:	83 ec 0c             	sub    $0xc,%esp
80105541:	50                   	push   %eax
80105542:	e8 ad 15 00 00       	call   80106af4 <release>
80105547:	83 c4 10             	add    $0x10,%esp
	return n;
8010554a:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010554d:	c9                   	leave  
8010554e:	c3                   	ret    

8010554f <piperead>:

int piperead(struct pipe *p, char *addr, int n)
{
8010554f:	55                   	push   %ebp
80105550:	89 e5                	mov    %esp,%ebp
80105552:	53                   	push   %ebx
80105553:	83 ec 14             	sub    $0x14,%esp
	int i;

	acquire(&p->lock);
80105556:	8b 45 08             	mov    0x8(%ebp),%eax
80105559:	83 ec 0c             	sub    $0xc,%esp
8010555c:	50                   	push   %eax
8010555d:	e8 2b 15 00 00       	call   80106a8d <acquire>
80105562:	83 c4 10             	add    $0x10,%esp
	while (p->nread == p->nwrite && p->writeopen) {	//DOC: pipe-empty
80105565:	eb 3f                	jmp    801055a6 <piperead+0x57>
		if (proc->killed) {
80105567:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010556d:	8b 40 24             	mov    0x24(%eax),%eax
80105570:	85 c0                	test   %eax,%eax
80105572:	74 19                	je     8010558d <piperead+0x3e>
			release(&p->lock);
80105574:	8b 45 08             	mov    0x8(%ebp),%eax
80105577:	83 ec 0c             	sub    $0xc,%esp
8010557a:	50                   	push   %eax
8010557b:	e8 74 15 00 00       	call   80106af4 <release>
80105580:	83 c4 10             	add    $0x10,%esp
			return -1;
80105583:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105588:	e9 bf 00 00 00       	jmp    8010564c <piperead+0xfd>
		}
		sleep(&p->nread, &p->lock);	//DOC: piperead-sleep
8010558d:	8b 45 08             	mov    0x8(%ebp),%eax
80105590:	8b 55 08             	mov    0x8(%ebp),%edx
80105593:	81 c2 34 02 00 00    	add    $0x234,%edx
80105599:	83 ec 08             	sub    $0x8,%esp
8010559c:	50                   	push   %eax
8010559d:	52                   	push   %edx
8010559e:	e8 53 0c 00 00       	call   801061f6 <sleep>
801055a3:	83 c4 10             	add    $0x10,%esp
int piperead(struct pipe *p, char *addr, int n)
{
	int i;

	acquire(&p->lock);
	while (p->nread == p->nwrite && p->writeopen) {	//DOC: pipe-empty
801055a6:	8b 45 08             	mov    0x8(%ebp),%eax
801055a9:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801055af:	8b 45 08             	mov    0x8(%ebp),%eax
801055b2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801055b8:	39 c2                	cmp    %eax,%edx
801055ba:	75 0d                	jne    801055c9 <piperead+0x7a>
801055bc:	8b 45 08             	mov    0x8(%ebp),%eax
801055bf:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801055c5:	85 c0                	test   %eax,%eax
801055c7:	75 9e                	jne    80105567 <piperead+0x18>
			release(&p->lock);
			return -1;
		}
		sleep(&p->nread, &p->lock);	//DOC: piperead-sleep
	}
	for (i = 0; i < n; i++) {	//DOC: piperead-copy
801055c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801055d0:	eb 49                	jmp    8010561b <piperead+0xcc>
		if (p->nread == p->nwrite)
801055d2:	8b 45 08             	mov    0x8(%ebp),%eax
801055d5:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801055db:	8b 45 08             	mov    0x8(%ebp),%eax
801055de:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801055e4:	39 c2                	cmp    %eax,%edx
801055e6:	74 3d                	je     80105625 <piperead+0xd6>
			break;
		addr[i] = p->data[p->nread++ % PIPESIZE];
801055e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ee:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801055f1:	8b 45 08             	mov    0x8(%ebp),%eax
801055f4:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801055fa:	8d 48 01             	lea    0x1(%eax),%ecx
801055fd:	8b 55 08             	mov    0x8(%ebp),%edx
80105600:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80105606:	25 ff 01 00 00       	and    $0x1ff,%eax
8010560b:	89 c2                	mov    %eax,%edx
8010560d:	8b 45 08             	mov    0x8(%ebp),%eax
80105610:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80105615:	88 03                	mov    %al,(%ebx)
			release(&p->lock);
			return -1;
		}
		sleep(&p->nread, &p->lock);	//DOC: piperead-sleep
	}
	for (i = 0; i < n; i++) {	//DOC: piperead-copy
80105617:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010561b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010561e:	3b 45 10             	cmp    0x10(%ebp),%eax
80105621:	7c af                	jl     801055d2 <piperead+0x83>
80105623:	eb 01                	jmp    80105626 <piperead+0xd7>
		if (p->nread == p->nwrite)
			break;
80105625:	90                   	nop
		addr[i] = p->data[p->nread++ % PIPESIZE];
	}
	wakeup(&p->nwrite);	//DOC: piperead-wakeup
80105626:	8b 45 08             	mov    0x8(%ebp),%eax
80105629:	05 38 02 00 00       	add    $0x238,%eax
8010562e:	83 ec 0c             	sub    $0xc,%esp
80105631:	50                   	push   %eax
80105632:	e8 ad 0c 00 00       	call   801062e4 <wakeup>
80105637:	83 c4 10             	add    $0x10,%esp
	release(&p->lock);
8010563a:	8b 45 08             	mov    0x8(%ebp),%eax
8010563d:	83 ec 0c             	sub    $0xc,%esp
80105640:	50                   	push   %eax
80105641:	e8 ae 14 00 00       	call   80106af4 <release>
80105646:	83 c4 10             	add    $0x10,%esp
	return i;
80105649:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010564c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010564f:	c9                   	leave  
80105650:	c3                   	ret    

80105651 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105651:	55                   	push   %ebp
80105652:	89 e5                	mov    %esp,%ebp
80105654:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105657:	9c                   	pushf  
80105658:	58                   	pop    %eax
80105659:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010565c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010565f:	c9                   	leave  
80105660:	c3                   	ret    

80105661 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80105661:	55                   	push   %ebp
80105662:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105664:	fb                   	sti    
}
80105665:	90                   	nop
80105666:	5d                   	pop    %ebp
80105667:	c3                   	ret    

80105668 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105668:	55                   	push   %ebp
80105669:	89 e5                	mov    %esp,%ebp
8010566b:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010566e:	8b 55 08             	mov    0x8(%ebp),%edx
80105671:	8b 45 0c             	mov    0xc(%ebp),%eax
80105674:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105677:	f0 87 02             	lock xchg %eax,(%edx)
8010567a:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010567d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105680:	c9                   	leave  
80105681:	c3                   	ret    

80105682 <mxarray_init>:


//Create the data structure holding mutexes
//Initialized to zero
void mxarray_init(void)
{
80105682:	55                   	push   %ebp
80105683:	89 e5                	mov    %esp,%ebp
80105685:	83 ec 10             	sub    $0x10,%esp
    int count;
    for(count=0; count < MUX_MAXNUM; count++){
80105688:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010568f:	eb 7c                	jmp    8010570d <mxarray_init+0x8b>

        mxarray[count].name = 0;
80105691:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105694:	89 d0                	mov    %edx,%eax
80105696:	c1 e0 02             	shl    $0x2,%eax
80105699:	01 d0                	add    %edx,%eax
8010569b:	c1 e0 02             	shl    $0x2,%eax
8010569e:	05 28 5d 11 80       	add    $0x80115d28,%eax
801056a3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mxarray[count].name_len = 0;
801056a9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056ac:	89 d0                	mov    %edx,%eax
801056ae:	c1 e0 02             	shl    $0x2,%eax
801056b1:	01 d0                	add    %edx,%eax
801056b3:	c1 e0 02             	shl    $0x2,%eax
801056b6:	05 2c 5d 11 80       	add    $0x80115d2c,%eax
801056bb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mxarray[count].lock = 0;
801056c1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056c4:	89 d0                	mov    %edx,%eax
801056c6:	c1 e0 02             	shl    $0x2,%eax
801056c9:	01 d0                	add    %edx,%eax
801056cb:	c1 e0 02             	shl    $0x2,%eax
801056ce:	05 20 5d 11 80       	add    $0x80115d20,%eax
801056d3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        mxarray[count].id = count;
801056d9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056dc:	89 d0                	mov    %edx,%eax
801056de:	c1 e0 02             	shl    $0x2,%eax
801056e1:	01 d0                	add    %edx,%eax
801056e3:	c1 e0 02             	shl    $0x2,%eax
801056e6:	8d 90 24 5d 11 80    	lea    -0x7feea2dc(%eax),%edx
801056ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056ef:	89 02                	mov    %eax,(%edx)
	mxarray[count].num_proc = 0;
801056f1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056f4:	89 d0                	mov    %edx,%eax
801056f6:	c1 e0 02             	shl    $0x2,%eax
801056f9:	01 d0                	add    %edx,%eax
801056fb:	c1 e0 02             	shl    $0x2,%eax
801056fe:	05 30 5d 11 80       	add    $0x80115d30,%eax
80105703:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
//Create the data structure holding mutexes
//Initialized to zero
void mxarray_init(void)
{
    int count;
    for(count=0; count < MUX_MAXNUM; count++){
80105709:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010570d:	83 7d fc 09          	cmpl   $0x9,-0x4(%ebp)
80105711:	0f 8e 7a ff ff ff    	jle    80105691 <mxarray_init+0xf>
	mxarray[count].lock = 0;
        mxarray[count].id = count;
	mxarray[count].num_proc = 0;
    }

}
80105717:	90                   	nop
80105718:	c9                   	leave  
80105719:	c3                   	ret    

8010571a <pinit>:
extern void trapret(void);

static void wakeup1(void *chan);

void pinit(void) //initializes ptable
{
8010571a:	55                   	push   %ebp
8010571b:	89 e5                	mov    %esp,%ebp
8010571d:	83 ec 08             	sub    $0x8,%esp
	ptable.highpid = 0; //scheduler
80105720:	c7 05 34 47 12 80 00 	movl   $0x0,0x80124734
80105727:	00 00 00 
	initlock(&ptable.lock, "ptable");
8010572a:	83 ec 08             	sub    $0x8,%esp
8010572d:	68 8d ab 10 80       	push   $0x8010ab8d
80105732:	68 00 5e 11 80       	push   $0x80115e00
80105737:	e8 2f 13 00 00       	call   80106a6b <initlock>
8010573c:	83 c4 10             	add    $0x10,%esp
}
8010573f:	90                   	nop
80105740:	c9                   	leave  
80105741:	c3                   	ret    

80105742 <allocproc>:
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc *allocproc(void)
{
80105742:	55                   	push   %ebp
80105743:	89 e5                	mov    %esp,%ebp
80105745:	83 ec 18             	sub    $0x18,%esp
	struct proc *p;
	char *sp;

	acquire(&ptable.lock);
80105748:	83 ec 0c             	sub    $0xc,%esp
8010574b:	68 00 5e 11 80       	push   $0x80115e00
80105750:	e8 38 13 00 00       	call   80106a8d <acquire>
80105755:	83 c4 10             	add    $0x10,%esp
	for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105758:	c7 45 f4 34 5e 11 80 	movl   $0x80115e34,-0xc(%ebp)
8010575f:	eb 11                	jmp    80105772 <allocproc+0x30>
		if (p->state == UNUSED)
80105761:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105764:	8b 40 0c             	mov    0xc(%eax),%eax
80105767:	85 c0                	test   %eax,%eax
80105769:	74 2a                	je     80105795 <allocproc+0x53>
{
	struct proc *p;
	char *sp;

	acquire(&ptable.lock);
	for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010576b:	81 45 f4 a4 03 00 00 	addl   $0x3a4,-0xc(%ebp)
80105772:	81 7d f4 34 47 12 80 	cmpl   $0x80124734,-0xc(%ebp)
80105779:	72 e6                	jb     80105761 <allocproc+0x1f>
		if (p->state == UNUSED)
			goto found;
	release(&ptable.lock);
8010577b:	83 ec 0c             	sub    $0xc,%esp
8010577e:	68 00 5e 11 80       	push   $0x80115e00
80105783:	e8 6c 13 00 00       	call   80106af4 <release>
80105788:	83 c4 10             	add    $0x10,%esp
	return 0;
8010578b:	b8 00 00 00 00       	mov    $0x0,%eax
80105790:	e9 db 00 00 00       	jmp    80105870 <allocproc+0x12e>
	char *sp;

	acquire(&ptable.lock);
	for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
		if (p->state == UNUSED)
			goto found;
80105795:	90                   	nop
	release(&ptable.lock);
	return 0;

 found:
	p->state = EMBRYO;
80105796:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105799:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
	p->pid = nextpid++;
801057a0:	a1 04 e0 10 80       	mov    0x8010e004,%eax
801057a5:	8d 50 01             	lea    0x1(%eax),%edx
801057a8:	89 15 04 e0 10 80    	mov    %edx,0x8010e004
801057ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057b1:	89 42 10             	mov    %eax,0x10(%edx)
	//Mod3: Init per process mutex array
	for(int i=0; i<MUX_MAXNUM; i++){
801057b4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801057bb:	eb 18                	jmp    801057d5 <allocproc+0x93>
		p->mxproc[i] = -1;
801057bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801057c3:	81 c2 dc 00 00 00    	add    $0xdc,%edx
801057c9:	c7 44 90 0c ff ff ff 	movl   $0xffffffff,0xc(%eax,%edx,4)
801057d0:	ff 

 found:
	p->state = EMBRYO;
	p->pid = nextpid++;
	//Mod3: Init per process mutex array
	for(int i=0; i<MUX_MAXNUM; i++){
801057d1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801057d5:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
801057d9:	7e e2                	jle    801057bd <allocproc+0x7b>
		p->mxproc[i] = -1;
	}
	release(&ptable.lock);
801057db:	83 ec 0c             	sub    $0xc,%esp
801057de:	68 00 5e 11 80       	push   $0x80115e00
801057e3:	e8 0c 13 00 00       	call   80106af4 <release>
801057e8:	83 c4 10             	add    $0x10,%esp

	// Allocate kernel stack.
	if ((p->kstack = kalloc()) == 0) {
801057eb:	e8 7a d4 ff ff       	call   80102c6a <kalloc>
801057f0:	89 c2                	mov    %eax,%edx
801057f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f5:	89 50 08             	mov    %edx,0x8(%eax)
801057f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057fb:	8b 40 08             	mov    0x8(%eax),%eax
801057fe:	85 c0                	test   %eax,%eax
80105800:	75 11                	jne    80105813 <allocproc+0xd1>
		p->state = UNUSED;
80105802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105805:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
		return 0;
8010580c:	b8 00 00 00 00       	mov    $0x0,%eax
80105811:	eb 5d                	jmp    80105870 <allocproc+0x12e>
	}
	sp = p->kstack + KSTACKSIZE;
80105813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105816:	8b 40 08             	mov    0x8(%eax),%eax
80105819:	05 00 10 00 00       	add    $0x1000,%eax
8010581e:	89 45 ec             	mov    %eax,-0x14(%ebp)

	// Leave room for trap frame.
	sp -= sizeof *p->tf;
80105821:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
	p->tf = (struct trapframe *)sp;
80105825:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105828:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010582b:	89 50 18             	mov    %edx,0x18(%eax)

	// Set up new context to start executing at forkret,
	// which returns to trapret.
	sp -= 4;
8010582e:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
	*(uint *) sp = (uint) trapret;
80105832:	ba bc 83 10 80       	mov    $0x801083bc,%edx
80105837:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010583a:	89 10                	mov    %edx,(%eax)

	sp -= sizeof *p->context;
8010583c:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
	p->context = (struct context *)sp;
80105840:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105843:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105846:	89 50 1c             	mov    %edx,0x1c(%eax)
	memset(p->context, 0, sizeof *p->context);
80105849:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010584c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010584f:	83 ec 04             	sub    $0x4,%esp
80105852:	6a 14                	push   $0x14
80105854:	6a 00                	push   $0x0
80105856:	50                   	push   %eax
80105857:	e8 94 14 00 00       	call   80106cf0 <memset>
8010585c:	83 c4 10             	add    $0x10,%esp
	p->context->eip = (uint) forkret;
8010585f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105862:	8b 40 1c             	mov    0x1c(%eax),%eax
80105865:	ba b0 61 10 80       	mov    $0x801061b0,%edx
8010586a:	89 50 10             	mov    %edx,0x10(%eax)

	return p;
8010586d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105870:	c9                   	leave  
80105871:	c3                   	ret    

80105872 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void userinit(void)
{
80105872:	55                   	push   %ebp
80105873:	89 e5                	mov    %esp,%ebp
80105875:	83 ec 18             	sub    $0x18,%esp
	struct proc *p;
	extern char _binary_initcode_start[], _binary_initcode_size[];
	int i = 0;
80105878:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	p = allocproc();
8010587f:	e8 be fe ff ff       	call   80105742 <allocproc>
80105884:	89 45 f0             	mov    %eax,-0x10(%ebp)
	initproc = p;
80105887:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010588a:	a3 68 e6 10 80       	mov    %eax,0x8010e668
	if ((p->pgdir = setupkvm()) == 0)
8010588f:	e8 ed 41 00 00       	call   80109a81 <setupkvm>
80105894:	89 c2                	mov    %eax,%edx
80105896:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105899:	89 50 04             	mov    %edx,0x4(%eax)
8010589c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010589f:	8b 40 04             	mov    0x4(%eax),%eax
801058a2:	85 c0                	test   %eax,%eax
801058a4:	75 0d                	jne    801058b3 <userinit+0x41>
		panic("userinit: out of memory?");
801058a6:	83 ec 0c             	sub    $0xc,%esp
801058a9:	68 94 ab 10 80       	push   $0x8010ab94
801058ae:	e8 b3 ac ff ff       	call   80100566 <panic>
	inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801058b3:	ba 2c 00 00 00       	mov    $0x2c,%edx
801058b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058bb:	8b 40 04             	mov    0x4(%eax),%eax
801058be:	83 ec 04             	sub    $0x4,%esp
801058c1:	52                   	push   %edx
801058c2:	68 00 e5 10 80       	push   $0x8010e500
801058c7:	50                   	push   %eax
801058c8:	e8 0e 44 00 00       	call   80109cdb <inituvm>
801058cd:	83 c4 10             	add    $0x10,%esp
	p->sz = PGSIZE;
801058d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058d3:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
	memset(p->tf, 0, sizeof(*p->tf));
801058d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058dc:	8b 40 18             	mov    0x18(%eax),%eax
801058df:	83 ec 04             	sub    $0x4,%esp
801058e2:	6a 4c                	push   $0x4c
801058e4:	6a 00                	push   $0x0
801058e6:	50                   	push   %eax
801058e7:	e8 04 14 00 00       	call   80106cf0 <memset>
801058ec:	83 c4 10             	add    $0x10,%esp
	p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801058ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f2:	8b 40 18             	mov    0x18(%eax),%eax
801058f5:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
	p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801058fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058fe:	8b 40 18             	mov    0x18(%eax),%eax
80105901:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
	p->tf->es = p->tf->ds;
80105907:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010590a:	8b 40 18             	mov    0x18(%eax),%eax
8010590d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105910:	8b 52 18             	mov    0x18(%edx),%edx
80105913:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80105917:	66 89 50 28          	mov    %dx,0x28(%eax)
	p->tf->ss = p->tf->ds;
8010591b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010591e:	8b 40 18             	mov    0x18(%eax),%eax
80105921:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105924:	8b 52 18             	mov    0x18(%edx),%edx
80105927:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010592b:	66 89 50 48          	mov    %dx,0x48(%eax)
	p->tf->eflags = FL_IF;
8010592f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105932:	8b 40 18             	mov    0x18(%eax),%eax
80105935:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
	p->tf->esp = PGSIZE;
8010593c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010593f:	8b 40 18             	mov    0x18(%eax),%eax
80105942:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
	p->tf->eip = 0;		// beginning of initcode.S
80105949:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010594c:	8b 40 18             	mov    0x18(%eax),%eax
8010594f:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

	safestrcpy(p->name, "initcode", sizeof(p->name));
80105956:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105959:	83 c0 6c             	add    $0x6c,%eax
8010595c:	83 ec 04             	sub    $0x4,%esp
8010595f:	6a 10                	push   $0x10
80105961:	68 ad ab 10 80       	push   $0x8010abad
80105966:	50                   	push   %eax
80105967:	e8 87 15 00 00       	call   80106ef3 <safestrcpy>
8010596c:	83 c4 10             	add    $0x10,%esp
	p->cwd = namei("/");
8010596f:	83 ec 0c             	sub    $0xc,%esp
80105972:	68 b6 ab 10 80       	push   $0x8010abb6
80105977:	e8 b0 cb ff ff       	call   8010252c <namei>
8010597c:	83 c4 10             	add    $0x10,%esp
8010597f:	89 c2                	mov    %eax,%edx
80105981:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105984:	89 50 68             	mov    %edx,0x68(%eax)

	for(i = 0; i<SHM_MAXNUM; i++)
80105987:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010598e:	eb 52                	jmp    801059e2 <userinit+0x170>
	{
		safestrcpy(p->shm_name[i].name, "DNE", sizeof(p->shm_name[i].name)); //mod2
80105990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105993:	83 c0 07             	add    $0x7,%eax
80105996:	c1 e0 04             	shl    $0x4,%eax
80105999:	89 c2                	mov    %eax,%edx
8010599b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010599e:	01 d0                	add    %edx,%eax
801059a0:	83 c0 0c             	add    $0xc,%eax
801059a3:	83 ec 04             	sub    $0x4,%esp
801059a6:	6a 10                	push   $0x10
801059a8:	68 b8 ab 10 80       	push   $0x8010abb8
801059ad:	50                   	push   %eax
801059ae:	e8 40 15 00 00       	call   80106ef3 <safestrcpy>
801059b3:	83 c4 10             	add    $0x10,%esp
		//cprintf("Initialize PROC: %s\n", &(p->shm_name[i].name[0])); 
		p->shm_vir[i] = 0; //mod2
801059b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059bc:	81 c2 9c 00 00 00    	add    $0x9c,%edx
801059c2:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
801059c9:	00 
		p->shm_phys[i] = 0; //mod2
801059ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059d0:	81 c2 bc 00 00 00    	add    $0xbc,%edx
801059d6:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
801059dd:	00 
	p->tf->eip = 0;		// beginning of initcode.S

	safestrcpy(p->name, "initcode", sizeof(p->name));
	p->cwd = namei("/");

	for(i = 0; i<SHM_MAXNUM; i++)
801059de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801059e2:	83 7d f4 1f          	cmpl   $0x1f,-0xc(%ebp)
801059e6:	7e a8                	jle    80105990 <userinit+0x11e>
		//cprintf("Initialize PROC: %s\n", &(p->shm_name[i].name[0])); 
		p->shm_vir[i] = 0; //mod2
		p->shm_phys[i] = 0; //mod2
	}

	p->state = RUNNABLE;
801059e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059eb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801059f2:	90                   	nop
801059f3:	c9                   	leave  
801059f4:	c3                   	ret    

801059f5 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int growproc(int n)
{
801059f5:	55                   	push   %ebp
801059f6:	89 e5                	mov    %esp,%ebp
801059f8:	83 ec 18             	sub    $0x18,%esp
	uint sz;

	sz = proc->sz;
801059fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a01:	8b 00                	mov    (%eax),%eax
80105a03:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (n > 0) {
80105a06:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105a0a:	7e 31                	jle    80105a3d <growproc+0x48>
		if ((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80105a0c:	8b 55 08             	mov    0x8(%ebp),%edx
80105a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a12:	01 c2                	add    %eax,%edx
80105a14:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a1a:	8b 40 04             	mov    0x4(%eax),%eax
80105a1d:	83 ec 04             	sub    $0x4,%esp
80105a20:	52                   	push   %edx
80105a21:	ff 75 f4             	pushl  -0xc(%ebp)
80105a24:	50                   	push   %eax
80105a25:	e8 fe 43 00 00       	call   80109e28 <allocuvm>
80105a2a:	83 c4 10             	add    $0x10,%esp
80105a2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a30:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a34:	75 3d                	jne    80105a73 <growproc+0x7e>
			return -1;
80105a36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a3b:	eb 58                	jmp    80105a95 <growproc+0xa0>
	} else if (n < 0) {
80105a3d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105a41:	79 30                	jns    80105a73 <growproc+0x7e>
		if ((sz = deallocuvm(proc->pgdir, sz, sz + n, 0)) == 0)
80105a43:	8b 55 08             	mov    0x8(%ebp),%edx
80105a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a49:	01 c2                	add    %eax,%edx
80105a4b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a51:	8b 40 04             	mov    0x4(%eax),%eax
80105a54:	6a 00                	push   $0x0
80105a56:	52                   	push   %edx
80105a57:	ff 75 f4             	pushl  -0xc(%ebp)
80105a5a:	50                   	push   %eax
80105a5b:	e8 90 44 00 00       	call   80109ef0 <deallocuvm>
80105a60:	83 c4 10             	add    $0x10,%esp
80105a63:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a66:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a6a:	75 07                	jne    80105a73 <growproc+0x7e>
			return -1;
80105a6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a71:	eb 22                	jmp    80105a95 <growproc+0xa0>
	}
	proc->sz = sz;
80105a73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a79:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a7c:	89 10                	mov    %edx,(%eax)
	switchuvm(proc);
80105a7e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a84:	83 ec 0c             	sub    $0xc,%esp
80105a87:	50                   	push   %eax
80105a88:	e8 db 40 00 00       	call   80109b68 <switchuvm>
80105a8d:	83 c4 10             	add    $0x10,%esp
	return 0;
80105a90:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a95:	c9                   	leave  
80105a96:	c3                   	ret    

80105a97 <fork>:

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int fork(void)
{
80105a97:	55                   	push   %ebp
80105a98:	89 e5                	mov    %esp,%ebp
80105a9a:	57                   	push   %edi
80105a9b:	56                   	push   %esi
80105a9c:	53                   	push   %ebx
80105a9d:	83 ec 1c             	sub    $0x1c,%esp
	int i, pid;
	struct proc *np;

	// Allocate process.
	if ((np = allocproc()) == 0)
80105aa0:	e8 9d fc ff ff       	call   80105742 <allocproc>
80105aa5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105aa8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80105aac:	75 0a                	jne    80105ab8 <fork+0x21>
		return -1;
80105aae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ab3:	e9 16 02 00 00       	jmp    80105cce <fork+0x237>

	// Copy process state from p.
	if ((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0) {
80105ab8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105abe:	8b 10                	mov    (%eax),%edx
80105ac0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ac6:	8b 40 04             	mov    0x4(%eax),%eax
80105ac9:	83 ec 08             	sub    $0x8,%esp
80105acc:	52                   	push   %edx
80105acd:	50                   	push   %eax
80105ace:	e8 f4 45 00 00       	call   8010a0c7 <copyuvm>
80105ad3:	83 c4 10             	add    $0x10,%esp
80105ad6:	89 c2                	mov    %eax,%edx
80105ad8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105adb:	89 50 04             	mov    %edx,0x4(%eax)
80105ade:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105ae1:	8b 40 04             	mov    0x4(%eax),%eax
80105ae4:	85 c0                	test   %eax,%eax
80105ae6:	75 30                	jne    80105b18 <fork+0x81>
		kfree(np->kstack);
80105ae8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105aeb:	8b 40 08             	mov    0x8(%eax),%eax
80105aee:	83 ec 0c             	sub    $0xc,%esp
80105af1:	50                   	push   %eax
80105af2:	e8 d6 d0 ff ff       	call   80102bcd <kfree>
80105af7:	83 c4 10             	add    $0x10,%esp
		np->kstack = 0;
80105afa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105afd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
		np->state = UNUSED;
80105b04:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105b07:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
		return -1;
80105b0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b13:	e9 b6 01 00 00       	jmp    80105cce <fork+0x237>
	}
	np->sz = proc->sz;
80105b18:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b1e:	8b 10                	mov    (%eax),%edx
80105b20:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105b23:	89 10                	mov    %edx,(%eax)
	np->parent = proc;
80105b25:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105b2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105b2f:	89 50 14             	mov    %edx,0x14(%eax)
	*np->tf = *proc->tf;
80105b32:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105b35:	8b 50 18             	mov    0x18(%eax),%edx
80105b38:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b3e:	8b 40 18             	mov    0x18(%eax),%eax
80105b41:	89 c3                	mov    %eax,%ebx
80105b43:	b8 13 00 00 00       	mov    $0x13,%eax
80105b48:	89 d7                	mov    %edx,%edi
80105b4a:	89 de                	mov    %ebx,%esi
80105b4c:	89 c1                	mov    %eax,%ecx
80105b4e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	
	for(i = 0; i<SHM_MAXNUM; i++)
80105b50:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80105b57:	e9 98 00 00 00       	jmp    80105bf4 <fork+0x15d>
	{
		safestrcpy(np->shm_name[i].name, proc->shm_name[i].name, sizeof(np->shm_name[i].name));//mod2
80105b5c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b62:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105b65:	83 c2 07             	add    $0x7,%edx
80105b68:	c1 e2 04             	shl    $0x4,%edx
80105b6b:	01 d0                	add    %edx,%eax
80105b6d:	8d 50 0c             	lea    0xc(%eax),%edx
80105b70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b73:	83 c0 07             	add    $0x7,%eax
80105b76:	c1 e0 04             	shl    $0x4,%eax
80105b79:	89 c1                	mov    %eax,%ecx
80105b7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105b7e:	01 c8                	add    %ecx,%eax
80105b80:	83 c0 0c             	add    $0xc,%eax
80105b83:	83 ec 04             	sub    $0x4,%esp
80105b86:	6a 10                	push   $0x10
80105b88:	52                   	push   %edx
80105b89:	50                   	push   %eax
80105b8a:	e8 64 13 00 00       	call   80106ef3 <safestrcpy>
80105b8f:	83 c4 10             	add    $0x10,%esp
		np->shm_phys[i] = proc->shm_phys[i]; //mod2
80105b92:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b98:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105b9b:	81 c2 bc 00 00 00    	add    $0xbc,%edx
80105ba1:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80105ba5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105ba8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80105bab:	81 c1 bc 00 00 00    	add    $0xbc,%ecx
80105bb1:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
		np->shm_vir[i] = shm_assign(np->pgdir, np->sz, np->shm_phys[i]); //mod2
80105bb5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105bb8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105bbb:	81 c2 bc 00 00 00    	add    $0xbc,%edx
80105bc1:	8b 4c 90 0c          	mov    0xc(%eax,%edx,4),%ecx
80105bc5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105bc8:	8b 10                	mov    (%eax),%edx
80105bca:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105bcd:	8b 40 04             	mov    0x4(%eax),%eax
80105bd0:	83 ec 04             	sub    $0x4,%esp
80105bd3:	51                   	push   %ecx
80105bd4:	52                   	push   %edx
80105bd5:	50                   	push   %eax
80105bd6:	e8 54 e4 ff ff       	call   8010402f <shm_assign>
80105bdb:	83 c4 10             	add    $0x10,%esp
80105bde:	89 c1                	mov    %eax,%ecx
80105be0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105be3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105be6:	81 c2 9c 00 00 00    	add    $0x9c,%edx
80105bec:	89 4c 90 0c          	mov    %ecx,0xc(%eax,%edx,4)
	}
	np->sz = proc->sz;
	np->parent = proc;
	*np->tf = *proc->tf;
	
	for(i = 0; i<SHM_MAXNUM; i++)
80105bf0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80105bf4:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80105bf8:	0f 8e 5e ff ff ff    	jle    80105b5c <fork+0xc5>
		np->shm_phys[i] = proc->shm_phys[i]; //mod2
		np->shm_vir[i] = shm_assign(np->pgdir, np->sz, np->shm_phys[i]); //mod2
	}

	// Clear %eax so that fork returns 0 in the child.
	np->tf->eax = 0;
80105bfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105c01:	8b 40 18             	mov    0x18(%eax),%eax
80105c04:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	for (i = 0; i < NOFILE; i++)
80105c0b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80105c12:	eb 43                	jmp    80105c57 <fork+0x1c0>
		if (proc->ofile[i])
80105c14:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c1a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105c1d:	83 c2 08             	add    $0x8,%edx
80105c20:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105c24:	85 c0                	test   %eax,%eax
80105c26:	74 2b                	je     80105c53 <fork+0x1bc>
			np->ofile[i] = filedup(proc->ofile[i]);
80105c28:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c2e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105c31:	83 c2 08             	add    $0x8,%edx
80105c34:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105c38:	83 ec 0c             	sub    $0xc,%esp
80105c3b:	50                   	push   %eax
80105c3c:	e8 c3 b3 ff ff       	call   80101004 <filedup>
80105c41:	83 c4 10             	add    $0x10,%esp
80105c44:	89 c1                	mov    %eax,%ecx
80105c46:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105c49:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105c4c:	83 c2 08             	add    $0x8,%edx
80105c4f:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
	}

	// Clear %eax so that fork returns 0 in the child.
	np->tf->eax = 0;

	for (i = 0; i < NOFILE; i++)
80105c53:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80105c57:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80105c5b:	7e b7                	jle    80105c14 <fork+0x17d>
		if (proc->ofile[i])
			np->ofile[i] = filedup(proc->ofile[i]);
	np->cwd = idup(proc->cwd);
80105c5d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c63:	8b 40 68             	mov    0x68(%eax),%eax
80105c66:	83 ec 0c             	sub    $0xc,%esp
80105c69:	50                   	push   %eax
80105c6a:	e8 c5 bc ff ff       	call   80101934 <idup>
80105c6f:	83 c4 10             	add    $0x10,%esp
80105c72:	89 c2                	mov    %eax,%edx
80105c74:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105c77:	89 50 68             	mov    %edx,0x68(%eax)

	safestrcpy(np->name, proc->name, sizeof(proc->name));
80105c7a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c80:	8d 50 6c             	lea    0x6c(%eax),%edx
80105c83:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105c86:	83 c0 6c             	add    $0x6c,%eax
80105c89:	83 ec 04             	sub    $0x4,%esp
80105c8c:	6a 10                	push   $0x10
80105c8e:	52                   	push   %edx
80105c8f:	50                   	push   %eax
80105c90:	e8 5e 12 00 00       	call   80106ef3 <safestrcpy>
80105c95:	83 c4 10             	add    $0x10,%esp

	pid = np->pid;
80105c98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105c9b:	8b 40 10             	mov    0x10(%eax),%eax
80105c9e:	89 45 dc             	mov    %eax,-0x24(%ebp)

	// lock to force the compiler to emit the np->state write last.
	acquire(&ptable.lock);
80105ca1:	83 ec 0c             	sub    $0xc,%esp
80105ca4:	68 00 5e 11 80       	push   $0x80115e00
80105ca9:	e8 df 0d 00 00       	call   80106a8d <acquire>
80105cae:	83 c4 10             	add    $0x10,%esp
	np->state = RUNNABLE;
80105cb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105cb4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
	release(&ptable.lock);
80105cbb:	83 ec 0c             	sub    $0xc,%esp
80105cbe:	68 00 5e 11 80       	push   $0x80115e00
80105cc3:	e8 2c 0e 00 00       	call   80106af4 <release>
80105cc8:	83 c4 10             	add    $0x10,%esp

	return pid;
80105ccb:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80105cce:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105cd1:	5b                   	pop    %ebx
80105cd2:	5e                   	pop    %esi
80105cd3:	5f                   	pop    %edi
80105cd4:	5d                   	pop    %ebp
80105cd5:	c3                   	ret    

80105cd6 <exit>:

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void exit(void)
{
80105cd6:	55                   	push   %ebp
80105cd7:	89 e5                	mov    %esp,%ebp
80105cd9:	83 ec 18             	sub    $0x18,%esp
	struct proc *p;
	int fd;

	if (proc == initproc)
80105cdc:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105ce3:	a1 68 e6 10 80       	mov    0x8010e668,%eax
80105ce8:	39 c2                	cmp    %eax,%edx
80105cea:	75 0d                	jne    80105cf9 <exit+0x23>
		panic("init exiting");
80105cec:	83 ec 0c             	sub    $0xc,%esp
80105cef:	68 bc ab 10 80       	push   $0x8010abbc
80105cf4:	e8 6d a8 ff ff       	call   80100566 <panic>

	// Close all open files.
	for (fd = 0; fd < NOFILE; fd++) {
80105cf9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105d00:	eb 48                	jmp    80105d4a <exit+0x74>
		if (proc->ofile[fd]) {
80105d02:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d08:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d0b:	83 c2 08             	add    $0x8,%edx
80105d0e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105d12:	85 c0                	test   %eax,%eax
80105d14:	74 30                	je     80105d46 <exit+0x70>
			fileclose(proc->ofile[fd]);
80105d16:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d1c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d1f:	83 c2 08             	add    $0x8,%edx
80105d22:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105d26:	83 ec 0c             	sub    $0xc,%esp
80105d29:	50                   	push   %eax
80105d2a:	e8 26 b3 ff ff       	call   80101055 <fileclose>
80105d2f:	83 c4 10             	add    $0x10,%esp
			proc->ofile[fd] = 0;
80105d32:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d38:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d3b:	83 c2 08             	add    $0x8,%edx
80105d3e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105d45:	00 

	if (proc == initproc)
		panic("init exiting");

	// Close all open files.
	for (fd = 0; fd < NOFILE; fd++) {
80105d46:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105d4a:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80105d4e:	7e b2                	jle    80105d02 <exit+0x2c>

	//Delete SHM Regions only used by exiting process
	//shmExitClean(); //mod2

	//Delete All Associated Mutexes
	for(fd=0; fd<MUX_MAXNUM; fd++){
80105d50:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105d57:	eb 29                	jmp    80105d82 <exit+0xac>
		if(proc->mxproc[fd] >= 0)
80105d59:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d5f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d62:	81 c2 dc 00 00 00    	add    $0xdc,%edx
80105d68:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105d6c:	85 c0                	test   %eax,%eax
80105d6e:	78 0e                	js     80105d7e <exit+0xa8>
			mxdelete(fd);
80105d70:	83 ec 0c             	sub    $0xc,%esp
80105d73:	ff 75 f0             	pushl  -0x10(%ebp)
80105d76:	e8 9e 0a 00 00       	call   80106819 <mxdelete>
80105d7b:	83 c4 10             	add    $0x10,%esp

	//Delete SHM Regions only used by exiting process
	//shmExitClean(); //mod2

	//Delete All Associated Mutexes
	for(fd=0; fd<MUX_MAXNUM; fd++){
80105d7e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105d82:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
80105d86:	7e d1                	jle    80105d59 <exit+0x83>
		if(proc->mxproc[fd] >= 0)
			mxdelete(fd);
	}

	begin_op();
80105d88:	e8 c4 d7 ff ff       	call   80103551 <begin_op>
	iput(proc->cwd);
80105d8d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d93:	8b 40 68             	mov    0x68(%eax),%eax
80105d96:	83 ec 0c             	sub    $0xc,%esp
80105d99:	50                   	push   %eax
80105d9a:	e8 9f bd ff ff       	call   80101b3e <iput>
80105d9f:	83 c4 10             	add    $0x10,%esp
	end_op();
80105da2:	e8 36 d8 ff ff       	call   801035dd <end_op>
	proc->cwd = 0;
80105da7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105dad:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

	acquire(&ptable.lock);
80105db4:	83 ec 0c             	sub    $0xc,%esp
80105db7:	68 00 5e 11 80       	push   $0x80115e00
80105dbc:	e8 cc 0c 00 00       	call   80106a8d <acquire>
80105dc1:	83 c4 10             	add    $0x10,%esp

	// Parent might be sleeping in wait().
	wakeup1(proc->parent);
80105dc4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105dca:	8b 40 14             	mov    0x14(%eax),%eax
80105dcd:	83 ec 0c             	sub    $0xc,%esp
80105dd0:	50                   	push   %eax
80105dd1:	e8 cc 04 00 00       	call   801062a2 <wakeup1>
80105dd6:	83 c4 10             	add    $0x10,%esp

	// Pass abandoned children to init.
	for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80105dd9:	c7 45 f4 34 5e 11 80 	movl   $0x80115e34,-0xc(%ebp)
80105de0:	eb 3f                	jmp    80105e21 <exit+0x14b>
		if (p->parent == proc) {
80105de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de5:	8b 50 14             	mov    0x14(%eax),%edx
80105de8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105dee:	39 c2                	cmp    %eax,%edx
80105df0:	75 28                	jne    80105e1a <exit+0x144>
			p->parent = initproc;
80105df2:	8b 15 68 e6 10 80    	mov    0x8010e668,%edx
80105df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dfb:	89 50 14             	mov    %edx,0x14(%eax)
			if (p->state == ZOMBIE)
80105dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e01:	8b 40 0c             	mov    0xc(%eax),%eax
80105e04:	83 f8 05             	cmp    $0x5,%eax
80105e07:	75 11                	jne    80105e1a <exit+0x144>
				wakeup1(initproc);
80105e09:	a1 68 e6 10 80       	mov    0x8010e668,%eax
80105e0e:	83 ec 0c             	sub    $0xc,%esp
80105e11:	50                   	push   %eax
80105e12:	e8 8b 04 00 00       	call   801062a2 <wakeup1>
80105e17:	83 c4 10             	add    $0x10,%esp

	// Parent might be sleeping in wait().
	wakeup1(proc->parent);

	// Pass abandoned children to init.
	for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80105e1a:	81 45 f4 a4 03 00 00 	addl   $0x3a4,-0xc(%ebp)
80105e21:	81 7d f4 34 47 12 80 	cmpl   $0x80124734,-0xc(%ebp)
80105e28:	72 b8                	jb     80105de2 <exit+0x10c>
				wakeup1(initproc);
		}
	}

	// Jump into the scheduler, never to return.
	proc->state = ZOMBIE;
80105e2a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e30:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
	
	sched();
80105e37:	e8 7d 02 00 00       	call   801060b9 <sched>
	panic("zombie exit");
80105e3c:	83 ec 0c             	sub    $0xc,%esp
80105e3f:	68 c9 ab 10 80       	push   $0x8010abc9
80105e44:	e8 1d a7 ff ff       	call   80100566 <panic>

80105e49 <wait>:
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int wait(void)
{
80105e49:	55                   	push   %ebp
80105e4a:	89 e5                	mov    %esp,%ebp
80105e4c:	83 ec 18             	sub    $0x18,%esp
	struct proc *p;
	int havekids, pid;

	acquire(&ptable.lock);
80105e4f:	83 ec 0c             	sub    $0xc,%esp
80105e52:	68 00 5e 11 80       	push   $0x80115e00
80105e57:	e8 31 0c 00 00       	call   80106a8d <acquire>
80105e5c:	83 c4 10             	add    $0x10,%esp
	for (;;) {
		// Scan through table looking for zombie children.
		havekids = 0;
80105e5f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80105e66:	c7 45 f4 34 5e 11 80 	movl   $0x80115e34,-0xc(%ebp)
80105e6d:	e9 ab 00 00 00       	jmp    80105f1d <wait+0xd4>
			if (p->parent != proc)
80105e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e75:	8b 50 14             	mov    0x14(%eax),%edx
80105e78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e7e:	39 c2                	cmp    %eax,%edx
80105e80:	0f 85 8f 00 00 00    	jne    80105f15 <wait+0xcc>
				continue;
			havekids = 1;
80105e86:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
			if (p->state == ZOMBIE) {
80105e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e90:	8b 40 0c             	mov    0xc(%eax),%eax
80105e93:	83 f8 05             	cmp    $0x5,%eax
80105e96:	75 7e                	jne    80105f16 <wait+0xcd>
				// Found one.
				pid = p->pid;
80105e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e9b:	8b 40 10             	mov    0x10(%eax),%eax
80105e9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
				kfree(p->kstack);
80105ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea4:	8b 40 08             	mov    0x8(%eax),%eax
80105ea7:	83 ec 0c             	sub    $0xc,%esp
80105eaa:	50                   	push   %eax
80105eab:	e8 1d cd ff ff       	call   80102bcd <kfree>
80105eb0:	83 c4 10             	add    $0x10,%esp
				p->kstack = 0;
80105eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
				freevm(p->pgdir, -1); //freevm modified for mod2
80105ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec0:	8b 40 04             	mov    0x4(%eax),%eax
80105ec3:	83 ec 08             	sub    $0x8,%esp
80105ec6:	6a ff                	push   $0xffffffff
80105ec8:	50                   	push   %eax
80105ec9:	e8 18 41 00 00       	call   80109fe6 <freevm>
80105ece:	83 c4 10             	add    $0x10,%esp
				p->state = UNUSED;
80105ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
				p->pid = 0;
80105edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ede:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
				p->parent = 0;
80105ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee8:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
				p->name[0] = 0;
80105eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef2:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
				p->killed = 0;
80105ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef9:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
				release(&ptable.lock);
80105f00:	83 ec 0c             	sub    $0xc,%esp
80105f03:	68 00 5e 11 80       	push   $0x80115e00
80105f08:	e8 e7 0b 00 00       	call   80106af4 <release>
80105f0d:	83 c4 10             	add    $0x10,%esp
				return pid;
80105f10:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f13:	eb 5b                	jmp    80105f70 <wait+0x127>
	for (;;) {
		// Scan through table looking for zombie children.
		havekids = 0;
		for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
			if (p->parent != proc)
				continue;
80105f15:	90                   	nop

	acquire(&ptable.lock);
	for (;;) {
		// Scan through table looking for zombie children.
		havekids = 0;
		for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80105f16:	81 45 f4 a4 03 00 00 	addl   $0x3a4,-0xc(%ebp)
80105f1d:	81 7d f4 34 47 12 80 	cmpl   $0x80124734,-0xc(%ebp)
80105f24:	0f 82 48 ff ff ff    	jb     80105e72 <wait+0x29>
				return pid;
			}
		}

		// No point waiting if we don't have any children.
		if (!havekids || proc->killed) {
80105f2a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f2e:	74 0d                	je     80105f3d <wait+0xf4>
80105f30:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f36:	8b 40 24             	mov    0x24(%eax),%eax
80105f39:	85 c0                	test   %eax,%eax
80105f3b:	74 17                	je     80105f54 <wait+0x10b>
			release(&ptable.lock);
80105f3d:	83 ec 0c             	sub    $0xc,%esp
80105f40:	68 00 5e 11 80       	push   $0x80115e00
80105f45:	e8 aa 0b 00 00       	call   80106af4 <release>
80105f4a:	83 c4 10             	add    $0x10,%esp
			return -1;
80105f4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f52:	eb 1c                	jmp    80105f70 <wait+0x127>
		}
		// Wait for children to exit.  (See wakeup1 call in proc_exit.)
		sleep(proc, &ptable.lock);	//DOC: wait-sleep
80105f54:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f5a:	83 ec 08             	sub    $0x8,%esp
80105f5d:	68 00 5e 11 80       	push   $0x80115e00
80105f62:	50                   	push   %eax
80105f63:	e8 8e 02 00 00       	call   801061f6 <sleep>
80105f68:	83 c4 10             	add    $0x10,%esp
	}
80105f6b:	e9 ef fe ff ff       	jmp    80105e5f <wait+0x16>
}
80105f70:	c9                   	leave  
80105f71:	c3                   	ret    

80105f72 <scheduler>:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void scheduler(void)
{
80105f72:	55                   	push   %ebp
80105f73:	89 e5                	mov    %esp,%ebp
80105f75:	83 ec 18             	sub    $0x18,%esp
	struct proc *p, *high;
	for(;;)
	{
		// Enable interrupts on this processor.
		sti();
80105f78:	e8 e4 f6 ff ff       	call   80105661 <sti>
		
		high = 0; //cannot have pointer equal to zero
80105f7d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

    	// Loop over process table looking for process to run.
		acquire(&ptable.lock);
80105f84:	83 ec 0c             	sub    $0xc,%esp
80105f87:	68 00 5e 11 80       	push   $0x80115e00
80105f8c:	e8 fc 0a 00 00       	call   80106a8d <acquire>
80105f91:	83 c4 10             	add    $0x10,%esp
    	
		if(ptable.highpid != 0)
80105f94:	a1 34 47 12 80       	mov    0x80124734,%eax
80105f99:	85 c0                	test   %eax,%eax
80105f9b:	74 3c                	je     80105fd9 <scheduler+0x67>
		{
			for(p = ptable.proc; p<&ptable.proc[NPROC]; p++)
80105f9d:	c7 45 f4 34 5e 11 80 	movl   $0x80115e34,-0xc(%ebp)
80105fa4:	eb 2a                	jmp    80105fd0 <scheduler+0x5e>
			{
	      		if(p->state != RUNNABLE)
80105fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa9:	8b 40 0c             	mov    0xc(%eax),%eax
80105fac:	83 f8 03             	cmp    $0x3,%eax
80105faf:	75 17                	jne    80105fc8 <scheduler+0x56>
	        		continue;//goes back up to the for loop while still incrementing p

				if(p->pid == ptable.highpid) 
80105fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fb4:	8b 50 10             	mov    0x10(%eax),%edx
80105fb7:	a1 34 47 12 80       	mov    0x80124734,%eax
80105fbc:	39 c2                	cmp    %eax,%edx
80105fbe:	75 09                	jne    80105fc9 <scheduler+0x57>
				{
					high = p;
80105fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc3:	89 45 f0             	mov    %eax,-0x10(%ebp)
					break;
80105fc6:	eb 11                	jmp    80105fd9 <scheduler+0x67>
		if(ptable.highpid != 0)
		{
			for(p = ptable.proc; p<&ptable.proc[NPROC]; p++)
			{
	      		if(p->state != RUNNABLE)
	        		continue;//goes back up to the for loop while still incrementing p
80105fc8:	90                   	nop
    	// Loop over process table looking for process to run.
		acquire(&ptable.lock);
    	
		if(ptable.highpid != 0)
		{
			for(p = ptable.proc; p<&ptable.proc[NPROC]; p++)
80105fc9:	81 45 f4 a4 03 00 00 	addl   $0x3a4,-0xc(%ebp)
80105fd0:	81 7d f4 34 47 12 80 	cmpl   $0x80124734,-0xc(%ebp)
80105fd7:	72 cd                	jb     80105fa6 <scheduler+0x34>
				}
			}
				
		}

		if(high)
80105fd9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fdd:	74 50                	je     8010602f <scheduler+0xbd>
		{
			proc = high;
80105fdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe2:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
			switchuvm(high);
80105fe8:	83 ec 0c             	sub    $0xc,%esp
80105feb:	ff 75 f0             	pushl  -0x10(%ebp)
80105fee:	e8 75 3b 00 00       	call   80109b68 <switchuvm>
80105ff3:	83 c4 10             	add    $0x10,%esp
			high->state = RUNNING;
80105ff6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ff9:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
			swtch(&cpu->scheduler, high->context);
80106000:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106003:	8b 40 1c             	mov    0x1c(%eax),%eax
80106006:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010600d:	83 c2 04             	add    $0x4,%edx
80106010:	83 ec 08             	sub    $0x8,%esp
80106013:	50                   	push   %eax
80106014:	52                   	push   %edx
80106015:	e8 4a 0f 00 00       	call   80106f64 <swtch>
8010601a:	83 c4 10             	add    $0x10,%esp
			switchkvm();
8010601d:	e8 29 3b 00 00       	call   80109b4b <switchkvm>
			proc = 0;
80106022:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80106029:	00 00 00 00 
8010602d:	eb 75                	jmp    801060a4 <scheduler+0x132>
		}
			
		else
		{
			for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010602f:	c7 45 f4 34 5e 11 80 	movl   $0x80115e34,-0xc(%ebp)
80106036:	eb 63                	jmp    8010609b <scheduler+0x129>
			{
	      		if(p->state != RUNNABLE)
80106038:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010603b:	8b 40 0c             	mov    0xc(%eax),%eax
8010603e:	83 f8 03             	cmp    $0x3,%eax
80106041:	75 50                	jne    80106093 <scheduler+0x121>
				//Switch to chosen process.  It is the process's job
	      		// to release ptable.lock and then reacquire it
	      		// before jumping back to us.
				//proc is global kernel variable. allows the current process to be viewed outside the function
	  
				proc = p;
80106043:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106046:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
				switchuvm(p);
8010604c:	83 ec 0c             	sub    $0xc,%esp
8010604f:	ff 75 f4             	pushl  -0xc(%ebp)
80106052:	e8 11 3b 00 00       	call   80109b68 <switchuvm>
80106057:	83 c4 10             	add    $0x10,%esp
				p->state = RUNNING;
8010605a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010605d:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
	      		swtch(&cpu->scheduler, p->context);
80106064:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106067:	8b 40 1c             	mov    0x1c(%eax),%eax
8010606a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106071:	83 c2 04             	add    $0x4,%edx
80106074:	83 ec 08             	sub    $0x8,%esp
80106077:	50                   	push   %eax
80106078:	52                   	push   %edx
80106079:	e8 e6 0e 00 00       	call   80106f64 <swtch>
8010607e:	83 c4 10             	add    $0x10,%esp
	      		switchkvm();
80106081:	e8 c5 3a 00 00       	call   80109b4b <switchkvm>
				// Process is done running for now.
				// It should have changed its p->state before coming back.
	  			proc = 0;
80106086:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010608d:	00 00 00 00 
80106091:	eb 01                	jmp    80106094 <scheduler+0x122>
		else
		{
			for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
			{
	      		if(p->state != RUNNABLE)
	        		continue;//goes back up to the for loop while still incrementing p
80106093:	90                   	nop
			proc = 0;
		}
			
		else
		{
			for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80106094:	81 45 f4 a4 03 00 00 	addl   $0x3a4,-0xc(%ebp)
8010609b:	81 7d f4 34 47 12 80 	cmpl   $0x80124734,-0xc(%ebp)
801060a2:	72 94                	jb     80106038 <scheduler+0xc6>
				// Process is done running for now.
				// It should have changed its p->state before coming back.
	  			proc = 0;
		    }
	    }
		release(&ptable.lock);
801060a4:	83 ec 0c             	sub    $0xc,%esp
801060a7:	68 00 5e 11 80       	push   $0x80115e00
801060ac:	e8 43 0a 00 00       	call   80106af4 <release>
801060b1:	83 c4 10             	add    $0x10,%esp
  	}
801060b4:	e9 bf fe ff ff       	jmp    80105f78 <scheduler+0x6>

801060b9 <sched>:
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void sched(void)
{
801060b9:	55                   	push   %ebp
801060ba:	89 e5                	mov    %esp,%ebp
801060bc:	83 ec 18             	sub    $0x18,%esp
	int intena;

	if (!holding(&ptable.lock))
801060bf:	83 ec 0c             	sub    $0xc,%esp
801060c2:	68 00 5e 11 80       	push   $0x80115e00
801060c7:	e8 f4 0a 00 00       	call   80106bc0 <holding>
801060cc:	83 c4 10             	add    $0x10,%esp
801060cf:	85 c0                	test   %eax,%eax
801060d1:	75 0d                	jne    801060e0 <sched+0x27>
		panic("sched ptable.lock");
801060d3:	83 ec 0c             	sub    $0xc,%esp
801060d6:	68 d5 ab 10 80       	push   $0x8010abd5
801060db:	e8 86 a4 ff ff       	call   80100566 <panic>
	if (cpu->ncli != 1)
801060e0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801060e6:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801060ec:	83 f8 01             	cmp    $0x1,%eax
801060ef:	74 0d                	je     801060fe <sched+0x45>
		panic("sched locks");
801060f1:	83 ec 0c             	sub    $0xc,%esp
801060f4:	68 e7 ab 10 80       	push   $0x8010abe7
801060f9:	e8 68 a4 ff ff       	call   80100566 <panic>
	if (proc->state == RUNNING)
801060fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106104:	8b 40 0c             	mov    0xc(%eax),%eax
80106107:	83 f8 04             	cmp    $0x4,%eax
8010610a:	75 0d                	jne    80106119 <sched+0x60>
		panic("sched running");
8010610c:	83 ec 0c             	sub    $0xc,%esp
8010610f:	68 f3 ab 10 80       	push   $0x8010abf3
80106114:	e8 4d a4 ff ff       	call   80100566 <panic>
	if (readeflags() & FL_IF)
80106119:	e8 33 f5 ff ff       	call   80105651 <readeflags>
8010611e:	25 00 02 00 00       	and    $0x200,%eax
80106123:	85 c0                	test   %eax,%eax
80106125:	74 0d                	je     80106134 <sched+0x7b>
		panic("sched interruptible");
80106127:	83 ec 0c             	sub    $0xc,%esp
8010612a:	68 01 ac 10 80       	push   $0x8010ac01
8010612f:	e8 32 a4 ff ff       	call   80100566 <panic>
	intena = cpu->intena;
80106134:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010613a:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106140:	89 45 f4             	mov    %eax,-0xc(%ebp)
	swtch(&proc->context, cpu->scheduler);
80106143:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106149:	8b 40 04             	mov    0x4(%eax),%eax
8010614c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80106153:	83 c2 1c             	add    $0x1c,%edx
80106156:	83 ec 08             	sub    $0x8,%esp
80106159:	50                   	push   %eax
8010615a:	52                   	push   %edx
8010615b:	e8 04 0e 00 00       	call   80106f64 <swtch>
80106160:	83 c4 10             	add    $0x10,%esp
	cpu->intena = intena;
80106163:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106169:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010616c:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80106172:	90                   	nop
80106173:	c9                   	leave  
80106174:	c3                   	ret    

80106175 <yield>:

// Give up the CPU for one scheduling round.
void yield(void)
{
80106175:	55                   	push   %ebp
80106176:	89 e5                	mov    %esp,%ebp
80106178:	83 ec 08             	sub    $0x8,%esp
	acquire(&ptable.lock);	//DOC: yieldlock
8010617b:	83 ec 0c             	sub    $0xc,%esp
8010617e:	68 00 5e 11 80       	push   $0x80115e00
80106183:	e8 05 09 00 00       	call   80106a8d <acquire>
80106188:	83 c4 10             	add    $0x10,%esp
	proc->state = RUNNABLE;
8010618b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106191:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
	
	sched();
80106198:	e8 1c ff ff ff       	call   801060b9 <sched>
	release(&ptable.lock);
8010619d:	83 ec 0c             	sub    $0xc,%esp
801061a0:	68 00 5e 11 80       	push   $0x80115e00
801061a5:	e8 4a 09 00 00       	call   80106af4 <release>
801061aa:	83 c4 10             	add    $0x10,%esp
}
801061ad:	90                   	nop
801061ae:	c9                   	leave  
801061af:	c3                   	ret    

801061b0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void forkret(void)
{
801061b0:	55                   	push   %ebp
801061b1:	89 e5                	mov    %esp,%ebp
801061b3:	83 ec 08             	sub    $0x8,%esp
	static int first = 1;
	// Still holding ptable.lock from scheduler.
	release(&ptable.lock);
801061b6:	83 ec 0c             	sub    $0xc,%esp
801061b9:	68 00 5e 11 80       	push   $0x80115e00
801061be:	e8 31 09 00 00       	call   80106af4 <release>
801061c3:	83 c4 10             	add    $0x10,%esp

	if (first) {
801061c6:	a1 08 e0 10 80       	mov    0x8010e008,%eax
801061cb:	85 c0                	test   %eax,%eax
801061cd:	74 24                	je     801061f3 <forkret+0x43>
		// Some initialization functions must be run in the context
		// of a regular process (e.g., they call sleep), and thus cannot 
		// be run from main().
		first = 0;
801061cf:	c7 05 08 e0 10 80 00 	movl   $0x0,0x8010e008
801061d6:	00 00 00 
		iinit(ROOTDEV);
801061d9:	83 ec 0c             	sub    $0xc,%esp
801061dc:	6a 01                	push   $0x1
801061de:	e8 5f b4 ff ff       	call   80101642 <iinit>
801061e3:	83 c4 10             	add    $0x10,%esp
		initlog(ROOTDEV);
801061e6:	83 ec 0c             	sub    $0xc,%esp
801061e9:	6a 01                	push   $0x1
801061eb:	e8 43 d1 ff ff       	call   80103333 <initlog>
801061f0:	83 c4 10             	add    $0x10,%esp
	}
	// Return to "caller", actually trapret (see allocproc).
}
801061f3:	90                   	nop
801061f4:	c9                   	leave  
801061f5:	c3                   	ret    

801061f6 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
801061f6:	55                   	push   %ebp
801061f7:	89 e5                	mov    %esp,%ebp
801061f9:	83 ec 08             	sub    $0x8,%esp
	if (proc == 0)
801061fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106202:	85 c0                	test   %eax,%eax
80106204:	75 0d                	jne    80106213 <sleep+0x1d>
		panic("sleep");
80106206:	83 ec 0c             	sub    $0xc,%esp
80106209:	68 15 ac 10 80       	push   $0x8010ac15
8010620e:	e8 53 a3 ff ff       	call   80100566 <panic>

	if (lk == 0)
80106213:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106217:	75 0d                	jne    80106226 <sleep+0x30>
		panic("sleep without lk");
80106219:	83 ec 0c             	sub    $0xc,%esp
8010621c:	68 1b ac 10 80       	push   $0x8010ac1b
80106221:	e8 40 a3 ff ff       	call   80100566 <panic>
	// change p->state and then call sched.
	// Once we hold ptable.lock, we can be
	// guaranteed that we won't miss any wakeup
	// (wakeup runs with ptable.lock locked),
	// so it's okay to release lk.
	if (lk != &ptable.lock) {	//DOC: sleeplock0
80106226:	81 7d 0c 00 5e 11 80 	cmpl   $0x80115e00,0xc(%ebp)
8010622d:	74 1e                	je     8010624d <sleep+0x57>
		acquire(&ptable.lock);	//DOC: sleeplock1
8010622f:	83 ec 0c             	sub    $0xc,%esp
80106232:	68 00 5e 11 80       	push   $0x80115e00
80106237:	e8 51 08 00 00       	call   80106a8d <acquire>
8010623c:	83 c4 10             	add    $0x10,%esp
		
		release(lk);
8010623f:	83 ec 0c             	sub    $0xc,%esp
80106242:	ff 75 0c             	pushl  0xc(%ebp)
80106245:	e8 aa 08 00 00       	call   80106af4 <release>
8010624a:	83 c4 10             	add    $0x10,%esp
	}
	// Go to sleep.
	proc->chan = chan;
8010624d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106253:	8b 55 08             	mov    0x8(%ebp),%edx
80106256:	89 50 20             	mov    %edx,0x20(%eax)
	proc->state = SLEEPING;
80106259:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010625f:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
	//cprintf("tesT\n");
	sched();
80106266:	e8 4e fe ff ff       	call   801060b9 <sched>

	// Tidy up.
	proc->chan = 0;
8010626b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106271:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

	// Reacquire original lock.
	if (lk != &ptable.lock) {	//DOC: sleeplock2
80106278:	81 7d 0c 00 5e 11 80 	cmpl   $0x80115e00,0xc(%ebp)
8010627f:	74 1e                	je     8010629f <sleep+0xa9>
		release(&ptable.lock);
80106281:	83 ec 0c             	sub    $0xc,%esp
80106284:	68 00 5e 11 80       	push   $0x80115e00
80106289:	e8 66 08 00 00       	call   80106af4 <release>
8010628e:	83 c4 10             	add    $0x10,%esp
		acquire(lk);
80106291:	83 ec 0c             	sub    $0xc,%esp
80106294:	ff 75 0c             	pushl  0xc(%ebp)
80106297:	e8 f1 07 00 00       	call   80106a8d <acquire>
8010629c:	83 c4 10             	add    $0x10,%esp
	}
}
8010629f:	90                   	nop
801062a0:	c9                   	leave  
801062a1:	c3                   	ret    

801062a2 <wakeup1>:

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void wakeup1(void *chan)
{
801062a2:	55                   	push   %ebp
801062a3:	89 e5                	mov    %esp,%ebp
801062a5:	83 ec 10             	sub    $0x10,%esp
	struct proc *p;

	for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801062a8:	c7 45 fc 34 5e 11 80 	movl   $0x80115e34,-0x4(%ebp)
801062af:	eb 27                	jmp    801062d8 <wakeup1+0x36>
		if (p->state == SLEEPING && p->chan == chan)
801062b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062b4:	8b 40 0c             	mov    0xc(%eax),%eax
801062b7:	83 f8 02             	cmp    $0x2,%eax
801062ba:	75 15                	jne    801062d1 <wakeup1+0x2f>
801062bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062bf:	8b 40 20             	mov    0x20(%eax),%eax
801062c2:	3b 45 08             	cmp    0x8(%ebp),%eax
801062c5:	75 0a                	jne    801062d1 <wakeup1+0x2f>
			p->state = RUNNABLE;
801062c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062ca:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
// The ptable lock must be held.
static void wakeup1(void *chan)
{
	struct proc *p;

	for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801062d1:	81 45 fc a4 03 00 00 	addl   $0x3a4,-0x4(%ebp)
801062d8:	81 7d fc 34 47 12 80 	cmpl   $0x80124734,-0x4(%ebp)
801062df:	72 d0                	jb     801062b1 <wakeup1+0xf>
		if (p->state == SLEEPING && p->chan == chan)
			p->state = RUNNABLE;
}
801062e1:	90                   	nop
801062e2:	c9                   	leave  
801062e3:	c3                   	ret    

801062e4 <wakeup>:

// Wake up all processes sleeping on chan.
void wakeup(void *chan)
{
801062e4:	55                   	push   %ebp
801062e5:	89 e5                	mov    %esp,%ebp
801062e7:	83 ec 08             	sub    $0x8,%esp
	acquire(&ptable.lock);
801062ea:	83 ec 0c             	sub    $0xc,%esp
801062ed:	68 00 5e 11 80       	push   $0x80115e00
801062f2:	e8 96 07 00 00       	call   80106a8d <acquire>
801062f7:	83 c4 10             	add    $0x10,%esp
	wakeup1(chan);
801062fa:	83 ec 0c             	sub    $0xc,%esp
801062fd:	ff 75 08             	pushl  0x8(%ebp)
80106300:	e8 9d ff ff ff       	call   801062a2 <wakeup1>
80106305:	83 c4 10             	add    $0x10,%esp
	release(&ptable.lock);
80106308:	83 ec 0c             	sub    $0xc,%esp
8010630b:	68 00 5e 11 80       	push   $0x80115e00
80106310:	e8 df 07 00 00       	call   80106af4 <release>
80106315:	83 c4 10             	add    $0x10,%esp
}
80106318:	90                   	nop
80106319:	c9                   	leave  
8010631a:	c3                   	ret    

8010631b <kill>:

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int kill(int pid)
{
8010631b:	55                   	push   %ebp
8010631c:	89 e5                	mov    %esp,%ebp
8010631e:	83 ec 18             	sub    $0x18,%esp
	struct proc *p;

	acquire(&ptable.lock);
80106321:	83 ec 0c             	sub    $0xc,%esp
80106324:	68 00 5e 11 80       	push   $0x80115e00
80106329:	e8 5f 07 00 00       	call   80106a8d <acquire>
8010632e:	83 c4 10             	add    $0x10,%esp
	for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80106331:	c7 45 f4 34 5e 11 80 	movl   $0x80115e34,-0xc(%ebp)
80106338:	eb 48                	jmp    80106382 <kill+0x67>
		if (p->pid == pid) {
8010633a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010633d:	8b 40 10             	mov    0x10(%eax),%eax
80106340:	3b 45 08             	cmp    0x8(%ebp),%eax
80106343:	75 36                	jne    8010637b <kill+0x60>
			p->killed = 1;
80106345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106348:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
			// Wake process from sleep if necessary.
			if (p->state == SLEEPING)
8010634f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106352:	8b 40 0c             	mov    0xc(%eax),%eax
80106355:	83 f8 02             	cmp    $0x2,%eax
80106358:	75 0a                	jne    80106364 <kill+0x49>
				p->state = RUNNABLE;
8010635a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010635d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
			release(&ptable.lock);
80106364:	83 ec 0c             	sub    $0xc,%esp
80106367:	68 00 5e 11 80       	push   $0x80115e00
8010636c:	e8 83 07 00 00       	call   80106af4 <release>
80106371:	83 c4 10             	add    $0x10,%esp
			return 0;
80106374:	b8 00 00 00 00       	mov    $0x0,%eax
80106379:	eb 25                	jmp    801063a0 <kill+0x85>
int kill(int pid)
{
	struct proc *p;

	acquire(&ptable.lock);
	for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010637b:	81 45 f4 a4 03 00 00 	addl   $0x3a4,-0xc(%ebp)
80106382:	81 7d f4 34 47 12 80 	cmpl   $0x80124734,-0xc(%ebp)
80106389:	72 af                	jb     8010633a <kill+0x1f>
				p->state = RUNNABLE;
			release(&ptable.lock);
			return 0;
		}
	}
	release(&ptable.lock);
8010638b:	83 ec 0c             	sub    $0xc,%esp
8010638e:	68 00 5e 11 80       	push   $0x80115e00
80106393:	e8 5c 07 00 00       	call   80106af4 <release>
80106398:	83 c4 10             	add    $0x10,%esp
	return -1;
8010639b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801063a0:	c9                   	leave  
801063a1:	c3                   	ret    

801063a2 <procdump>:
//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
801063a2:	55                   	push   %ebp
801063a3:	89 e5                	mov    %esp,%ebp
801063a5:	83 ec 48             	sub    $0x48,%esp
	int i;
	struct proc *p;
	char *state;
	uint pc[10];

	for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801063a8:	c7 45 f0 34 5e 11 80 	movl   $0x80115e34,-0x10(%ebp)
801063af:	e9 da 00 00 00       	jmp    8010648e <procdump+0xec>
		if (p->state == UNUSED)
801063b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b7:	8b 40 0c             	mov    0xc(%eax),%eax
801063ba:	85 c0                	test   %eax,%eax
801063bc:	0f 84 c4 00 00 00    	je     80106486 <procdump+0xe4>
			continue;
		if (p->state >= 0 && p->state < NELEM(states)
801063c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c5:	8b 40 0c             	mov    0xc(%eax),%eax
801063c8:	83 f8 05             	cmp    $0x5,%eax
801063cb:	77 23                	ja     801063f0 <procdump+0x4e>
		    && states[p->state])
801063cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d0:	8b 40 0c             	mov    0xc(%eax),%eax
801063d3:	8b 04 85 0c e0 10 80 	mov    -0x7fef1ff4(,%eax,4),%eax
801063da:	85 c0                	test   %eax,%eax
801063dc:	74 12                	je     801063f0 <procdump+0x4e>
			state = states[p->state];
801063de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063e1:	8b 40 0c             	mov    0xc(%eax),%eax
801063e4:	8b 04 85 0c e0 10 80 	mov    -0x7fef1ff4(,%eax,4),%eax
801063eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
801063ee:	eb 07                	jmp    801063f7 <procdump+0x55>
		else
			state = "???";
801063f0:	c7 45 ec 2c ac 10 80 	movl   $0x8010ac2c,-0x14(%ebp)
		cprintf("%d %s %s", p->pid, state, p->name);
801063f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063fa:	8d 50 6c             	lea    0x6c(%eax),%edx
801063fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106400:	8b 40 10             	mov    0x10(%eax),%eax
80106403:	52                   	push   %edx
80106404:	ff 75 ec             	pushl  -0x14(%ebp)
80106407:	50                   	push   %eax
80106408:	68 30 ac 10 80       	push   $0x8010ac30
8010640d:	e8 b4 9f ff ff       	call   801003c6 <cprintf>
80106412:	83 c4 10             	add    $0x10,%esp
		if (p->state == SLEEPING) {
80106415:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106418:	8b 40 0c             	mov    0xc(%eax),%eax
8010641b:	83 f8 02             	cmp    $0x2,%eax
8010641e:	75 54                	jne    80106474 <procdump+0xd2>
			getcallerpcs((uint *) p->context->ebp + 2, pc);
80106420:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106423:	8b 40 1c             	mov    0x1c(%eax),%eax
80106426:	8b 40 0c             	mov    0xc(%eax),%eax
80106429:	83 c0 08             	add    $0x8,%eax
8010642c:	89 c2                	mov    %eax,%edx
8010642e:	83 ec 08             	sub    $0x8,%esp
80106431:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80106434:	50                   	push   %eax
80106435:	52                   	push   %edx
80106436:	e8 0b 07 00 00       	call   80106b46 <getcallerpcs>
8010643b:	83 c4 10             	add    $0x10,%esp
			for (i = 0; i < 10 && pc[i] != 0; i++)
8010643e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106445:	eb 1c                	jmp    80106463 <procdump+0xc1>
				cprintf(" %p", pc[i]);
80106447:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010644a:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010644e:	83 ec 08             	sub    $0x8,%esp
80106451:	50                   	push   %eax
80106452:	68 39 ac 10 80       	push   $0x8010ac39
80106457:	e8 6a 9f ff ff       	call   801003c6 <cprintf>
8010645c:	83 c4 10             	add    $0x10,%esp
		else
			state = "???";
		cprintf("%d %s %s", p->pid, state, p->name);
		if (p->state == SLEEPING) {
			getcallerpcs((uint *) p->context->ebp + 2, pc);
			for (i = 0; i < 10 && pc[i] != 0; i++)
8010645f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106463:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80106467:	7f 0b                	jg     80106474 <procdump+0xd2>
80106469:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010646c:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80106470:	85 c0                	test   %eax,%eax
80106472:	75 d3                	jne    80106447 <procdump+0xa5>
				cprintf(" %p", pc[i]);
		}
		cprintf("\n");
80106474:	83 ec 0c             	sub    $0xc,%esp
80106477:	68 3d ac 10 80       	push   $0x8010ac3d
8010647c:	e8 45 9f ff ff       	call   801003c6 <cprintf>
80106481:	83 c4 10             	add    $0x10,%esp
80106484:	eb 01                	jmp    80106487 <procdump+0xe5>
	char *state;
	uint pc[10];

	for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
		if (p->state == UNUSED)
			continue;
80106486:	90                   	nop
	int i;
	struct proc *p;
	char *state;
	uint pc[10];

	for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80106487:	81 45 f0 a4 03 00 00 	addl   $0x3a4,-0x10(%ebp)
8010648e:	81 7d f0 34 47 12 80 	cmpl   $0x80124734,-0x10(%ebp)
80106495:	0f 82 19 ff ff ff    	jb     801063b4 <procdump+0x12>
			for (i = 0; i < 10 && pc[i] != 0; i++)
				cprintf(" %p", pc[i]);
		}
		cprintf("\n");
	}
}
8010649b:	90                   	nop
8010649c:	c9                   	leave  
8010649d:	c3                   	ret    

8010649e <setHighPrio>:



int setHighPrio(void) //scheduler
{
8010649e:	55                   	push   %ebp
8010649f:	89 e5                	mov    %esp,%ebp
	ptable.highpid = proc->pid;
801064a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064a7:	8b 40 10             	mov    0x10(%eax),%eax
801064aa:	a3 34 47 12 80       	mov    %eax,0x80124734
	return 0;
801064af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064b4:	5d                   	pop    %ebp
801064b5:	c3                   	ret    

801064b6 <initmutex>:


int initmutex(char *name, int name_len)
{
801064b6:	55                   	push   %ebp
801064b7:	89 e5                	mov    %esp,%ebp
801064b9:	83 ec 10             	sub    $0x10,%esp

	//Scan for an unallocated mutex in the global array
	//If one is found, break the loop and set mutex values
	//If one is found with the same name, scan for an available
	//index in the per process array to add the mutex id
        for(i=0; i<=MUX_MAXNUM; i++){
801064bc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801064c3:	e9 dc 00 00 00       	jmp    801065a4 <initmutex+0xee>
                if(i==MUX_MAXNUM)
801064c8:	83 7d fc 0a          	cmpl   $0xa,-0x4(%ebp)
801064cc:	75 0a                	jne    801064d8 <initmutex+0x22>
                        return -1;
801064ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064d3:	e9 b3 01 00 00       	jmp    8010668b <initmutex+0x1d5>
                if(mxarray[i].name == 0)
801064d8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801064db:	89 d0                	mov    %edx,%eax
801064dd:	c1 e0 02             	shl    $0x2,%eax
801064e0:	01 d0                	add    %edx,%eax
801064e2:	c1 e0 02             	shl    $0x2,%eax
801064e5:	05 28 5d 11 80       	add    $0x80115d28,%eax
801064ea:	8b 00                	mov    (%eax),%eax
801064ec:	85 c0                	test   %eax,%eax
801064ee:	0f 84 bc 00 00 00    	je     801065b0 <initmutex+0xfa>
                        break;
                else if(mxarray[i].name == name){
801064f4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801064f7:	89 d0                	mov    %edx,%eax
801064f9:	c1 e0 02             	shl    $0x2,%eax
801064fc:	01 d0                	add    %edx,%eax
801064fe:	c1 e0 02             	shl    $0x2,%eax
80106501:	05 28 5d 11 80       	add    $0x80115d28,%eax
80106506:	8b 00                	mov    (%eax),%eax
80106508:	3b 45 08             	cmp    0x8(%ebp),%eax
8010650b:	0f 85 8f 00 00 00    	jne    801065a0 <initmutex+0xea>

			for(j=0; j<MUX_MAXNUM; j++){
80106511:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80106518:	eb 76                	jmp    80106590 <initmutex+0xda>
				if(proc->mxproc[j] < 0){
8010651a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106520:	8b 55 f8             	mov    -0x8(%ebp),%edx
80106523:	81 c2 dc 00 00 00    	add    $0xdc,%edx
80106529:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010652d:	85 c0                	test   %eax,%eax
8010652f:	79 5b                	jns    8010658c <initmutex+0xd6>
					mxarray[i].num_proc++;
80106531:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106534:	89 d0                	mov    %edx,%eax
80106536:	c1 e0 02             	shl    $0x2,%eax
80106539:	01 d0                	add    %edx,%eax
8010653b:	c1 e0 02             	shl    $0x2,%eax
8010653e:	05 30 5d 11 80       	add    $0x80115d30,%eax
80106543:	8b 00                	mov    (%eax),%eax
80106545:	8d 48 01             	lea    0x1(%eax),%ecx
80106548:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010654b:	89 d0                	mov    %edx,%eax
8010654d:	c1 e0 02             	shl    $0x2,%eax
80106550:	01 d0                	add    %edx,%eax
80106552:	c1 e0 02             	shl    $0x2,%eax
80106555:	05 30 5d 11 80       	add    $0x80115d30,%eax
8010655a:	89 08                	mov    %ecx,(%eax)
					proc->mxproc[j] =mxarray[i].id;
8010655c:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80106563:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106566:	89 d0                	mov    %edx,%eax
80106568:	c1 e0 02             	shl    $0x2,%eax
8010656b:	01 d0                	add    %edx,%eax
8010656d:	c1 e0 02             	shl    $0x2,%eax
80106570:	05 24 5d 11 80       	add    $0x80115d24,%eax
80106575:	8b 00                	mov    (%eax),%eax
80106577:	8b 55 f8             	mov    -0x8(%ebp),%edx
8010657a:	81 c2 dc 00 00 00    	add    $0xdc,%edx
80106580:	89 44 91 0c          	mov    %eax,0xc(%ecx,%edx,4)
					return j;
80106584:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106587:	e9 ff 00 00 00       	jmp    8010668b <initmutex+0x1d5>
                        return -1;
                if(mxarray[i].name == 0)
                        break;
                else if(mxarray[i].name == name){

			for(j=0; j<MUX_MAXNUM; j++){
8010658c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80106590:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106594:	7e 84                	jle    8010651a <initmutex+0x64>
					mxarray[i].num_proc++;
					proc->mxproc[j] =mxarray[i].id;
					return j;
				}
			}
			return -1;
80106596:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010659b:	e9 eb 00 00 00       	jmp    8010668b <initmutex+0x1d5>

	//Scan for an unallocated mutex in the global array
	//If one is found, break the loop and set mutex values
	//If one is found with the same name, scan for an available
	//index in the per process array to add the mutex id
        for(i=0; i<=MUX_MAXNUM; i++){
801065a0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801065a4:	83 7d fc 0a          	cmpl   $0xa,-0x4(%ebp)
801065a8:	0f 8e 1a ff ff ff    	jle    801064c8 <initmutex+0x12>
801065ae:	eb 01                	jmp    801065b1 <initmutex+0xfb>
                if(i==MUX_MAXNUM)
                        return -1;
                if(mxarray[i].name == 0)
                        break;
801065b0:	90                   	nop
			}
			return -1;
		}
        }

	for(j=0; j<MUX_MAXNUM; j++){
801065b1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801065b8:	e9 bf 00 00 00       	jmp    8010667c <initmutex+0x1c6>
        	if(proc->mxproc[j] < 0){
801065bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065c3:	8b 55 f8             	mov    -0x8(%ebp),%edx
801065c6:	81 c2 dc 00 00 00    	add    $0xdc,%edx
801065cc:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801065d0:	85 c0                	test   %eax,%eax
801065d2:	0f 89 a0 00 00 00    	jns    80106678 <initmutex+0x1c2>
                	mxarray[i].num_proc++;
801065d8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801065db:	89 d0                	mov    %edx,%eax
801065dd:	c1 e0 02             	shl    $0x2,%eax
801065e0:	01 d0                	add    %edx,%eax
801065e2:	c1 e0 02             	shl    $0x2,%eax
801065e5:	05 30 5d 11 80       	add    $0x80115d30,%eax
801065ea:	8b 00                	mov    (%eax),%eax
801065ec:	8d 48 01             	lea    0x1(%eax),%ecx
801065ef:	8b 55 fc             	mov    -0x4(%ebp),%edx
801065f2:	89 d0                	mov    %edx,%eax
801065f4:	c1 e0 02             	shl    $0x2,%eax
801065f7:	01 d0                	add    %edx,%eax
801065f9:	c1 e0 02             	shl    $0x2,%eax
801065fc:	05 30 5d 11 80       	add    $0x80115d30,%eax
80106601:	89 08                	mov    %ecx,(%eax)
			mxarray[i].name = name;
80106603:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106606:	89 d0                	mov    %edx,%eax
80106608:	c1 e0 02             	shl    $0x2,%eax
8010660b:	01 d0                	add    %edx,%eax
8010660d:	c1 e0 02             	shl    $0x2,%eax
80106610:	8d 90 28 5d 11 80    	lea    -0x7feea2d8(%eax),%edx
80106616:	8b 45 08             	mov    0x8(%ebp),%eax
80106619:	89 02                	mov    %eax,(%edx)
			mxarray[i].name_len = name_len;
8010661b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010661e:	89 d0                	mov    %edx,%eax
80106620:	c1 e0 02             	shl    $0x2,%eax
80106623:	01 d0                	add    %edx,%eax
80106625:	c1 e0 02             	shl    $0x2,%eax
80106628:	8d 90 2c 5d 11 80    	lea    -0x7feea2d4(%eax),%edx
8010662e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106631:	89 02                	mov    %eax,(%edx)
			mxarray[i].lock = 0;
80106633:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106636:	89 d0                	mov    %edx,%eax
80106638:	c1 e0 02             	shl    $0x2,%eax
8010663b:	01 d0                	add    %edx,%eax
8010663d:	c1 e0 02             	shl    $0x2,%eax
80106640:	05 20 5d 11 80       	add    $0x80115d20,%eax
80106645:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
                        proc->mxproc[j] =mxarray[i].id;
8010664b:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80106652:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106655:	89 d0                	mov    %edx,%eax
80106657:	c1 e0 02             	shl    $0x2,%eax
8010665a:	01 d0                	add    %edx,%eax
8010665c:	c1 e0 02             	shl    $0x2,%eax
8010665f:	05 24 5d 11 80       	add    $0x80115d24,%eax
80106664:	8b 00                	mov    (%eax),%eax
80106666:	8b 55 f8             	mov    -0x8(%ebp),%edx
80106669:	81 c2 dc 00 00 00    	add    $0xdc,%edx
8010666f:	89 44 91 0c          	mov    %eax,0xc(%ecx,%edx,4)
                        return j;
80106673:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106676:	eb 13                	jmp    8010668b <initmutex+0x1d5>
			}
			return -1;
		}
        }

	for(j=0; j<MUX_MAXNUM; j++){
80106678:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010667c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106680:	0f 8e 37 ff ff ff    	jle    801065bd <initmutex+0x107>
			mxarray[i].lock = 0;
                        proc->mxproc[j] =mxarray[i].id;
                        return j;
                }
	}
	return -1;
80106686:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010668b:	c9                   	leave  
8010668c:	c3                   	ret    

8010668d <mxacquire>:

// Acquire the mutex lock. Blocks until lock is acquired
// Global mutex ID (gid) is retrieved from process's
// mutex array
void mxacquire(int muxid)
{
8010668d:	55                   	push   %ebp
8010668e:	89 e5                	mov    %esp,%ebp
80106690:	83 ec 18             	sub    $0x18,%esp
	int gid;

	if(proc->mxproc[muxid] < 0)
80106693:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106699:	8b 55 08             	mov    0x8(%ebp),%edx
8010669c:	81 c2 dc 00 00 00    	add    $0xdc,%edx
801066a2:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801066a6:	85 c0                	test   %eax,%eax
801066a8:	0f 88 b3 00 00 00    	js     80106761 <mxacquire+0xd4>
		return;
	
	gid = proc->mxproc[muxid];
801066ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066b4:	8b 55 08             	mov    0x8(%ebp),%edx
801066b7:	81 c2 dc 00 00 00    	add    $0xdc,%edx
801066bd:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801066c1:	89 45 f4             	mov    %eax,-0xc(%ebp)

	if(mxarray[gid].name == 0)
801066c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066c7:	89 d0                	mov    %edx,%eax
801066c9:	c1 e0 02             	shl    $0x2,%eax
801066cc:	01 d0                	add    %edx,%eax
801066ce:	c1 e0 02             	shl    $0x2,%eax
801066d1:	05 28 5d 11 80       	add    $0x80115d28,%eax
801066d6:	8b 00                	mov    (%eax),%eax
801066d8:	85 c0                	test   %eax,%eax
801066da:	0f 84 84 00 00 00    	je     80106764 <mxacquire+0xd7>
                return;
        if(mxarray[gid].lock == 1){
801066e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066e3:	89 d0                	mov    %edx,%eax
801066e5:	c1 e0 02             	shl    $0x2,%eax
801066e8:	01 d0                	add    %edx,%eax
801066ea:	c1 e0 02             	shl    $0x2,%eax
801066ed:	05 20 5d 11 80       	add    $0x80115d20,%eax
801066f2:	8b 00                	mov    (%eax),%eax
801066f4:	83 f8 01             	cmp    $0x1,%eax
801066f7:	75 46                	jne    8010673f <mxacquire+0xb2>
		//Put process to sleep if mutex is locked
		acquire(&ptable.lock);
801066f9:	83 ec 0c             	sub    $0xc,%esp
801066fc:	68 00 5e 11 80       	push   $0x80115e00
80106701:	e8 87 03 00 00       	call   80106a8d <acquire>
80106706:	83 c4 10             	add    $0x10,%esp
                sleep(&mxarray[gid].name, &ptable.lock);
80106709:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010670c:	89 d0                	mov    %edx,%eax
8010670e:	c1 e0 02             	shl    $0x2,%eax
80106711:	01 d0                	add    %edx,%eax
80106713:	c1 e0 02             	shl    $0x2,%eax
80106716:	05 20 5d 11 80       	add    $0x80115d20,%eax
8010671b:	83 c0 08             	add    $0x8,%eax
8010671e:	83 ec 08             	sub    $0x8,%esp
80106721:	68 00 5e 11 80       	push   $0x80115e00
80106726:	50                   	push   %eax
80106727:	e8 ca fa ff ff       	call   801061f6 <sleep>
8010672c:	83 c4 10             	add    $0x10,%esp
		release(&ptable.lock);
8010672f:	83 ec 0c             	sub    $0xc,%esp
80106732:	68 00 5e 11 80       	push   $0x80115e00
80106737:	e8 b8 03 00 00       	call   80106af4 <release>
8010673c:	83 c4 10             	add    $0x10,%esp
        }

        xchg(&mxarray[muxid].lock, 1);  //Use xchg to atomically switch lock to one
8010673f:	8b 55 08             	mov    0x8(%ebp),%edx
80106742:	89 d0                	mov    %edx,%eax
80106744:	c1 e0 02             	shl    $0x2,%eax
80106747:	01 d0                	add    %edx,%eax
80106749:	c1 e0 02             	shl    $0x2,%eax
8010674c:	05 20 5d 11 80       	add    $0x80115d20,%eax
80106751:	83 ec 08             	sub    $0x8,%esp
80106754:	6a 01                	push   $0x1
80106756:	50                   	push   %eax
80106757:	e8 0c ef ff ff       	call   80105668 <xchg>
8010675c:	83 c4 10             	add    $0x10,%esp
8010675f:	eb 04                	jmp    80106765 <mxacquire+0xd8>
void mxacquire(int muxid)
{
	int gid;

	if(proc->mxproc[muxid] < 0)
		return;
80106761:	90                   	nop
80106762:	eb 01                	jmp    80106765 <mxacquire+0xd8>
	
	gid = proc->mxproc[muxid];

	if(mxarray[gid].name == 0)
                return;
80106764:	90                   	nop
		release(&ptable.lock);
        }

        xchg(&mxarray[muxid].lock, 1);  //Use xchg to atomically switch lock to one

}
80106765:	c9                   	leave  
80106766:	c3                   	ret    

80106767 <mxrelease>:

//Release mutex lock
void mxrelease(int muxid)
{
80106767:	55                   	push   %ebp
80106768:	89 e5                	mov    %esp,%ebp
8010676a:	83 ec 18             	sub    $0x18,%esp
        int gid;

        if(proc->mxproc[muxid] < 0)
8010676d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106773:	8b 55 08             	mov    0x8(%ebp),%edx
80106776:	81 c2 dc 00 00 00    	add    $0xdc,%edx
8010677c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80106780:	85 c0                	test   %eax,%eax
80106782:	0f 88 8b 00 00 00    	js     80106813 <mxrelease+0xac>
                return;

        gid = proc->mxproc[muxid];
80106788:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010678e:	8b 55 08             	mov    0x8(%ebp),%edx
80106791:	81 c2 dc 00 00 00    	add    $0xdc,%edx
80106797:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010679b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	
	if(mxarray[gid].name == 0)
8010679e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067a1:	89 d0                	mov    %edx,%eax
801067a3:	c1 e0 02             	shl    $0x2,%eax
801067a6:	01 d0                	add    %edx,%eax
801067a8:	c1 e0 02             	shl    $0x2,%eax
801067ab:	05 28 5d 11 80       	add    $0x80115d28,%eax
801067b0:	8b 00                	mov    (%eax),%eax
801067b2:	85 c0                	test   %eax,%eax
801067b4:	74 60                	je     80106816 <mxrelease+0xaf>
		return;
	if(mxarray[gid].lock == 0){
801067b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067b9:	89 d0                	mov    %edx,%eax
801067bb:	c1 e0 02             	shl    $0x2,%eax
801067be:	01 d0                	add    %edx,%eax
801067c0:	c1 e0 02             	shl    $0x2,%eax
801067c3:	05 20 5d 11 80       	add    $0x80115d20,%eax
801067c8:	8b 00                	mov    (%eax),%eax
801067ca:	85 c0                	test   %eax,%eax
801067cc:	75 23                	jne    801067f1 <mxrelease+0x8a>
		//Wakeup processes if mutex is unlocked
                wakeup(&mxarray[gid].name);
801067ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067d1:	89 d0                	mov    %edx,%eax
801067d3:	c1 e0 02             	shl    $0x2,%eax
801067d6:	01 d0                	add    %edx,%eax
801067d8:	c1 e0 02             	shl    $0x2,%eax
801067db:	05 20 5d 11 80       	add    $0x80115d20,%eax
801067e0:	83 c0 08             	add    $0x8,%eax
801067e3:	83 ec 0c             	sub    $0xc,%esp
801067e6:	50                   	push   %eax
801067e7:	e8 f8 fa ff ff       	call   801062e4 <wakeup>
801067ec:	83 c4 10             	add    $0x10,%esp
                return;
801067ef:	eb 26                	jmp    80106817 <mxrelease+0xb0>
        }

        xchg(&mxarray[gid].lock, 0);	//Use xchg to atomically switch lock to zero
801067f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067f4:	89 d0                	mov    %edx,%eax
801067f6:	c1 e0 02             	shl    $0x2,%eax
801067f9:	01 d0                	add    %edx,%eax
801067fb:	c1 e0 02             	shl    $0x2,%eax
801067fe:	05 20 5d 11 80       	add    $0x80115d20,%eax
80106803:	83 ec 08             	sub    $0x8,%esp
80106806:	6a 00                	push   $0x0
80106808:	50                   	push   %eax
80106809:	e8 5a ee ff ff       	call   80105668 <xchg>
8010680e:	83 c4 10             	add    $0x10,%esp
80106811:	eb 04                	jmp    80106817 <mxrelease+0xb0>
void mxrelease(int muxid)
{
        int gid;

        if(proc->mxproc[muxid] < 0)
                return;
80106813:	90                   	nop
80106814:	eb 01                	jmp    80106817 <mxrelease+0xb0>

        gid = proc->mxproc[muxid];
	
	if(mxarray[gid].name == 0)
		return;
80106816:	90                   	nop
                return;
        }

        xchg(&mxarray[gid].lock, 0);	//Use xchg to atomically switch lock to zero

}
80106817:	c9                   	leave  
80106818:	c3                   	ret    

80106819 <mxdelete>:


void mxdelete(int muxid)
{
80106819:	55                   	push   %ebp
8010681a:	89 e5                	mov    %esp,%ebp
8010681c:	83 ec 10             	sub    $0x10,%esp
	struct proc *p;
    p = ptable.proc;
8010681f:	c7 45 fc 34 5e 11 80 	movl   $0x80115e34,-0x4(%ebp)
    int gid;

    if(p->mxproc[muxid] < 0)
80106826:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106829:	8b 55 08             	mov    0x8(%ebp),%edx
8010682c:	81 c2 dc 00 00 00    	add    $0xdc,%edx
80106832:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80106836:	85 c0                	test   %eax,%eax
80106838:	0f 88 e8 00 00 00    	js     80106926 <mxdelete+0x10d>
        return;

    gid = p->mxproc[muxid];
8010683e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106841:	8b 55 08             	mov    0x8(%ebp),%edx
80106844:	81 c2 dc 00 00 00    	add    $0xdc,%edx
8010684a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010684e:	89 45 f8             	mov    %eax,-0x8(%ebp)

	if(mxarray[gid].name == 0)
80106851:	8b 55 f8             	mov    -0x8(%ebp),%edx
80106854:	89 d0                	mov    %edx,%eax
80106856:	c1 e0 02             	shl    $0x2,%eax
80106859:	01 d0                	add    %edx,%eax
8010685b:	c1 e0 02             	shl    $0x2,%eax
8010685e:	05 28 5d 11 80       	add    $0x80115d28,%eax
80106863:	8b 00                	mov    (%eax),%eax
80106865:	85 c0                	test   %eax,%eax
80106867:	0f 84 bc 00 00 00    	je     80106929 <mxdelete+0x110>
		return;
	mxarray[gid].num_proc--;
8010686d:	8b 55 f8             	mov    -0x8(%ebp),%edx
80106870:	89 d0                	mov    %edx,%eax
80106872:	c1 e0 02             	shl    $0x2,%eax
80106875:	01 d0                	add    %edx,%eax
80106877:	c1 e0 02             	shl    $0x2,%eax
8010687a:	05 30 5d 11 80       	add    $0x80115d30,%eax
8010687f:	8b 00                	mov    (%eax),%eax
80106881:	8d 48 ff             	lea    -0x1(%eax),%ecx
80106884:	8b 55 f8             	mov    -0x8(%ebp),%edx
80106887:	89 d0                	mov    %edx,%eax
80106889:	c1 e0 02             	shl    $0x2,%eax
8010688c:	01 d0                	add    %edx,%eax
8010688e:	c1 e0 02             	shl    $0x2,%eax
80106891:	05 30 5d 11 80       	add    $0x80115d30,%eax
80106896:	89 08                	mov    %ecx,(%eax)
	p->mxproc[muxid] = -1;
80106898:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010689b:	8b 55 08             	mov    0x8(%ebp),%edx
8010689e:	81 c2 dc 00 00 00    	add    $0xdc,%edx
801068a4:	c7 44 90 0c ff ff ff 	movl   $0xffffffff,0xc(%eax,%edx,4)
801068ab:	ff 

        if(mxarray[gid].num_proc == 0){
801068ac:	8b 55 f8             	mov    -0x8(%ebp),%edx
801068af:	89 d0                	mov    %edx,%eax
801068b1:	c1 e0 02             	shl    $0x2,%eax
801068b4:	01 d0                	add    %edx,%eax
801068b6:	c1 e0 02             	shl    $0x2,%eax
801068b9:	05 30 5d 11 80       	add    $0x80115d30,%eax
801068be:	8b 00                	mov    (%eax),%eax
801068c0:	85 c0                	test   %eax,%eax
801068c2:	75 66                	jne    8010692a <mxdelete+0x111>
                mxarray[gid].name = 0;
801068c4:	8b 55 f8             	mov    -0x8(%ebp),%edx
801068c7:	89 d0                	mov    %edx,%eax
801068c9:	c1 e0 02             	shl    $0x2,%eax
801068cc:	01 d0                	add    %edx,%eax
801068ce:	c1 e0 02             	shl    $0x2,%eax
801068d1:	05 28 5d 11 80       	add    $0x80115d28,%eax
801068d6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
                mxarray[gid].lock = 0;
801068dc:	8b 55 f8             	mov    -0x8(%ebp),%edx
801068df:	89 d0                	mov    %edx,%eax
801068e1:	c1 e0 02             	shl    $0x2,%eax
801068e4:	01 d0                	add    %edx,%eax
801068e6:	c1 e0 02             	shl    $0x2,%eax
801068e9:	05 20 5d 11 80       	add    $0x80115d20,%eax
801068ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
                mxarray[gid].name_len = 0;
801068f4:	8b 55 f8             	mov    -0x8(%ebp),%edx
801068f7:	89 d0                	mov    %edx,%eax
801068f9:	c1 e0 02             	shl    $0x2,%eax
801068fc:	01 d0                	add    %edx,%eax
801068fe:	c1 e0 02             	shl    $0x2,%eax
80106901:	05 2c 5d 11 80       	add    $0x80115d2c,%eax
80106906:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
                mxarray[gid].num_proc = 0;
8010690c:	8b 55 f8             	mov    -0x8(%ebp),%edx
8010690f:	89 d0                	mov    %edx,%eax
80106911:	c1 e0 02             	shl    $0x2,%eax
80106914:	01 d0                	add    %edx,%eax
80106916:	c1 e0 02             	shl    $0x2,%eax
80106919:	05 30 5d 11 80       	add    $0x80115d30,%eax
8010691e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80106924:	eb 04                	jmp    8010692a <mxdelete+0x111>
	struct proc *p;
    p = ptable.proc;
    int gid;

    if(p->mxproc[muxid] < 0)
        return;
80106926:	90                   	nop
80106927:	eb 01                	jmp    8010692a <mxdelete+0x111>

    gid = p->mxproc[muxid];

	if(mxarray[gid].name == 0)
		return;
80106929:	90                   	nop
                mxarray[gid].lock = 0;
                mxarray[gid].name_len = 0;
                mxarray[gid].num_proc = 0;
        }

}
8010692a:	c9                   	leave  
8010692b:	c3                   	ret    

8010692c <cvwait>:
// Only one condition variable exists for each
// mutex. Processes sleep when waiting.
// Signal wakes up all processes waiting
// on the channel defined by the mutex
void cvwait(int muxid)
{
8010692c:	55                   	push   %ebp
8010692d:	89 e5                	mov    %esp,%ebp
8010692f:	83 ec 18             	sub    $0x18,%esp
    int gid;

    if(proc->mxproc[muxid] < 0)
80106932:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106938:	8b 55 08             	mov    0x8(%ebp),%edx
8010693b:	81 c2 dc 00 00 00    	add    $0xdc,%edx
80106941:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80106945:	85 c0                	test   %eax,%eax
80106947:	78 73                	js     801069bc <cvwait+0x90>
            return;

    gid = proc->mxproc[muxid];
80106949:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010694f:	8b 55 08             	mov    0x8(%ebp),%edx
80106952:	81 c2 dc 00 00 00    	add    $0xdc,%edx
80106958:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010695c:	89 45 f4             	mov    %eax,-0xc(%ebp)

	if(mxarray[gid].name == 0)
8010695f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106962:	89 d0                	mov    %edx,%eax
80106964:	c1 e0 02             	shl    $0x2,%eax
80106967:	01 d0                	add    %edx,%eax
80106969:	c1 e0 02             	shl    $0x2,%eax
8010696c:	05 28 5d 11 80       	add    $0x80115d28,%eax
80106971:	8b 00                	mov    (%eax),%eax
80106973:	85 c0                	test   %eax,%eax
80106975:	74 48                	je     801069bf <cvwait+0x93>
		return;
	//if(mxarray[gid].lock == 0)
		//panic("Lock Not Held");

	//mxrelease(muxid);
	acquire(&ptable.lock);
80106977:	83 ec 0c             	sub    $0xc,%esp
8010697a:	68 00 5e 11 80       	push   $0x80115e00
8010697f:	e8 09 01 00 00       	call   80106a8d <acquire>
80106984:	83 c4 10             	add    $0x10,%esp
	sleep(&mxarray[gid], &ptable.lock);
80106987:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010698a:	89 d0                	mov    %edx,%eax
8010698c:	c1 e0 02             	shl    $0x2,%eax
8010698f:	01 d0                	add    %edx,%eax
80106991:	c1 e0 02             	shl    $0x2,%eax
80106994:	05 20 5d 11 80       	add    $0x80115d20,%eax
80106999:	83 ec 08             	sub    $0x8,%esp
8010699c:	68 00 5e 11 80       	push   $0x80115e00
801069a1:	50                   	push   %eax
801069a2:	e8 4f f8 ff ff       	call   801061f6 <sleep>
801069a7:	83 c4 10             	add    $0x10,%esp
	release(&ptable.lock);
801069aa:	83 ec 0c             	sub    $0xc,%esp
801069ad:	68 00 5e 11 80       	push   $0x80115e00
801069b2:	e8 3d 01 00 00       	call   80106af4 <release>
801069b7:	83 c4 10             	add    $0x10,%esp
801069ba:	eb 04                	jmp    801069c0 <cvwait+0x94>
void cvwait(int muxid)
{
    int gid;

    if(proc->mxproc[muxid] < 0)
            return;
801069bc:	90                   	nop
801069bd:	eb 01                	jmp    801069c0 <cvwait+0x94>

    gid = proc->mxproc[muxid];

	if(mxarray[gid].name == 0)
		return;
801069bf:	90                   	nop
	//mxrelease(muxid);
	acquire(&ptable.lock);
	sleep(&mxarray[gid], &ptable.lock);
	release(&ptable.lock);
	//mxacquire(muxid);
}
801069c0:	c9                   	leave  
801069c1:	c3                   	ret    

801069c2 <cvsignal>:

void cvsignal(int muxid)
{
801069c2:	55                   	push   %ebp
801069c3:	89 e5                	mov    %esp,%ebp
801069c5:	83 ec 18             	sub    $0x18,%esp
	int gid;

	if(proc->mxproc[muxid] < 0)
801069c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069ce:	8b 55 08             	mov    0x8(%ebp),%edx
801069d1:	81 c2 dc 00 00 00    	add    $0xdc,%edx
801069d7:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801069db:	85 c0                	test   %eax,%eax
801069dd:	78 4e                	js     80106a2d <cvsignal+0x6b>
		return;

    gid = proc->mxproc[muxid];
801069df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069e5:	8b 55 08             	mov    0x8(%ebp),%edx
801069e8:	81 c2 dc 00 00 00    	add    $0xdc,%edx
801069ee:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801069f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	
	if(mxarray[gid].name == 0)
801069f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069f8:	89 d0                	mov    %edx,%eax
801069fa:	c1 e0 02             	shl    $0x2,%eax
801069fd:	01 d0                	add    %edx,%eax
801069ff:	c1 e0 02             	shl    $0x2,%eax
80106a02:	05 28 5d 11 80       	add    $0x80115d28,%eax
80106a07:	8b 00                	mov    (%eax),%eax
80106a09:	85 c0                	test   %eax,%eax
80106a0b:	74 23                	je     80106a30 <cvsignal+0x6e>
		return;
	//if(mxarray[gid].lock == 0)
		//panic("Lock Not Held");

	//mxrelease(muxid);
	wakeup(&mxarray[gid]);
80106a0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106a10:	89 d0                	mov    %edx,%eax
80106a12:	c1 e0 02             	shl    $0x2,%eax
80106a15:	01 d0                	add    %edx,%eax
80106a17:	c1 e0 02             	shl    $0x2,%eax
80106a1a:	05 20 5d 11 80       	add    $0x80115d20,%eax
80106a1f:	83 ec 0c             	sub    $0xc,%esp
80106a22:	50                   	push   %eax
80106a23:	e8 bc f8 ff ff       	call   801062e4 <wakeup>
80106a28:	83 c4 10             	add    $0x10,%esp
80106a2b:	eb 04                	jmp    80106a31 <cvsignal+0x6f>
void cvsignal(int muxid)
{
	int gid;

	if(proc->mxproc[muxid] < 0)
		return;
80106a2d:	90                   	nop
80106a2e:	eb 01                	jmp    80106a31 <cvsignal+0x6f>

    gid = proc->mxproc[muxid];
	
	if(mxarray[gid].name == 0)
		return;
80106a30:	90                   	nop
	//if(mxarray[gid].lock == 0)
		//panic("Lock Not Held");

	//mxrelease(muxid);
	wakeup(&mxarray[gid]);
}
80106a31:	c9                   	leave  
80106a32:	c3                   	ret    

80106a33 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80106a33:	55                   	push   %ebp
80106a34:	89 e5                	mov    %esp,%ebp
80106a36:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80106a39:	9c                   	pushf  
80106a3a:	58                   	pop    %eax
80106a3b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80106a3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106a41:	c9                   	leave  
80106a42:	c3                   	ret    

80106a43 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80106a43:	55                   	push   %ebp
80106a44:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80106a46:	fa                   	cli    
}
80106a47:	90                   	nop
80106a48:	5d                   	pop    %ebp
80106a49:	c3                   	ret    

80106a4a <sti>:

static inline void
sti(void)
{
80106a4a:	55                   	push   %ebp
80106a4b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80106a4d:	fb                   	sti    
}
80106a4e:	90                   	nop
80106a4f:	5d                   	pop    %ebp
80106a50:	c3                   	ret    

80106a51 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80106a51:	55                   	push   %ebp
80106a52:	89 e5                	mov    %esp,%ebp
80106a54:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80106a57:	8b 55 08             	mov    0x8(%ebp),%edx
80106a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106a60:	f0 87 02             	lock xchg %eax,(%edx)
80106a63:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80106a66:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106a69:	c9                   	leave  
80106a6a:	c3                   	ret    

80106a6b <initlock>:
#include "mmu.h"
#include "proc.h"
#include "spinlock.h"

void initlock(struct spinlock *lk, char *name)
{
80106a6b:	55                   	push   %ebp
80106a6c:	89 e5                	mov    %esp,%ebp
	lk->name = name;
80106a6e:	8b 45 08             	mov    0x8(%ebp),%eax
80106a71:	8b 55 0c             	mov    0xc(%ebp),%edx
80106a74:	89 50 04             	mov    %edx,0x4(%eax)
	lk->locked = 0;
80106a77:	8b 45 08             	mov    0x8(%ebp),%eax
80106a7a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	lk->cpu = 0;
80106a80:	8b 45 08             	mov    0x8(%ebp),%eax
80106a83:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80106a8a:	90                   	nop
80106a8b:	5d                   	pop    %ebp
80106a8c:	c3                   	ret    

80106a8d <acquire>:
// Acquire the lock.
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void acquire(struct spinlock *lk)
{
80106a8d:	55                   	push   %ebp
80106a8e:	89 e5                	mov    %esp,%ebp
80106a90:	83 ec 08             	sub    $0x8,%esp
	pushcli();		// disable interrupts to avoid deadlock.
80106a93:	e8 52 01 00 00       	call   80106bea <pushcli>
	if (holding(lk))
80106a98:	8b 45 08             	mov    0x8(%ebp),%eax
80106a9b:	83 ec 0c             	sub    $0xc,%esp
80106a9e:	50                   	push   %eax
80106a9f:	e8 1c 01 00 00       	call   80106bc0 <holding>
80106aa4:	83 c4 10             	add    $0x10,%esp
80106aa7:	85 c0                	test   %eax,%eax
80106aa9:	74 0d                	je     80106ab8 <acquire+0x2b>
		panic("acquire");
80106aab:	83 ec 0c             	sub    $0xc,%esp
80106aae:	68 69 ac 10 80       	push   $0x8010ac69
80106ab3:	e8 ae 9a ff ff       	call   80100566 <panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0) ;
80106ab8:	90                   	nop
80106ab9:	8b 45 08             	mov    0x8(%ebp),%eax
80106abc:	83 ec 08             	sub    $0x8,%esp
80106abf:	6a 01                	push   $0x1
80106ac1:	50                   	push   %eax
80106ac2:	e8 8a ff ff ff       	call   80106a51 <xchg>
80106ac7:	83 c4 10             	add    $0x10,%esp
80106aca:	85 c0                	test   %eax,%eax
80106acc:	75 eb                	jne    80106ab9 <acquire+0x2c>

	// Record info about lock acquisition for debugging.
	lk->cpu = cpu;
80106ace:	8b 45 08             	mov    0x8(%ebp),%eax
80106ad1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106ad8:	89 50 08             	mov    %edx,0x8(%eax)
	getcallerpcs(&lk, lk->pcs);
80106adb:	8b 45 08             	mov    0x8(%ebp),%eax
80106ade:	83 c0 0c             	add    $0xc,%eax
80106ae1:	83 ec 08             	sub    $0x8,%esp
80106ae4:	50                   	push   %eax
80106ae5:	8d 45 08             	lea    0x8(%ebp),%eax
80106ae8:	50                   	push   %eax
80106ae9:	e8 58 00 00 00       	call   80106b46 <getcallerpcs>
80106aee:	83 c4 10             	add    $0x10,%esp
}
80106af1:	90                   	nop
80106af2:	c9                   	leave  
80106af3:	c3                   	ret    

80106af4 <release>:

// Release the lock.
void release(struct spinlock *lk)
{
80106af4:	55                   	push   %ebp
80106af5:	89 e5                	mov    %esp,%ebp
80106af7:	83 ec 08             	sub    $0x8,%esp
	if (!holding(lk))
80106afa:	83 ec 0c             	sub    $0xc,%esp
80106afd:	ff 75 08             	pushl  0x8(%ebp)
80106b00:	e8 bb 00 00 00       	call   80106bc0 <holding>
80106b05:	83 c4 10             	add    $0x10,%esp
80106b08:	85 c0                	test   %eax,%eax
80106b0a:	75 0d                	jne    80106b19 <release+0x25>
		panic("release");
80106b0c:	83 ec 0c             	sub    $0xc,%esp
80106b0f:	68 71 ac 10 80       	push   $0x8010ac71
80106b14:	e8 4d 9a ff ff       	call   80100566 <panic>

	lk->pcs[0] = 0;
80106b19:	8b 45 08             	mov    0x8(%ebp),%eax
80106b1c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	lk->cpu = 0;
80106b23:	8b 45 08             	mov    0x8(%ebp),%eax
80106b26:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	// But the 2007 Intel 64 Architecture Memory Ordering White
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
80106b2d:	8b 45 08             	mov    0x8(%ebp),%eax
80106b30:	83 ec 08             	sub    $0x8,%esp
80106b33:	6a 00                	push   $0x0
80106b35:	50                   	push   %eax
80106b36:	e8 16 ff ff ff       	call   80106a51 <xchg>
80106b3b:	83 c4 10             	add    $0x10,%esp

	popcli();
80106b3e:	e8 ec 00 00 00       	call   80106c2f <popcli>
}
80106b43:	90                   	nop
80106b44:	c9                   	leave  
80106b45:	c3                   	ret    

80106b46 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void getcallerpcs(void *v, uint pcs[])
{
80106b46:	55                   	push   %ebp
80106b47:	89 e5                	mov    %esp,%ebp
80106b49:	83 ec 10             	sub    $0x10,%esp
	uint *ebp;
	int i;

	ebp = (uint *) v - 2;
80106b4c:	8b 45 08             	mov    0x8(%ebp),%eax
80106b4f:	83 e8 08             	sub    $0x8,%eax
80106b52:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (i = 0; i < 10; i++) {
80106b55:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80106b5c:	eb 38                	jmp    80106b96 <getcallerpcs+0x50>
		if (ebp == 0 || ebp < (uint *) KERNBASE
80106b5e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80106b62:	74 53                	je     80106bb7 <getcallerpcs+0x71>
80106b64:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80106b6b:	76 4a                	jbe    80106bb7 <getcallerpcs+0x71>
		    || ebp == (uint *) 0xffffffff)
80106b6d:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80106b71:	74 44                	je     80106bb7 <getcallerpcs+0x71>
			break;
		pcs[i] = ebp[1];	// saved %eip
80106b73:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106b76:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106b7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b80:	01 c2                	add    %eax,%edx
80106b82:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106b85:	8b 40 04             	mov    0x4(%eax),%eax
80106b88:	89 02                	mov    %eax,(%edx)
		ebp = (uint *) ebp[0];	// saved %ebp
80106b8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106b8d:	8b 00                	mov    (%eax),%eax
80106b8f:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
	uint *ebp;
	int i;

	ebp = (uint *) v - 2;
	for (i = 0; i < 10; i++) {
80106b92:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80106b96:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106b9a:	7e c2                	jle    80106b5e <getcallerpcs+0x18>
		    || ebp == (uint *) 0xffffffff)
			break;
		pcs[i] = ebp[1];	// saved %eip
		ebp = (uint *) ebp[0];	// saved %ebp
	}
	for (; i < 10; i++)
80106b9c:	eb 19                	jmp    80106bb7 <getcallerpcs+0x71>
		pcs[i] = 0;
80106b9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106ba1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
80106bab:	01 d0                	add    %edx,%eax
80106bad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		    || ebp == (uint *) 0xffffffff)
			break;
		pcs[i] = ebp[1];	// saved %eip
		ebp = (uint *) ebp[0];	// saved %ebp
	}
	for (; i < 10; i++)
80106bb3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80106bb7:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106bbb:	7e e1                	jle    80106b9e <getcallerpcs+0x58>
		pcs[i] = 0;
}
80106bbd:	90                   	nop
80106bbe:	c9                   	leave  
80106bbf:	c3                   	ret    

80106bc0 <holding>:

// Check whether this cpu is holding the lock.
int holding(struct spinlock *lock)
{
80106bc0:	55                   	push   %ebp
80106bc1:	89 e5                	mov    %esp,%ebp
	return lock->locked && lock->cpu == cpu;
80106bc3:	8b 45 08             	mov    0x8(%ebp),%eax
80106bc6:	8b 00                	mov    (%eax),%eax
80106bc8:	85 c0                	test   %eax,%eax
80106bca:	74 17                	je     80106be3 <holding+0x23>
80106bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80106bcf:	8b 50 08             	mov    0x8(%eax),%edx
80106bd2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106bd8:	39 c2                	cmp    %eax,%edx
80106bda:	75 07                	jne    80106be3 <holding+0x23>
80106bdc:	b8 01 00 00 00       	mov    $0x1,%eax
80106be1:	eb 05                	jmp    80106be8 <holding+0x28>
80106be3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106be8:	5d                   	pop    %ebp
80106be9:	c3                   	ret    

80106bea <pushcli>:
// Pushcli/popcli are like cli/sti except that they are matched:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void pushcli(void)
{
80106bea:	55                   	push   %ebp
80106beb:	89 e5                	mov    %esp,%ebp
80106bed:	83 ec 10             	sub    $0x10,%esp
	int eflags;

	eflags = readeflags();
80106bf0:	e8 3e fe ff ff       	call   80106a33 <readeflags>
80106bf5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cli();
80106bf8:	e8 46 fe ff ff       	call   80106a43 <cli>
	if (cpu->ncli++ == 0)
80106bfd:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106c04:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80106c0a:	8d 48 01             	lea    0x1(%eax),%ecx
80106c0d:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80106c13:	85 c0                	test   %eax,%eax
80106c15:	75 15                	jne    80106c2c <pushcli+0x42>
		cpu->intena = eflags & FL_IF;
80106c17:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c1d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106c20:	81 e2 00 02 00 00    	and    $0x200,%edx
80106c26:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80106c2c:	90                   	nop
80106c2d:	c9                   	leave  
80106c2e:	c3                   	ret    

80106c2f <popcli>:

void popcli(void)
{
80106c2f:	55                   	push   %ebp
80106c30:	89 e5                	mov    %esp,%ebp
80106c32:	83 ec 08             	sub    $0x8,%esp
	if (readeflags() & FL_IF)
80106c35:	e8 f9 fd ff ff       	call   80106a33 <readeflags>
80106c3a:	25 00 02 00 00       	and    $0x200,%eax
80106c3f:	85 c0                	test   %eax,%eax
80106c41:	74 0d                	je     80106c50 <popcli+0x21>
		panic("popcli - interruptible");
80106c43:	83 ec 0c             	sub    $0xc,%esp
80106c46:	68 79 ac 10 80       	push   $0x8010ac79
80106c4b:	e8 16 99 ff ff       	call   80100566 <panic>
	if (--cpu->ncli < 0)
80106c50:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c56:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80106c5c:	83 ea 01             	sub    $0x1,%edx
80106c5f:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80106c65:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106c6b:	85 c0                	test   %eax,%eax
80106c6d:	79 0d                	jns    80106c7c <popcli+0x4d>
		panic("popcli");
80106c6f:	83 ec 0c             	sub    $0xc,%esp
80106c72:	68 90 ac 10 80       	push   $0x8010ac90
80106c77:	e8 ea 98 ff ff       	call   80100566 <panic>
	if (cpu->ncli == 0 && cpu->intena)
80106c7c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c82:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106c88:	85 c0                	test   %eax,%eax
80106c8a:	75 15                	jne    80106ca1 <popcli+0x72>
80106c8c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c92:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106c98:	85 c0                	test   %eax,%eax
80106c9a:	74 05                	je     80106ca1 <popcli+0x72>
		sti();
80106c9c:	e8 a9 fd ff ff       	call   80106a4a <sti>
}
80106ca1:	90                   	nop
80106ca2:	c9                   	leave  
80106ca3:	c3                   	ret    

80106ca4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80106ca4:	55                   	push   %ebp
80106ca5:	89 e5                	mov    %esp,%ebp
80106ca7:	57                   	push   %edi
80106ca8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80106ca9:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106cac:	8b 55 10             	mov    0x10(%ebp),%edx
80106caf:	8b 45 0c             	mov    0xc(%ebp),%eax
80106cb2:	89 cb                	mov    %ecx,%ebx
80106cb4:	89 df                	mov    %ebx,%edi
80106cb6:	89 d1                	mov    %edx,%ecx
80106cb8:	fc                   	cld    
80106cb9:	f3 aa                	rep stos %al,%es:(%edi)
80106cbb:	89 ca                	mov    %ecx,%edx
80106cbd:	89 fb                	mov    %edi,%ebx
80106cbf:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106cc2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106cc5:	90                   	nop
80106cc6:	5b                   	pop    %ebx
80106cc7:	5f                   	pop    %edi
80106cc8:	5d                   	pop    %ebp
80106cc9:	c3                   	ret    

80106cca <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80106cca:	55                   	push   %ebp
80106ccb:	89 e5                	mov    %esp,%ebp
80106ccd:	57                   	push   %edi
80106cce:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80106ccf:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106cd2:	8b 55 10             	mov    0x10(%ebp),%edx
80106cd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80106cd8:	89 cb                	mov    %ecx,%ebx
80106cda:	89 df                	mov    %ebx,%edi
80106cdc:	89 d1                	mov    %edx,%ecx
80106cde:	fc                   	cld    
80106cdf:	f3 ab                	rep stos %eax,%es:(%edi)
80106ce1:	89 ca                	mov    %ecx,%edx
80106ce3:	89 fb                	mov    %edi,%ebx
80106ce5:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106ce8:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106ceb:	90                   	nop
80106cec:	5b                   	pop    %ebx
80106ced:	5f                   	pop    %edi
80106cee:	5d                   	pop    %ebp
80106cef:	c3                   	ret    

80106cf0 <memset>:
#include "types.h"
#include "x86.h"

void *memset(void *dst, int c, uint n)
{
80106cf0:	55                   	push   %ebp
80106cf1:	89 e5                	mov    %esp,%ebp
	if ((int)dst % 4 == 0 && n % 4 == 0) {
80106cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80106cf6:	83 e0 03             	and    $0x3,%eax
80106cf9:	85 c0                	test   %eax,%eax
80106cfb:	75 43                	jne    80106d40 <memset+0x50>
80106cfd:	8b 45 10             	mov    0x10(%ebp),%eax
80106d00:	83 e0 03             	and    $0x3,%eax
80106d03:	85 c0                	test   %eax,%eax
80106d05:	75 39                	jne    80106d40 <memset+0x50>
		c &= 0xFF;
80106d07:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		stosl(dst, (c << 24) | (c << 16) | (c << 8) | c, n / 4);
80106d0e:	8b 45 10             	mov    0x10(%ebp),%eax
80106d11:	c1 e8 02             	shr    $0x2,%eax
80106d14:	89 c1                	mov    %eax,%ecx
80106d16:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d19:	c1 e0 18             	shl    $0x18,%eax
80106d1c:	89 c2                	mov    %eax,%edx
80106d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d21:	c1 e0 10             	shl    $0x10,%eax
80106d24:	09 c2                	or     %eax,%edx
80106d26:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d29:	c1 e0 08             	shl    $0x8,%eax
80106d2c:	09 d0                	or     %edx,%eax
80106d2e:	0b 45 0c             	or     0xc(%ebp),%eax
80106d31:	51                   	push   %ecx
80106d32:	50                   	push   %eax
80106d33:	ff 75 08             	pushl  0x8(%ebp)
80106d36:	e8 8f ff ff ff       	call   80106cca <stosl>
80106d3b:	83 c4 0c             	add    $0xc,%esp
80106d3e:	eb 12                	jmp    80106d52 <memset+0x62>
	} else
		stosb(dst, c, n);
80106d40:	8b 45 10             	mov    0x10(%ebp),%eax
80106d43:	50                   	push   %eax
80106d44:	ff 75 0c             	pushl  0xc(%ebp)
80106d47:	ff 75 08             	pushl  0x8(%ebp)
80106d4a:	e8 55 ff ff ff       	call   80106ca4 <stosb>
80106d4f:	83 c4 0c             	add    $0xc,%esp
	return dst;
80106d52:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106d55:	c9                   	leave  
80106d56:	c3                   	ret    

80106d57 <memcmp>:

int memcmp(const void *v1, const void *v2, uint n)
{
80106d57:	55                   	push   %ebp
80106d58:	89 e5                	mov    %esp,%ebp
80106d5a:	83 ec 10             	sub    $0x10,%esp
	const uchar *s1, *s2;

	s1 = v1;
80106d5d:	8b 45 08             	mov    0x8(%ebp),%eax
80106d60:	89 45 fc             	mov    %eax,-0x4(%ebp)
	s2 = v2;
80106d63:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d66:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0) {
80106d69:	eb 30                	jmp    80106d9b <memcmp+0x44>
		if (*s1 != *s2)
80106d6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106d6e:	0f b6 10             	movzbl (%eax),%edx
80106d71:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106d74:	0f b6 00             	movzbl (%eax),%eax
80106d77:	38 c2                	cmp    %al,%dl
80106d79:	74 18                	je     80106d93 <memcmp+0x3c>
			return *s1 - *s2;
80106d7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106d7e:	0f b6 00             	movzbl (%eax),%eax
80106d81:	0f b6 d0             	movzbl %al,%edx
80106d84:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106d87:	0f b6 00             	movzbl (%eax),%eax
80106d8a:	0f b6 c0             	movzbl %al,%eax
80106d8d:	29 c2                	sub    %eax,%edx
80106d8f:	89 d0                	mov    %edx,%eax
80106d91:	eb 1a                	jmp    80106dad <memcmp+0x56>
		s1++, s2++;
80106d93:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106d97:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
	const uchar *s1, *s2;

	s1 = v1;
	s2 = v2;
	while (n-- > 0) {
80106d9b:	8b 45 10             	mov    0x10(%ebp),%eax
80106d9e:	8d 50 ff             	lea    -0x1(%eax),%edx
80106da1:	89 55 10             	mov    %edx,0x10(%ebp)
80106da4:	85 c0                	test   %eax,%eax
80106da6:	75 c3                	jne    80106d6b <memcmp+0x14>
		if (*s1 != *s2)
			return *s1 - *s2;
		s1++, s2++;
	}

	return 0;
80106da8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106dad:	c9                   	leave  
80106dae:	c3                   	ret    

80106daf <memmove>:

void *memmove(void *dst, const void *src, uint n)
{
80106daf:	55                   	push   %ebp
80106db0:	89 e5                	mov    %esp,%ebp
80106db2:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
80106db5:	8b 45 0c             	mov    0xc(%ebp),%eax
80106db8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
80106dbb:	8b 45 08             	mov    0x8(%ebp),%eax
80106dbe:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
80106dc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106dc4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106dc7:	73 54                	jae    80106e1d <memmove+0x6e>
80106dc9:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106dcc:	8b 45 10             	mov    0x10(%ebp),%eax
80106dcf:	01 d0                	add    %edx,%eax
80106dd1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106dd4:	76 47                	jbe    80106e1d <memmove+0x6e>
		s += n;
80106dd6:	8b 45 10             	mov    0x10(%ebp),%eax
80106dd9:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
80106ddc:	8b 45 10             	mov    0x10(%ebp),%eax
80106ddf:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
80106de2:	eb 13                	jmp    80106df7 <memmove+0x48>
			*--d = *--s;
80106de4:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80106de8:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80106dec:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106def:	0f b6 10             	movzbl (%eax),%edx
80106df2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106df5:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
80106df7:	8b 45 10             	mov    0x10(%ebp),%eax
80106dfa:	8d 50 ff             	lea    -0x1(%eax),%edx
80106dfd:	89 55 10             	mov    %edx,0x10(%ebp)
80106e00:	85 c0                	test   %eax,%eax
80106e02:	75 e0                	jne    80106de4 <memmove+0x35>
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
80106e04:	eb 24                	jmp    80106e2a <memmove+0x7b>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
80106e06:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106e09:	8d 50 01             	lea    0x1(%eax),%edx
80106e0c:	89 55 f8             	mov    %edx,-0x8(%ebp)
80106e0f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106e12:	8d 4a 01             	lea    0x1(%edx),%ecx
80106e15:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80106e18:	0f b6 12             	movzbl (%edx),%edx
80106e1b:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
80106e1d:	8b 45 10             	mov    0x10(%ebp),%eax
80106e20:	8d 50 ff             	lea    -0x1(%eax),%edx
80106e23:	89 55 10             	mov    %edx,0x10(%ebp)
80106e26:	85 c0                	test   %eax,%eax
80106e28:	75 dc                	jne    80106e06 <memmove+0x57>
			*d++ = *s++;

	return dst;
80106e2a:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106e2d:	c9                   	leave  
80106e2e:	c3                   	ret    

80106e2f <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *memcpy(void *dst, const void *src, uint n)
{
80106e2f:	55                   	push   %ebp
80106e30:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
80106e32:	ff 75 10             	pushl  0x10(%ebp)
80106e35:	ff 75 0c             	pushl  0xc(%ebp)
80106e38:	ff 75 08             	pushl  0x8(%ebp)
80106e3b:	e8 6f ff ff ff       	call   80106daf <memmove>
80106e40:	83 c4 0c             	add    $0xc,%esp
}
80106e43:	c9                   	leave  
80106e44:	c3                   	ret    

80106e45 <strncmp>:

int strncmp(const char *p, const char *q, uint n)
{
80106e45:	55                   	push   %ebp
80106e46:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
80106e48:	eb 0c                	jmp    80106e56 <strncmp+0x11>
		n--, p++, q++;
80106e4a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106e4e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80106e52:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	return memmove(dst, src, n);
}

int strncmp(const char *p, const char *q, uint n)
{
	while (n > 0 && *p && *p == *q)
80106e56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106e5a:	74 1a                	je     80106e76 <strncmp+0x31>
80106e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e5f:	0f b6 00             	movzbl (%eax),%eax
80106e62:	84 c0                	test   %al,%al
80106e64:	74 10                	je     80106e76 <strncmp+0x31>
80106e66:	8b 45 08             	mov    0x8(%ebp),%eax
80106e69:	0f b6 10             	movzbl (%eax),%edx
80106e6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e6f:	0f b6 00             	movzbl (%eax),%eax
80106e72:	38 c2                	cmp    %al,%dl
80106e74:	74 d4                	je     80106e4a <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
80106e76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106e7a:	75 07                	jne    80106e83 <strncmp+0x3e>
		return 0;
80106e7c:	b8 00 00 00 00       	mov    $0x0,%eax
80106e81:	eb 16                	jmp    80106e99 <strncmp+0x54>
	return (uchar) * p - (uchar) * q;
80106e83:	8b 45 08             	mov    0x8(%ebp),%eax
80106e86:	0f b6 00             	movzbl (%eax),%eax
80106e89:	0f b6 d0             	movzbl %al,%edx
80106e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e8f:	0f b6 00             	movzbl (%eax),%eax
80106e92:	0f b6 c0             	movzbl %al,%eax
80106e95:	29 c2                	sub    %eax,%edx
80106e97:	89 d0                	mov    %edx,%eax
}
80106e99:	5d                   	pop    %ebp
80106e9a:	c3                   	ret    

80106e9b <strncpy>:

char *strncpy(char *s, const char *t, int n)
{
80106e9b:	55                   	push   %ebp
80106e9c:	89 e5                	mov    %esp,%ebp
80106e9e:	83 ec 10             	sub    $0x10,%esp
	char *os;

	os = s;
80106ea1:	8b 45 08             	mov    0x8(%ebp),%eax
80106ea4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while (n-- > 0 && (*s++ = *t++) != 0) ;
80106ea7:	90                   	nop
80106ea8:	8b 45 10             	mov    0x10(%ebp),%eax
80106eab:	8d 50 ff             	lea    -0x1(%eax),%edx
80106eae:	89 55 10             	mov    %edx,0x10(%ebp)
80106eb1:	85 c0                	test   %eax,%eax
80106eb3:	7e 2c                	jle    80106ee1 <strncpy+0x46>
80106eb5:	8b 45 08             	mov    0x8(%ebp),%eax
80106eb8:	8d 50 01             	lea    0x1(%eax),%edx
80106ebb:	89 55 08             	mov    %edx,0x8(%ebp)
80106ebe:	8b 55 0c             	mov    0xc(%ebp),%edx
80106ec1:	8d 4a 01             	lea    0x1(%edx),%ecx
80106ec4:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106ec7:	0f b6 12             	movzbl (%edx),%edx
80106eca:	88 10                	mov    %dl,(%eax)
80106ecc:	0f b6 00             	movzbl (%eax),%eax
80106ecf:	84 c0                	test   %al,%al
80106ed1:	75 d5                	jne    80106ea8 <strncpy+0xd>
	while (n-- > 0)
80106ed3:	eb 0c                	jmp    80106ee1 <strncpy+0x46>
		*s++ = 0;
80106ed5:	8b 45 08             	mov    0x8(%ebp),%eax
80106ed8:	8d 50 01             	lea    0x1(%eax),%edx
80106edb:	89 55 08             	mov    %edx,0x8(%ebp)
80106ede:	c6 00 00             	movb   $0x0,(%eax)
{
	char *os;

	os = s;
	while (n-- > 0 && (*s++ = *t++) != 0) ;
	while (n-- > 0)
80106ee1:	8b 45 10             	mov    0x10(%ebp),%eax
80106ee4:	8d 50 ff             	lea    -0x1(%eax),%edx
80106ee7:	89 55 10             	mov    %edx,0x10(%ebp)
80106eea:	85 c0                	test   %eax,%eax
80106eec:	7f e7                	jg     80106ed5 <strncpy+0x3a>
		*s++ = 0;
	return os;
80106eee:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106ef1:	c9                   	leave  
80106ef2:	c3                   	ret    

80106ef3 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *safestrcpy(char *s, const char *t, int n)
{
80106ef3:	55                   	push   %ebp
80106ef4:	89 e5                	mov    %esp,%ebp
80106ef6:	83 ec 10             	sub    $0x10,%esp
	char *os;

	os = s;
80106ef9:	8b 45 08             	mov    0x8(%ebp),%eax
80106efc:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (n <= 0)
80106eff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106f03:	7f 05                	jg     80106f0a <safestrcpy+0x17>
		return os;
80106f05:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106f08:	eb 31                	jmp    80106f3b <safestrcpy+0x48>
	while (--n > 0 && (*s++ = *t++) != 0) ;
80106f0a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106f0e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106f12:	7e 1e                	jle    80106f32 <safestrcpy+0x3f>
80106f14:	8b 45 08             	mov    0x8(%ebp),%eax
80106f17:	8d 50 01             	lea    0x1(%eax),%edx
80106f1a:	89 55 08             	mov    %edx,0x8(%ebp)
80106f1d:	8b 55 0c             	mov    0xc(%ebp),%edx
80106f20:	8d 4a 01             	lea    0x1(%edx),%ecx
80106f23:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106f26:	0f b6 12             	movzbl (%edx),%edx
80106f29:	88 10                	mov    %dl,(%eax)
80106f2b:	0f b6 00             	movzbl (%eax),%eax
80106f2e:	84 c0                	test   %al,%al
80106f30:	75 d8                	jne    80106f0a <safestrcpy+0x17>
	*s = 0;
80106f32:	8b 45 08             	mov    0x8(%ebp),%eax
80106f35:	c6 00 00             	movb   $0x0,(%eax)
	return os;
80106f38:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106f3b:	c9                   	leave  
80106f3c:	c3                   	ret    

80106f3d <strlen>:

int strlen(const char *s)
{
80106f3d:	55                   	push   %ebp
80106f3e:	89 e5                	mov    %esp,%ebp
80106f40:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; s[n]; n++) ;
80106f43:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106f4a:	eb 04                	jmp    80106f50 <strlen+0x13>
80106f4c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106f50:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106f53:	8b 45 08             	mov    0x8(%ebp),%eax
80106f56:	01 d0                	add    %edx,%eax
80106f58:	0f b6 00             	movzbl (%eax),%eax
80106f5b:	84 c0                	test   %al,%al
80106f5d:	75 ed                	jne    80106f4c <strlen+0xf>
	return n;
80106f5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106f62:	c9                   	leave  
80106f63:	c3                   	ret    

80106f64 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80106f64:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80106f68:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106f6c:	55                   	push   %ebp
  pushl %ebx
80106f6d:	53                   	push   %ebx
  pushl %esi
80106f6e:	56                   	push   %esi
  pushl %edi
80106f6f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106f70:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80106f72:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80106f74:	5f                   	pop    %edi
  popl %esi
80106f75:	5e                   	pop    %esi
  popl %ebx
80106f76:	5b                   	pop    %ebx
  popl %ebp
80106f77:	5d                   	pop    %ebp
  ret
80106f78:	c3                   	ret    

80106f79 <fetchint>:
// library system call function. The saved user %esp points
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int fetchint(uint addr, int *ip)
{
80106f79:	55                   	push   %ebp
80106f7a:	89 e5                	mov    %esp,%ebp
	if (addr >= proc->sz || addr + 4 > proc->sz)
80106f7c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f82:	8b 00                	mov    (%eax),%eax
80106f84:	3b 45 08             	cmp    0x8(%ebp),%eax
80106f87:	76 12                	jbe    80106f9b <fetchint+0x22>
80106f89:	8b 45 08             	mov    0x8(%ebp),%eax
80106f8c:	8d 50 04             	lea    0x4(%eax),%edx
80106f8f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f95:	8b 00                	mov    (%eax),%eax
80106f97:	39 c2                	cmp    %eax,%edx
80106f99:	76 07                	jbe    80106fa2 <fetchint+0x29>
		return -1;
80106f9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fa0:	eb 0f                	jmp    80106fb1 <fetchint+0x38>
	*ip = *(int *)(addr);
80106fa2:	8b 45 08             	mov    0x8(%ebp),%eax
80106fa5:	8b 10                	mov    (%eax),%edx
80106fa7:	8b 45 0c             	mov    0xc(%ebp),%eax
80106faa:	89 10                	mov    %edx,(%eax)
	return 0;
80106fac:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106fb1:	5d                   	pop    %ebp
80106fb2:	c3                   	ret    

80106fb3 <fetchstr>:

// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int fetchstr(uint addr, char **pp)
{
80106fb3:	55                   	push   %ebp
80106fb4:	89 e5                	mov    %esp,%ebp
80106fb6:	83 ec 10             	sub    $0x10,%esp
	char *s, *ep;

	if (addr >= proc->sz)
80106fb9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fbf:	8b 00                	mov    (%eax),%eax
80106fc1:	3b 45 08             	cmp    0x8(%ebp),%eax
80106fc4:	77 07                	ja     80106fcd <fetchstr+0x1a>
		return -1;
80106fc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fcb:	eb 46                	jmp    80107013 <fetchstr+0x60>
	*pp = (char *)addr;
80106fcd:	8b 55 08             	mov    0x8(%ebp),%edx
80106fd0:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fd3:	89 10                	mov    %edx,(%eax)
	ep = (char *)proc->sz;
80106fd5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fdb:	8b 00                	mov    (%eax),%eax
80106fdd:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (s = *pp; s < ep; s++)
80106fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fe3:	8b 00                	mov    (%eax),%eax
80106fe5:	89 45 fc             	mov    %eax,-0x4(%ebp)
80106fe8:	eb 1c                	jmp    80107006 <fetchstr+0x53>
		if (*s == 0)
80106fea:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106fed:	0f b6 00             	movzbl (%eax),%eax
80106ff0:	84 c0                	test   %al,%al
80106ff2:	75 0e                	jne    80107002 <fetchstr+0x4f>
			return s - *pp;
80106ff4:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106ff7:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ffa:	8b 00                	mov    (%eax),%eax
80106ffc:	29 c2                	sub    %eax,%edx
80106ffe:	89 d0                	mov    %edx,%eax
80107000:	eb 11                	jmp    80107013 <fetchstr+0x60>

	if (addr >= proc->sz)
		return -1;
	*pp = (char *)addr;
	ep = (char *)proc->sz;
	for (s = *pp; s < ep; s++)
80107002:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80107006:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107009:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010700c:	72 dc                	jb     80106fea <fetchstr+0x37>
		if (*s == 0)
			return s - *pp;
	return -1;
8010700e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107013:	c9                   	leave  
80107014:	c3                   	ret    

80107015 <argint>:

// Fetch the nth 32-bit system call argument.
int argint(int n, int *ip)
{
80107015:	55                   	push   %ebp
80107016:	89 e5                	mov    %esp,%ebp
	return fetchint(proc->tf->esp + 4 + 4 * n, ip);
80107018:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010701e:	8b 40 18             	mov    0x18(%eax),%eax
80107021:	8b 40 44             	mov    0x44(%eax),%eax
80107024:	8b 55 08             	mov    0x8(%ebp),%edx
80107027:	c1 e2 02             	shl    $0x2,%edx
8010702a:	01 d0                	add    %edx,%eax
8010702c:	83 c0 04             	add    $0x4,%eax
8010702f:	ff 75 0c             	pushl  0xc(%ebp)
80107032:	50                   	push   %eax
80107033:	e8 41 ff ff ff       	call   80106f79 <fetchint>
80107038:	83 c4 08             	add    $0x8,%esp
}
8010703b:	c9                   	leave  
8010703c:	c3                   	ret    

8010703d <argptr>:

// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int argptr(int n, char **pp, int size)
{
8010703d:	55                   	push   %ebp
8010703e:	89 e5                	mov    %esp,%ebp
80107040:	83 ec 10             	sub    $0x10,%esp
	int i;

	if (argint(n, &i) < 0)
80107043:	8d 45 fc             	lea    -0x4(%ebp),%eax
80107046:	50                   	push   %eax
80107047:	ff 75 08             	pushl  0x8(%ebp)
8010704a:	e8 c6 ff ff ff       	call   80107015 <argint>
8010704f:	83 c4 08             	add    $0x8,%esp
80107052:	85 c0                	test   %eax,%eax
80107054:	79 07                	jns    8010705d <argptr+0x20>
		return -1;
80107056:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010705b:	eb 3b                	jmp    80107098 <argptr+0x5b>
	if ((uint) i >= proc->sz || (uint) i + size > proc->sz)
8010705d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107063:	8b 00                	mov    (%eax),%eax
80107065:	8b 55 fc             	mov    -0x4(%ebp),%edx
80107068:	39 d0                	cmp    %edx,%eax
8010706a:	76 16                	jbe    80107082 <argptr+0x45>
8010706c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010706f:	89 c2                	mov    %eax,%edx
80107071:	8b 45 10             	mov    0x10(%ebp),%eax
80107074:	01 c2                	add    %eax,%edx
80107076:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010707c:	8b 00                	mov    (%eax),%eax
8010707e:	39 c2                	cmp    %eax,%edx
80107080:	76 07                	jbe    80107089 <argptr+0x4c>
		return -1;
80107082:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107087:	eb 0f                	jmp    80107098 <argptr+0x5b>
	*pp = (char *)i;
80107089:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010708c:	89 c2                	mov    %eax,%edx
8010708e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107091:	89 10                	mov    %edx,(%eax)
	return 0;
80107093:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107098:	c9                   	leave  
80107099:	c3                   	ret    

8010709a <argstr>:
// Fetch the nth word-sized system call argument as a string pointer.
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int argstr(int n, char **pp)
{
8010709a:	55                   	push   %ebp
8010709b:	89 e5                	mov    %esp,%ebp
8010709d:	83 ec 10             	sub    $0x10,%esp
	int addr;
	if (argint(n, &addr) < 0)
801070a0:	8d 45 fc             	lea    -0x4(%ebp),%eax
801070a3:	50                   	push   %eax
801070a4:	ff 75 08             	pushl  0x8(%ebp)
801070a7:	e8 69 ff ff ff       	call   80107015 <argint>
801070ac:	83 c4 08             	add    $0x8,%esp
801070af:	85 c0                	test   %eax,%eax
801070b1:	79 07                	jns    801070ba <argstr+0x20>
		return -1;
801070b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070b8:	eb 0f                	jmp    801070c9 <argstr+0x2f>
	return fetchstr(addr, pp);
801070ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
801070bd:	ff 75 0c             	pushl  0xc(%ebp)
801070c0:	50                   	push   %eax
801070c1:	e8 ed fe ff ff       	call   80106fb3 <fetchstr>
801070c6:	83 c4 08             	add    $0x8,%esp
}
801070c9:	c9                   	leave  
801070ca:	c3                   	ret    

801070cb <syscall>:
	[SYS_cv_signal] sys_cv_signal,//end of mod3

};

void syscall(void)
{
801070cb:	55                   	push   %ebp
801070cc:	89 e5                	mov    %esp,%ebp
801070ce:	53                   	push   %ebx
801070cf:	83 ec 14             	sub    $0x14,%esp
	int num;

	num = proc->tf->eax;
801070d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070d8:	8b 40 18             	mov    0x18(%eax),%eax
801070db:	8b 40 1c             	mov    0x1c(%eax),%eax
801070de:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801070e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801070e5:	7e 30                	jle    80107117 <syscall+0x4c>
801070e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ea:	83 f8 1e             	cmp    $0x1e,%eax
801070ed:	77 28                	ja     80107117 <syscall+0x4c>
801070ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f2:	8b 04 85 40 e0 10 80 	mov    -0x7fef1fc0(,%eax,4),%eax
801070f9:	85 c0                	test   %eax,%eax
801070fb:	74 1a                	je     80107117 <syscall+0x4c>
		proc->tf->eax = syscalls[num] ();
801070fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107103:	8b 58 18             	mov    0x18(%eax),%ebx
80107106:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107109:	8b 04 85 40 e0 10 80 	mov    -0x7fef1fc0(,%eax,4),%eax
80107110:	ff d0                	call   *%eax
80107112:	89 43 1c             	mov    %eax,0x1c(%ebx)
80107115:	eb 34                	jmp    8010714b <syscall+0x80>
	} else {
		cprintf("%d %s: unknown sys call %d\n",
			proc->pid, proc->name, num);
80107117:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010711d:	8d 50 6c             	lea    0x6c(%eax),%edx
80107120:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

	num = proc->tf->eax;
	if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
		proc->tf->eax = syscalls[num] ();
	} else {
		cprintf("%d %s: unknown sys call %d\n",
80107126:	8b 40 10             	mov    0x10(%eax),%eax
80107129:	ff 75 f4             	pushl  -0xc(%ebp)
8010712c:	52                   	push   %edx
8010712d:	50                   	push   %eax
8010712e:	68 97 ac 10 80       	push   $0x8010ac97
80107133:	e8 8e 92 ff ff       	call   801003c6 <cprintf>
80107138:	83 c4 10             	add    $0x10,%esp
			proc->pid, proc->name, num);
		proc->tf->eax = -1;
8010713b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107141:	8b 40 18             	mov    0x18(%eax),%eax
80107144:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
	}
}
8010714b:	90                   	nop
8010714c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010714f:	c9                   	leave  
80107150:	c3                   	ret    

80107151 <argfd>:
#include "fcntl.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int argfd(int n, int *pfd, struct file **pf)
{
80107151:	55                   	push   %ebp
80107152:	89 e5                	mov    %esp,%ebp
80107154:	83 ec 18             	sub    $0x18,%esp
	int fd;
	struct file *f;

	if (argint(n, &fd) < 0)
80107157:	83 ec 08             	sub    $0x8,%esp
8010715a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010715d:	50                   	push   %eax
8010715e:	ff 75 08             	pushl  0x8(%ebp)
80107161:	e8 af fe ff ff       	call   80107015 <argint>
80107166:	83 c4 10             	add    $0x10,%esp
80107169:	85 c0                	test   %eax,%eax
8010716b:	79 07                	jns    80107174 <argfd+0x23>
		return -1;
8010716d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107172:	eb 50                	jmp    801071c4 <argfd+0x73>
	if (fd < 0 || fd >= NOFILE || (f = proc->ofile[fd]) == 0)
80107174:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107177:	85 c0                	test   %eax,%eax
80107179:	78 21                	js     8010719c <argfd+0x4b>
8010717b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010717e:	83 f8 0f             	cmp    $0xf,%eax
80107181:	7f 19                	jg     8010719c <argfd+0x4b>
80107183:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107189:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010718c:	83 c2 08             	add    $0x8,%edx
8010718f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80107193:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107196:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010719a:	75 07                	jne    801071a3 <argfd+0x52>
		return -1;
8010719c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071a1:	eb 21                	jmp    801071c4 <argfd+0x73>
	if (pfd)
801071a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801071a7:	74 08                	je     801071b1 <argfd+0x60>
		*pfd = fd;
801071a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801071ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801071af:	89 10                	mov    %edx,(%eax)
	if (pf)
801071b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801071b5:	74 08                	je     801071bf <argfd+0x6e>
		*pf = f;
801071b7:	8b 45 10             	mov    0x10(%ebp),%eax
801071ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801071bd:	89 10                	mov    %edx,(%eax)
	return 0;
801071bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801071c4:	c9                   	leave  
801071c5:	c3                   	ret    

801071c6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int fdalloc(struct file *f)
{
801071c6:	55                   	push   %ebp
801071c7:	89 e5                	mov    %esp,%ebp
801071c9:	83 ec 10             	sub    $0x10,%esp
	int fd;

	for (fd = 0; fd < NOFILE; fd++) {
801071cc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801071d3:	eb 30                	jmp    80107205 <fdalloc+0x3f>
		if (proc->ofile[fd] == 0) {
801071d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071db:	8b 55 fc             	mov    -0x4(%ebp),%edx
801071de:	83 c2 08             	add    $0x8,%edx
801071e1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801071e5:	85 c0                	test   %eax,%eax
801071e7:	75 18                	jne    80107201 <fdalloc+0x3b>
			proc->ofile[fd] = f;
801071e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071ef:	8b 55 fc             	mov    -0x4(%ebp),%edx
801071f2:	8d 4a 08             	lea    0x8(%edx),%ecx
801071f5:	8b 55 08             	mov    0x8(%ebp),%edx
801071f8:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
			return fd;
801071fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801071ff:	eb 0f                	jmp    80107210 <fdalloc+0x4a>
// Takes over file reference from caller on success.
static int fdalloc(struct file *f)
{
	int fd;

	for (fd = 0; fd < NOFILE; fd++) {
80107201:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80107205:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80107209:	7e ca                	jle    801071d5 <fdalloc+0xf>
		if (proc->ofile[fd] == 0) {
			proc->ofile[fd] = f;
			return fd;
		}
	}
	return -1;
8010720b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107210:	c9                   	leave  
80107211:	c3                   	ret    

80107212 <sys_dup>:

int sys_dup(void)
{
80107212:	55                   	push   %ebp
80107213:	89 e5                	mov    %esp,%ebp
80107215:	83 ec 18             	sub    $0x18,%esp
	struct file *f;
	int fd;

	if (argfd(0, 0, &f) < 0)
80107218:	83 ec 04             	sub    $0x4,%esp
8010721b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010721e:	50                   	push   %eax
8010721f:	6a 00                	push   $0x0
80107221:	6a 00                	push   $0x0
80107223:	e8 29 ff ff ff       	call   80107151 <argfd>
80107228:	83 c4 10             	add    $0x10,%esp
8010722b:	85 c0                	test   %eax,%eax
8010722d:	79 07                	jns    80107236 <sys_dup+0x24>
		return -1;
8010722f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107234:	eb 31                	jmp    80107267 <sys_dup+0x55>
	if ((fd = fdalloc(f)) < 0)
80107236:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107239:	83 ec 0c             	sub    $0xc,%esp
8010723c:	50                   	push   %eax
8010723d:	e8 84 ff ff ff       	call   801071c6 <fdalloc>
80107242:	83 c4 10             	add    $0x10,%esp
80107245:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107248:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010724c:	79 07                	jns    80107255 <sys_dup+0x43>
		return -1;
8010724e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107253:	eb 12                	jmp    80107267 <sys_dup+0x55>
	filedup(f);
80107255:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107258:	83 ec 0c             	sub    $0xc,%esp
8010725b:	50                   	push   %eax
8010725c:	e8 a3 9d ff ff       	call   80101004 <filedup>
80107261:	83 c4 10             	add    $0x10,%esp
	return fd;
80107264:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107267:	c9                   	leave  
80107268:	c3                   	ret    

80107269 <sys_read>:

int sys_read(void)
{
80107269:	55                   	push   %ebp
8010726a:	89 e5                	mov    %esp,%ebp
8010726c:	83 ec 18             	sub    $0x18,%esp
	struct file *f;
	int n;
	char *p;

	if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010726f:	83 ec 04             	sub    $0x4,%esp
80107272:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107275:	50                   	push   %eax
80107276:	6a 00                	push   $0x0
80107278:	6a 00                	push   $0x0
8010727a:	e8 d2 fe ff ff       	call   80107151 <argfd>
8010727f:	83 c4 10             	add    $0x10,%esp
80107282:	85 c0                	test   %eax,%eax
80107284:	78 2e                	js     801072b4 <sys_read+0x4b>
80107286:	83 ec 08             	sub    $0x8,%esp
80107289:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010728c:	50                   	push   %eax
8010728d:	6a 02                	push   $0x2
8010728f:	e8 81 fd ff ff       	call   80107015 <argint>
80107294:	83 c4 10             	add    $0x10,%esp
80107297:	85 c0                	test   %eax,%eax
80107299:	78 19                	js     801072b4 <sys_read+0x4b>
8010729b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010729e:	83 ec 04             	sub    $0x4,%esp
801072a1:	50                   	push   %eax
801072a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801072a5:	50                   	push   %eax
801072a6:	6a 01                	push   $0x1
801072a8:	e8 90 fd ff ff       	call   8010703d <argptr>
801072ad:	83 c4 10             	add    $0x10,%esp
801072b0:	85 c0                	test   %eax,%eax
801072b2:	79 07                	jns    801072bb <sys_read+0x52>
		return -1;
801072b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072b9:	eb 17                	jmp    801072d2 <sys_read+0x69>
	return fileread(f, p, n);
801072bb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801072be:	8b 55 ec             	mov    -0x14(%ebp),%edx
801072c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c4:	83 ec 04             	sub    $0x4,%esp
801072c7:	51                   	push   %ecx
801072c8:	52                   	push   %edx
801072c9:	50                   	push   %eax
801072ca:	e8 c5 9e ff ff       	call   80101194 <fileread>
801072cf:	83 c4 10             	add    $0x10,%esp
}
801072d2:	c9                   	leave  
801072d3:	c3                   	ret    

801072d4 <sys_write>:

int sys_write(void)
{
801072d4:	55                   	push   %ebp
801072d5:	89 e5                	mov    %esp,%ebp
801072d7:	83 ec 18             	sub    $0x18,%esp
	struct file *f;
	int n;
	char *p;

	if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801072da:	83 ec 04             	sub    $0x4,%esp
801072dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
801072e0:	50                   	push   %eax
801072e1:	6a 00                	push   $0x0
801072e3:	6a 00                	push   $0x0
801072e5:	e8 67 fe ff ff       	call   80107151 <argfd>
801072ea:	83 c4 10             	add    $0x10,%esp
801072ed:	85 c0                	test   %eax,%eax
801072ef:	78 2e                	js     8010731f <sys_write+0x4b>
801072f1:	83 ec 08             	sub    $0x8,%esp
801072f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801072f7:	50                   	push   %eax
801072f8:	6a 02                	push   $0x2
801072fa:	e8 16 fd ff ff       	call   80107015 <argint>
801072ff:	83 c4 10             	add    $0x10,%esp
80107302:	85 c0                	test   %eax,%eax
80107304:	78 19                	js     8010731f <sys_write+0x4b>
80107306:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107309:	83 ec 04             	sub    $0x4,%esp
8010730c:	50                   	push   %eax
8010730d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107310:	50                   	push   %eax
80107311:	6a 01                	push   $0x1
80107313:	e8 25 fd ff ff       	call   8010703d <argptr>
80107318:	83 c4 10             	add    $0x10,%esp
8010731b:	85 c0                	test   %eax,%eax
8010731d:	79 07                	jns    80107326 <sys_write+0x52>
		return -1;
8010731f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107324:	eb 17                	jmp    8010733d <sys_write+0x69>
	return filewrite(f, p, n);
80107326:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80107329:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010732c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010732f:	83 ec 04             	sub    $0x4,%esp
80107332:	51                   	push   %ecx
80107333:	52                   	push   %edx
80107334:	50                   	push   %eax
80107335:	e8 12 9f ff ff       	call   8010124c <filewrite>
8010733a:	83 c4 10             	add    $0x10,%esp
}
8010733d:	c9                   	leave  
8010733e:	c3                   	ret    

8010733f <sys_close>:

int sys_close(void)
{
8010733f:	55                   	push   %ebp
80107340:	89 e5                	mov    %esp,%ebp
80107342:	83 ec 18             	sub    $0x18,%esp
	int fd;
	struct file *f;

	if (argfd(0, &fd, &f) < 0)
80107345:	83 ec 04             	sub    $0x4,%esp
80107348:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010734b:	50                   	push   %eax
8010734c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010734f:	50                   	push   %eax
80107350:	6a 00                	push   $0x0
80107352:	e8 fa fd ff ff       	call   80107151 <argfd>
80107357:	83 c4 10             	add    $0x10,%esp
8010735a:	85 c0                	test   %eax,%eax
8010735c:	79 07                	jns    80107365 <sys_close+0x26>
		return -1;
8010735e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107363:	eb 28                	jmp    8010738d <sys_close+0x4e>
	proc->ofile[fd] = 0;
80107365:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010736b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010736e:	83 c2 08             	add    $0x8,%edx
80107371:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107378:	00 
	fileclose(f);
80107379:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010737c:	83 ec 0c             	sub    $0xc,%esp
8010737f:	50                   	push   %eax
80107380:	e8 d0 9c ff ff       	call   80101055 <fileclose>
80107385:	83 c4 10             	add    $0x10,%esp
	return 0;
80107388:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010738d:	c9                   	leave  
8010738e:	c3                   	ret    

8010738f <sys_fstat>:

int sys_fstat(void)
{
8010738f:	55                   	push   %ebp
80107390:	89 e5                	mov    %esp,%ebp
80107392:	83 ec 18             	sub    $0x18,%esp
	struct file *f;
	struct stat *st;

	if (argfd(0, 0, &f) < 0 || argptr(1, (void *)&st, sizeof(*st)) < 0)
80107395:	83 ec 04             	sub    $0x4,%esp
80107398:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010739b:	50                   	push   %eax
8010739c:	6a 00                	push   $0x0
8010739e:	6a 00                	push   $0x0
801073a0:	e8 ac fd ff ff       	call   80107151 <argfd>
801073a5:	83 c4 10             	add    $0x10,%esp
801073a8:	85 c0                	test   %eax,%eax
801073aa:	78 17                	js     801073c3 <sys_fstat+0x34>
801073ac:	83 ec 04             	sub    $0x4,%esp
801073af:	6a 14                	push   $0x14
801073b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801073b4:	50                   	push   %eax
801073b5:	6a 01                	push   $0x1
801073b7:	e8 81 fc ff ff       	call   8010703d <argptr>
801073bc:	83 c4 10             	add    $0x10,%esp
801073bf:	85 c0                	test   %eax,%eax
801073c1:	79 07                	jns    801073ca <sys_fstat+0x3b>
		return -1;
801073c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073c8:	eb 13                	jmp    801073dd <sys_fstat+0x4e>
	return filestat(f, st);
801073ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
801073cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d0:	83 ec 08             	sub    $0x8,%esp
801073d3:	52                   	push   %edx
801073d4:	50                   	push   %eax
801073d5:	e8 63 9d ff ff       	call   8010113d <filestat>
801073da:	83 c4 10             	add    $0x10,%esp
}
801073dd:	c9                   	leave  
801073de:	c3                   	ret    

801073df <sys_link>:

// Create the path new as a link to the same inode as old.
int sys_link(void)
{
801073df:	55                   	push   %ebp
801073e0:	89 e5                	mov    %esp,%ebp
801073e2:	83 ec 28             	sub    $0x28,%esp
	char name[DIRSIZ], *new, *old;
	struct inode *dp, *ip;

	if (argstr(0, &old) < 0 || argstr(1, &new) < 0)
801073e5:	83 ec 08             	sub    $0x8,%esp
801073e8:	8d 45 d8             	lea    -0x28(%ebp),%eax
801073eb:	50                   	push   %eax
801073ec:	6a 00                	push   $0x0
801073ee:	e8 a7 fc ff ff       	call   8010709a <argstr>
801073f3:	83 c4 10             	add    $0x10,%esp
801073f6:	85 c0                	test   %eax,%eax
801073f8:	78 15                	js     8010740f <sys_link+0x30>
801073fa:	83 ec 08             	sub    $0x8,%esp
801073fd:	8d 45 dc             	lea    -0x24(%ebp),%eax
80107400:	50                   	push   %eax
80107401:	6a 01                	push   $0x1
80107403:	e8 92 fc ff ff       	call   8010709a <argstr>
80107408:	83 c4 10             	add    $0x10,%esp
8010740b:	85 c0                	test   %eax,%eax
8010740d:	79 0a                	jns    80107419 <sys_link+0x3a>
		return -1;
8010740f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107414:	e9 68 01 00 00       	jmp    80107581 <sys_link+0x1a2>

	begin_op();
80107419:	e8 33 c1 ff ff       	call   80103551 <begin_op>
	if ((ip = namei(old)) == 0) {
8010741e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80107421:	83 ec 0c             	sub    $0xc,%esp
80107424:	50                   	push   %eax
80107425:	e8 02 b1 ff ff       	call   8010252c <namei>
8010742a:	83 c4 10             	add    $0x10,%esp
8010742d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107430:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107434:	75 0f                	jne    80107445 <sys_link+0x66>
		end_op();
80107436:	e8 a2 c1 ff ff       	call   801035dd <end_op>
		return -1;
8010743b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107440:	e9 3c 01 00 00       	jmp    80107581 <sys_link+0x1a2>
	}

	ilock(ip);
80107445:	83 ec 0c             	sub    $0xc,%esp
80107448:	ff 75 f4             	pushl  -0xc(%ebp)
8010744b:	e8 1e a5 ff ff       	call   8010196e <ilock>
80107450:	83 c4 10             	add    $0x10,%esp
	if (ip->type == T_DIR) {
80107453:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107456:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010745a:	66 83 f8 01          	cmp    $0x1,%ax
8010745e:	75 1d                	jne    8010747d <sys_link+0x9e>
		iunlockput(ip);
80107460:	83 ec 0c             	sub    $0xc,%esp
80107463:	ff 75 f4             	pushl  -0xc(%ebp)
80107466:	e8 c3 a7 ff ff       	call   80101c2e <iunlockput>
8010746b:	83 c4 10             	add    $0x10,%esp
		end_op();
8010746e:	e8 6a c1 ff ff       	call   801035dd <end_op>
		return -1;
80107473:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107478:	e9 04 01 00 00       	jmp    80107581 <sys_link+0x1a2>
	}

	ip->nlink++;
8010747d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107480:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107484:	83 c0 01             	add    $0x1,%eax
80107487:	89 c2                	mov    %eax,%edx
80107489:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748c:	66 89 50 16          	mov    %dx,0x16(%eax)
	iupdate(ip);
80107490:	83 ec 0c             	sub    $0xc,%esp
80107493:	ff 75 f4             	pushl  -0xc(%ebp)
80107496:	e8 f9 a2 ff ff       	call   80101794 <iupdate>
8010749b:	83 c4 10             	add    $0x10,%esp
	iunlock(ip);
8010749e:	83 ec 0c             	sub    $0xc,%esp
801074a1:	ff 75 f4             	pushl  -0xc(%ebp)
801074a4:	e8 23 a6 ff ff       	call   80101acc <iunlock>
801074a9:	83 c4 10             	add    $0x10,%esp

	if ((dp = nameiparent(new, name)) == 0)
801074ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
801074af:	83 ec 08             	sub    $0x8,%esp
801074b2:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801074b5:	52                   	push   %edx
801074b6:	50                   	push   %eax
801074b7:	e8 8c b0 ff ff       	call   80102548 <nameiparent>
801074bc:	83 c4 10             	add    $0x10,%esp
801074bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
801074c2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801074c6:	74 71                	je     80107539 <sys_link+0x15a>
		goto bad;
	ilock(dp);
801074c8:	83 ec 0c             	sub    $0xc,%esp
801074cb:	ff 75 f0             	pushl  -0x10(%ebp)
801074ce:	e8 9b a4 ff ff       	call   8010196e <ilock>
801074d3:	83 c4 10             	add    $0x10,%esp
	if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
801074d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801074d9:	8b 10                	mov    (%eax),%edx
801074db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074de:	8b 00                	mov    (%eax),%eax
801074e0:	39 c2                	cmp    %eax,%edx
801074e2:	75 1d                	jne    80107501 <sys_link+0x122>
801074e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e7:	8b 40 04             	mov    0x4(%eax),%eax
801074ea:	83 ec 04             	sub    $0x4,%esp
801074ed:	50                   	push   %eax
801074ee:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801074f1:	50                   	push   %eax
801074f2:	ff 75 f0             	pushl  -0x10(%ebp)
801074f5:	e8 96 ad ff ff       	call   80102290 <dirlink>
801074fa:	83 c4 10             	add    $0x10,%esp
801074fd:	85 c0                	test   %eax,%eax
801074ff:	79 10                	jns    80107511 <sys_link+0x132>
		iunlockput(dp);
80107501:	83 ec 0c             	sub    $0xc,%esp
80107504:	ff 75 f0             	pushl  -0x10(%ebp)
80107507:	e8 22 a7 ff ff       	call   80101c2e <iunlockput>
8010750c:	83 c4 10             	add    $0x10,%esp
		goto bad;
8010750f:	eb 29                	jmp    8010753a <sys_link+0x15b>
	}
	iunlockput(dp);
80107511:	83 ec 0c             	sub    $0xc,%esp
80107514:	ff 75 f0             	pushl  -0x10(%ebp)
80107517:	e8 12 a7 ff ff       	call   80101c2e <iunlockput>
8010751c:	83 c4 10             	add    $0x10,%esp
	iput(ip);
8010751f:	83 ec 0c             	sub    $0xc,%esp
80107522:	ff 75 f4             	pushl  -0xc(%ebp)
80107525:	e8 14 a6 ff ff       	call   80101b3e <iput>
8010752a:	83 c4 10             	add    $0x10,%esp

	end_op();
8010752d:	e8 ab c0 ff ff       	call   801035dd <end_op>

	return 0;
80107532:	b8 00 00 00 00       	mov    $0x0,%eax
80107537:	eb 48                	jmp    80107581 <sys_link+0x1a2>
	ip->nlink++;
	iupdate(ip);
	iunlock(ip);

	if ((dp = nameiparent(new, name)) == 0)
		goto bad;
80107539:	90                   	nop
	end_op();

	return 0;

 bad:
	ilock(ip);
8010753a:	83 ec 0c             	sub    $0xc,%esp
8010753d:	ff 75 f4             	pushl  -0xc(%ebp)
80107540:	e8 29 a4 ff ff       	call   8010196e <ilock>
80107545:	83 c4 10             	add    $0x10,%esp
	ip->nlink--;
80107548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010754b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010754f:	83 e8 01             	sub    $0x1,%eax
80107552:	89 c2                	mov    %eax,%edx
80107554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107557:	66 89 50 16          	mov    %dx,0x16(%eax)
	iupdate(ip);
8010755b:	83 ec 0c             	sub    $0xc,%esp
8010755e:	ff 75 f4             	pushl  -0xc(%ebp)
80107561:	e8 2e a2 ff ff       	call   80101794 <iupdate>
80107566:	83 c4 10             	add    $0x10,%esp
	iunlockput(ip);
80107569:	83 ec 0c             	sub    $0xc,%esp
8010756c:	ff 75 f4             	pushl  -0xc(%ebp)
8010756f:	e8 ba a6 ff ff       	call   80101c2e <iunlockput>
80107574:	83 c4 10             	add    $0x10,%esp
	end_op();
80107577:	e8 61 c0 ff ff       	call   801035dd <end_op>
	return -1;
8010757c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107581:	c9                   	leave  
80107582:	c3                   	ret    

80107583 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int isdirempty(struct inode *dp)
{
80107583:	55                   	push   %ebp
80107584:	89 e5                	mov    %esp,%ebp
80107586:	83 ec 28             	sub    $0x28,%esp
	int off;
	struct dirent de;

	for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
80107589:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80107590:	eb 40                	jmp    801075d2 <isdirempty+0x4f>
		if (readi(dp, (char *)&de, off, sizeof(de)) != sizeof(de))
80107592:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107595:	6a 10                	push   $0x10
80107597:	50                   	push   %eax
80107598:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010759b:	50                   	push   %eax
8010759c:	ff 75 08             	pushl  0x8(%ebp)
8010759f:	e8 38 a9 ff ff       	call   80101edc <readi>
801075a4:	83 c4 10             	add    $0x10,%esp
801075a7:	83 f8 10             	cmp    $0x10,%eax
801075aa:	74 0d                	je     801075b9 <isdirempty+0x36>
			panic("isdirempty: readi");
801075ac:	83 ec 0c             	sub    $0xc,%esp
801075af:	68 b3 ac 10 80       	push   $0x8010acb3
801075b4:	e8 ad 8f ff ff       	call   80100566 <panic>
		if (de.inum != 0)
801075b9:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801075bd:	66 85 c0             	test   %ax,%ax
801075c0:	74 07                	je     801075c9 <isdirempty+0x46>
			return 0;
801075c2:	b8 00 00 00 00       	mov    $0x0,%eax
801075c7:	eb 1b                	jmp    801075e4 <isdirempty+0x61>
static int isdirempty(struct inode *dp)
{
	int off;
	struct dirent de;

	for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
801075c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075cc:	83 c0 10             	add    $0x10,%eax
801075cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801075d2:	8b 45 08             	mov    0x8(%ebp),%eax
801075d5:	8b 50 18             	mov    0x18(%eax),%edx
801075d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075db:	39 c2                	cmp    %eax,%edx
801075dd:	77 b3                	ja     80107592 <isdirempty+0xf>
		if (readi(dp, (char *)&de, off, sizeof(de)) != sizeof(de))
			panic("isdirempty: readi");
		if (de.inum != 0)
			return 0;
	}
	return 1;
801075df:	b8 01 00 00 00       	mov    $0x1,%eax
}
801075e4:	c9                   	leave  
801075e5:	c3                   	ret    

801075e6 <sys_unlink>:

//PAGEBREAK!
int sys_unlink(void)
{
801075e6:	55                   	push   %ebp
801075e7:	89 e5                	mov    %esp,%ebp
801075e9:	83 ec 38             	sub    $0x38,%esp
	struct inode *ip, *dp;
	struct dirent de;
	char name[DIRSIZ], *path;
	uint off;

	if (argstr(0, &path) < 0)
801075ec:	83 ec 08             	sub    $0x8,%esp
801075ef:	8d 45 cc             	lea    -0x34(%ebp),%eax
801075f2:	50                   	push   %eax
801075f3:	6a 00                	push   $0x0
801075f5:	e8 a0 fa ff ff       	call   8010709a <argstr>
801075fa:	83 c4 10             	add    $0x10,%esp
801075fd:	85 c0                	test   %eax,%eax
801075ff:	79 0a                	jns    8010760b <sys_unlink+0x25>
		return -1;
80107601:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107606:	e9 bc 01 00 00       	jmp    801077c7 <sys_unlink+0x1e1>

	begin_op();
8010760b:	e8 41 bf ff ff       	call   80103551 <begin_op>
	if ((dp = nameiparent(path, name)) == 0) {
80107610:	8b 45 cc             	mov    -0x34(%ebp),%eax
80107613:	83 ec 08             	sub    $0x8,%esp
80107616:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80107619:	52                   	push   %edx
8010761a:	50                   	push   %eax
8010761b:	e8 28 af ff ff       	call   80102548 <nameiparent>
80107620:	83 c4 10             	add    $0x10,%esp
80107623:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107626:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010762a:	75 0f                	jne    8010763b <sys_unlink+0x55>
		end_op();
8010762c:	e8 ac bf ff ff       	call   801035dd <end_op>
		return -1;
80107631:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107636:	e9 8c 01 00 00       	jmp    801077c7 <sys_unlink+0x1e1>
	}

	ilock(dp);
8010763b:	83 ec 0c             	sub    $0xc,%esp
8010763e:	ff 75 f4             	pushl  -0xc(%ebp)
80107641:	e8 28 a3 ff ff       	call   8010196e <ilock>
80107646:	83 c4 10             	add    $0x10,%esp

	// Cannot unlink "." or "..".
	if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80107649:	83 ec 08             	sub    $0x8,%esp
8010764c:	68 c5 ac 10 80       	push   $0x8010acc5
80107651:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80107654:	50                   	push   %eax
80107655:	e8 61 ab ff ff       	call   801021bb <namecmp>
8010765a:	83 c4 10             	add    $0x10,%esp
8010765d:	85 c0                	test   %eax,%eax
8010765f:	0f 84 4a 01 00 00    	je     801077af <sys_unlink+0x1c9>
80107665:	83 ec 08             	sub    $0x8,%esp
80107668:	68 c7 ac 10 80       	push   $0x8010acc7
8010766d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80107670:	50                   	push   %eax
80107671:	e8 45 ab ff ff       	call   801021bb <namecmp>
80107676:	83 c4 10             	add    $0x10,%esp
80107679:	85 c0                	test   %eax,%eax
8010767b:	0f 84 2e 01 00 00    	je     801077af <sys_unlink+0x1c9>
		goto bad;

	if ((ip = dirlookup(dp, name, &off)) == 0)
80107681:	83 ec 04             	sub    $0x4,%esp
80107684:	8d 45 c8             	lea    -0x38(%ebp),%eax
80107687:	50                   	push   %eax
80107688:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010768b:	50                   	push   %eax
8010768c:	ff 75 f4             	pushl  -0xc(%ebp)
8010768f:	e8 42 ab ff ff       	call   801021d6 <dirlookup>
80107694:	83 c4 10             	add    $0x10,%esp
80107697:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010769a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010769e:	0f 84 0a 01 00 00    	je     801077ae <sys_unlink+0x1c8>
		goto bad;
	ilock(ip);
801076a4:	83 ec 0c             	sub    $0xc,%esp
801076a7:	ff 75 f0             	pushl  -0x10(%ebp)
801076aa:	e8 bf a2 ff ff       	call   8010196e <ilock>
801076af:	83 c4 10             	add    $0x10,%esp

	if (ip->nlink < 1)
801076b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076b5:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801076b9:	66 85 c0             	test   %ax,%ax
801076bc:	7f 0d                	jg     801076cb <sys_unlink+0xe5>
		panic("unlink: nlink < 1");
801076be:	83 ec 0c             	sub    $0xc,%esp
801076c1:	68 ca ac 10 80       	push   $0x8010acca
801076c6:	e8 9b 8e ff ff       	call   80100566 <panic>
	if (ip->type == T_DIR && !isdirempty(ip)) {
801076cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076ce:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801076d2:	66 83 f8 01          	cmp    $0x1,%ax
801076d6:	75 25                	jne    801076fd <sys_unlink+0x117>
801076d8:	83 ec 0c             	sub    $0xc,%esp
801076db:	ff 75 f0             	pushl  -0x10(%ebp)
801076de:	e8 a0 fe ff ff       	call   80107583 <isdirempty>
801076e3:	83 c4 10             	add    $0x10,%esp
801076e6:	85 c0                	test   %eax,%eax
801076e8:	75 13                	jne    801076fd <sys_unlink+0x117>
		iunlockput(ip);
801076ea:	83 ec 0c             	sub    $0xc,%esp
801076ed:	ff 75 f0             	pushl  -0x10(%ebp)
801076f0:	e8 39 a5 ff ff       	call   80101c2e <iunlockput>
801076f5:	83 c4 10             	add    $0x10,%esp
		goto bad;
801076f8:	e9 b2 00 00 00       	jmp    801077af <sys_unlink+0x1c9>
	}

	memset(&de, 0, sizeof(de));
801076fd:	83 ec 04             	sub    $0x4,%esp
80107700:	6a 10                	push   $0x10
80107702:	6a 00                	push   $0x0
80107704:	8d 45 e0             	lea    -0x20(%ebp),%eax
80107707:	50                   	push   %eax
80107708:	e8 e3 f5 ff ff       	call   80106cf0 <memset>
8010770d:	83 c4 10             	add    $0x10,%esp
	if (writei(dp, (char *)&de, off, sizeof(de)) != sizeof(de))
80107710:	8b 45 c8             	mov    -0x38(%ebp),%eax
80107713:	6a 10                	push   $0x10
80107715:	50                   	push   %eax
80107716:	8d 45 e0             	lea    -0x20(%ebp),%eax
80107719:	50                   	push   %eax
8010771a:	ff 75 f4             	pushl  -0xc(%ebp)
8010771d:	e8 11 a9 ff ff       	call   80102033 <writei>
80107722:	83 c4 10             	add    $0x10,%esp
80107725:	83 f8 10             	cmp    $0x10,%eax
80107728:	74 0d                	je     80107737 <sys_unlink+0x151>
		panic("unlink: writei");
8010772a:	83 ec 0c             	sub    $0xc,%esp
8010772d:	68 dc ac 10 80       	push   $0x8010acdc
80107732:	e8 2f 8e ff ff       	call   80100566 <panic>
	if (ip->type == T_DIR) {
80107737:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010773a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010773e:	66 83 f8 01          	cmp    $0x1,%ax
80107742:	75 21                	jne    80107765 <sys_unlink+0x17f>
		dp->nlink--;
80107744:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107747:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010774b:	83 e8 01             	sub    $0x1,%eax
8010774e:	89 c2                	mov    %eax,%edx
80107750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107753:	66 89 50 16          	mov    %dx,0x16(%eax)
		iupdate(dp);
80107757:	83 ec 0c             	sub    $0xc,%esp
8010775a:	ff 75 f4             	pushl  -0xc(%ebp)
8010775d:	e8 32 a0 ff ff       	call   80101794 <iupdate>
80107762:	83 c4 10             	add    $0x10,%esp
	}
	iunlockput(dp);
80107765:	83 ec 0c             	sub    $0xc,%esp
80107768:	ff 75 f4             	pushl  -0xc(%ebp)
8010776b:	e8 be a4 ff ff       	call   80101c2e <iunlockput>
80107770:	83 c4 10             	add    $0x10,%esp

	ip->nlink--;
80107773:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107776:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010777a:	83 e8 01             	sub    $0x1,%eax
8010777d:	89 c2                	mov    %eax,%edx
8010777f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107782:	66 89 50 16          	mov    %dx,0x16(%eax)
	iupdate(ip);
80107786:	83 ec 0c             	sub    $0xc,%esp
80107789:	ff 75 f0             	pushl  -0x10(%ebp)
8010778c:	e8 03 a0 ff ff       	call   80101794 <iupdate>
80107791:	83 c4 10             	add    $0x10,%esp
	iunlockput(ip);
80107794:	83 ec 0c             	sub    $0xc,%esp
80107797:	ff 75 f0             	pushl  -0x10(%ebp)
8010779a:	e8 8f a4 ff ff       	call   80101c2e <iunlockput>
8010779f:	83 c4 10             	add    $0x10,%esp

	end_op();
801077a2:	e8 36 be ff ff       	call   801035dd <end_op>

	return 0;
801077a7:	b8 00 00 00 00       	mov    $0x0,%eax
801077ac:	eb 19                	jmp    801077c7 <sys_unlink+0x1e1>
	// Cannot unlink "." or "..".
	if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
		goto bad;

	if ((ip = dirlookup(dp, name, &off)) == 0)
		goto bad;
801077ae:	90                   	nop
	end_op();

	return 0;

 bad:
	iunlockput(dp);
801077af:	83 ec 0c             	sub    $0xc,%esp
801077b2:	ff 75 f4             	pushl  -0xc(%ebp)
801077b5:	e8 74 a4 ff ff       	call   80101c2e <iunlockput>
801077ba:	83 c4 10             	add    $0x10,%esp
	end_op();
801077bd:	e8 1b be ff ff       	call   801035dd <end_op>
	return -1;
801077c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801077c7:	c9                   	leave  
801077c8:	c3                   	ret    

801077c9 <create>:

static struct inode *create(char *path, short type, short major, short minor)
{
801077c9:	55                   	push   %ebp
801077ca:	89 e5                	mov    %esp,%ebp
801077cc:	83 ec 38             	sub    $0x38,%esp
801077cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801077d2:	8b 55 10             	mov    0x10(%ebp),%edx
801077d5:	8b 45 14             	mov    0x14(%ebp),%eax
801077d8:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801077dc:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801077e0:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
	uint off;
	struct inode *ip, *dp;
	char name[DIRSIZ];

	if ((dp = nameiparent(path, name)) == 0)
801077e4:	83 ec 08             	sub    $0x8,%esp
801077e7:	8d 45 de             	lea    -0x22(%ebp),%eax
801077ea:	50                   	push   %eax
801077eb:	ff 75 08             	pushl  0x8(%ebp)
801077ee:	e8 55 ad ff ff       	call   80102548 <nameiparent>
801077f3:	83 c4 10             	add    $0x10,%esp
801077f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801077f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801077fd:	75 0a                	jne    80107809 <create+0x40>
		return 0;
801077ff:	b8 00 00 00 00       	mov    $0x0,%eax
80107804:	e9 90 01 00 00       	jmp    80107999 <create+0x1d0>
	ilock(dp);
80107809:	83 ec 0c             	sub    $0xc,%esp
8010780c:	ff 75 f4             	pushl  -0xc(%ebp)
8010780f:	e8 5a a1 ff ff       	call   8010196e <ilock>
80107814:	83 c4 10             	add    $0x10,%esp

	if ((ip = dirlookup(dp, name, &off)) != 0) {
80107817:	83 ec 04             	sub    $0x4,%esp
8010781a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010781d:	50                   	push   %eax
8010781e:	8d 45 de             	lea    -0x22(%ebp),%eax
80107821:	50                   	push   %eax
80107822:	ff 75 f4             	pushl  -0xc(%ebp)
80107825:	e8 ac a9 ff ff       	call   801021d6 <dirlookup>
8010782a:	83 c4 10             	add    $0x10,%esp
8010782d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107830:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107834:	74 50                	je     80107886 <create+0xbd>
		iunlockput(dp);
80107836:	83 ec 0c             	sub    $0xc,%esp
80107839:	ff 75 f4             	pushl  -0xc(%ebp)
8010783c:	e8 ed a3 ff ff       	call   80101c2e <iunlockput>
80107841:	83 c4 10             	add    $0x10,%esp
		ilock(ip);
80107844:	83 ec 0c             	sub    $0xc,%esp
80107847:	ff 75 f0             	pushl  -0x10(%ebp)
8010784a:	e8 1f a1 ff ff       	call   8010196e <ilock>
8010784f:	83 c4 10             	add    $0x10,%esp
		if (type == T_FILE && ip->type == T_FILE)
80107852:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80107857:	75 15                	jne    8010786e <create+0xa5>
80107859:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010785c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107860:	66 83 f8 02          	cmp    $0x2,%ax
80107864:	75 08                	jne    8010786e <create+0xa5>
			return ip;
80107866:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107869:	e9 2b 01 00 00       	jmp    80107999 <create+0x1d0>
		iunlockput(ip);
8010786e:	83 ec 0c             	sub    $0xc,%esp
80107871:	ff 75 f0             	pushl  -0x10(%ebp)
80107874:	e8 b5 a3 ff ff       	call   80101c2e <iunlockput>
80107879:	83 c4 10             	add    $0x10,%esp
		return 0;
8010787c:	b8 00 00 00 00       	mov    $0x0,%eax
80107881:	e9 13 01 00 00       	jmp    80107999 <create+0x1d0>
	}

	if ((ip = ialloc(dp->dev, type)) == 0)
80107886:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010788a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788d:	8b 00                	mov    (%eax),%eax
8010788f:	83 ec 08             	sub    $0x8,%esp
80107892:	52                   	push   %edx
80107893:	50                   	push   %eax
80107894:	e8 24 9e ff ff       	call   801016bd <ialloc>
80107899:	83 c4 10             	add    $0x10,%esp
8010789c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010789f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801078a3:	75 0d                	jne    801078b2 <create+0xe9>
		panic("create: ialloc");
801078a5:	83 ec 0c             	sub    $0xc,%esp
801078a8:	68 eb ac 10 80       	push   $0x8010aceb
801078ad:	e8 b4 8c ff ff       	call   80100566 <panic>

	ilock(ip);
801078b2:	83 ec 0c             	sub    $0xc,%esp
801078b5:	ff 75 f0             	pushl  -0x10(%ebp)
801078b8:	e8 b1 a0 ff ff       	call   8010196e <ilock>
801078bd:	83 c4 10             	add    $0x10,%esp
	ip->major = major;
801078c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078c3:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801078c7:	66 89 50 12          	mov    %dx,0x12(%eax)
	ip->minor = minor;
801078cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078ce:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801078d2:	66 89 50 14          	mov    %dx,0x14(%eax)
	ip->nlink = 1;
801078d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078d9:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
	iupdate(ip);
801078df:	83 ec 0c             	sub    $0xc,%esp
801078e2:	ff 75 f0             	pushl  -0x10(%ebp)
801078e5:	e8 aa 9e ff ff       	call   80101794 <iupdate>
801078ea:	83 c4 10             	add    $0x10,%esp

	if (type == T_DIR) {	// Create . and .. entries.
801078ed:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801078f2:	75 6a                	jne    8010795e <create+0x195>
		dp->nlink++;	// for ".."
801078f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801078fb:	83 c0 01             	add    $0x1,%eax
801078fe:	89 c2                	mov    %eax,%edx
80107900:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107903:	66 89 50 16          	mov    %dx,0x16(%eax)
		iupdate(dp);
80107907:	83 ec 0c             	sub    $0xc,%esp
8010790a:	ff 75 f4             	pushl  -0xc(%ebp)
8010790d:	e8 82 9e ff ff       	call   80101794 <iupdate>
80107912:	83 c4 10             	add    $0x10,%esp
		// No ip->nlink++ for ".": avoid cyclic ref count.
		if (dirlink(ip, ".", ip->inum) < 0
80107915:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107918:	8b 40 04             	mov    0x4(%eax),%eax
8010791b:	83 ec 04             	sub    $0x4,%esp
8010791e:	50                   	push   %eax
8010791f:	68 c5 ac 10 80       	push   $0x8010acc5
80107924:	ff 75 f0             	pushl  -0x10(%ebp)
80107927:	e8 64 a9 ff ff       	call   80102290 <dirlink>
8010792c:	83 c4 10             	add    $0x10,%esp
8010792f:	85 c0                	test   %eax,%eax
80107931:	78 1e                	js     80107951 <create+0x188>
		    || dirlink(ip, "..", dp->inum) < 0)
80107933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107936:	8b 40 04             	mov    0x4(%eax),%eax
80107939:	83 ec 04             	sub    $0x4,%esp
8010793c:	50                   	push   %eax
8010793d:	68 c7 ac 10 80       	push   $0x8010acc7
80107942:	ff 75 f0             	pushl  -0x10(%ebp)
80107945:	e8 46 a9 ff ff       	call   80102290 <dirlink>
8010794a:	83 c4 10             	add    $0x10,%esp
8010794d:	85 c0                	test   %eax,%eax
8010794f:	79 0d                	jns    8010795e <create+0x195>
			panic("create dots");
80107951:	83 ec 0c             	sub    $0xc,%esp
80107954:	68 fa ac 10 80       	push   $0x8010acfa
80107959:	e8 08 8c ff ff       	call   80100566 <panic>
	}

	if (dirlink(dp, name, ip->inum) < 0)
8010795e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107961:	8b 40 04             	mov    0x4(%eax),%eax
80107964:	83 ec 04             	sub    $0x4,%esp
80107967:	50                   	push   %eax
80107968:	8d 45 de             	lea    -0x22(%ebp),%eax
8010796b:	50                   	push   %eax
8010796c:	ff 75 f4             	pushl  -0xc(%ebp)
8010796f:	e8 1c a9 ff ff       	call   80102290 <dirlink>
80107974:	83 c4 10             	add    $0x10,%esp
80107977:	85 c0                	test   %eax,%eax
80107979:	79 0d                	jns    80107988 <create+0x1bf>
		panic("create: dirlink");
8010797b:	83 ec 0c             	sub    $0xc,%esp
8010797e:	68 06 ad 10 80       	push   $0x8010ad06
80107983:	e8 de 8b ff ff       	call   80100566 <panic>

	iunlockput(dp);
80107988:	83 ec 0c             	sub    $0xc,%esp
8010798b:	ff 75 f4             	pushl  -0xc(%ebp)
8010798e:	e8 9b a2 ff ff       	call   80101c2e <iunlockput>
80107993:	83 c4 10             	add    $0x10,%esp

	return ip;
80107996:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107999:	c9                   	leave  
8010799a:	c3                   	ret    

8010799b <sys_open>:

int sys_open(void)
{
8010799b:	55                   	push   %ebp
8010799c:	89 e5                	mov    %esp,%ebp
8010799e:	83 ec 28             	sub    $0x28,%esp
	char *path;
	int fd, omode;
	struct file *f;
	struct inode *ip;

	if (argstr(0, &path) < 0 || argint(1, &omode) < 0)
801079a1:	83 ec 08             	sub    $0x8,%esp
801079a4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801079a7:	50                   	push   %eax
801079a8:	6a 00                	push   $0x0
801079aa:	e8 eb f6 ff ff       	call   8010709a <argstr>
801079af:	83 c4 10             	add    $0x10,%esp
801079b2:	85 c0                	test   %eax,%eax
801079b4:	78 15                	js     801079cb <sys_open+0x30>
801079b6:	83 ec 08             	sub    $0x8,%esp
801079b9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801079bc:	50                   	push   %eax
801079bd:	6a 01                	push   $0x1
801079bf:	e8 51 f6 ff ff       	call   80107015 <argint>
801079c4:	83 c4 10             	add    $0x10,%esp
801079c7:	85 c0                	test   %eax,%eax
801079c9:	79 0a                	jns    801079d5 <sys_open+0x3a>
		return -1;
801079cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079d0:	e9 61 01 00 00       	jmp    80107b36 <sys_open+0x19b>

	begin_op();
801079d5:	e8 77 bb ff ff       	call   80103551 <begin_op>

	if (omode & O_CREATE) {
801079da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801079dd:	25 00 02 00 00       	and    $0x200,%eax
801079e2:	85 c0                	test   %eax,%eax
801079e4:	74 2a                	je     80107a10 <sys_open+0x75>
		ip = create(path, T_FILE, 0, 0);
801079e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801079e9:	6a 00                	push   $0x0
801079eb:	6a 00                	push   $0x0
801079ed:	6a 02                	push   $0x2
801079ef:	50                   	push   %eax
801079f0:	e8 d4 fd ff ff       	call   801077c9 <create>
801079f5:	83 c4 10             	add    $0x10,%esp
801079f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if (ip == 0) {
801079fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801079ff:	75 75                	jne    80107a76 <sys_open+0xdb>
			end_op();
80107a01:	e8 d7 bb ff ff       	call   801035dd <end_op>
			return -1;
80107a06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a0b:	e9 26 01 00 00       	jmp    80107b36 <sys_open+0x19b>
		}
	} else {
		if ((ip = namei(path)) == 0) {
80107a10:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107a13:	83 ec 0c             	sub    $0xc,%esp
80107a16:	50                   	push   %eax
80107a17:	e8 10 ab ff ff       	call   8010252c <namei>
80107a1c:	83 c4 10             	add    $0x10,%esp
80107a1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107a22:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107a26:	75 0f                	jne    80107a37 <sys_open+0x9c>
			end_op();
80107a28:	e8 b0 bb ff ff       	call   801035dd <end_op>
			return -1;
80107a2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a32:	e9 ff 00 00 00       	jmp    80107b36 <sys_open+0x19b>
		}
		ilock(ip);
80107a37:	83 ec 0c             	sub    $0xc,%esp
80107a3a:	ff 75 f4             	pushl  -0xc(%ebp)
80107a3d:	e8 2c 9f ff ff       	call   8010196e <ilock>
80107a42:	83 c4 10             	add    $0x10,%esp
		if (ip->type == T_DIR && omode != O_RDONLY) {
80107a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a48:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107a4c:	66 83 f8 01          	cmp    $0x1,%ax
80107a50:	75 24                	jne    80107a76 <sys_open+0xdb>
80107a52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107a55:	85 c0                	test   %eax,%eax
80107a57:	74 1d                	je     80107a76 <sys_open+0xdb>
			iunlockput(ip);
80107a59:	83 ec 0c             	sub    $0xc,%esp
80107a5c:	ff 75 f4             	pushl  -0xc(%ebp)
80107a5f:	e8 ca a1 ff ff       	call   80101c2e <iunlockput>
80107a64:	83 c4 10             	add    $0x10,%esp
			end_op();
80107a67:	e8 71 bb ff ff       	call   801035dd <end_op>
			return -1;
80107a6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a71:	e9 c0 00 00 00       	jmp    80107b36 <sys_open+0x19b>
		}
	}

	if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
80107a76:	e8 1c 95 ff ff       	call   80100f97 <filealloc>
80107a7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107a7e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a82:	74 17                	je     80107a9b <sys_open+0x100>
80107a84:	83 ec 0c             	sub    $0xc,%esp
80107a87:	ff 75 f0             	pushl  -0x10(%ebp)
80107a8a:	e8 37 f7 ff ff       	call   801071c6 <fdalloc>
80107a8f:	83 c4 10             	add    $0x10,%esp
80107a92:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107a95:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107a99:	79 2e                	jns    80107ac9 <sys_open+0x12e>
		if (f)
80107a9b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a9f:	74 0e                	je     80107aaf <sys_open+0x114>
			fileclose(f);
80107aa1:	83 ec 0c             	sub    $0xc,%esp
80107aa4:	ff 75 f0             	pushl  -0x10(%ebp)
80107aa7:	e8 a9 95 ff ff       	call   80101055 <fileclose>
80107aac:	83 c4 10             	add    $0x10,%esp
		iunlockput(ip);
80107aaf:	83 ec 0c             	sub    $0xc,%esp
80107ab2:	ff 75 f4             	pushl  -0xc(%ebp)
80107ab5:	e8 74 a1 ff ff       	call   80101c2e <iunlockput>
80107aba:	83 c4 10             	add    $0x10,%esp
		end_op();
80107abd:	e8 1b bb ff ff       	call   801035dd <end_op>
		return -1;
80107ac2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ac7:	eb 6d                	jmp    80107b36 <sys_open+0x19b>
	}
	iunlock(ip);
80107ac9:	83 ec 0c             	sub    $0xc,%esp
80107acc:	ff 75 f4             	pushl  -0xc(%ebp)
80107acf:	e8 f8 9f ff ff       	call   80101acc <iunlock>
80107ad4:	83 c4 10             	add    $0x10,%esp
	end_op();
80107ad7:	e8 01 bb ff ff       	call   801035dd <end_op>

	f->type = FD_INODE;
80107adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107adf:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
	f->ip = ip;
80107ae5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ae8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107aeb:	89 50 10             	mov    %edx,0x10(%eax)
	f->off = 0;
80107aee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107af1:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
	f->readable = !(omode & O_WRONLY);
80107af8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107afb:	83 e0 01             	and    $0x1,%eax
80107afe:	85 c0                	test   %eax,%eax
80107b00:	0f 94 c0             	sete   %al
80107b03:	89 c2                	mov    %eax,%edx
80107b05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b08:	88 50 08             	mov    %dl,0x8(%eax)
	f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80107b0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107b0e:	83 e0 01             	and    $0x1,%eax
80107b11:	85 c0                	test   %eax,%eax
80107b13:	75 0a                	jne    80107b1f <sys_open+0x184>
80107b15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107b18:	83 e0 02             	and    $0x2,%eax
80107b1b:	85 c0                	test   %eax,%eax
80107b1d:	74 07                	je     80107b26 <sys_open+0x18b>
80107b1f:	b8 01 00 00 00       	mov    $0x1,%eax
80107b24:	eb 05                	jmp    80107b2b <sys_open+0x190>
80107b26:	b8 00 00 00 00       	mov    $0x0,%eax
80107b2b:	89 c2                	mov    %eax,%edx
80107b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b30:	88 50 09             	mov    %dl,0x9(%eax)
	return fd;
80107b33:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80107b36:	c9                   	leave  
80107b37:	c3                   	ret    

80107b38 <sys_mkdir>:

int sys_mkdir(void)
{
80107b38:	55                   	push   %ebp
80107b39:	89 e5                	mov    %esp,%ebp
80107b3b:	83 ec 18             	sub    $0x18,%esp
	char *path;
	struct inode *ip;

	begin_op();
80107b3e:	e8 0e ba ff ff       	call   80103551 <begin_op>
	if (argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
80107b43:	83 ec 08             	sub    $0x8,%esp
80107b46:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107b49:	50                   	push   %eax
80107b4a:	6a 00                	push   $0x0
80107b4c:	e8 49 f5 ff ff       	call   8010709a <argstr>
80107b51:	83 c4 10             	add    $0x10,%esp
80107b54:	85 c0                	test   %eax,%eax
80107b56:	78 1b                	js     80107b73 <sys_mkdir+0x3b>
80107b58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b5b:	6a 00                	push   $0x0
80107b5d:	6a 00                	push   $0x0
80107b5f:	6a 01                	push   $0x1
80107b61:	50                   	push   %eax
80107b62:	e8 62 fc ff ff       	call   801077c9 <create>
80107b67:	83 c4 10             	add    $0x10,%esp
80107b6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107b71:	75 0c                	jne    80107b7f <sys_mkdir+0x47>
		end_op();
80107b73:	e8 65 ba ff ff       	call   801035dd <end_op>
		return -1;
80107b78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b7d:	eb 18                	jmp    80107b97 <sys_mkdir+0x5f>
	}
	iunlockput(ip);
80107b7f:	83 ec 0c             	sub    $0xc,%esp
80107b82:	ff 75 f4             	pushl  -0xc(%ebp)
80107b85:	e8 a4 a0 ff ff       	call   80101c2e <iunlockput>
80107b8a:	83 c4 10             	add    $0x10,%esp
	end_op();
80107b8d:	e8 4b ba ff ff       	call   801035dd <end_op>
	return 0;
80107b92:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107b97:	c9                   	leave  
80107b98:	c3                   	ret    

80107b99 <sys_mknod>:

int sys_mknod(void)
{
80107b99:	55                   	push   %ebp
80107b9a:	89 e5                	mov    %esp,%ebp
80107b9c:	83 ec 28             	sub    $0x28,%esp
	struct inode *ip;
	char *path;
	int len;
	int major, minor;

	begin_op();
80107b9f:	e8 ad b9 ff ff       	call   80103551 <begin_op>
	if ((len = argstr(0, &path)) < 0 ||
80107ba4:	83 ec 08             	sub    $0x8,%esp
80107ba7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107baa:	50                   	push   %eax
80107bab:	6a 00                	push   $0x0
80107bad:	e8 e8 f4 ff ff       	call   8010709a <argstr>
80107bb2:	83 c4 10             	add    $0x10,%esp
80107bb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107bb8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107bbc:	78 4f                	js     80107c0d <sys_mknod+0x74>
	    argint(1, &major) < 0 ||
80107bbe:	83 ec 08             	sub    $0x8,%esp
80107bc1:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107bc4:	50                   	push   %eax
80107bc5:	6a 01                	push   $0x1
80107bc7:	e8 49 f4 ff ff       	call   80107015 <argint>
80107bcc:	83 c4 10             	add    $0x10,%esp
	char *path;
	int len;
	int major, minor;

	begin_op();
	if ((len = argstr(0, &path)) < 0 ||
80107bcf:	85 c0                	test   %eax,%eax
80107bd1:	78 3a                	js     80107c0d <sys_mknod+0x74>
	    argint(1, &major) < 0 ||
	    argint(2, &minor) < 0 ||
80107bd3:	83 ec 08             	sub    $0x8,%esp
80107bd6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107bd9:	50                   	push   %eax
80107bda:	6a 02                	push   $0x2
80107bdc:	e8 34 f4 ff ff       	call   80107015 <argint>
80107be1:	83 c4 10             	add    $0x10,%esp
	int len;
	int major, minor;

	begin_op();
	if ((len = argstr(0, &path)) < 0 ||
	    argint(1, &major) < 0 ||
80107be4:	85 c0                	test   %eax,%eax
80107be6:	78 25                	js     80107c0d <sys_mknod+0x74>
	    argint(2, &minor) < 0 ||
	    (ip = create(path, T_DEV, major, minor)) == 0) {
80107be8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107beb:	0f bf c8             	movswl %ax,%ecx
80107bee:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107bf1:	0f bf d0             	movswl %ax,%edx
80107bf4:	8b 45 ec             	mov    -0x14(%ebp),%eax
	int major, minor;

	begin_op();
	if ((len = argstr(0, &path)) < 0 ||
	    argint(1, &major) < 0 ||
	    argint(2, &minor) < 0 ||
80107bf7:	51                   	push   %ecx
80107bf8:	52                   	push   %edx
80107bf9:	6a 03                	push   $0x3
80107bfb:	50                   	push   %eax
80107bfc:	e8 c8 fb ff ff       	call   801077c9 <create>
80107c01:	83 c4 10             	add    $0x10,%esp
80107c04:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c07:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c0b:	75 0c                	jne    80107c19 <sys_mknod+0x80>
	    (ip = create(path, T_DEV, major, minor)) == 0) {
		end_op();
80107c0d:	e8 cb b9 ff ff       	call   801035dd <end_op>
		return -1;
80107c12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c17:	eb 18                	jmp    80107c31 <sys_mknod+0x98>
	}
	iunlockput(ip);
80107c19:	83 ec 0c             	sub    $0xc,%esp
80107c1c:	ff 75 f0             	pushl  -0x10(%ebp)
80107c1f:	e8 0a a0 ff ff       	call   80101c2e <iunlockput>
80107c24:	83 c4 10             	add    $0x10,%esp
	end_op();
80107c27:	e8 b1 b9 ff ff       	call   801035dd <end_op>
	return 0;
80107c2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c31:	c9                   	leave  
80107c32:	c3                   	ret    

80107c33 <sys_chdir>:

int sys_chdir(void)
{
80107c33:	55                   	push   %ebp
80107c34:	89 e5                	mov    %esp,%ebp
80107c36:	83 ec 18             	sub    $0x18,%esp
	char *path;
	struct inode *ip;

	begin_op();
80107c39:	e8 13 b9 ff ff       	call   80103551 <begin_op>
	if (argstr(0, &path) < 0 || (ip = namei(path)) == 0) {
80107c3e:	83 ec 08             	sub    $0x8,%esp
80107c41:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107c44:	50                   	push   %eax
80107c45:	6a 00                	push   $0x0
80107c47:	e8 4e f4 ff ff       	call   8010709a <argstr>
80107c4c:	83 c4 10             	add    $0x10,%esp
80107c4f:	85 c0                	test   %eax,%eax
80107c51:	78 18                	js     80107c6b <sys_chdir+0x38>
80107c53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c56:	83 ec 0c             	sub    $0xc,%esp
80107c59:	50                   	push   %eax
80107c5a:	e8 cd a8 ff ff       	call   8010252c <namei>
80107c5f:	83 c4 10             	add    $0x10,%esp
80107c62:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c69:	75 0c                	jne    80107c77 <sys_chdir+0x44>
		end_op();
80107c6b:	e8 6d b9 ff ff       	call   801035dd <end_op>
		return -1;
80107c70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c75:	eb 6e                	jmp    80107ce5 <sys_chdir+0xb2>
	}
	ilock(ip);
80107c77:	83 ec 0c             	sub    $0xc,%esp
80107c7a:	ff 75 f4             	pushl  -0xc(%ebp)
80107c7d:	e8 ec 9c ff ff       	call   8010196e <ilock>
80107c82:	83 c4 10             	add    $0x10,%esp
	if (ip->type != T_DIR) {
80107c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c88:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107c8c:	66 83 f8 01          	cmp    $0x1,%ax
80107c90:	74 1a                	je     80107cac <sys_chdir+0x79>
		iunlockput(ip);
80107c92:	83 ec 0c             	sub    $0xc,%esp
80107c95:	ff 75 f4             	pushl  -0xc(%ebp)
80107c98:	e8 91 9f ff ff       	call   80101c2e <iunlockput>
80107c9d:	83 c4 10             	add    $0x10,%esp
		end_op();
80107ca0:	e8 38 b9 ff ff       	call   801035dd <end_op>
		return -1;
80107ca5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107caa:	eb 39                	jmp    80107ce5 <sys_chdir+0xb2>
	}
	iunlock(ip);
80107cac:	83 ec 0c             	sub    $0xc,%esp
80107caf:	ff 75 f4             	pushl  -0xc(%ebp)
80107cb2:	e8 15 9e ff ff       	call   80101acc <iunlock>
80107cb7:	83 c4 10             	add    $0x10,%esp
	iput(proc->cwd);
80107cba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107cc0:	8b 40 68             	mov    0x68(%eax),%eax
80107cc3:	83 ec 0c             	sub    $0xc,%esp
80107cc6:	50                   	push   %eax
80107cc7:	e8 72 9e ff ff       	call   80101b3e <iput>
80107ccc:	83 c4 10             	add    $0x10,%esp
	end_op();
80107ccf:	e8 09 b9 ff ff       	call   801035dd <end_op>
	proc->cwd = ip;
80107cd4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107cda:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107cdd:	89 50 68             	mov    %edx,0x68(%eax)
	return 0;
80107ce0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ce5:	c9                   	leave  
80107ce6:	c3                   	ret    

80107ce7 <sys_exec>:

int sys_exec(void)
{
80107ce7:	55                   	push   %ebp
80107ce8:	89 e5                	mov    %esp,%ebp
80107cea:	81 ec 98 00 00 00    	sub    $0x98,%esp
	char *path, *argv[MAXARG];
	int i;
	uint uargv, uarg;

	if (argstr(0, &path) < 0 || argint(1, (int *)&uargv) < 0) {
80107cf0:	83 ec 08             	sub    $0x8,%esp
80107cf3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107cf6:	50                   	push   %eax
80107cf7:	6a 00                	push   $0x0
80107cf9:	e8 9c f3 ff ff       	call   8010709a <argstr>
80107cfe:	83 c4 10             	add    $0x10,%esp
80107d01:	85 c0                	test   %eax,%eax
80107d03:	78 18                	js     80107d1d <sys_exec+0x36>
80107d05:	83 ec 08             	sub    $0x8,%esp
80107d08:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80107d0e:	50                   	push   %eax
80107d0f:	6a 01                	push   $0x1
80107d11:	e8 ff f2 ff ff       	call   80107015 <argint>
80107d16:	83 c4 10             	add    $0x10,%esp
80107d19:	85 c0                	test   %eax,%eax
80107d1b:	79 0a                	jns    80107d27 <sys_exec+0x40>
		return -1;
80107d1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d22:	e9 c6 00 00 00       	jmp    80107ded <sys_exec+0x106>
	}
	memset(argv, 0, sizeof(argv));
80107d27:	83 ec 04             	sub    $0x4,%esp
80107d2a:	68 80 00 00 00       	push   $0x80
80107d2f:	6a 00                	push   $0x0
80107d31:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107d37:	50                   	push   %eax
80107d38:	e8 b3 ef ff ff       	call   80106cf0 <memset>
80107d3d:	83 c4 10             	add    $0x10,%esp
	for (i = 0;; i++) {
80107d40:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
		if (i >= NELEM(argv))
80107d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4a:	83 f8 1f             	cmp    $0x1f,%eax
80107d4d:	76 0a                	jbe    80107d59 <sys_exec+0x72>
			return -1;
80107d4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d54:	e9 94 00 00 00       	jmp    80107ded <sys_exec+0x106>
		if (fetchint(uargv + 4 * i, (int *)&uarg) < 0)
80107d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5c:	c1 e0 02             	shl    $0x2,%eax
80107d5f:	89 c2                	mov    %eax,%edx
80107d61:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80107d67:	01 c2                	add    %eax,%edx
80107d69:	83 ec 08             	sub    $0x8,%esp
80107d6c:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80107d72:	50                   	push   %eax
80107d73:	52                   	push   %edx
80107d74:	e8 00 f2 ff ff       	call   80106f79 <fetchint>
80107d79:	83 c4 10             	add    $0x10,%esp
80107d7c:	85 c0                	test   %eax,%eax
80107d7e:	79 07                	jns    80107d87 <sys_exec+0xa0>
			return -1;
80107d80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d85:	eb 66                	jmp    80107ded <sys_exec+0x106>
		if (uarg == 0) {
80107d87:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107d8d:	85 c0                	test   %eax,%eax
80107d8f:	75 27                	jne    80107db8 <sys_exec+0xd1>
			argv[i] = 0;
80107d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d94:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80107d9b:	00 00 00 00 
			break;
80107d9f:	90                   	nop
		}
		if (fetchstr(uarg, &argv[i]) < 0)
			return -1;
	}
	return exec(path, argv);
80107da0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107da3:	83 ec 08             	sub    $0x8,%esp
80107da6:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80107dac:	52                   	push   %edx
80107dad:	50                   	push   %eax
80107dae:	e8 be 8d ff ff       	call   80100b71 <exec>
80107db3:	83 c4 10             	add    $0x10,%esp
80107db6:	eb 35                	jmp    80107ded <sys_exec+0x106>
			return -1;
		if (uarg == 0) {
			argv[i] = 0;
			break;
		}
		if (fetchstr(uarg, &argv[i]) < 0)
80107db8:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107dbe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107dc1:	c1 e2 02             	shl    $0x2,%edx
80107dc4:	01 c2                	add    %eax,%edx
80107dc6:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107dcc:	83 ec 08             	sub    $0x8,%esp
80107dcf:	52                   	push   %edx
80107dd0:	50                   	push   %eax
80107dd1:	e8 dd f1 ff ff       	call   80106fb3 <fetchstr>
80107dd6:	83 c4 10             	add    $0x10,%esp
80107dd9:	85 c0                	test   %eax,%eax
80107ddb:	79 07                	jns    80107de4 <sys_exec+0xfd>
			return -1;
80107ddd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107de2:	eb 09                	jmp    80107ded <sys_exec+0x106>

	if (argstr(0, &path) < 0 || argint(1, (int *)&uargv) < 0) {
		return -1;
	}
	memset(argv, 0, sizeof(argv));
	for (i = 0;; i++) {
80107de4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
			argv[i] = 0;
			break;
		}
		if (fetchstr(uarg, &argv[i]) < 0)
			return -1;
	}
80107de8:	e9 5a ff ff ff       	jmp    80107d47 <sys_exec+0x60>
	return exec(path, argv);
}
80107ded:	c9                   	leave  
80107dee:	c3                   	ret    

80107def <sys_pipe>:

int sys_pipe(void)
{
80107def:	55                   	push   %ebp
80107df0:	89 e5                	mov    %esp,%ebp
80107df2:	83 ec 28             	sub    $0x28,%esp
	int *fd;
	struct file *rf, *wf;
	int fd0, fd1;

	if (argptr(0, (void *)&fd, 2 * sizeof(fd[0])) < 0)
80107df5:	83 ec 04             	sub    $0x4,%esp
80107df8:	6a 08                	push   $0x8
80107dfa:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107dfd:	50                   	push   %eax
80107dfe:	6a 00                	push   $0x0
80107e00:	e8 38 f2 ff ff       	call   8010703d <argptr>
80107e05:	83 c4 10             	add    $0x10,%esp
80107e08:	85 c0                	test   %eax,%eax
80107e0a:	79 0a                	jns    80107e16 <sys_pipe+0x27>
		return -1;
80107e0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e11:	e9 af 00 00 00       	jmp    80107ec5 <sys_pipe+0xd6>
	if (pipealloc(&rf, &wf) < 0)
80107e16:	83 ec 08             	sub    $0x8,%esp
80107e19:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107e1c:	50                   	push   %eax
80107e1d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107e20:	50                   	push   %eax
80107e21:	e8 2e d4 ff ff       	call   80105254 <pipealloc>
80107e26:	83 c4 10             	add    $0x10,%esp
80107e29:	85 c0                	test   %eax,%eax
80107e2b:	79 0a                	jns    80107e37 <sys_pipe+0x48>
		return -1;
80107e2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e32:	e9 8e 00 00 00       	jmp    80107ec5 <sys_pipe+0xd6>
	fd0 = -1;
80107e37:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
	if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
80107e3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107e41:	83 ec 0c             	sub    $0xc,%esp
80107e44:	50                   	push   %eax
80107e45:	e8 7c f3 ff ff       	call   801071c6 <fdalloc>
80107e4a:	83 c4 10             	add    $0x10,%esp
80107e4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e50:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e54:	78 18                	js     80107e6e <sys_pipe+0x7f>
80107e56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107e59:	83 ec 0c             	sub    $0xc,%esp
80107e5c:	50                   	push   %eax
80107e5d:	e8 64 f3 ff ff       	call   801071c6 <fdalloc>
80107e62:	83 c4 10             	add    $0x10,%esp
80107e65:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e68:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e6c:	79 3f                	jns    80107ead <sys_pipe+0xbe>
		if (fd0 >= 0)
80107e6e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e72:	78 14                	js     80107e88 <sys_pipe+0x99>
			proc->ofile[fd0] = 0;
80107e74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107e7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107e7d:	83 c2 08             	add    $0x8,%edx
80107e80:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107e87:	00 
		fileclose(rf);
80107e88:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107e8b:	83 ec 0c             	sub    $0xc,%esp
80107e8e:	50                   	push   %eax
80107e8f:	e8 c1 91 ff ff       	call   80101055 <fileclose>
80107e94:	83 c4 10             	add    $0x10,%esp
		fileclose(wf);
80107e97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107e9a:	83 ec 0c             	sub    $0xc,%esp
80107e9d:	50                   	push   %eax
80107e9e:	e8 b2 91 ff ff       	call   80101055 <fileclose>
80107ea3:	83 c4 10             	add    $0x10,%esp
		return -1;
80107ea6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107eab:	eb 18                	jmp    80107ec5 <sys_pipe+0xd6>
	}
	fd[0] = fd0;
80107ead:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107eb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107eb3:	89 10                	mov    %edx,(%eax)
	fd[1] = fd1;
80107eb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107eb8:	8d 50 04             	lea    0x4(%eax),%edx
80107ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ebe:	89 02                	mov    %eax,(%edx)
	return 0;
80107ec0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ec5:	c9                   	leave  
80107ec6:	c3                   	ret    

80107ec7 <sys_fork>:
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int sys_fork(void)
{
80107ec7:	55                   	push   %ebp
80107ec8:	89 e5                	mov    %esp,%ebp
80107eca:	83 ec 08             	sub    $0x8,%esp
	return fork();
80107ecd:	e8 c5 db ff ff       	call   80105a97 <fork>
}
80107ed2:	c9                   	leave  
80107ed3:	c3                   	ret    

80107ed4 <sys_exit>:

int sys_exit(void)
{
80107ed4:	55                   	push   %ebp
80107ed5:	89 e5                	mov    %esp,%ebp
80107ed7:	83 ec 08             	sub    $0x8,%esp
	exit();
80107eda:	e8 f7 dd ff ff       	call   80105cd6 <exit>
	return 0;		// not reached
80107edf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ee4:	c9                   	leave  
80107ee5:	c3                   	ret    

80107ee6 <sys_wait>:

int sys_wait(void)
{
80107ee6:	55                   	push   %ebp
80107ee7:	89 e5                	mov    %esp,%ebp
80107ee9:	83 ec 08             	sub    $0x8,%esp
	return wait();
80107eec:	e8 58 df ff ff       	call   80105e49 <wait>
}
80107ef1:	c9                   	leave  
80107ef2:	c3                   	ret    

80107ef3 <sys_kill>:

int sys_kill(void)
{
80107ef3:	55                   	push   %ebp
80107ef4:	89 e5                	mov    %esp,%ebp
80107ef6:	83 ec 18             	sub    $0x18,%esp
	int pid;

	if (argint(0, &pid) < 0)
80107ef9:	83 ec 08             	sub    $0x8,%esp
80107efc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107eff:	50                   	push   %eax
80107f00:	6a 00                	push   $0x0
80107f02:	e8 0e f1 ff ff       	call   80107015 <argint>
80107f07:	83 c4 10             	add    $0x10,%esp
80107f0a:	85 c0                	test   %eax,%eax
80107f0c:	79 07                	jns    80107f15 <sys_kill+0x22>
		return -1;
80107f0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f13:	eb 0f                	jmp    80107f24 <sys_kill+0x31>
	return kill(pid);
80107f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f18:	83 ec 0c             	sub    $0xc,%esp
80107f1b:	50                   	push   %eax
80107f1c:	e8 fa e3 ff ff       	call   8010631b <kill>
80107f21:	83 c4 10             	add    $0x10,%esp
}
80107f24:	c9                   	leave  
80107f25:	c3                   	ret    

80107f26 <sys_getpid>:

int sys_getpid(void)
{
80107f26:	55                   	push   %ebp
80107f27:	89 e5                	mov    %esp,%ebp
	return proc->pid;
80107f29:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107f2f:	8b 40 10             	mov    0x10(%eax),%eax
}
80107f32:	5d                   	pop    %ebp
80107f33:	c3                   	ret    

80107f34 <sys_sbrk>:

int sys_sbrk(void)
{
80107f34:	55                   	push   %ebp
80107f35:	89 e5                	mov    %esp,%ebp
80107f37:	83 ec 18             	sub    $0x18,%esp
	int addr;
	int n;

	if (argint(0, &n) < 0)
80107f3a:	83 ec 08             	sub    $0x8,%esp
80107f3d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107f40:	50                   	push   %eax
80107f41:	6a 00                	push   $0x0
80107f43:	e8 cd f0 ff ff       	call   80107015 <argint>
80107f48:	83 c4 10             	add    $0x10,%esp
80107f4b:	85 c0                	test   %eax,%eax
80107f4d:	79 07                	jns    80107f56 <sys_sbrk+0x22>
		return -1;
80107f4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f54:	eb 28                	jmp    80107f7e <sys_sbrk+0x4a>
	addr = proc->sz;
80107f56:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107f5c:	8b 00                	mov    (%eax),%eax
80107f5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (growproc(n) < 0)
80107f61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f64:	83 ec 0c             	sub    $0xc,%esp
80107f67:	50                   	push   %eax
80107f68:	e8 88 da ff ff       	call   801059f5 <growproc>
80107f6d:	83 c4 10             	add    $0x10,%esp
80107f70:	85 c0                	test   %eax,%eax
80107f72:	79 07                	jns    80107f7b <sys_sbrk+0x47>
		return -1;
80107f74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f79:	eb 03                	jmp    80107f7e <sys_sbrk+0x4a>
	return addr;
80107f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107f7e:	c9                   	leave  
80107f7f:	c3                   	ret    

80107f80 <sys_sleep>:

int sys_sleep(void)
{
80107f80:	55                   	push   %ebp
80107f81:	89 e5                	mov    %esp,%ebp
80107f83:	83 ec 18             	sub    $0x18,%esp
	int n;
	uint ticks0;

	if (argint(0, &n) < 0)
80107f86:	83 ec 08             	sub    $0x8,%esp
80107f89:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107f8c:	50                   	push   %eax
80107f8d:	6a 00                	push   $0x0
80107f8f:	e8 81 f0 ff ff       	call   80107015 <argint>
80107f94:	83 c4 10             	add    $0x10,%esp
80107f97:	85 c0                	test   %eax,%eax
80107f99:	79 07                	jns    80107fa2 <sys_sleep+0x22>
		return -1;
80107f9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fa0:	eb 77                	jmp    80108019 <sys_sleep+0x99>
	acquire(&tickslock);
80107fa2:	83 ec 0c             	sub    $0xc,%esp
80107fa5:	68 40 47 12 80       	push   $0x80124740
80107faa:	e8 de ea ff ff       	call   80106a8d <acquire>
80107faf:	83 c4 10             	add    $0x10,%esp
	ticks0 = ticks;
80107fb2:	a1 80 4f 12 80       	mov    0x80124f80,%eax
80107fb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	while (ticks - ticks0 < n) {
80107fba:	eb 39                	jmp    80107ff5 <sys_sleep+0x75>
		if (proc->killed) {
80107fbc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107fc2:	8b 40 24             	mov    0x24(%eax),%eax
80107fc5:	85 c0                	test   %eax,%eax
80107fc7:	74 17                	je     80107fe0 <sys_sleep+0x60>
			release(&tickslock);
80107fc9:	83 ec 0c             	sub    $0xc,%esp
80107fcc:	68 40 47 12 80       	push   $0x80124740
80107fd1:	e8 1e eb ff ff       	call   80106af4 <release>
80107fd6:	83 c4 10             	add    $0x10,%esp
			return -1;
80107fd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fde:	eb 39                	jmp    80108019 <sys_sleep+0x99>
		}
		sleep(&ticks, &tickslock);
80107fe0:	83 ec 08             	sub    $0x8,%esp
80107fe3:	68 40 47 12 80       	push   $0x80124740
80107fe8:	68 80 4f 12 80       	push   $0x80124f80
80107fed:	e8 04 e2 ff ff       	call   801061f6 <sleep>
80107ff2:	83 c4 10             	add    $0x10,%esp

	if (argint(0, &n) < 0)
		return -1;
	acquire(&tickslock);
	ticks0 = ticks;
	while (ticks - ticks0 < n) {
80107ff5:	a1 80 4f 12 80       	mov    0x80124f80,%eax
80107ffa:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107ffd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108000:	39 d0                	cmp    %edx,%eax
80108002:	72 b8                	jb     80107fbc <sys_sleep+0x3c>
			release(&tickslock);
			return -1;
		}
		sleep(&ticks, &tickslock);
	}
	release(&tickslock);
80108004:	83 ec 0c             	sub    $0xc,%esp
80108007:	68 40 47 12 80       	push   $0x80124740
8010800c:	e8 e3 ea ff ff       	call   80106af4 <release>
80108011:	83 c4 10             	add    $0x10,%esp
	return 0;
80108014:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108019:	c9                   	leave  
8010801a:	c3                   	ret    

8010801b <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int sys_uptime(void)
{
8010801b:	55                   	push   %ebp
8010801c:	89 e5                	mov    %esp,%ebp
8010801e:	83 ec 18             	sub    $0x18,%esp
	uint xticks;

	acquire(&tickslock);
80108021:	83 ec 0c             	sub    $0xc,%esp
80108024:	68 40 47 12 80       	push   $0x80124740
80108029:	e8 5f ea ff ff       	call   80106a8d <acquire>
8010802e:	83 c4 10             	add    $0x10,%esp
	xticks = ticks;
80108031:	a1 80 4f 12 80       	mov    0x80124f80,%eax
80108036:	89 45 f4             	mov    %eax,-0xc(%ebp)
	release(&tickslock);
80108039:	83 ec 0c             	sub    $0xc,%esp
8010803c:	68 40 47 12 80       	push   $0x80124740
80108041:	e8 ae ea ff ff       	call   80106af4 <release>
80108046:	83 c4 10             	add    $0x10,%esp
	return xticks;
80108049:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010804c:	c9                   	leave  
8010804d:	c3                   	ret    

8010804e <sys_setHighPrio>:

int
sys_setHighPrio(void)//scheduler
{
8010804e:	55                   	push   %ebp
8010804f:	89 e5                	mov    %esp,%ebp
80108051:	83 ec 08             	sub    $0x8,%esp
	setHighPrio();
80108054:	e8 45 e4 ff ff       	call   8010649e <setHighPrio>
	return 0;
80108059:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010805e:	c9                   	leave  
8010805f:	c3                   	ret    

80108060 <sys_shm_get>:


int sys_shm_get(void) //mod2
{
80108060:	55                   	push   %ebp
80108061:	89 e5                	mov    %esp,%ebp
80108063:	83 ec 18             	sub    $0x18,%esp
	char *name;
	int length;
	char* result = 0;
80108066:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	//int addr = 0;
	int check = 0;
8010806d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	
	if(argint(1, &length) < 0 || argptr(0, &name, length) < 0)
80108074:	83 ec 08             	sub    $0x8,%esp
80108077:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010807a:	50                   	push   %eax
8010807b:	6a 01                	push   $0x1
8010807d:	e8 93 ef ff ff       	call   80107015 <argint>
80108082:	83 c4 10             	add    $0x10,%esp
80108085:	85 c0                	test   %eax,%eax
80108087:	78 19                	js     801080a2 <sys_shm_get+0x42>
80108089:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010808c:	83 ec 04             	sub    $0x4,%esp
8010808f:	50                   	push   %eax
80108090:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108093:	50                   	push   %eax
80108094:	6a 00                	push   $0x0
80108096:	e8 a2 ef ff ff       	call   8010703d <argptr>
8010809b:	83 c4 10             	add    $0x10,%esp
8010809e:	85 c0                	test   %eax,%eax
801080a0:	79 07                	jns    801080a9 <sys_shm_get+0x49>
		return 0;
801080a2:	b8 00 00 00 00       	mov    $0x0,%eax
801080a7:	eb 6e                	jmp    80108117 <sys_shm_get+0xb7>

	if(length>16)
801080a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801080ac:	83 f8 10             	cmp    $0x10,%eax
801080af:	7e 17                	jle    801080c8 <sys_shm_get+0x68>
	{
		cprintf("SHM Name Too Long! Cannot create SHM Region.");
801080b1:	83 ec 0c             	sub    $0xc,%esp
801080b4:	68 18 ad 10 80       	push   $0x8010ad18
801080b9:	e8 08 83 ff ff       	call   801003c6 <cprintf>
801080be:	83 c4 10             	add    $0x10,%esp
		return 0;
801080c1:	b8 00 00 00 00       	mov    $0x0,%eax
801080c6:	eb 4f                	jmp    80108117 <sys_shm_get+0xb7>
	}

	check = strncmp(name, "DNE", sizeof(name));
801080c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080cb:	83 ec 04             	sub    $0x4,%esp
801080ce:	6a 04                	push   $0x4
801080d0:	68 45 ad 10 80       	push   $0x8010ad45
801080d5:	50                   	push   %eax
801080d6:	e8 6a ed ff ff       	call   80106e45 <strncmp>
801080db:	83 c4 10             	add    $0x10,%esp
801080de:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(check == 0)
801080e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080e5:	75 17                	jne    801080fe <sys_shm_get+0x9e>
	{
		cprintf("The name 'DNE' is reserved for kernel use only. Please give SHM Region a different name.");
801080e7:	83 ec 0c             	sub    $0xc,%esp
801080ea:	68 4c ad 10 80       	push   $0x8010ad4c
801080ef:	e8 d2 82 ff ff       	call   801003c6 <cprintf>
801080f4:	83 c4 10             	add    $0x10,%esp
		return 0;
801080f7:	b8 00 00 00 00       	mov    $0x0,%eax
801080fc:	eb 19                	jmp    80108117 <sys_shm_get+0xb7>
	else
	{
		//cprintf("Character = %s\n", name);
		//addr = proc->sz;
		//cprintf("\nOld Size of process is starting point of SHM = %d\n", addr);
		result = shm_get(name, length);
801080fe:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108101:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108104:	83 ec 08             	sub    $0x8,%esp
80108107:	52                   	push   %edx
80108108:	50                   	push   %eax
80108109:	e8 3a c2 ff ff       	call   80104348 <shm_get>
8010810e:	83 c4 10             	add    $0x10,%esp
80108111:	89 45 f4             	mov    %eax,-0xc(%ebp)
		
		//cprintf("\nNormal char* result form SysCall = %d\n", result);
		//cprintf("\nTypecasted result form SysCall as int = %d\n", (int)result);
		//return (int)result;
		return (int)result;
80108114:	8b 45 f4             	mov    -0xc(%ebp),%eax
	}
	return 0;
}
80108117:	c9                   	leave  
80108118:	c3                   	ret    

80108119 <sys_shm_rem>:




int sys_shm_rem(void) //mod2
{
80108119:	55                   	push   %ebp
8010811a:	89 e5                	mov    %esp,%ebp
8010811c:	83 ec 18             	sub    $0x18,%esp

	char *name;
	int length;
	int result = 0;
8010811f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int check = 0;
80108126:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	
	if(argint(1, &length) < 0 || argptr(0, &name, length) < 0)
8010812d:	83 ec 08             	sub    $0x8,%esp
80108130:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108133:	50                   	push   %eax
80108134:	6a 01                	push   $0x1
80108136:	e8 da ee ff ff       	call   80107015 <argint>
8010813b:	83 c4 10             	add    $0x10,%esp
8010813e:	85 c0                	test   %eax,%eax
80108140:	78 19                	js     8010815b <sys_shm_rem+0x42>
80108142:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108145:	83 ec 04             	sub    $0x4,%esp
80108148:	50                   	push   %eax
80108149:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010814c:	50                   	push   %eax
8010814d:	6a 00                	push   $0x0
8010814f:	e8 e9 ee ff ff       	call   8010703d <argptr>
80108154:	83 c4 10             	add    $0x10,%esp
80108157:	85 c0                	test   %eax,%eax
80108159:	79 07                	jns    80108162 <sys_shm_rem+0x49>
		return 0;
8010815b:	b8 00 00 00 00       	mov    $0x0,%eax
80108160:	eb 6e                	jmp    801081d0 <sys_shm_rem+0xb7>
	
	if(length>16)
80108162:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108165:	83 f8 10             	cmp    $0x10,%eax
80108168:	7e 17                	jle    80108181 <sys_shm_rem+0x68>
	{
		cprintf("SHM Name Too Long! No Region Exists with that Length.");
8010816a:	83 ec 0c             	sub    $0xc,%esp
8010816d:	68 a8 ad 10 80       	push   $0x8010ada8
80108172:	e8 4f 82 ff ff       	call   801003c6 <cprintf>
80108177:	83 c4 10             	add    $0x10,%esp
		return 0;
8010817a:	b8 00 00 00 00       	mov    $0x0,%eax
8010817f:	eb 4f                	jmp    801081d0 <sys_shm_rem+0xb7>
	}

	check = strncmp(name, "DNE", sizeof(name));
80108181:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108184:	83 ec 04             	sub    $0x4,%esp
80108187:	6a 04                	push   $0x4
80108189:	68 45 ad 10 80       	push   $0x8010ad45
8010818e:	50                   	push   %eax
8010818f:	e8 b1 ec ff ff       	call   80106e45 <strncmp>
80108194:	83 c4 10             	add    $0x10,%esp
80108197:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(check == 0)
8010819a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010819e:	75 17                	jne    801081b7 <sys_shm_rem+0x9e>
	{
		cprintf("The name 'DNE' is reserved for kernel use only. Please give SHM Region a different name.");
801081a0:	83 ec 0c             	sub    $0xc,%esp
801081a3:	68 4c ad 10 80       	push   $0x8010ad4c
801081a8:	e8 19 82 ff ff       	call   801003c6 <cprintf>
801081ad:	83 c4 10             	add    $0x10,%esp
		return 0;
801081b0:	b8 00 00 00 00       	mov    $0x0,%eax
801081b5:	eb 19                	jmp    801081d0 <sys_shm_rem+0xb7>
	}

	else
	{
		result = shm_rem(name, length);
801081b7:	8b 55 e8             	mov    -0x18(%ebp),%edx
801081ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081bd:	83 ec 08             	sub    $0x8,%esp
801081c0:	52                   	push   %edx
801081c1:	50                   	push   %eax
801081c2:	e8 1d c5 ff ff       	call   801046e4 <shm_rem>
801081c7:	83 c4 10             	add    $0x10,%esp
801081ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return result;
801081cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
	}
	
	return 0;
}
801081d0:	c9                   	leave  
801081d1:	c3                   	ret    

801081d2 <sys_mutex_create>:

int sys_mutex_create(void){
801081d2:	55                   	push   %ebp
801081d3:	89 e5                	mov    %esp,%ebp
801081d5:	83 ec 18             	sub    $0x18,%esp
	

	//Returns -1 if a mutex cannot be created
	//Otherwise, a mutex id is returned to be used for
	//future mutex calls
	if(argint(1,&name_len)<0 || argptr(0, &name, name_len)<0)
801081d8:	83 ec 08             	sub    $0x8,%esp
801081db:	8d 45 f0             	lea    -0x10(%ebp),%eax
801081de:	50                   	push   %eax
801081df:	6a 01                	push   $0x1
801081e1:	e8 2f ee ff ff       	call   80107015 <argint>
801081e6:	83 c4 10             	add    $0x10,%esp
801081e9:	85 c0                	test   %eax,%eax
801081eb:	78 19                	js     80108206 <sys_mutex_create+0x34>
801081ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081f0:	83 ec 04             	sub    $0x4,%esp
801081f3:	50                   	push   %eax
801081f4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801081f7:	50                   	push   %eax
801081f8:	6a 00                	push   $0x0
801081fa:	e8 3e ee ff ff       	call   8010703d <argptr>
801081ff:	83 c4 10             	add    $0x10,%esp
80108202:	85 c0                	test   %eax,%eax
80108204:	79 07                	jns    8010820d <sys_mutex_create+0x3b>
		return -1;
80108206:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010820b:	eb 19                	jmp    80108226 <sys_mutex_create+0x54>
	else{
		muxid = initmutex(name, name_len);
8010820d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108210:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108213:	83 ec 08             	sub    $0x8,%esp
80108216:	52                   	push   %edx
80108217:	50                   	push   %eax
80108218:	e8 99 e2 ff ff       	call   801064b6 <initmutex>
8010821d:	83 c4 10             	add    $0x10,%esp
80108220:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return muxid;
80108223:	8b 45 f4             	mov    -0xc(%ebp),%eax
	}
	return 0;
}
80108226:	c9                   	leave  
80108227:	c3                   	ret    

80108228 <sys_mutex_delete>:
int sys_mutex_delete(void){
80108228:	55                   	push   %ebp
80108229:	89 e5                	mov    %esp,%ebp
8010822b:	83 ec 18             	sub    $0x18,%esp


	int muxid;
	if(argint(0, &muxid)<0)
8010822e:	83 ec 08             	sub    $0x8,%esp
80108231:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108234:	50                   	push   %eax
80108235:	6a 00                	push   $0x0
80108237:	e8 d9 ed ff ff       	call   80107015 <argint>
8010823c:	83 c4 10             	add    $0x10,%esp
8010823f:	85 c0                	test   %eax,%eax
80108241:	79 07                	jns    8010824a <sys_mutex_delete+0x22>
		return -1;
80108243:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108248:	eb 14                	jmp    8010825e <sys_mutex_delete+0x36>
	mxdelete(muxid);
8010824a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010824d:	83 ec 0c             	sub    $0xc,%esp
80108250:	50                   	push   %eax
80108251:	e8 c3 e5 ff ff       	call   80106819 <mxdelete>
80108256:	83 c4 10             	add    $0x10,%esp
	return 0;
80108259:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010825e:	c9                   	leave  
8010825f:	c3                   	ret    

80108260 <sys_mutex_lock>:
int sys_mutex_lock(void){
80108260:	55                   	push   %ebp
80108261:	89 e5                	mov    %esp,%ebp
80108263:	83 ec 18             	sub    $0x18,%esp
	int muxid;
	if(argint(0, &muxid)<0)
80108266:	83 ec 08             	sub    $0x8,%esp
80108269:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010826c:	50                   	push   %eax
8010826d:	6a 00                	push   $0x0
8010826f:	e8 a1 ed ff ff       	call   80107015 <argint>
80108274:	83 c4 10             	add    $0x10,%esp
80108277:	85 c0                	test   %eax,%eax
80108279:	79 07                	jns    80108282 <sys_mutex_lock+0x22>
                return -1;
8010827b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108280:	eb 14                	jmp    80108296 <sys_mutex_lock+0x36>
	mxacquire(muxid);
80108282:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108285:	83 ec 0c             	sub    $0xc,%esp
80108288:	50                   	push   %eax
80108289:	e8 ff e3 ff ff       	call   8010668d <mxacquire>
8010828e:	83 c4 10             	add    $0x10,%esp
	return 0;
80108291:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108296:	c9                   	leave  
80108297:	c3                   	ret    

80108298 <sys_mutex_unlock>:
int sys_mutex_unlock(void)
{
80108298:	55                   	push   %ebp
80108299:	89 e5                	mov    %esp,%ebp
8010829b:	83 ec 18             	sub    $0x18,%esp
	int muxid;
	if(argint(0, &muxid)<0)
8010829e:	83 ec 08             	sub    $0x8,%esp
801082a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801082a4:	50                   	push   %eax
801082a5:	6a 00                	push   $0x0
801082a7:	e8 69 ed ff ff       	call   80107015 <argint>
801082ac:	83 c4 10             	add    $0x10,%esp
801082af:	85 c0                	test   %eax,%eax
801082b1:	79 07                	jns    801082ba <sys_mutex_unlock+0x22>
                return -1;
801082b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801082b8:	eb 14                	jmp    801082ce <sys_mutex_unlock+0x36>

	mxrelease(muxid);
801082ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082bd:	83 ec 0c             	sub    $0xc,%esp
801082c0:	50                   	push   %eax
801082c1:	e8 a1 e4 ff ff       	call   80106767 <mxrelease>
801082c6:	83 c4 10             	add    $0x10,%esp
	return 0;
801082c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801082ce:	c9                   	leave  
801082cf:	c3                   	ret    

801082d0 <sys_cv_wait>:

int sys_cv_wait(void)
{
801082d0:	55                   	push   %ebp
801082d1:	89 e5                	mov    %esp,%ebp
801082d3:	83 ec 18             	sub    $0x18,%esp
	int muxid;
	if(argint(0, &muxid)<0)
801082d6:	83 ec 08             	sub    $0x8,%esp
801082d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801082dc:	50                   	push   %eax
801082dd:	6a 00                	push   $0x0
801082df:	e8 31 ed ff ff       	call   80107015 <argint>
801082e4:	83 c4 10             	add    $0x10,%esp
801082e7:	85 c0                	test   %eax,%eax
801082e9:	79 07                	jns    801082f2 <sys_cv_wait+0x22>
		return -1;
801082eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801082f0:	eb 14                	jmp    80108306 <sys_cv_wait+0x36>
	cvwait(muxid);
801082f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f5:	83 ec 0c             	sub    $0xc,%esp
801082f8:	50                   	push   %eax
801082f9:	e8 2e e6 ff ff       	call   8010692c <cvwait>
801082fe:	83 c4 10             	add    $0x10,%esp
	return 0;
80108301:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108306:	c9                   	leave  
80108307:	c3                   	ret    

80108308 <sys_cv_signal>:

int sys_cv_signal(void)
{
80108308:	55                   	push   %ebp
80108309:	89 e5                	mov    %esp,%ebp
8010830b:	83 ec 18             	sub    $0x18,%esp
	int muxid;
        if(argint(0, &muxid)<0)
8010830e:	83 ec 08             	sub    $0x8,%esp
80108311:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108314:	50                   	push   %eax
80108315:	6a 00                	push   $0x0
80108317:	e8 f9 ec ff ff       	call   80107015 <argint>
8010831c:	83 c4 10             	add    $0x10,%esp
8010831f:	85 c0                	test   %eax,%eax
80108321:	79 07                	jns    8010832a <sys_cv_signal+0x22>
                return -1;
80108323:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108328:	eb 14                	jmp    8010833e <sys_cv_signal+0x36>
        cvsignal(muxid);
8010832a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832d:	83 ec 0c             	sub    $0xc,%esp
80108330:	50                   	push   %eax
80108331:	e8 8c e6 ff ff       	call   801069c2 <cvsignal>
80108336:	83 c4 10             	add    $0x10,%esp
        return 0;
80108339:	b8 00 00 00 00       	mov    $0x0,%eax


}
8010833e:	c9                   	leave  
8010833f:	c3                   	ret    

80108340 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80108340:	55                   	push   %ebp
80108341:	89 e5                	mov    %esp,%ebp
80108343:	83 ec 08             	sub    $0x8,%esp
80108346:	8b 55 08             	mov    0x8(%ebp),%edx
80108349:	8b 45 0c             	mov    0xc(%ebp),%eax
8010834c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80108350:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108353:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108357:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010835b:	ee                   	out    %al,(%dx)
}
8010835c:	90                   	nop
8010835d:	c9                   	leave  
8010835e:	c3                   	ret    

8010835f <timerinit>:
#define TIMER_SEL0      0x00	// select counter 0
#define TIMER_RATEGEN   0x04	// mode 2, rate generator
#define TIMER_16BIT     0x30	// r/w counter 16 bits, LSB first

void timerinit(void)
{
8010835f:	55                   	push   %ebp
80108360:	89 e5                	mov    %esp,%ebp
80108362:	83 ec 08             	sub    $0x8,%esp
	// Interrupt 100 times/sec.
	outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80108365:	6a 34                	push   $0x34
80108367:	6a 43                	push   $0x43
80108369:	e8 d2 ff ff ff       	call   80108340 <outb>
8010836e:	83 c4 08             	add    $0x8,%esp
	outb(IO_TIMER1, TIMER_DIV(100) % 256);
80108371:	68 9c 00 00 00       	push   $0x9c
80108376:	6a 40                	push   $0x40
80108378:	e8 c3 ff ff ff       	call   80108340 <outb>
8010837d:	83 c4 08             	add    $0x8,%esp
	outb(IO_TIMER1, TIMER_DIV(100) / 256);
80108380:	6a 2e                	push   $0x2e
80108382:	6a 40                	push   $0x40
80108384:	e8 b7 ff ff ff       	call   80108340 <outb>
80108389:	83 c4 08             	add    $0x8,%esp
	picenable(IRQ_TIMER);
8010838c:	83 ec 0c             	sub    $0xc,%esp
8010838f:	6a 00                	push   $0x0
80108391:	e8 a8 cd ff ff       	call   8010513e <picenable>
80108396:	83 c4 10             	add    $0x10,%esp
}
80108399:	90                   	nop
8010839a:	c9                   	leave  
8010839b:	c3                   	ret    

8010839c <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010839c:	1e                   	push   %ds
  pushl %es
8010839d:	06                   	push   %es
  pushl %fs
8010839e:	0f a0                	push   %fs
  pushl %gs
801083a0:	0f a8                	push   %gs
  pushal
801083a2:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801083a3:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801083a7:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801083a9:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801083ab:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801083af:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801083b1:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801083b3:	54                   	push   %esp
  call trap
801083b4:	e8 d7 01 00 00       	call   80108590 <trap>
  addl $4, %esp
801083b9:	83 c4 04             	add    $0x4,%esp

801083bc <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801083bc:	61                   	popa   
  popl %gs
801083bd:	0f a9                	pop    %gs
  popl %fs
801083bf:	0f a1                	pop    %fs
  popl %es
801083c1:	07                   	pop    %es
  popl %ds
801083c2:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801083c3:	83 c4 08             	add    $0x8,%esp
  iret
801083c6:	cf                   	iret   

801083c7 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801083c7:	55                   	push   %ebp
801083c8:	89 e5                	mov    %esp,%ebp
801083ca:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801083cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801083d0:	83 e8 01             	sub    $0x1,%eax
801083d3:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801083d7:	8b 45 08             	mov    0x8(%ebp),%eax
801083da:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801083de:	8b 45 08             	mov    0x8(%ebp),%eax
801083e1:	c1 e8 10             	shr    $0x10,%eax
801083e4:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801083e8:	8d 45 fa             	lea    -0x6(%ebp),%eax
801083eb:	0f 01 18             	lidtl  (%eax)
}
801083ee:	90                   	nop
801083ef:	c9                   	leave  
801083f0:	c3                   	ret    

801083f1 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801083f1:	55                   	push   %ebp
801083f2:	89 e5                	mov    %esp,%ebp
801083f4:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801083f7:	0f 20 d0             	mov    %cr2,%eax
801083fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801083fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108400:	c9                   	leave  
80108401:	c3                   	ret    

80108402 <tvinit>:
extern uint vectors[];		// in vectors.S: array of 256 entry pointers
struct spinlock tickslock;
uint ticks;

void tvinit(void)
{
80108402:	55                   	push   %ebp
80108403:	89 e5                	mov    %esp,%ebp
80108405:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < 256; i++)
80108408:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010840f:	e9 c3 00 00 00       	jmp    801084d7 <tvinit+0xd5>
		SETGATE(idt[i], 0, SEG_KCODE << 3, vectors[i], 0);
80108414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108417:	8b 04 85 bc e0 10 80 	mov    -0x7fef1f44(,%eax,4),%eax
8010841e:	89 c2                	mov    %eax,%edx
80108420:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108423:	66 89 14 c5 80 47 12 	mov    %dx,-0x7fedb880(,%eax,8)
8010842a:	80 
8010842b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842e:	66 c7 04 c5 82 47 12 	movw   $0x8,-0x7fedb87e(,%eax,8)
80108435:	80 08 00 
80108438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843b:	0f b6 14 c5 84 47 12 	movzbl -0x7fedb87c(,%eax,8),%edx
80108442:	80 
80108443:	83 e2 e0             	and    $0xffffffe0,%edx
80108446:	88 14 c5 84 47 12 80 	mov    %dl,-0x7fedb87c(,%eax,8)
8010844d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108450:	0f b6 14 c5 84 47 12 	movzbl -0x7fedb87c(,%eax,8),%edx
80108457:	80 
80108458:	83 e2 1f             	and    $0x1f,%edx
8010845b:	88 14 c5 84 47 12 80 	mov    %dl,-0x7fedb87c(,%eax,8)
80108462:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108465:	0f b6 14 c5 85 47 12 	movzbl -0x7fedb87b(,%eax,8),%edx
8010846c:	80 
8010846d:	83 e2 f0             	and    $0xfffffff0,%edx
80108470:	83 ca 0e             	or     $0xe,%edx
80108473:	88 14 c5 85 47 12 80 	mov    %dl,-0x7fedb87b(,%eax,8)
8010847a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010847d:	0f b6 14 c5 85 47 12 	movzbl -0x7fedb87b(,%eax,8),%edx
80108484:	80 
80108485:	83 e2 ef             	and    $0xffffffef,%edx
80108488:	88 14 c5 85 47 12 80 	mov    %dl,-0x7fedb87b(,%eax,8)
8010848f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108492:	0f b6 14 c5 85 47 12 	movzbl -0x7fedb87b(,%eax,8),%edx
80108499:	80 
8010849a:	83 e2 9f             	and    $0xffffff9f,%edx
8010849d:	88 14 c5 85 47 12 80 	mov    %dl,-0x7fedb87b(,%eax,8)
801084a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a7:	0f b6 14 c5 85 47 12 	movzbl -0x7fedb87b(,%eax,8),%edx
801084ae:	80 
801084af:	83 ca 80             	or     $0xffffff80,%edx
801084b2:	88 14 c5 85 47 12 80 	mov    %dl,-0x7fedb87b(,%eax,8)
801084b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084bc:	8b 04 85 bc e0 10 80 	mov    -0x7fef1f44(,%eax,4),%eax
801084c3:	c1 e8 10             	shr    $0x10,%eax
801084c6:	89 c2                	mov    %eax,%edx
801084c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084cb:	66 89 14 c5 86 47 12 	mov    %dx,-0x7fedb87a(,%eax,8)
801084d2:	80 

void tvinit(void)
{
	int i;

	for (i = 0; i < 256; i++)
801084d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801084d7:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801084de:	0f 8e 30 ff ff ff    	jle    80108414 <tvinit+0x12>
		SETGATE(idt[i], 0, SEG_KCODE << 3, vectors[i], 0);
	SETGATE(idt[T_SYSCALL], 1, SEG_KCODE << 3, vectors[T_SYSCALL],
801084e4:	a1 bc e1 10 80       	mov    0x8010e1bc,%eax
801084e9:	66 a3 80 49 12 80    	mov    %ax,0x80124980
801084ef:	66 c7 05 82 49 12 80 	movw   $0x8,0x80124982
801084f6:	08 00 
801084f8:	0f b6 05 84 49 12 80 	movzbl 0x80124984,%eax
801084ff:	83 e0 e0             	and    $0xffffffe0,%eax
80108502:	a2 84 49 12 80       	mov    %al,0x80124984
80108507:	0f b6 05 84 49 12 80 	movzbl 0x80124984,%eax
8010850e:	83 e0 1f             	and    $0x1f,%eax
80108511:	a2 84 49 12 80       	mov    %al,0x80124984
80108516:	0f b6 05 85 49 12 80 	movzbl 0x80124985,%eax
8010851d:	83 c8 0f             	or     $0xf,%eax
80108520:	a2 85 49 12 80       	mov    %al,0x80124985
80108525:	0f b6 05 85 49 12 80 	movzbl 0x80124985,%eax
8010852c:	83 e0 ef             	and    $0xffffffef,%eax
8010852f:	a2 85 49 12 80       	mov    %al,0x80124985
80108534:	0f b6 05 85 49 12 80 	movzbl 0x80124985,%eax
8010853b:	83 c8 60             	or     $0x60,%eax
8010853e:	a2 85 49 12 80       	mov    %al,0x80124985
80108543:	0f b6 05 85 49 12 80 	movzbl 0x80124985,%eax
8010854a:	83 c8 80             	or     $0xffffff80,%eax
8010854d:	a2 85 49 12 80       	mov    %al,0x80124985
80108552:	a1 bc e1 10 80       	mov    0x8010e1bc,%eax
80108557:	c1 e8 10             	shr    $0x10,%eax
8010855a:	66 a3 86 49 12 80    	mov    %ax,0x80124986
		DPL_USER);

	initlock(&tickslock, "time");
80108560:	83 ec 08             	sub    $0x8,%esp
80108563:	68 e0 ad 10 80       	push   $0x8010ade0
80108568:	68 40 47 12 80       	push   $0x80124740
8010856d:	e8 f9 e4 ff ff       	call   80106a6b <initlock>
80108572:	83 c4 10             	add    $0x10,%esp
}
80108575:	90                   	nop
80108576:	c9                   	leave  
80108577:	c3                   	ret    

80108578 <idtinit>:

void idtinit(void)
{
80108578:	55                   	push   %ebp
80108579:	89 e5                	mov    %esp,%ebp
	lidt(idt, sizeof(idt));
8010857b:	68 00 08 00 00       	push   $0x800
80108580:	68 80 47 12 80       	push   $0x80124780
80108585:	e8 3d fe ff ff       	call   801083c7 <lidt>
8010858a:	83 c4 08             	add    $0x8,%esp
}
8010858d:	90                   	nop
8010858e:	c9                   	leave  
8010858f:	c3                   	ret    

80108590 <trap>:

//PAGEBREAK: 41
void trap(struct trapframe *tf)
{
80108590:	55                   	push   %ebp
80108591:	89 e5                	mov    %esp,%ebp
80108593:	57                   	push   %edi
80108594:	56                   	push   %esi
80108595:	53                   	push   %ebx
80108596:	83 ec 1c             	sub    $0x1c,%esp
	if (tf->trapno == T_SYSCALL) {
80108599:	8b 45 08             	mov    0x8(%ebp),%eax
8010859c:	8b 40 30             	mov    0x30(%eax),%eax
8010859f:	83 f8 40             	cmp    $0x40,%eax
801085a2:	75 3e                	jne    801085e2 <trap+0x52>
		if (proc->killed)
801085a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801085aa:	8b 40 24             	mov    0x24(%eax),%eax
801085ad:	85 c0                	test   %eax,%eax
801085af:	74 05                	je     801085b6 <trap+0x26>
			exit();
801085b1:	e8 20 d7 ff ff       	call   80105cd6 <exit>
		proc->tf = tf;
801085b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801085bc:	8b 55 08             	mov    0x8(%ebp),%edx
801085bf:	89 50 18             	mov    %edx,0x18(%eax)
		syscall();
801085c2:	e8 04 eb ff ff       	call   801070cb <syscall>
		if (proc->killed)
801085c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801085cd:	8b 40 24             	mov    0x24(%eax),%eax
801085d0:	85 c0                	test   %eax,%eax
801085d2:	0f 84 1b 02 00 00    	je     801087f3 <trap+0x263>
			exit();
801085d8:	e8 f9 d6 ff ff       	call   80105cd6 <exit>
		return;
801085dd:	e9 11 02 00 00       	jmp    801087f3 <trap+0x263>
	}

	switch (tf->trapno) {
801085e2:	8b 45 08             	mov    0x8(%ebp),%eax
801085e5:	8b 40 30             	mov    0x30(%eax),%eax
801085e8:	83 e8 20             	sub    $0x20,%eax
801085eb:	83 f8 1f             	cmp    $0x1f,%eax
801085ee:	0f 87 c0 00 00 00    	ja     801086b4 <trap+0x124>
801085f4:	8b 04 85 88 ae 10 80 	mov    -0x7fef5178(,%eax,4),%eax
801085fb:	ff e0                	jmp    *%eax
	case T_IRQ0 + IRQ_TIMER:
		if (cpu->id == 0) {
801085fd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108603:	0f b6 00             	movzbl (%eax),%eax
80108606:	84 c0                	test   %al,%al
80108608:	75 3d                	jne    80108647 <trap+0xb7>
			acquire(&tickslock);
8010860a:	83 ec 0c             	sub    $0xc,%esp
8010860d:	68 40 47 12 80       	push   $0x80124740
80108612:	e8 76 e4 ff ff       	call   80106a8d <acquire>
80108617:	83 c4 10             	add    $0x10,%esp
			ticks++;
8010861a:	a1 80 4f 12 80       	mov    0x80124f80,%eax
8010861f:	83 c0 01             	add    $0x1,%eax
80108622:	a3 80 4f 12 80       	mov    %eax,0x80124f80
			wakeup(&ticks);
80108627:	83 ec 0c             	sub    $0xc,%esp
8010862a:	68 80 4f 12 80       	push   $0x80124f80
8010862f:	e8 b0 dc ff ff       	call   801062e4 <wakeup>
80108634:	83 c4 10             	add    $0x10,%esp
			release(&tickslock);
80108637:	83 ec 0c             	sub    $0xc,%esp
8010863a:	68 40 47 12 80       	push   $0x80124740
8010863f:	e8 b0 e4 ff ff       	call   80106af4 <release>
80108644:	83 c4 10             	add    $0x10,%esp
		}
		lapiceoi();
80108647:	e8 dd a9 ff ff       	call   80103029 <lapiceoi>
		break;
8010864c:	e9 1c 01 00 00       	jmp    8010876d <trap+0x1dd>
	case T_IRQ0 + IRQ_IDE:
		ideintr();
80108651:	e8 e6 a1 ff ff       	call   8010283c <ideintr>
		lapiceoi();
80108656:	e8 ce a9 ff ff       	call   80103029 <lapiceoi>
		break;
8010865b:	e9 0d 01 00 00       	jmp    8010876d <trap+0x1dd>
	case T_IRQ0 + IRQ_IDE + 1:
		// Bochs generates spurious IDE1 interrupts.
		break;
	case T_IRQ0 + IRQ_KBD:
		kbdintr();
80108660:	e8 c6 a7 ff ff       	call   80102e2b <kbdintr>
		lapiceoi();
80108665:	e8 bf a9 ff ff       	call   80103029 <lapiceoi>
		break;
8010866a:	e9 fe 00 00 00       	jmp    8010876d <trap+0x1dd>
	case T_IRQ0 + IRQ_COM1:
		uartintr();
8010866f:	e8 60 03 00 00       	call   801089d4 <uartintr>
		lapiceoi();
80108674:	e8 b0 a9 ff ff       	call   80103029 <lapiceoi>
		break;
80108679:	e9 ef 00 00 00       	jmp    8010876d <trap+0x1dd>
	case T_IRQ0 + 7:
	case T_IRQ0 + IRQ_SPURIOUS:
		cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010867e:	8b 45 08             	mov    0x8(%ebp),%eax
80108681:	8b 48 38             	mov    0x38(%eax),%ecx
			cpu->id, tf->cs, tf->eip);
80108684:	8b 45 08             	mov    0x8(%ebp),%eax
80108687:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
		uartintr();
		lapiceoi();
		break;
	case T_IRQ0 + 7:
	case T_IRQ0 + IRQ_SPURIOUS:
		cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010868b:	0f b7 d0             	movzwl %ax,%edx
			cpu->id, tf->cs, tf->eip);
8010868e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108694:	0f b6 00             	movzbl (%eax),%eax
		uartintr();
		lapiceoi();
		break;
	case T_IRQ0 + 7:
	case T_IRQ0 + IRQ_SPURIOUS:
		cprintf("cpu%d: spurious interrupt at %x:%x\n",
80108697:	0f b6 c0             	movzbl %al,%eax
8010869a:	51                   	push   %ecx
8010869b:	52                   	push   %edx
8010869c:	50                   	push   %eax
8010869d:	68 e8 ad 10 80       	push   $0x8010ade8
801086a2:	e8 1f 7d ff ff       	call   801003c6 <cprintf>
801086a7:	83 c4 10             	add    $0x10,%esp
			cpu->id, tf->cs, tf->eip);
		lapiceoi();
801086aa:	e8 7a a9 ff ff       	call   80103029 <lapiceoi>
		break;
801086af:	e9 b9 00 00 00       	jmp    8010876d <trap+0x1dd>

		//PAGEBREAK: 13
	default:
		if (proc == 0 || (tf->cs & 3) == 0) {
801086b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801086ba:	85 c0                	test   %eax,%eax
801086bc:	74 11                	je     801086cf <trap+0x13f>
801086be:	8b 45 08             	mov    0x8(%ebp),%eax
801086c1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801086c5:	0f b7 c0             	movzwl %ax,%eax
801086c8:	83 e0 03             	and    $0x3,%eax
801086cb:	85 c0                	test   %eax,%eax
801086cd:	75 40                	jne    8010870f <trap+0x17f>
			// In kernel, it must be our mistake.
			cprintf
801086cf:	e8 1d fd ff ff       	call   801083f1 <rcr2>
801086d4:	89 c3                	mov    %eax,%ebx
801086d6:	8b 45 08             	mov    0x8(%ebp),%eax
801086d9:	8b 48 38             	mov    0x38(%eax),%ecx
			    ("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
			     tf->trapno, cpu->id, tf->eip, rcr2());
801086dc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801086e2:	0f b6 00             	movzbl (%eax),%eax

		//PAGEBREAK: 13
	default:
		if (proc == 0 || (tf->cs & 3) == 0) {
			// In kernel, it must be our mistake.
			cprintf
801086e5:	0f b6 d0             	movzbl %al,%edx
801086e8:	8b 45 08             	mov    0x8(%ebp),%eax
801086eb:	8b 40 30             	mov    0x30(%eax),%eax
801086ee:	83 ec 0c             	sub    $0xc,%esp
801086f1:	53                   	push   %ebx
801086f2:	51                   	push   %ecx
801086f3:	52                   	push   %edx
801086f4:	50                   	push   %eax
801086f5:	68 0c ae 10 80       	push   $0x8010ae0c
801086fa:	e8 c7 7c ff ff       	call   801003c6 <cprintf>
801086ff:	83 c4 20             	add    $0x20,%esp
			    ("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
			     tf->trapno, cpu->id, tf->eip, rcr2());
			panic("trap");
80108702:	83 ec 0c             	sub    $0xc,%esp
80108705:	68 3e ae 10 80       	push   $0x8010ae3e
8010870a:	e8 57 7e ff ff       	call   80100566 <panic>
		}
		// In user space, assume process misbehaved.
		cprintf("pid %d %s: trap %d err %d on cpu %d "
8010870f:	e8 dd fc ff ff       	call   801083f1 <rcr2>
80108714:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80108717:	8b 45 08             	mov    0x8(%ebp),%eax
8010871a:	8b 70 38             	mov    0x38(%eax),%esi
			"eip 0x%x addr 0x%x--kill proc\n",
			proc->pid, proc->name, tf->trapno, tf->err, cpu->id,
8010871d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108723:	0f b6 00             	movzbl (%eax),%eax
			    ("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
			     tf->trapno, cpu->id, tf->eip, rcr2());
			panic("trap");
		}
		// In user space, assume process misbehaved.
		cprintf("pid %d %s: trap %d err %d on cpu %d "
80108726:	0f b6 d8             	movzbl %al,%ebx
80108729:	8b 45 08             	mov    0x8(%ebp),%eax
8010872c:	8b 48 34             	mov    0x34(%eax),%ecx
8010872f:	8b 45 08             	mov    0x8(%ebp),%eax
80108732:	8b 50 30             	mov    0x30(%eax),%edx
			"eip 0x%x addr 0x%x--kill proc\n",
			proc->pid, proc->name, tf->trapno, tf->err, cpu->id,
80108735:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010873b:	8d 78 6c             	lea    0x6c(%eax),%edi
8010873e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
			    ("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
			     tf->trapno, cpu->id, tf->eip, rcr2());
			panic("trap");
		}
		// In user space, assume process misbehaved.
		cprintf("pid %d %s: trap %d err %d on cpu %d "
80108744:	8b 40 10             	mov    0x10(%eax),%eax
80108747:	ff 75 e4             	pushl  -0x1c(%ebp)
8010874a:	56                   	push   %esi
8010874b:	53                   	push   %ebx
8010874c:	51                   	push   %ecx
8010874d:	52                   	push   %edx
8010874e:	57                   	push   %edi
8010874f:	50                   	push   %eax
80108750:	68 44 ae 10 80       	push   $0x8010ae44
80108755:	e8 6c 7c ff ff       	call   801003c6 <cprintf>
8010875a:	83 c4 20             	add    $0x20,%esp
			"eip 0x%x addr 0x%x--kill proc\n",
			proc->pid, proc->name, tf->trapno, tf->err, cpu->id,
			tf->eip, rcr2());
		proc->killed = 1;
8010875d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108763:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010876a:	eb 01                	jmp    8010876d <trap+0x1dd>
		ideintr();
		lapiceoi();
		break;
	case T_IRQ0 + IRQ_IDE + 1:
		// Bochs generates spurious IDE1 interrupts.
		break;
8010876c:	90                   	nop
	}

	// Force process exit if it has been killed and is in user space.
	// (If it is still executing in the kernel, let it keep running 
	// until it gets to the regular system call return.)
	if (proc && proc->killed && (tf->cs & 3) == DPL_USER)
8010876d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108773:	85 c0                	test   %eax,%eax
80108775:	74 24                	je     8010879b <trap+0x20b>
80108777:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010877d:	8b 40 24             	mov    0x24(%eax),%eax
80108780:	85 c0                	test   %eax,%eax
80108782:	74 17                	je     8010879b <trap+0x20b>
80108784:	8b 45 08             	mov    0x8(%ebp),%eax
80108787:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010878b:	0f b7 c0             	movzwl %ax,%eax
8010878e:	83 e0 03             	and    $0x3,%eax
80108791:	83 f8 03             	cmp    $0x3,%eax
80108794:	75 05                	jne    8010879b <trap+0x20b>
		exit();
80108796:	e8 3b d5 ff ff       	call   80105cd6 <exit>

	// Force process to give up CPU on clock tick.
	// If interrupts were on while locks held, would need to check nlock.
	if (proc && proc->state == RUNNING && tf->trapno == T_IRQ0 + IRQ_TIMER)
8010879b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801087a1:	85 c0                	test   %eax,%eax
801087a3:	74 1e                	je     801087c3 <trap+0x233>
801087a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801087ab:	8b 40 0c             	mov    0xc(%eax),%eax
801087ae:	83 f8 04             	cmp    $0x4,%eax
801087b1:	75 10                	jne    801087c3 <trap+0x233>
801087b3:	8b 45 08             	mov    0x8(%ebp),%eax
801087b6:	8b 40 30             	mov    0x30(%eax),%eax
801087b9:	83 f8 20             	cmp    $0x20,%eax
801087bc:	75 05                	jne    801087c3 <trap+0x233>
		yield();
801087be:	e8 b2 d9 ff ff       	call   80106175 <yield>

	// Check if the process has been killed since we yielded
	if (proc && proc->killed && (tf->cs & 3) == DPL_USER)
801087c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801087c9:	85 c0                	test   %eax,%eax
801087cb:	74 27                	je     801087f4 <trap+0x264>
801087cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801087d3:	8b 40 24             	mov    0x24(%eax),%eax
801087d6:	85 c0                	test   %eax,%eax
801087d8:	74 1a                	je     801087f4 <trap+0x264>
801087da:	8b 45 08             	mov    0x8(%ebp),%eax
801087dd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801087e1:	0f b7 c0             	movzwl %ax,%eax
801087e4:	83 e0 03             	and    $0x3,%eax
801087e7:	83 f8 03             	cmp    $0x3,%eax
801087ea:	75 08                	jne    801087f4 <trap+0x264>
		exit();
801087ec:	e8 e5 d4 ff ff       	call   80105cd6 <exit>
801087f1:	eb 01                	jmp    801087f4 <trap+0x264>
			exit();
		proc->tf = tf;
		syscall();
		if (proc->killed)
			exit();
		return;
801087f3:	90                   	nop
		yield();

	// Check if the process has been killed since we yielded
	if (proc && proc->killed && (tf->cs & 3) == DPL_USER)
		exit();
}
801087f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801087f7:	5b                   	pop    %ebx
801087f8:	5e                   	pop    %esi
801087f9:	5f                   	pop    %edi
801087fa:	5d                   	pop    %ebp
801087fb:	c3                   	ret    

801087fc <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801087fc:	55                   	push   %ebp
801087fd:	89 e5                	mov    %esp,%ebp
801087ff:	83 ec 14             	sub    $0x14,%esp
80108802:	8b 45 08             	mov    0x8(%ebp),%eax
80108805:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108809:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010880d:	89 c2                	mov    %eax,%edx
8010880f:	ec                   	in     (%dx),%al
80108810:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108813:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108817:	c9                   	leave  
80108818:	c3                   	ret    

80108819 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80108819:	55                   	push   %ebp
8010881a:	89 e5                	mov    %esp,%ebp
8010881c:	83 ec 08             	sub    $0x8,%esp
8010881f:	8b 55 08             	mov    0x8(%ebp),%edx
80108822:	8b 45 0c             	mov    0xc(%ebp),%eax
80108825:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80108829:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010882c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108830:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108834:	ee                   	out    %al,(%dx)
}
80108835:	90                   	nop
80108836:	c9                   	leave  
80108837:	c3                   	ret    

80108838 <uartinit>:
#define COM1    0x3f8

static int uart;		// is there a uart?

void uartinit(void)
{
80108838:	55                   	push   %ebp
80108839:	89 e5                	mov    %esp,%ebp
8010883b:	83 ec 18             	sub    $0x18,%esp
	char *p;

	// Turn off the FIFO
	outb(COM1 + 2, 0);
8010883e:	6a 00                	push   $0x0
80108840:	68 fa 03 00 00       	push   $0x3fa
80108845:	e8 cf ff ff ff       	call   80108819 <outb>
8010884a:	83 c4 08             	add    $0x8,%esp

	// 9600 baud, 8 data bits, 1 stop bit, parity off.
	outb(COM1 + 3, 0x80);	// Unlock divisor
8010884d:	68 80 00 00 00       	push   $0x80
80108852:	68 fb 03 00 00       	push   $0x3fb
80108857:	e8 bd ff ff ff       	call   80108819 <outb>
8010885c:	83 c4 08             	add    $0x8,%esp
	outb(COM1 + 0, 115200 / 9600);
8010885f:	6a 0c                	push   $0xc
80108861:	68 f8 03 00 00       	push   $0x3f8
80108866:	e8 ae ff ff ff       	call   80108819 <outb>
8010886b:	83 c4 08             	add    $0x8,%esp
	outb(COM1 + 1, 0);
8010886e:	6a 00                	push   $0x0
80108870:	68 f9 03 00 00       	push   $0x3f9
80108875:	e8 9f ff ff ff       	call   80108819 <outb>
8010887a:	83 c4 08             	add    $0x8,%esp
	outb(COM1 + 3, 0x03);	// Lock divisor, 8 data bits.
8010887d:	6a 03                	push   $0x3
8010887f:	68 fb 03 00 00       	push   $0x3fb
80108884:	e8 90 ff ff ff       	call   80108819 <outb>
80108889:	83 c4 08             	add    $0x8,%esp
	outb(COM1 + 4, 0);
8010888c:	6a 00                	push   $0x0
8010888e:	68 fc 03 00 00       	push   $0x3fc
80108893:	e8 81 ff ff ff       	call   80108819 <outb>
80108898:	83 c4 08             	add    $0x8,%esp
	outb(COM1 + 1, 0x01);	// Enable receive interrupts.
8010889b:	6a 01                	push   $0x1
8010889d:	68 f9 03 00 00       	push   $0x3f9
801088a2:	e8 72 ff ff ff       	call   80108819 <outb>
801088a7:	83 c4 08             	add    $0x8,%esp

	// If status is 0xFF, no serial port.
	if (inb(COM1 + 5) == 0xFF)
801088aa:	68 fd 03 00 00       	push   $0x3fd
801088af:	e8 48 ff ff ff       	call   801087fc <inb>
801088b4:	83 c4 04             	add    $0x4,%esp
801088b7:	3c ff                	cmp    $0xff,%al
801088b9:	74 6e                	je     80108929 <uartinit+0xf1>
		return;
	uart = 1;
801088bb:	c7 05 6c e6 10 80 01 	movl   $0x1,0x8010e66c
801088c2:	00 00 00 

	// Acknowledge pre-existing interrupt conditions;
	// enable interrupts.
	inb(COM1 + 2);
801088c5:	68 fa 03 00 00       	push   $0x3fa
801088ca:	e8 2d ff ff ff       	call   801087fc <inb>
801088cf:	83 c4 04             	add    $0x4,%esp
	inb(COM1 + 0);
801088d2:	68 f8 03 00 00       	push   $0x3f8
801088d7:	e8 20 ff ff ff       	call   801087fc <inb>
801088dc:	83 c4 04             	add    $0x4,%esp
	picenable(IRQ_COM1);
801088df:	83 ec 0c             	sub    $0xc,%esp
801088e2:	6a 04                	push   $0x4
801088e4:	e8 55 c8 ff ff       	call   8010513e <picenable>
801088e9:	83 c4 10             	add    $0x10,%esp
	ioapicenable(IRQ_COM1, 0);
801088ec:	83 ec 08             	sub    $0x8,%esp
801088ef:	6a 00                	push   $0x0
801088f1:	6a 04                	push   $0x4
801088f3:	e8 e6 a1 ff ff       	call   80102ade <ioapicenable>
801088f8:	83 c4 10             	add    $0x10,%esp

	// Announce that we're here.
	for (p = "xv6...\n"; *p; p++)
801088fb:	c7 45 f4 08 af 10 80 	movl   $0x8010af08,-0xc(%ebp)
80108902:	eb 19                	jmp    8010891d <uartinit+0xe5>
		uartputc(*p);
80108904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108907:	0f b6 00             	movzbl (%eax),%eax
8010890a:	0f be c0             	movsbl %al,%eax
8010890d:	83 ec 0c             	sub    $0xc,%esp
80108910:	50                   	push   %eax
80108911:	e8 16 00 00 00       	call   8010892c <uartputc>
80108916:	83 c4 10             	add    $0x10,%esp
	inb(COM1 + 0);
	picenable(IRQ_COM1);
	ioapicenable(IRQ_COM1, 0);

	// Announce that we're here.
	for (p = "xv6...\n"; *p; p++)
80108919:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010891d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108920:	0f b6 00             	movzbl (%eax),%eax
80108923:	84 c0                	test   %al,%al
80108925:	75 dd                	jne    80108904 <uartinit+0xcc>
80108927:	eb 01                	jmp    8010892a <uartinit+0xf2>
	outb(COM1 + 4, 0);
	outb(COM1 + 1, 0x01);	// Enable receive interrupts.

	// If status is 0xFF, no serial port.
	if (inb(COM1 + 5) == 0xFF)
		return;
80108929:	90                   	nop
	ioapicenable(IRQ_COM1, 0);

	// Announce that we're here.
	for (p = "xv6...\n"; *p; p++)
		uartputc(*p);
}
8010892a:	c9                   	leave  
8010892b:	c3                   	ret    

8010892c <uartputc>:

void uartputc(int c)
{
8010892c:	55                   	push   %ebp
8010892d:	89 e5                	mov    %esp,%ebp
8010892f:	83 ec 18             	sub    $0x18,%esp
	int i;

	if (!uart)
80108932:	a1 6c e6 10 80       	mov    0x8010e66c,%eax
80108937:	85 c0                	test   %eax,%eax
80108939:	74 53                	je     8010898e <uartputc+0x62>
		return;
	for (i = 0; i < 128 && !(inb(COM1 + 5) & 0x20); i++)
8010893b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108942:	eb 11                	jmp    80108955 <uartputc+0x29>
		microdelay(10);
80108944:	83 ec 0c             	sub    $0xc,%esp
80108947:	6a 0a                	push   $0xa
80108949:	e8 f6 a6 ff ff       	call   80103044 <microdelay>
8010894e:	83 c4 10             	add    $0x10,%esp
{
	int i;

	if (!uart)
		return;
	for (i = 0; i < 128 && !(inb(COM1 + 5) & 0x20); i++)
80108951:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108955:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108959:	7f 1a                	jg     80108975 <uartputc+0x49>
8010895b:	83 ec 0c             	sub    $0xc,%esp
8010895e:	68 fd 03 00 00       	push   $0x3fd
80108963:	e8 94 fe ff ff       	call   801087fc <inb>
80108968:	83 c4 10             	add    $0x10,%esp
8010896b:	0f b6 c0             	movzbl %al,%eax
8010896e:	83 e0 20             	and    $0x20,%eax
80108971:	85 c0                	test   %eax,%eax
80108973:	74 cf                	je     80108944 <uartputc+0x18>
		microdelay(10);
	outb(COM1 + 0, c);
80108975:	8b 45 08             	mov    0x8(%ebp),%eax
80108978:	0f b6 c0             	movzbl %al,%eax
8010897b:	83 ec 08             	sub    $0x8,%esp
8010897e:	50                   	push   %eax
8010897f:	68 f8 03 00 00       	push   $0x3f8
80108984:	e8 90 fe ff ff       	call   80108819 <outb>
80108989:	83 c4 10             	add    $0x10,%esp
8010898c:	eb 01                	jmp    8010898f <uartputc+0x63>
void uartputc(int c)
{
	int i;

	if (!uart)
		return;
8010898e:	90                   	nop
	for (i = 0; i < 128 && !(inb(COM1 + 5) & 0x20); i++)
		microdelay(10);
	outb(COM1 + 0, c);
}
8010898f:	c9                   	leave  
80108990:	c3                   	ret    

80108991 <uartgetc>:

static int uartgetc(void)
{
80108991:	55                   	push   %ebp
80108992:	89 e5                	mov    %esp,%ebp
	if (!uart)
80108994:	a1 6c e6 10 80       	mov    0x8010e66c,%eax
80108999:	85 c0                	test   %eax,%eax
8010899b:	75 07                	jne    801089a4 <uartgetc+0x13>
		return -1;
8010899d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801089a2:	eb 2e                	jmp    801089d2 <uartgetc+0x41>
	if (!(inb(COM1 + 5) & 0x01))
801089a4:	68 fd 03 00 00       	push   $0x3fd
801089a9:	e8 4e fe ff ff       	call   801087fc <inb>
801089ae:	83 c4 04             	add    $0x4,%esp
801089b1:	0f b6 c0             	movzbl %al,%eax
801089b4:	83 e0 01             	and    $0x1,%eax
801089b7:	85 c0                	test   %eax,%eax
801089b9:	75 07                	jne    801089c2 <uartgetc+0x31>
		return -1;
801089bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801089c0:	eb 10                	jmp    801089d2 <uartgetc+0x41>
	return inb(COM1 + 0);
801089c2:	68 f8 03 00 00       	push   $0x3f8
801089c7:	e8 30 fe ff ff       	call   801087fc <inb>
801089cc:	83 c4 04             	add    $0x4,%esp
801089cf:	0f b6 c0             	movzbl %al,%eax
}
801089d2:	c9                   	leave  
801089d3:	c3                   	ret    

801089d4 <uartintr>:

void uartintr(void)
{
801089d4:	55                   	push   %ebp
801089d5:	89 e5                	mov    %esp,%ebp
801089d7:	83 ec 08             	sub    $0x8,%esp
	consoleintr(uartgetc);
801089da:	83 ec 0c             	sub    $0xc,%esp
801089dd:	68 91 89 10 80       	push   $0x80108991
801089e2:	e8 12 7e ff ff       	call   801007f9 <consoleintr>
801089e7:	83 c4 10             	add    $0x10,%esp
}
801089ea:	90                   	nop
801089eb:	c9                   	leave  
801089ec:	c3                   	ret    

801089ed <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801089ed:	6a 00                	push   $0x0
  pushl $0
801089ef:	6a 00                	push   $0x0
  jmp alltraps
801089f1:	e9 a6 f9 ff ff       	jmp    8010839c <alltraps>

801089f6 <vector1>:
.globl vector1
vector1:
  pushl $0
801089f6:	6a 00                	push   $0x0
  pushl $1
801089f8:	6a 01                	push   $0x1
  jmp alltraps
801089fa:	e9 9d f9 ff ff       	jmp    8010839c <alltraps>

801089ff <vector2>:
.globl vector2
vector2:
  pushl $0
801089ff:	6a 00                	push   $0x0
  pushl $2
80108a01:	6a 02                	push   $0x2
  jmp alltraps
80108a03:	e9 94 f9 ff ff       	jmp    8010839c <alltraps>

80108a08 <vector3>:
.globl vector3
vector3:
  pushl $0
80108a08:	6a 00                	push   $0x0
  pushl $3
80108a0a:	6a 03                	push   $0x3
  jmp alltraps
80108a0c:	e9 8b f9 ff ff       	jmp    8010839c <alltraps>

80108a11 <vector4>:
.globl vector4
vector4:
  pushl $0
80108a11:	6a 00                	push   $0x0
  pushl $4
80108a13:	6a 04                	push   $0x4
  jmp alltraps
80108a15:	e9 82 f9 ff ff       	jmp    8010839c <alltraps>

80108a1a <vector5>:
.globl vector5
vector5:
  pushl $0
80108a1a:	6a 00                	push   $0x0
  pushl $5
80108a1c:	6a 05                	push   $0x5
  jmp alltraps
80108a1e:	e9 79 f9 ff ff       	jmp    8010839c <alltraps>

80108a23 <vector6>:
.globl vector6
vector6:
  pushl $0
80108a23:	6a 00                	push   $0x0
  pushl $6
80108a25:	6a 06                	push   $0x6
  jmp alltraps
80108a27:	e9 70 f9 ff ff       	jmp    8010839c <alltraps>

80108a2c <vector7>:
.globl vector7
vector7:
  pushl $0
80108a2c:	6a 00                	push   $0x0
  pushl $7
80108a2e:	6a 07                	push   $0x7
  jmp alltraps
80108a30:	e9 67 f9 ff ff       	jmp    8010839c <alltraps>

80108a35 <vector8>:
.globl vector8
vector8:
  pushl $8
80108a35:	6a 08                	push   $0x8
  jmp alltraps
80108a37:	e9 60 f9 ff ff       	jmp    8010839c <alltraps>

80108a3c <vector9>:
.globl vector9
vector9:
  pushl $0
80108a3c:	6a 00                	push   $0x0
  pushl $9
80108a3e:	6a 09                	push   $0x9
  jmp alltraps
80108a40:	e9 57 f9 ff ff       	jmp    8010839c <alltraps>

80108a45 <vector10>:
.globl vector10
vector10:
  pushl $10
80108a45:	6a 0a                	push   $0xa
  jmp alltraps
80108a47:	e9 50 f9 ff ff       	jmp    8010839c <alltraps>

80108a4c <vector11>:
.globl vector11
vector11:
  pushl $11
80108a4c:	6a 0b                	push   $0xb
  jmp alltraps
80108a4e:	e9 49 f9 ff ff       	jmp    8010839c <alltraps>

80108a53 <vector12>:
.globl vector12
vector12:
  pushl $12
80108a53:	6a 0c                	push   $0xc
  jmp alltraps
80108a55:	e9 42 f9 ff ff       	jmp    8010839c <alltraps>

80108a5a <vector13>:
.globl vector13
vector13:
  pushl $13
80108a5a:	6a 0d                	push   $0xd
  jmp alltraps
80108a5c:	e9 3b f9 ff ff       	jmp    8010839c <alltraps>

80108a61 <vector14>:
.globl vector14
vector14:
  pushl $14
80108a61:	6a 0e                	push   $0xe
  jmp alltraps
80108a63:	e9 34 f9 ff ff       	jmp    8010839c <alltraps>

80108a68 <vector15>:
.globl vector15
vector15:
  pushl $0
80108a68:	6a 00                	push   $0x0
  pushl $15
80108a6a:	6a 0f                	push   $0xf
  jmp alltraps
80108a6c:	e9 2b f9 ff ff       	jmp    8010839c <alltraps>

80108a71 <vector16>:
.globl vector16
vector16:
  pushl $0
80108a71:	6a 00                	push   $0x0
  pushl $16
80108a73:	6a 10                	push   $0x10
  jmp alltraps
80108a75:	e9 22 f9 ff ff       	jmp    8010839c <alltraps>

80108a7a <vector17>:
.globl vector17
vector17:
  pushl $17
80108a7a:	6a 11                	push   $0x11
  jmp alltraps
80108a7c:	e9 1b f9 ff ff       	jmp    8010839c <alltraps>

80108a81 <vector18>:
.globl vector18
vector18:
  pushl $0
80108a81:	6a 00                	push   $0x0
  pushl $18
80108a83:	6a 12                	push   $0x12
  jmp alltraps
80108a85:	e9 12 f9 ff ff       	jmp    8010839c <alltraps>

80108a8a <vector19>:
.globl vector19
vector19:
  pushl $0
80108a8a:	6a 00                	push   $0x0
  pushl $19
80108a8c:	6a 13                	push   $0x13
  jmp alltraps
80108a8e:	e9 09 f9 ff ff       	jmp    8010839c <alltraps>

80108a93 <vector20>:
.globl vector20
vector20:
  pushl $0
80108a93:	6a 00                	push   $0x0
  pushl $20
80108a95:	6a 14                	push   $0x14
  jmp alltraps
80108a97:	e9 00 f9 ff ff       	jmp    8010839c <alltraps>

80108a9c <vector21>:
.globl vector21
vector21:
  pushl $0
80108a9c:	6a 00                	push   $0x0
  pushl $21
80108a9e:	6a 15                	push   $0x15
  jmp alltraps
80108aa0:	e9 f7 f8 ff ff       	jmp    8010839c <alltraps>

80108aa5 <vector22>:
.globl vector22
vector22:
  pushl $0
80108aa5:	6a 00                	push   $0x0
  pushl $22
80108aa7:	6a 16                	push   $0x16
  jmp alltraps
80108aa9:	e9 ee f8 ff ff       	jmp    8010839c <alltraps>

80108aae <vector23>:
.globl vector23
vector23:
  pushl $0
80108aae:	6a 00                	push   $0x0
  pushl $23
80108ab0:	6a 17                	push   $0x17
  jmp alltraps
80108ab2:	e9 e5 f8 ff ff       	jmp    8010839c <alltraps>

80108ab7 <vector24>:
.globl vector24
vector24:
  pushl $0
80108ab7:	6a 00                	push   $0x0
  pushl $24
80108ab9:	6a 18                	push   $0x18
  jmp alltraps
80108abb:	e9 dc f8 ff ff       	jmp    8010839c <alltraps>

80108ac0 <vector25>:
.globl vector25
vector25:
  pushl $0
80108ac0:	6a 00                	push   $0x0
  pushl $25
80108ac2:	6a 19                	push   $0x19
  jmp alltraps
80108ac4:	e9 d3 f8 ff ff       	jmp    8010839c <alltraps>

80108ac9 <vector26>:
.globl vector26
vector26:
  pushl $0
80108ac9:	6a 00                	push   $0x0
  pushl $26
80108acb:	6a 1a                	push   $0x1a
  jmp alltraps
80108acd:	e9 ca f8 ff ff       	jmp    8010839c <alltraps>

80108ad2 <vector27>:
.globl vector27
vector27:
  pushl $0
80108ad2:	6a 00                	push   $0x0
  pushl $27
80108ad4:	6a 1b                	push   $0x1b
  jmp alltraps
80108ad6:	e9 c1 f8 ff ff       	jmp    8010839c <alltraps>

80108adb <vector28>:
.globl vector28
vector28:
  pushl $0
80108adb:	6a 00                	push   $0x0
  pushl $28
80108add:	6a 1c                	push   $0x1c
  jmp alltraps
80108adf:	e9 b8 f8 ff ff       	jmp    8010839c <alltraps>

80108ae4 <vector29>:
.globl vector29
vector29:
  pushl $0
80108ae4:	6a 00                	push   $0x0
  pushl $29
80108ae6:	6a 1d                	push   $0x1d
  jmp alltraps
80108ae8:	e9 af f8 ff ff       	jmp    8010839c <alltraps>

80108aed <vector30>:
.globl vector30
vector30:
  pushl $0
80108aed:	6a 00                	push   $0x0
  pushl $30
80108aef:	6a 1e                	push   $0x1e
  jmp alltraps
80108af1:	e9 a6 f8 ff ff       	jmp    8010839c <alltraps>

80108af6 <vector31>:
.globl vector31
vector31:
  pushl $0
80108af6:	6a 00                	push   $0x0
  pushl $31
80108af8:	6a 1f                	push   $0x1f
  jmp alltraps
80108afa:	e9 9d f8 ff ff       	jmp    8010839c <alltraps>

80108aff <vector32>:
.globl vector32
vector32:
  pushl $0
80108aff:	6a 00                	push   $0x0
  pushl $32
80108b01:	6a 20                	push   $0x20
  jmp alltraps
80108b03:	e9 94 f8 ff ff       	jmp    8010839c <alltraps>

80108b08 <vector33>:
.globl vector33
vector33:
  pushl $0
80108b08:	6a 00                	push   $0x0
  pushl $33
80108b0a:	6a 21                	push   $0x21
  jmp alltraps
80108b0c:	e9 8b f8 ff ff       	jmp    8010839c <alltraps>

80108b11 <vector34>:
.globl vector34
vector34:
  pushl $0
80108b11:	6a 00                	push   $0x0
  pushl $34
80108b13:	6a 22                	push   $0x22
  jmp alltraps
80108b15:	e9 82 f8 ff ff       	jmp    8010839c <alltraps>

80108b1a <vector35>:
.globl vector35
vector35:
  pushl $0
80108b1a:	6a 00                	push   $0x0
  pushl $35
80108b1c:	6a 23                	push   $0x23
  jmp alltraps
80108b1e:	e9 79 f8 ff ff       	jmp    8010839c <alltraps>

80108b23 <vector36>:
.globl vector36
vector36:
  pushl $0
80108b23:	6a 00                	push   $0x0
  pushl $36
80108b25:	6a 24                	push   $0x24
  jmp alltraps
80108b27:	e9 70 f8 ff ff       	jmp    8010839c <alltraps>

80108b2c <vector37>:
.globl vector37
vector37:
  pushl $0
80108b2c:	6a 00                	push   $0x0
  pushl $37
80108b2e:	6a 25                	push   $0x25
  jmp alltraps
80108b30:	e9 67 f8 ff ff       	jmp    8010839c <alltraps>

80108b35 <vector38>:
.globl vector38
vector38:
  pushl $0
80108b35:	6a 00                	push   $0x0
  pushl $38
80108b37:	6a 26                	push   $0x26
  jmp alltraps
80108b39:	e9 5e f8 ff ff       	jmp    8010839c <alltraps>

80108b3e <vector39>:
.globl vector39
vector39:
  pushl $0
80108b3e:	6a 00                	push   $0x0
  pushl $39
80108b40:	6a 27                	push   $0x27
  jmp alltraps
80108b42:	e9 55 f8 ff ff       	jmp    8010839c <alltraps>

80108b47 <vector40>:
.globl vector40
vector40:
  pushl $0
80108b47:	6a 00                	push   $0x0
  pushl $40
80108b49:	6a 28                	push   $0x28
  jmp alltraps
80108b4b:	e9 4c f8 ff ff       	jmp    8010839c <alltraps>

80108b50 <vector41>:
.globl vector41
vector41:
  pushl $0
80108b50:	6a 00                	push   $0x0
  pushl $41
80108b52:	6a 29                	push   $0x29
  jmp alltraps
80108b54:	e9 43 f8 ff ff       	jmp    8010839c <alltraps>

80108b59 <vector42>:
.globl vector42
vector42:
  pushl $0
80108b59:	6a 00                	push   $0x0
  pushl $42
80108b5b:	6a 2a                	push   $0x2a
  jmp alltraps
80108b5d:	e9 3a f8 ff ff       	jmp    8010839c <alltraps>

80108b62 <vector43>:
.globl vector43
vector43:
  pushl $0
80108b62:	6a 00                	push   $0x0
  pushl $43
80108b64:	6a 2b                	push   $0x2b
  jmp alltraps
80108b66:	e9 31 f8 ff ff       	jmp    8010839c <alltraps>

80108b6b <vector44>:
.globl vector44
vector44:
  pushl $0
80108b6b:	6a 00                	push   $0x0
  pushl $44
80108b6d:	6a 2c                	push   $0x2c
  jmp alltraps
80108b6f:	e9 28 f8 ff ff       	jmp    8010839c <alltraps>

80108b74 <vector45>:
.globl vector45
vector45:
  pushl $0
80108b74:	6a 00                	push   $0x0
  pushl $45
80108b76:	6a 2d                	push   $0x2d
  jmp alltraps
80108b78:	e9 1f f8 ff ff       	jmp    8010839c <alltraps>

80108b7d <vector46>:
.globl vector46
vector46:
  pushl $0
80108b7d:	6a 00                	push   $0x0
  pushl $46
80108b7f:	6a 2e                	push   $0x2e
  jmp alltraps
80108b81:	e9 16 f8 ff ff       	jmp    8010839c <alltraps>

80108b86 <vector47>:
.globl vector47
vector47:
  pushl $0
80108b86:	6a 00                	push   $0x0
  pushl $47
80108b88:	6a 2f                	push   $0x2f
  jmp alltraps
80108b8a:	e9 0d f8 ff ff       	jmp    8010839c <alltraps>

80108b8f <vector48>:
.globl vector48
vector48:
  pushl $0
80108b8f:	6a 00                	push   $0x0
  pushl $48
80108b91:	6a 30                	push   $0x30
  jmp alltraps
80108b93:	e9 04 f8 ff ff       	jmp    8010839c <alltraps>

80108b98 <vector49>:
.globl vector49
vector49:
  pushl $0
80108b98:	6a 00                	push   $0x0
  pushl $49
80108b9a:	6a 31                	push   $0x31
  jmp alltraps
80108b9c:	e9 fb f7 ff ff       	jmp    8010839c <alltraps>

80108ba1 <vector50>:
.globl vector50
vector50:
  pushl $0
80108ba1:	6a 00                	push   $0x0
  pushl $50
80108ba3:	6a 32                	push   $0x32
  jmp alltraps
80108ba5:	e9 f2 f7 ff ff       	jmp    8010839c <alltraps>

80108baa <vector51>:
.globl vector51
vector51:
  pushl $0
80108baa:	6a 00                	push   $0x0
  pushl $51
80108bac:	6a 33                	push   $0x33
  jmp alltraps
80108bae:	e9 e9 f7 ff ff       	jmp    8010839c <alltraps>

80108bb3 <vector52>:
.globl vector52
vector52:
  pushl $0
80108bb3:	6a 00                	push   $0x0
  pushl $52
80108bb5:	6a 34                	push   $0x34
  jmp alltraps
80108bb7:	e9 e0 f7 ff ff       	jmp    8010839c <alltraps>

80108bbc <vector53>:
.globl vector53
vector53:
  pushl $0
80108bbc:	6a 00                	push   $0x0
  pushl $53
80108bbe:	6a 35                	push   $0x35
  jmp alltraps
80108bc0:	e9 d7 f7 ff ff       	jmp    8010839c <alltraps>

80108bc5 <vector54>:
.globl vector54
vector54:
  pushl $0
80108bc5:	6a 00                	push   $0x0
  pushl $54
80108bc7:	6a 36                	push   $0x36
  jmp alltraps
80108bc9:	e9 ce f7 ff ff       	jmp    8010839c <alltraps>

80108bce <vector55>:
.globl vector55
vector55:
  pushl $0
80108bce:	6a 00                	push   $0x0
  pushl $55
80108bd0:	6a 37                	push   $0x37
  jmp alltraps
80108bd2:	e9 c5 f7 ff ff       	jmp    8010839c <alltraps>

80108bd7 <vector56>:
.globl vector56
vector56:
  pushl $0
80108bd7:	6a 00                	push   $0x0
  pushl $56
80108bd9:	6a 38                	push   $0x38
  jmp alltraps
80108bdb:	e9 bc f7 ff ff       	jmp    8010839c <alltraps>

80108be0 <vector57>:
.globl vector57
vector57:
  pushl $0
80108be0:	6a 00                	push   $0x0
  pushl $57
80108be2:	6a 39                	push   $0x39
  jmp alltraps
80108be4:	e9 b3 f7 ff ff       	jmp    8010839c <alltraps>

80108be9 <vector58>:
.globl vector58
vector58:
  pushl $0
80108be9:	6a 00                	push   $0x0
  pushl $58
80108beb:	6a 3a                	push   $0x3a
  jmp alltraps
80108bed:	e9 aa f7 ff ff       	jmp    8010839c <alltraps>

80108bf2 <vector59>:
.globl vector59
vector59:
  pushl $0
80108bf2:	6a 00                	push   $0x0
  pushl $59
80108bf4:	6a 3b                	push   $0x3b
  jmp alltraps
80108bf6:	e9 a1 f7 ff ff       	jmp    8010839c <alltraps>

80108bfb <vector60>:
.globl vector60
vector60:
  pushl $0
80108bfb:	6a 00                	push   $0x0
  pushl $60
80108bfd:	6a 3c                	push   $0x3c
  jmp alltraps
80108bff:	e9 98 f7 ff ff       	jmp    8010839c <alltraps>

80108c04 <vector61>:
.globl vector61
vector61:
  pushl $0
80108c04:	6a 00                	push   $0x0
  pushl $61
80108c06:	6a 3d                	push   $0x3d
  jmp alltraps
80108c08:	e9 8f f7 ff ff       	jmp    8010839c <alltraps>

80108c0d <vector62>:
.globl vector62
vector62:
  pushl $0
80108c0d:	6a 00                	push   $0x0
  pushl $62
80108c0f:	6a 3e                	push   $0x3e
  jmp alltraps
80108c11:	e9 86 f7 ff ff       	jmp    8010839c <alltraps>

80108c16 <vector63>:
.globl vector63
vector63:
  pushl $0
80108c16:	6a 00                	push   $0x0
  pushl $63
80108c18:	6a 3f                	push   $0x3f
  jmp alltraps
80108c1a:	e9 7d f7 ff ff       	jmp    8010839c <alltraps>

80108c1f <vector64>:
.globl vector64
vector64:
  pushl $0
80108c1f:	6a 00                	push   $0x0
  pushl $64
80108c21:	6a 40                	push   $0x40
  jmp alltraps
80108c23:	e9 74 f7 ff ff       	jmp    8010839c <alltraps>

80108c28 <vector65>:
.globl vector65
vector65:
  pushl $0
80108c28:	6a 00                	push   $0x0
  pushl $65
80108c2a:	6a 41                	push   $0x41
  jmp alltraps
80108c2c:	e9 6b f7 ff ff       	jmp    8010839c <alltraps>

80108c31 <vector66>:
.globl vector66
vector66:
  pushl $0
80108c31:	6a 00                	push   $0x0
  pushl $66
80108c33:	6a 42                	push   $0x42
  jmp alltraps
80108c35:	e9 62 f7 ff ff       	jmp    8010839c <alltraps>

80108c3a <vector67>:
.globl vector67
vector67:
  pushl $0
80108c3a:	6a 00                	push   $0x0
  pushl $67
80108c3c:	6a 43                	push   $0x43
  jmp alltraps
80108c3e:	e9 59 f7 ff ff       	jmp    8010839c <alltraps>

80108c43 <vector68>:
.globl vector68
vector68:
  pushl $0
80108c43:	6a 00                	push   $0x0
  pushl $68
80108c45:	6a 44                	push   $0x44
  jmp alltraps
80108c47:	e9 50 f7 ff ff       	jmp    8010839c <alltraps>

80108c4c <vector69>:
.globl vector69
vector69:
  pushl $0
80108c4c:	6a 00                	push   $0x0
  pushl $69
80108c4e:	6a 45                	push   $0x45
  jmp alltraps
80108c50:	e9 47 f7 ff ff       	jmp    8010839c <alltraps>

80108c55 <vector70>:
.globl vector70
vector70:
  pushl $0
80108c55:	6a 00                	push   $0x0
  pushl $70
80108c57:	6a 46                	push   $0x46
  jmp alltraps
80108c59:	e9 3e f7 ff ff       	jmp    8010839c <alltraps>

80108c5e <vector71>:
.globl vector71
vector71:
  pushl $0
80108c5e:	6a 00                	push   $0x0
  pushl $71
80108c60:	6a 47                	push   $0x47
  jmp alltraps
80108c62:	e9 35 f7 ff ff       	jmp    8010839c <alltraps>

80108c67 <vector72>:
.globl vector72
vector72:
  pushl $0
80108c67:	6a 00                	push   $0x0
  pushl $72
80108c69:	6a 48                	push   $0x48
  jmp alltraps
80108c6b:	e9 2c f7 ff ff       	jmp    8010839c <alltraps>

80108c70 <vector73>:
.globl vector73
vector73:
  pushl $0
80108c70:	6a 00                	push   $0x0
  pushl $73
80108c72:	6a 49                	push   $0x49
  jmp alltraps
80108c74:	e9 23 f7 ff ff       	jmp    8010839c <alltraps>

80108c79 <vector74>:
.globl vector74
vector74:
  pushl $0
80108c79:	6a 00                	push   $0x0
  pushl $74
80108c7b:	6a 4a                	push   $0x4a
  jmp alltraps
80108c7d:	e9 1a f7 ff ff       	jmp    8010839c <alltraps>

80108c82 <vector75>:
.globl vector75
vector75:
  pushl $0
80108c82:	6a 00                	push   $0x0
  pushl $75
80108c84:	6a 4b                	push   $0x4b
  jmp alltraps
80108c86:	e9 11 f7 ff ff       	jmp    8010839c <alltraps>

80108c8b <vector76>:
.globl vector76
vector76:
  pushl $0
80108c8b:	6a 00                	push   $0x0
  pushl $76
80108c8d:	6a 4c                	push   $0x4c
  jmp alltraps
80108c8f:	e9 08 f7 ff ff       	jmp    8010839c <alltraps>

80108c94 <vector77>:
.globl vector77
vector77:
  pushl $0
80108c94:	6a 00                	push   $0x0
  pushl $77
80108c96:	6a 4d                	push   $0x4d
  jmp alltraps
80108c98:	e9 ff f6 ff ff       	jmp    8010839c <alltraps>

80108c9d <vector78>:
.globl vector78
vector78:
  pushl $0
80108c9d:	6a 00                	push   $0x0
  pushl $78
80108c9f:	6a 4e                	push   $0x4e
  jmp alltraps
80108ca1:	e9 f6 f6 ff ff       	jmp    8010839c <alltraps>

80108ca6 <vector79>:
.globl vector79
vector79:
  pushl $0
80108ca6:	6a 00                	push   $0x0
  pushl $79
80108ca8:	6a 4f                	push   $0x4f
  jmp alltraps
80108caa:	e9 ed f6 ff ff       	jmp    8010839c <alltraps>

80108caf <vector80>:
.globl vector80
vector80:
  pushl $0
80108caf:	6a 00                	push   $0x0
  pushl $80
80108cb1:	6a 50                	push   $0x50
  jmp alltraps
80108cb3:	e9 e4 f6 ff ff       	jmp    8010839c <alltraps>

80108cb8 <vector81>:
.globl vector81
vector81:
  pushl $0
80108cb8:	6a 00                	push   $0x0
  pushl $81
80108cba:	6a 51                	push   $0x51
  jmp alltraps
80108cbc:	e9 db f6 ff ff       	jmp    8010839c <alltraps>

80108cc1 <vector82>:
.globl vector82
vector82:
  pushl $0
80108cc1:	6a 00                	push   $0x0
  pushl $82
80108cc3:	6a 52                	push   $0x52
  jmp alltraps
80108cc5:	e9 d2 f6 ff ff       	jmp    8010839c <alltraps>

80108cca <vector83>:
.globl vector83
vector83:
  pushl $0
80108cca:	6a 00                	push   $0x0
  pushl $83
80108ccc:	6a 53                	push   $0x53
  jmp alltraps
80108cce:	e9 c9 f6 ff ff       	jmp    8010839c <alltraps>

80108cd3 <vector84>:
.globl vector84
vector84:
  pushl $0
80108cd3:	6a 00                	push   $0x0
  pushl $84
80108cd5:	6a 54                	push   $0x54
  jmp alltraps
80108cd7:	e9 c0 f6 ff ff       	jmp    8010839c <alltraps>

80108cdc <vector85>:
.globl vector85
vector85:
  pushl $0
80108cdc:	6a 00                	push   $0x0
  pushl $85
80108cde:	6a 55                	push   $0x55
  jmp alltraps
80108ce0:	e9 b7 f6 ff ff       	jmp    8010839c <alltraps>

80108ce5 <vector86>:
.globl vector86
vector86:
  pushl $0
80108ce5:	6a 00                	push   $0x0
  pushl $86
80108ce7:	6a 56                	push   $0x56
  jmp alltraps
80108ce9:	e9 ae f6 ff ff       	jmp    8010839c <alltraps>

80108cee <vector87>:
.globl vector87
vector87:
  pushl $0
80108cee:	6a 00                	push   $0x0
  pushl $87
80108cf0:	6a 57                	push   $0x57
  jmp alltraps
80108cf2:	e9 a5 f6 ff ff       	jmp    8010839c <alltraps>

80108cf7 <vector88>:
.globl vector88
vector88:
  pushl $0
80108cf7:	6a 00                	push   $0x0
  pushl $88
80108cf9:	6a 58                	push   $0x58
  jmp alltraps
80108cfb:	e9 9c f6 ff ff       	jmp    8010839c <alltraps>

80108d00 <vector89>:
.globl vector89
vector89:
  pushl $0
80108d00:	6a 00                	push   $0x0
  pushl $89
80108d02:	6a 59                	push   $0x59
  jmp alltraps
80108d04:	e9 93 f6 ff ff       	jmp    8010839c <alltraps>

80108d09 <vector90>:
.globl vector90
vector90:
  pushl $0
80108d09:	6a 00                	push   $0x0
  pushl $90
80108d0b:	6a 5a                	push   $0x5a
  jmp alltraps
80108d0d:	e9 8a f6 ff ff       	jmp    8010839c <alltraps>

80108d12 <vector91>:
.globl vector91
vector91:
  pushl $0
80108d12:	6a 00                	push   $0x0
  pushl $91
80108d14:	6a 5b                	push   $0x5b
  jmp alltraps
80108d16:	e9 81 f6 ff ff       	jmp    8010839c <alltraps>

80108d1b <vector92>:
.globl vector92
vector92:
  pushl $0
80108d1b:	6a 00                	push   $0x0
  pushl $92
80108d1d:	6a 5c                	push   $0x5c
  jmp alltraps
80108d1f:	e9 78 f6 ff ff       	jmp    8010839c <alltraps>

80108d24 <vector93>:
.globl vector93
vector93:
  pushl $0
80108d24:	6a 00                	push   $0x0
  pushl $93
80108d26:	6a 5d                	push   $0x5d
  jmp alltraps
80108d28:	e9 6f f6 ff ff       	jmp    8010839c <alltraps>

80108d2d <vector94>:
.globl vector94
vector94:
  pushl $0
80108d2d:	6a 00                	push   $0x0
  pushl $94
80108d2f:	6a 5e                	push   $0x5e
  jmp alltraps
80108d31:	e9 66 f6 ff ff       	jmp    8010839c <alltraps>

80108d36 <vector95>:
.globl vector95
vector95:
  pushl $0
80108d36:	6a 00                	push   $0x0
  pushl $95
80108d38:	6a 5f                	push   $0x5f
  jmp alltraps
80108d3a:	e9 5d f6 ff ff       	jmp    8010839c <alltraps>

80108d3f <vector96>:
.globl vector96
vector96:
  pushl $0
80108d3f:	6a 00                	push   $0x0
  pushl $96
80108d41:	6a 60                	push   $0x60
  jmp alltraps
80108d43:	e9 54 f6 ff ff       	jmp    8010839c <alltraps>

80108d48 <vector97>:
.globl vector97
vector97:
  pushl $0
80108d48:	6a 00                	push   $0x0
  pushl $97
80108d4a:	6a 61                	push   $0x61
  jmp alltraps
80108d4c:	e9 4b f6 ff ff       	jmp    8010839c <alltraps>

80108d51 <vector98>:
.globl vector98
vector98:
  pushl $0
80108d51:	6a 00                	push   $0x0
  pushl $98
80108d53:	6a 62                	push   $0x62
  jmp alltraps
80108d55:	e9 42 f6 ff ff       	jmp    8010839c <alltraps>

80108d5a <vector99>:
.globl vector99
vector99:
  pushl $0
80108d5a:	6a 00                	push   $0x0
  pushl $99
80108d5c:	6a 63                	push   $0x63
  jmp alltraps
80108d5e:	e9 39 f6 ff ff       	jmp    8010839c <alltraps>

80108d63 <vector100>:
.globl vector100
vector100:
  pushl $0
80108d63:	6a 00                	push   $0x0
  pushl $100
80108d65:	6a 64                	push   $0x64
  jmp alltraps
80108d67:	e9 30 f6 ff ff       	jmp    8010839c <alltraps>

80108d6c <vector101>:
.globl vector101
vector101:
  pushl $0
80108d6c:	6a 00                	push   $0x0
  pushl $101
80108d6e:	6a 65                	push   $0x65
  jmp alltraps
80108d70:	e9 27 f6 ff ff       	jmp    8010839c <alltraps>

80108d75 <vector102>:
.globl vector102
vector102:
  pushl $0
80108d75:	6a 00                	push   $0x0
  pushl $102
80108d77:	6a 66                	push   $0x66
  jmp alltraps
80108d79:	e9 1e f6 ff ff       	jmp    8010839c <alltraps>

80108d7e <vector103>:
.globl vector103
vector103:
  pushl $0
80108d7e:	6a 00                	push   $0x0
  pushl $103
80108d80:	6a 67                	push   $0x67
  jmp alltraps
80108d82:	e9 15 f6 ff ff       	jmp    8010839c <alltraps>

80108d87 <vector104>:
.globl vector104
vector104:
  pushl $0
80108d87:	6a 00                	push   $0x0
  pushl $104
80108d89:	6a 68                	push   $0x68
  jmp alltraps
80108d8b:	e9 0c f6 ff ff       	jmp    8010839c <alltraps>

80108d90 <vector105>:
.globl vector105
vector105:
  pushl $0
80108d90:	6a 00                	push   $0x0
  pushl $105
80108d92:	6a 69                	push   $0x69
  jmp alltraps
80108d94:	e9 03 f6 ff ff       	jmp    8010839c <alltraps>

80108d99 <vector106>:
.globl vector106
vector106:
  pushl $0
80108d99:	6a 00                	push   $0x0
  pushl $106
80108d9b:	6a 6a                	push   $0x6a
  jmp alltraps
80108d9d:	e9 fa f5 ff ff       	jmp    8010839c <alltraps>

80108da2 <vector107>:
.globl vector107
vector107:
  pushl $0
80108da2:	6a 00                	push   $0x0
  pushl $107
80108da4:	6a 6b                	push   $0x6b
  jmp alltraps
80108da6:	e9 f1 f5 ff ff       	jmp    8010839c <alltraps>

80108dab <vector108>:
.globl vector108
vector108:
  pushl $0
80108dab:	6a 00                	push   $0x0
  pushl $108
80108dad:	6a 6c                	push   $0x6c
  jmp alltraps
80108daf:	e9 e8 f5 ff ff       	jmp    8010839c <alltraps>

80108db4 <vector109>:
.globl vector109
vector109:
  pushl $0
80108db4:	6a 00                	push   $0x0
  pushl $109
80108db6:	6a 6d                	push   $0x6d
  jmp alltraps
80108db8:	e9 df f5 ff ff       	jmp    8010839c <alltraps>

80108dbd <vector110>:
.globl vector110
vector110:
  pushl $0
80108dbd:	6a 00                	push   $0x0
  pushl $110
80108dbf:	6a 6e                	push   $0x6e
  jmp alltraps
80108dc1:	e9 d6 f5 ff ff       	jmp    8010839c <alltraps>

80108dc6 <vector111>:
.globl vector111
vector111:
  pushl $0
80108dc6:	6a 00                	push   $0x0
  pushl $111
80108dc8:	6a 6f                	push   $0x6f
  jmp alltraps
80108dca:	e9 cd f5 ff ff       	jmp    8010839c <alltraps>

80108dcf <vector112>:
.globl vector112
vector112:
  pushl $0
80108dcf:	6a 00                	push   $0x0
  pushl $112
80108dd1:	6a 70                	push   $0x70
  jmp alltraps
80108dd3:	e9 c4 f5 ff ff       	jmp    8010839c <alltraps>

80108dd8 <vector113>:
.globl vector113
vector113:
  pushl $0
80108dd8:	6a 00                	push   $0x0
  pushl $113
80108dda:	6a 71                	push   $0x71
  jmp alltraps
80108ddc:	e9 bb f5 ff ff       	jmp    8010839c <alltraps>

80108de1 <vector114>:
.globl vector114
vector114:
  pushl $0
80108de1:	6a 00                	push   $0x0
  pushl $114
80108de3:	6a 72                	push   $0x72
  jmp alltraps
80108de5:	e9 b2 f5 ff ff       	jmp    8010839c <alltraps>

80108dea <vector115>:
.globl vector115
vector115:
  pushl $0
80108dea:	6a 00                	push   $0x0
  pushl $115
80108dec:	6a 73                	push   $0x73
  jmp alltraps
80108dee:	e9 a9 f5 ff ff       	jmp    8010839c <alltraps>

80108df3 <vector116>:
.globl vector116
vector116:
  pushl $0
80108df3:	6a 00                	push   $0x0
  pushl $116
80108df5:	6a 74                	push   $0x74
  jmp alltraps
80108df7:	e9 a0 f5 ff ff       	jmp    8010839c <alltraps>

80108dfc <vector117>:
.globl vector117
vector117:
  pushl $0
80108dfc:	6a 00                	push   $0x0
  pushl $117
80108dfe:	6a 75                	push   $0x75
  jmp alltraps
80108e00:	e9 97 f5 ff ff       	jmp    8010839c <alltraps>

80108e05 <vector118>:
.globl vector118
vector118:
  pushl $0
80108e05:	6a 00                	push   $0x0
  pushl $118
80108e07:	6a 76                	push   $0x76
  jmp alltraps
80108e09:	e9 8e f5 ff ff       	jmp    8010839c <alltraps>

80108e0e <vector119>:
.globl vector119
vector119:
  pushl $0
80108e0e:	6a 00                	push   $0x0
  pushl $119
80108e10:	6a 77                	push   $0x77
  jmp alltraps
80108e12:	e9 85 f5 ff ff       	jmp    8010839c <alltraps>

80108e17 <vector120>:
.globl vector120
vector120:
  pushl $0
80108e17:	6a 00                	push   $0x0
  pushl $120
80108e19:	6a 78                	push   $0x78
  jmp alltraps
80108e1b:	e9 7c f5 ff ff       	jmp    8010839c <alltraps>

80108e20 <vector121>:
.globl vector121
vector121:
  pushl $0
80108e20:	6a 00                	push   $0x0
  pushl $121
80108e22:	6a 79                	push   $0x79
  jmp alltraps
80108e24:	e9 73 f5 ff ff       	jmp    8010839c <alltraps>

80108e29 <vector122>:
.globl vector122
vector122:
  pushl $0
80108e29:	6a 00                	push   $0x0
  pushl $122
80108e2b:	6a 7a                	push   $0x7a
  jmp alltraps
80108e2d:	e9 6a f5 ff ff       	jmp    8010839c <alltraps>

80108e32 <vector123>:
.globl vector123
vector123:
  pushl $0
80108e32:	6a 00                	push   $0x0
  pushl $123
80108e34:	6a 7b                	push   $0x7b
  jmp alltraps
80108e36:	e9 61 f5 ff ff       	jmp    8010839c <alltraps>

80108e3b <vector124>:
.globl vector124
vector124:
  pushl $0
80108e3b:	6a 00                	push   $0x0
  pushl $124
80108e3d:	6a 7c                	push   $0x7c
  jmp alltraps
80108e3f:	e9 58 f5 ff ff       	jmp    8010839c <alltraps>

80108e44 <vector125>:
.globl vector125
vector125:
  pushl $0
80108e44:	6a 00                	push   $0x0
  pushl $125
80108e46:	6a 7d                	push   $0x7d
  jmp alltraps
80108e48:	e9 4f f5 ff ff       	jmp    8010839c <alltraps>

80108e4d <vector126>:
.globl vector126
vector126:
  pushl $0
80108e4d:	6a 00                	push   $0x0
  pushl $126
80108e4f:	6a 7e                	push   $0x7e
  jmp alltraps
80108e51:	e9 46 f5 ff ff       	jmp    8010839c <alltraps>

80108e56 <vector127>:
.globl vector127
vector127:
  pushl $0
80108e56:	6a 00                	push   $0x0
  pushl $127
80108e58:	6a 7f                	push   $0x7f
  jmp alltraps
80108e5a:	e9 3d f5 ff ff       	jmp    8010839c <alltraps>

80108e5f <vector128>:
.globl vector128
vector128:
  pushl $0
80108e5f:	6a 00                	push   $0x0
  pushl $128
80108e61:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80108e66:	e9 31 f5 ff ff       	jmp    8010839c <alltraps>

80108e6b <vector129>:
.globl vector129
vector129:
  pushl $0
80108e6b:	6a 00                	push   $0x0
  pushl $129
80108e6d:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80108e72:	e9 25 f5 ff ff       	jmp    8010839c <alltraps>

80108e77 <vector130>:
.globl vector130
vector130:
  pushl $0
80108e77:	6a 00                	push   $0x0
  pushl $130
80108e79:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80108e7e:	e9 19 f5 ff ff       	jmp    8010839c <alltraps>

80108e83 <vector131>:
.globl vector131
vector131:
  pushl $0
80108e83:	6a 00                	push   $0x0
  pushl $131
80108e85:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80108e8a:	e9 0d f5 ff ff       	jmp    8010839c <alltraps>

80108e8f <vector132>:
.globl vector132
vector132:
  pushl $0
80108e8f:	6a 00                	push   $0x0
  pushl $132
80108e91:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80108e96:	e9 01 f5 ff ff       	jmp    8010839c <alltraps>

80108e9b <vector133>:
.globl vector133
vector133:
  pushl $0
80108e9b:	6a 00                	push   $0x0
  pushl $133
80108e9d:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80108ea2:	e9 f5 f4 ff ff       	jmp    8010839c <alltraps>

80108ea7 <vector134>:
.globl vector134
vector134:
  pushl $0
80108ea7:	6a 00                	push   $0x0
  pushl $134
80108ea9:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80108eae:	e9 e9 f4 ff ff       	jmp    8010839c <alltraps>

80108eb3 <vector135>:
.globl vector135
vector135:
  pushl $0
80108eb3:	6a 00                	push   $0x0
  pushl $135
80108eb5:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80108eba:	e9 dd f4 ff ff       	jmp    8010839c <alltraps>

80108ebf <vector136>:
.globl vector136
vector136:
  pushl $0
80108ebf:	6a 00                	push   $0x0
  pushl $136
80108ec1:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80108ec6:	e9 d1 f4 ff ff       	jmp    8010839c <alltraps>

80108ecb <vector137>:
.globl vector137
vector137:
  pushl $0
80108ecb:	6a 00                	push   $0x0
  pushl $137
80108ecd:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80108ed2:	e9 c5 f4 ff ff       	jmp    8010839c <alltraps>

80108ed7 <vector138>:
.globl vector138
vector138:
  pushl $0
80108ed7:	6a 00                	push   $0x0
  pushl $138
80108ed9:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80108ede:	e9 b9 f4 ff ff       	jmp    8010839c <alltraps>

80108ee3 <vector139>:
.globl vector139
vector139:
  pushl $0
80108ee3:	6a 00                	push   $0x0
  pushl $139
80108ee5:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80108eea:	e9 ad f4 ff ff       	jmp    8010839c <alltraps>

80108eef <vector140>:
.globl vector140
vector140:
  pushl $0
80108eef:	6a 00                	push   $0x0
  pushl $140
80108ef1:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80108ef6:	e9 a1 f4 ff ff       	jmp    8010839c <alltraps>

80108efb <vector141>:
.globl vector141
vector141:
  pushl $0
80108efb:	6a 00                	push   $0x0
  pushl $141
80108efd:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80108f02:	e9 95 f4 ff ff       	jmp    8010839c <alltraps>

80108f07 <vector142>:
.globl vector142
vector142:
  pushl $0
80108f07:	6a 00                	push   $0x0
  pushl $142
80108f09:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80108f0e:	e9 89 f4 ff ff       	jmp    8010839c <alltraps>

80108f13 <vector143>:
.globl vector143
vector143:
  pushl $0
80108f13:	6a 00                	push   $0x0
  pushl $143
80108f15:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80108f1a:	e9 7d f4 ff ff       	jmp    8010839c <alltraps>

80108f1f <vector144>:
.globl vector144
vector144:
  pushl $0
80108f1f:	6a 00                	push   $0x0
  pushl $144
80108f21:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80108f26:	e9 71 f4 ff ff       	jmp    8010839c <alltraps>

80108f2b <vector145>:
.globl vector145
vector145:
  pushl $0
80108f2b:	6a 00                	push   $0x0
  pushl $145
80108f2d:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80108f32:	e9 65 f4 ff ff       	jmp    8010839c <alltraps>

80108f37 <vector146>:
.globl vector146
vector146:
  pushl $0
80108f37:	6a 00                	push   $0x0
  pushl $146
80108f39:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80108f3e:	e9 59 f4 ff ff       	jmp    8010839c <alltraps>

80108f43 <vector147>:
.globl vector147
vector147:
  pushl $0
80108f43:	6a 00                	push   $0x0
  pushl $147
80108f45:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108f4a:	e9 4d f4 ff ff       	jmp    8010839c <alltraps>

80108f4f <vector148>:
.globl vector148
vector148:
  pushl $0
80108f4f:	6a 00                	push   $0x0
  pushl $148
80108f51:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80108f56:	e9 41 f4 ff ff       	jmp    8010839c <alltraps>

80108f5b <vector149>:
.globl vector149
vector149:
  pushl $0
80108f5b:	6a 00                	push   $0x0
  pushl $149
80108f5d:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80108f62:	e9 35 f4 ff ff       	jmp    8010839c <alltraps>

80108f67 <vector150>:
.globl vector150
vector150:
  pushl $0
80108f67:	6a 00                	push   $0x0
  pushl $150
80108f69:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80108f6e:	e9 29 f4 ff ff       	jmp    8010839c <alltraps>

80108f73 <vector151>:
.globl vector151
vector151:
  pushl $0
80108f73:	6a 00                	push   $0x0
  pushl $151
80108f75:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80108f7a:	e9 1d f4 ff ff       	jmp    8010839c <alltraps>

80108f7f <vector152>:
.globl vector152
vector152:
  pushl $0
80108f7f:	6a 00                	push   $0x0
  pushl $152
80108f81:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80108f86:	e9 11 f4 ff ff       	jmp    8010839c <alltraps>

80108f8b <vector153>:
.globl vector153
vector153:
  pushl $0
80108f8b:	6a 00                	push   $0x0
  pushl $153
80108f8d:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80108f92:	e9 05 f4 ff ff       	jmp    8010839c <alltraps>

80108f97 <vector154>:
.globl vector154
vector154:
  pushl $0
80108f97:	6a 00                	push   $0x0
  pushl $154
80108f99:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80108f9e:	e9 f9 f3 ff ff       	jmp    8010839c <alltraps>

80108fa3 <vector155>:
.globl vector155
vector155:
  pushl $0
80108fa3:	6a 00                	push   $0x0
  pushl $155
80108fa5:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80108faa:	e9 ed f3 ff ff       	jmp    8010839c <alltraps>

80108faf <vector156>:
.globl vector156
vector156:
  pushl $0
80108faf:	6a 00                	push   $0x0
  pushl $156
80108fb1:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80108fb6:	e9 e1 f3 ff ff       	jmp    8010839c <alltraps>

80108fbb <vector157>:
.globl vector157
vector157:
  pushl $0
80108fbb:	6a 00                	push   $0x0
  pushl $157
80108fbd:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80108fc2:	e9 d5 f3 ff ff       	jmp    8010839c <alltraps>

80108fc7 <vector158>:
.globl vector158
vector158:
  pushl $0
80108fc7:	6a 00                	push   $0x0
  pushl $158
80108fc9:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80108fce:	e9 c9 f3 ff ff       	jmp    8010839c <alltraps>

80108fd3 <vector159>:
.globl vector159
vector159:
  pushl $0
80108fd3:	6a 00                	push   $0x0
  pushl $159
80108fd5:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108fda:	e9 bd f3 ff ff       	jmp    8010839c <alltraps>

80108fdf <vector160>:
.globl vector160
vector160:
  pushl $0
80108fdf:	6a 00                	push   $0x0
  pushl $160
80108fe1:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80108fe6:	e9 b1 f3 ff ff       	jmp    8010839c <alltraps>

80108feb <vector161>:
.globl vector161
vector161:
  pushl $0
80108feb:	6a 00                	push   $0x0
  pushl $161
80108fed:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80108ff2:	e9 a5 f3 ff ff       	jmp    8010839c <alltraps>

80108ff7 <vector162>:
.globl vector162
vector162:
  pushl $0
80108ff7:	6a 00                	push   $0x0
  pushl $162
80108ff9:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80108ffe:	e9 99 f3 ff ff       	jmp    8010839c <alltraps>

80109003 <vector163>:
.globl vector163
vector163:
  pushl $0
80109003:	6a 00                	push   $0x0
  pushl $163
80109005:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010900a:	e9 8d f3 ff ff       	jmp    8010839c <alltraps>

8010900f <vector164>:
.globl vector164
vector164:
  pushl $0
8010900f:	6a 00                	push   $0x0
  pushl $164
80109011:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80109016:	e9 81 f3 ff ff       	jmp    8010839c <alltraps>

8010901b <vector165>:
.globl vector165
vector165:
  pushl $0
8010901b:	6a 00                	push   $0x0
  pushl $165
8010901d:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80109022:	e9 75 f3 ff ff       	jmp    8010839c <alltraps>

80109027 <vector166>:
.globl vector166
vector166:
  pushl $0
80109027:	6a 00                	push   $0x0
  pushl $166
80109029:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010902e:	e9 69 f3 ff ff       	jmp    8010839c <alltraps>

80109033 <vector167>:
.globl vector167
vector167:
  pushl $0
80109033:	6a 00                	push   $0x0
  pushl $167
80109035:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010903a:	e9 5d f3 ff ff       	jmp    8010839c <alltraps>

8010903f <vector168>:
.globl vector168
vector168:
  pushl $0
8010903f:	6a 00                	push   $0x0
  pushl $168
80109041:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80109046:	e9 51 f3 ff ff       	jmp    8010839c <alltraps>

8010904b <vector169>:
.globl vector169
vector169:
  pushl $0
8010904b:	6a 00                	push   $0x0
  pushl $169
8010904d:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80109052:	e9 45 f3 ff ff       	jmp    8010839c <alltraps>

80109057 <vector170>:
.globl vector170
vector170:
  pushl $0
80109057:	6a 00                	push   $0x0
  pushl $170
80109059:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010905e:	e9 39 f3 ff ff       	jmp    8010839c <alltraps>

80109063 <vector171>:
.globl vector171
vector171:
  pushl $0
80109063:	6a 00                	push   $0x0
  pushl $171
80109065:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010906a:	e9 2d f3 ff ff       	jmp    8010839c <alltraps>

8010906f <vector172>:
.globl vector172
vector172:
  pushl $0
8010906f:	6a 00                	push   $0x0
  pushl $172
80109071:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80109076:	e9 21 f3 ff ff       	jmp    8010839c <alltraps>

8010907b <vector173>:
.globl vector173
vector173:
  pushl $0
8010907b:	6a 00                	push   $0x0
  pushl $173
8010907d:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80109082:	e9 15 f3 ff ff       	jmp    8010839c <alltraps>

80109087 <vector174>:
.globl vector174
vector174:
  pushl $0
80109087:	6a 00                	push   $0x0
  pushl $174
80109089:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010908e:	e9 09 f3 ff ff       	jmp    8010839c <alltraps>

80109093 <vector175>:
.globl vector175
vector175:
  pushl $0
80109093:	6a 00                	push   $0x0
  pushl $175
80109095:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010909a:	e9 fd f2 ff ff       	jmp    8010839c <alltraps>

8010909f <vector176>:
.globl vector176
vector176:
  pushl $0
8010909f:	6a 00                	push   $0x0
  pushl $176
801090a1:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801090a6:	e9 f1 f2 ff ff       	jmp    8010839c <alltraps>

801090ab <vector177>:
.globl vector177
vector177:
  pushl $0
801090ab:	6a 00                	push   $0x0
  pushl $177
801090ad:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801090b2:	e9 e5 f2 ff ff       	jmp    8010839c <alltraps>

801090b7 <vector178>:
.globl vector178
vector178:
  pushl $0
801090b7:	6a 00                	push   $0x0
  pushl $178
801090b9:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801090be:	e9 d9 f2 ff ff       	jmp    8010839c <alltraps>

801090c3 <vector179>:
.globl vector179
vector179:
  pushl $0
801090c3:	6a 00                	push   $0x0
  pushl $179
801090c5:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801090ca:	e9 cd f2 ff ff       	jmp    8010839c <alltraps>

801090cf <vector180>:
.globl vector180
vector180:
  pushl $0
801090cf:	6a 00                	push   $0x0
  pushl $180
801090d1:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801090d6:	e9 c1 f2 ff ff       	jmp    8010839c <alltraps>

801090db <vector181>:
.globl vector181
vector181:
  pushl $0
801090db:	6a 00                	push   $0x0
  pushl $181
801090dd:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801090e2:	e9 b5 f2 ff ff       	jmp    8010839c <alltraps>

801090e7 <vector182>:
.globl vector182
vector182:
  pushl $0
801090e7:	6a 00                	push   $0x0
  pushl $182
801090e9:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801090ee:	e9 a9 f2 ff ff       	jmp    8010839c <alltraps>

801090f3 <vector183>:
.globl vector183
vector183:
  pushl $0
801090f3:	6a 00                	push   $0x0
  pushl $183
801090f5:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801090fa:	e9 9d f2 ff ff       	jmp    8010839c <alltraps>

801090ff <vector184>:
.globl vector184
vector184:
  pushl $0
801090ff:	6a 00                	push   $0x0
  pushl $184
80109101:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80109106:	e9 91 f2 ff ff       	jmp    8010839c <alltraps>

8010910b <vector185>:
.globl vector185
vector185:
  pushl $0
8010910b:	6a 00                	push   $0x0
  pushl $185
8010910d:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80109112:	e9 85 f2 ff ff       	jmp    8010839c <alltraps>

80109117 <vector186>:
.globl vector186
vector186:
  pushl $0
80109117:	6a 00                	push   $0x0
  pushl $186
80109119:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010911e:	e9 79 f2 ff ff       	jmp    8010839c <alltraps>

80109123 <vector187>:
.globl vector187
vector187:
  pushl $0
80109123:	6a 00                	push   $0x0
  pushl $187
80109125:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010912a:	e9 6d f2 ff ff       	jmp    8010839c <alltraps>

8010912f <vector188>:
.globl vector188
vector188:
  pushl $0
8010912f:	6a 00                	push   $0x0
  pushl $188
80109131:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80109136:	e9 61 f2 ff ff       	jmp    8010839c <alltraps>

8010913b <vector189>:
.globl vector189
vector189:
  pushl $0
8010913b:	6a 00                	push   $0x0
  pushl $189
8010913d:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80109142:	e9 55 f2 ff ff       	jmp    8010839c <alltraps>

80109147 <vector190>:
.globl vector190
vector190:
  pushl $0
80109147:	6a 00                	push   $0x0
  pushl $190
80109149:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010914e:	e9 49 f2 ff ff       	jmp    8010839c <alltraps>

80109153 <vector191>:
.globl vector191
vector191:
  pushl $0
80109153:	6a 00                	push   $0x0
  pushl $191
80109155:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010915a:	e9 3d f2 ff ff       	jmp    8010839c <alltraps>

8010915f <vector192>:
.globl vector192
vector192:
  pushl $0
8010915f:	6a 00                	push   $0x0
  pushl $192
80109161:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80109166:	e9 31 f2 ff ff       	jmp    8010839c <alltraps>

8010916b <vector193>:
.globl vector193
vector193:
  pushl $0
8010916b:	6a 00                	push   $0x0
  pushl $193
8010916d:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80109172:	e9 25 f2 ff ff       	jmp    8010839c <alltraps>

80109177 <vector194>:
.globl vector194
vector194:
  pushl $0
80109177:	6a 00                	push   $0x0
  pushl $194
80109179:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010917e:	e9 19 f2 ff ff       	jmp    8010839c <alltraps>

80109183 <vector195>:
.globl vector195
vector195:
  pushl $0
80109183:	6a 00                	push   $0x0
  pushl $195
80109185:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010918a:	e9 0d f2 ff ff       	jmp    8010839c <alltraps>

8010918f <vector196>:
.globl vector196
vector196:
  pushl $0
8010918f:	6a 00                	push   $0x0
  pushl $196
80109191:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80109196:	e9 01 f2 ff ff       	jmp    8010839c <alltraps>

8010919b <vector197>:
.globl vector197
vector197:
  pushl $0
8010919b:	6a 00                	push   $0x0
  pushl $197
8010919d:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801091a2:	e9 f5 f1 ff ff       	jmp    8010839c <alltraps>

801091a7 <vector198>:
.globl vector198
vector198:
  pushl $0
801091a7:	6a 00                	push   $0x0
  pushl $198
801091a9:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801091ae:	e9 e9 f1 ff ff       	jmp    8010839c <alltraps>

801091b3 <vector199>:
.globl vector199
vector199:
  pushl $0
801091b3:	6a 00                	push   $0x0
  pushl $199
801091b5:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801091ba:	e9 dd f1 ff ff       	jmp    8010839c <alltraps>

801091bf <vector200>:
.globl vector200
vector200:
  pushl $0
801091bf:	6a 00                	push   $0x0
  pushl $200
801091c1:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801091c6:	e9 d1 f1 ff ff       	jmp    8010839c <alltraps>

801091cb <vector201>:
.globl vector201
vector201:
  pushl $0
801091cb:	6a 00                	push   $0x0
  pushl $201
801091cd:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801091d2:	e9 c5 f1 ff ff       	jmp    8010839c <alltraps>

801091d7 <vector202>:
.globl vector202
vector202:
  pushl $0
801091d7:	6a 00                	push   $0x0
  pushl $202
801091d9:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801091de:	e9 b9 f1 ff ff       	jmp    8010839c <alltraps>

801091e3 <vector203>:
.globl vector203
vector203:
  pushl $0
801091e3:	6a 00                	push   $0x0
  pushl $203
801091e5:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801091ea:	e9 ad f1 ff ff       	jmp    8010839c <alltraps>

801091ef <vector204>:
.globl vector204
vector204:
  pushl $0
801091ef:	6a 00                	push   $0x0
  pushl $204
801091f1:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801091f6:	e9 a1 f1 ff ff       	jmp    8010839c <alltraps>

801091fb <vector205>:
.globl vector205
vector205:
  pushl $0
801091fb:	6a 00                	push   $0x0
  pushl $205
801091fd:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80109202:	e9 95 f1 ff ff       	jmp    8010839c <alltraps>

80109207 <vector206>:
.globl vector206
vector206:
  pushl $0
80109207:	6a 00                	push   $0x0
  pushl $206
80109209:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010920e:	e9 89 f1 ff ff       	jmp    8010839c <alltraps>

80109213 <vector207>:
.globl vector207
vector207:
  pushl $0
80109213:	6a 00                	push   $0x0
  pushl $207
80109215:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010921a:	e9 7d f1 ff ff       	jmp    8010839c <alltraps>

8010921f <vector208>:
.globl vector208
vector208:
  pushl $0
8010921f:	6a 00                	push   $0x0
  pushl $208
80109221:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80109226:	e9 71 f1 ff ff       	jmp    8010839c <alltraps>

8010922b <vector209>:
.globl vector209
vector209:
  pushl $0
8010922b:	6a 00                	push   $0x0
  pushl $209
8010922d:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80109232:	e9 65 f1 ff ff       	jmp    8010839c <alltraps>

80109237 <vector210>:
.globl vector210
vector210:
  pushl $0
80109237:	6a 00                	push   $0x0
  pushl $210
80109239:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010923e:	e9 59 f1 ff ff       	jmp    8010839c <alltraps>

80109243 <vector211>:
.globl vector211
vector211:
  pushl $0
80109243:	6a 00                	push   $0x0
  pushl $211
80109245:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010924a:	e9 4d f1 ff ff       	jmp    8010839c <alltraps>

8010924f <vector212>:
.globl vector212
vector212:
  pushl $0
8010924f:	6a 00                	push   $0x0
  pushl $212
80109251:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80109256:	e9 41 f1 ff ff       	jmp    8010839c <alltraps>

8010925b <vector213>:
.globl vector213
vector213:
  pushl $0
8010925b:	6a 00                	push   $0x0
  pushl $213
8010925d:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80109262:	e9 35 f1 ff ff       	jmp    8010839c <alltraps>

80109267 <vector214>:
.globl vector214
vector214:
  pushl $0
80109267:	6a 00                	push   $0x0
  pushl $214
80109269:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010926e:	e9 29 f1 ff ff       	jmp    8010839c <alltraps>

80109273 <vector215>:
.globl vector215
vector215:
  pushl $0
80109273:	6a 00                	push   $0x0
  pushl $215
80109275:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010927a:	e9 1d f1 ff ff       	jmp    8010839c <alltraps>

8010927f <vector216>:
.globl vector216
vector216:
  pushl $0
8010927f:	6a 00                	push   $0x0
  pushl $216
80109281:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80109286:	e9 11 f1 ff ff       	jmp    8010839c <alltraps>

8010928b <vector217>:
.globl vector217
vector217:
  pushl $0
8010928b:	6a 00                	push   $0x0
  pushl $217
8010928d:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80109292:	e9 05 f1 ff ff       	jmp    8010839c <alltraps>

80109297 <vector218>:
.globl vector218
vector218:
  pushl $0
80109297:	6a 00                	push   $0x0
  pushl $218
80109299:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010929e:	e9 f9 f0 ff ff       	jmp    8010839c <alltraps>

801092a3 <vector219>:
.globl vector219
vector219:
  pushl $0
801092a3:	6a 00                	push   $0x0
  pushl $219
801092a5:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801092aa:	e9 ed f0 ff ff       	jmp    8010839c <alltraps>

801092af <vector220>:
.globl vector220
vector220:
  pushl $0
801092af:	6a 00                	push   $0x0
  pushl $220
801092b1:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801092b6:	e9 e1 f0 ff ff       	jmp    8010839c <alltraps>

801092bb <vector221>:
.globl vector221
vector221:
  pushl $0
801092bb:	6a 00                	push   $0x0
  pushl $221
801092bd:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801092c2:	e9 d5 f0 ff ff       	jmp    8010839c <alltraps>

801092c7 <vector222>:
.globl vector222
vector222:
  pushl $0
801092c7:	6a 00                	push   $0x0
  pushl $222
801092c9:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801092ce:	e9 c9 f0 ff ff       	jmp    8010839c <alltraps>

801092d3 <vector223>:
.globl vector223
vector223:
  pushl $0
801092d3:	6a 00                	push   $0x0
  pushl $223
801092d5:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801092da:	e9 bd f0 ff ff       	jmp    8010839c <alltraps>

801092df <vector224>:
.globl vector224
vector224:
  pushl $0
801092df:	6a 00                	push   $0x0
  pushl $224
801092e1:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801092e6:	e9 b1 f0 ff ff       	jmp    8010839c <alltraps>

801092eb <vector225>:
.globl vector225
vector225:
  pushl $0
801092eb:	6a 00                	push   $0x0
  pushl $225
801092ed:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801092f2:	e9 a5 f0 ff ff       	jmp    8010839c <alltraps>

801092f7 <vector226>:
.globl vector226
vector226:
  pushl $0
801092f7:	6a 00                	push   $0x0
  pushl $226
801092f9:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801092fe:	e9 99 f0 ff ff       	jmp    8010839c <alltraps>

80109303 <vector227>:
.globl vector227
vector227:
  pushl $0
80109303:	6a 00                	push   $0x0
  pushl $227
80109305:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010930a:	e9 8d f0 ff ff       	jmp    8010839c <alltraps>

8010930f <vector228>:
.globl vector228
vector228:
  pushl $0
8010930f:	6a 00                	push   $0x0
  pushl $228
80109311:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80109316:	e9 81 f0 ff ff       	jmp    8010839c <alltraps>

8010931b <vector229>:
.globl vector229
vector229:
  pushl $0
8010931b:	6a 00                	push   $0x0
  pushl $229
8010931d:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80109322:	e9 75 f0 ff ff       	jmp    8010839c <alltraps>

80109327 <vector230>:
.globl vector230
vector230:
  pushl $0
80109327:	6a 00                	push   $0x0
  pushl $230
80109329:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010932e:	e9 69 f0 ff ff       	jmp    8010839c <alltraps>

80109333 <vector231>:
.globl vector231
vector231:
  pushl $0
80109333:	6a 00                	push   $0x0
  pushl $231
80109335:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010933a:	e9 5d f0 ff ff       	jmp    8010839c <alltraps>

8010933f <vector232>:
.globl vector232
vector232:
  pushl $0
8010933f:	6a 00                	push   $0x0
  pushl $232
80109341:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80109346:	e9 51 f0 ff ff       	jmp    8010839c <alltraps>

8010934b <vector233>:
.globl vector233
vector233:
  pushl $0
8010934b:	6a 00                	push   $0x0
  pushl $233
8010934d:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80109352:	e9 45 f0 ff ff       	jmp    8010839c <alltraps>

80109357 <vector234>:
.globl vector234
vector234:
  pushl $0
80109357:	6a 00                	push   $0x0
  pushl $234
80109359:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010935e:	e9 39 f0 ff ff       	jmp    8010839c <alltraps>

80109363 <vector235>:
.globl vector235
vector235:
  pushl $0
80109363:	6a 00                	push   $0x0
  pushl $235
80109365:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010936a:	e9 2d f0 ff ff       	jmp    8010839c <alltraps>

8010936f <vector236>:
.globl vector236
vector236:
  pushl $0
8010936f:	6a 00                	push   $0x0
  pushl $236
80109371:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80109376:	e9 21 f0 ff ff       	jmp    8010839c <alltraps>

8010937b <vector237>:
.globl vector237
vector237:
  pushl $0
8010937b:	6a 00                	push   $0x0
  pushl $237
8010937d:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80109382:	e9 15 f0 ff ff       	jmp    8010839c <alltraps>

80109387 <vector238>:
.globl vector238
vector238:
  pushl $0
80109387:	6a 00                	push   $0x0
  pushl $238
80109389:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010938e:	e9 09 f0 ff ff       	jmp    8010839c <alltraps>

80109393 <vector239>:
.globl vector239
vector239:
  pushl $0
80109393:	6a 00                	push   $0x0
  pushl $239
80109395:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010939a:	e9 fd ef ff ff       	jmp    8010839c <alltraps>

8010939f <vector240>:
.globl vector240
vector240:
  pushl $0
8010939f:	6a 00                	push   $0x0
  pushl $240
801093a1:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801093a6:	e9 f1 ef ff ff       	jmp    8010839c <alltraps>

801093ab <vector241>:
.globl vector241
vector241:
  pushl $0
801093ab:	6a 00                	push   $0x0
  pushl $241
801093ad:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801093b2:	e9 e5 ef ff ff       	jmp    8010839c <alltraps>

801093b7 <vector242>:
.globl vector242
vector242:
  pushl $0
801093b7:	6a 00                	push   $0x0
  pushl $242
801093b9:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801093be:	e9 d9 ef ff ff       	jmp    8010839c <alltraps>

801093c3 <vector243>:
.globl vector243
vector243:
  pushl $0
801093c3:	6a 00                	push   $0x0
  pushl $243
801093c5:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801093ca:	e9 cd ef ff ff       	jmp    8010839c <alltraps>

801093cf <vector244>:
.globl vector244
vector244:
  pushl $0
801093cf:	6a 00                	push   $0x0
  pushl $244
801093d1:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801093d6:	e9 c1 ef ff ff       	jmp    8010839c <alltraps>

801093db <vector245>:
.globl vector245
vector245:
  pushl $0
801093db:	6a 00                	push   $0x0
  pushl $245
801093dd:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801093e2:	e9 b5 ef ff ff       	jmp    8010839c <alltraps>

801093e7 <vector246>:
.globl vector246
vector246:
  pushl $0
801093e7:	6a 00                	push   $0x0
  pushl $246
801093e9:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801093ee:	e9 a9 ef ff ff       	jmp    8010839c <alltraps>

801093f3 <vector247>:
.globl vector247
vector247:
  pushl $0
801093f3:	6a 00                	push   $0x0
  pushl $247
801093f5:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801093fa:	e9 9d ef ff ff       	jmp    8010839c <alltraps>

801093ff <vector248>:
.globl vector248
vector248:
  pushl $0
801093ff:	6a 00                	push   $0x0
  pushl $248
80109401:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80109406:	e9 91 ef ff ff       	jmp    8010839c <alltraps>

8010940b <vector249>:
.globl vector249
vector249:
  pushl $0
8010940b:	6a 00                	push   $0x0
  pushl $249
8010940d:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80109412:	e9 85 ef ff ff       	jmp    8010839c <alltraps>

80109417 <vector250>:
.globl vector250
vector250:
  pushl $0
80109417:	6a 00                	push   $0x0
  pushl $250
80109419:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010941e:	e9 79 ef ff ff       	jmp    8010839c <alltraps>

80109423 <vector251>:
.globl vector251
vector251:
  pushl $0
80109423:	6a 00                	push   $0x0
  pushl $251
80109425:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010942a:	e9 6d ef ff ff       	jmp    8010839c <alltraps>

8010942f <vector252>:
.globl vector252
vector252:
  pushl $0
8010942f:	6a 00                	push   $0x0
  pushl $252
80109431:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80109436:	e9 61 ef ff ff       	jmp    8010839c <alltraps>

8010943b <vector253>:
.globl vector253
vector253:
  pushl $0
8010943b:	6a 00                	push   $0x0
  pushl $253
8010943d:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80109442:	e9 55 ef ff ff       	jmp    8010839c <alltraps>

80109447 <vector254>:
.globl vector254
vector254:
  pushl $0
80109447:	6a 00                	push   $0x0
  pushl $254
80109449:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010944e:	e9 49 ef ff ff       	jmp    8010839c <alltraps>

80109453 <vector255>:
.globl vector255
vector255:
  pushl $0
80109453:	6a 00                	push   $0x0
  pushl $255
80109455:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010945a:	e9 3d ef ff ff       	jmp    8010839c <alltraps>

8010945f <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010945f:	55                   	push   %ebp
80109460:	89 e5                	mov    %esp,%ebp
80109462:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80109465:	8b 45 0c             	mov    0xc(%ebp),%eax
80109468:	83 e8 01             	sub    $0x1,%eax
8010946b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010946f:	8b 45 08             	mov    0x8(%ebp),%eax
80109472:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80109476:	8b 45 08             	mov    0x8(%ebp),%eax
80109479:	c1 e8 10             	shr    $0x10,%eax
8010947c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80109480:	8d 45 fa             	lea    -0x6(%ebp),%eax
80109483:	0f 01 10             	lgdtl  (%eax)
}
80109486:	90                   	nop
80109487:	c9                   	leave  
80109488:	c3                   	ret    

80109489 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80109489:	55                   	push   %ebp
8010948a:	89 e5                	mov    %esp,%ebp
8010948c:	83 ec 04             	sub    $0x4,%esp
8010948f:	8b 45 08             	mov    0x8(%ebp),%eax
80109492:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80109496:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010949a:	0f 00 d8             	ltr    %ax
}
8010949d:	90                   	nop
8010949e:	c9                   	leave  
8010949f:	c3                   	ret    

801094a0 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801094a0:	55                   	push   %ebp
801094a1:	89 e5                	mov    %esp,%ebp
801094a3:	83 ec 04             	sub    $0x4,%esp
801094a6:	8b 45 08             	mov    0x8(%ebp),%eax
801094a9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801094ad:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801094b1:	8e e8                	mov    %eax,%gs
}
801094b3:	90                   	nop
801094b4:	c9                   	leave  
801094b5:	c3                   	ret    

801094b6 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801094b6:	55                   	push   %ebp
801094b7:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801094b9:	8b 45 08             	mov    0x8(%ebp),%eax
801094bc:	0f 22 d8             	mov    %eax,%cr3
}
801094bf:	90                   	nop
801094c0:	5d                   	pop    %ebp
801094c1:	c3                   	ret    

801094c2 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801094c2:	55                   	push   %ebp
801094c3:	89 e5                	mov    %esp,%ebp
801094c5:	8b 45 08             	mov    0x8(%ebp),%eax
801094c8:	05 00 00 00 80       	add    $0x80000000,%eax
801094cd:	5d                   	pop    %ebp
801094ce:	c3                   	ret    

801094cf <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801094cf:	55                   	push   %ebp
801094d0:	89 e5                	mov    %esp,%ebp
801094d2:	8b 45 08             	mov    0x8(%ebp),%eax
801094d5:	05 00 00 00 80       	add    $0x80000000,%eax
801094da:	5d                   	pop    %ebp
801094db:	c3                   	ret    

801094dc <seginit>:
struct segdesc gdt[NSEGS];

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void seginit(void)
{
801094dc:	55                   	push   %ebp
801094dd:	89 e5                	mov    %esp,%ebp
801094df:	53                   	push   %ebx
801094e0:	83 ec 14             	sub    $0x14,%esp

	// Map "logical" addresses to virtual addresses using identity map.
	// Cannot share a CODE descriptor for both kernel and user
	// because it would have to have DPL_USR, but the CPU forbids
	// an interrupt from CPL=0 to DPL=3.
	c = &cpus[cpunum()];
801094e3:	e8 e8 9a ff ff       	call   80102fd0 <cpunum>
801094e8:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801094ee:	05 20 57 11 80       	add    $0x80115720,%eax
801094f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	c->gdt[SEG_KCODE] = SEG(STA_X | STA_R, 0, 0xffffffff, 0);
801094f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094f9:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801094ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109502:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80109508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010950b:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010950f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109512:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80109516:	83 e2 f0             	and    $0xfffffff0,%edx
80109519:	83 ca 0a             	or     $0xa,%edx
8010951c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010951f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109522:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80109526:	83 ca 10             	or     $0x10,%edx
80109529:	88 50 7d             	mov    %dl,0x7d(%eax)
8010952c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010952f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80109533:	83 e2 9f             	and    $0xffffff9f,%edx
80109536:	88 50 7d             	mov    %dl,0x7d(%eax)
80109539:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010953c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80109540:	83 ca 80             	or     $0xffffff80,%edx
80109543:	88 50 7d             	mov    %dl,0x7d(%eax)
80109546:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109549:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010954d:	83 ca 0f             	or     $0xf,%edx
80109550:	88 50 7e             	mov    %dl,0x7e(%eax)
80109553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109556:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010955a:	83 e2 ef             	and    $0xffffffef,%edx
8010955d:	88 50 7e             	mov    %dl,0x7e(%eax)
80109560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109563:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80109567:	83 e2 df             	and    $0xffffffdf,%edx
8010956a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010956d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109570:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80109574:	83 ca 40             	or     $0x40,%edx
80109577:	88 50 7e             	mov    %dl,0x7e(%eax)
8010957a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010957d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80109581:	83 ca 80             	or     $0xffffff80,%edx
80109584:	88 50 7e             	mov    %dl,0x7e(%eax)
80109587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010958a:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
	c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010958e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109591:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80109598:	ff ff 
8010959a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010959d:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801095a4:	00 00 
801095a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095a9:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801095b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095b3:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801095ba:	83 e2 f0             	and    $0xfffffff0,%edx
801095bd:	83 ca 02             	or     $0x2,%edx
801095c0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801095c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095c9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801095d0:	83 ca 10             	or     $0x10,%edx
801095d3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801095d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095dc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801095e3:	83 e2 9f             	and    $0xffffff9f,%edx
801095e6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801095ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095ef:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801095f6:	83 ca 80             	or     $0xffffff80,%edx
801095f9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801095ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109602:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80109609:	83 ca 0f             	or     $0xf,%edx
8010960c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80109612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109615:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010961c:	83 e2 ef             	and    $0xffffffef,%edx
8010961f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80109625:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109628:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010962f:	83 e2 df             	and    $0xffffffdf,%edx
80109632:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80109638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010963b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80109642:	83 ca 40             	or     $0x40,%edx
80109645:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010964b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010964e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80109655:	83 ca 80             	or     $0xffffff80,%edx
80109658:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010965e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109661:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
	c->gdt[SEG_UCODE] = SEG(STA_X | STA_R, 0, 0xffffffff, DPL_USER);
80109668:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010966b:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80109672:	ff ff 
80109674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109677:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010967e:	00 00 
80109680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109683:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010968a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010968d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80109694:	83 e2 f0             	and    $0xfffffff0,%edx
80109697:	83 ca 0a             	or     $0xa,%edx
8010969a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801096a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096a3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801096aa:	83 ca 10             	or     $0x10,%edx
801096ad:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801096b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096b6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801096bd:	83 ca 60             	or     $0x60,%edx
801096c0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801096c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096c9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801096d0:	83 ca 80             	or     $0xffffff80,%edx
801096d3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801096d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096dc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801096e3:	83 ca 0f             	or     $0xf,%edx
801096e6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801096ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096ef:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801096f6:	83 e2 ef             	and    $0xffffffef,%edx
801096f9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801096ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109702:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80109709:	83 e2 df             	and    $0xffffffdf,%edx
8010970c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109715:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010971c:	83 ca 40             	or     $0x40,%edx
8010971f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109728:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010972f:	83 ca 80             	or     $0xffffff80,%edx
80109732:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109738:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010973b:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
	c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80109742:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109745:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
8010974c:	ff ff 
8010974e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109751:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80109758:	00 00 
8010975a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010975d:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80109764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109767:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010976e:	83 e2 f0             	and    $0xfffffff0,%edx
80109771:	83 ca 02             	or     $0x2,%edx
80109774:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010977a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010977d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109784:	83 ca 10             	or     $0x10,%edx
80109787:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010978d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109790:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109797:	83 ca 60             	or     $0x60,%edx
8010979a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801097a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097a3:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801097aa:	83 ca 80             	or     $0xffffff80,%edx
801097ad:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801097b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097b6:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801097bd:	83 ca 0f             	or     $0xf,%edx
801097c0:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801097c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097c9:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801097d0:	83 e2 ef             	and    $0xffffffef,%edx
801097d3:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801097d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097dc:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801097e3:	83 e2 df             	and    $0xffffffdf,%edx
801097e6:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801097ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097ef:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801097f6:	83 ca 40             	or     $0x40,%edx
801097f9:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801097ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109802:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109809:	83 ca 80             	or     $0xffffff80,%edx
8010980c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109812:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109815:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

	// Map cpu, and curproc
	c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
8010981c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010981f:	05 b4 00 00 00       	add    $0xb4,%eax
80109824:	89 c3                	mov    %eax,%ebx
80109826:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109829:	05 b4 00 00 00       	add    $0xb4,%eax
8010982e:	c1 e8 10             	shr    $0x10,%eax
80109831:	89 c2                	mov    %eax,%edx
80109833:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109836:	05 b4 00 00 00       	add    $0xb4,%eax
8010983b:	c1 e8 18             	shr    $0x18,%eax
8010983e:	89 c1                	mov    %eax,%ecx
80109840:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109843:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
8010984a:	00 00 
8010984c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010984f:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80109856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109859:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
8010985f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109862:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80109869:	83 e2 f0             	and    $0xfffffff0,%edx
8010986c:	83 ca 02             	or     $0x2,%edx
8010986f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109878:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010987f:	83 ca 10             	or     $0x10,%edx
80109882:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010988b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80109892:	83 e2 9f             	and    $0xffffff9f,%edx
80109895:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010989b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010989e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801098a5:	83 ca 80             	or     $0xffffff80,%edx
801098a8:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801098ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098b1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801098b8:	83 e2 f0             	and    $0xfffffff0,%edx
801098bb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801098c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098c4:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801098cb:	83 e2 ef             	and    $0xffffffef,%edx
801098ce:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801098d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098d7:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801098de:	83 e2 df             	and    $0xffffffdf,%edx
801098e1:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801098e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098ea:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801098f1:	83 ca 40             	or     $0x40,%edx
801098f4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801098fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098fd:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109904:	83 ca 80             	or     $0xffffff80,%edx
80109907:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010990d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109910:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

	lgdt(c->gdt, sizeof(c->gdt));
80109916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109919:	83 c0 70             	add    $0x70,%eax
8010991c:	83 ec 08             	sub    $0x8,%esp
8010991f:	6a 38                	push   $0x38
80109921:	50                   	push   %eax
80109922:	e8 38 fb ff ff       	call   8010945f <lgdt>
80109927:	83 c4 10             	add    $0x10,%esp
	loadgs(SEG_KCPU << 3);
8010992a:	83 ec 0c             	sub    $0xc,%esp
8010992d:	6a 18                	push   $0x18
8010992f:	e8 6c fb ff ff       	call   801094a0 <loadgs>
80109934:	83 c4 10             	add    $0x10,%esp

	// Initialize cpu-local storage.
	cpu = c;
80109937:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010993a:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
	proc = 0;
80109940:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80109947:	00 00 00 00 
}
8010994b:	90                   	nop
8010994c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010994f:	c9                   	leave  
80109950:	c3                   	ret    

80109951 <walkpgdir>:

// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *walkpgdir(pde_t * pgdir, const void *va, int alloc)
{
80109951:	55                   	push   %ebp
80109952:	89 e5                	mov    %esp,%ebp
80109954:	83 ec 18             	sub    $0x18,%esp
	pde_t *pde;
	pte_t *pgtab;

	pde = &pgdir[PDX(va)];
80109957:	8b 45 0c             	mov    0xc(%ebp),%eax
8010995a:	c1 e8 16             	shr    $0x16,%eax
8010995d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109964:	8b 45 08             	mov    0x8(%ebp),%eax
80109967:	01 d0                	add    %edx,%eax
80109969:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (*pde & PTE_P) {
8010996c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010996f:	8b 00                	mov    (%eax),%eax
80109971:	83 e0 01             	and    $0x1,%eax
80109974:	85 c0                	test   %eax,%eax
80109976:	74 18                	je     80109990 <walkpgdir+0x3f>
		pgtab = (pte_t *) p2v(PTE_ADDR(*pde));
80109978:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010997b:	8b 00                	mov    (%eax),%eax
8010997d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109982:	50                   	push   %eax
80109983:	e8 47 fb ff ff       	call   801094cf <p2v>
80109988:	83 c4 04             	add    $0x4,%esp
8010998b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010998e:	eb 48                	jmp    801099d8 <walkpgdir+0x87>
	} else {
		if (!alloc || (pgtab = (pte_t *) kalloc()) == 0)
80109990:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80109994:	74 0e                	je     801099a4 <walkpgdir+0x53>
80109996:	e8 cf 92 ff ff       	call   80102c6a <kalloc>
8010999b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010999e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801099a2:	75 07                	jne    801099ab <walkpgdir+0x5a>
			return 0;
801099a4:	b8 00 00 00 00       	mov    $0x0,%eax
801099a9:	eb 44                	jmp    801099ef <walkpgdir+0x9e>
		// Make sure all those PTE_P bits are zero.
		memset(pgtab, 0, PGSIZE);
801099ab:	83 ec 04             	sub    $0x4,%esp
801099ae:	68 00 10 00 00       	push   $0x1000
801099b3:	6a 00                	push   $0x0
801099b5:	ff 75 f4             	pushl  -0xc(%ebp)
801099b8:	e8 33 d3 ff ff       	call   80106cf0 <memset>
801099bd:	83 c4 10             	add    $0x10,%esp
		// The permissions here are overly generous, but they can
		// be further restricted by the permissions in the page table 
		// entries, if necessary.
		*pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
801099c0:	83 ec 0c             	sub    $0xc,%esp
801099c3:	ff 75 f4             	pushl  -0xc(%ebp)
801099c6:	e8 f7 fa ff ff       	call   801094c2 <v2p>
801099cb:	83 c4 10             	add    $0x10,%esp
801099ce:	83 c8 07             	or     $0x7,%eax
801099d1:	89 c2                	mov    %eax,%edx
801099d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099d6:	89 10                	mov    %edx,(%eax)
	}
	return &pgtab[PTX(va)];
801099d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801099db:	c1 e8 0c             	shr    $0xc,%eax
801099de:	25 ff 03 00 00       	and    $0x3ff,%eax
801099e3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801099ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099ed:	01 d0                	add    %edx,%eax
}
801099ef:	c9                   	leave  
801099f0:	c3                   	ret    

801099f1 <mappages>:

// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int mappages(pde_t * pgdir, void *va, uint size, uint pa, int perm)
{
801099f1:	55                   	push   %ebp
801099f2:	89 e5                	mov    %esp,%ebp
801099f4:	83 ec 18             	sub    $0x18,%esp
	char *a, *last;
	pte_t *pte;

	a = (char *)PGROUNDDOWN((uint) va);
801099f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801099fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801099ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
	last = (char *)PGROUNDDOWN(((uint) va) + size - 1);
80109a02:	8b 55 0c             	mov    0xc(%ebp),%edx
80109a05:	8b 45 10             	mov    0x10(%ebp),%eax
80109a08:	01 d0                	add    %edx,%eax
80109a0a:	83 e8 01             	sub    $0x1,%eax
80109a0d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109a12:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (;;) {
		if ((pte = walkpgdir(pgdir, a, 1)) == 0)
80109a15:	83 ec 04             	sub    $0x4,%esp
80109a18:	6a 01                	push   $0x1
80109a1a:	ff 75 f4             	pushl  -0xc(%ebp)
80109a1d:	ff 75 08             	pushl  0x8(%ebp)
80109a20:	e8 2c ff ff ff       	call   80109951 <walkpgdir>
80109a25:	83 c4 10             	add    $0x10,%esp
80109a28:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109a2b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109a2f:	75 07                	jne    80109a38 <mappages+0x47>
			return -1;
80109a31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109a36:	eb 47                	jmp    80109a7f <mappages+0x8e>
		if (*pte & PTE_P)
80109a38:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a3b:	8b 00                	mov    (%eax),%eax
80109a3d:	83 e0 01             	and    $0x1,%eax
80109a40:	85 c0                	test   %eax,%eax
80109a42:	74 0d                	je     80109a51 <mappages+0x60>
			panic("remap");
80109a44:	83 ec 0c             	sub    $0xc,%esp
80109a47:	68 10 af 10 80       	push   $0x8010af10
80109a4c:	e8 15 6b ff ff       	call   80100566 <panic>
		*pte = pa | perm | PTE_P;
80109a51:	8b 45 18             	mov    0x18(%ebp),%eax
80109a54:	0b 45 14             	or     0x14(%ebp),%eax
80109a57:	83 c8 01             	or     $0x1,%eax
80109a5a:	89 c2                	mov    %eax,%edx
80109a5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a5f:	89 10                	mov    %edx,(%eax)
		if (a == last)
80109a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a64:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80109a67:	74 10                	je     80109a79 <mappages+0x88>
			break;
		a += PGSIZE;
80109a69:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
		pa += PGSIZE;
80109a70:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
	}
80109a77:	eb 9c                	jmp    80109a15 <mappages+0x24>
			return -1;
		if (*pte & PTE_P)
			panic("remap");
		*pte = pa | perm | PTE_P;
		if (a == last)
			break;
80109a79:	90                   	nop
		a += PGSIZE;
		pa += PGSIZE;
	}
	return 0;
80109a7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109a7f:	c9                   	leave  
80109a80:	c3                   	ret    

80109a81 <setupkvm>:
	(void *)DEVSPACE, DEVSPACE, 0, PTE_W},	// more devices
};

// Set up kernel part of a page table.
pde_t *setupkvm(void)
{
80109a81:	55                   	push   %ebp
80109a82:	89 e5                	mov    %esp,%ebp
80109a84:	53                   	push   %ebx
80109a85:	83 ec 14             	sub    $0x14,%esp
	pde_t *pgdir;
	struct kmap *k;

	if ((pgdir = (pde_t *) kalloc()) == 0)
80109a88:	e8 dd 91 ff ff       	call   80102c6a <kalloc>
80109a8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109a90:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109a94:	75 0a                	jne    80109aa0 <setupkvm+0x1f>
		return 0;
80109a96:	b8 00 00 00 00       	mov    $0x0,%eax
80109a9b:	e9 8e 00 00 00       	jmp    80109b2e <setupkvm+0xad>
	memset(pgdir, 0, PGSIZE);
80109aa0:	83 ec 04             	sub    $0x4,%esp
80109aa3:	68 00 10 00 00       	push   $0x1000
80109aa8:	6a 00                	push   $0x0
80109aaa:	ff 75 f0             	pushl  -0x10(%ebp)
80109aad:	e8 3e d2 ff ff       	call   80106cf0 <memset>
80109ab2:	83 c4 10             	add    $0x10,%esp
	if (p2v(PHYSTOP) > (void *)DEVSPACE)
80109ab5:	83 ec 0c             	sub    $0xc,%esp
80109ab8:	68 00 00 00 0e       	push   $0xe000000
80109abd:	e8 0d fa ff ff       	call   801094cf <p2v>
80109ac2:	83 c4 10             	add    $0x10,%esp
80109ac5:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80109aca:	76 0d                	jbe    80109ad9 <setupkvm+0x58>
		panic("PHYSTOP too high");
80109acc:	83 ec 0c             	sub    $0xc,%esp
80109acf:	68 16 af 10 80       	push   $0x8010af16
80109ad4:	e8 8d 6a ff ff       	call   80100566 <panic>
	for (k = kmap; k < &kmap[NELEM(kmap)]; k++)
80109ad9:	c7 45 f4 c0 e4 10 80 	movl   $0x8010e4c0,-0xc(%ebp)
80109ae0:	eb 40                	jmp    80109b22 <setupkvm+0xa1>
		if (mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80109ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ae5:	8b 48 0c             	mov    0xc(%eax),%ecx
			     (uint) k->phys_start, k->perm) < 0)
80109ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aeb:	8b 50 04             	mov    0x4(%eax),%edx
		return 0;
	memset(pgdir, 0, PGSIZE);
	if (p2v(PHYSTOP) > (void *)DEVSPACE)
		panic("PHYSTOP too high");
	for (k = kmap; k < &kmap[NELEM(kmap)]; k++)
		if (mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80109aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109af1:	8b 58 08             	mov    0x8(%eax),%ebx
80109af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109af7:	8b 40 04             	mov    0x4(%eax),%eax
80109afa:	29 c3                	sub    %eax,%ebx
80109afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aff:	8b 00                	mov    (%eax),%eax
80109b01:	83 ec 0c             	sub    $0xc,%esp
80109b04:	51                   	push   %ecx
80109b05:	52                   	push   %edx
80109b06:	53                   	push   %ebx
80109b07:	50                   	push   %eax
80109b08:	ff 75 f0             	pushl  -0x10(%ebp)
80109b0b:	e8 e1 fe ff ff       	call   801099f1 <mappages>
80109b10:	83 c4 20             	add    $0x20,%esp
80109b13:	85 c0                	test   %eax,%eax
80109b15:	79 07                	jns    80109b1e <setupkvm+0x9d>
			     (uint) k->phys_start, k->perm) < 0)
			return 0;
80109b17:	b8 00 00 00 00       	mov    $0x0,%eax
80109b1c:	eb 10                	jmp    80109b2e <setupkvm+0xad>
	if ((pgdir = (pde_t *) kalloc()) == 0)
		return 0;
	memset(pgdir, 0, PGSIZE);
	if (p2v(PHYSTOP) > (void *)DEVSPACE)
		panic("PHYSTOP too high");
	for (k = kmap; k < &kmap[NELEM(kmap)]; k++)
80109b1e:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80109b22:	81 7d f4 00 e5 10 80 	cmpl   $0x8010e500,-0xc(%ebp)
80109b29:	72 b7                	jb     80109ae2 <setupkvm+0x61>
		if (mappages(pgdir, k->virt, k->phys_end - k->phys_start,
			     (uint) k->phys_start, k->perm) < 0)
			return 0;
	return pgdir;
80109b2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80109b2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109b31:	c9                   	leave  
80109b32:	c3                   	ret    

80109b33 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void kvmalloc(void)
{
80109b33:	55                   	push   %ebp
80109b34:	89 e5                	mov    %esp,%ebp
80109b36:	83 ec 08             	sub    $0x8,%esp
	kpgdir = setupkvm();
80109b39:	e8 43 ff ff ff       	call   80109a81 <setupkvm>
80109b3e:	a3 d8 4f 12 80       	mov    %eax,0x80124fd8
	switchkvm();
80109b43:	e8 03 00 00 00       	call   80109b4b <switchkvm>
}
80109b48:	90                   	nop
80109b49:	c9                   	leave  
80109b4a:	c3                   	ret    

80109b4b <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void switchkvm(void)
{
80109b4b:	55                   	push   %ebp
80109b4c:	89 e5                	mov    %esp,%ebp
	lcr3(v2p(kpgdir));	// switch to the kernel page table
80109b4e:	a1 d8 4f 12 80       	mov    0x80124fd8,%eax
80109b53:	50                   	push   %eax
80109b54:	e8 69 f9 ff ff       	call   801094c2 <v2p>
80109b59:	83 c4 04             	add    $0x4,%esp
80109b5c:	50                   	push   %eax
80109b5d:	e8 54 f9 ff ff       	call   801094b6 <lcr3>
80109b62:	83 c4 04             	add    $0x4,%esp
}
80109b65:	90                   	nop
80109b66:	c9                   	leave  
80109b67:	c3                   	ret    

80109b68 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void switchuvm(struct proc *p)
{
80109b68:	55                   	push   %ebp
80109b69:	89 e5                	mov    %esp,%ebp
80109b6b:	56                   	push   %esi
80109b6c:	53                   	push   %ebx
	pushcli();
80109b6d:	e8 78 d0 ff ff       	call   80106bea <pushcli>
	cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts) - 1, 0);
80109b72:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109b78:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109b7f:	83 c2 08             	add    $0x8,%edx
80109b82:	89 d6                	mov    %edx,%esi
80109b84:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109b8b:	83 c2 08             	add    $0x8,%edx
80109b8e:	c1 ea 10             	shr    $0x10,%edx
80109b91:	89 d3                	mov    %edx,%ebx
80109b93:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109b9a:	83 c2 08             	add    $0x8,%edx
80109b9d:	c1 ea 18             	shr    $0x18,%edx
80109ba0:	89 d1                	mov    %edx,%ecx
80109ba2:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80109ba9:	67 00 
80109bab:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80109bb2:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80109bb8:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109bbf:	83 e2 f0             	and    $0xfffffff0,%edx
80109bc2:	83 ca 09             	or     $0x9,%edx
80109bc5:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109bcb:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109bd2:	83 ca 10             	or     $0x10,%edx
80109bd5:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109bdb:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109be2:	83 e2 9f             	and    $0xffffff9f,%edx
80109be5:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109beb:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109bf2:	83 ca 80             	or     $0xffffff80,%edx
80109bf5:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109bfb:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109c02:	83 e2 f0             	and    $0xfffffff0,%edx
80109c05:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109c0b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109c12:	83 e2 ef             	and    $0xffffffef,%edx
80109c15:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109c1b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109c22:	83 e2 df             	and    $0xffffffdf,%edx
80109c25:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109c2b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109c32:	83 ca 40             	or     $0x40,%edx
80109c35:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109c3b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109c42:	83 e2 7f             	and    $0x7f,%edx
80109c45:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109c4b:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
	cpu->gdt[SEG_TSS].s = 0;
80109c51:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109c57:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109c5e:	83 e2 ef             	and    $0xffffffef,%edx
80109c61:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
	cpu->ts.ss0 = SEG_KDATA << 3;
80109c67:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109c6d:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
	cpu->ts.esp0 = (uint) proc->kstack + KSTACKSIZE;
80109c73:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109c79:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109c80:	8b 52 08             	mov    0x8(%edx),%edx
80109c83:	81 c2 00 10 00 00    	add    $0x1000,%edx
80109c89:	89 50 0c             	mov    %edx,0xc(%eax)
	ltr(SEG_TSS << 3);
80109c8c:	83 ec 0c             	sub    $0xc,%esp
80109c8f:	6a 30                	push   $0x30
80109c91:	e8 f3 f7 ff ff       	call   80109489 <ltr>
80109c96:	83 c4 10             	add    $0x10,%esp
	if (p->pgdir == 0)
80109c99:	8b 45 08             	mov    0x8(%ebp),%eax
80109c9c:	8b 40 04             	mov    0x4(%eax),%eax
80109c9f:	85 c0                	test   %eax,%eax
80109ca1:	75 0d                	jne    80109cb0 <switchuvm+0x148>
		panic("switchuvm: no pgdir");
80109ca3:	83 ec 0c             	sub    $0xc,%esp
80109ca6:	68 27 af 10 80       	push   $0x8010af27
80109cab:	e8 b6 68 ff ff       	call   80100566 <panic>
	lcr3(v2p(p->pgdir));	// switch to new address space
80109cb0:	8b 45 08             	mov    0x8(%ebp),%eax
80109cb3:	8b 40 04             	mov    0x4(%eax),%eax
80109cb6:	83 ec 0c             	sub    $0xc,%esp
80109cb9:	50                   	push   %eax
80109cba:	e8 03 f8 ff ff       	call   801094c2 <v2p>
80109cbf:	83 c4 10             	add    $0x10,%esp
80109cc2:	83 ec 0c             	sub    $0xc,%esp
80109cc5:	50                   	push   %eax
80109cc6:	e8 eb f7 ff ff       	call   801094b6 <lcr3>
80109ccb:	83 c4 10             	add    $0x10,%esp
	popcli();
80109cce:	e8 5c cf ff ff       	call   80106c2f <popcli>
}
80109cd3:	90                   	nop
80109cd4:	8d 65 f8             	lea    -0x8(%ebp),%esp
80109cd7:	5b                   	pop    %ebx
80109cd8:	5e                   	pop    %esi
80109cd9:	5d                   	pop    %ebp
80109cda:	c3                   	ret    

80109cdb <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void inituvm(pde_t * pgdir, char *init, uint sz)
{
80109cdb:	55                   	push   %ebp
80109cdc:	89 e5                	mov    %esp,%ebp
80109cde:	83 ec 18             	sub    $0x18,%esp
	char *mem;

	if (sz >= PGSIZE)
80109ce1:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80109ce8:	76 0d                	jbe    80109cf7 <inituvm+0x1c>
		panic("inituvm: more than a page");
80109cea:	83 ec 0c             	sub    $0xc,%esp
80109ced:	68 3b af 10 80       	push   $0x8010af3b
80109cf2:	e8 6f 68 ff ff       	call   80100566 <panic>
	mem = kalloc();
80109cf7:	e8 6e 8f ff ff       	call   80102c6a <kalloc>
80109cfc:	89 45 f4             	mov    %eax,-0xc(%ebp)
	memset(mem, 0, PGSIZE);
80109cff:	83 ec 04             	sub    $0x4,%esp
80109d02:	68 00 10 00 00       	push   $0x1000
80109d07:	6a 00                	push   $0x0
80109d09:	ff 75 f4             	pushl  -0xc(%ebp)
80109d0c:	e8 df cf ff ff       	call   80106cf0 <memset>
80109d11:	83 c4 10             	add    $0x10,%esp
	mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W | PTE_U);
80109d14:	83 ec 0c             	sub    $0xc,%esp
80109d17:	ff 75 f4             	pushl  -0xc(%ebp)
80109d1a:	e8 a3 f7 ff ff       	call   801094c2 <v2p>
80109d1f:	83 c4 10             	add    $0x10,%esp
80109d22:	83 ec 0c             	sub    $0xc,%esp
80109d25:	6a 06                	push   $0x6
80109d27:	50                   	push   %eax
80109d28:	68 00 10 00 00       	push   $0x1000
80109d2d:	6a 00                	push   $0x0
80109d2f:	ff 75 08             	pushl  0x8(%ebp)
80109d32:	e8 ba fc ff ff       	call   801099f1 <mappages>
80109d37:	83 c4 20             	add    $0x20,%esp
	memmove(mem, init, sz);
80109d3a:	83 ec 04             	sub    $0x4,%esp
80109d3d:	ff 75 10             	pushl  0x10(%ebp)
80109d40:	ff 75 0c             	pushl  0xc(%ebp)
80109d43:	ff 75 f4             	pushl  -0xc(%ebp)
80109d46:	e8 64 d0 ff ff       	call   80106daf <memmove>
80109d4b:	83 c4 10             	add    $0x10,%esp
}
80109d4e:	90                   	nop
80109d4f:	c9                   	leave  
80109d50:	c3                   	ret    

80109d51 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int loaduvm(pde_t * pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80109d51:	55                   	push   %ebp
80109d52:	89 e5                	mov    %esp,%ebp
80109d54:	53                   	push   %ebx
80109d55:	83 ec 14             	sub    $0x14,%esp
	uint i, pa, n;
	pte_t *pte;

	if ((uint) addr % PGSIZE != 0)
80109d58:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d5b:	25 ff 0f 00 00       	and    $0xfff,%eax
80109d60:	85 c0                	test   %eax,%eax
80109d62:	74 0d                	je     80109d71 <loaduvm+0x20>
		panic("loaduvm: addr must be page aligned");
80109d64:	83 ec 0c             	sub    $0xc,%esp
80109d67:	68 58 af 10 80       	push   $0x8010af58
80109d6c:	e8 f5 67 ff ff       	call   80100566 <panic>
	for (i = 0; i < sz; i += PGSIZE) {
80109d71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109d78:	e9 95 00 00 00       	jmp    80109e12 <loaduvm+0xc1>
		if ((pte = walkpgdir(pgdir, addr + i, 0)) == 0)
80109d7d:	8b 55 0c             	mov    0xc(%ebp),%edx
80109d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d83:	01 d0                	add    %edx,%eax
80109d85:	83 ec 04             	sub    $0x4,%esp
80109d88:	6a 00                	push   $0x0
80109d8a:	50                   	push   %eax
80109d8b:	ff 75 08             	pushl  0x8(%ebp)
80109d8e:	e8 be fb ff ff       	call   80109951 <walkpgdir>
80109d93:	83 c4 10             	add    $0x10,%esp
80109d96:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109d99:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109d9d:	75 0d                	jne    80109dac <loaduvm+0x5b>
			panic("loaduvm: address should exist");
80109d9f:	83 ec 0c             	sub    $0xc,%esp
80109da2:	68 7b af 10 80       	push   $0x8010af7b
80109da7:	e8 ba 67 ff ff       	call   80100566 <panic>
		pa = PTE_ADDR(*pte);
80109dac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109daf:	8b 00                	mov    (%eax),%eax
80109db1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109db6:	89 45 e8             	mov    %eax,-0x18(%ebp)
		if (sz - i < PGSIZE)
80109db9:	8b 45 18             	mov    0x18(%ebp),%eax
80109dbc:	2b 45 f4             	sub    -0xc(%ebp),%eax
80109dbf:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80109dc4:	77 0b                	ja     80109dd1 <loaduvm+0x80>
			n = sz - i;
80109dc6:	8b 45 18             	mov    0x18(%ebp),%eax
80109dc9:	2b 45 f4             	sub    -0xc(%ebp),%eax
80109dcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109dcf:	eb 07                	jmp    80109dd8 <loaduvm+0x87>
		else
			n = PGSIZE;
80109dd1:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
		if (readi(ip, p2v(pa), offset + i, n) != n)
80109dd8:	8b 55 14             	mov    0x14(%ebp),%edx
80109ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dde:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80109de1:	83 ec 0c             	sub    $0xc,%esp
80109de4:	ff 75 e8             	pushl  -0x18(%ebp)
80109de7:	e8 e3 f6 ff ff       	call   801094cf <p2v>
80109dec:	83 c4 10             	add    $0x10,%esp
80109def:	ff 75 f0             	pushl  -0x10(%ebp)
80109df2:	53                   	push   %ebx
80109df3:	50                   	push   %eax
80109df4:	ff 75 10             	pushl  0x10(%ebp)
80109df7:	e8 e0 80 ff ff       	call   80101edc <readi>
80109dfc:	83 c4 10             	add    $0x10,%esp
80109dff:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80109e02:	74 07                	je     80109e0b <loaduvm+0xba>
			return -1;
80109e04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109e09:	eb 18                	jmp    80109e23 <loaduvm+0xd2>
	uint i, pa, n;
	pte_t *pte;

	if ((uint) addr % PGSIZE != 0)
		panic("loaduvm: addr must be page aligned");
	for (i = 0; i < sz; i += PGSIZE) {
80109e0b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e15:	3b 45 18             	cmp    0x18(%ebp),%eax
80109e18:	0f 82 5f ff ff ff    	jb     80109d7d <loaduvm+0x2c>
		else
			n = PGSIZE;
		if (readi(ip, p2v(pa), offset + i, n) != n)
			return -1;
	}
	return 0;
80109e1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109e23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109e26:	c9                   	leave  
80109e27:	c3                   	ret    

80109e28 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int allocuvm(pde_t * pgdir, uint oldsz, uint newsz)
{
80109e28:	55                   	push   %ebp
80109e29:	89 e5                	mov    %esp,%ebp
80109e2b:	83 ec 18             	sub    $0x18,%esp
	char *mem;
	uint a;

	if (newsz >= KERNBASE)
80109e2e:	8b 45 10             	mov    0x10(%ebp),%eax
80109e31:	85 c0                	test   %eax,%eax
80109e33:	79 0a                	jns    80109e3f <allocuvm+0x17>
		return 0;
80109e35:	b8 00 00 00 00       	mov    $0x0,%eax
80109e3a:	e9 af 00 00 00       	jmp    80109eee <allocuvm+0xc6>
	if (newsz < oldsz)
80109e3f:	8b 45 10             	mov    0x10(%ebp),%eax
80109e42:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109e45:	73 08                	jae    80109e4f <allocuvm+0x27>
		return oldsz;
80109e47:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e4a:	e9 9f 00 00 00       	jmp    80109eee <allocuvm+0xc6>

	a = PGROUNDUP(oldsz);
80109e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e52:	05 ff 0f 00 00       	add    $0xfff,%eax
80109e57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109e5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	//loops making page tables until the wanted new size is achieved
	for (; a < newsz; a += PGSIZE) {
80109e5f:	eb 7e                	jmp    80109edf <allocuvm+0xb7>
		mem = kalloc(); //mem is physical location of page, but only for kernel
80109e61:	e8 04 8e ff ff       	call   80102c6a <kalloc>
80109e66:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (mem == 0) {
80109e69:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109e6d:	75 2a                	jne    80109e99 <allocuvm+0x71>
			cprintf("allocuvm out of memory\n");
80109e6f:	83 ec 0c             	sub    $0xc,%esp
80109e72:	68 99 af 10 80       	push   $0x8010af99
80109e77:	e8 4a 65 ff ff       	call   801003c6 <cprintf>
80109e7c:	83 c4 10             	add    $0x10,%esp
			deallocuvm(pgdir, newsz, oldsz, 0);
80109e7f:	6a 00                	push   $0x0
80109e81:	ff 75 0c             	pushl  0xc(%ebp)
80109e84:	ff 75 10             	pushl  0x10(%ebp)
80109e87:	ff 75 08             	pushl  0x8(%ebp)
80109e8a:	e8 61 00 00 00       	call   80109ef0 <deallocuvm>
80109e8f:	83 c4 10             	add    $0x10,%esp
			return 0;
80109e92:	b8 00 00 00 00       	mov    $0x0,%eax
80109e97:	eb 55                	jmp    80109eee <allocuvm+0xc6>
		}
		memset(mem, 0, PGSIZE);
80109e99:	83 ec 04             	sub    $0x4,%esp
80109e9c:	68 00 10 00 00       	push   $0x1000
80109ea1:	6a 00                	push   $0x0
80109ea3:	ff 75 f0             	pushl  -0x10(%ebp)
80109ea6:	e8 45 ce ff ff       	call   80106cf0 <memset>
80109eab:	83 c4 10             	add    $0x10,%esp
		mappages(pgdir, (char *)a, PGSIZE, v2p(mem), PTE_W | PTE_U); //gives physical address to user
80109eae:	83 ec 0c             	sub    $0xc,%esp
80109eb1:	ff 75 f0             	pushl  -0x10(%ebp)
80109eb4:	e8 09 f6 ff ff       	call   801094c2 <v2p>
80109eb9:	83 c4 10             	add    $0x10,%esp
80109ebc:	89 c2                	mov    %eax,%edx
80109ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ec1:	83 ec 0c             	sub    $0xc,%esp
80109ec4:	6a 06                	push   $0x6
80109ec6:	52                   	push   %edx
80109ec7:	68 00 10 00 00       	push   $0x1000
80109ecc:	50                   	push   %eax
80109ecd:	ff 75 08             	pushl  0x8(%ebp)
80109ed0:	e8 1c fb ff ff       	call   801099f1 <mappages>
80109ed5:	83 c4 20             	add    $0x20,%esp
	if (newsz < oldsz)
		return oldsz;

	a = PGROUNDUP(oldsz);
	//loops making page tables until the wanted new size is achieved
	for (; a < newsz; a += PGSIZE) {
80109ed8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ee2:	3b 45 10             	cmp    0x10(%ebp),%eax
80109ee5:	0f 82 76 ff ff ff    	jb     80109e61 <allocuvm+0x39>
			return 0;
		}
		memset(mem, 0, PGSIZE);
		mappages(pgdir, (char *)a, PGSIZE, v2p(mem), PTE_W | PTE_U); //gives physical address to user
	}
	return newsz;
80109eeb:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109eee:	c9                   	leave  
80109eef:	c3                   	ret    

80109ef0 <deallocuvm>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int deallocuvm(pde_t * pgdir, uint oldsz, uint newsz, int accChange)
{
80109ef0:	55                   	push   %ebp
80109ef1:	89 e5                	mov    %esp,%ebp
80109ef3:	83 ec 28             	sub    $0x28,%esp
	pte_t *pte;
	uint a, pa;
	uint foundPA = 0;
80109ef6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (newsz >= oldsz)
80109efd:	8b 45 10             	mov    0x10(%ebp),%eax
80109f00:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109f03:	72 08                	jb     80109f0d <deallocuvm+0x1d>
		return oldsz;
80109f05:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f08:	e9 d7 00 00 00       	jmp    80109fe4 <deallocuvm+0xf4>

//have case where if shm, then call deallocshm for that block

	a = PGROUNDUP(newsz);
80109f0d:	8b 45 10             	mov    0x10(%ebp),%eax
80109f10:	05 ff 0f 00 00       	add    $0xfff,%eax
80109f15:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109f1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (; a < oldsz; a += PGSIZE) {
80109f1d:	e9 b3 00 00 00       	jmp    80109fd5 <deallocuvm+0xe5>
		pte = walkpgdir(pgdir, (char *)a, 0);
80109f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f25:	83 ec 04             	sub    $0x4,%esp
80109f28:	6a 00                	push   $0x0
80109f2a:	50                   	push   %eax
80109f2b:	ff 75 08             	pushl  0x8(%ebp)
80109f2e:	e8 1e fa ff ff       	call   80109951 <walkpgdir>
80109f33:	83 c4 10             	add    $0x10,%esp
80109f36:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if (!pte)
80109f39:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109f3d:	75 0c                	jne    80109f4b <deallocuvm+0x5b>
			a += (NPTENTRIES - 1) * PGSIZE;
80109f3f:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80109f46:	e9 83 00 00 00       	jmp    80109fce <deallocuvm+0xde>
		else if ((*pte & PTE_P) != 0) 
80109f4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f4e:	8b 00                	mov    (%eax),%eax
80109f50:	83 e0 01             	and    $0x1,%eax
80109f53:	85 c0                	test   %eax,%eax
80109f55:	74 77                	je     80109fce <deallocuvm+0xde>
		{
			pa = PTE_ADDR(*pte);
80109f57:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f5a:	8b 00                	mov    (%eax),%eax
80109f5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109f61:	89 45 e8             	mov    %eax,-0x18(%ebp)
			if (pa == 0)
80109f64:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109f68:	75 0d                	jne    80109f77 <deallocuvm+0x87>
				panic("kfree");
80109f6a:	83 ec 0c             	sub    $0xc,%esp
80109f6d:	68 b1 af 10 80       	push   $0x8010afb1
80109f72:	e8 ef 65 ff ff       	call   80100566 <panic>
		
			if((foundPA = shm_arr_findPA(pa, accChange)) != -1) //if statement added for mod2 maybe subtract 1 instead of leaving same
80109f77:	83 ec 08             	sub    $0x8,%esp
80109f7a:	ff 75 14             	pushl  0x14(%ebp)
80109f7d:	ff 75 e8             	pushl  -0x18(%ebp)
80109f80:	e8 2d a1 ff ff       	call   801040b2 <shm_arr_findPA>
80109f85:	83 c4 10             	add    $0x10,%esp
80109f88:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109f8b:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109f8f:	74 15                	je     80109fa6 <deallocuvm+0xb6>
			{
				cprintf("\nfreevm: SHM Region [%p] found, not deleting region\n", foundPA);
80109f91:	83 ec 08             	sub    $0x8,%esp
80109f94:	ff 75 f0             	pushl  -0x10(%ebp)
80109f97:	68 b8 af 10 80       	push   $0x8010afb8
80109f9c:	e8 25 64 ff ff       	call   801003c6 <cprintf>
80109fa1:	83 c4 10             	add    $0x10,%esp
				continue;
80109fa4:	eb 28                	jmp    80109fce <deallocuvm+0xde>
			}
		
			else
			{
				char *v = p2v(pa);
80109fa6:	83 ec 0c             	sub    $0xc,%esp
80109fa9:	ff 75 e8             	pushl  -0x18(%ebp)
80109fac:	e8 1e f5 ff ff       	call   801094cf <p2v>
80109fb1:	83 c4 10             	add    $0x10,%esp
80109fb4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				kfree(v);
80109fb7:	83 ec 0c             	sub    $0xc,%esp
80109fba:	ff 75 e4             	pushl  -0x1c(%ebp)
80109fbd:	e8 0b 8c ff ff       	call   80102bcd <kfree>
80109fc2:	83 c4 10             	add    $0x10,%esp
				*pte = 0;
80109fc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109fc8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return oldsz;

//have case where if shm, then call deallocshm for that block

	a = PGROUNDUP(newsz);
	for (; a < oldsz; a += PGSIZE) {
80109fce:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fd8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109fdb:	0f 82 41 ff ff ff    	jb     80109f22 <deallocuvm+0x32>
				kfree(v);
				*pte = 0;
			}
		}
	}
	return newsz;
80109fe1:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109fe4:	c9                   	leave  
80109fe5:	c3                   	ret    

80109fe6 <freevm>:
// Free a page table and all the physical memory pages
// in the user part.
//access change determines to either decrement reference count if a wait is called or keep reference count as is if there is an exec
//call becasue that exec call can be switched back to and might need the SHM region. Therefore, it is still a reference.
void freevm(pde_t * pgdir, int accessChange)//accessChange added for mod2
{
80109fe6:	55                   	push   %ebp
80109fe7:	89 e5                	mov    %esp,%ebp
80109fe9:	83 ec 18             	sub    $0x18,%esp
	uint i;

	if (pgdir == 0)
80109fec:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80109ff0:	75 0d                	jne    80109fff <freevm+0x19>
		panic("freevm: no pgdir");
80109ff2:	83 ec 0c             	sub    $0xc,%esp
80109ff5:	68 ed af 10 80       	push   $0x8010afed
80109ffa:	e8 67 65 ff ff       	call   80100566 <panic>
	deallocuvm(pgdir, KERNBASE, 0, accessChange);
80109fff:	ff 75 0c             	pushl  0xc(%ebp)
8010a002:	6a 00                	push   $0x0
8010a004:	68 00 00 00 80       	push   $0x80000000
8010a009:	ff 75 08             	pushl  0x8(%ebp)
8010a00c:	e8 df fe ff ff       	call   80109ef0 <deallocuvm>
8010a011:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < NPDENTRIES; i++) {
8010a014:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010a01b:	eb 4f                	jmp    8010a06c <freevm+0x86>
		if (pgdir[i] & PTE_P) {
8010a01d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a020:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010a027:	8b 45 08             	mov    0x8(%ebp),%eax
8010a02a:	01 d0                	add    %edx,%eax
8010a02c:	8b 00                	mov    (%eax),%eax
8010a02e:	83 e0 01             	and    $0x1,%eax
8010a031:	85 c0                	test   %eax,%eax
8010a033:	74 33                	je     8010a068 <freevm+0x82>
			char *v = p2v(PTE_ADDR(pgdir[i]));
8010a035:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a038:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010a03f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a042:	01 d0                	add    %edx,%eax
8010a044:	8b 00                	mov    (%eax),%eax
8010a046:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a04b:	83 ec 0c             	sub    $0xc,%esp
8010a04e:	50                   	push   %eax
8010a04f:	e8 7b f4 ff ff       	call   801094cf <p2v>
8010a054:	83 c4 10             	add    $0x10,%esp
8010a057:	89 45 f0             	mov    %eax,-0x10(%ebp)
			kfree(v);
8010a05a:	83 ec 0c             	sub    $0xc,%esp
8010a05d:	ff 75 f0             	pushl  -0x10(%ebp)
8010a060:	e8 68 8b ff ff       	call   80102bcd <kfree>
8010a065:	83 c4 10             	add    $0x10,%esp
	uint i;

	if (pgdir == 0)
		panic("freevm: no pgdir");
	deallocuvm(pgdir, KERNBASE, 0, accessChange);
	for (i = 0; i < NPDENTRIES; i++) {
8010a068:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010a06c:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010a073:	76 a8                	jbe    8010a01d <freevm+0x37>
		if (pgdir[i] & PTE_P) {
			char *v = p2v(PTE_ADDR(pgdir[i]));
			kfree(v);
		}
	}
	kfree((char *)pgdir);
8010a075:	83 ec 0c             	sub    $0xc,%esp
8010a078:	ff 75 08             	pushl  0x8(%ebp)
8010a07b:	e8 4d 8b ff ff       	call   80102bcd <kfree>
8010a080:	83 c4 10             	add    $0x10,%esp
}
8010a083:	90                   	nop
8010a084:	c9                   	leave  
8010a085:	c3                   	ret    

8010a086 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void clearpteu(pde_t * pgdir, char *uva)
{
8010a086:	55                   	push   %ebp
8010a087:	89 e5                	mov    %esp,%ebp
8010a089:	83 ec 18             	sub    $0x18,%esp
	pte_t *pte;

	pte = walkpgdir(pgdir, uva, 0);
8010a08c:	83 ec 04             	sub    $0x4,%esp
8010a08f:	6a 00                	push   $0x0
8010a091:	ff 75 0c             	pushl  0xc(%ebp)
8010a094:	ff 75 08             	pushl  0x8(%ebp)
8010a097:	e8 b5 f8 ff ff       	call   80109951 <walkpgdir>
8010a09c:	83 c4 10             	add    $0x10,%esp
8010a09f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (pte == 0)
8010a0a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010a0a6:	75 0d                	jne    8010a0b5 <clearpteu+0x2f>
		panic("clearpteu");
8010a0a8:	83 ec 0c             	sub    $0xc,%esp
8010a0ab:	68 fe af 10 80       	push   $0x8010affe
8010a0b0:	e8 b1 64 ff ff       	call   80100566 <panic>
	*pte &= ~PTE_U;
8010a0b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0b8:	8b 00                	mov    (%eax),%eax
8010a0ba:	83 e0 fb             	and    $0xfffffffb,%eax
8010a0bd:	89 c2                	mov    %eax,%edx
8010a0bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0c2:	89 10                	mov    %edx,(%eax)
}
8010a0c4:	90                   	nop
8010a0c5:	c9                   	leave  
8010a0c6:	c3                   	ret    

8010a0c7 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t *copyuvm(pde_t * pgdir, uint sz)
{
8010a0c7:	55                   	push   %ebp
8010a0c8:	89 e5                	mov    %esp,%ebp
8010a0ca:	53                   	push   %ebx
8010a0cb:	83 ec 24             	sub    $0x24,%esp
	pde_t *d;
	pte_t *pte;
	uint pa, i, flags;
	char *mem;
	uint foundPA = 0;
8010a0ce:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if ((d = setupkvm()) == 0)
8010a0d5:	e8 a7 f9 ff ff       	call   80109a81 <setupkvm>
8010a0da:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010a0dd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010a0e1:	75 0a                	jne    8010a0ed <copyuvm+0x26>
		return 0;
8010a0e3:	b8 00 00 00 00       	mov    $0x0,%eax
8010a0e8:	e9 37 01 00 00       	jmp    8010a224 <copyuvm+0x15d>
	for (i = 0; i < sz; i += PGSIZE) {
8010a0ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010a0f4:	e9 01 01 00 00       	jmp    8010a1fa <copyuvm+0x133>
		if ((pte = walkpgdir(pgdir, (void *)i, 0)) == 0)
8010a0f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0fc:	83 ec 04             	sub    $0x4,%esp
8010a0ff:	6a 00                	push   $0x0
8010a101:	50                   	push   %eax
8010a102:	ff 75 08             	pushl  0x8(%ebp)
8010a105:	e8 47 f8 ff ff       	call   80109951 <walkpgdir>
8010a10a:	83 c4 10             	add    $0x10,%esp
8010a10d:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010a110:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010a114:	75 0d                	jne    8010a123 <copyuvm+0x5c>
			panic("copyuvm: pte should exist");
8010a116:	83 ec 0c             	sub    $0xc,%esp
8010a119:	68 08 b0 10 80       	push   $0x8010b008
8010a11e:	e8 43 64 ff ff       	call   80100566 <panic>
		if (!(*pte & PTE_P))
8010a123:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a126:	8b 00                	mov    (%eax),%eax
8010a128:	83 e0 01             	and    $0x1,%eax
8010a12b:	85 c0                	test   %eax,%eax
8010a12d:	75 0d                	jne    8010a13c <copyuvm+0x75>
			panic("copyuvm: page not present");
8010a12f:	83 ec 0c             	sub    $0xc,%esp
8010a132:	68 22 b0 10 80       	push   $0x8010b022
8010a137:	e8 2a 64 ff ff       	call   80100566 <panic>
		pa = PTE_ADDR(*pte);
8010a13c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a13f:	8b 00                	mov    (%eax),%eax
8010a141:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a146:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		flags = PTE_FLAGS(*pte);
8010a149:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a14c:	8b 00                	mov    (%eax),%eax
8010a14e:	25 ff 0f 00 00       	and    $0xfff,%eax
8010a153:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if((foundPA = shm_arr_findPA(pa, 1)) != -1) //if statement for mod2
8010a156:	83 ec 08             	sub    $0x8,%esp
8010a159:	6a 01                	push   $0x1
8010a15b:	ff 75 e4             	pushl  -0x1c(%ebp)
8010a15e:	e8 4f 9f ff ff       	call   801040b2 <shm_arr_findPA>
8010a163:	83 c4 10             	add    $0x10,%esp
8010a166:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010a169:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010a16d:	74 24                	je     8010a193 <copyuvm+0xcc>
		{
			//enter here if one of the found physical addresses in the parent's mapping is a SHM
			//maps the VA to the SHM address instead of allocating another page of physical memory
			//this maintains SHM region from parent in the child
			//doesn't keep track of virtual address corresponding to physical address. this is done by shm_assign() in fork()
			if (mappages(d, (void *)i, PGSIZE, foundPA, flags) < 0)
8010a16f:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a172:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a175:	83 ec 0c             	sub    $0xc,%esp
8010a178:	52                   	push   %edx
8010a179:	ff 75 f0             	pushl  -0x10(%ebp)
8010a17c:	68 00 10 00 00       	push   $0x1000
8010a181:	50                   	push   %eax
8010a182:	ff 75 ec             	pushl  -0x14(%ebp)
8010a185:	e8 67 f8 ff ff       	call   801099f1 <mappages>
8010a18a:	83 c4 20             	add    $0x20,%esp
8010a18d:	85 c0                	test   %eax,%eax
8010a18f:	79 62                	jns    8010a1f3 <copyuvm+0x12c>
				goto bad;
8010a191:	eb 7c                	jmp    8010a20f <copyuvm+0x148>
		}
		else
		{
			if ((mem = kalloc()) == 0)
8010a193:	e8 d2 8a ff ff       	call   80102c6a <kalloc>
8010a198:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010a19b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010a19f:	74 6a                	je     8010a20b <copyuvm+0x144>
				goto bad;
			memmove(mem, (char *)p2v(pa), PGSIZE);
8010a1a1:	83 ec 0c             	sub    $0xc,%esp
8010a1a4:	ff 75 e4             	pushl  -0x1c(%ebp)
8010a1a7:	e8 23 f3 ff ff       	call   801094cf <p2v>
8010a1ac:	83 c4 10             	add    $0x10,%esp
8010a1af:	83 ec 04             	sub    $0x4,%esp
8010a1b2:	68 00 10 00 00       	push   $0x1000
8010a1b7:	50                   	push   %eax
8010a1b8:	ff 75 dc             	pushl  -0x24(%ebp)
8010a1bb:	e8 ef cb ff ff       	call   80106daf <memmove>
8010a1c0:	83 c4 10             	add    $0x10,%esp
			if (mappages(d, (void *)i, PGSIZE, v2p(mem), flags) < 0)
8010a1c3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
8010a1c6:	83 ec 0c             	sub    $0xc,%esp
8010a1c9:	ff 75 dc             	pushl  -0x24(%ebp)
8010a1cc:	e8 f1 f2 ff ff       	call   801094c2 <v2p>
8010a1d1:	83 c4 10             	add    $0x10,%esp
8010a1d4:	89 c2                	mov    %eax,%edx
8010a1d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1d9:	83 ec 0c             	sub    $0xc,%esp
8010a1dc:	53                   	push   %ebx
8010a1dd:	52                   	push   %edx
8010a1de:	68 00 10 00 00       	push   $0x1000
8010a1e3:	50                   	push   %eax
8010a1e4:	ff 75 ec             	pushl  -0x14(%ebp)
8010a1e7:	e8 05 f8 ff ff       	call   801099f1 <mappages>
8010a1ec:	83 c4 20             	add    $0x20,%esp
8010a1ef:	85 c0                	test   %eax,%eax
8010a1f1:	78 1b                	js     8010a20e <copyuvm+0x147>
	char *mem;
	uint foundPA = 0;

	if ((d = setupkvm()) == 0)
		return 0;
	for (i = 0; i < sz; i += PGSIZE) {
8010a1f3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010a1fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1fd:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010a200:	0f 82 f3 fe ff ff    	jb     8010a0f9 <copyuvm+0x32>
			memmove(mem, (char *)p2v(pa), PGSIZE);
			if (mappages(d, (void *)i, PGSIZE, v2p(mem), flags) < 0)
				goto bad;
		}
	}
	return d;
8010a206:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a209:	eb 19                	jmp    8010a224 <copyuvm+0x15d>
				goto bad;
		}
		else
		{
			if ((mem = kalloc()) == 0)
				goto bad;
8010a20b:	90                   	nop
8010a20c:	eb 01                	jmp    8010a20f <copyuvm+0x148>
			memmove(mem, (char *)p2v(pa), PGSIZE);
			if (mappages(d, (void *)i, PGSIZE, v2p(mem), flags) < 0)
				goto bad;
8010a20e:	90                   	nop
		}
	}
	return d;

 bad:
	freevm(d, 0);
8010a20f:	83 ec 08             	sub    $0x8,%esp
8010a212:	6a 00                	push   $0x0
8010a214:	ff 75 ec             	pushl  -0x14(%ebp)
8010a217:	e8 ca fd ff ff       	call   80109fe6 <freevm>
8010a21c:	83 c4 10             	add    $0x10,%esp
	return 0;
8010a21f:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010a224:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a227:	c9                   	leave  
8010a228:	c3                   	ret    

8010a229 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char *uva2ka(pde_t * pgdir, char *uva)
{
8010a229:	55                   	push   %ebp
8010a22a:	89 e5                	mov    %esp,%ebp
8010a22c:	83 ec 18             	sub    $0x18,%esp
	pte_t *pte;

	pte = walkpgdir(pgdir, uva, 0);
8010a22f:	83 ec 04             	sub    $0x4,%esp
8010a232:	6a 00                	push   $0x0
8010a234:	ff 75 0c             	pushl  0xc(%ebp)
8010a237:	ff 75 08             	pushl  0x8(%ebp)
8010a23a:	e8 12 f7 ff ff       	call   80109951 <walkpgdir>
8010a23f:	83 c4 10             	add    $0x10,%esp
8010a242:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if ((*pte & PTE_P) == 0)
8010a245:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a248:	8b 00                	mov    (%eax),%eax
8010a24a:	83 e0 01             	and    $0x1,%eax
8010a24d:	85 c0                	test   %eax,%eax
8010a24f:	75 07                	jne    8010a258 <uva2ka+0x2f>
		return 0;
8010a251:	b8 00 00 00 00       	mov    $0x0,%eax
8010a256:	eb 29                	jmp    8010a281 <uva2ka+0x58>
	if ((*pte & PTE_U) == 0)
8010a258:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a25b:	8b 00                	mov    (%eax),%eax
8010a25d:	83 e0 04             	and    $0x4,%eax
8010a260:	85 c0                	test   %eax,%eax
8010a262:	75 07                	jne    8010a26b <uva2ka+0x42>
		return 0;
8010a264:	b8 00 00 00 00       	mov    $0x0,%eax
8010a269:	eb 16                	jmp    8010a281 <uva2ka+0x58>
	return (char *)p2v(PTE_ADDR(*pte));
8010a26b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a26e:	8b 00                	mov    (%eax),%eax
8010a270:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a275:	83 ec 0c             	sub    $0xc,%esp
8010a278:	50                   	push   %eax
8010a279:	e8 51 f2 ff ff       	call   801094cf <p2v>
8010a27e:	83 c4 10             	add    $0x10,%esp
}
8010a281:	c9                   	leave  
8010a282:	c3                   	ret    

8010a283 <copyout>:

// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int copyout(pde_t * pgdir, uint va, void *p, uint len)
{
8010a283:	55                   	push   %ebp
8010a284:	89 e5                	mov    %esp,%ebp
8010a286:	83 ec 18             	sub    $0x18,%esp
	char *buf, *pa0;
	uint n, va0;

	buf = (char *)p;
8010a289:	8b 45 10             	mov    0x10(%ebp),%eax
8010a28c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	while (len > 0) {
8010a28f:	eb 7f                	jmp    8010a310 <copyout+0x8d>
		va0 = (uint) PGROUNDDOWN(va);
8010a291:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a294:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a299:	89 45 ec             	mov    %eax,-0x14(%ebp)
		pa0 = uva2ka(pgdir, (char *)va0);
8010a29c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a29f:	83 ec 08             	sub    $0x8,%esp
8010a2a2:	50                   	push   %eax
8010a2a3:	ff 75 08             	pushl  0x8(%ebp)
8010a2a6:	e8 7e ff ff ff       	call   8010a229 <uva2ka>
8010a2ab:	83 c4 10             	add    $0x10,%esp
8010a2ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
		if (pa0 == 0)
8010a2b1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010a2b5:	75 07                	jne    8010a2be <copyout+0x3b>
			return -1;
8010a2b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010a2bc:	eb 61                	jmp    8010a31f <copyout+0x9c>
		n = PGSIZE - (va - va0);
8010a2be:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a2c1:	2b 45 0c             	sub    0xc(%ebp),%eax
8010a2c4:	05 00 10 00 00       	add    $0x1000,%eax
8010a2c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (n > len)
8010a2cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2cf:	3b 45 14             	cmp    0x14(%ebp),%eax
8010a2d2:	76 06                	jbe    8010a2da <copyout+0x57>
			n = len;
8010a2d4:	8b 45 14             	mov    0x14(%ebp),%eax
8010a2d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
		memmove(pa0 + (va - va0), buf, n);
8010a2da:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a2dd:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010a2e0:	89 c2                	mov    %eax,%edx
8010a2e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2e5:	01 d0                	add    %edx,%eax
8010a2e7:	83 ec 04             	sub    $0x4,%esp
8010a2ea:	ff 75 f0             	pushl  -0x10(%ebp)
8010a2ed:	ff 75 f4             	pushl  -0xc(%ebp)
8010a2f0:	50                   	push   %eax
8010a2f1:	e8 b9 ca ff ff       	call   80106daf <memmove>
8010a2f6:	83 c4 10             	add    $0x10,%esp
		len -= n;
8010a2f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2fc:	29 45 14             	sub    %eax,0x14(%ebp)
		buf += n;
8010a2ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a302:	01 45 f4             	add    %eax,-0xc(%ebp)
		va = va0 + PGSIZE;
8010a305:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a308:	05 00 10 00 00       	add    $0x1000,%eax
8010a30d:	89 45 0c             	mov    %eax,0xc(%ebp)
{
	char *buf, *pa0;
	uint n, va0;

	buf = (char *)p;
	while (len > 0) {
8010a310:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010a314:	0f 85 77 ff ff ff    	jne    8010a291 <copyout+0xe>
		memmove(pa0 + (va - va0), buf, n);
		len -= n;
		buf += n;
		va = va0 + PGSIZE;
	}
	return 0;
8010a31a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010a31f:	c9                   	leave  
8010a320:	c3                   	ret    
