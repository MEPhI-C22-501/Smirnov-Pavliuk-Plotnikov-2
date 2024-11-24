#!/bin/bash

# Проверка на наличие входного параметра
if [ -z "$1" ]; then
    echo "Usage: $0 <filename_without_extension>"
    exit 1
fi

# Имя файла, переданное в качестве параметра
FILE_NAME=$1

# Шаг 1: Ассемблирование (program.s -> program.o)
echo "Assembling $FILE_NAME.s..."
riscv64-unknown-elf-as "$FILE_NAME.s" -o "$FILE_NAME.o"
if [ $? -ne 0 ]; then
    echo "Error: Assembly failed."
    exit 1
fi

# Шаг 2: Линковка (program.o -> program.elf)
echo "Linking $FILE_NAME.o..."
riscv64-unknown-elf-ld "$FILE_NAME.o" -o "$FILE_NAME.elf"
if [ $? -ne 0 ]; then
    echo "Error: Linking failed."
    exit 1
fi

# Шаг 3: Преобразование в бинарный файл (program.elf -> program.bin)
echo "Converting $FILE_NAME.elf to binary..."
riscv64-unknown-elf-objcopy -O binary "$FILE_NAME.elf" "$FILE_NAME.bin"
if [ $? -ne 0 ]; then
    echo "Error: Conversion to binary failed."
    exit 1
fi

# Шаг 4: Преобразование бинарного файла в hex (program.bin -> program.hex) с Big Endian
echo "Converting $FILE_NAME.bin to hex in Big Endian format..."

# Используем xxd для получения hex-представления, затем меняем порядок байт на Big Endian
xxd -p -c 4 "$FILE_NAME.bin" | while read line; do
    # Разбиваем строку на байты и переставляем их в Big Endian
    echo "${line:6:2}${line:4:2}${line:2:2}${line:0:2}"
done > "$FILE_NAME.hex"

if [ $? -ne 0 ]; then
    echo "Error: Conversion to hex failed."
    exit 1
fi

echo "Build complete! Generated files:"
echo "  - $FILE_NAME.o (Object file)"
echo "  - $FILE_NAME.elf (ELF executable)"
echo "  - $FILE_NAME.bin (Binary file)"
echo "  - $FILE_NAME.hex (Hex file in Big Endian)"
