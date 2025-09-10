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
PAUSETIME    = $000b
TINYPAUSETIME = $000c
SINGLESHIFTPAUSE = $000d
ACACHE = $000e
XCACHE = $000f
YCACHE = $0010
SHIFTPAUSEYCACHE = $0011



    .org $8000


reset:
    ldy #0                ; init some stuff
    sty RANDOMSTEP
    ldy #%11111111
    sty BLINKHIGH
    ldy #%00000000
    sty BLINKLOW

    lda #150            ; standard pause time; adjust according to clock speed
    sta PAUSETIME

    lda #30
    sta TINYPAUSETIME




checkinput:
    sta input_a           ; cache the registers; more important if it's actually an interrupt
    stx input_x
    sty input_y


    lda #0
    sta SINGLESHIFTPAUSE

    lda $6008             ; choose sequence based on io lines

    nop
    and #%00001000
    cmp #%00001000
    beq ci_sethighspeed
    bne ci_setlowspeed
postsetspeed:
    lda $6008             ; choose sequence based on io lines
    and #%00000111

    cmp #0
    beq ci_randomcascadeloop

    cmp #1
    beq ci_startcycle

    cmp #2
    beq ci_startcycle2

    cmp #3
    beq ci_randomloop

    cmp #4
    beq ci_blinkstart

    cmp #5
    beq ci_allblink

    cmp #6
    beq ci_cylon

    cmp #7
    beq ci_randomloopsingleshift



    lda input_a
    ldx input_x
    ldy input_y



ci_startcycle:              ; avoid branch-out-of-range stuff
    jmp startcycle

ci_startcycle2:
    jmp startcycle2

ci_randomloop:
    jmp randomloop

ci_blinkstart:
    jmp blinkstart

ci_randomcascadeloop:
    jmp randomcascadeloop

ci_allblink:
    jmp allblink

ci_cylon:
    jmp cylon

ci_randomloopsingleshift:
    lda #1
    sta SINGLESHIFTPAUSE
    jmp randomloop

ci_sethighspeed:
    ldy #10
    sty PAUSETIME
    ldy #40
    sty TINYPAUSETIME
    jmp postsetspeed

ci_setlowspeed:
    ldy #70
    sty PAUSETIME
    ldy #255
    sty TINYPAUSETIME
    jmp postsetspeed




    
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
    jsr pause
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
    jsr pause
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

    jsr tinypause

    sty RANDOMSTEP
    jmp checkinput
    cpy #255
    bne randomloop
    beq randomreset

randomreset:
    jmp reset



randomcascadeloop:
    ldy RANDOMSTEP

    lda $8000, y ; program code ftw
    sta SOURCEBYTE
    jsr singleshift
    iny             ; increment forever
    
    sty RANDOMSTEP
    jsr pause
    jsr pause
    jmp checkinput




blinkstart:
    lda BLINKHIGH
    sta SOURCEBYTE
    jsr singleshift
    ldx #0

    jsr pause
    jsr pause

    lda BLINKLOW
    sta SOURCEBYTE
    jsr singleshift
    ldx #0

    jsr pause
    jsr pause

    ; increment blink counter
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



allblink:
    lda #$ff
    sta SOURCEBYTE

    jsr shiftfive
    jsr pause
    jsr pause
    jsr pause

    lda #$00
    sta SOURCEBYTE

    jsr shiftfive
    jsr pause
    jsr pause
    jsr pause

    jmp checkinput


shiftfive:
    jsr shiftstart
    jsr shiftout
    jsr shiftout
    jsr shiftout
    jsr shiftout
    jsr shiftout
    jsr shiftend
    rts



cylon:
    lda #%10000000
    sta SOURCEBYTE
    jsr shiftfive

    jsr cylonleft
    jsr cylonleft
    jsr cylonleft
    jsr cylonleft
    jsr cylonleft
    jsr cylonleft
    jsr cylonleft

    jsr cylonright
    jsr cylonright
    jsr cylonright
    jsr cylonright
    jsr cylonright
    jsr cylonright
    jsr cylonright

    jmp checkinput


cylonleft:
    lda SOURCEBYTE
    lsr a
    sta SOURCEBYTE
    jsr shiftfive
    rts

cylonright:
    lda SOURCEBYTE
    asl a
    sta SOURCEBYTE
    jsr shiftfive
    rts






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
    sta ACACHE
    stx XCACHE
    sty YCACHE

    ldx #$00        ; shift counter

    lda SOURCEBYTE  ; source byte
    sta WORKBYTE

    ; initial cycle without lsr
    and #1          ; set target bit to shift register data bit; all other bits low
    sta PORTA       ; send to shift register

    ora #2          ; set clock bit high
    sta PORTA       ; send to shift register

    jsr shiftsteps  ; shift remaining steps

    lda ACACHE
    ldx XCACHE
    ldy YCACHE

    rts



shiftsteps:
    lda WORKBYTE    ; source byte
    lsr a           ; shift right once
    sta WORKBYTE    ; store resulting shifted jawn

    and #1          ; set target bit to shift register data bit; all other bits low
    sta PORTA       ; send to shift register

    sty SHIFTPAUSEYCACHE
    ldy SINGLESHIFTPAUSE
    cpy #1
    beq shiftpause
    
    ora #2          ; set clock bit high
    
shiftresume:
    sta PORTA       ; send to shift register
    ldy SHIFTPAUSEYCACHE
    inx             ; increment counter
    cpx #7          ; go to eight bits
    bne shiftsteps  ; if we're not there, repeat

    rts

shiftpause:
    ora #6          ; shift in place
    jsr pause
    jmp shiftresume







pause:
    stx PAUSE_X
    ldx #0
    jsr pauseloop
    rts


pauseloop:
    inx
    cpx PAUSETIME
    bne pauseloop

    ldx PAUSE_X
    rts



tinypause:
    stx PAUSE_X
    ldx #0
    jsr tinypauseloop
    rts


tinypauseloop:
    inx
    cpx TINYPAUSETIME
    bne tinypauseloop

    ldx PAUSE_X
    rts







; RANDOM .byte $8c, $91, $cb, $c0, $07, $fb, $6f, $e3, $98, $f9, $e7, $54, $19, $a9, $e5, $d8, $e4, $75, $b8, $a0, $41, $e1, $cb, $b1, $bc, $d8, $57, $d3, $23, $1d, $2f, $3a


    .org $fffc
    .word blinkstart
    .word $0000
