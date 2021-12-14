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

        lda binScore
@modLoop:
        cmp #100
        bcc @modEnd
        sec
        sbc #100
        jmp @modLoop
@modEnd:
        sta hundredths

        lda holdDownPoints
        sbc #1
        adc ones
        sta pdptmp

        and #$F
        cmp #$A
        bcc @pdp2
        lda pdptmp
        adc #6
        sta pdptmp
@pdp2:

        lda pdptmp
        and #$f
        sta low

        lda pdptmp
        and #$f0
        ror
        ror
        ror
        ror
        tax
        lda multBy10Table,x
        sta high

        lda hundredths
        sbc ones
        adc high
        sta pdptmp

        adc low
        cmp #101
        bcs @noLow
        sta pdptmp
@noLow:

        lda binScore
        sbc hundredths
        adc pdptmp
        sta binScore
        ; TODO

        lda #$FF
        sta marker

multBy10Table:
        .byte   $00,$0A,$14,$1E,$28,$32,$3C,$46
        .byte   $50,$5A,$64,$6E,$78,$82,$8C,$96
        .byte   $A0,$AA,$B4,$BE
