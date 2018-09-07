;
; hw8.asm
;
; Created: 15-Jun-17 12:41:18 AM
; Author : Tina sed
;


; Replace with your application code

    rjmp start

	.org 0x00
   jmp reset
.org 0x04
   jmp int1_isr
int1_isr:
      cli
      ldi r16, 0x00
      out DDRA, r16
      ldi r16, (0 << PB0 | 0 << PB1 | 1 << PB2 | 1 << PB3 | 1<< PB4 | 1<<PB5 | 1<<PB6)
      out DDRB, r16
      ldi r16, (0 << PB2 | 0<< PB3 | 1 << PB4 | 1<<PB5 | 1<<PB6)
      out PORTB, r16 
      call input
      call output
      sei
      ret
reset:
      cli
      ldi r16, 0x00
      out DDRA, r16
      ldi r16, (0 << PB0 | 0 << PB1 | 1 << PB2 | 1 << PB3 | 1<< PB4 | 1<<PB5 | 1<<PB6)
      out DDRB, r16
      ldi r16, (0 << PB2 | 0<< PB3 | 1<< PB4 | 1<<PB5 | 1<<PB6)
      out PORTB, r16
      ldi r16, (1 << ISC11 | 0 << ISC10)
      out MCUCR, r16
      ldi r16, (1 << INT1)
      out GICR, r16
      sei
Start:
      ; Write your code here
Loop:
      rjmp  Loop


      
input:
      
      in r17, PINB
      out PORTC, r17
      ldi r16, 0x00
      out DDRA, r16
maybe1:
      cpi r17, 0x72;0111 0010
      brne maybe2
      sbi PORTB, 2
      cbi PORTB, 3
      nop
      in r18, PINA
      com r18
      cbi PORTB, 2
      cbi PORTB, 3
	  cbi PORTB, 4
      
maybe2:
      cpi r17, 0x71;0111 0001
      brne maybe3
      cbi PORTB,2
      sbi PORTB,3
      nop
      in r18, PINA
      com r18
      cbi PORTB, 2
      cbi PORTB, 3
	  cbi PORTB, 5
      
maybe3:
      cpi r17, 0x70;0111 0000
      brne end
      sbi PORTB, 2
      sbi PORTB, 3
      nop
      in r18, PINA
      com r18
      cbi PORTB, 2
      cbi PORTB, 3
	  cbi PORTB, 6
     
end:     
      ret
      
output:
ldi r16, 0xFF
      out DDRA, r16
      
check1: 
      cpi r18, 0x01
      brne check2
      ldi r16, 0x06
      out PORTA, r16
check2:
      cpi r18, 0x02
      brne check3
      ldi r16, 0x5B
      out PORTA, r16
check3:
      cpi r18, 0x04
      brne check4
      ldi r16, 0x4F
      out PORTA, r16
check4:
      cpi r18, 0x08
      brne check5
      ldi r16, 0x66
      out PORTA, r16
check5:
      cpi r18, 0x10
      brne check6
      ldi r16, 0x6D
      out PORTA, r16
check6:
      cpi r18, 0x20
      brne check7
      ldi r16, 0xFD
      out PORTA, r16
check7:
      cpi r18, 0x40
      brne check8
      ldi r16, 0x07
      out PORTA, r16
check8:
      cpi r18, 0x80
      brne end1
      ldi r16, 0xFF
      out PORTA, r16
end1:
      ret
