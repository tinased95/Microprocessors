;
; q1_Matris_keyboard.asm
;
; Created: 11-Apr-17 12:07:15 AM
; Author : Tina sed
;


; Replace with your application code
.org 0x00 jmp RESET
.org 0x04 jmp EXTERNAL_INT1

EXTERNAL_INT1:
	cli
	ldi r17, (1 << PD5)
	in r16, PORTD
	eor r16, r17
	out PORTD, r16
	sei
	ret

RESET:
	cli
	; initializing port D
	ldi r16, (1 << PD5)
	out DDRD, r16
	ldi r16, (1 << PD3)
	out PORTD, r16
	; initializing external interrupt1
	ldi r16, (1 << INT1)
	out GICR, r16
	ldi r16, (1 << INT1)
	out GIFR, r16
	ldi r16, (0 << ISC11) | (0 << ISC10)
	out MCUCR, r16
	sei
LAST_LINE: jmp LAST_LINE