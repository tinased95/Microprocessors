;
; q3_g.asm
;
; Created: 04-Apr-17 8:17:21 PM
; Author : Tina sed
;
.org 0x00
jmp rst_isr

.org 0x04
jmp int1_isr

int1_isr:
	cli
	ldi r16, (1 << PD5)
	out PORTD, r16
	call delay
	sei
ret

rst_isr:
	///////
	cli
	ldi r16, (0 << PD3)
	out DDRD, r16
	ldi r16, (1 << PD3) //PD3 pull up
	out PORTD, r16

	inc r20
	ldi r16, (1 << INT1) //enable INT1
	out GICR, r16
	ldi r16, (1 << PD5) //setting PORT D pin 5 as OUTPUT
	out DDRD, r16
	cp r20,r21
	brne rst_isr
	sei

start:
	ldi r16, (0 << PD5) //PORTD5 is 0 (LED off) (
	out PORTD, r16
	jmp start


DELAY:  
LDI R19, 0x0a
ldi R20,0x00
d:

ldi r16, (1 << PD5) //PORTD5 is 1 (LED on) (
	out PORTD, r16 



	ldi r18, 0xFF
delay_loop_1:
	ldi r17, 0xFF
delay_loop_2:
	nop
	dec r17
	cpi r17, 0x00
	brne delay_loop_2
	dec r18
	cpi r18, 0x00
	brne delay_loop_1

	ldi r16, (0 << PD5) //PORTD5 is 0 (LED off) (
out PORTD, r16 

	ldi r18, 0xFF
delay_loop_3:
	ldi r17, 0xFF
delay_loop_4:
	nop
	dec r17
	cpi r17, 0x00
	brne delay_loop_4
	dec r18
	cpi r18, 0x00
	brne delay_loop_3

	
	INC r20
	cp R19,R20
	brne d
RET        ;RETURN TO PREVIOUS PC ADDRESS 
