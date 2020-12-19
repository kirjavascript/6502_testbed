lines := $10
target := $20
numerator := $30
denominator := $40

paceRAM := $60 ; $12 bytes
binary32 := paceRAM+$0
bcd32 := paceRAM+$4
exp := paceRAM+$8
product24 := paceRAM+$9
factorA24 := paceRAM+$C
factorB24 := paceRAM+$F
binaryTemp := paceRAM+$C
sign := paceRAM+$F

marker := $EF


; target = p <= 100 ? 4000 : 4000 + ((lines - 110) / (230 - 110)) * 348

lineTargetThreshold := 110

main:
        ldy #0
        lda lines
        cmp #lineTargetThreshold
        bcc @baseTarget

        sbc #lineTargetThreshold ; denominator
        sta numerator


        jmp @done

@baseTarget:
        lda targetTable, y
        sta target
        lda targetTable+1, y
        sta target+1
@done:


        lda #$FF
        sta marker

targetTable:
        .byte $A0,$0F
        .byte $FC,$10

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
