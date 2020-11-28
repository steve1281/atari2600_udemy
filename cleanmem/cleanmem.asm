    processor 6502

    seg code
    org $F000  ; start of ROM cartridge
    
Start:
    sei        ; disable interrupts (odd, but necessary)
    cld        ; disable/clear the decimal mode (BCD)
    ldx #$FF
    txs        ; transfer x reg to the stack pointer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Clear the page zero region ($00 to $FF)
;  Meaning clear entire RAM and clear the TIA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #0       ; a=0
    ldx #$FF     ; x=#$ff

MemLoop:
    sta $0,x     ; store value a inside memory $0 plus x
    dex          ; x--
    bne MemLoop  ; Loop until x ==0 (until z flag is set)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start  ; Reset vector at $FFFC (where the program starts)
    .word Start  ; Interrupt vector $FFFE (yup, same. not a a typo).






