#include <xc.inc>
	
global	Time_Setup, Time_Int
extrn	pan_flag,tilt_flag 

    
    
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ;num of 100us in period   
pulse_width:	ds 1  ;num of 100us in high pulse  
period:		ds 1    

   
    
psect	timer_code, class=CODE
   
Time_Int:	
	btfss	TMR0IF		; Check that this is timer0 interrupt
	retfie	f		; If not then return
	
	
	;Check counter value. If more than period reset to 0
	movf	period,W
	cpfslt	counter
	clrf	counter
	
	
	;If pan_flag is 1 then flip pan bit 
	movlw 0
	cpfseq	pan_flag
	call pan

	
	;If tilt_flag id 1 then flip tilt bit
	movlw 0
	cpfseq	tilt_flag
	call tilt
	
	
	;Increment counter
	incf	counter
	
	;Clear interrupt flag
	bcf	TMR0IF		
	
	;Reload preload value
	movlw	0x38
	movwf	TMR0
	
	
	retfie	f		; fast return from interrupt

Time_Setup:
	
	;Specify the time at which the square wave pulses are high
	movwf	pulse_width
	
	
	;Specify periodicity of pulse signal
	movlw	200
	movwf	period	;20ms = 200 x 100us
	
	;Intialise the counter
	movlw	0 
	movwf	counter
	
	
	clrf	TRISJ, A	; Set PORTD as all outputs
	

	;Dont want to count from 0 
	;i.e want interupt every 128us to be every 100us instead
;	;Corresponds to counting from 56 (0x38) to 2^8 instead of 0 to 2^8
	movlw	0x38
	movwf	TMR0
	
	
	movlw	11000010B	; Set timer0 to 8-bit, 1:8 prescaler
	movwf	T0CON, A	
	bsf	TMR0IE		; Enable timer0 interrupt
	bsf	GIE		; Enable all interrupts
	return

	
	
	
pan:
    
	movf	pulse_width,W
	cpfslt	counter
	bcf LATJ,0
	
	
	
	movf	pulse_width,W
	cpfsgt	counter
	bsf LATJ,0
	
	return
	
tilt:
    
	movf	pulse_width,W
	cpfslt	counter
	bcf LATJ,6
	
	movf	pulse_width,W
	cpfsgt	counter
	bsf LATJ,6
	
	return


	
	end

