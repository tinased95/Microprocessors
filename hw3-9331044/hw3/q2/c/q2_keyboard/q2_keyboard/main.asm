;
; q2_keyboard.asm
;
; Created: 20-Apr-17 5:10:56 PM
; Author : Tina sed
;



; Replace with your application code
;*******************************************************************************
;	File:	m8_LCD_4bit.asm
;      Title:	ATmega8 driver for LCD in 4-bit mode (HD44780)
;  Assembler:	AVR assembler/AVR Studio
;    Version:	1.0
;    Created:	April 5th, 2004
;     Target:	ATmega8
; Christoph Redecker, http://www.avrbeginners.net
;*******************************************************************************

; Some notes on the hardware:
;ATmega8 (clock frequency doesn't matter, tested with 1 MHz to 8 MHz)
; PortA.1 -> LCD RS (register select)
; PortA.2 -> LCD RW (read/write)
; PortA.3 -> LCd E (Enable)
; PortA.4 ... PortA.7 -> LCD data.4 ... data.7
; the other LCd data lines can be left open or tied to ground.

;.include "c:\program files\atmel\avr studio\appnotes\m8def.inc"

.equ	LCD_RS	= 1
.equ	LCD_RW	= 2
.equ	LCD_E	= 3

.def	temp	= r16
.def	argument= r17		;argument for calling subroutines
.def	return	= r18		;return value from subroutines

.org 0x00 jmp RST_ISR
.org 0x02 jmp EXT_INT0_ISR

EXT_INT0_ISR:
	cli

	call keyFind
	call codeToChar

	call LCD_wait
	mov argument, r1
	call LCD_putchar

	sei
	ret

RST_ISR:
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


;LCD after power-up: ("*" means black bar)
;|****************|
;|		  |

	call	LCD_init
	
;LCD now:
;|&		  | (&: cursor, blinking)
;|		  |

end:
	jmp end
	
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

codeToChar:
	mov r16, r0
	cpi r16, 0x00
	brne sssNot_0
	ldi r16, '0'
		mov r1, r16
	ret

	sssNot_0:
		cpi r16, 0x01
		brne sssNot_1
		ldi r16, '1'
		mov r1, r16
		ret

	sssNot_1:
		cpi r16, 0x02
		brne sssNot_2
		ldi r16, '2'
		mov r1, r16
		ret

	sssNot_2:
		cpi r16, 0x03
		brne sssNot_3
		ldi r16, '3'
		mov r1, r16
		ret

	sssNot_3:
		cpi r16, 0x04
		brne sssNot_4
		ldi r16, '4'
		mov r1, r16
		ret

	sssNot_4:
		cpi r16, 0x05
		brne sssNot_5
		ldi r16, '5'
		mov r1, r16
		ret

	sssNot_5:
		cpi r16, 0x06
		brne sssNot_6
		ldi r16, '6'
		mov r1, r16
		ret

	sssNot_6:
		cpi r16, 0x07
		brne sssNot_7
		ldi r16, '7'
		mov r1, r16
		ret

	sssNot_7:
		cpi r16, 0x08
		brne sssNot_8
		ldi r16, '8'
		mov r1, r16
		ret

	sssNot_8:
		cpi r16, 0x09
		brne sssNot_9
		ldi r16, '9'
		mov r1, r16
		ret

	sssNot_9:
		cpi r16, 0x0A
		brne sssNot_A
		ldi r16, 'A'
		mov r1, r16
		ret

	sssNot_A:
		cpi r16, 0x0B
		brne sssNot_B
		ldi r16, 'B'
		mov r1, r16
		ret

	sssNot_B:
		cpi r16, 0x0C
		brne sssNot_C
		ldi r16, 'C'
		mov r1, r16
		ret

	sssNot_C:
		cpi r16, 0x0D
		brne sssNot_D
		ldi r16, 'D'
		mov r1, r16
		ret

	sssNot_D:
		cpi r16, 0x0E
		brne sssNot_E
		ldi r16, 'E'
		mov r1, r16
		ret

	sssNot_E:
		ldi r16, 'F'
		mov r1, r16
		ret

lcd_command8:	;used for init (we need some 8-bit commands to switch to 4-bit mode!)
	in	temp, DDRA		;we need to set the high nibble of DDRA while leaving
					;the other bits untouched. Using temp for that.
	sbr	temp, 0b11110000	;set high nibble in temp
	out	DDRA, temp		;write value to DDRA again
	in	temp, PortA		;then get the port value
	cbr	temp, 0b11110000	;and clear the data bits
	cbr	argument, 0b00001111	;then clear the low nibble of the argument
					;so that no control line bits are overwritten
	or	temp, argument		;then set the data bits (from the argument) in the
					;Port value
	out	PortA, temp		;and write the port value.
	sbi	PortA, LCD_E		;now strobe E
	nop
	nop
	nop
	cbi	PortA, LCD_E
	in	temp, DDRA		;get DDRA to make the data lines input again
	cbr	temp, 0b11110000	;clear data line direction bits
	out	DDRA, temp		;and write to DDRA
ret

lcd_putchar:
	push	argument		;save the argmuent (it's destroyed in between)
	in	temp, DDRA		;get data direction bits
	sbr	temp, 0b11110000	;set the data lines to output
	out	DDRA, temp		;write value to DDRA
	in	temp, PortA		;then get the data from PortA
	cbr	temp, 0b11111110	;clear ALL LCD lines (data and control!)
	cbr	argument, 0b00001111	;we have to write the high nibble of our argument first
					;so mask off the low nibble
	or	temp, argument		;now set the argument bits in the Port value
	out	PortA, temp		;and write the port value
	sbi	PortA, LCD_RS		;now take RS high for LCD char data register access
	sbi	PortA, LCD_E		;strobe Enable
	nop
	nop
	nop
	cbi	PortA, LCD_E
	pop	argument		;restore the argument, we need the low nibble now...
	cbr	temp, 0b11110000	;clear the data bits of our port value
	swap	argument		;we want to write the LOW nibble of the argument to
					;the LCD data lines, which are the HIGH port nibble!
	cbr	argument, 0b00001111	;clear unused bits in argument
	or	temp, argument		;and set the required argument bits in the port value
	out	PortA, temp		;write data to port
	sbi	PortA, LCD_RS		;again, set RS
	sbi	PortA, LCD_E		;strobe Enable
	nop
	nop
	nop
	cbi	PortA, LCD_E
	cbi	PortA, LCD_RS
	in	temp, DDRA
	cbr	temp, 0b11110000	;data lines are input again
	out	DDRA, temp
ret

lcd_command:	;same as LCD_putchar, but with RS low!
	push	argument
	in	temp, DDRA
	sbr	temp, 0b11110000
	out	DDRA, temp
	in	temp, PortA
	cbr	temp, 0b11111110
	cbr	argument, 0b00001111
	or	temp, argument

	out	PortA, temp
	sbi	PortA, LCD_E
	nop
	nop
	nop
	cbi	PortA, LCD_E
	pop	argument
	cbr	temp, 0b11110000
	swap	argument
	cbr	argument, 0b00001111
	or	temp, argument
	out	PortA, temp
	sbi	PortA, LCD_E
	nop
	nop
	nop
	cbi	PortA, LCD_E
	in	temp, DDRA
	cbr	temp, 0b11110000
	out	DDRA, temp
ret

LCD_getchar:
	in	temp, DDRA		;make sure the data lines are inputs
	andi	temp, 0b00001111	;so clear their DDR bits
	out	DDRA, temp
	sbi	PortA, LCD_RS		;we want to access the char data register, so RS high
	sbi	PortA, LCD_RW		;we also want to read from the LCD -> RW high
	sbi	PortA, LCD_E		;while E is high
	nop
	in	temp, PinA		;we need to fetch the HIGH nibble
	andi	temp, 0b11110000	;mask off the control line data
	mov	return, temp		;and copy the HIGH nibble to return
	cbi	PortA, LCD_E		;now take E low again
	nop				;wait a bit before strobing E again
	nop	
	sbi	PortA, LCD_E		;same as above, now we're reading the low nibble
	nop
	in	temp, PinA		;get the data
	andi	temp, 0b11110000	;and again mask off the control line bits
	swap	temp			;temp HIGH nibble contains data LOW nibble! so swap
	or	return, temp		;and combine with previously read high nibble
	cbi	PortA, LCD_E		;take all control lines low again
	cbi	PortA, LCD_RS
	cbi	PortA, LCD_RW
ret					;the character read from the LCD is now in return

LCD_getaddr:	;works just like LCD_getchar, but with RS low, return.7 is the busy flag
	in	temp, DDRA
	andi	temp, 0b00001111
	out	DDRA, temp
	cbi	PortA, LCD_RS
	sbi	PortA, LCD_RW
	sbi	PortA, LCD_E
	nop
	in	temp, PinA
	andi	temp, 0b11110000
	mov	return, temp
	cbi	PortA, LCD_E
	nop
	nop
	sbi	PortA, LCD_E
	nop
	in	temp, PinA
	andi	temp, 0b11110000
	swap	temp
	or	return, temp
	cbi	PortA, LCD_E
	cbi	PortA, LCD_RW
ret

LCD_wait:				;read address and busy flag until busy flag cleared
	rcall	LCD_getaddr
	andi	return, 0x80
	brne	LCD_wait
	ret


LCD_delay:
	clr	r2
	LCD_delay_outer:
	clr	r3
		LCD_delay_inner:
		dec	r3
		brne	LCD_delay_inner
	dec	r2
	brne	LCD_delay_outer
ret

LCD_init:
	
	ldi	temp, 0b00001110	;control lines are output, rest is input
	out	DDRA, temp
	
	rcall	LCD_delay		;first, we'll tell the LCD that we want to use it
	ldi	argument, 0x20		;in 4-bit mode.
	rcall	LCD_command8		;LCD is still in 8-BIT MODE while writing this command!!!

	rcall	LCD_wait
	ldi	argument, 0x28		;NOW: 2 lines, 5*7 font, 4-BIT MODE!
	rcall	LCD_command		;
	
	rcall	LCD_wait
	ldi	argument, 0x0F		;now proceed as usual: Display on, cursor on, blinking
	rcall	LCD_command
	
	rcall	LCD_wait
	ldi	argument, 0x01		;clear display, cursor -> home
	rcall	LCD_command
	
	rcall	LCD_wait
	ldi	argument, 0x06		;auto-inc cursor
	rcall	LCD_command
ret
