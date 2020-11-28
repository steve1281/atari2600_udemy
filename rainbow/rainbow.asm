    processor 6502
    include "../include/vcs.h"
    include "../include/macro.h"
    
    seg code
    org $F000

Start:
    CLEAN_START

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start a new frame by turning on VBLANK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NextFrame:
    lda #2
    sta VBLANK
    sta VSYNC


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate three lines of VSYNC 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    sta WSYNC   ; wait for TIA for strobe
    sta WSYNC
    sta WSYNC
    lda #0
    sta VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Let the TIA output the recommended 37 lines of VBLANK 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #37
LoopVBlank:
    sta WSYNC   ; wait for TIA for strobe
    dex
    bne LoopVBlank
    lda #0
    sta VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draw 192 Visibile scan lines 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #192
LoopVisible:
    stx COLUBK  ; TIA background color
    sta WSYNC
    dex
    bne LoopVisible
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draw Over scan 30 lines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda #2
    sta VBLANK
    ldx #30
LoopOverscan:
    sta WSYNC
    dex
    bne LoopOverscan
   
    jmp NextFrame   ; back to top


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   force cartridge size to 4KB 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start
    .word Start
