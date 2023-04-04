; Modified version of playState_checkForCompletedRows that checks all 4 rows without crashing:
; https://github.com/zohassadar/TetrisNESDisasm/blob/single_frame_linecheck/main.asm#L3063

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


playfield = $0400


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
        tax                       ; +2
        lda     multBy10Table,x   ; +4
        sta     generalCounter
        ; asl     a               ; -2
        ; sta     generalCounter  ; -3
        ; asl     a               ; -2
        ; asl     a               ; -2
        ; clc                     ; -2
        ; adc     generalCounter  ; -3
        ; sta     generalCounter
        tay
        ldx     #$0A
@checkIfRowComplete:
        lda     playfield,y   ; -1
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
        lda     playfield,y ;     -1
        ; ldx     #$0A;           -2
        ; stx     playfieldAddr;  -3
        sta     playfield+10,y ;  -1
        ; lda     #$00         ;  -2
        ; sta     playfieldAddr;  -3
        dey
        cpy     #$FF
        bne     @movePlayfieldDownOneRow
        lda     #$EF
        ldy     #$00
@clearRowTopRow:
        sta     playfield,y  ; -1
        iny
        cpy     #$0A
        bne     @clearRowTopRow
        lda     #$13
        sta     currentPiece
        bne     @incrementLineIndex

@rowNotComplete:
        ldx     lineIndex
        lda     #$00
        sta     completedRow,x
@incrementLineIndex:
        inc     lineIndex
        lda     lineIndex
        cmp     #$04
        bmi     @updatePlayfieldComplete
        ; ldy     completedLines              ; -3
        ; lda     garbageLines,y              ; -4
        ; clc                                 ; -2
        ; adc     pendingGarbageInactivePlayer; -3
        ; sta     pendingGarbageInactivePlayer; -3
        lda     #$00
        sta     vramRow
        sta     rowY
        lda     #$04
        cmp     completedLines              ; +1
        bne     @skipTetrisSoundEffect
        ; cmp     #$04                      ; -2
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



multBy10Table:
        .byte   $00,$0A,$14,$1E,$28,$32,$3C,$46
        .byte   $50,$5A,$64,$6E,$78,$82,$8C,$96
        .byte   $A0,$AA,$B4,$BE,$C8
