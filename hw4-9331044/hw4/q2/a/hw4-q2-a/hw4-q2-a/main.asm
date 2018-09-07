;
; hw4-q2-a.asm
;
; Created: 04-May-17 12:12:46 PM
; Author : Tina sed
;


; Replace with your application code
.org 0x00 jmp RST_ISR

RST_ISR:
	cli

	; set D6, D7 inputs
	ldi r16, 0xC0
	out PORTD, r16

	; set B3 output
	ldi r16, 0x08
	out DDRB, r16

	; set timer 0
	ldi r16, (1 << COM01) | (0 << COM00) | (1 << WGM01) | (1 << WGM00) | (1 << CS02) | (0 << CS01) | (1 << CS00)
	out TCCR0, r16
	ldi r16, 0xFF
	out OCR0, r16

	sei

WAIT_KEY:
	in r16, PIND

	ldi r17, 0x80
	and r17, r16
	cpi r17, 0
	breq SW1

	ldi r17, 0x40
	and r17, r16
	cpi r17, 0
	breq SW2

	jmp WAIT_KEY

	SW1:
		ldi r16, 0x5C
		out OCR0, r16
		jmp WAIT_KEY

	SW2:
		ldi r16, 0xFF
		out OCR0, r16
		jmp WAIT_KEY