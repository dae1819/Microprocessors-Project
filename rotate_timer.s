
#include <xc.inc>

global  delay
    

    
    
psect	ms_delay_code, class=CODE	    
delay:
	
	
	;set port B as output
	movlw	0
	movwf	TRISB
	movlw	0
	movwf	PORTB
	
	;Congure prescaler, number of bits in timer
	movlw	00001000B ; 16 bits, no prescale
	movwf	T0CON
	
	;Configure preload 0XC180 for 1ms
	movlw	0xC1
	movwf	TMR0H
	movlw	0x80
	movwf	TMR0L
	
	;Set TMR0IE and GIE bits to 1 in INTCON (interupt control)
	bsf	INTCON,7 ;Set GIE (Global interupt)
	bsf	INTCON,5 ;Set TMR0IE (overflow interupt)
	
	;start timer to 1 in T0CON(TIMER0 COTROL)
	bsf	T0CON,7 ; Turn on timer
	
	
	return
	


	
	
end




