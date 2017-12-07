
	org $2000

Temp1 .ds 8
aNum1 .ds 4
aNum2 .ds 4 

start

	// move long
	mda #$4 aNum1
	mda #$16b62 aNum2
	
	// multiply long
	mda #$4 math.Num1
	mda #$16b62 math.Num2
	jsr math.MulLong
	mda math.Num3 Temp1	; save result
	
	jmp *
	
	icl 'long_math.asm'


	run start