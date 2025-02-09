.include "m328pdef.inc"

.equ    helloLen    = 14            ; Length of hello world string inc. \0

.dseg                               ; Start of RAM
.org SRAM_START
    helloString: .byte helloLen     ; Reserve space in RAM for string

.cseg                               ; Start of ROM
.org 	0x00
reset:
    ldi r16, low(RAMEND)            ; Initialise stack pointer to end of RAM
    out SPL, r16                    ; Write out stack pointer low byte
    ldi r16, high(RAMEND)
    out SPH, r16                    ; Write out high byte

    sbi DDRB, PB5                   ; Enable PB5 (LED) as an output

    rcall LcdInit                   ; Initialise the LCD

    ; Get the pointers ready for ROM and RAM
    ldi	XL,LOW(helloString)		    ; Set X to string RAM array, low byte
	ldi	XH,HIGH(helloString)		; High byte
    movw YL, XL                     ; Make a copy, X will be used by LCD
	ldi	ZL,LOW(2*helloString_ROM)   ; Set Z pointer string ROM address, low
	ldi	ZH,HIGH(2*helloString_ROM)  ; String ROM address high

	ldi	r17, helloLen               ; Set loop counter to size in bytes
ram_init_loop:
    lpm	r16, Z+                     ; Load a byte from ROM, and inc Z pointer
    st	Y+, r16                     ; Store in RAM, and inc Y pointer
    dec	r17                         ; Decrement loop counter
    brne ram_init_loop              ; Stop when loop counter is 0

    rcall LcdWriteString            ; Print with X register (RAM pointer)

loop:
    sbi PINB, PB5                   ; Invert LED output by writing to PINB
    rcall delay_1s                  ; Wait a second
    rjmp loop                       ; Loop forever

.include "asmlcd.asm"               ; Include the LCD code here

__DATA_START:
helloString_ROM:
    .db "Hello, world!",0           ; Hello world string and null terminator
__DATA_END:
