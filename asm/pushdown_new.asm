marker := $EF
holdDownPoints := $01
score := $02 ; $03

buf := $10
ones := buf+1
hundredths := buf+2
pdptmp := buf+3
low := buf+4
high := buf+5
binScore := $80

main:
        lda #0
        sta completedLines
        lda #18
        sta levelNumber

        clc
        lda score
        and #$F
        sta ones

        lda score
        jsr div16mul10
        adc ones
        sta hundredths

        lda holdDownPoints
        sbc #1
        adc ones
        sta pdptmp

        and #$F
        cmp #$A
        bcc @pdp2
        lda pdptmp
        adc #5
        sta pdptmp
@pdp2:

        lda pdptmp
        and #$f
        sta low

        lda pdptmp
        jsr div16mul10
        sta high

        lda hundredths
        sbc ones
        sec
        adc high
        sta pdptmp

        clc
        adc low
        cmp #101
        bcs @noLow
        sta pdptmp
@noLow:

        sec
        lda binScore
        sbc hundredths
        sta binScore
        lda binScore+1
        sbc #0
        sta binScore+1
        lda binScore+2
        sbc #0
        sta binScore+2
        lda binScore+3
        sbc #0
        sta binScore+3

        clc
        lda binScore
        adc pdptmp
        sta binScore
        lda binScore+1
        adc #0
        sta binScore+1
        lda binScore+2
        adc #0
        sta binScore+2
        lda binScore+3
        adc #0
        sta binScore+3

        ; jsr addLineClearPoints

        lda #$FF
        sta marker

div16mul10:
        and #$f0
        ror
        ror
        ror
        ror
        tax
        lda multBy10Table,x
        rts

scr := $90
product24 := scr
factorB24 := scr+3
factorA24 := scr+6
binary32 := scr+9
bcd32 := scr+13
exp := scr+16
completedLines :=scr+18
levelNumber :=scr+19

bigScore := scr+25

addLineClearPoints:
        lda #0
        sta factorA24+1
        sta factorA24+2
        lda levelNumber
        adc #1
        sta factorA24

        lda completedLines
        asl
        tax
        lda pointsTable, x
        sta factorB24+0
        lda pointsTable+1, x
        sta factorB24+1
        lda #0
        sta factorB24+2

        jsr unsigned_mul24 ; points to add in product24

        clc
        lda binScore
        adc product24
        sta binScore
        lda binScore+1
        adc product24+1
        sta binScore+1
        lda binScore+2
        adc product24+2
        sta binScore+2
        lda binScore+3
        adc #0
        sta binScore+3

        ; lda     outOfDateRenderFlags
        ; ora     #$04
        ; sta     outOfDateRenderFlags
        ; lda     #$00
        ; sta     completedLines
        ; inc     playState

        lda binScore
        sta binary32
        lda binScore+1
        sta binary32+1
        lda binScore+2
        sta binary32+2
        lda binScore+3
        sta binary32+3
        jsr hex2dec

        lda binScore
        sta binary32
        lda binScore+1
        sta binary32+1
        lda binScore+2
        sta binary32+2
        lda binScore+3
        sta binary32+3
        jsr BIN_BCD

        lda bcd32
        sta score
        lda bcd32+1
        sta score+1
        lda bcd32+2
        sta score+2
        lda bcd32+3
        rts

        ; converts 10 digits (32 bit values have max. 10 decimal digits)
        ; https://codebase64.org/doku.php?id=base:32_bit_hexadecimal_to_decimal_conversion
hex2dec:
        ldx #0
hexloop:
        jsr @div10
        sta bigScore,x
        inx
        cpx #10
        bne hexloop
        rts

        ; divides a 32 bit value by 10
        ; remainder is returned in akku
@div10:
        ldy #32         ; 32 bits
        lda #0
        clc
@loop:   rol
        cmp #10
        bcc @skip
        sbc #10
@skip:  rol binary32
        rol binary32+1
        rol binary32+2
        rol binary32+3
        dey
        bpl @loop
        rts

unsigned_mul24:
	lda #$00			; set product to zero
	sta product24
	sta product24+1
	sta product24+2

@loop:
	lda factorB24                   ; while factorB24 !=0
	bne @nz
	lda factorB24+1
	bne @nz
	lda factorB24+2
	bne @nz
	rts
@nz:
	lda factorB24; if factorB24 isodd
	and #$01
	beq @skip

	lda factorA24			; product24 += factorA24
	clc
	adc product24
	sta product24

	lda factorA24+1
	adc product24+1
	sta product24+1

	lda factorA24+2
	adc product24+2
	sta product24+2			; end if

@skip:
	asl factorA24			; << factorA24
	rol factorA24+1
	rol factorA24+2
	lsr factorB24+2			; >> factorB24
	ror factorB24+1
	ror factorB24

	jmp @loop			; end while

BIN_BCD:
        lda binary32+3 ;Get MSBY
        and #$f0     ;Filter out low nibble
        lsr a        ;Move hi nibble right (dp)
        lsr a
        lsr a
        lsr a
        sta exp      ;store dp
        lda binary32+3
        and #$0f     ;Filter out high nibble
        sta binary32+3
BCD_DP:
        ldy #$00     ;Clear table pointer
NXTDIG:
        ldx #$00     ;Clear digit count
SUB_MEM:
        lda binary32   ;Get LSBY of binary value
        sec
        sbc SUBTBL,y ;Subtract LSBY + y of table value
        sta binary32   ;Return result
        lda binary32+1 ;Get next byte of binary value
        iny
        sbc SUBTBL,y ;Subtract next byte of table value
        sta binary32+1
        lda binary32+2 ;Get next byte
        iny
        sbc SUBTBL,y ;Subtract next byte of table
        sta binary32+2
        lda binary32+3 ;Get MSBY of binary value
        iny
        sbc SUBTBL,y ;Subtract MSBY of table
        bcc ADBACK   ;If result is neg go add back
        sta binary32+3 ;Store MSBY then point back to LSBY of table
        dey
        dey
        dey
        inx
        jmp SUB_MEM  ;Go subtract again
ADBACK:
        dey          ;Point back to LSBY of table
        dey
        dey
        lda binary32   ;Get LSBY of binary value and add LSBY
        adc SUBTBL,y ;of table value
        sta binary32
        lda binary32+1 ;Get next byte
        iny
        adc SUBTBL,y ;Add next byte of table
        sta binary32+1
        lda binary32+2 ;Next byte
        iny
        adc SUBTBL,y ;Add next byte of table
        sta binary32+2
        txa          ;Put dec count in acc
        jsr BCDREG   ;Put in BCD reg
        iny
        iny
        cpy #$20     ;End of table?
        bcc NXTDIG   ;No? go back with next dec weight
        lda binary32   ;Yes? put remainder in acc and put in BCD reg
BCDREG:
        asl a
        asl a
        asl a
        asl a
        ldx #$04
SHFT_L:
        asl a
        rol bcd32
        rol bcd32+1
        rol bcd32+2
        rol bcd32+3
        dex
        bne SHFT_L
        rts

SUBTBL:
        .byte $00,$e1,$f5,$05
        .byte $80,$96,$98,$00
        .byte $40,$42,$0f,$00
        .byte $a0,$86,$01,$00
        .byte $10,$27,$00,$00
        .byte $e8,$03,$00,$00
        .byte $64,$00,$00,$00
        .byte $0a,$00,$00,$00

multBy10Table:
        .byte   $00,$0A,$14,$1E,$28,$32,$3C,$46
        .byte   $50,$5A,$64,$6E,$78,$82,$8C,$96
        .byte   $A0,$AA,$B4,$BE

pointsTable:
        .word   $0000,$0028,$0064,$012C
        .word   $04B0
