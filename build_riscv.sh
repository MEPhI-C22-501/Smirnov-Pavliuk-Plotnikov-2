#!/bin/bash

ENDIAN="little"   
KEEP_FILES=false  

while [[ $# -gt 0 ]]; do
    case $1 in
        --endian)
            if [[ "$2" == "big" || "$2" == "little" ]]; then
                ENDIAN="$2"
                shift
            else
                echo "Error: Invalid value for --endian. Use 'big' or 'little'."
                exit 1
            fi
            ;;
        --keep)
            KEEP_FILES=true
            ;;
        *)
            FILE_NAME="$1"
            ;;
    esac
    shift
done

if [ -z "$FILE_NAME" ]; then
    echo "Usage: $0 <filename_without_extension> [--endian <big|little>] [--keep]"
    exit 1
fi

echo "Assembling $FILE_NAME.s..."
riscv64-unknown-elf-as "$FILE_NAME.s" -o "$FILE_NAME.o"
if [ $? -ne 0 ]; then
    echo "Error: Assembly failed."
    exit 1
fi

echo "Linking $FILE_NAME.o..."
riscv64-unknown-elf-ld "$FILE_NAME.o" -o "$FILE_NAME.elf"
if [ $? -ne 0 ]; then
    echo "Error: Linking failed."
    exit 1
fi

echo "Converting $FILE_NAME.elf to binary..."
riscv64-unknown-elf-objcopy -O binary "$FILE_NAME.elf" "$FILE_NAME.bin"
if [ $? -ne 0 ]; then
    echo "Error: Conversion to binary failed."
    exit 1
fi

echo "Converting $FILE_NAME.bin to hex ($ENDIAN Endian)..."

if [[ "$ENDIAN" == "big" ]]; then
    # Big Endian: Переставляем байты (32-битные слова)
    xxd -p -c 4 "$FILE_NAME.bin" | while read line; do
        echo "${line:6:2}${line:4:2}${line:2:2}${line:0:2}"
    done > "$FILE_NAME.hex"
elif [[ "$ENDIAN" == "little" ]]; then
    # Little Endian: Просто создаём hex без перестановки
    xxd -p "$FILE_NAME.bin" > "$FILE_NAME.hex"
fi

if [ $? -ne 0 ]; then
    echo "Error: Conversion to hex failed."
    exit 1
fi

if [ "$KEEP_FILES" = false ]; then
    echo "Cleaning up intermediate files..."
    rm -f "$FILE_NAME.o" "$FILE_NAME.elf" "$FILE_NAME.bin"
fi

echo "Build complete! Generated files:"
echo "  - $FILE_NAME.hex (Hex file in $ENDIAN Endian)"
[ "$KEEP_FILES" = true ] && echo "  - $FILE_NAME.o (Object file)"
[ "$KEEP_FILES" = true ] && echo "  - $FILE_NAME.elf (ELF file)"
[ "$KEEP_FILES" = true ] && echo "  - $FILE_NAME.bin (Binary file)"
