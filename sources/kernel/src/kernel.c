/* kernel.c, originally copied from wiki.osdev.org/Bare_Bones on Dec 14 2022 */

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "../include/vga.h"
#include "../include/kstring.h"

/* Check if the compiler thinks you are targeting the wrong operating system. */
#if defined(__linux__)
#error "You are not using a cross-compiler, you will most certainly run into trouble"
#endif

/* This tutorial will only work for the 32-bit ix86 targets. */
#if!defined(__i386__)
#error "This tutorial needs to be compiled with a ix86-elf compiler"
#endif



void kernel_main(void) 
{
	/* Initialize terminal interface */
	terminal_initialize();

	for(int i = 0; i < 200; i++)
	{
		terminal_setcolor(VGA_COLOR_RED);
		terminal_writestring(itoa(i, 10));
		terminal_setcolor(VGA_COLOR_WHITE);
		terminal_writestring("abcdefghijklmnopqrstuvwxyz");
	}
	terminal_writestring("Hello, kernel World!\n");
}
