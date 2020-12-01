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
    lda #60
    sta JetXPos
    lda #83
    sta BomberYPos
    lda #54
    sta BomberXPos

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
; fill this out


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
;; Draw the 192 visible scanlines 
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

    ldx #192            ; X counts of remaining scanlines
.GameLineLoop:
    sta WSYNC           ;
    dex                 ; x-- (decrement x)
    bne .GameLineLoop   ; repeat until x == 192


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
;; Loop to next Frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Lookup tables for player graphics bitmap  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

JetSprite:
        .byte #%00000000        ; note the additional padding 00000000
        .byte #%00100100
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

