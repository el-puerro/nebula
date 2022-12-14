TARGET := $(shell pwd)/tools/cross/bin/i686-elf-

SRC_DIR := sources/kernel/src
INC_DIR := sources/kernel/include
PROJDIRS := $(SRC_DIR) $(INC_DIR)
BUILD_DIR := build
ISO_DIR := isodir

C_FILES := $(shell find $(PROJDIRS) -type f -name "\*.c")
HDR_FILES := $(shell find $(PROJDIRS) -type f -name "\*.h")
ASM_FILES := $(shell find $(PROJDIRS) -type f -name "\*.asm")
LD_FILE := $(shell find $(PROJDIRS) -type f -name "\*.ld")
SRC_FILES := $(C_FILES) $(ASM_FILES)
OBJFILES := $(patsubst %.c,%.o,$(SRC_FILES))

CFLAGS := -std=gnu99 -ffreestanding -O2 -Wall -Wextra
LDFLAGS := -ffreestanding -O2 -nostdlib -lgcc
ASFLAGS := -felf32
INCLUDE := -I$(INC_DIR)

CC := $(TARGET)gcc
AS := nasm


.PHONY: all clean run todo

all: nebula.iso

nebula.iso: $(ISO_DIR)/boot/nebula.bin $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $(BUILD_DIR)/$@ $(ISODIR)

nebula.bin: $(OBJFILES)
	$(CC) -T $(LD_FILE) -o $(ISO_DIR)/boot/nebula.bin $(LDFLAGS) $(OBJFILES)

%.o: %.c
	$(CC) -c $< -0 $@ $(CFLAGS)

%.o: %.asm
	$(AS) $(ASFLAGS) -c $< -o $@

run: nebula.iso
	qemu-system-i386 -cdrom $(BUILD_DIR)/nebula.iso

clean: 
	-@(RM) $(wildcard $(OBJFILES) $(BUILD_DIR) nebula.bin)