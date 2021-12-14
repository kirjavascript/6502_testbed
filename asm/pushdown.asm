marker := $EF
holdDownPoints := $01
score := $02 ; $03
dummy_0 := $10


main:
        lda holdDownPoints
        clc                                     ; 9C04
        dec     score                           ; 9C05
        adc     score                           ; 9C07
        sta     score                           ; 9C09
        and     #$0F                            ; 9C0B
        cmp     #$0A                            ; 9C0D
        bcc     @noLowOverflow                  ; 9C0F
        lda     score                           ; 9C11
        clc                                     ; 9C13
        adc     #$06                            ; 9C14
        sta     score                           ; 9C16
@noLowOverflow:
        lda     score                           ; 9C18
        and     #$F0                            ; 9C1A
        cmp     #$A0                            ; 9C1C
        bcc     @noHighOverflow                 ; 9C1E
        clc                                     ; 9C20
        adc     #$60                            ; 9C21
        sta     score                           ; 9C23
        inc     score+1                         ; 9C25
@noHighOverflow:

        lda     score+1                         ; 9C55
        and     #$0F                            ; 9C57
        cmp     #$0A                            ; 9C59
        bcc     @noScore1LowOverlow             ; 9C5B
        lda     score+1                         ; 9C5D
        clc                                     ; 9C5F
        adc     #$06                            ; 9C60
        sta     score+1                         ; 9C62
@noScore1LowOverlow:

@addLineClearPoints:
        lda     #$00                            ; 9C2D
        sta     holdDownPoints                  ; 9C2F
        lda     dummy_0 ; levelNumber                    ; 9C31
        sta     $11                  ; 9C33
        inc     $11                  ; 9C35
@levelLoop:
        lda     dummy_0 ;completedLines                  ; 9C37
        asl     a                               ; 9C39
        tax                                     ; 9C3A
        lda     pointsTable,x                   ; 9C3B
        clc                                     ; 9C3E
        adc     score                           ; 9C3F
        sta     score                           ; 9C41
        cmp     #$A0                            ; 9C43
        bcc     @score1AddPoints                ; 9C45
        clc                                     ; 9C47
        adc     #$60                            ; 9C48
        sta     score                           ; 9C4A
        inc     score+1                         ; 9C4C
@score1AddPoints:
        inx                                     ; 9C4E
        lda     pointsTable,x                   ; 9C4F
        clc                                     ; 9C52
        adc     score+1                         ; 9C53
        sta     score+1                         ; 9C55
        and     #$0F                            ; 9C57
        cmp     #$0A                            ; 9C59
        bcc     @score1High                     ; 9C5B
        lda     score+1                         ; 9C5D
        clc                                     ; 9C5F
        adc     #$06                            ; 9C60
        sta     score+1                         ; 9C62
@score1High:
        lda     score+1                         ; 9C64
        and     #$F0                            ; 9C66
        cmp     #$A0                            ; 9C68
        bcc     @score2Low                      ; 9C6A
        lda     score+1                         ; 9C6C
        clc                                     ; 9C6E
        adc     #$60                            ; 9C6F
        sta     score+1                         ; 9C71
        inc     score+2                         ; 9C73
@score2Low:
        lda     score+2                         ; 9C75
        and     #$0F                            ; 9C77
        cmp     #$0A                            ; 9C79
        bcc     @score2High                     ; 9C7B
        lda     score+2                         ; 9C7D
        clc                                     ; 9C7F
        adc     #$06                            ; 9C80
        sta     score+2                         ; 9C82
@score2High:
        lda     score+2                         ; 9C84
        and     #$F0                            ; 9C86
        cmp     #$A0                            ; 9C88
        bcc     @levelLoopCheck                 ; 9C8A
        lda     #$99                            ; 9C8C
        sta     score                           ; 9C8E
        sta     score+1                         ; 9C90
        sta     score+2                         ; 9C92
@levelLoopCheck:
        dec     $11                  ; 9C94
        bne     @levelLoop                      ; 9C96

        lda #$FF
        sta marker

pointsTable:
        .word   $0000,$0040,$0100,$0300         ; 9CA5
        .word   $1200                           ; 9CAD
