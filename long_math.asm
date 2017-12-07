Num1	.ds 4		// mul, div
Num2	.ds 4		// mul
Num3	.ds 8		// mul
Remainder	.ds 4	// div
Dividend	.ds 4   // div

mda 	.macro " "	; 32-bit move
	.if .not [:0 = 4]
		.error 'Wrong Number of Arguments!'
	.else
		.if :1 = '#' ; immediate mode
			lda #[:2 & $FF]
			sta :4
			lda #[[:2 >> 8 ] & $FF]
			sta :4+1
			lda #[[:2 >> 16] & $FF]
			sta :4+2
			lda #[[:2 >> 24] & $FF]
			sta :4+3
		.else
			ldy #3
?1
			lda :2,y
			sta :4,y
			dey
			bpl ?1
		.endif
	.endif
	.endm

// examples: 
// sbl a_dw b_dw (result in a_dw) 
// sbl a_dw b_dw c_dw (result in c_dw) 
sbl 	.macro 	" " ; 32-bit subtraction
	.if .not [:0 = 4 .or :0 = 6]
		.error 'Wrong Number of Arguments!'
	.else
		.if :0 = 4 ; two arguments
			.if :3 = '#' ; immediate mode
				lda :2
				sec
				sbc #[:4 & $FF]
				sta :2
				lda :2+1
				sbc #[[:4 >> 8 ] & $FF]
				sta :2+1
				lda :2+2
				sbc #[[:4 >> 16] & $FF]
				sta :2+2
				lda :2+3
				sbc #[:4 >> 24]
				sta :2+3
			.else
				ldy #0
				ldx #3
				sec
?1
				lda :2,y
				sbc :4,y
				sta :2,y
				iny
				dex
				bpl ?1
			.endif
		.else ; three arguments
			.if :3 = '#' ; immediate mode
				lda :2
				sec
				sbc #[:4 & $FF]
				sta :6
				lda :2+1
				sbc #[[:4 >> 8 ] & $FF]
				sta :6+1
				lda :2+2
				sbc #[[:4 >> 16] & $FF]
				sta :6+2
				lda :2+3
				sbc #[:4 >> 24]
				sta :6+3
			.else
				ldy #0
				ldx #3
				sec
?1
				lda :2,y
				sbc :4,y
				sta :6,y
				iny
				dex
				bpl ?1
			.endif		
		.endif
	.endif
	.endm

// examples: 
// adl a_dw b_dw (result in a_dw) a = a+b 
// adl a_dw b_dw c_dw (result in c_dw) c = a+b
	
adl 	.macro 	" " ; 32-bit addition
	.if .not [:0 = 4 .or :0 = 6]
		.error 'Wrong Number of Arguments!'
	.else
		.if :0 = 4 ; two arguments
			.if :3 = '#' ; immediate mode
				lda :2
				clc
				adc #[:4 & $FF]
				sta :2
				lda :2+1
				adc #[[:4 >> 8 ] & $FF]
				sta :2+1
				lda :2+2
				adc #[[:4 >> 16] & $FF]
				sta :2+2
				lda :2+3
				adc #[:4 >> 24]
				sta :2+3
			.else
				ldy #0
				ldx #3
				clc
?1
				lda :2,y
				adc :4,y
				sta :2,y
				iny
				dex
				bpl ?1
			.endif
		.else ; three arguments
			.if :3 = '#' ; immediate mode
				lda :2
				clc
				adc #[:4 & $FF]
				sta :6
				lda :2+1
				adc #[[:4 >> 8 ] & $FF]
				sta :6+1
				lda :2+2
				adc #[[:4 >> 16] & $FF]
				sta :6+2
				lda :2+3
				adc #[:4 >> 24]
				sta :6+3
			.else
				ldy #0
				ldx #3
				clc
?1
				lda :2,y
				adc :4,y
				sta :6,y
				iny
				dex
				bpl ?1
			.endif		
		.endif
	.endif
	.endm


// Num1 * Num2 = Num3	
.proc MulLong ; 32 bit multiplication: Num1 by Num2, result in Num3
	lda #0
	sta Num3+4
	sta Num3+5
	sta Num3+6
	sta Num3+7
	ldx #32 ; loop for each bit
multloop
	lsr Num1+3 ; divide multiplier by 2
	ror Num1+2
	ror Num1+1
	ror Num1
	bcc rotate
	lda Num3+4 ; get upper half of product and add multiplicand
	clc
	adc Num2
	sta Num3+4
	lda Num3+5
	adc Num2+1
	sta Num3+5
	lda Num3+6
	adc Num2+2
	sta Num3+6
	lda Num3+7
	adc Num2+3
rotate
	ror ; rotate partial product 
	sta Num3+7
	ror Num3+6
	ror Num3+5
	ror Num3+4
	ror Num3+3
	ror Num3+2
	ror Num3+1
	ror Num3
	dex
	bne multloop
	lda Num3
	ldx Num3+1
	rts
	.endp


// Dividend / Num1 = Dividend, Remainder
	jsr divlong	 
.proc divlong ; Num1 into Dividend, result Dividend, Remainder in Remainder
	lda #0	        ;preset Remainder to 0
	sta Remainder
	sta Remainder+1
	sta Remainder+2
	sta Remainder+3
	ldx #32	        ;repeat for each bit: ...
divloop1
	asl Dividend	;Dividend lb & hb*2, msb -> Carry
	rol Dividend+1	
	rol Dividend+2
	rol Dividend+3
	rol Remainder	;Remainder lb & hb * 2 + msb from carry
	rol Remainder+1
	rol Remainder+2
	rol Remainder+3
	lda Remainder
	sec
	sbc Num1	;substract divisor to see if it fits in
	pha	        ;lb result -> Y, for we may need it later
	lda Remainder+1
	sbc Num1+1
	pha
	lda Remainder+2
	sbc #0
	pha
	lda Remainder+3
	sbc #0
	bcc skip1	;if carry=0 then divisor didn't fit in yet

	sta Remainder+3
	pla
	sta Remainder+2	;else save substraction result as new Remainder,
	pla
	sta Remainder+1
	pla
	sta Remainder
	inc Dividend	;and INCrement result cause divisor fit in 1 times
	dex
	bne divloop1
	rts
skip1
	pla
	pla
	pla
	dex
	bne divloop1	
	rts
	.endp
	
