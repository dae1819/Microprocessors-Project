#include <xc.inc>
	
global	DAC_Setup, DAC_Int_Hi

psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ;num of 100us in period   
pulse_width:	ds 1  ;num of 100us in high pulse  
period:		ds 1    
h:		ds 1
l:		ds 1
   
    
    
psect	dac_code, class=CODE

    
DAC_Int_Hi:	
	btfss	TMR0IF		; check that this is timer0 interrupt
	retfie	f		; if not then return
	
	
	;check counter value. If more than period reset to 0
	movf	period,W
	cpfslt	counter
	clrf	counter
	
	
	
	;compare counter to pulse_width, specify if 1 or 0 
	; counter < pulse_width: LATJ -> 1
	; counter > pulse_width: LATJ -> 0

	
	movf	pulse_width,W
	cpfslt	counter
	movff	l,LATJ
	
	
	movf	pulse_width,W
	cpfsgt	counter
	movff	h,LATJ
	
	
	;FIX EQUAL TO COMPARISON ONCE WE KNOW HOW WE ARE COUNTING
	
	
	
	
	
	;Increment counter
	incf	counter
	
	; clear interrupt flag
	bcf	TMR0IF		
	
	;Reload preload value
	movlw	0x38
	movwf	TMR0
	
	
	retfie	f		; fast return from interrupt

DAC_Setup:
    
	movwf	pulse_width
    
	movlw	200
	movwf	period	;20ms = 200 x 100us
	
	movlw	0
	movwf	counter
	
	movlw	00000000B
	movwf	l
	
	movlw	11111111B
	movwf	h
	
    
	clrf	TRISJ, A	; Set PORTD as all outputs
	clrf	LATJ, A		; Clear PORTD outputs
	
	
	;Dont want to count from 0 i.e want 128us -> 100us
;	;Corresponds to counting from 56 (0x38) -> 2^8 instead of 0 -> 2^8
	movlw	0x38
	movwf	TMR0
	
	
	movlw	11000010B	; Set timer0 to 8-bit, 1:8 prescaler
	movwf	T0CON, A	
	bsf	TMR0IE		; Enable timer0 interrupt
	bsf	GIE		; Enable all interrupts
	return

	end

