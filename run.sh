#!/bin/bash
avra main.asm && \
avrdude -p atmega328p -c arduino -P /dev/tty.usbserial-141410 -U flash:w:main.hex