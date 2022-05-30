tmp1 = $0
tmp2 = $1
tmp3 = $2
rng_seed = $17
spawnID = $19
spawnCount = $1A
nextPiece = $00BF
iterations = $EF

; rng_seed = 0x8988
; spawnCount = 07

; pause, run generateNextPseudorandomNumber 16844 times

; 0x17: 4C
; 0x18: 00
; 0x19: 07


mainLoop:
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        lda rng_seed
        and #$0F
        cmp #$0A
        bpl mainLoop
        sta $AB


        ; ldx #$17
        ; ldy #$02
        ; jsr generateNextPseudorandomNumber
        ; jsr pickRandomTetrimino
        ; sta nextPiece
        inc iterations
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
