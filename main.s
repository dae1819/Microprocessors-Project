#include <xc.inc>

global pan_flag,tilt_flag,ldr0,ldr1,ldr2,ldr3
extrn	DAC_Setup, DAC_Int_Hi
extrn	ADC_Setup0,ADC_Setup1,ADC_Setup2,ADC_Setup3,ADC_Setup_panel ,ADC_Read
extrn	UART_Setup, UART_Transmit_Message

psect	udata_acs   ; reserve data space in access ram
ldr0:   ds 1       
ldr1:	ds 1  
ldr2:	ds 1    
ldr3:	ds 1
panel_light:	ds 1
posn_pan:	ds 1
posn_tilt:	ds 1 
pulse_width_LR:	ds 1
pulse_width_TB:	ds 1    
    
;Stuff for the delays...    
LCD_cnt_l:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	ds 1   ; reserve 1 byte for ms counter
pan_flag:	ds 1
tilt_flag:	ds 1


    
psect	code, abs
rst:	org	0x0000	; reset vector
	goto	start

int_hi:	org	0x0008	; high vector, no low vector
	goto	DAC_Int_Hi

	
	
	
	
	
start:	
	call UART_Setup
    
	clrf pan_flag
	clrf tilt_flag
   
	
	movlw 1
	movwf pan_flag
	
	movlw	15
	movwf	posn_pan
	call DAC_Setup
	movlw 1000
	call LCD_delay_ms
	
	clrf pan_flag
	
	
	movlw 1
	movwf tilt_flag
	
	
	movlw	15 ;was 17
	movwf	posn_tilt
	call DAC_Setup
	movlw 1000
	call LCD_delay_ms
 
	clrf tilt_flag
	
	
	goto comparison_loop
	
	
comparison_loop:
	call ADC_Setup_panel
	call measure
	movwf	panel_light
	
	
	;UART transmission for panel;;;;;;;;;;;;;;;;
	movlw	1
	lfsr	2, panel_light
	call	UART_Transmit_Message
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
    
    
	clrf	ldr0
	clrf	ldr1
	clrf	ldr2
	clrf	ldr3
    
	
	call ADC_Setup0
	call measure
	movwf	ldr0
	
	
	;UART transmission for LDR0;;;;;;;;;;;;;;;;
	movlw	1
	lfsr	2, ldr0
	call	UART_Transmit_Message
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	call ADC_Setup1
	call measure
	movwf	ldr1
	
	;UART transmission for LDR1;;;;;;;;;;;;;;;;
	movlw	1
	lfsr	2, ldr1
	call	UART_Transmit_Message
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	
	
	
	
	
	;COMPARE LEFT/RIGHT
	
left_right:
    
;	movf  ldr0,w	; If light on LDR 0 and LDR 1 is different, set pan_flag as 1 
;	subwf ldr1,w
;	btfss STATUS,2
;	bsf pan_flag,0 
;    
;    
;	movf  ldr0,w
;	subwf ldr1,w
;	btfsc STATUS,2
;	call top_bottom   
;	
	
	;send posn_pan;;;;;;;;;;;;;;;;
	movlw	1
	lfsr	2, posn_pan
	call	UART_Transmit_Message
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
	
	movf	ldr0,W,A
	cpfslt	ldr1
	call	left_rotate
    
	
	movf	ldr0,W,A
	cpfsgt	ldr1
	call	right_rotate
    

	
	
	
top_bottom: ;COMPARE TOP/BOTTOM
	
	call ADC_Setup2
	call measure
	movwf	ldr2
	
	;UART transmission for LDR2;;;;;;;;;;;;;;;;
	movlw	1
	lfsr	2, ldr2
	call	UART_Transmit_Message
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	
	call ADC_Setup3
	call measure
	movwf	ldr3
	
	;UART transmission for LDR3;;;;;;;;;;;;;;;;
	movlw	1
	lfsr	2, ldr3
	call	UART_Transmit_Message
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
    
    
;	movf  ldr2,w	; If light on LDR 0 and LDR 1 is different, set tilt_flag as 1 
;	subwf ldr3,w
;	btfss STATUS,2
;	bsf tilt_flag,0 
;    
;	movf  ldr2,w
;	subwf ldr3,w
;	btfsc STATUS,2
;	goto comparison_loop   
	
	;send posn_tilt;;;;;;;;;;;;;;;;
	movlw	1
	lfsr	2, posn_tilt
	call	UART_Transmit_Message
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	
    
	movf	ldr2,W,A
	cpfslt	ldr3
	call	top_rotate
    
	movf	ldr2,W,A
	cpfsgt	ldr3
	call	bottom_rotate
	
	
	
;	movlw 1000
;	call LCD_delay_ms
;	movlw 1000
;	call LCD_delay_ms
;	movlw 1000
;	call LCD_delay_ms
;	movlw 1000
;	call LCD_delay_ms
;	movlw 1000
;	call LCD_delay_ms
;	movlw 1000
;	call LCD_delay_ms
;	movlw 1000
;	call LCD_delay_ms
	
	
	goto comparison_loop	

	

	
	
	
	
right_rotate:
	movlw 1
	movwf pan_flag
	
	;choose right as decrement
	
	decf posn_pan
	movf posn_pan,W,A
	
	call DAC_Setup
	
	movlw 1000
	call LCD_delay_ms
	
	clrf pan_flag
	
	return
	
left_rotate:
	movlw 1
	movwf pan_flag
    
    
	;choose left as increment
  
	incf posn_pan
	movf posn_pan,W,A
	
	call DAC_Setup
	
	movlw 1000
	call LCD_delay_ms
	
	clrf pan_flag
	
	return

top_rotate: ; im just testing if changing incf to decf will correct
	movlw 1
	movwf tilt_flag
    
	;choose top as increment
	incf posn_tilt
	movf posn_tilt,W,A
	
	call DAC_Setup
	
	movlw 1000
	call LCD_delay_ms
	
	clrf tilt_flag
	
	return
	
	
bottom_rotate: ; im just testing if changing decf to incf will correct
	movlw 1
	movwf tilt_flag
	
	;choose bottom as decrement
	decf posn_tilt
	movf posn_tilt,W,A
	
	
	call DAC_Setup
	
	movlw 1000
	call LCD_delay_ms
	
	clrf tilt_flag
	
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