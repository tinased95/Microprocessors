;
; q3.asm
;
; Created: 02-Apr-17 7:31:30 PM
; Author : Tina sed
;
start:
    ldi R16, (0 << PD3) 
    out DDRD,R16   

    ldi R17, (1 << PD5) 
    out DDRD,R17    

OFF_MODE:
    ldi R18,(0 << PD5)
    out PORTD,R18
    sbic PIND,3
    jmp OFF_MODE 

	ON_MODE:
    ldi R18,(1 << PD5)
    out PORTD,R18
    sbis PIND,3
    jmp ON_MODE    
rjmp start


