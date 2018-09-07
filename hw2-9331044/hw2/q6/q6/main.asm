;
; q6.asm
;
; Created: 06-Apr-17 8:43:01 PM
; Author : Tina sed
;


; q6.asm
;
; Created: 22-Mar-17 10:46:30 PM
; Author : Tina sed
;
.include "m16def.inc"

	.def temp    = r16 
	.def Counter = r17 
	

	.cseg
	.org 0 

; Replace with your application code

;r20 is for checking if the loop has reached 8 or not
ldi r20,10

ldi r19,0;r19 is a counter for write
;EEPROM addresses initialization
ldi r18,0x00
ldi r17,0x00
;EEPROM data register initialization
ldi r21,1


ldi r22,0x00
ldi r23,0x00
ldi r24,0;r24 is a counter for read

EEPROM_write:
; Wait for completion of previous write
;sbic EECR, EEWE
;rjmp EEPROM_write
; Set up address (r18:r17) in address register
out EEARH, r18
out EEARL, r17
; Write data (r19) to data register
out EEDR, r19
; Write logical one to EEMWE
sbi EECR, EEMWE
; Start eeprom write by setting EEWE
sbi EECR, EEWE
;next data
add r19,r21
;next address
add r17,r21

;Check the loop end point
cp R19,R20
brne EEPROM_WRITE



BCDTO7_seg:

  .db 0b0111111 , 0b0000110,  0b1011011,  0b1001111  ,0b1100110,  0b1101101,  0b1111101,  0b0000111 ,0b1111111,  0b1101111
  
  


Reset: 
  ser temp             ; DDRB as outputs 
  out DDRB, temp          

  ;Set bit pattern to display 0 initially 
  ldi temp,  0b00110000 ; 
  out PortB, temp ; 

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


  inc Counter
  cpi Counter, 10
  brne Start
  
 rjmp Reset_counter

	
EEPROM_read:
; Wait for completion of previous write
sbic EECR, EEWE
rjmp EEPROM_read
; Set up address (r18:r17) in address register
out EEARH, r23
out EEARL, r22
; Start eeprom read by writing EERE
sbi EECR, EERE
; Read data from data register
in r21, EEDR
lpm r21,Z
inc r24 ;increase counter
inc r22
cp r24,r20
brne EEPROM_READ