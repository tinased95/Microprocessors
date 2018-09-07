;
; q9.asm
;
; Created: 19-Mar-17 2:52:36 PM
; Author : Tina sed
;


; Replace with your application code
start:
	ldi R21,0x00
	ldi R22,0x00
	
	ldi R23,0x05
	;for example if n=10
	ldi R25,0x10
	mov R10,R25
		
	;A register for x5
	ldi R20,0x05
	
adder_subroutine:
	;Sqaure the R20 and put the result in R1:R0 
	mul R20,R20
	add R21,R0
	adc R22,R1

	;increment 5
	inc R20
	inc R20
	inc R20
	inc R20
	inc R20

	;Check if we have reached the end of the loop
	cp R10,R20
	brge adder_subroutine

	ret
	