;
; hw5q2.asm
;
; Created: 12-May-17 7:05:59 PM
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
; PORTC.1 -> LCD RS (register select)
; PORTC.2 -> LCD RW (read/write)
; PORTC.3 -> LCd E (Enable)
; PORTC.4 ... PORTC.7 -> LCD data.4 ... data.7
; the 

.equ	LCD_RS	= 1
.equ	LCD_RW	= 2
.equ	LCD_E	= 3

.def	temp	= r16
.def	argument= r17		;argument for calling subroutines
.def	return	= r18		;return value from subroutines

.org 0x00 jmp RST_ISR
.org 0x1C jmp ADC_ISR

		CALC_TEMP:
			mov r20, r5 ;ADCH
			subi r20 ,0x28
			lsr r20
			ldi r21,0x02

			ldi r17, 0x00
			CHECK_MSD:
				cpi r20, 0x0a 
				brlo MSD_IS_DONE ;branch if lower ( if r16 < 10 )
				inc r17 
				add r20,r21
				subi r20, 0x0a 
				jmp CHECK_MSD

			MSD_IS_DONE:
			mov r7, r17 
			mov r6, r20 

			ldi r16, '0'
			add r6, r16
			add r7, r16

			call LCD_wait
			ldi argument, 0x01
			call LCD_command
	
			call LCD_wait
			mov argument, r7	;write MSB to the LCD char data RAM
			call LCD_putchar
	
			call LCD_wait
			mov argument, r6	;write LSB to the LCD char data RAM
			call LCD_putchar
		
		;------------delay	
			ldi r16, 0xFF
			LOOP1: 
				ldi r17, 0x8F 
				LOOP2:
					dec r17
					cpi r17, 0x00
					brne LOOP2
				dec r16
				cpi r16, 0x00
				brne LOOP1
		;------------delay	

	ADC_ISR_END:
		mov r16, r6
		mov r17, r7
		sei
		ret

ADC_ISR:
	cli
	mov r6, r16
	mov r7, r17

	in r16, ADMUX
	andi r16, (1 << MUX1 | 1 << MUX0) 
	cpi r16, (1 << MUX1 |  1 << MUX0) 
	breq MAX_MODE ;if mux1 = 1 and mux0=1 go to max_mode

	in r16, ADMUX
	andi r16, (1 << MUX1)
	cpi r16, (1 << MUX1) ;if mux0=1 go to min_mode
	breq MIN_MODE


	; Normal mode
	;in r16, ADCL
	;mov r4, r16 ;ADCL
	in r16, ADCH
	mov r5, r16 ;ADCH

	mov r16, r5 ;normal ADCH 
	mov r17, r1 ; ADCH in min_mode 
	cp r16, r17
	brge MORE_THAN_MIN ;if r16>=r17 branch to more_than_min
	LESS_THAN_MIN:
		ldi r16, (1 << PD2) | (0 << PD5)
		out PORTD, r16

		jmp CALC_TEMP
	MORE_THAN_MIN:
		mov r17, r3 ;ADCH in max_mode
		cp r16, r17
		brlo LESS_THAN_MAX
		MORE_THAN_MAX:
			ldi r16, (0 << PD2) | (0 << PD5)
			out PORTD, r16

			jmp CALC_TEMP
		LESS_THAN_MAX:
			ldi r16, (0 << PD2) | (1 << PD5)
			out PORTD, r16
			jmp CALC_TEMP
		
		MIN_MODE:
		; read min
		;in r16, ADCL
		;mov r0, r16
		in r16, ADCH
		mov r1, r16

		; change mode to get input (ADC1)
		in r16, ADMUX
		ldi r17, (1 << MUX1) ;ADC1
		com r17
		and r16, r17 ; reset mux1 
		ori r16, (1 << MUX0) ;set mux0 
		out ADMUX, r16

		jmp ADC_ISR_END
	MAX_MODE:
		; read max
		;in r16, ADCL
		;mov r2, r16
		in r16, ADCH
		mov r3, r16

		; change mode to get min (ADC3)
		in r16, ADMUX
		ldi r17, (1 << MUX0);ADC3
		com r17
		and r16, r17 ;reset mux0
		ori r16, (1 << MUX1);set mux1
		out ADMUX, r16

		jmp ADC_ISR_END

RST_ISR:
	cli
	ldi r16, '0'
	ldi	temp, low(RAMEND)
	out	SPL, temp
	ldi	temp, high(RAMEND)
	out	SPH, temp

	ldi r16, (1 << PD2) | (1 << PD5)
	out DDRD, r16
	
	; mode 0: IN: ADC1:  mux4..0: 00001
	; mode 1: MIN: ADC2: mux4..0: 00010
	; mode 2: MAX: ADC3: mux4..0: 00011 (Default)
	ldi r16, 0
	out SFIOR, r16
	ldi r16, ( 0 << REFS1) | (1 << REFS0)| (1 << ADLAR) | (0 << MUX4) | (0 << MUX3) | (0 << MUX2) | (1 << MUX1) | (1 << MUX0)
	out ADMUX, r16
	ldi r16, (1 << ADEN) | (1 << ADSC) |  (1 << ADIE)
	out ADCSRA, r16
	
	call LCD_init

	sei
	
;rcall	LCD_wait
;ldi	argument, '0'	;write '0' to the LCD char data RAM
;call	LCD_putchar

END:
	in r16, ADCSRA
	ori r16, (1 << ADEN) | (1 << ADSC)
	out ADCSRA, r16

	ldi r16, (0 << SM2) | (0 << SM1) | (1 << SM0) | (1 << SE)
	sleep
	jmp END

lcd_command8:	;used for init (we need some 8-bit commands to switch to 4-bit mode!)
	in	temp, DDRC		;we need to set the high nibble of DDRC while leaving
					;the other bits untouched. Using temp for that.
	sbr	temp, 0b11110000	;set high nibble in temp
	out	DDRC, temp		;write value to DDRC again
	in	temp, PORTC		;then get the port value
	cbr	temp, 0b11110000	;and clear the data bits
	cbr	argument, 0b00001111	;then clear the low nibble of the argument
					;so that no control line bits are overwritten
	or	temp, argument		;then set the data bits (from the argument) in the
					;Port value
	out	PORTC, temp		;and write the port value.
	sbi	PORTC, LCD_E		;now strobe E
	nop
	nop
	nop
	cbi	PORTC, LCD_E
	in	temp, DDRC		;get DDRC to make the data lines input again
	cbr	temp, 0b11110000	;clear data line direction bits
	out	DDRC, temp		;and write to DDRC
ret

lcd_putchar:
	push	argument		;save the argmuent (it's destroyed in between)
	in	temp, DDRC		;get data direction bits
	sbr	temp, 0b11110000	;set the data lines to output
	out	DDRC, temp		;write value to DDRC
	in	temp, PORTC		;then get the data from PORTC
	cbr	temp, 0b11111110	;clear ALL LCD lines (data and control!)
	cbr	argument, 0b00001111	;we have to write the high nibble of our argument first
					;so mask off the low nibble
	or	temp, argument		;now set the argument bits in the Port value
	out	PORTC, temp		;and write the port value
	sbi	PORTC, LCD_RS		;now take RS high for LCD char data register access
	sbi	PORTC, LCD_E		;strobe Enable
	nop
	nop
	nop
	cbi	PORTC, LCD_E
	pop	argument		;restore the argument, we need the low nibble now...
	cbr	temp, 0b11110000	;clear the data bits of our port value
	swap	argument		;we want to write the LOW nibble of the argument to
					;the LCD data lines, which are the HIGH port nibble!
	cbr	argument, 0b00001111	;clear unused bits in argument
	or	temp, argument		;and set the required argument bits in the port value
	out	PORTC, temp		;write data to port
	sbi	PORTC, LCD_RS		;again, set RS
	sbi	PORTC, LCD_E		;strobe Enable
	nop
	nop
	nop
	cbi	PORTC, LCD_E
	cbi	PORTC, LCD_RS
	in	temp, DDRC
	cbr	temp, 0b11110000	;data lines are input again
	out	DDRC, temp
ret

lcd_command:	;same as LCD_putchar, but with RS low!
	push	argument
	in	temp, DDRC
	sbr	temp, 0b11110000
	out	DDRC, temp
	in	temp, PORTC
	cbr	temp, 0b11111110
	cbr	argument, 0b00001111
	or	temp, argument

	out	PORTC, temp
	sbi	PORTC, LCD_E
	nop
	nop
	nop
	cbi	PORTC, LCD_E
	pop	argument
	cbr	temp, 0b11110000
	swap	argument
	cbr	argument, 0b00001111
	or	temp, argument
	out	PORTC, temp
	sbi	PORTC, LCD_E
	nop
	nop
	nop
	cbi	PORTC, LCD_E
	in	temp, DDRC
	cbr	temp, 0b11110000
	out	DDRC, temp
ret

LCD_getchar:
	in	temp, DDRC		;make sure the data lines are inputs
	andi	temp, 0b00001111	;so clear their DDR bits
	out	DDRC, temp
	sbi	PORTC, LCD_RS		;we want to access the char data register, so RS high
	sbi	PORTC, LCD_RW		;we also want to read from the LCD -> RW high
	sbi	PORTC, LCD_E		;while E is high
	nop
	in	temp, PINC		;we need to fetch the HIGH nibble
	andi	temp, 0b11110000	;mask off the control line data
	mov	return, temp		;and copy the HIGH nibble to return
	cbi	PORTC, LCD_E		;now take E low again
	nop				;wait a bit before strobing E again
	nop	
	sbi	PORTC, LCD_E		;same as above, now we're reading the low nibble
	nop
	in	temp, PINC		;get the data
	andi	temp, 0b11110000	;and again mask off the control line bits
	swap	temp			;temp HIGH nibble contains data LOW nibble! so swap
	or	return, temp		;and combine with previously read high nibble
	cbi	PORTC, LCD_E		;take all control lines low again
	cbi	PORTC, LCD_RS
	cbi	PORTC, LCD_RW
ret					;the character read from the LCD is now in return

LCD_getaddr:	;works just like LCD_getchar, but with RS low, return.7 is the busy flag
	in	temp, DDRC
	andi	temp, 0b00001111
	out	DDRC, temp
	cbi	PORTC, LCD_RS
	sbi	PORTC, LCD_RW
	sbi	PORTC, LCD_E
	nop
	in	temp, PINC
	andi	temp, 0b11110000
	mov	return, temp
	cbi	PORTC, LCD_E
	nop
	nop
	sbi	PORTC, LCD_E
	nop
	in	temp, PINC
	andi	temp, 0b11110000
	swap	temp
	or	return, temp
	cbi	PORTC, LCD_E
	cbi	PORTC, LCD_RW
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
	out	DDRC, temp
	
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