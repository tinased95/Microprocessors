;
; hw5q1.asm
;
; Created: 11-May-17 5:43:13 PM
; Author : Tina sed
;


; Replace with your application code
.org 0x00 jmp RST_ISR
.org 0x20 jmp AC_ISR

AC_ISR:
	cli

	in r16, ACSR
	andi r16, (1 << ACO)
	cpi r16, 0x00
	breq AC_ISR_TURN_ON

	call TURN_OFF
	jmp AC_ISR_END

	AC_ISR_TURN_ON:
		call TURN_ON

	AC_ISR_END:

	sei
	ret

RST_ISR:
	cli

	; set PD5 output
	ldi r16, (1 << PD5)
	out DDRD, r16

	; set mux out to ac
	ldi r16, (1 << ACME)
	out SFIOR, r16

	ldi r16, (1 << MUX0)
	out ADMUX, r16

	; enable ac
	ldi r16, (1 << ACIE) | (0 << ACIS1) | (0 << ACIS0)
	ori r16, (1 << ACI) ; set an interupt request to turn off or on LED for first value.
	out ACSR, r16

	sei

END: jmp END

TURN_ON:
	ldi r16, (1 << PD5)
	out PORTD, r16
	
	ret

TURN_OFF:
	in r16, PORTD
	ldi r17, (1 << PD5)
	com r17
	and r16, r17
	out PORTD, r16
	
	ret
