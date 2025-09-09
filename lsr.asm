SOURCEBYTE = $0000
WORKBYTE   = $0001
PATTERNBYTE = $0002
PORTA      = $6000


    .org $1000


_start:
                    ; let's experi
    
    ldy #$00        ; fx counter 


    lda #%10000000  ; source byte
    sta SOURCEBYTE
    jsr shiftout

cycle:
    lda SOURCEBYTE
    lsr a
    sta SOURCEBYTE
    jsr shiftout

    iny
    cpy #7
    bne cycle


    jmp end



shiftout:
    lda #%00000100  ; latch high
    sta PORTA       ; send to shift register
    lda #%00000000  ; latch low; begin shifting
    sta PORTA       ; send to shift register

    ldx #$00        ; shift counter

    lda SOURCEBYTE  ; source byte
    sta WORKBYTE

    ; initial cycle without lsr
    and #1          ; set target bit to shift register data bit; all other bits low
    sta PORTA       ; send to shift register

    ora #2          ; set clock bit high
    sta PORTA       ; send to shift register

    jsr shiftsteps

    lda #%00000100  ; latch high; we're done here
    sta PORTA       ; send to shift register

    rts



shiftsteps:
    lda WORKBYTE  ; source byte
    lsr a           ; shift right once
    sta WORKBYTE  ; store resulting shifted jawn

    and #1          ; set target bit to shift register data bit; all other bits low
    sta PORTA       ; send to shift register

    ora #2          ; set clock bit high
    sta PORTA       ; send to shift register

    inx             ; increment counter
    cpx #7          ; go to eight bits
    bne shiftsteps  ; if we're not there, repeat

    rts




end:
    nop