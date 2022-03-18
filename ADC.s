#include <xc.inc>

global  ADC_Setup0,ADC_Setup1,ADC_Setup2,ADC_Setup3, ADC_Read 


  
psect	adc_code, class=CODE
    
ADC_Setup0:
	bsf	TRISA, PORTA_RA0_POSN, A  ; pin RA0==AN0 input; CHANGE FOR OTHER PINS!
	movlb	0x0f
	bsf	ANSEL0	    ; set AN0 to analog
	movlb	0x00
	movlw   0x01	    ; select AN0 for measurement
	movwf   ADCON0, A   ; and turn ADC on
	movlw   0x30	    ; Select 4.096V positive reference
	movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
	movlw   0xF6	    ; Right justified output
	movwf   ADCON2, A   ; Fosc/64 clock and acquisition times
	return

ADC_Setup1:
	bsf	TRISA, PORTA_RA1_POSN, A  ; pin RA1==AN0 input; CHANGE FOR OTHER PINS!
	movlb	0x0f
	bsf	ANSEL1	    ; set AN0 to analog
	movlb	0x00
	
	;NEED TO CHANGE THIS...
	movlw   00000101B	    ; select AN0 for measurement
	movwf   ADCON0, A   ; and turn ADC on
	
	
	;THIS BIT CAN BE RE-USED
	movlw   0x30	    ; Select 4.096V positive reference
	movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
	movlw   0xF6	    ; Right justified output
	movwf   ADCON2, A   ; Fosc/64 clock and acquisition times
	return	

ADC_Setup2:
	bsf	TRISA, PORTA_RA2_POSN, A  ; pin RA2==AN0 input; CHANGE FOR OTHER PINS!
	movlb	0x0f
	bsf	ANSEL2	    ; set AN0 to analog
	movlb	0x00
	
	movlw   00001001B	    ; select AN0 for measurement
	movwf   ADCON0, A   ; and turn ADC on
	
	movlw   0x30	    ; Select 4.096V positive reference
	movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
	movlw   0xF6	    ; Right justified output
	movwf   ADCON2, A   ; Fosc/64 clock and acquisition times
	return

	
ADC_Setup3:
`	bsf	TRISA, PORTA_RA3_POSN, A  ; pin RA0==AN0 input; CHANGE FOR OTHER PINS!
	movlb	0x0f
	bsf	ANSEL3	    ; set AN0 to analog
	movlb	0x00
	movlw   00010001B	    ; select AN0 for measurement
	movwf   ADCON0, A   ; and turn ADC on
	movlw   0x30	    ; Select 4.096V positive reference
	movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
	movlw   0xF6	    ; Right justified output
	movwf   ADCON2, A   ; Fosc/64 clock and acquisition times
	return	
	
	
ADC_Read:
	bsf	GO	    ; Start conversion by setting GO bit in ADCON0
adc_loop:
	btfsc   GO	    ; check to see if finished
	bra	adc_loop
	return

end


