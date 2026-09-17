#!/bin/bash

# Locate this script's own folder — works no matter where Google Drive is mounted
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check avrdude is installed on this Mac
if ! command -v avrdude >/dev/null 2>&1; then
    echo "Error: avrdude is not installed on this Mac."
    echo ""
    echo "One-time setup - run these in the Terminal app, IN ORDER:"
    echo ""
    echo "1) If you don't already have Homebrew, install it first:"
    echo '   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    echo ""
    echo "2) Once Homebrew has finished, install avrdude:"
    echo "   brew install avrdude"
    echo ""
    echo "Then run this script again."
    read -p "Press enter to exit"
    exit 1
fi

# Find the .hex firmware file(s) in this folder
shopt -s nullglob
HEXFILES=("$SCRIPT_DIR"/*.hex)
shopt -u nullglob

if [ ${#HEXFILES[@]} -eq 0 ]; then
    echo "Error: no .hex file found in this folder."
    echo "Folder: $SCRIPT_DIR"
    read -p "Press enter to exit"
    exit 1
elif [ ${#HEXFILES[@]} -eq 1 ]; then
    # Only one firmware here — use it automatically
    HEXFILE="${HEXFILES[0]}"
else
    # Several firmware versions here — ask which one to flash
    echo "Multiple firmware files found. Which one do you want to flash?"
    i=1
    for f in "${HEXFILES[@]}"; do
        echo "  $i) $(basename "$f")"
        i=$((i+1))
    done
    read -p "Enter a number: " HEXNUM
    if ! [[ "$HEXNUM" =~ ^[0-9]+$ ]] || [ "$HEXNUM" -lt 1 ] || [ "$HEXNUM" -gt ${#HEXFILES[@]} ]; then
        echo "Invalid selection. Exiting."
        read -p "Press enter to exit"
        exit 1
    fi
    HEXFILE="${HEXFILES[$((HEXNUM-1))]}"
fi

echo "Firmware: $(basename "$HEXFILE")"
echo ""

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

echo "Flashing $CHIP_NAME boards with $(basename "$HEXFILE"). Press Ctrl+C or Q to quit."

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