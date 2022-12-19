# Makefile for building nebula
#
# Hopefully, I barely have to touch this abomination again

TARGET := tools/cross/bin/i686-elf-
CC := $(TARGET)gcc
AS := nasm

CFLAGS := -std=gnu99 -ffreestanding -O2 -Wall -Wextra
LDFLAGS := -ffreestanding -O2 -nostdlib -lgcc
ASMFLAGS := -felf32
SRC_DIR := sources/kernel/src 
CFILES := $(shell find $(SRC_DIR) -type f -name "*.c") #$(wildcard $(SRC_DIR)/*.c)
ASMFILES := $(shell find $(SRC_DIR) -type f -name "*.asm") #$(wildcard $(SRC_DIR)/*.asm)
SRC := $(CFILES) $(ASMFILES)

COBJS:= $(patsubst %.c,%.o,$(CFILES))
ASMOBJS := $(patsubst %.asm,%.o,$(ASMFILES))
OBJFILES := $(wildcard $(SRC_DIR/*.o))

INCLUDE_DIR := sources/kernel/include 

LDFILE := sources/kernel/src/linker.ld


.PHONY: iso clean

iso: binary
		grub-mkrescure -o nebula.iso isodir

binary: c-sources asm-sources
		$(CC) -T isodir/boot/nebula.bin $(COBJS) $(ASMOBJS) $(LDFLAGS)

c-sources: $(CFILES)
		$(foreach cfile, $(CFILES), $(CC) -I$(INCLUDE_DIR) -c $(cfile) -o $(patsubst %.c,%.o,$(cfile) $(CFLAGS)))
	
asm-sources: $(ASMFILES)
		$(foreach asmfile, $(ASFILES), $(AS) $(ASFLAGS) $(asmfile) -o $(patsubst %.asm,%.o,$(asmfile)))


clean: 
	rm -rf isodir/boot/nebula.bin $(OBJFILES) nebula.iso


