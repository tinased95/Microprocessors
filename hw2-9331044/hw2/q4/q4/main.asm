;
; q4.asm
;
; Created: 22-Mar-17 10:46:30 PM
; Author : Tina sed
;


; Replace with your application code
start:
;r20 is for checking if the loop has reached 8 or not
ldi r20,10
;r19 is a counter
ldi r19,0
;EEPROM addresses initialization
ldi r18,0x00
ldi r17,0x00
;EEPROM data register initialization
;ldi r16,1
ldi r21,1


EEPROM_write:
; Wait for completion of previous write
;sbic EECR, EEWE
;rjmp EEPROM_write
; Set up address (r18:r17) in address register
out EEARH, r18
out EEARL, r17
; Write data (r16) to data register
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
;rjmp EEPROM_WRITE
;rjmp start
ret