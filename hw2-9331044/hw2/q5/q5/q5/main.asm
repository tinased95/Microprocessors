;
; q5.asm
;
; Created: 27-Mar-17 13:30:01 PM
; Author : Tina sed
;


.include "m16def.inc"

  .def temp    = r16 
  .def Counter = r17 
  

  .cseg
  .org 0 
  jmp Reset

BCDTO7_seg:

  .db 0b0111111 , 0b0000110,  0b1011011,  0b1001111  ,0b1100110,  0b1101101,  0b1111101,  0b0000111 ,0b1111111,  0b1101111
  
  


Reset: 
  ser temp             ; DDRB as outputs 
  out DDRB, temp        

  ldi temp, 0b11111110 ; DDRDs.0 as input 
  out DDRD, temp       

  ;Set bit pattern to display 0 initially 
  ldi temp,  0b00110000 ; 
  out PortB, temp ; 

  ;Turn on pull up resistors at PortD.0 
  ldi temp, 0b00000001 ; 
  out PortD, temp      ; 

Reset_counter:
  clr Counter          ; Initialize to 0 

  ldi Zl,low(BCDTO7_seg << 1) ;  cseg address to byte addressing
  ldi Zh,high(BCDTO7_seg << 1)

  

Start:
  lpm  temp,Z+    ;read a byte from 'BCDTO7_seg'
  out PORTB, temp

  ;delay.................................

  ldi  r18, 5       ;1 clock cycle
  ldi  r19, 25     ;1 clock cycle
  ldi  r20, 25     ;1 clock cycle
  L1: dec  r20      ;1 clock cycle
  brne L1           ;2 clock cycle
  dec  r19          ;1 clock cycle
  brne L1           ;2 clock cycle
  dec  r18          ;1 clock cycle
  brne L1           ;2 clock cycle
  nop               ;1 clock cycle
  ;delay.................................


loop_while_button_held:
  sbic PIND,0
  rjmp loop_while_button_held

  inc Counter
  cpi Counter, 10
  brne Start
  
  rjmp Reset_counter