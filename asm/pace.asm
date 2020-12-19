lines := $10
target := $20

paceRAM := $60 ; $12 bytes
binary32 := paceRAM+$0
bcd32 := paceRAM+$4
exp := paceRAM+$8
product24 := paceRAM+$9
factorA24 := paceRAM+$C
factorB24 := paceRAM+$F
binaryTemp := paceRAM+$C

dividend := paceRAM+$4
divisor := paceRAM+$7
remainder := paceRAM+$A
pztemp := paceRAM+$D

sign := paceRAM+$F


marker := $EF

; t = 110
; for(i=10;i<=230;i+=10) {
;     if (i <= t) {
;         p = 4000;
;     } else {
;         p = 4000 + (((i-t) / (230-t)) * 348 )
;     }
;     console.log(`${i} lines - ${0|p * i} points ${0|p}`)

; }


; target = p <= 100 ? 4000 : 4000 + ((lines - 110) / (230 - 110)) * 348

lineTargetThreshold := 110

main:
        ldy #0
        lda lines
        cmp #lineTargetThreshold+1
        bcc @baseTarget

        sbc #lineTargetThreshold

        ; store the value as if multiplied by 100
        sta dividend+2
        lda #0
        sta dividend
        sta dividend+1

        ; / (230 - 110)
        lda #120
        sta divisor
        lda #0
        sta divisor+1
        sta divisor+2

        jsr unsigned_div24

        ; result in dividend, copy as first factor

        lda dividend+1
        sta factorA24
        lda dividend+2
        sta factorA24+1
        lda #0
        sta factorA24+2

        ; pace target multiplier as other factor

        lda #$5C
        sta factorB24
        lda #$01
        sta factorB24+1
        lda #0
        sta factorB24+2

        jsr unsigned_mul24

        ; additional target data now in product24

        ; we take the high bytes, so round the low one

        lda product24+0
        cmp #$80
        bcc @noRounding

        clc
        lda product24+1
        adc #1
        sta product24+1

        lda product24+2
        adc #0 ; this load/add/load has an effect if the carry flag is set
        sta product24+2


@noRounding:

        ; add the base target value to the additional target amount

        clc
        lda product24+1
        adc #$A0
        sta product24
        lda product24+2
        adc #$0F
        sta product24+1
        lda #0
        adc #0
        sta product24+2


        lda product24+0
        sta target+0
        lda product24+1
        sta target+1
        lda product24+2
        sta target+2

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
        .byte $5C,$01

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

unsigned_div24:
        lda #0	        ;preset remainder to 0
	sta remainder
	sta remainder+1
	sta remainder+2
	ldx #24	        ;repeat for each bit: ...

@divloop:
        asl dividend	;dividend lb & hb*2, msb -> Carry
	rol dividend+1
	rol dividend+2
	rol remainder	;remainder lb & hb * 2 + msb from carry
	rol remainder+1
	rol remainder+2
	lda remainder
	sec
	sbc divisor	;substract divisor to see if it fits in
	tay	        ;lb result -> Y, for we may need it later
	lda remainder+1
	sbc divisor+1
	sta pztemp
	lda remainder+2
	sbc divisor+2
	bcc @skip	;if carry=0 then divisor didn't fit in yet

	sta remainder+2	;else save substraction result as new remainder,
	lda pztemp
	sta remainder+1
	sty remainder
	inc dividend 	;and INCrement result cause divisor fit in 1 times

@skip:
        dex
	bne @divloop
	rts
