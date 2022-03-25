#include <xc.inc>

global pan_flag,tilt_flag,ldr0,ldr1,ldr2,ldr3
extrn	Time_Setup, Time_Int
extrn	ADC_Setup0,ADC_Setup1,ADC_Setup2,ADC_Setup3,ADC_Setup_panel ,ADC_Read
extrn	UART_Setup, UART_Transmit_Message

    
    
psect	udata_acs   ; reserve data space in access ram

;ADC voltage of LDRs
ldr0:   ds 1       
ldr1:	ds 1   
ldr2:	ds 1  
ldr3:	ds 1  
    
panel_light:	ds 1 ;ADC solar panel voltage
    
posn_pan:	ds 1 ;Position of pan (left/right) servo
posn_tilt:	ds 1 ;Position of tilt (top/bottom) servo

;Counters for the delays...    
delay_cnt_l:	ds 1   
delay_cnt_h:	ds 1   
delay_cnt_ms:	ds 1   

;Stores whether or not a pan or tilt is occuring
pan_flag:	ds 1
tilt_flag:	ds 1


    
    
psect	code, abs
rst:	org	0x0000	; reset vector
	goto	start

int_hi:	org	0x0008	; high vector, no low vector
	goto	Time_Int

	
	
	
	
	
start:	
	call UART_Setup ;Setup UART
    
	clrf pan_flag	;No pan or tilt is expected yet...
	clrf tilt_flag
   
	
	movlw 1
	movwf pan_flag ;Flag for a pan
	
	movlw	15 ;Pan to (arbitrary) initial position of 1.5ms
	movwf	posn_pan
	call Time_Setup
	movlw 1000
	call delay_ms
	
	clrf pan_flag
	
	
	movlw 1
	movwf tilt_flag ;Flag for a tilt
	
	
	movlw	15 ;Tilt to (arbitrary) initial position of 1.5ms
	movwf	posn_tilt
	call Time_Setup
	movlw 1000
	call delay_ms
 
	clrf tilt_flag
	
	
	goto comparison_loop
	
	
comparison_loop:
	;Measure solar panel voltage w/ ADC
	call ADC_Setup_panel
	call measure
	movwf	panel_light
	;UART transmission for solar panel
	movlw	1
	lfsr	2, panel_light
	call	UART_Transmit_Message
	
	
	;Clear the LDR values
	clrf	ldr0
	clrf	ldr1
	clrf	ldr2
	clrf	ldr3
    
	
	;Measure voltage in LDR0 (left)
	call ADC_Setup0
	call measure
	movwf	ldr0
	;UART/serial transmission for LDR0
	movlw	1
	lfsr	2, ldr0
	call	UART_Transmit_Message
	
	
	;Measure voltage in LDR1 (right)
	call ADC_Setup1
	call measure
	movwf	ldr1
	;UART/serial transmission for LDR1
	movlw	1
	lfsr	2, ldr1
	call	UART_Transmit_Message
	
	
	
left_right: ;compare left/right LDRs for tilt motion 
 
	;send position of pan servo w/ UART/serial
	movlw	1
	lfsr	2, posn_pan
	call	UART_Transmit_Message
	
    
	;If ldr1 > ldr0 then rotate left
	movf	ldr0,W,A
	cpfslt	ldr1
	call	left_rotate
    
	;If ldr1 < ldr0 then rotate right
	movf	ldr0,W,A
	cpfsgt	ldr1
	call	right_rotate
    

	
	
	
top_bottom: ;compare top/bottom LDRs for tilt motion 
	
	;Measure voltage in LDR2 (top)
	call ADC_Setup2
	call measure
	movwf	ldr2
	;UART/serial transmission for LDR2
	movlw	1
	lfsr	2, ldr2
	call	UART_Transmit_Message
	
	
	
	;Measure voltage in LDR3 (bottom)
	call ADC_Setup3
	call measure
	movwf	ldr3
	;UART/serial transmission for LDR3
	movlw	1
	lfsr	2, ldr3
	call	UART_Transmit_Message
	
 
	
	;send posn_tilt via UART/serial
	movlw	1
	lfsr	2, posn_tilt
	call	UART_Transmit_Message

	
	
	
	;If ldr3 > ldr2 then rotate top
	movf	ldr2,W,A
	cpfslt	ldr3
	call	top_rotate
	;If ldr3 < ldr2 then rotate bottom
	movf	ldr2,W,A
	cpfsgt	ldr3
	call	bottom_rotate
	
	
	

	
	
	goto comparison_loop	;Loop back again

	


	
right_rotate:
	movlw 1
	movwf pan_flag
	
	;choose right as decrement
	decf posn_pan
	movf posn_pan,W,A
	
	call Time_Setup
	
	movlw 1000 ;Wait until enough periods have been sent before stopping
	call delay_ms
	
	clrf pan_flag
	
	return
	
left_rotate:
	movlw 1
	movwf pan_flag
    
    
	;choose left as increment
	incf posn_pan
	movf posn_pan,W,A
	
	call Time_Setup
	
	movlw 1000 ;Wait until enough periods have been sent before stopping
	call delay_ms
	
	clrf pan_flag
	
	return

top_rotate: 
	movlw 1
	movwf tilt_flag
    
	;choose top as increment
	incf posn_tilt
	movf posn_tilt,W,A
	
	call Time_Setup
	
	movlw 1000 ;Wait until enough periods have been sent before stopping
	call delay_ms
	
	clrf tilt_flag
	
	return
	
	
bottom_rotate: 
	movlw 1
	movwf tilt_flag
	
	;choose bottom as decrement
	decf posn_tilt
	movf posn_tilt,W,A
	
	
	call Time_Setup
	
	movlw 1000 ;Wait until enough periods have been sent before stopping
	call delay_ms
	
	clrf tilt_flag
	
	return

	
	
	
measure:
	call	ADC_Read
	movf	ADRESH, W, A ;Ignore 2 least significant bits
	return


	
	
	
	
	
	
	
	
	

delay_ms:		    ; delay given in ms in W
	movwf	delay_cnt_ms, A
lp2:	movlw	250	    ; 1 ms delay
	call	delay_x4us	
	decfsz	delay_cnt_ms, A
	bra	lp2
	return
    
delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	delay_cnt_l, A	; now need to multiply by 16
	swapf   delay_cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	delay_cnt_l, W, A ; move low nibble to W
	movwf	delay_cnt_h, A	; then to delay_cnt_h
	movlw	0xf0	    
	andwf	delay_cnt_l, F, A ; keep high nibble in delay_cnt_l
	call	delay
	return

delay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lp1:	decf 	delay_cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	delay_cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	lp1		; carry, then loop again
	return			; carry reset so return	
	
	

	
	
	
end	rst