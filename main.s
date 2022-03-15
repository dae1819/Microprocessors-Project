#include <xc.inc>

extrn	DAC_Setup, DAC_Int_Hi
extrn	ADC_Setup0,ADC_Setup1,ADC_Setup2,ADC_Setup3, ADC_Read

psect	udata_acs   ; reserve data space in access ram
ldr0:   ds 1       
ldr1:	ds 1  
ldr2:	ds 1    
ldr3:	ds 1
posn:	ds 1
  

    
psect	code, abs
rst:	org	0x0000	; reset vector
	goto	start

int_hi:	org	0x0008	; high vector, no low vector
	goto	DAC_Int_Hi
	
start:	
	
	movlw	15
	movwf	posn
	
	
	
	goto comparison_loop
	
	

right_rotate:
	;add to posn
	incf posn
	movf posn,W
	call DAC_Setup
	goto $
	return
	
	
left_rotate:
	;subtract from posn
	decf posn
	movf posn,W
	
	call DAC_Setup
	goto $
	return
	
measure:
	call	ADC_Read
	movf	ADRESH, W, A
	;Ignore 2 least significant bits
	;movf	ADRESL, W, A
	
	return
	
	

	
comparison_loop:
;	call ADC_Setup0
;	call measure
;	movwf	ldr0
;	
;	
;	call ADC_Setup1
;	call measure
;	movwf	ldr1
;	
;	
;	call ADC_Setup2
;	call measure
;	movwf	ldr2
;	
;	
;	call ADC_Setup3
;	call measure
;	movwf	ldr3
;	
;	
	
	;compare ldrs 0 and 1
	;movf	ldr0,W
	;cpfsgt	ldr1
	;goto left_rotate
	
	movlw 10
	movwf ldr0
	movlw 5
	movwf ldr1
	
	movf	ldr0,W
	cpfsgt	ldr1
	;goto left_rotate
	
	
	
	
	;goto comparison_loop
	
	end	rst