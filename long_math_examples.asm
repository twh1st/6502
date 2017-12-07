
	org $2000
	
start

	mda #$4 Num1
	mda #$16b62 Num2
	
	jmp *
	
	icl 'long_math.asm'

	run start