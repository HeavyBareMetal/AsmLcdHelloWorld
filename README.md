# Minimal assembly AVR HD44780 LCD driver
Very minimal example of a pure assembly program for an Arduino Nano, driving
an HD44780 1602 LCD in 4 bit mode. The program outputs `Hello, World!` to the
LCD, and flashes the built-in LED once a second.

The total code size is 200 bytes. 14 bytes of RAM are used for the string.

A bash script `build.sh` is provided assemble the two source files into a hex 
file. The script `run.sh` will build and upload the code. USB port will need to
be changed.