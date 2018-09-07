;
; q8.asm
;
; Created: 25-Mar-17 11:54:19 AM
; Author : Tina sed
;


start:
	ldi r18,0x00
	call SUBROUTINE
    rjmp start

SUBROUTINE:
	in R17,0x25
	swap R17

	CBR R17,8

	sbrc R17,5

	jmp STORE
	asr R17					

	mul R17,R18
	ldi	R16, low(RAMEND)
	out	SPL, R16
	ldi	R16, high(RAMEND)
	out	SPH, R16
 
	push R1
	push R0
STORE:
	STD Z+0x10,R17			
