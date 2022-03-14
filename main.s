#include <xc.inc>

extrn	DAC_Setup, DAC_Int_Hi
extrn	ADC_Setup, ADC_Read


    
psect	code, abs
rst:	org	0x0000	; reset vector
	goto	start

int_hi:	org	0x0008	; high vector, no low vector
	goto	DAC_Int_Hi
	
start:	
	
	
	
	call	ADC_Setup	; setup ADC
	
	
	movlw	15 ;period is 15 x 100us = 1.5ms
	call	DAC_Setup
	
	goto	$	; Sit in infinite loop

	

	
	
	

measure_loop:
	call	ADC_Read
	movf	ADRESH, W, A
	;;;;;
	
	movf	ADRESL, W, A
	;;;;;
	
	goto	measure_loop

	
	end	rst

	