        .setcpu "6502"


.segment    "PRG_chunk1": absolute

lines := $10
levelNumber := $F
generalCounter2 := $20
generalCounter := $21
marker = $EF

start:

        ldx #$A
incrementLines:
        inc lines
        lda lines
        and #$0F
        cmp #$0A
        bmi checkLevelUp
        lda lines
        clc
        adc #$06
        sta lines
        and #$F0
        cmp #$A0
        bcc checkLevelUp
        lda lines
        and #$0F
        sta lines
        inc lines+1

checkLevelUp:

        lda lines
        and #$0F
        bne @lineLoop

        lda lines+1
        sta generalCounter2
        lda lines
        sta generalCounter
        lsr generalCounter2
        ror generalCounter
        lsr generalCounter2
        ror generalCounter
        lsr generalCounter2
        ror generalCounter
        lsr generalCounter2
        ror generalCounter
        lda levelNumber
        cmp generalCounter
        bpl @lineLoop

@nextLevel:
        inc levelNumber
        lda #$FF
        sta marker
@lineLoop:  dex
        bne incrementLines

        jmp start

.code
