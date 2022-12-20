/* linker.ld, originally copied from wiki.osdev.org/Bare_Bones on Dec 14 2022 */

/* Modified to suit higher half kernel according to osdev wiki entry
 * https://wiki.osdev.org/Higher_Half_x86_Bare_Bones_(Backup)
 */

/* The bootloader will look at this image and start execution at the symbol
   designated as the entry point. */
/*ENTRY(_start) before higher half mapping */
ENTRY(loader)

/* Tell where the various sections of the object files will be put in the final
   kernel image. */
SECTIONS
{
	/* The kernel will be at 3GB + 1GB in virtual address space, which will be mapped to 1MB
     * in physical address space */
	. = 0xC0100000;
    /* . = 1M; from before highe half mapping*/

	/* First put the multiboot header, as it is required to be put very early
	   early in the image or the bootloader won't recognize the file format.
	   Next we'll put the .text section. */
	.text : AT(ADDR(.text) - 0xC0000000) /*.text BLOCK(4K) : ALIGN(4K) from before higher half*/
	{
		*(.multiboot)
		*(.text)
        *(.rodata*)
	}

	/* Read-only data. */
	/* .rodata BLOCK(4K) : ALIGN(4K)  from before higher half mapping
	{
		*(.rodata)
	}
    */

	/* Read-write data (initialized) */
	.data ALIGN (0x1000) : AT(ADDR(.data) - 0xC0000000) /*.data BLOCK(4K) : ALIGN(4K) from before higher half*/
	{
		*(.data)
	}

	/* Read-write data (uninitialized) and stack */
	.bss : AT(ADDR(.bss) - 0xC0000000) /*.bss BLOCK(4K) : ALIGN(4K) from before higher half */
	{
		*(COMMON)
		*(.bss)
	}

	/* The compiler may produce other sections, by default it will put them in
	   a segment with the same name. Simply add stuff here as needed. */
}
