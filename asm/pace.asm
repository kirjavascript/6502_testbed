lines := $10
target := $20


main:

    lda lines
    cmp #110
    bcc @baseTarget


@baseTarget:
    lda targetTable
    sta target
    lda targetTable
    sta target+1

@done:


targetTable:
        .byte $A0,$0F
        .byte $FC,$10
