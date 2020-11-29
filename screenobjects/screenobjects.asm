    processor 6502
    include "../include/vcs.h"
    include "../include/macro.h"

    seg code
    org $F000

Reset:
    CLEAN_START
    
    ldx #$80    ; blue back
    stx COLUBK
    lda #%1111  ; white playfield
    sta COLUPF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TIA registers for the colors of the players
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #$48    ; player 0 color light red
    sta COLUP0

    lda #$C6    ; player 1 color light blue
    sta COLUP1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start a new fram - VBLANK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:
    lda #2
    sta VBLANK
    sta VSYNC

    REPEAT 3
        sta WSYNC
    REPEND

    lda #0
    sta VSYNC

    REPEAT 37
        sta WSYNC
    REPEND

    lda #0
    sta VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  192 Visible scanlines 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Draw 10 empty scanlines at the top of the frame
    REPEAT 10
        sta WSYNC
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display 10 scanlines for the scoreboard.
;; Pulls data from an array of bytes defined at NumberBitmap 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldy #0
ScoreboardLoop:
    lda NumberBitmap,Y      ; adds to the address, defined below
    sta PF1
    sta WSYNC
    iny                     ; Y++
    cpy #10                 ; 10 scanlines ?
    bne ScoreboardLoop      ; branch not equal

    lda #0
    sta PF1     ; 

    ; My note: um, writing out 2 for each score doesn't make sense
    ; the scores can be different?
    ; maybe this is explained in a later lesson, but this is going to
    ; need some hacks we don't have yet
    
    ; draw 50 empty lines - leaving a space between scoreboard and player
    REPEAT 50
        sta WSYNC
    REPEND
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Dsiplays 10 scanlines for Player0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldy #0
Player0Loop:
    lda PlayerBitmap,Y
    sta GRP0
    sta WSYNC
    iny
    cpy #10
    bne Player0Loop

    lda #0
    sta GRP0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Displays 10 scanlines for Player1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldy #0
Player1Loop:
    lda PlayerBitmap,Y
    sta GRP1
    sta WSYNC
    iny
    cpy #10
    bne Player1Loop

    lda #0
    sta GRP1
    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  draw remaining 102 visible
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    REPEAT 102
        sta WSYNC
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; overscan 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK
    REPEAT 30
        sta WSYNC
    REPEND
    lda #0
    sta VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  next frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define array bytes to draw player 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFE8
PlayerBitmap:
    .byte #%01111110    ;  ######  @ FFE8
    .byte #%11111111    ; ######## @ FFE9
    .byte #%10011001    ; #  ##  # @ FFEA
    .byte #%11111111    ; ######## @ FFEB
    .byte #%11111111    ; ######## @ FFEC
    .byte #%11111111    ; ######## @ FFED
    .byte #%10111101    ; # #### # @ FFEE
    .byte #%11000011    ; ##    ## @ FFEF
    .byte #%11111111    ; ######## @ FFF0
    .byte #%01111110    ;  ######  @ FFF1 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Defines an array of bytes to draw the scoreboard number
;; We add these bytes in the final ROM addresses. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFF2           ; is this strictly necessary? 
NumberBitmap:
    .byte #%00001110    ; ########
    .byte #%00001110    ; ########
    .byte #%00000010    ;     ####
    .byte #%00000010    ;     ####
    .byte #%00001110    ; ########
    .byte #%00001110    ; ########
    .byte #%00001000    ; ####
    .byte #%00001000    ; ####
    .byte #%00001110    ; ########
    .byte #%00001110    ; ########

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set cartridge size to 4K, set restart and interrupt vectors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Reset
    .word Reset

