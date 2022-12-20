;; boot.asm, originally copied from wiki.osdev.org/Bare_Bones on Dec 14 2022 ;;

; Declare constants for the multiboot header.
MBALIGN  equ  1 << 0            ; align loaded modules on page boundaries
MEMINFO  equ  1 << 1            ; provide memory map
MBFLAGS  equ  MBALIGN | MEMINFO ; this is the Multiboot 'flag' field
MAGIC    equ  0x1BADB002        ; 'magic number' lets bootloader find the header
CHECKSUM equ -(MAGIC + MBFLAGS)   ; checksum of above, to prove we are multiboot

; virtual base address of the kernelspace. Must be used to convert virtual to 
; physical until actual paging is enabled. Note that this is not the virtual 
; address where the kernel image itself is loaded, just the amount that must be
; subtracted from the virtual address to get the physical one

KERNEL_VIRTUAL_BASE equ 0xC0000000                  ; 3GB
KERNEL_PAGE_NUMBER  equ (KERNEL_VIRTUAL_BASE >> 22) ; Page directory index


section .data
align 0x1000
bootPageDirectory:
    dd 0x00000083
    times (KERNEL_PAGE_NUMBER - 1) dd 0         ; Pages before kernelspace 
    dd 0x00000083
    times (1024 - KERNEL_PAGE_NUMBER - 1) dd 0  ; pages after kernel image

; Declare a multiboot header that marks the program as a kernel. These are magic
; values that are documented in the multiboot standard. The bootloader will
; search for this signature in the first 8 KiB of the kernel file, aligned at a
; 32-bit boundary. The signature is in its own section so the header can be
; forced to be within the first 8 KiB of the kernel file.
section .multiboot
align 4
	dd MAGIC
	dd MBFLAGS
	dd CHECKSUM

; The multiboot standard does not define the value of the stack pointer register
; (esp) and it is up to the kernel to provide a stack. This allocates room for a
; small stack by creating a symbol at the bottom of it, then allocating 16384
; bytes for it, and finally creating a symbol at the top. The stack grows
; downwards on x86. The stack is in its own section so it can be marked nobits,
; which means the kernel file is smaller because it does not contain an
; uninitialized stack. The stack on x86 must be 16-byte aligned according to the
; System V ABI standard and de-facto extensions. The compiler will assume the
; stack is properly aligned and failure to align the stack will result in
; undefined behavior.
section .bss
align 16
stack_bottom:
resb 16384 ; 16 KiB
stack_top:

; The linker script specifies _start as the entry point to the kernel and the
; bootloader will jump to this position once the kernel has been loaded. It
; doesn't make sense to return from this function as the bootloader is gone.
; Declare _start as a function symbol with the given symbol size.
section .text

loader equ(_loader - 0xC0000000)
global loader
global _start:function (_start.end - _start)
extern gdt_init
extern get_memmap

_loader:
    ; until paging has been set up, the code must be position-independent and use
    ; physical instead of virtual addresses
    mov ecx, (bootPageDirectory - KERNEL_VIRTUAL_BASE)
    mov cr3, ecx                    ; load page directory base reg

    mov ecx, cr4 
    or ecx, 0x00000010              ; set PSE bit in CR4 to enable 4mb pages
    mov cr4, ecx

    mov ecx, cr0
    or ecx, 0x80000000              ; set PG bit in CR0 to enable paging
    mov cr0, ecx

    lea ecx, [_start]               ; load correct virtual address of the kernel 
                                    ; entry to do a long jump and fetch the next
                                    ; instruction
    jmp ecx

_start:
	; The bootloader has loaded us into 32-bit protected mode on a x86
	; machine. Interrupts are disabled. Paging is disabled. The processor
	; state is as defined in the multiboot standard. The kernel has full
	; control of the CPU. The kernel can only make use of hardware features
	; and any code it provides as part of itself. There's no printf
	; function, unless the kernel provides its own <stdio.h> header and a
	; printf implementation. There are no security restrictions, no
	; safeguards, no debugging mechanisms, only what the kernel provides
	; itself. It has absolute and complete power over the
	; machine.

    ; Unmap identity-mapped first 4mb of physical addresses, since it shouldnt 
    ; be needed anymore: 
    mov dword [bootPageDirectory], 0
    invlpg [0]

	; To set up a stack, we set the esp register to point to the top of our
	; stack (as it grows downwards on x86 systems). This is necessarily done
	; in assembly as languages such as C cannot function without a stack.
	mov esp, stack_top
	; Obtain memory map
	push eax ; grub nicely left the magic multiboot header number here 
	push ebx

	call get_memmap

	; This is a good place to initialize crucial processor state before the
	; high-level kernel is entered. It's best to minimize the early
	; environment where crucial features are offline. Note that the
	; processor is not fully initialized yet: Features such as floating
	; point instructions and instruction set extensions are not initialized
	; yet. The GDT should be loaded here. Paging should be enabled here.
	; C++ features such as global constructors and exceptions will require
	; runtime support to work as well.

	call gdt_init

	; TODO: Paging

	; Enter the high-level kernel. The ABI requires the stack is 16-byte
	; aligned at the time of the call instruction (which afterwards pushes
	; the return pointer of size 4 bytes). The stack was originally 16-byte
	; aligned above and we've since pushed a multiple of 16 bytes to the
	; stack since (pushed 0 bytes so far) and the alignment is thus
	; preserved and the call is well defined.
        ; note, that if you are building on Windows, C functions may have "_" prefix in assembly: _kernel_main
	extern kernel_main
	call kernel_main

	; If the system has nothing more to do, put the computer into an
	; infinite loop. To do that:
	; 1) Disable interrupts with cli (clear interrupt enable in eflags).
	;    They are already disabled by the bootloader, so this is not needed.
	;    Mind that you might later enable interrupts and return from
	;    kernel_main (which is sort of nonsensical to do).
	; 2) Wait for the next interrupt to arrive with hlt (halt instruction).
	;    Since they are disabled, this will lock up the computer.
	; 3) Jump to the hlt instruction if it ever wakes up due to a
	;    non-maskable interrupt occurring or due to system management mode.
	cli
.hang:	hlt
	jmp .hang
.end:
