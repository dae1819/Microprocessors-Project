#include <xc.inc>
	
global	DAC_Setup, DAC_Int_Hi
    
psect	dac_code, class=CODE
	
DAC_Int_Hi:	
	btfss	TMR0IF		; check that this is timer0 interrupt
	retfie	f		; if not then return
	
	;check counter number, specify if 1 or 0 depending on count
	
	
	
	comf	LATJ, F, A	; bit flip PORTD
	bcf	TMR0IF		; clear interrupt flag
	
	movlw	0x60
	movwf	TMR0
	
	retfie	f		; fast return from interrupt

DAC_Setup:
	clrf	TRISJ, A	; Set PORTD as all outputs
	clrf	LATJ, A		; Clear PORTD outputs
	
	
	;Dont want to count from 0 i.e want 16us -> 10us
;	;Corresponds to counting from 96 (0x60) -> 2^8 instead of 0 -> 2^8
	movlw	0x60
	movwf	TMR0
	
	
	movlw	11001000B	; Set timer0 to 8-bit, Fosc/4 = Fclock
	movwf	T0CON, A	
	bsf	TMR0IE		; Enable timer0 interrupt
	bsf	GIE		; Enable all interrupts
	return
	
	end

