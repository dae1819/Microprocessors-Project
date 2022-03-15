#include <xc.inc>

extrn	DAC_Setup, DAC_Int_Hi
extrn	ADC_Setup0,ADC_Setup1,ADC_Setup2,ADC_Setup3, ADC_Read

psect	udata_acs   ; reserve data space in access ram
ldr0:   ds 1       
ldr1:	ds 1  
ldr2:	ds 1    
ldr3:	ds 1
posn:	ds 1
LCD_cnt_l:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	ds 1   ; reserve 1 byte for ms counter


    
psect	code, abs
rst:	org	0x0000	; reset vector
	goto	start

int_hi:	org	0x0008	; high vector, no low vector
	goto	DAC_Int_Hi

	
	
	
	
	
start:	
	
	movlw	15
	movwf	posn
	
	goto comparison_loop
	
	
comparison_loop:
	clrf	ldr0
	clrf	ldr1
	clrf	ldr2
	clrf	ldr3
    
	call ADC_Setup0
	call measure
	movwf	ldr0
	
	
	call ADC_Setup1
	call measure
	movwf	ldr1
	
	
	call ADC_Setup2
	call measure
	movwf	ldr2
	
	
	call ADC_Setup3
	call measure
	movwf	ldr3
	
    
    
    
;	movlw 5
;	movwf ldr0
;	movlw 10
;	movwf ldr1
	
	;ldr0 < ldr1 --> rotate to left 
	
	movlw 0
	movwf ldr0
	movlw 0
	movwf ldr1
	
	
	movf	ldr0,W,A
	cpfseq	ldr1
	call	left_rotate
    
    
    
	
	
	
	
	
	goto comparison_loop	

	

right_rotate:
	
 
    
	incf posn
	movf posn,W,A
	
	call DAC_Setup
	
	movlw 1000
	call LCD_delay_ms
	
	return
	
	
left_rotate:
	
	decf posn
	movf posn,W,A
	
	call DAC_Setup
	
	movlw 1000
	call LCD_delay_ms
	
	
	return
	
measure:
	call	ADC_Read
	movf	ADRESH, W, A
	;Ignore 2 least significant bits
	;movf	ADRESL, W, A
	
	return


	
	
	
	
	
	
	
	
	
; ** a few delay routines below here as LCD timing can be quite critical ****
LCD_delay_ms:		    ; delay given in ms in W
	movwf	LCD_cnt_ms, A
lcdlp2:	movlw	250	    ; 1 ms delay
	call	LCD_delay_x4us	
	decfsz	LCD_cnt_ms, A
	bra	lcdlp2
	return
    
LCD_delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	LCD_cnt_l, A	; now need to multiply by 16
	swapf   LCD_cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	LCD_cnt_l, W, A ; move low nibble to W
	movwf	LCD_cnt_h, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	LCD_cnt_l, F, A ; keep high nibble in LCD_cnt_l
	call	LCD_delay
	return

LCD_delay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lcdlp1:	decf 	LCD_cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	LCD_cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	lcdlp1		; carry, then loop again
	return			; carry reset so return	
	
	

	
	
	
end	rst