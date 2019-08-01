/*
 * LCD.inc
 *
 *        Date: 09.01.2016 15:58:11
 *        Author: Borko Rajkovic
 */ 

; LCD interface
;   make sure that the LCD RW pin is connected to GND
.equ    lcd_D7_port         = PORTC         ; lcd D7 connection
.equ    lcd_D7_bit          = PORTC5
.equ    lcd_D7_ddr          = DDRC

.equ    lcd_D6_port         = PORTC         ; lcd D6 connection
.equ    lcd_D6_bit          = PORTC4
.equ    lcd_D6_ddr          = DDRC

.equ    lcd_D5_port         = PORTC         ; lcd D5 connection
.equ    lcd_D5_bit          = PORTC3
.equ    lcd_D5_ddr          = DDRC

.equ    lcd_D4_port         = PORTC         ; lcd D4 connection
.equ    lcd_D4_bit          = PORTC2
.equ    lcd_D4_ddr          = DDRC

.equ    lcd_E_port          = PORTA         ; lcd Enable pin
.equ    lcd_E_bit           = PORTA7
.equ    lcd_E_ddr           = DDRA

.equ    lcd_RS_port         = PORTA         ; lcd Register Select pin
.equ    lcd_RS_bit          = PORTA6
.equ    lcd_RS_ddr          = DDRA

; LCD module information
.equ    lcd_LineOne         = 0x00          ; start of line 1
.equ    lcd_LineTwo         = 0x40          ; start of line 2

; LCD instructions
.equ    lcd_Clear           = 0b00000001    ; replace all characters with ASCII 'space'
.equ    lcd_Home            = 0b00000010    ; return cursor to first position on first line
.equ    lcd_EntryMode       = 0b00000110    ; shift cursor from left to right on read/write
.equ    lcd_DisplayOff      = 0b00001000    ; turn display off
.equ    lcd_DisplayOn       = 0b00001100    ; display on, cursor off, don't blink character
.equ    lcd_FunctionReset   = 0b00110000    ; reset the LCD
.equ    lcd_FunctionSet4bit = 0b00101000    ; 4-bit data, 2-line display, 5 x 7 font
.equ    lcd_SetCursor       = 0b10000000    ; set cursor position

program_author:
.db         "Borko Rajkovic",0,0

program_version:
.db         "Borko Rajkovic",0,0

; ****************************** Test Program Code **************************
lcd_test:

; initialize the LCD controller as determined by the equates (LCD instructions)
    call    lcd_init_4d                     ; initialize the LCD display for a 4-bit interface

; display the first line of information
    ldi     ZH, high(program_author)        ; point to the information that is to be displayed
    ldi     ZL, low(program_author)
    ldi     tmpReg, lcd_LineOne             ; point to where the information should be displayed
    call    lcd_write_string_4d

; display the second line of information
    ldi     ZH, high(program_version)       ; point to the information that is to be displayed
    ldi     ZL, low(program_version)
    ldi     tmpReg, lcd_LineTwo             ; point to where the information should be displayed
    call    lcd_write_string_4d

    ret
; ****************************** End of Test Program Code *******************

; ============================== 4-bit LCD Subroutines ======================
; Name:     lcd_init_4d
; Purpose:  initialize the LCD module for a 4-bit data interface
; Entry:    equates (LCD instructions) set up for the desired operation
; Exit:     no parameters
; Notes:    uses time delays instead of checking the busy flag

lcd_init_4d:

; configure the microprocessor pins for the data lines
    sbi     lcd_D7_ddr, lcd_D7_bit          ; 4 data lines - output
    sbi     lcd_D6_ddr, lcd_D6_bit
    sbi     lcd_D5_ddr, lcd_D5_bit
    sbi     lcd_D4_ddr, lcd_D4_bit

; configure the microprocessor pins for the control lines
    sbi     lcd_E_ddr,  lcd_E_bit           ; E line - output
    sbi     lcd_RS_ddr, lcd_RS_bit          ; RS line - output

; Power-up delay
    ldi     tmpReg, 100                     ; initial 40 mSec delay
    call    delayTx1mS

; IMPORTANT - At this point the LCD module is in the 8-bit mode and it is expecting to receive  
;    8 bits of data, one bit on each of its 8 data lines, each time the 'E' line is pulsed.
;
; Since the LCD module is wired for the 4-bit mode, only the upper four data lines are connected to 
;    the microprocessor and the lower four data lines are typically left open.  Therefore, when 
;    the 'E' line is pulsed, the LCD controller will read whatever data has been set up on the upper 
;    four data lines and the lower four data lines will be high (due to internal pull-up circuitry).
;
; Fortunately the 'FunctionReset' instruction does not care about what is on the lower four bits so  
;    this instruction can be sent on just the four available data lines and it will be interpreted 
;    properly by the LCD controller.  The 'lcd_write_4' subroutine will accomplish this if the 
;    control lines have previously been configured properly.

; Set up the RS and E lines for the 'lcd_write_4' subroutine.
    cbi     lcd_RS_port, lcd_RS_bit         ; select the Instruction Register (RS low)
    cbi     lcd_E_port, lcd_E_bit           ; make sure E is initially low

; Reset the LCD controller.
    ldi     tmpReg, lcd_FunctionReset       ; first part of reset sequence
    call    lcd_write_4
    ldi     tmpReg, 10                      ; 4.1 mS delay (min)
    call    delayTx1mS

    ldi     tmpReg, lcd_FunctionReset       ; second part of reset sequence
    call    lcd_write_4
    ldi     tmpReg, 200                     ; 100 uS delay (min)
    call    delayTx1uS

    ldi     tmpReg, lcd_FunctionReset       ; third part of reset sequence
    call    lcd_write_4
    ldi     tmpReg, 200                     ; this delay is omitted in the data sheet
    call    delayTx1uS

; Preliminary Function Set instruction - used only to set the 4-bit mode.
; The number of lines or the font cannot be set at this time since the controller is still in the 
;   8-bit mode, but the data transfer mode can be changed since this parameter is determined by one 
;   of the upper four bits of the instruction.
    ldi     tmpReg, lcd_FunctionSet4bit     ; set 4-bit mode
    call    lcd_write_4
    ldi     tmpReg, 80                      ; 40 uS delay (min)
    call    delayTx1uS

; Function Set instruction
    ldi     tmpReg, lcd_FunctionSet4bit     ; set mode, lines, and font
    call    lcd_write_instruction_4d
    ldi     tmpReg, 80                      ; 40 uS delay (min)
    call    delayTx1uS

; The next three instructions are specified in the data sheet as part of the initialization routine,
;   so it is a good idea (but probably not necessary) to do them just as specified and then redo them
;   later if the application requires a different configuration.

; Display On/Off Control instruction
    ldi     tmpReg, lcd_DisplayOff          ; turn display OFF
    call    lcd_write_instruction_4d
    ldi     tmpReg, 80                      ; 40 uS delay (min)
    call    delayTx1uS

; Clear Display instruction
    ldi     tmpReg, lcd_Clear               ; clear display RAM
    call    lcd_write_instruction_4d
    ldi     tmpReg, 4                       ; 1.64 mS delay (min)
    call    delayTx1mS

; Entry Mode Set instruction
    ldi     tmpReg, lcd_EntryMode           ; set desired shift characteristics
    call    lcd_write_instruction_4d
    ldi     tmpReg, 80                      ; 40 uS delay (min)
    call    delayTx1uS

; This is the end of the LCD controller initialization as specified in the data sheet, but the display
;   has been left in the OFF condition.  This is a good time to turn the display back ON.

; Display On/Off Control instruction
    ldi     tmpReg, lcd_DisplayOn           ; turn the display ON
    call    lcd_write_instruction_4d
    ldi     tmpReg, 80                      ; 40 uS delay (min)
    call    delayTx1uS
    ret


; ---------------------------------------------------------------------------
; Name:     lcd_write_string_4d
; Purpose:  display a string of characters on the LCD
; Entry:    ZH and ZL pointing to the start of the string
;           (tmpReg) contains the desired DDRAM address at which to start the display
; Exit:     no parameters
; Notes:    the string must end with a null (0)
;           uses time delays instead of checking the busy flag

lcd_write_string_4d:
; preserve registers
    push    ZH                              ; preserve pointer registers
    push    ZL

; fix up the pointers for use with the 'lpm' instruction
    lsl     ZL                              ; shift the pointer one bit left for the lpm instruction
    rol     ZH

; set up the initial DDRAM address
    ori     tmpReg, lcd_SetCursor           ; convert the plain address to a set cursor instruction
    call    lcd_write_instruction_4d        ; set up the first DDRAM address
    ldi     tmpReg, 80                      ; 40 uS delay (min)
    call    delayTx1uS

; write the string of characters
lcd_write_string_4d_01:
    lpm     tmpReg, Z+                      ; get a character
    cpi     tmpReg,  0                      ; check for end of string
    breq    lcd_write_string_4d_02          ; done

; arrive here if this is a valid character
    call    lcd_write_character_4d          ; display the character
    ldi     tmpReg, 80                      ; 40 uS delay (min)
    call    delayTx1uS
    rjmp    lcd_write_string_4d_01          ; not done, send another character

; arrive here when all characters in the message have been sent to the LCD module
lcd_write_string_4d_02:
    pop     ZL                              ; restore pointer registers
    pop     ZH
    ret


; ---------------------------------------------------------------------------
; Name:     lcd_write_4
; Purpose:  send a nibble (4-bits) of information to the LCD module
; Entry:    (tmpReg) contains a byte of data with the desired 4-bits in the upper nibble
;           (RS) is configured for the desired LCD register
;           (E) is low
;           (RW) is low
; Exit:     no parameters
; Notes:    use either time delays or the busy flag

lcd_write_4:
; set up D7
    sbi     lcd_D7_port, lcd_D7_bit         ; assume that the D7 data is '1'
    sbrs    tmpReg, 7                       ; check the actual data value
    cbi     lcd_D7_port, lcd_D7_bit         ; arrive here only if the data was actually '0'

; set up D6
    sbi     lcd_D6_port, lcd_D6_bit         ; repeat for each data bit
    sbrs    tmpReg, 6
    cbi     lcd_D6_port, lcd_D6_bit

; set up D5
    sbi     lcd_D5_port, lcd_D5_bit
    sbrs    tmpReg, 5
    cbi     lcd_D5_port, lcd_D5_bit

; set up D4
    sbi     lcd_D4_port, lcd_D4_bit
    sbrs    tmpReg, 4 
    cbi     lcd_D4_port, lcd_D4_bit

; write the data
                                            ; 'Address set-up time' (40 nS)
    sbi     lcd_E_port, lcd_E_bit           ; Enable pin high
    call    delay1uS                        ; implement 'Data set-up time' (80 nS) and 'Enable pulse width' (230 nS)
    cbi     lcd_E_port, lcd_E_bit           ; Enable pin low
    call    delay1uS                        ; implement 'Data hold time' (10 nS) and 'Enable cycle time' (500 nS)
    ret

; ---------------------------------------------------------------------------
; Name:     lcd_write_4
; Purpose:  send a nibble (4-bits) of information to the LCD module
; Entry:    (dataReg) contains a byte of data with the desired 4-bits in the upper nibble
;           (RS) is configured for the desired LCD register
;           (E) is low
;           (RW) is low
; Exit:     no parameters
; Notes:    use either time delays or the busy flag

lcd_write_4_dataReg:
; set up D7
    sbi     lcd_D7_port, lcd_D7_bit         ; assume that the D7 data is '1'
    sbrs    dataReg, 7                      ; check the actual data value
    cbi     lcd_D7_port, lcd_D7_bit         ; arrive here only if the data was actually '0'

; set up D6
    sbi     lcd_D6_port, lcd_D6_bit         ; repeat for each data bit
    sbrs    dataReg, 6
    cbi     lcd_D6_port, lcd_D6_bit

; set up D5
    sbi     lcd_D5_port, lcd_D5_bit
    sbrs    dataReg, 5
    cbi     lcd_D5_port, lcd_D5_bit

; set up D4
    sbi     lcd_D4_port, lcd_D4_bit
    sbrs    dataReg, 4 
    cbi     lcd_D4_port, lcd_D4_bit

; write the data
                                            ; 'Address set-up time' (40 nS)
    sbi     lcd_E_port, lcd_E_bit           ; Enable pin high
    call    delay1uS                        ; implement 'Data set-up time' (80 nS) and 'Enable pulse width' (230 nS)
    cbi     lcd_E_port, lcd_E_bit           ; Enable pin low
    call    delay1uS                        ; implement 'Data hold time' (10 nS) and 'Enable cycle time' (500 nS)
    ret
     
; ============================== End of 4-bit LCD Subroutines ===============



; ---------------------------------------------------------------------------
; Name:     lcd_write_instruction_4d
; Purpose:  send a byte of information to the LCD instruction register
; Entry:    (tmpReg) contains the data byte
; Exit:     no parameters
; Notes:    does not deal with RW (busy flag is not implemented)

lcd_write_instruction_4d:
    cbi     lcd_RS_port, lcd_RS_bit         ; select the Instruction Register (RS low)
    cbi     lcd_E_port, lcd_E_bit           ; make sure E is initially low
    call    lcd_write_4                     ; write the upper 4-bits of the instruction
    swap    tmpReg                          ; swap high and low nibbles
    call    lcd_write_4                     ; write the lower 4-bits of the instruction
    ret


; ---------------------------------------------------------------------------
; Name:     lcd_write_character_4d
; Purpose:  send a byte of information to the LCD data register
; Entry:    (tmpReg) contains the data byte
; Exit:     no parameters
; Notes:    does not deal with RW (busy flag is not implemented)

lcd_write_character_4d:

    sbi     lcd_RS_port, lcd_RS_bit         ; select the Data Register (RS high)
    cbi     lcd_E_port, lcd_E_bit           ; make sure E is initially low
    call    lcd_write_4                     ; write the upper 4-bits of the data
    swap    tmpReg                          ; swap high and low nibbles
    call    lcd_write_4                     ; write the lower 4-bits of the data
     
ret

; ---------------------------------------------------------------------------
; Name:     lcd_write_character_4d
; Purpose:  send a byte of information to the LCD data register
; Entry:    (tmpReg) contains the data byte
; Exit:     no parameters
; Notes:    does not deal with RW (busy flag is not implemented)

lcd_write_character_4d_dataReg:

    sbi     lcd_RS_port, lcd_RS_bit         ; select the Data Register (RS high)
    cbi     lcd_E_port, lcd_E_bit           ; make sure E is initially low
    call    lcd_write_4_dataReg             ; write the upper 4-bits of the data
    swap    dataReg                         ; swap high and low nibbles
    call    lcd_write_4_dataReg             ; write the lower 4-bits of the data
     
ret
