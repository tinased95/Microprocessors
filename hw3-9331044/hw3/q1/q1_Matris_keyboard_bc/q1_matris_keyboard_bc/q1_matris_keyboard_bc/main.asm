;
; q1_matris_keyboard_bc.asm
;
; Created: 11-Apr-17 12:18:42 AM
; Author : Tina sed
;


; Replace with your application code

.org 0x00 jmp RESET
.org 0x02 jmp EXTERNAL_INT0

EXTERNAL_INT0:
	cli
	call keyFind
	call setSevenSeg
	sei
	ret

RESET:
	cli
	; init stack
	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16

	; init port B
	ldi r16, 0xFF
	out DDRB, r16
	ldi r16, 0x00
	out PORTB, r16

	; init port C
	ldi r16, 0xF0
	out DDRC, r16
	ldi r16, 0x0F
	out PORTC, r16

	; init int0
	;ldi r16, 0x04
	;out PORTD, r16
	ldi r16, (1 << ISC01) ; falling edge
	out MCUCR, r16
	ldi r16, (1 << INT0)
	out GICR, r16
	;ldi r16, 0x80 ; clear int1 flag
	;out GIFR, r16

	sei

start:
    inc r16
    rjmp start
	
keyFind:
	; get column
	in r17, PINC

	; change mode to get row
	ldi r16, 0x0F
	out DDRC, r16
	ldi r16, 0xF0
	out PORTC, r16
	
	; get row
	in r18, PINC
	
	; change mode to get next column
	ldi r16, 0xF0
	out DDRC, r16
	ldi r16, 0x0F
	out PORTC, r16

	; decode number
	cpi r17, 0b00001110
	brne not_col1

	cpi r18, 0b11100000
	brne not_0
	ldi r16, 0x00
	mov r0, r16
	ret
	not_0:
		cpi r18, 0b11010000
		brne not_4
		ldi r16, 0x04
		mov r0, r16
		ret
	not_4:
		cpi r18, 0b10110000
		brne not_8
		ldi r16, 0x08
		mov r0, r16
		ret
	not_8:
		ldi r16, 0x0C
		mov r0, r16
		ret

	not_col1:
		cpi r17, 0b00001101
		brne not_col2
		
		cpi r18, 0b11100000
		brne not_1
		ldi r16, 0x01
		mov r0, r16
		ret
		not_1:
			cpi r18, 0b11010000
			brne not_5
			ldi r16, 0x05
			mov r0, r16
			ret
		not_5:
			cpi r18, 0b10110000
			brne not_9
			ldi r16, 0x09
			mov r0, r16
			ret
		not_9:
			ldi r16, 0x0D
			mov r0, r16
			ret

	not_col2:
		cpi r17, 0b00001011
		brne not_col3
		
		cpi r18, 0b11100000
		brne not_2
		ldi r16, 0x02
		mov r0, r16
		ret
		not_2:
			cpi r18, 0b11010000
			brne not_6
			ldi r16, 0x06
			mov r0, r16
			ret
		not_6:
			cpi r18, 0b10110000
			brne not_A
			ldi r16, 0x0A
			mov r0, r16
			ret
		not_A:
			ldi r16, 0x0E
			mov r0, r16
			ret

	not_col3:
		cpi r18, 0b11100000
		brne not_3
		ldi r16, 0x03
		mov r0, r16
		ret
		not_3:
			cpi r18, 0b11010000
			brne not_7
			ldi r16, 0x07
			mov r0, r16
			ret
		not_7:
			cpi r18, 0b10110000
			brne not_B
			ldi r16, 0x0B
			mov r0, r16
			ret
		not_B:
			ldi r16, 0x0F
			mov r0, r16
			ret

setSevenSeg:
	mov r16, r0
	cpi r16, 0x00
	brne sssNot_0
	ldi r16, 0x3F
	out PORTB, r16
	ret

	sssNot_0:
		cpi r16, 0x01
		brne sssNot_1
		ldi r16, 0x06
		out PORTB, r16
		ret

	sssNot_1:
		cpi r16, 0x02
		brne sssNot_2
		ldi r16, 0x5B
		out PORTB, r16
		ret

	sssNot_2:
		cpi r16, 0x03
		brne sssNot_3
		ldi r16, 0x4F
		out PORTB, r16
		ret

	sssNot_3:
		cpi r16, 0x04
		brne sssNot_4
		ldi r16, 0x66
		out PORTB, r16
		ret

	sssNot_4:
		cpi r16, 0x05
		brne sssNot_5
		ldi r16, 0x6D
		out PORTB, r16
		ret

	sssNot_5:
		cpi r16, 0x06
		brne sssNot_6
		ldi r16, 0x7D
		out PORTB, r16
		ret

	sssNot_6:
		cpi r16, 0x07
		brne sssNot_7
		ldi r16, 0x07
		out PORTB, r16
		ret

	sssNot_7:
		cpi r16, 0x08
		brne sssNot_8
		ldi r16, 0x7F
		out PORTB, r16
		ret

	sssNot_8:
		cpi r16, 0x09
		brne sssNot_9
		ldi r16, 0x6F
		out PORTB, r16
		ret

	sssNot_9:
		cpi r16, 0x0A
		brne sssNot_A
		ldi r16, 0x77
		out PORTB, r16
		ret

	sssNot_A:
		cpi r16, 0x0B
		brne sssNot_B
		ldi r16, 0x7C
		out PORTB, r16
		ret

	sssNot_B:
		cpi r16, 0x0C
		brne sssNot_C
		ldi r16, 0x61
		out PORTB, r16
		ret

	sssNot_C:
		cpi r16, 0x0D
		brne sssNot_D
		ldi r16, 0x5E
		out PORTB, r16
		ret

	sssNot_D:
		cpi r16, 0x0E
		brne sssNot_E
		ldi r16, 0x79
		out PORTB, r16
		ret

	sssNot_E:
		ldi r16, 0x71
		out PORTB, r16
		ret