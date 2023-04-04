; Original version of playState_checkForCompletedRows with single modification to check all 4 rows:
; https://github.com/CelestialAmber/TetrisNESDisasm/blob/master/main.asm#L3063    
   
        .setcpu "6502"


.segment    "PRG_chunk1": absolute

marker := $EF


tetriminoY = $0041
vramRow = $0049
currentPiece = $0042
completedRow = $004A
playState = $0048
rowY = $0052
lineIndex = $0057 
completedLines = $0056
generalCounter = $00A8
generalCounter2 = $00A9
playfieldAddr = $00B8
pendingGarbageInactivePlayer = $00BC
soundEffectSlot1Init = $06F1




playState_checkForCompletedRows:
        lda     vramRow
        cmp     #$20
        bpl     @updatePlayfieldComplete
        jmp     @ret

@updatePlayfieldComplete:
        lda     tetriminoY
        sec
        sbc     #$02
        bpl     @yInRange
        lda     #$00
@yInRange:
        clc
        adc     lineIndex
        sta     generalCounter2
        asl     a
        sta     generalCounter
        asl     a
        asl     a
        clc
        adc     generalCounter
        sta     generalCounter
        tay
        ldx     #$0A
@checkIfRowComplete:
        lda     (playfieldAddr),y
        cmp     #$EF
        beq     @rowNotComplete
        iny
        dex
        bne     @checkIfRowComplete
        lda     #$0A
        sta     soundEffectSlot1Init
        inc     completedLines
        ldx     lineIndex
        lda     generalCounter2
        sta     completedRow,x
        ldy     generalCounter
        dey
@movePlayfieldDownOneRow:
        lda     (playfieldAddr),y
        ldx     #$0A
        stx     playfieldAddr
        sta     (playfieldAddr),y
        lda     #$00
        sta     playfieldAddr
        dey
        cpy     #$FF
        bne     @movePlayfieldDownOneRow
        lda     #$EF
        ldy     #$00
@clearRowTopRow:
        sta     (playfieldAddr),y
        iny
        cpy     #$0A
        bne     @clearRowTopRow
        lda     #$13
        sta     currentPiece
        jmp     @incrementLineIndex

@rowNotComplete:
        ldx     lineIndex
        lda     #$00
        sta     completedRow,x
@incrementLineIndex:
        inc     lineIndex
        lda     lineIndex
        cmp     #$04
        bmi     @updatePlayfieldComplete      ; Modified from @ret
        ldy     completedLines
        lda     garbageLines,y
        clc
        adc     pendingGarbageInactivePlayer
        sta     pendingGarbageInactivePlayer
        lda     #$00
        sta     vramRow
        sta     rowY
        lda     completedLines
        cmp     #$04
        bne     @skipTetrisSoundEffect
        lda     #$04
        sta     soundEffectSlot1Init
@skipTetrisSoundEffect:
        inc     playState
        lda     completedLines
        bne     @ret
        inc     playState
        lda     #$07
        sta     soundEffectSlot1Init
@ret:
        lda #$FF
        sta marker


garbageLines:
        .byte   $00,$00,$01,$02,$04

multBy10Table:
        .byte   $00,$0A,$14,$1E,$28,$32,$3C,$46
        .byte   $50,$5A,$64,$6E,$78,$82,$8C,$96
        .byte   $A0,$AA,$B4,$BE,$C8
