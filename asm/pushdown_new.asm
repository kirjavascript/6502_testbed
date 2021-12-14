marker := $EF
holdDownPoints := $01
score := $02 ; $03

buf := $10
ones := buf+1
hundredths := buf+2
pdptmp := buf+3
low := buf+4
high := buf+5
binScore := $80

main:
        lda score
        and #$F
        sta ones

        lda score
        jsr div16mul10
        adc ones
        sta hundredths

        lda holdDownPoints
        sbc #1
        adc ones
        sta pdptmp

        and #$F
        cmp #$A
        bcc @pdp2
        lda pdptmp
        adc #5
        sta pdptmp
@pdp2:

        lda pdptmp
        and #$f
        sta low

        lda pdptmp
        jsr div16mul10
        sta high

        lda hundredths
        sbc ones
        sec
        adc high
        sta pdptmp

        clc
        adc low
        cmp #101
        bcs @noLow
        sta pdptmp
@noLow:

        sec
        lda binScore
        sbc hundredths
        sta binScore
        lda binScore+1
        sbc #0
        sta binScore+1

        clc
        lda binScore
        adc pdptmp
        sta binScore
        lda binScore+1
        adc #0
        sta binScore+1

        lda #$FF
        sta marker

div16mul10:
        and #$f0
        ror
        ror
        ror
        ror
        tax
        lda multBy10Table,x
        rts

multBy10Table:
        .byte   $00,$0A,$14,$1E,$28,$32,$3C,$46
        .byte   $50,$5A,$64,$6E,$78,$82,$8C,$96
        .byte   $A0,$AA,$B4,$BE
