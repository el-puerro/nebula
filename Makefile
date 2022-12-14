TARGET := $(shell pwd)/tools/cross/bin/i686-elf-

SRC_DIR := $(shell pwd)/sources/kernel/src
INC_DIR := $(shell pwd)/sources/kernel/include
PROJDIRS := $(SRC_DIR) $(INC_DIR)
BUILD_DIR := $(shell pwd)/build
ISO_DIR := $(shell pwd)/isodir

C_FILES := $(shell find $(SRC_DIR) -type f -name "*.c")
HDR_FILES := $(shell find $(SRC_DIR) -type f -name "*.h")
ASM_FILES := $(shell find $(SRC_DIR) -type f -name "*.asm")
LD_FILE := $(SRC_DIR)/linker.ld #$(shell find $(SRC_DIR) -type f -name "\*.ld")
SRC_FILES := $(C_FILES) $(ASM_FILES)
OBJFILES := $(patsubst %.c,%.o,$(C_FILES))
ASMOBJFILES := $(patsubst %.asm,%.o,$(ASM_FILES))
ALLFILES := $(C_FILES) $(HDR_FILES) $(ASM_FILES) $(LD_FILE)

CFLAGS := -std=gnu99 -ffreestanding -O2 -Wall -Wextra
LDFLAGS := -ffreestanding -O2 -nostdlib -lgcc
ASFLAGS := -felf32
INCLUDE := -I$(INC_DIR)

CC := $(TARGET)gcc
AS := nasm


.PHONY: all clean run todo

all: nebula.iso

nebula.iso: nebula.bin
	grub-mkrescue -o $@ isodir

nebula.bin: cbuild asmbuild #$(OBJFILES)
	$(CC) -T $(LD_FILE) -o $(ISO_DIR)/boot/nebula.bin $(OBJFILES) $(ASMOBJFILES) $(LDFLAGS) 

#$(OBJFILES): $(C_FILES)
#%.o: %.c
cbuild: 
	$(CC) $(INCLUDE) -c $(C_FILES) -o $(OBJFILES) $(CFLAGS) 

#$(ASMOBJFILES): $(ASM_FILES)
#%.o: %.asm
asmbuild:
	$(AS) $(ASFLAGS) $(ASM_FILES) -o $(ASMOBJFILES)

run: nebula.iso
	qemu-system-i386 -cdrom nebula.iso

clean: 
	rm -rf build/ isodir/boot/nebula.bin nebula.iso
	$(RM) $(OBJFILES) $(ASMOBJFILES)

todo:
	$(shell bash todo.sh)