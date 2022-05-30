        .setcpu "6502"


.segment    "PRG_chunk1": absolute

tmpX        := $0003
tmpY        := $0004
tmpZ        := $0005
completedLinesCopy := $623 ; hard drop
completedLines  := $0056
lineOffset := $624 ; hard drop
playfield   := $0400

EMPTY_TILE := $EF

marker = $EF

harddrop_tetrimino:

        ; hard drop line clear algorithm (kinda);

        ; completedLines = 0

        ; for (i = 19; i >= completedLines; i--) {
        ;     if (rowIsFull(i)) {
        ;         completedLines++
        ;     }

        ;     lineOffset = 0
        ;     completedLinesCopy = completedLines

        ;     for (lineIndex = i - 1; completedLinesCopy > 0; lineIndex--) {
        ;         if (!rowIsFull(lineIndex)) {
        ;             completedLinesCopy--
        ;         }
        ;         lineOffset++
        ;     }

        ;     if (completedLines > 0) {
        ;         for (j = 0; j < 10 ; j++) {
        ;             index = (i * 10) + j
        ;             copyPlayfield(index - (lineOffset * 10), index)
        ;         }
        ;     }
        ; }

        ; for (i = 0; i < completedLines; i++ {
        ;     clearRow(i)
        ; }

        lda #19
        sta tmpY ; row
@lineLoop:

        ldx tmpY
        lda multBy10Table, x
        tax

        ; check for empty row
        ldy #$0
@minoLoop:
        lda playfield, x
        cmp #EMPTY_TILE
        beq @noLineClear

        inx
        iny
        cpy #$A
        beq @lineClear
        jmp @minoLoop

@lineClear:
        inc completedLines
@noLineClear:
        lda completedLines
        beq @nextLine

        ; get line offset
        lda #0
        sta lineOffset
        lda completedLines
        sta completedLinesCopy

        sec
        txa
        sbc #20
        sta tmpZ ; i - 1
        tax

@offsetLoop:
        ; check for empty row
        ldy #$0
@offsetCheckLineFull:
        lda playfield, x
        cmp #EMPTY_TILE
        beq @emptyLine

        inx
        iny
        cpy #$A
        beq @fullLine
        jmp @offsetCheckLineFull

@emptyLine:
        dec completedLinesCopy
@fullLine:
        inc lineOffset

        lda tmpZ
        sbc #10
        sta tmpZ
        tax

        lda completedLinesCopy
        bne @offsetLoop

        lda lineOffset
        beq @nextLine

        tax
        lda multBy10Table, x
        sta lineOffset ; reuse for lineOffset * 10

        ; loop*10
        ldy #0
        ldx tmpY
        lda multBy10Table, x
        sta tmpX
        sec
        sbc lineOffset
        sta tmpZ

@shiftLineLoop:

        ldx tmpZ
        lda playfield, x
        ldx tmpX
        sta playfield, x

        inc tmpX
        inc tmpZ
        iny
        cpy #$A
        bne @shiftLineLoop

@nextLine:
        dec tmpY
        lda tmpY
        cmp #0
        beq @addScore
        jmp @lineLoop

@addScore:
@ret:

        lda #$EF
        sta marker

multBy10Table:
        .byte   $00,$0A,$14,$1E,$28,$32,$3C,$46
        .byte   $50,$5A,$64,$6E,$78,$82,$8C,$96
        .byte   $A0,$AA,$B4,$BE
