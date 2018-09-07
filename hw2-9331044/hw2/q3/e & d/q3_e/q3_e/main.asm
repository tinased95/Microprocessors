;
; q3_e.asm
;
; Created: 10-Apr-17 8:50:29 PM
; Author : Tina sed
;


; Replace with your application code
.org 0x00 jmp RST_ISR

RST_ISR:
	cli

	; set pd5 output
	ldi r16, (1 << pd5)
	out ddrd, r16

	; set pd3 and pd6 inputs
	ldi r16, (1 << pd3) | (1 << pd6)
	out portd, r16

	sei

START:
	in r16, pind
	andi r16, (1 << pd3)
	cpi r16, 0
	brne START
	
	; turn LED on
	in r16, portd
	ori r16, (1 << pd5)
	out portd, r16

	; enable wdt
	ldi r16, (1 << wde) | (1 << WDP0) | (1 << WDP1) | (1 << WDP2)
	out WDTCR, r16

WAIT_FOR_WDR:
	in r16, PinD
	andi r16, (1 << pd6)
	cpi r16, 0
	brne WAIT_FOR_WDR

	;wdr
	jmp WAIT_FOR_WDR
