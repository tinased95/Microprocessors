;
; hw4q1a.asm
;
; Created: 01-May-17 10:27:47 PM
; Author : Tina sed
;


; Replace with your application code
.org 0x00 jmp RST_ISR
.org 0x12 jmp TMR0_OVF_ISR

TMR0_OVF_ISR:
	cli

	dec r18
	cpi r18, 0x00
	brne TMR0_OVF_ISR_END

	ldi r18, 0x04

	ldi r16, 0x01
	eor r17, r16
	breq OFF

	call TURN_ON
	sei
	ret

	OFF:
	call TURN_OFF
	TMR0_OVF_ISR_END:
	sei
	ret

RST_ISR:
	cli

	ldi r16, 0x30 ;D4 and D5 output
	out DDRD, r16
	out PORTD, r16

	; set timer0
	ldi r17, 0x01 ; LED status
	ldi r18, 0x04 ; counter
	ldi r16, (1 << CS02) | (1 << CS00)
	out TCCR0, r16

	ldi r16, (1 << TOIE0)
	out TIMSK, r16

	sei

END: jmp END

TURN_ON:
	in r16, PORTD
	ori r16, 0x30
	out PORTD, r16
	ret

TURN_OFF:
	in r16, PORTD
	andi r16, 0xCF
	out PORTD, r16
	ret