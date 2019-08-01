/*
 * Timer_counter_0.inc
 *
 *        Date: 09.01.2016 15:58:11
 *        Author: Borko Rajkovic
 */ 

; Timer/Counter0 Init

TC0_INIT:
                                                                                        
    ldi        tmpReg, (1<<WGM01)|(5<<CS00)        ; Setup existing clock prescaler to 1024 (CS02:00) and Waveform Generation Mode to WGM01 - CTC
    out        TCCR0, tmpReg                       ; (Clear Timer on Compare), so counter will reset to 0 on interrupt

    in         tmpReg, TIMSK                       ; Take existing TIMSK
    ori        tmpReg, (1<<OCIE0)                  ; Logical or with OCIE0
    out        TIMSK, tmpReg                       ; Turn on Output Compare Interrupt Enable

    ldi        tmpReg, 0x08                        ; We want to count 1ms
    out        OCR0, tmpReg                        ; 8MHz/1024(prescaler)=7812 ticks per second
                                                   ; 1ms = 7812/1000 = 7.8 ~ 8 ticks

    ldi        tmpReg, 0x00                        ; We reset counter manually (this is not critical, since it shouldn't count much up to here)
    out        TCNT0, tmpReg 

    ret
