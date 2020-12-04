    processor 6502
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Include constants and macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    include "../include/vcs.h"
    include "../include/macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Local variables.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg.u Variables
    org $80

JetXPos         byte    ; player 0 x-pos
JetYPos         byte    ; player 0 y-pos
BomberXPos      byte    ; player 1 x-pos
BomberYPos      byte    ; player 1 y-pos
Score           byte    ; the fact that they are right after one another
Timer           byte    ; means somthing.
Temp            byte
OnesDigitOffset word    
TensDigitOffset word
JetSpritePtr    word    ; 2 bytes pointer 0 sprite lookup table
JetColorPtr     word
BomberSpritePtr word
BomberColorPtr  word
JetAnimOffset   byte
Random          byte    ; random seed generated
ScoreSprite     byte
TimerSprite     byte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define Constants.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JET_HEIGHT    = 9
BOMBER_HEIGHT = 9
DIGITS_HEIGHT = 5   ; score board digit height

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Start our ROM code segment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg code
    org $F000

Reset:
    CLEAN_START

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Init variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #10         ; A = 10
    sta JetYPos     ; JetYPos = A
    lda #60
    sta JetXPos
    lda #83
    sta BomberYPos
    lda #54
    sta BomberXPos
    lda #0
    sta JetAnimOffset
    lda #%11010100
    sta Random
    lda #4
    sta Score
    lda #8
    sta Timer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Init pointers to correct lookup table addresses
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #<JetSprite         ; low byte
    sta JetSpritePtr
    lda #>JetSprite         ; high byte
    sta JetSpritePtr+1      ;

    lda #<JetColor          ; low byte
    sta JetColorPtr
    lda #>JetColor          ; high byte
    sta JetColorPtr+1       ;

    lda #<BomberSprite      ; low byte
    sta BomberSpritePtr
    lda #>BomberSprite         ; high byte
    sta BomberSpritePtr+1      ;

    lda #<BomberColor          ; low byte
    sta BomberColorPtr
    lda #>BomberColor          ; high byte
    sta BomberColorPtr+1       ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start main game loop/a new frame with VBLANK/VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:
    lda #2
    sta VBLANK  ; VBLANK ON
    sta VSYNC   ; VSYNC ON

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Display 3 vertical lines of VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    sta WSYNC
    sta WSYNC
    sta WSYNC
    lda #0
    sta VSYNC   ; turn off VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Let the TIA output the remaining lines of VBLANK 
;; (total 37)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    REPEAT 33
        sta WSYNC
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set player horizontal position while in VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda     JetXPos
    ldy     #0
    jsr     SetObjectXPos

    lda     BomberXPos
    ldy     #1
    jsr     SetObjectXPos

    jsr     CalculateDigitOffset    

    sta WSYNC
    sta HMOVE          ; apply the Horizontal offset

    lda #0
    sta VBLANK  ; turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; display scoreboard
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda #0          ; clear TIA registers before each new
    sta COLUBK
    sta PF0
    sta PF1
    sta PF2
    sta GRP0
    sta GRP1

    lda #$1E        ; set score board to white
    sta COLUPF
    lda #%00000000  ; do not reflect
    sta CTRLPF
    
    ldx #DIGITS_HEIGHT      ; start X with 5
.ScoreDigitLoop:
    ldy TensDigitOffset     ; get the tens digit offset
    lda Digits,Y
    and #$F0
    sta ScoreSprite         ; save the score 10s digit pattern

    ldy OnesDigitOffset     ; get the tens digit offset
    lda Digits,Y
    and #$0F
    ora ScoreSprite         ; save the score 10s digit pattern
    sta ScoreSprite
    sta WSYNC
    sta PF1
   
    ldy TensDigitOffset+1
    lda Digits,Y
    and #$F0
    sta TimerSprite
    
    ldy OnesDigitOffset+1
    lda Digits,Y
    and #$0F
    ora TimerSprite
    sta TimerSprite

    ; waste some cycles
    jsr Sleep12Cycles       ;
    sta PF1

    ldy ScoreSprite         ; preload for next scanline
    sta WSYNC
    
    sty PF1
    inc TensDigitOffset
    inc TensDigitOffset+1
    inc OnesDigitOffset
    inc OnesDigitOffset+1

    jsr Sleep12Cycles


    dex
    sta PF1
    bne .ScoreDigitLoop
    sta WSYNC
    lda #0
    sta PF0
    sta PF1
    sta PF2
    sta WSYNC
    sta WSYNC
    sta WSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw the 84 visible scanlines (2 line kernal, 172/2) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fill this in
GameVisibleLine:
    lda #$84        ; blue
    sta COLUBK      ; background

    lda #$C2        ; green
    sta COLUPF      ; playfield

    lda #%00000001  ; set d0 to 1
    sta CTRLPF      ; playfield reflect

    lda #$F0
    sta PF0

    lda #$FC 
    sta PF1

    lda #0
    sta PF2

    ldx #85            ; X counts of remaining scanlines
.GameLineLoop:
.AreWeInsideJetSprite:
    txa             ; a =x
    sec             ; set carry flag before subtraction
    sbc JetYPos     ; 
    cmp JET_HEIGHT  ; less than, then drawing JetSprite
    bcc .DrawSpriteP0   
    lda #0          ; else, set up lookup index 0

.DrawSpriteP0:
    clc                     ; before an addition clear the carry
    adc JetAnimOffset
    tay                     ; Y = A
    lda (JetSpritePtr),Y    ; Y is the only indirect register
    sta WSYNC               ; need a scanline
    sta GRP0                ; set graphics player0
    lda (JetColorPtr),Y
    sta COLUP0              ; set color of player0

.AreWeInsideBomberSprite:
    txa             ; a =x
    sec             ; set carry flag before subtraction
    sbc BomberYPos     ; 
    cmp BOMBER_HEIGHT  ; less than, then drawing JetSprite
    bcc .DrawSpriteP1   
    lda #0          ; else, set up lookup index 0

.DrawSpriteP1:
    tay                     ; Y = A
    lda #%00000101
    sta NUSIZ1              ; stretch player1
    lda (BomberSpritePtr),Y ; Y is the only indirect register
    sta WSYNC               ; need a scanline
    sta GRP1                ; set graphics player1
    lda (BomberColorPtr),Y
    sta COLUP1              ; set color of player1
    
    dex                 ; x-- (decrement x)
    bne .GameLineLoop   ; repeat until x == 192

    lda #0
    sta JetAnimOffset   ; reset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Output 30 VBLANK overscan lines to complete our frame 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Overscan:

    lda #2
    sta VBLANK  ; turn on VBLANK
    REPEAT 30
        sta WSYNC
    REPEND
    lda #0
    sta VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; joystick player 0 controls
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckP0Up:
    lda #%00010000          ; player 0 joystick up
    bit SWCHA
    bne CheckP0Down         ; 
    inc JetYPos             ; logic for Up
    lda #0
    sta JetAnimOffset       ; first frame

CheckP0Down:
    lda #%00100000          ; player 0 joystick dn
    bit SWCHA
    bne CheckP0Left         ; 
    dec JetYPos             ; logic for dn
    lda #0
    sta JetAnimOffset       ; first frame


CheckP0Left:
    lda #%01000000          ; player 0 joystick left
    bit SWCHA
    bne CheckP0Right         ; 
    dec JetXPos              ; logic for left
    lda JET_HEIGHT
    sta JetAnimOffset       ; second frame


CheckP0Right:
    lda #%10000000          ; player 0 joystick right
    bit SWCHA
    bne EndInput; 
    inc JetXPos             ; logic for a right
    lda JET_HEIGHT
    sta JetAnimOffset       ; second frame

EndInput: 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Calculations to update position for next frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UpdateBomberPosition:
    lda BomberYPos
    clc
    cmp #0
    bmi .ResetBomberPosition        ; if less than 0
    dec BomberYPos
    jmp EndPositionUpdate
.ResetBomberPosition
    jsr GetRandomBomberPos      ; call sub for next enemy positions

EndPositionUpdate: 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Check Collisons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckCollisionsP0P1:
    lda #%10000000      ; bit 7
    bit CXPPMM          ; check p0 vs p1
    bne .CollisionP0P1  ; collision detected
    jmp CheckCollisionP0PF
.CollisionP0P1:
    jsr GameOver        ; boom baby

CheckCollisionP0PF:
    lda #%10000000      ; bit 7
    bit CXP0FB          ; check p0 vs playfield
    bne .CollisionP0PF  ; collision detected
    jmp EndCollisionCheck
.CollisionP0PF:
    jsr GameOver        ; boom baby

EndCollisionCheck:      ; fallback
    sta CXCLR           ; clear collisions

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loop to next Frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Subroutines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Waste 12 cylces 
;; - jsr takes 6 cycles
;; - rts takes 6 cycles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Sleep12Cycles subroutine
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; handle object horizontal position with fine offset
; A is target X-coord
; Y is the object type (0: player0, 1:player1, 2:missle0 3: missle1, 4:ball)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
SetObjectXPos subroutine
    sta     WSYNC       ; start a fresh scan line
    sec                 ; set carry before subtraction
.Div15Loop
    sbc #15            ; division is subtraction until you can't 
    bcs .Div15Loop
    eor #7
    asl
    asl
    asl
    asl                 ; four left shifts to get only top 4 bits
    sta HMP0,Y          ; store fine offset into the HMxx
    sta RESP0,Y         ; fix object pos in the 15 step increment
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Subroutine to Game OVer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameOver subroutine
    ; score = 0
    ; change background color
    lda #$30
    sta COLUBK
    rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Subroutine to generate LFSR random value
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetRandomBomberPos subroutine
    ; generate a random number $00-&FF
    lda Random      ; Load starting with a random seed
    asl             ; shift left
    eor Random      ; XOR accumulator with Random
    asl             ; shift left
    eor Random      ; XOR accumulator with Random
    asl
    asl
    eor Random
    asl
    rol Random      ; rotate left
    ; limit value /4
    lsr             ; divide by 2 using right shift (eg 1000 -> 0100)
    lsr             ; divide by 2 (eg 0100 -> 0010) 
    sta BomberXPos  ; save it
    ; add 30 to offset the green field.
    lda #30
    adc BomberXPos
    sta BomberXPos  ; save it
    ; now the y
    lda #96
    sta BomberYPos    
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Subroutine to handle scoreboard digits to be displayed on the screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Convert high and low nibbles variable score and timer 
;; to get the offsets of digits lookup table so the value can be displayed.
;; Each digit has a hieght of 5 bytes
;; For the low nibble multiply by 5.
;;  left shift x2
;;  for any number n*5 == n*2*2+n
;; 
;; For the upper nibble
;; since already *16 (hex) we need to divide it by 16 and then multiply it
;; by 5.
;; - we can use right shifts to divide by 2, 
;;  the value (n/16)/5   = n/2/2 + n/2/2/2/2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CalculateDigitOffset subroutine
    ldx #1              ; x reg is the loop counter
.PrepareScoreLoop       ; this will loop twice, first X=1, then X=0
    lda Score,X         ; Score+1 is the Timer, due to where we declared it
    and #$0F            ; remoce the tens digit by masking 4 bits
    sta Temp            ; save value into Temp
    asl                 ; * 2
    asl                 ; * 2
    adc Temp            ; + n
    sta OnesDigitOffset,X

    lda Score,X         ; 
    and #$F0            ; 
    lsr                 ; / 2 
    lsr                 ; / 2
    sta Temp
    lsr
    lsr
    adc Temp
    sta TensDigitOffset,X

    dex                     ; x--
    bpl .PrepareScoreLoop   

    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Lookup tables for player graphics bitmap  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;===============================================================================
; Digit Graphics
;===============================================================================
Digits:
        .byte %01110111
        .byte %01010101
        .byte %01010101
        .byte %01010101
        .byte %01110111
        
        .byte %00010001
        .byte %00010001
        .byte %00010001
        .byte %00010001        
        .byte %00010001
        
        .byte %01110111
        .byte %00010001
        .byte %01110111
        .byte %01000100
        .byte %01110111
        
        .byte %01110111
        .byte %00010001
        .byte %00110011
        .byte %00010001
        .byte %01110111
        
        .byte %01010101
        .byte %01010101
        .byte %01110111
        .byte %00010001
        .byte %00010001
        
        .byte %01110111
        .byte %01000100
        .byte %01110111
        .byte %00010001
        .byte %01110111
           
        .byte %01110111
        .byte %01000100
        .byte %01110111
        .byte %01010101
        .byte %01110111
        
        .byte %01110111
        .byte %00010001
        .byte %00010001
        .byte %00010001
        .byte %00010001
        
        .byte %01110111
        .byte %01010101
        .byte %01110111
        .byte %01010101
        .byte %01110111
        
        .byte %01110111
        .byte %01010101
        .byte %01110111
        .byte %00010001
        .byte %01110111
        
        .byte %00100010
        .byte %01010101
        .byte %01110111
        .byte %01010101
        .byte %01010101
         
        .byte %01100110
        .byte %01010101
        .byte %01100110
        .byte %01010101
        .byte %01100110
        
        .byte %00110011
        .byte %01000100
        .byte %01000100
        .byte %01000100
        .byte %00110011
        
        .byte %01100110
        .byte %01010101
        .byte %01010101
        .byte %01010101
        .byte %01100110
        
        .byte %01110111
        .byte %01000100
        .byte %01100110
        .byte %01000100
        .byte %01110111
        
        .byte %01110111
        .byte %01000100
        .byte %01100110
        .byte %01000100
        .byte %01000100

JetSprite:
        .byte #%00000000        ; note the additional padding 00000000
        .byte #%00010100
        .byte #%01111111
        .byte #%00111110
        .byte #%00011100
        .byte #%00011100
        .byte #%00001000
        .byte #%00001000
        .byte #%00001000
JetSpriteTurn:
        .byte #%00000000
        .byte #%00001000
        .byte #%00111110
        .byte #%00011100
        .byte #%00011100
        .byte #%00011100
        .byte #%00001000
        .byte #%00001000
        .byte #%00001000

BomberSprite:
        .byte #%00000000
        .byte #%00001000
        .byte #%00001000
        .byte #%00101010
        .byte #%00111110
        .byte #%01111111
        .byte #%00101010
        .byte #%00001000
        .byte #%00011100

JetColor:
        .byte #$00          ; added color for the paddding.
        .byte #$FE;
        .byte #$06;
        .byte #$0E;
        .byte #$0E;
        .byte #$04;
        .byte #$B6;
        .byte #$0E;
        .byte #$08;

JetColorTurn:
        .byte #$00
        .byte #$FE;
        .byte #$06;
        .byte #$0E;
        .byte #$0E;
        .byte #$04;
        .byte #$B6;
        .byte #$0E;
        .byte #$08;

BomberColor:
        .byte #$00
        .byte #$24;
        .byte #$24;
        .byte #$0E;
        .byte #$30;
        .byte #$30;
        .byte #$30;
        .byte #$30;
        .byte #$20;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set cartridge size to 4K, set restart and interrupt vectors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Reset
    .word Reset

