#!/bin/bash

# Full folder path to your firmware
SCRIPT_DIR="/Users/chippo/Documents/GitHub/Code/Web Junctions/Underfacer"
HEXFILE="$SCRIPT_DIR/firmware.hex"

# Check firmware exists
if [ ! -f "$HEXFILE" ]; then
    echo "Error: firmware.hex not found in $SCRIPT_DIR"
    read -p "Press enter to exit"
    exit 1
fi

# Ask for chip type once
echo "Select microcontroller to flash for this session:"
echo "1) ATtiny44"
echo "2) ATtiny84"
echo "3) ATmega328PB"
read -p "Enter 1, 2, or 3: " CHIP

case $CHIP in
    1) CHIP_NAME="ATtiny44";;
    2) CHIP_NAME="ATtiny84";;
    3) CHIP_NAME="ATmega328PB";;
    *) echo "Invalid selection. Exiting."; exit 1;;
esac

echo "Flashing $CHIP_NAME boards. Press Ctrl+C or Q to quit."

# Flash loop
while true; do
    case $CHIP in
        1)
            avrdude -c usbtiny -p t44 -U lfuse:w:0xE2:m
            avrdude -c usbtiny -p t44 -U hfuse:w:0xD4:m
            avrdude -c usbtiny -p t44 -U efuse:w:0xFF:m
            avrdude -c usbtiny -p t44 -U flash:w:"$HEXFILE":i
            ;;
        2)
            avrdude -c usbtiny -p t84 -U lfuse:w:0xE2:m
            avrdude -c usbtiny -p t84 -U hfuse:w:0xD4:m
            avrdude -c usbtiny -p t84 -U efuse:w:0xFF:m
            avrdude -c usbtiny -p t84 -U flash:w:"$HEXFILE":i
            ;;
        3)
            avrdude -c usbtiny -p m328pb -U flash:w:"$HEXFILE":i
            ;;
    esac

    echo "Board flashed successfully!"
    echo "--------------------------------"
    read -p "Press Enter to flash next board or type Q then Enter to quit: " NEXT
    if [[ "$NEXT" =~ [Qq] ]]; then
        echo "Exiting..."
        exit 0
    fi
done