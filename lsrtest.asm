SOURCEBYTE = $0000
WORKBYTE   = $0001

    lda #%11111111
    sta $0000

    ldx #0

    lda $0000
    and #1
    sta $6000
    ora #2
    sta $6000

loop:
    lda $0000
    lsr
    sta $0000
    and #1
    sta $6000
    ora #2
    sta $6000

    inx
    cpx #7
    bne loop


    nop

