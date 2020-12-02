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
JetSpritePtr    word    ; 2 bytes pointer 0 sprite lookup table
JetColorPtr     word
BomberSpritePtr word
BomberColorPtr  word
JetAnimOffset   byte


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define Constants.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JET_HEIGHT = 9
BOMBER_HEIGHT = 9

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
    ;lda #60
    lda #0
    sta JetXPos
    lda #83
    sta BomberYPos
    lda #54
    sta BomberXPos
    lda #0
    sta JetAnimOffset

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

    lda #<BomberSprite         ; low byte
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
;; Set player horizontal position while in VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda     JetXPos
    ldy     #0
    jsr     SetObjectXPos

    lda     BomberXPos
    ldy     #1
    jsr     SetObjectXPos

    sta WSYNC
    sta HMOVE          ; apply the Horizontal offset


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Let the TIA output the remaining lines of VBLANK 
;; (total 37)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    REPEAT 37
        sta WSYNC
    REPEND
    lda #0
    sta VBLANK  ; turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw the 96 visible scanlines (2 line kernal, 192/2) 
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

    ldx #96            ; X counts of remaining scanlines
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
    bne NoInput; 
    inc JetXPos             ; logic for a right
    lda JET_HEIGHT
    sta JetAnimOffset       ; second frame

NoInput:
    ; logic for no input, if any


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loop to next Frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Subroutines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
;;  Lookup tables for player graphics bitmap  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

