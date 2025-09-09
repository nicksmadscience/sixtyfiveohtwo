SOURCEBYTE   = $0000
WORKBYTE     = $0001
PATTERNBYTE  = $0002
PORTA        = $6000
input_a      = $0003
input_x      = $0004
input_y      = $0005
RANDOMSTEP   = $0006
BLINKHIGH    = $0007
BLINKLOW     = $0008
BLINKCOUNTER = $0009
PAUSE_X      = $000a


    .org $8000


reset:
    ldy #0
    sty RANDOMSTEP



checkinput:
    sta input_a
    stx input_x
    sty input_y

    ldx $6008
    cpx #0
    beq ci_startcycle
    cpx #1
    beq ci_startcycle2
    cpx #2
    beq ci_randomloop
    cpx #3
    beq ci_blinkstart

    lda input_a
    ldx input_x
    ldy input_y



ci_startcycle:
    jmp startcycle

ci_startcycle2:
    jmp startcycle2

ci_randomloop:
    jmp randomloop

ci_blinkstart:
    jmp blinkstart


    
startcycle:
    ldy #$00        ; fx counter 


    lda #%10000000  ; source byte
    sta SOURCEBYTE
    jsr singleshift

 cycle:
    lda SOURCEBYTE
    lsr a
    sta SOURCEBYTE
    jsr singleshift
    jsr pause

    iny
    cpy #7
    bne cycle

    jmp checkinput
    


startcycle2
    ldy #$00        ; fx counter 

    lda #%00000001  ; source byte
    sta SOURCEBYTE
    jsr singleshift


 cycle2:
    lda SOURCEBYTE
    asl a
    sta SOURCEBYTE
    jsr singleshift
    jsr pause

    iny
    cpy #7
    bne cycle2
    
    jmp checkinput





randomloop:
    ldy RANDOMSTEP


    jsr shiftstart
    lda $8000, y ; program code ftw
    sta SOURCEBYTE
    jsr shiftout
    iny
    lda $8000, y ; program code ftw
    sta SOURCEBYTE
    jsr shiftout
    iny
    lda $8000, y ; program code ftw
    sta SOURCEBYTE
    jsr shiftout
    iny
    lda $8000, y ; program code ftw
    sta SOURCEBYTE
    jsr shiftout
    iny
    lda $8000, y ; program code ftw
    sta SOURCEBYTE
    jsr shiftout
    iny
    jsr shiftend

    sty RANDOMSTEP
    jmp checkinput
    cpy #150
    bne randomloop
    beq randomreset

randomreset:
    jmp reset



blinkstart:
    lda BLINKHIGH
    sta SOURCEBYTE
    jsr singleshift
    ldx #0

blinkonwait:
    inx
    cpx #120
    bne blinkonwait

    lda BLINKLOW
    sta SOURCEBYTE
    jsr singleshift
    ldx #0

blinkoffwait:
    inx
    cpx #120
    bne blinkoffwait
    beq blinkcounterincrement

blinkcounterincrement:
    ldy BLINKCOUNTER
    iny
    sty BLINKCOUNTER
    cpy #10
    beq blinkpattern1
    cpy #20
    beq blinkpattern2
    cpy #30
    beq blinkpattern3
    cpy #40
    beq resetblinkcounter
    jmp blinkreset

blinkpattern1:
    lda #%11111111
    sta BLINKHIGH
    lda #%00000000
    sta BLINKLOW
    jmp blinkreset

blinkpattern2:
    lda #%11110000
    sta BLINKHIGH
    lda #%10101010
    sta BLINKLOW
    jmp blinkreset

blinkpattern3:
    lda #%11001100
    sta BLINKHIGH
    lda #%00110011
    sta BLINKLOW
    jmp blinkreset

resetblinkcounter:
    lda #0
    sta BLINKCOUNTER

blinkreset:
    jmp checkinput




singleshift:
    jsr shiftstart
    jsr shiftout
    jsr shiftend
    rts



shiftstart:
    lda #%00000100  ; latch high
    sta PORTA       ; send to shift register
    lda #%00000000  ; latch low; begin shifting
    sta PORTA       ; send to shift register
    rts


shiftend:
    lda #%00000100  ; latch high; we're done here
    sta PORTA       ; send to shift register
    rts



shiftout:
    ldx #$00        ; shift counter

    lda SOURCEBYTE  ; source byte
    sta WORKBYTE

    ; initial cycle without lsr
    and #1          ; set target bit to shift register data bit; all other bits low
    sta PORTA       ; send to shift register

    ora #2          ; set clock bit high
    sta PORTA       ; send to shift register

    jsr shiftsteps  ; shift remaining steps

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


pause:
    stx PAUSE_X
    ldx #0
    jsr pauseloop
    rts


pauseloop:
    inx
    cpx #80
    bne pauseloop

    ldx PAUSE_X
    rts







; RANDOM .byte $8c, $91, $cb, $c0, $07, $fb, $6f, $e3, $98, $f9, $e7, $54, $19, $a9, $e5, $d8, $e4, $75, $b8, $a0, $41, $e1, $cb, $b1, $bc, $d8, $57, $d3, $23, $1d, $2f, $3a


    .org $fffc
    .word blinkstart
    .word $0000
