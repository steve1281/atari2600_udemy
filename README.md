# NOTES about course

* this course is offered by udemy.  
* the instructor is Gustavo Pezzi; the notes that follow are my notes from his course.
* see: https://www.udemy.com/course/programming-games-for-the-atari-2600/learn/lecture/16077318#overview

# Hardware and Specs

Opens with general discussion about gaming elements: 
*  Player 1
*  Player 2
*  Scoreboard
*  Ball
*  Playing field
*  Collision

## 1975 console based on programmable design
* rom cartridges
* called Stella
* options were 8080, Motorola 6800, mos 6502
* 6502 won cause it was cheap
* CPU: 1.19 Mhz 6507 processor ( cheaper version of 6502)
* Audio/Video: TIA Chip (Television Interface Adapter)
* RAM: 128 bytes 6532 RIOT Chip  (RAM I/O Timer)
* ROM: game cartridge; 4kB
* Input: Two controller ports - joysticks, paddle
* Output: TV via RCA Connector (NTSC, PAL, SECAM)

## Models:
* 1977 - 2600   "Heavy Sixer" 
* 1978 - 2600   "Light Sixer"
* 1980 - 2600-A "Four-Switch"
* 1981 - 2600   "Darth Vader"
* 1986 - 2600   "JR."

## Parts:
* an overview of the board.

```
      |-----------------|
      | cartridge/ROM   |
      |-----------------|

        [  6532 RIOT  ]
	  
	  [ 6507 CPU ]

      [ TIA             ]	  
```

* A minimal design.

## Who uses the 6502 family
* Apple IIe
* BBC Micro
* Commodore VIC-20
* Commodore 64 
* Tamagotchi
* Atari 2600
* NES
* Bender Rodriguez (from Futurama ha ha)

## Quick overview of 6502

* pin2 - RDY pin (strobe it for next thing)
* pin4 - IRQ
* data bus: pin 33 - 26 (D0 - D7) <-- 8bit processor (so 8 bits at a time) 
* address bus: pin 9-20 (A0 - A11) 

* 8bits for the data bus
* 16bits for the address bus

## The 6507 variations 
*  no IRQ, no NIM
*  pin 5-pin14 A0-A9
*  pin 17-15 A12-A10
*  pin 25-pin18 (D0-D7)

### TIA - PAL vs NTSC 
    * colors
    * scan lines
    * some variety

* We will focus on the NTSC


# Binary and Hexadecimal

* How do we store information "in the metal"?
* High voltage vs Low Voltage
* 1 vs 0

* A very standard decimal system overview
* A very standard binary system overview
* Mentioned the 12 base system and the hand trick; coolness.

## Hexadecimal

* 0123456789ACDEF

```
00011011     (byte)
0001 1011   (2 nibble)
   1    B    
````

* This simple mapping between binary and hexadecimal makes it easy to organize.
* So, programmers typically usually hex for memory

* 6502 instructions map logically to hexadecimal. 
* eg. load value $3F


### Notation
*  Decimal     #2
*  Hexadecimal $2F
*  Binary      %00010011


## Processor Overview

### 6502/6507

* 13 address pins, and 8 data pins
* reminaing pins - clock, power, reset, gnd etc
* no IRQ/NMI (very different from other 6502s, that use interupts)

* seven main parts
* 1.19 million times per secoind
* tick is clock cycle

```
   [ data bus                                                           ]
    --+------+---+--+---------+-+---+------------+-----------------------
      |      |   |  | N       | |   |            |        +--------+
    Input/   P   S  P V       X Y   accumulator -|--+     | MEMORY |
    Output   C   P  | B/D/I   | |   |    |       |  |     +--------+
      |      |   |  | Z/C     | |   +-- ALU------+  |
    --+------+---+--+---------+-+-------------------+---------------------
   [ address bus                                                         ]
```

* ALU - arithmetic logic unit
*    - add/sub/etc
*    - greater than
*    - logical operations

* Registers
* - 6 addrerssible addresses
* -- PC program counter (address of next instruction)
* -- SP stack pointer (top of the stack) 
* -- P (processor flags - NV-B DIZC)
* -- X general purpose
* -- Y general purpose
* -- Accumulator (A) - general purpose, BUT used by ALU
*    (ALU gets value from A, Databus result goes into A)
 
 ### Registers are 8 bit
 * SP is 16bits - weird 0000001:nnnnnnnn
 * PC is 16bits

 * c carry
 * z zero
 * i irq disabled always 1 in 6507
 * d decimal mode re: BCD binary-coded decimal
 * b break instruction
 * -
 * v overflow
 * n negative

# Carry and Overflow flag

* register P from above

* bits for c and v

* How do we represent negative numbers?

* if the last instruction was negative , n =1
* what is a carry?
* example

```
  c n
  0 11111111
+ 0 00000001
-------------
  1 00000000
```

## So negative numbers

* 01111111  
* number is either positve or negative
* so we need one bit
* use the most significant bit for represent
* so 0 is positive, and 1 is negative
* so values range from -127 to 127
* This called sign & magnitude

### But this is NOT how we do this.
* This gives us positive 0 or negative 0. which is weird.
* Adding becomes odd

## Two's complement


* -128 64 32 16 8 4 2 1

* how many -128s the number has
* one way represent 0.
* and the math works

## Examples

```
-128 |  64 |  32 |  16 |   8 |   4  |   2 |   1 |
  0      1     1     1     1     1      1     1   = 127
  1      0     0     0     0     0      0     0   = -128
  1      1     1     1     1     1      1     1   = -1
```

* Consider:

```
   01111111       127
+  00000001         1
   --------
   10000000      -128 
```

* no carry happens. 
* so now what?
* twos complement overflow
* the flag v gets set

# Assembler
* link: http://www.6502.org/tutorials/6502opcodes.html

* provide a way to send instructions to processor.
* how do tell processor #2 into the A register

```
send 1010 1001 0000 0010
            A9         2
```

* op code :  A9 02
* assembly: LDA #2

* assembler will translate from assembly to opcodes


## More examples

```
LDA #2      ; store 2 into A
STA $2B     ; store whats in A to address $2b
LDX $1234   ; load x register whatever value at 1234
DEX         ; decrement (x--) X register
```

assembles to

```
a9 02 
85 2b
ae 34 12  <-- note the order. little endian (the LSB is first)
ca
```

# Popular 6502 Assembly codes

```
LDA ; load
LDX
LDY

STA ; store
STX
STY

ADC ; add with carry
SBC ; subtract with carry
(no multiply, no addition)

CLC clear carry (before addition)
SEC sets the carry (before subtraction)

INC ; increment
INX
INY

DEC ; decrement
DEX
DEY

z=1 if result is 0, 0 otherwise
n=1 if 7bit is set. 0 otherwise

JMP  ; jump (like a goto)
BCC  ; branch on carry clear
BCS  ; branch on carry set
BEQ  ; branch if equal to zero
BNE  ; branch on if not 0
BMI  ; branch on minus
BPL  ; branch on plus
BVC  ; branch overflow clear
BVS  ; branch overflow set
```

* Example of loop

```
       ldy #100 ; y= 100
Loop:
       dey      ; y--
       bne Loop ; repeat until y==0

```
Note: at this point, the course is doing some actual examples; see
* ./cleanasm

# Different Address Modes


* Immediate: 
- LDA #80  ; load A register with the literal value decimal 80
- A9 50

* Absolute:
- LDA $80  ; load A register from address $80  --> question: hex or decimal?
- A5 80

* Hmm - seems that it HEX. 
* So is the hash # meaning immediate mode then?

* Ah, he does explain this, thank you: 
LDA #$80  ; load A register with literal hexadecimal 80 



# VCS Memory Map

Some ideas we have seen:

* ROM: $F000 - $FFFF
* page 0: $0000 - $00FF

Where are things located in address space

VCS bus - OK, first time I recall hearing this. Let me scroll up and look at my notes...
* we had an address bus and a databus.  I wonder what he is talking about? 
Anyway. this "new?" bus connects to the 
*  TIA - television interface adapter.  (OK)
*  PIA - Peripheral Interface Adapter.  (New, but sure this makes sense)
*  ROM - Read Only Memory -Cartridge (OK)

VCS Memory Map

```
$00   TIA registers - send instruction to TV (color background, etc)
$01
$02


$7D
$7E
$7F
```

If you put a value in $09 - that color will go into the background.

```
$80  PIA RAM  
$81
$82


$FD
$FE
$FF
```

```
$F000   Cartridge ROM
$F001
$F002


$FFFC  reset vector
$FFFD
$FFFE  break interupt
$FFFF
```
Do we need to recall these? Well no. There is a file called vcs.h (it was included with dasm) with these
defined in it.

From: ~/projects/dasm/dasm-2.20.14.1$ vi ./machines/atari2600/vcs.h

```
    ; DO NOT CHANGE THE RELATIVE ORDERING OF REGISTERS!
    
VSYNC       ds 1    ; $00   0000 00x0   Vertical Sync Set-Clear
VBLANK      ds 1    ; $01   xx00 00x0   Vertical Blank Set-Clear
WSYNC       ds 1    ; $02   ---- ----   Wait for Horizontal Blank
RSYNC       ds 1    ; $03   ---- ----   Reset Horizontal Sync Counter
NUSIZ0      ds 1    ; $04   00xx 0xxx   Number-Size player/missle 0
NUSIZ1      ds 1    ; $05   00xx 0xxx   Number-Size player/missle 1
COLUP0      ds 1    ; $06   xxxx xxx0   Color-Luminance Player 0
COLUP1      ds 1    ; $07   xxxx xxx0   Color-Luminance Player 1
COLUPF      ds 1    ; $08   xxxx xxx0   Color-Luminance Playfield
COLUBK      ds 1    ; $09   xxxx xxx0   Color-Luminance Background
CTRLPF      ds 1    ; $0A   00xx 0xxx   Control Playfield, Ball, Collisions
REFP0       ds 1    ; $0B   0000 x000   Reflection Player 0
REFP1       ds 1    ; $0C   0000 x000   Reflection Player 1
PF0         ds 1    ; $0D   xxxx 0000   Playfield Register Byte 0
PF1         ds 1    ; $0E   xxxx xxxx   Playfield Register Byte 1
PF2         ds 1    ; $0F   xxxx xxxx   Playfield Register Byte 2
RESP0       ds 1    ; $10   ---- ----   Reset Player 0
RESP1       ds 1    ; $11   ---- ----   Reset Player 1
RESM0       ds 1    ; $12   ---- ----   Reset Missle 0
RESM1       ds 1    ; $13   ---- ----   Reset Missle 1
RESBL       ds 1    ; $14   ---- ----   Reset Ball
AUDC0       ds 1    ; $15   0000 xxxx   Audio Control 0
AUDC1       ds 1    ; $16   0000 xxxx   Audio Control 1
AUDF0       ds 1    ; $17   000x xxxx   Audio Frequency 0
AUDF1       ds 1    ; $18   000x xxxx   Audio Frequency 1
AUDV0       ds 1    ; $19   0000 xxxx   Audio Volume 0
AUDV1       ds 1    ; $1A   0000 xxxx   Audio Volume 1
GRP0        ds 1    ; $1B   xxxx xxxx   Graphics Register Player 0
```
 
In our assembly, we include "vcs.h" and "macro.h"

(so I guess I better copy these files into the project hmm?)

He provides a link for this.  I have the source, so for now, I will use that.

```
steve@cplusdev:~/projects/atari2600_udemy$ mkdir include
steve@cplusdev:~/projects/atari2600_udemy$ cd include
steve@cplusdev:~/projects/atari2600_udemy/include$ cp ~/projects/dasm/dasm-2.20.14.1/machines/atari2600/vcs.h .
steve@cplusdev:~/projects/atari2600_udemy/include$ cp ~/projects/dasm/dasm-2.20.14.1/machines/atari2600/macro.h .
```

Now I add to the top of my assembly files

```
include ../include/vcs.h
include ../include/macro.h
```
He mentions also that the page of memory is 256 bytes, when we only have 128 byte system. 
I assume that there is a mode thing happening, but not explained.

yet.

Next, we review the vcs.h.  

OK see ./colorbg for code example
He is moving the .h files into the project.  
I really don't want to do this; it will result with many .h files distributed.
Do I have to?

For colors:
link: https://en.wikipedia.org/wiki/List_of_video_game_console_palettes
for example, yellow is 1,14 MSB,LSB.
or 1E

# CRT Video Synchronization

Note: I actually watched this session twice. Its pretty deep.

Put a value into a register - this maps to TIA

"lockstep" ?

NTSC vs PAL

* General discussion about how CRT scan lines work - scanlines are "beamed" onto a phosphorescent screen
* Now adays, we have a place for every pixels (ie screen buffers)
* But, on an Atari, we dont have nearly enough memory for that
* So, we store scanlines
* and need to sync /reprogram on a per scanline basis

"Racing the beam" - reprogram TIA chip for each scanline.

So, timing is really important, we will need to sync somehow.

Horizontal blank: 
(color clocks sorta like pixels)

|<-- 68 color clocks -->|<-- 160 color clocks --------------------------> |
|<-- not visible     -->|<--  visible                                 --> |

The processor is halted until WSYNC is recieved from the TIA. 
(so the processor sends instruction to the TIA and halts.  Then the TIA strobes the WSYNC pin.)
(you can look at the pin out of the 6507 and see this PIN)

Vertical Sync - NTSC

```
| <-- scanline 1                                                      --> |
| <-- scanline 2                                                      --> |
| <-- scanline 3                                                      --> |
| <---------------------------------------------------------------------> |
| <---                         VERTICAL BLANKS                        --> |
..
   37 in total
..
| <----------------------+----------------------------------------------> |
| <-- 68 color clocks -->|<-- 160 wide         -------------------------> |
| <-- not visible     -->|<-- 192 high                                --> |
|                        |                                                |
...   192 of these       |                                                |
|                        |                                                |
| <----------------------+----------------------------------------------> |
| <-- over scan                                                       --> |
|  30 of these
| <---------------------------------------------------------------------> |

```

Assembly code example:

NextFrame:
    lda #2
    sta VBLANK      ; turn on VBLANK
    sta VSYNC       ; turn on VSYNC

    sta WSYNC       ; store A in WSYNC halts and waits to be strobed
    sta WSYNC       ; previsious happened, wait for the next
    sta WSYNC       ; prev happened; wait for the next

    lda #0          ; shut it down
    sta VSYNC

    lda #37
LoopVBlank:
    sta WSYNC   ; hit WSYNC to wait for TIA to strobe it
    dex
    bne LoopVBlank
    lda #0
    sta VBLANK     ; shut it down

; --- we do similair things for the next areas ...

# Painting the CRT
see ./rainbow/rainbow.asm


# TIA Screen Objects
* background
* playfield - objects/obstacles/walls in the "arena"
* player 0 - size, width, height. color
* player 1
* missle 0
* missle 1
* ball

We can poke different values for these. 

Scanlines are rendered based on /via the TIA registers

TIA registers are mapped into our memory.

* background takes whole visible background (160x192)
* one color per scan

* playfield uses a 20 bit pattern, over left side of scanline
* one color per scan
* either a repeat, or a reflection of the same pattern
* this is odd I think
* PF0, PF1, PF2
* COLOUPF
* CTRLPF
- D0: Reflect
- D1: Score
- D2: Priority
- D4-D5: Ball size (1, 2, 4, 8)

The playfield is build by reading PF0, PF1 and PF2

```
|   Left side of the play field                                               |
|   PF0        |   PF1                        |   PF2                         |
|4 | 5 | 6 | 7 |7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
```

Set the register, scanline, repeat.

PF0 = 0000     @ <--- read this way
PF1 = 00000000 @ ---> read this way
PF2 = 00000000 @ <--- read this way
REFLECT = 0

scanline = "                                       "

Another:

```
PF0 = 0001     @ <--- read this way
PF1 = 00000000 @ ---> read this way
PF2 = 00000000 @ <--- read this way
REFLECT = 0
----------- PF0 PF1     PF2
----------- 45677654321001234567
----------- 0123456789012345678901234567890123456789
scanline = "☐                   ☐                   "
```

Another:

```
PF0 = 0011     @ <--- read this way
PF1 = 00000000 @ ---> read this way
PF2 = 00000000 @ <--- read this way
REFLECT = 0
----------- PF0 PF1     PF2
----------- 45677654321001234567
----------- 0123456789012345678901234567890123456789
scanline = "☐☐                 ☐☐                  "

```

Another:

```
PF0 = 1111     @ <--- read this way
PF1 = 11110000 @ ---> read this way
PF2 = 00000000 @ <--- read this way
REFLECT = 0
----------- PF0 PF1     PF2
----------- 45677654321001234567
----------- 0123456789012345678901234567890123456789
scanline = "☐☐☐☐☐☐☐☐           ☐☐☐☐☐☐☐☐            "
```

Another:

```
bits  76543210
PF0 = 1111xxxx @ <--- read this way
PF1 = 11111110 @ ---> read this way
PF2 = 00010101 @ <--- read this way
REFLECT = 0
----------- 0123456789012345678901234567890123456789
----------- PF0 PF1     PF2
----------- 45677654321001234567
scanline = "☐☐☐☐☐☐☐☐☐☐☐ ☐ ☐ ☐   ☐☐☐☐☐☐☐☐☐☐☐ ☐ ☐ ☐   "
```

```
My note: Look, I don't know why they did it this way, but its not complicated. 
All you need to remember is the bit pattern rendering order: 45677654321001234567 
and that PF0 only renders its top most 4 bits.  The other half of the screen is either
a repeat (so 45677654321001234567 again) or a reflection.

So the question now is, how do they do reflection?  Do they re-order the bits, or the PFn, or both?
Normal order is PF0PF1PF2 and this defines 20 blocks.
A nonreflect (so REFLECT=0) looks like: PF0PF1PF2PF0PF1PF2.

So what does it look like when REFLECT=1?

Ah, he provides an example
```


Another:

```
bits  76543210
PF0 = 1111xxxx @ <--- read this way
PF1 = 11111110 @ ---> read this way
PF2 = 00010101 @ <--- read this way
REFLECT = 1
----------- 0123456789012345678901234567890123456789
----------- PF0 PF1     PF2     PF2     PF1     PF0
----------- 4567765432100123456776543210012345677654
scanline = "☐☐☐☐☐☐☐☐☐☐☐ ☐ ☐ ☐      ☐ ☐ ☐ ☐☐☐☐☐☐☐☐☐☐☐"
```

Ok, the key here is total bit reversal.

Lastly, note how this is repeated, to draw out our play field for the game:

```
scanline = "☐☐☐☐☐☐☐☐            ☐☐☐☐☐☐☐☐            "
scanline = "☐☐☐☐☐☐☐☐            ☐☐☐☐☐☐☐☐            "
scanline = "☐☐☐☐☐☐☐☐            ☐☐☐☐☐☐☐☐            "
scanline = "☐☐☐☐☐☐☐☐☐☐☐ ☐ ☐ ☐   ☐☐☐☐☐☐☐☐☐☐☐ ☐ ☐ ☐   "
scanline = "☐☐☐☐☐☐☐☐☐☐☐ ☐ ☐ ☐   ☐☐☐☐☐☐☐☐☐☐☐ ☐ ☐ ☐   "
scanline = "☐☐☐☐☐☐☐☐☐☐☐ ☐ ☐ ☐   ☐☐☐☐☐☐☐☐☐☐☐ ☐ ☐ ☐   "
scanline = "☐☐☐☐☐☐☐☐☐☐☐ ☐ ☐ ☐   ☐☐☐☐☐☐☐☐☐☐☐ ☐ ☐ ☐   "
scanline = "☐☐☐☐☐☐☐☐☐☐☐ ☐ ☐ ☐      ☐ ☐ ☐ ☐☐☐☐☐☐☐☐☐☐☐"
scanline = "☐☐☐☐☐☐☐☐☐☐☐ ☐ ☐ ☐      ☐ ☐ ☐ ☐☐☐☐☐☐☐☐☐☐☐"
scanline = "☐☐☐☐☐☐☐☐☐☐☐ ☐ ☐ ☐      ☐ ☐ ☐ ☐☐☐☐☐☐☐☐☐☐☐"
scanline = "☐☐☐☐☐☐☐☐☐☐☐ ☐ ☐ ☐      ☐ ☐ ☐ ☐☐☐☐☐☐☐☐☐☐☐"
scanline = "☐☐☐☐☐☐☐☐☐☐☐ ☐ ☐ ☐      ☐ ☐ ☐ ☐☐☐☐☐☐☐☐☐☐☐"
```


