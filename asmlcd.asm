.ifndef _ASM_LCD_ASM_
.define _ASM_LCD_ASM_

.include "m328pdef.inc"

; Inputs: r16: value to output
; Clobbers: r16, and r20-r22 from delays
write_data_bits:
    andi r16, 0x0F                  ; Set just the bits we want
    out PORTB, r16                  ; Write back out to LCD data
    rcall delay_1us                 ; delay 1us
    sbi PORTD, 4                    ; Set enable
    rcall delay_1us                 ; delay 1us
    cbi PORTD, 4                    ; Clear enable
    rcall delay_50us                ; 50us delay
    ret

; inputs: r16: whole byte to send
; Clobbers: r16-17, and r20-22 from delays
LcdWriteByte:
write_byte:
    mov r17, r16                    ; Copy the data to r17
    swap r16                        ; Swap nibbles, to write high nibble first
    rcall write_data_bits           ; Write out the low nibble of r16
    mov r16, r17                    ; Copy r17 back into r16
    rcall write_data_bits           ; Write out the low nibble second
    rcall delay_1us                 ; Delay 1us
    ret

; No inputs
; Clobbers: r16-18, r20-22
LcdInit:
    ; Configure pins as outputs and write them to all 0
    in r16, DDRB                    ; Read DDRB into r16
    ori r16, 0x0F                   ; Set the low 4 bits as outputs
    out DDRB, r16                   ; Write back to DDRB
    in r16, DDRD                    ; Read DDRD
    ori r16, 0x1C                   ; Set as outputs rw, rs, and enable
    out DDRD, r16                   ; Write back to DDRD
    ldi r16, 0x00                   ; Clear r16
    out PORTB, r16                  ; Write out to PORTB - all off
    out PORTD, r16                  ; And all of PORTD

    ldi r20, 8                      ; r16 is loop count, 4 x 15 = 60ms
    rcall delay_15ms                ; Delay 60ms - wait for display to boot

    ; Clear LCD control bits
    in r16, PORTD                   ; Read value of PORTD into r16
    andi r16, 0xE3                  ; Clear control bits
    out PORTD, r16                  ; Write r16 back to PORTD

    ; Write out 0x03 three times to set the display to 8 bit mode
    ldi r18, 0x03                   ; Loop variable, write 0x03 3 times
    ldi r16, 0x03                   ; Value to write - set LCD 8 bit mode
init_loop:
    rcall write_data_bits           ; Write out data bits
    dec r18                         ; Decrement r18
    brne init_loop                  ; If 0 < r18, jump back up to loop

    ldi r16, 0x02                   ; Load 0x02 as the value to send
    rcall write_data_bits           ; Write out value - 4 bit LCD mode
    ldi r16, 0x28                   ; Function set
    rcall write_byte
    ldi r16, 0x0C                   ; Display on
    rcall write_byte
    ldi r16, 0x01                   ; Clear display
    rcall write_byte
    ldi r20, 2                      ; 2 x 15ms = 30ms
    rcall delay_15ms                ; Delay for 30ms
    ldi r16, 0x06                   ; Entry mode set
    rcall write_byte

    ret

; inputs: X (r27H R26L) - pointer to null terminated string in RAM
; Clobbers: r16-17, and r20-22 from delays
LcdWriteString:
    sbi PORTD, PD2                  ; Set mode to data
    call delay_1us                  ; delay 1us
    ld r16, X+                      ; Load a byte from RAM from X
lcd_write_loop:                     ; We know the first byte is not null
    call write_byte                 ; Write the byte to the LCD
    ld r16, X+                      ; Read another byte
    tst r16                         ; Test the byte we just read
    brne lcd_write_loop             ; If it is not null, jump back and repeat
    ret

delay_1s:
    ldi r20, 64                     ; 1st loop count 64 x 15ms ~= 1s
delay_15ms:                         ; 15ms per top level loop
delay1:
    ldi r21, 250                    ; 2nd loop count
delay2:
    ldi r22, 250                    ; 3rd loop count
delay3:
    dec r22                         ; Decrement 3rd loop count
    brne delay3                     ; If not zero, jump back up to inner loop
    dec r21                         ; Decrement 2nd loop count
    brne delay2                     ; If not zero, jump back up to outer loop
delay_end:
    dec r20                         ; Decrement 1st loop count
    brne delay1                     ; If not zero, jump back up to top loop
    ret

delay_1us:
    ldi r20, 1                      ; Set 1st loop count to 1 to it returns
    nop                             ; nop just to slow down a little further
    rjmp delay_end                  ; Jump to delay routine, return from there

delay_50us:
    ldi r21, 1                      ; Setup 1st and 2nd loop count to run once
    ldi r20, 1
    rjmp delay2                     ; Jumping here sets us up for 250 loops


.endif