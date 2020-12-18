lines := $10
target := $20
marker := $F0

lineTargetThreshold := 110

main:

        lda lines
        cmp #lineTargetThreshold
        bcc @baseTarget


        jmp @done

@baseTarget:
        lda targetTable
        sta target
        lda targetTable
        sta target+1
@done:


        lda #$FF
        sta marker

targetTable:
        .byte $A0,$0F
        .byte $FC,$10
