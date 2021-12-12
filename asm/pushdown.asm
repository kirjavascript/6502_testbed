marker := $EF
holdDownPoints := $01
score := $02 ; $03


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

        lda #$FF
        sta marker
