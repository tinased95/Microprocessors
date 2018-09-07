;
; hw4-q1-b.asm
;
; Created: 02-May-17 9:25:43 AM
; Author : Tina sed
;


; Replace with your application code
.org 0x00 JMP RST_ISR

RST_ISR:
	cli

	; set B3 output
	ldi r16, (1 << PB3)
	out DDRB, r16
	out PORTB, r16

	; set timer 0
	ldi r16, 0xFF
	out OCR0, r16
	ldi r16, (1 << WGM01) | (0 << WGM00) | (0 << COM01) | (1 << COM00) | (1 << CS02) | (0 << CS01) | (1 << CS00)
	out TCCR0, r16

	sei

END: jmp END
