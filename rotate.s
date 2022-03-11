
#include <xc.inc>

global  Rotate_Servo
    
psect	udata_acs   ; reserve data space in access ram
pulse_width:	    ds 1    ; reserve one byte for duty cycle   
cnt_l:		    ds 1	; reserve 1 byte for variable cnt_l
cnt_h:		    ds 1	; reserve 1 byte for variable cnt_h
cnt_ms:		    ds 1	; reserve 1 byte for ms counter
    
psect	rotate_code, class=CODE	
    
Rotate_Servo:
	movwf	pulse_width
	
	bcf TRISC,0,A ; configure pin 0 of port C as output
	
	loop:
	;Make pin 0 on port c a 1
	bsf	PORTC,0,1
	
	;Delay for pulse width amount of time
	movf	pulse_width,W
	call	delay_ms    ;Delay for <pulse_width>ms
	
	
	;Make pin 0 a zero for the rest of the time
	bcf	PORTC,0
	
	
	;Delay for remaining amounf of period
	movlw	20  
	subfwb	pulse_width,0  ;subtract f (pulse width) from w (total period).Result stored back in W
	
	call delay_ms
	goto loop
	
	
		
delay_ms:		    ; delay given in ms in W
	movwf	cnt_ms, A
lp2:	movlw	250	    ; 1 ms delay
	call	delay_x4us	
	decfsz	cnt_ms, A
	bra	lp2
	return
    
delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	cnt_l, A	; now need to multiply by 16
	swapf   cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	cnt_l, W, A ; move low nibble to W
	movwf	cnt_h, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	cnt_l, F, A ; keep high nibble in LCD_cnt_l
	call	delay
	return

delay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lp1:	decf 	cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	lp1		; carry, then loop again
	return			; carry reset so return

end

