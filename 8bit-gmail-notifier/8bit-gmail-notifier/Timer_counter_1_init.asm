/*
 * Timer_counter_1.inc
 *
 *		Date: 09.01.2016 15:58:11
 *		Author: Borko Rajkovic
 */ 

; Timer/Counter1 Init

TC1_INIT:
																						
	ldi		tmpReg, (1<<COM1B1)				; COM1B1:COM1B0 = 1 0
	out		TCCR1A, tmpReg					; Clear OC1B on compare match when up-counting
											; Set	OC1B on compare match when down-counting

	ldi		tmpReg, (1<<WGM13)|(1<<CS11)	; CS11 = prescaler 8; WGM13 = PWM, Phase and Frequency Correct
	out		TCCR1B, tmpReg					; TOP value is written to ICR1 16-bit register

	ldi		tmpReg, 0
	mov		notEndOfMusic, tmpReg			; reset notEndOfMusic
	mov		biggerDigit, tmpReg				; reset biggerDigit
	mov		LCDPauseCountH, tmpReg			; reset LCDPauseCountH
	mov		LCDPauseCountL, tmpReg			; reset LCDPauseCountL
	mov		LCDCurrentChar, tmpReg			; reset LCDCurrentChar
	mov		USARTinProgress, tmpReg			; reset USARTinProgress
	mov		sameDigitReg, tmpReg			; reset sameDigitReg

	ret
