SOURCEBYTE  = $0000
WORKBYTE    = $0001
PATTERNBYTE = $0002
PORTA       = $6000
input_a     = $0003
input_x     = $0004
input_y     = $0005
RANDOMSTEP  = $0006



    .org $8000


reset:
    ldy #0
    sty RANDOMSTEP

    jsr checkinput


checkinput:
    sta input_a
    stx input_x
    sty input_y

    ldx $6008
    cpx #0
    beq startcycle
    cpx #1
    beq startcycle2
    cpx #2
    beq randomloop
    cpx #3
    beq blinkstart

    lda input_a
    ldx input_x
    ldy input_y

    rts

    


    
startcycle:
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

    jsr checkinput
    


startcycle2
    ldy #$00        ; fx counter 

    lda #%00000001  ; source byte
    sta SOURCEBYTE
    jsr shiftout


 cycle2:
    lda SOURCEBYTE
    asl a
    sta SOURCEBYTE
    jsr shiftout

    iny
    cpy #7
    bne cycle2
    
    jsr checkinput





randomloop:
    ldy RANDOMSTEP
    lda $8000, y ; program code ftw
    sta SOURCEBYTE
    jsr shiftout
    iny
    sty RANDOMSTEP
    jsr checkinput
    cpy #109
    bne randomloop
    beq reset



blinkstart:
    lda #$ff
    sta SOURCEBYTE
    jsr shiftout
    ldx #0

blinkonwait:
    inx
    cpx #40
    bne blinkonwait

    lda #$00
    sta SOURCEBYTE
    jsr shiftout
    ldx #0

blinkoffwait:
    inx
    cpx #40
    bne blinkoffwait
    beq blinkreset

blinkreset:
    jmp reset






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
    lda WORKBYTE    ; source byte
    lsr a           ; shift right once
    sta WORKBYTE    ; store resulting shifted jawn

    and #1          ; set target bit to shift register data bit; all other bits low
    sta PORTA       ; send to shift register

    ora #2          ; set clock bit high
    sta PORTA       ; send to shift register

    inx             ; increment counter
    cpx #7          ; go to eight bits
    bne shiftsteps  ; if we're not there, repeat

    rts







; RANDOM .byte $8c, $91, $cb, $c0, $07, $fb, $6f, $e3, $98, $f9, $e7, $54, $19, $a9, $e5, $d8, $e4, $75, $b8, $a0, $41, $e1, $cb, $b1, $bc, $d8, $57, $d3, $23, $1d, $2f, $3a


    .org $fffc
    .word blinkstart
    .word $0000
