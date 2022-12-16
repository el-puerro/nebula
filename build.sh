#!/usr/bin/env bash

set -e

export OBJECT=".o"
export CFLAGS="-std=gnu99 -ffreestanding -O2 -Wall -Wextra"
export LDFLAGS="-ffreestanding -O2 -nostdlib -lgcc"

for file in $(find sources/kernel -type f -name "*.c"); do
    echo "CC $file"
    $(pwd)/tools/cross/bin/i686-elf-gcc -I$(pwd)/sources/kernel/include -c $file -o $file$OBJECT $CFLAGS
done

for file in $(find -type f -name "*.asm"); do
    echo "AS $file"
    nasm -felf32 $file -o $file$OBJECT
done

for file in $(find -type f -name "*.ld"); do
    echo "LD $file"
    $(pwd)/tools/cross/bin/i686-elf-gcc -T $(pwd)/isodir/boot/nebula.bin $find -type f -name "*.o" $(LDFLAGS)
done

grub-mkrescue -o nebula.iso isodir
