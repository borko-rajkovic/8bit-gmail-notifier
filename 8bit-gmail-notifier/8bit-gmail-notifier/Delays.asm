/*
 * Delays.inc
 *
 *        Date: 09.01.2016 15:58:11
 *        Author: Borko Rajkovic
 */ 

 ; ============================== Time Delay Subroutines =====================
.equ    fclk                = 8000000              ; system clock frequency (for delays)

; ---------------------------------------------------------------------------
; Name:     delayTx1mS
; Purpose:  provide a delay of (tmpReg) x 1 mS
; Entry:    (tmpReg) = delay data
; Exit:     no parameters
; Notes:    the 8-bit register provides for a delay of up to 255 mS
;           requires delay1mS

delayTx1mS:
    call    delay1mS                               ; delay for 1 mS
    dec     tmpReg                                 ; update the delay counter
    brne    delayTx1mS                             ; counter is not zero

; arrive here when delay counter is zero (total delay period is finished)
    ret

; ---------------------------------------------------------------------------
; Name:     delay1mS
; Purpose:  provide a delay of 1 mS
; Entry:    no parameters
; Exit:     no parameters
; Notes:    chews up fclk/1000 clock cycles (including the 'call')

delay1mS:
    push    YL                                     ; [2] preserve registers
    push    YH                                     ; [2]
    ldi     YL, low (((fclk/1000)-18)/4)           ; [1] delay counter
    ldi     YH, high(((fclk/1000)-18)/4)           ; [1]

delay1mS_01:
    sbiw    YH:YL, 1                               ; [2] update the the delay counter
    brne    delay1mS_01                            ; [2] delay counter is not zero

; arrive here when delay counter is zero
    pop     YH                                     ; [2] restore registers
    pop     YL                                     ; [2]
    ret                                            ; [4]

; ---------------------------------------------------------------------------
; Name:     delayTx1uS
; Purpose:  provide a delay of (tmpReg) x 1 uS with a 8 MHz clock frequency
; Entry:    (tmpReg) = delay data
; Exit:     no parameters
; Notes:    the 8-bit register provides for a delay of up to 255 uS
;           requires delay1uS

delayTx1uS:
    call    delay1uS                               ; delay for 1 uS
    dec     tmpReg                                 ; decrement the delay counter
    brne    delayTx1uS                             ; counter is not zero

; arrive here when delay counter is zero (total delay period is finished)
    ret

; ---------------------------------------------------------------------------
; Name:     delay1uS
; Purpose:  provide a delay of 1 uS
; Entry:    no parameters
; Exit:     no parameters
; Notes:    add push/pop instructions for 20 MHz clock frequency

delay1uS:
    ;push    tmpReg                                ; [2] these instructions do nothing except consume clock cycles
    ;pop     tmpReg                                ; [2]
    ;push    tmpReg                                ; [2]
    ;pop     tmpReg                                ; [2]
    ret                                            ; [4]

; ============================== End of Time Delay Subroutines ==============
