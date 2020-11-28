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
...
