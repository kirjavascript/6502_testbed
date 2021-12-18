
tmp1 = $0
tmp2 = $1
rng_seed = $17
marker = $EF

mainLoop:

        ldx #$17
        ldy #$02
        jsr generateNextPseudorandomNumber

        lda #$FF
        sta marker

generateNextPseudorandomNumber:
        lda tmp1,x
        and #$02
        sta tmp1
        lda tmp2,x
        and #$02
        eor tmp1
        clc
        beq updateNextByteInSeed
        sec
updateNextByteInSeed:
        ror tmp1,x
        inx
        dey
        bne updateNextByteInSeed
        rts

spawnTable:
        .byte   $02,$07,$08,$0A,$0B,$0E,$12
        .byte   $02
spawnOrientationFromOrientation:
        .byte   $02,$02,$02,$02,$07,$07,$07,$07
        .byte   $08,$08,$0A,$0B,$0B,$0E,$0E,$0E
        .byte   $0E,$12,$12
