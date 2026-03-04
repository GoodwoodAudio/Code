cd /Users/chippo/Documents/GitHub/Code/Web_Junctions/Underfacer/
avrdude -c usbtiny -p t44 -U lfuse:w:0xE2:m
avrdude -c usbtiny -p t44 -U hfuse:w:0xD4:m
avrdude -c usbtiny -p t44 -U efuse:w:0xFF:m
avrdude -c usbtiny -p t44 -U flash:w:firmware.hex
exit 