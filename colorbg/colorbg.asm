    processor 6502
    include "../include/vcs.h"
    include "../include/macro.h"

    seg code
    org $F000
START:
    CLEAN_START    ; calling a macro in macro.h to clean page 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set background luminousity colour to yellow.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda #$1E    ; yellow into A (NTCS yellow)
    sta COLUBK  ; using the value into background color ($09)
    
    ;jmp START   ; repeat from start. (ick?)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Fill ROM size to exactly 4KB  - err. why not macro this?
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC   ; define the orgin to $FFFC
    .word START ; reset vector FFFC
    .word START ; interrupt vector FFFE

