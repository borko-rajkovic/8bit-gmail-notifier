/*
 * EEPROM_read_write.inc
 *
 *        Date: 09.01.2016 15:58:11
 *        Author: Borko Rajkovic
 */ 

; EEPROM_write

EEPROM_write:

    in         tmpSREG, SREG                        ; Save SREG
    cli                                             ; Turn off interrupts because of time-consuming write to EEPROM

    sbic       EECR,EEWE                            ; EECR - EEPROM Control Register; sbic - skip if bit is clear
                                                    ; EEWE - EEPROM Write Enable - if 1 than it's busy (it writes), if 0 than skip next line
    rjmp       EEPROM_write                         ; Go to start untill EEWE is set to 0 (finished previous write)

    push       tmpReg                               ; Write tmpReg on Stack (you must return it before routine ends)
    ldi        tmpReg, 0x00
    out        EEARH, tmpReg                        ; Set up part of address in EEARH (only first bit, because address uses 9 bits - 2^9 = 512)
    pop        tmpReg                               ; IMPORTANT! EEARH MUST be written, it's not enough to write only EEARL
    out        EEARL, tmpReg                        ; Set up rest of address (lower 8 of 9 bits); EEAR - EEPROM Address register - H - high; L - low

    out        EEDR,dataReg                         ; Write value of register dataReg to EEPROM Data Register - value we want to write

    sbi        EECR,EEMWE                           ; Write 1 in EEPROM Master Write Enable 
    sbi        EECR,EEWE                            ; Write 1 in EEPROM Write Enable to start write (only if EEMWE is set to 1)

    out        SREG, tmpSREG                        ; Turn back value of SREG-a
    sei                                             ; Turn on interrupts
    ret


; EEPROM_read

EEPROM_read:

    in         tmpSREG, SREG                        ; Save SREG
    cli                                             ; Turn off interrupts because of time-consuming read from EEPROM

    sbic       EECR,EEWE                            ; Wait for EEWE to be 0 (see EEPROM_write)
    rjmp       EEPROM_read

    push       tmpReg                               ; Write tmpReg on Stack (you must return it before routine ends)
    ldi        tmpReg, 0x00
    out        EEARH, tmpReg                        ; Set up address (see EEPROM_write)
    pop        tmpReg
    out        EEARL, tmpReg

    sbi        EECR,EERE                            ; Turn on EEPROM Read Enable bit
    in         dataReg,EEDR                         ; Write from EEPROM to dataReg

    out        SREG, tmpSREG                        ; Turn back value of SREG-a
    sei                                             ; Turn on interrupts
    ret
