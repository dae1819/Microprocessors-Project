#include <xc.inc>

extrn	DAC_Setup, DAC_Int_Hi
extrn	ADC_Setup, ADC_Read

psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable    
    
    
psect	code, abs
rst:	org	0x0000	; reset vector
	goto	start

int_hi:	org	0x0008	; high vector, no low vector
	goto	DAC_Int_Hi
	
start:	
	call	ADC_Setup	; setup ADC
	
	
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

	