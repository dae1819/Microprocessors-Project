
#include <xc.inc>

global  Rotate_Servo
    
psect	udata_acs   ; reserve data space in access ram
pulse_width:	    ds 1    ; reserve one byte for duty cycle   
    
    
psect	rotate_code, class=CODE	

Setup: ;initilise st the required angle in in the 
	movwf	pulse_width
	return
    
    
Rotate_Servo:
	call	Setup
	movlw 0x1387F; Set rotation period
	movwf PR2,A ; ?
	
	;movlw pulse_width ; set duty cycle value
	
	movf  pulse_width,W
	
	movwf CCPR1L,A ; ?
	movwf CCPR1H,A ; ?
	bcf TRISC,3,A ; configure CCP1 pin for output
	movlw 0x81; enable Timer3 in 16-bit mode and use
	movwf T3CON,A ; Timer2 as time base for PWM1 thru PWM5
	clrf TMR2,A ; force TMR2 to count from 0
	movlw 00000101B ; enable Timer2 and set its prescaler 
	movwf T2CON, A ; ?
	movlw 0x0C ; enable CCP1 PWM mode
	movwf CCP1CON,A ;

	

    
    
    
	
ADC_Read:
	bsf	GO	    ; Start conversion by setting GO bit in ADCON0
adc_loop:
	btfsc   GO	    ; check to see if finished
	bra	adc_loop
	return

end

