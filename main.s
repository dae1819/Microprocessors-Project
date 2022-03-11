#include <xc.inc>

extrn	ADC_Setup, ADC_Read		   ; external ADC subroutines
extrn	delay  

    
psect	udata_acs   ; reserve data space in access ram
pulse_width:	    ds 1    ; reserve one byte for duty cycle   
number_ms:	    ds 1
    
    
    
    
psect	code, abs

rst:	org	0x0000	; reset vector
	goto	setup

int_hi:	org	0x0008	; high vector, no low vector
	goto	timer_interupt
	
	
	
	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	
	movlw	0
	movwf	number_ms
	
	movlw	10 ;number of ms for the pulse
	movwf	pulse_width
	
	call	ADC_Setup	 
	goto	init

	
	
	
	; ******* Main programme ****************************************
init:	
	call	delay
	goto $
	
timer_interupt:
	btfss	TMR0IF		; check that this is timer0 interrupt
	retfie	f		; if not then return
	
	bcf	TMR0IF		; clear interrupt flag
	
	;check if number of ms = pulse width. If not increment count and go again
	;else return 
	movf	pulse_width,W
	cpfseq	number_ms
	incf	number_ms
	
	cpfseq	number_ms
	goto init
	
	
	
	goto next		; fast return from interrupt


next:
    




    
    
    
;
;
;start: 	lfsr	0, myArray	; Load FSR0 with address in RAM	
;	movlw	low highword(myTable)	; address of data in PM
;	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
;	movlw	high(myTable)	; address of data in PM
;	movwf	TBLPTRH, A		; load high byte to TBLPTRH
;	movlw	low(myTable)	; address of data in PM
;	movwf	TBLPTRL, A		; load low byte to TBLPTRL
;	movlw	myTable_l	; bytes to read
;	movwf 	counter, A		; our counter register
;loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
;	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
;	decfsz	counter, A		; count down to zero
;	bra	loop		; keep going until finished
;		
;	movlw	myTable_l	; output message to UART
;	lfsr	2, myArray
;	call	UART_Transmit_Message
;
;	movlw	myTable_l-1	; output message to LCD
;				; don't send the final carriage return to LCD
;	lfsr	2, myArray
;	call	LCD_Write_Message
;	
;measure_loop:
;	call	ADC_Read
;	movf	ADRESH, W, A
;	call	LCD_Write_Hex
;	movf	ADRESL, W, A
;	call	LCD_Write_Hex
;	goto	measure_loop		; goto current line in code
;	
;	; a delay subroutine if you need one, times around loop in delay_count
;delay:	decfsz	delay_count, A	; decrement until zero
;	bra	delay
;	return

	end	rst