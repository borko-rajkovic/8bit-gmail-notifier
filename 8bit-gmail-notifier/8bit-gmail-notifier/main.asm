 /******************************************************
 ****    8 bit Gmail Notifier           			****
 ****											    ****
 ****    Date: 02.01.2016 12:56:51        			****
 ****    Author: Borko Rajkovic                		****
 ****		Ver: 3.0 (7Segm. LED + Buzzer + LCD)    ****
 ****             (+ display EEPROM + T/C driven)	****
 ****										    	****
 ******************************************************/

 
; EEPROM Initial values

.ESEG									; Go to EEPROM
.ORG 0x00								; Write byte for digit zero (0) on Location 0x00
.DB "0                                                                 "

; Change memory type

.CSEG									; Back to flash memory
.ORG 0x00								; Start from address 0x00


; DEFINES

.def tmpReg				= R16			; Standard tmpReg register
.def displayCountReg	= R19			; Counts how much parts of digit has left to write
.def displayReg			= R15			; Register from which we are taking bit by bit to write on LCD display
.def dataReg			= R18			; We will use this register for taking data from EEPROM & UART and copy it to displayReg
.def tmpSREG			= R0			; This register will keep SREG when calling routine
.def tc0Count7seg		= R1			; Helper register which counts on interrupt from Counter 0
.def invalidChar		= R20			; If char is not valid it will be 1, otherwise 0
.def toneDuration		= R17
.def notEndOfMusic		= R2
.def volume				= R3
.def biggerDigit		= R4
.def LCDPauseCountH		= R6
.def LCDPauseCountL		= R5
.def LCDCurrentChar		= R7
.def USARTinProgress	= r8
.def sameDigitReg		= r9
.def current7seg		= r10

.equ pauseLCD = 6

; INTERRUPTS

jmp Start								; Reset interrupt
nop nop									; Since interrupt is addressed with 2 bytes, we should write 2 nop bytes for interrupt we do not use
nop nop
nop nop
nop nop
nop nop
nop nop									
nop nop									
nop nop
nop nop
nop nop
jmp USART_RX_COMPLETE					; USART Recieve completed interrupt; We cannot use pins PD0 and PD1 as GPIO because they are used for USART
nop nop
nop nop
nop nop
nop nop
nop nop
nop nop
nop nop
jmp TIMER0_COMP_INT						; Timer/Counter0 Compare Match (pin PB3 is used for this)
nop nop

; START

Start:
										; Setup stack pointer for method calls (so "ret" could work)
	ldi		tmpReg, low(RAMEND)
	out		SPL, tmpReg
	ldi		tmpReg, high(RAMEND)
	out		SPH, tmpReg

										; After restart initialization and reading from EEPROM, then display on LCD screen
	call	PORT_INIT
	call	TC0_INIT
	call	TC1_INIT
	call	USART_Init
	call	lcd_init_4d

	call	Refresh_data


; MAIN

main:
										; Main function is empty, we are using interrupts exclusively
	jmp		main



; ---------------------------------------------------------------------------
; Name:     Refresh_data
; Purpose:  Display new data from EEPROM. If number of emails is bigger then before, play music
; Entry:    sameDigitReg, biggerDigit
; Exit:     no parameters
; Notes:    If number of emails is same, exit routine
;			otherwise continue to Loading_characters

Refresh_data:

	; If same digit, then jump to end_LCD_display, otherwise go to continue_first_digit

	push	tmpReg
	mov		tmpReg, sameDigitReg
	cpi		tmpReg, 0x01
	pop		tmpReg
	brne	continue_first_digit

	rjmp	end_LCD_display

	; If digit is bigger than before, play music, otherwise just refresh LCD display

	continue_first_digit:

	mov		tmpReg, biggerDigit
	cpi		tmpReg, 0x01
	brne	skip_reset_music
	call	Reset_music

	skip_reset_music:

	; Set current char of LCD to 0, read from EEPROM to dataReg, format digit and display it

	ldi		tmpReg, 0x00
	mov		LCDCurrentChar, tmpReg
	call	EEPROM_read
	mov		current7seg, dataReg
	call	Format_digit
	call	Display_write_start

; ---------------------------------------------------------------------------
; Name:     Loading_characters
; Purpose:  Display new data from EEPROM
; Entry:    LCDCurrentChar
; Exit:     no parameters
; Notes:    Refresh_data does not have ret, so it will go through Loading_characters
;			this routine will be called from TIMER0_COMP_INT
;			Data is containing two sets of 32 characters delimited by pipe "|"
;				so in first set there will be 16 characters on first line and 16 on second line, which starts from position 17
;				for the second set, there are 32 characters prior to that set + delimiter (33) + 16 characters for first line (49)
;				so second line of second set starts at position 50

Loading_characters:

	; Check if USART is in progress and if it's not, go to continue_loading_characters

	push	tmpReg
	mov		tmpReg, USARTinProgress
	cpi		tmpReg, 0x01
	pop		tmpReg
	brne	continue_loading_characters
	ret

	continue_loading_characters:

	; increment LCDCurrentChar

	mov		tmpReg, LCDCurrentChar
	inc		tmpReg
	mov		LCDCurrentChar, tmpReg

	; check if first data set reached the end

	cpi		tmpReg, 33
	breq	finished_loading_characters

	; check if second data set reached the end

	cpi		tmpReg, 65
	breq	finished_loading_characters

	call EEPROM_read

	; set cursor to second line in case current position is 17 or 50

	cpi		tmpReg, 17
	breq	second_line_set_cursor
	cpi		tmpReg, 50
	breq	second_line_set_cursor

	; if not characters that starts second line, skip setting cursor to second line

	rjmp	skip_second_line_set_cursor

	second_line_set_cursor:

	push tmpReg

	; setting cursor to point to second line

	ldi		tmpReg, lcd_LineTwo			; set up the initial DDRAM address
	ori		tmpReg, lcd_SetCursor		; convert the plain address to a set cursor instruction
	call	lcd_write_instruction_4d	; set up the first DDRAM address
	ldi     tmpReg, 80					; 40 uS delay (min)
	call    delayTx1uS

	pop		tmpReg

	skip_second_line_set_cursor:

	; if position of char in data is 1 (first character of first set)
	; or 34 (first character of second set), we need to set cursor to first line

	cpi		tmpReg, 34
	breq	first_line_set_cursor
	cpi		tmpReg, 1
	breq	first_line_set_cursor

	; skip setting cursor to first line if not expected
	rjmp	skip_first_line_set_cursor

	first_line_set_cursor:

	; set cursor to first line

	push	tmpReg

	ldi		tmpReg, lcd_LineOne			; set up the initial DDRAM address
	ori     tmpReg, lcd_SetCursor		; convert the plain address to a set cursor instruction
	call	lcd_write_instruction_4d	; set up the first DDRAM address
	ldi     tmpReg, 80					; 40 uS delay (min)
	call    delayTx1uS

	pop		tmpReg

	skip_first_line_set_cursor:

	; write data from dataReg to LCD

	call	lcd_write_character_4d_dataReg

	push	tmpReg
	ldi     tmpReg, 80					; 40 uS delay (min)
	call    delayTx1uS
	pop		tmpReg

	; continue writing to LCD until finished_loading_characters is called

	rjmp	Loading_characters

	finished_loading_characters:

	; check if current position is 65 (end of second set)
	; if so, reset position to 0

	cpi		tmpReg, 65
	brne	end_LCD_display

	ldi		tmpReg, 0

	end_LCD_display:

ret

; PORT_INIT

PORT_INIT:

	ldi		tmpReg, 0b00011100			; tmpReg - set DDRD (exit ports) and PORTD (values on ports)
	out		DDRD, tmpReg				; (since it's port D we avoid TxD, RxD) PIND2=CLK; PIND3=Data; OC1B=Buzzer
	ldi		tmpReg, 0b00001100				
	out		PORTD, tmpReg

	ret


.include "Timer_counter_1_init.asm"
.include "Timer_counter_0_init.asm"
.include "EEPROM_read_write.asm"

; Timer/Counter0 Interrupt Service Routine

TIMER0_COMP_INT:

	; this interrupt will trigger on 1ms

	push	tmpReg

	; adding one to LCDPauseCountL and LCDPauseCountH (add 0 to LCDPauseCountH with carry from adding 1 to LCDPauseCountL)

	ldi		tmpReg, 0x01
	add		LCDPauseCountL, tmpReg
	ldi		tmpReg, 0x00
	adc		LCDPauseCountH, tmpReg

	; we are counting up to pauseLCD seconds
	; (actually, it will not be exact, for example 6 << 10 = 6144 ms)

	; if high and low part of our count is not same as desired, go to LCDisPause

	mov		tmpReg, LCDPauseCountH
	cpi		tmpReg, HIGH(pauseLCD << 10)
	brne	LCDisPause
	mov		tmpReg, LCDPauseCountL
	cpi		tmpReg, LOW(pauseLCD << 10)
	brne	LCDisPause

	; otherwise, reset our pause counter to zero and call Loading_characters to show other set on display
	; (if first set was shown, show second and vice-verse)

	ldi		tmpReg, 0x00
	mov		LCDPauseCountH, tmpReg
	mov		LCDPauseCountL, tmpReg

	pop		tmpReg

	call	Loading_characters

	push	tmpReg

	LCDisPause:

	pop		tmpReg

	; In all cases, call Play_music to check if tone or volume needs to be changed

	call	Play_music

	; Animate number of emails on 7-segment display
	;
	; Use tc0Count7seg to count to 100ms
	; Once it reach 100ms:
	;	- clear tc0Count7seg
	;	- check if there are still bits to move to shift register,
	;		if there are none, then exit;
	;		otherwise go to Display_write_continue

	push	tmpReg

	INC		tc0Count7seg				; Increment tc0Count7seg by one
	mov		tmpReg, tc0Count7seg		; Copy tc0Count7seg to tmpReg
	cpi		tmpReg, 100					; Compare tc0Count7seg with 100 (for 100ms, actually it will be more)
	pop		tmpReg						; IMPORTANT! If we do not pop here,
										; then in a stack it will be tmpReg and ret will return to address to which points tmpReg,
										; instead of the one that is written in a moment we entered routine

	BRNE	TIMER0_COMP_INT_EXIT		; If tc0Count7seg != 100 then exit; otherwise continue

	clr		tc0Count7seg				; Clear tc0Count7seg, so it can count from start

	cpi		displayCountReg, 0			; Compare displayCountReg to 0
	BRNE	Display_write_continue		; If displayCountReg != 0 then go to routine, otherwise exit

	TIMER0_COMP_INT_EXIT:
	reti								; reti will finish interrupt and set global interrupt to 1

; Start animation of number of emails on 7-segment display using shift register and shifting each bit every 100ms

Display_write_start:

	mov		displayReg, dataReg			; Copy from dataReg to displayReg
	ldi		displayCountReg, 8			; 8 bits are used, so we will count with displayCountReg from 8 to 0

Display_write_continue:

	push	tmpReg

	mov		tmpReg, displayReg			; Copy displayReg to tmpReg
	andi	tmpReg, 1					; Take just first bit
	lsl		tmpReg						; Move tmpReg 3 places left
	lsl		tmpReg
	lsl		tmpReg

	out		PORTD, tmpReg				; Set value of tmpReg to PORTD; PIND3 is set to data (for shift register) and PIND2 is set to 0 now
	sbi		PORTD, PIND2				; Set PIND2 (Clock for shift register)
	cbi		PORTD, PIND2				; Clear PIND2 and with that one puls is finished => 0 - 1 - 0

	pop		tmpReg

	lsr		displayReg					; Shift right, move on to next bit
	subi	displayCountReg, 1			; Decrement displayCountReg by 1
	reti


.include "USART_init_transmit.asm"


; USART Rx Complete Interrupt

USART_RX_COMPLETE:

	in		dataReg, UCSRA				; First, we need to read content of UCSRA (USART Control and Status Register A),
										;	because due to reading of UDR (USART Data Register) data are deleted from UCSRA
										; UCSRA contains control bits for Frame Error (FE), Data Over-Run (DOR) and Parity Error (PE)
										; After getting content of UCSRA we do logical AND with desired control bits

	andi	dataReg, (1<<FE)|(1<<DOR)|(1<<PE)

	push	tmpReg
	ldi		tmpReg, $1					; We will compare control bits with 1 (comparison is >= type)
	cp		dataReg, tmpReg
	pop		tmpReg
	
	BRGE	RX_interrupt_exception		; If any bit returned error, dataReg will be > 1 and it will go to RX_interrupt_exception

	rjmp	skip_RX_interrupt_exception
	
	RX_interrupt_exception:

	in		dataReg, UDR				; Put content of UDR (USART Data Register) to dataReg
										; Cleanup of UCSRA is required, otherwise next frame could not be received
	reti

	skip_RX_interrupt_exception:

	in		dataReg, UDR				; Put content of UDR (USART Data Register) to dataReg
	call	USART_Transmit				; After receiving, we are transmiting back message via UART for confirmation

	cli									; disable global interrupt



	; At this point we have our data from UART in dataReg
	;
	; We are expecting following data to be received via UART:
	;
	; 1) start of transmit				; value is 0x02
	; 2) number of emails				; single digit from 0 to 9, or dot "." if more than 9 new messages
	; 3) 32 chars for first data set	; LCD contains 2 lines X 16 chars, so first data set is 32 chars long
	; 4) delimiter (pipe "|")			; this is used to separate two data sets
	; 5) 32 chars for second data set	; second data set, also 32 chars long
	; 6) kraj i Refresh_data - 0x03		; TODO



	; Case 1)
	;
	; Compare if dataReg is 0x02; if not, skip this code
	; otherwise, set USARTinProgress to 1 and set LCDCurrentChar to 0

	cpi		dataReg, 0x02
	brne	not_start_of_transmit
	push	tmpReg
	ldi		tmpReg, 0x01
	mov		USARTinProgress, tmpReg
	ldi		tmpReg, 0x00
	mov		LCDCurrentChar, tmpReg
	pop		tmpReg
	reti

	not_start_of_transmit:

	; Case 6)
	;
	; Compare if dataReg is 0x03; if not, skip this code
	; otherwise, set USARTinProgress to 0 and call Refresh_data

	cpi		dataReg, 0x03
	brne	not_end_of_transmit
	push	tmpReg
	ldi		tmpReg, 0x00
	mov		USARTinProgress, tmpReg
	pop		tmpReg
	call	Refresh_data
	reti
	
	not_end_of_transmit:

	; Check if USARTinProgress
	; if not, skip to end

	push	tmpReg
	mov		tmpReg, USARTinProgress
	cpi		tmpReg, 0x01
	pop		tmpReg
	brne	not_USARTinProgress

	; Here we know that we want to process data from UART
	;
	; We will write dataReg to EEPROM and increment LCDCurrentChar

	push	tmpReg
	mov		tmpReg, LCDCurrentChar
	call	EEPROM_write				; Write dataReg to EEPROM on address given in tmpReg
	inc		LCDCurrentChar				; increment LCDCurrentChar
	pop		tmpReg

	; Case 2)
	;
	; First we will check if it's case two by checking is LCDCurrentChar == 1

	push	tmpReg
	mov		tmpReg, LCDCurrentChar
	cpi		tmpReg, 0x01
	pop		tmpReg
	brne	not_case_2					; Skip Case 2) if LCDCurrentChar != 1

	; Compare new number of emails with previous

	push	tmpReg
	ldi		tmpReg, 0x00
	mov		sameDigitReg, tmpReg		; Reset sameDigitReg to 0
	pop		tmpReg

	cp		dataReg, current7seg		; Compare old number of emails (current7seg register) with new one (dataReg)
	brne	number_of_emails_changed	; If they are same, we are marking sameDigitReg to 1 and finish this routine for case 2)

	number_of_emails_not_changed:

	push	tmpReg
	ldi		tmpReg, 0x01
	mov		sameDigitReg, tmpReg		; Set sameDigitReg to 1 to indicate that new and previous number of emails are same
	pop		tmpReg

	rjmp	number_of_emails_same


	number_of_emails_changed:

	; Reset bigger digit to 0

	push	tmpReg
	ldi		tmpReg, 0x00
	mov		biggerDigit, tmpReg			; Reset biggerDigit to 0
	pop		tmpReg

	; if old number of emails was "." then new number cannot be bigger

	push	tmpReg
	mov		tmpReg, current7seg
	cpi		tmpReg, '.'
	pop		tmpReg
	breq	USART_digit_not_bigger

	; compare old number of emails with new one if old one was != "."

	cp		current7seg, dataReg		; compare dataReg (new emails count) and current7seg (old emails count)
	brlo	email_count_got_bigger		; if current7seg is lower than dataReg, go to email_count_got_bigger
	cpi		dataReg, 0x2E				; compare dataReg with "."
	breq	email_count_got_bigger		; if dataReg == ".", then go to email_count_got_bigger
	rjmp	USART_digit_not_bigger		; at this point, we know that new email count is lower than old count
	
	email_count_got_bigger:

	push	tmpReg
	ldi		tmpReg, 0x01
	mov		biggerDigit, tmpReg			; Set biggerDigit to 1 to indicate that new email count is bigger than old one, so we can play music
	pop		tmpReg

	USART_digit_not_bigger:

	; Cases 3), 4), 5)
	not_case_2:

	cli									; Global interrupt disable

	not_USARTinProgress:
	number_of_emails_same:

	in dataReg, UDR						; Put content of UDR (USART Data Register) to dataReg
										; Cleanup of UCSRA is required, otherwise next frame could not be received

	sei									; Global interrupt enable
	ret


; Format digit

Format_digit:

digit_0:
	cpi		dataReg, 0x30				; With cpi we are comparing char and ASCII 0 (0x30)
	brne	digit_1						; If not equal, move on to next digit
	ldi		dataReg, 0b00011000			; If equal, format it for display
	ret

digit_1:
	cpi		dataReg, 0x31
	brne	digit_2
	ldi		dataReg, 0b11011110				
	ret

digit_2:
	cpi		dataReg, 0x32
	brne	digit_3
	ldi		dataReg, 0b00110100				
	ret

digit_3:
	cpi		dataReg, 0x33
	brne	digit_4
	ldi		dataReg, 0b10010100				
	ret

digit_4:
	cpi		dataReg, 0x34
	brne	digit_5
	ldi		dataReg, 0b11010010				
	ret

digit_5:
	cpi		dataReg, 0x35
	brne	digit_6
	ldi		dataReg, 0b10010001				
	ret

digit_6:
	cpi		dataReg, 0x36
	brne	digit_7
	ldi		dataReg, 0b00010001				
	ret

digit_7:
	cpi		dataReg, 0x37
	brne	digit_8
	ldi		dataReg, 0b11011100				
	ret

digit_8:
	cpi		dataReg, 0x38
	brne	digit_9
	ldi		dataReg, 0b00010000				
	ret

digit_9:
	cpi		dataReg, 0x39
	brne	digit_9_dot
	ldi		dataReg, 0b10010000				
	ret

digit_9_dot:
	ldi		dataReg, 0b10000000			; Represents "9." if more than 9
	ret


; ---------------------------------------------------------------------------
; Name:     Reset_music
; Purpose:  Reseting melody to start
; Entry:    no parameters
; Exit:     no parameters
; Notes:    Z register is set to point to address in memory where our melody is written
;			We reset toneDuration and notEndOfMusic registers to 1
;			After that, we are reading 4 times from memory because melodies are written in pairs,
;				out of which first pair is a volume (example: .DW 40, 0)
;				and other pairs are tone and duration of that particular note (example: .DW E7, 84)
;				as .DW is writing word, it means each part of pair is 2 bytes long, hence 4 bytes are filling out space of two pairs;
;				reading is done first by reading low, then high part of 16 bits

Reset_music:

	push	tmpReg

	ldi		ZH, HIGH(super_mario << 1)	; you can choose between super_mario and start_wars melodies
	ldi		ZL, LOW(super_mario << 1)	; or you can create your own melody in Melodies.inc
	; ldi	ZH, HIGH(starwars << 1)
	; ldi	ZL, LOW(starwars << 1)
	ldi		toneDuration, 0x01			; set toneDuration and notEndOfMusic to 1
	ldi		tmpReg, 0x01
	mov		notEndOfMusic, tmpReg

	lpm		tmpReg, Z+					; set up volume register
	mov		volume, tmpReg
	lpm		tmpReg, Z+ 
	lpm		tmpReg, Z+ 
	lpm		tmpReg, Z+ 

	pop		tmpReg

	ret

; ---------------------------------------------------------------------------
; Name:     Play_music
; Purpose:  plays melody with PWM using Timer/Counter1
; Entry:    toneDuration, notEndOfMusic, Z register
; Exit:     no parameters
; Notes:    We are reading 4 times from memory because melodies are written in pairs,
;				out of which first pair is a volume (example: .DW 40, 0)
;				and other pairs are tone and duration of that particular note (example: .DW E7, 84)
;				as .DW is writing word, it means each part of pair is 2 bytes long, hence 4 bytes are filling out space of two pairs;
;				for this we use registers r21, r22, r23, r24;
;				reading is done first by reading low, then high part of 16 bits;
;				first pair is consumed by Reset_music

Play_music:

	push	tmpReg

	dec		toneDuration
	ldi		tmpReg, 0x00
	cp		toneDuration, tmpReg		; only when toneDuration reaches 0 go on to change tone

	pop		tmpReg

	breq	loading
	ret

	loading:

	push	tmpReg
	mov		tmpReg, notEndOfMusic		; check if notEndOfMusic is != 0, then pick up notes and start playing
	cpi		tmpReg, 0x00				; it will be 1 after Reset_music
	pop		tmpReg
	brne	not_end_of_music

	ret

	not_end_of_music:					; if not end of music, load next pair from memory into registers r21, r22, r23, r24

	lpm		r21, Z+						; low 8 bits of tone
	lpm		r22, Z+						; high 8 bits of tone
	lpm		r23, Z+						; low 8 bits of delay
	lpm		r24, Z+						; high 8 bits of delay (always 0, we will not use it)

	mov		toneDuration, r23

	cpi		r22, 1						; if r22 same or higher than 1, go to play_tone
	brsh	play_tone 
	cpi		r21, 2						; if r21 same or higher than 2, go to play_tone
	brsh	play_tone					; in case it's 1, than it means we have pause; in case of 0 it's end of music

	silence:

	ldi		r25, 0x00
	ldi		r26, 0x00
	out		OCR1BH, r26					; provide zeros to OCR1BH and OCR1BL to set up volume to 0 and skip play_tone
	out		OCR1BL, r25					; OCR1 - Timer/Counter1 � Output Compare Register

	rjmp	skip_play_tone

	play_tone:

	mov		r25, volume
	ldi		r26, 0x00	
	out		OCR1BH, r26					; provide desired volume to OCR1BH and OCR1BL (only low part, high is always 0) for Timer/Counter1
	out		OCR1BL, r25					; OCR1 - Timer/Counter1 � Output Compare Register

	out		ICR1H, r22					; set up tone in ICR1H and ICR1L with r22 and r21, respectively
	out		ICR1L, r21					; ICR1 - Timer/Counter1 � Input Capture Register

	skip_play_tone:

	cpi		r21, 0x00					; if any of registers r21, r22, r23 are not empty, then skip setting end of music
	brne	skip_set_end_of_music
	cpi		r22, 0x00
	brne	skip_set_end_of_music
	cpi		r23, 0x00
	brne	skip_set_end_of_music
	cpi		r24, 0x00
	
	set_end_of_music:

	push	tmpReg
	ldi		tmpReg, 0x00
	mov		notEndOfMusic, tmpReg		; set notEndOfMusic to 0, basicaly this means the melody is over
	pop		tmpReg						; that is why all melodies must end with zeros (example: .DW 0, 0)

	skip_set_end_of_music:

	ret

.include "PWM_music_notes.asm" 

.include "LCD.asm"

.include "Delays.asm" 

.include "Melodies.asm"
