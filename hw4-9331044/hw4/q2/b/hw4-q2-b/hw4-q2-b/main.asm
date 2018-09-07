;
; hw4-q2-b.asm
;
; Created: 06-May-17 10:00:00 PM
; Author : Tina sed
;


; Replace with your application code
.org 0x00 jmp RST_ISR

RST_ISR:
	cli

	; set D6 and D7 input
	ldi r16, 0xC0
	out PORTD, r16

	; set B3 output
	ldi r16, 0x08
	out DDRB, r16

	; set timer 0
	ldi r16, 0xFF
	out OCR0, r16
	ldi r16, (0 << WGM01) | (1 << WGM00) | (1 << COM01) | (0 << COM00) | (1 << CS02) | (0 << CS01) | (0 << CS00)
	out TCCR0, r16

	sei

WAIT_KEY:
	in r16, PIND

	ldi r17, 0x80
	and r17, r16
	cpi r17, 0x00
	breq SET_HALF

	ldi r17, 0x40
	and r17, r16
	cpi r17, 0x00
	breq SET_FULL
	jmp WAIT_KEY

	SET_HALF:
		ldi r16, 0x66
		out OCR0, r16
		jmp WAIT_KEY

	SET_FULL:
		ldi r16, 0xFF
		out OCR0, r16
		jmp WAIT_KEY