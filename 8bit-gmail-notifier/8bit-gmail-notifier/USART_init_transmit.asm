/*
 * USART_init_transmit.inc
 *
 *        Date: 09.01.2016 15:58:11
 *        Author: Borko Rajkovic
 */ 

; USART_Init

USART_Init:

    cli                                        ; Turn off global interrupt until initialize of UART is complete
                                               ; (If we wanted to use for example 200 baud, we need to use UBRRH and just it's 3 bits
    ;ldi       tmpReg, UBRRH | 9 << 0          ; and in UBRRL the rest, that is up to 4095 => tmpReg=0CF)
    ;out       UBRRH, tmpReg
    ldi        tmpReg, 0xCF                    ; We will write just UBRRL, because value is 207 (< 256); for 8MHz = 2400 baud (0b00001100 for 38.4k baud)
    out        UBRRL, tmpReg
    ldi        tmpReg, (1<<RXCIE)|(3<<TXEN)    ; Turn on Rx Interrupt Enable and turn on Rx and Tx ((1<<RXEN)|(1<<TXEN))
    out        UCSRB,tmpReg
    ldi        tmpReg, 0b10111110              ; Setting up format of the frame: 8 data bits, 2 stop bits, parity = odd
                                               ; Same as: ldi tmpReg, (1<<URSEL)|(3<<UPM0)|(1<<USBS)|(3<<UCSZ0)
                                               ; URSEL must be 1 during initialization
                                               ; UPM0 and UPM1 are set to 1 for parity check
                                               ; USBS - how many stop bits; when it's value is 1, it means 2 stop bits
                                               ; UCSZ0 and UCSZ1 are set to 1 for 8 data bits in a frame
    out        UCSRC,tmpReg
    sei
    ret


; USART_Transmit

USART_Transmit:                                            

    sbis       UCSRA,UDRE                      ; Wait until UDRE (USART Data Register Empty) in UCSRA (USART Control and Status Register A) be 1
                                               ; (if 1, that means UDR - USART Data Register - and in particular for TxD, because RxD has it's own, is ready for Transmit)
    rjmp       USART_Transmit
    out        UDR,dataReg                     ; Put content of dataReg to UDR - USART Data Register which will activate transmit
    ret
