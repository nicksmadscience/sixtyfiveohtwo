    lda #%00000111 ; bit direction (write)
    sta $6002


    lda #%00000000 ; latch low
    sta $6000

    lda #%00000001 ; bit 0, clock low
    sta $6000

    lda #%00000011 ; bit 0, clock high
    sta $6000

    lda #%00000000 ; bit 1, clock low
    sta $6000

    lda #%00000010 ; bit 1, clock high
    sta $6000

    lda #%00000001 ; bit 2, clock low
    sta $6000

    lda #%00000011 ; bit 2, clock high
    sta $6000

    lda #%00000000 ; bit 3, clock low
    sta $6000

    lda #%00000010 ; bit 3, clock high
    sta $6000

    lda #%00000001 ; bit 4, clock low
    sta $6000

    lda #%00000011 ; bit 4, clock high
    sta $6000

    lda #%00000000 ; bit 5, clock low
    sta $6000

    lda #%00000010 ; bit 5, clock high
    sta $6000

    lda #%00000001 ; bit 6, clock low
    sta $6000

    lda #%00000011 ; bit 6, clock high
    sta $6000

    lda #%00000000 ; bit 7, clock low
    sta $6000

    lda #%00000010 ; bit 7, clock high
    sta $6000

    lda #%00000100 ; latch high
    sta $6000


