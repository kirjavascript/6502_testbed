marker := $EF

typeBModifier := $3
generalCounter := $4
generalCounter2 := $5
generalCounter3 := $6
generalCounter4 := $7
generalCounter5 := $8
vramRow := $9


tmp1 = $0
tmp2 = $1
tmp3 = $2
typeBInitHeight := $C
rng_seed := $17 ; $18
spawnID = $19
spawnCount = $1A
nextPiece = $00BF

playfield := $200


main:
        jsr initPlayfieldForTypeB

        lda #$FF
        sta marker

initPlayfieldForTypeB:
        lda typeBInitHeight
        sta generalCounter
L87E7:  lda generalCounter
        beq L884A
        lda #$14
        sec
        sbc generalCounter
        sta generalCounter2
        lda #$00
        sta vramRow
        lda #$09
        sta generalCounter3
L87FC:  ldx #$17
        ldy #$02
        jsr generateNextPseudorandomNumber
        lda rng_seed
        and #$07
        tay
        lda rngTable,y
        sta generalCounter4
        ldx generalCounter2
        lda multBy10Table,x
        clc
        adc generalCounter3
        tay
        lda generalCounter4
        sta playfield,y
        lda generalCounter3
        beq L8824
        dec generalCounter3
        jmp L87FC

L8824:
        ldx #$17
        ldy #$02
        jsr generateNextPseudorandomNumber
        lda rng_seed
        and #$0F
        cmp #$0A
        bpl L8824
        sta generalCounter5
        ldx generalCounter2
        lda multBy10Table,x
        clc
        adc generalCounter5
        tay
        lda #$EF
        sta playfield,y
        ; jsr updateAudioWaitForNmiAndResetOamStaging
        dec generalCounter
        bne L87E7
L884A:
        ldx typeBModifier
        lda typeBBlankInitCountByHeightTable,x
        tay
        lda #$EF
L885D:  sta playfield,y
        dey
        cpy #$0
        bne L885D
        lda #$00
        sta vramRow
        rts

        ; 0 3 5 8 10 12 -> 14 16 18
typeBBlankInitCountByHeightTable:
        .byte $C8,$AA,$96,$78,$64,$50,$3C,$28,$14
rngTable:
        .byte $EF,$7B,$EF,$7C,$7D,$7D,$EF
        .byte $EF

mainLoop:

        ldx #$17
        ldy #$02
        jsr generateNextPseudorandomNumber

        jsr pickRandomTetrimino
        sta nextPiece
        jmp mainLoop

pickRandomTetrimino:
        jsr realStart
        rts

realStart:
        inc spawnCount
        lda rng_seed
        clc
        adc spawnCount
        and #$07
        cmp #$07
        beq invalidIndex
        tax
        lda spawnTable,x
        cmp spawnID
        bne useNewSpawnID
invalidIndex:
        ldx #$17
        ldy #$02
        jsr generateNextPseudorandomNumber
        lda rng_seed
        and #$07
        clc
        adc spawnID
L992A:  cmp #$07
        bcc L9934
        sec
        sbc #$07
        jmp L992A

L9934:
        tax
        lda spawnTable,x
useNewSpawnID:
        sta spawnID
        rts

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

multBy10Table:
        .byte   $00,$0A,$14,$1E,$28,$32,$3C,$46
        .byte   $50,$5A,$64,$6E,$78,$82,$8C,$96
        .byte   $A0,$AA,$B4,$BE
