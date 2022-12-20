#include "../include/interrupt.h"

void exception_handler(void)
{
    __asm__ volatile("cli; hlt"); // Hang the computer
}

void idt_set_descriptor(uint8_t vector, void* isr, uint8_t flags)
{
    idt_entry_t* descriptor = &idt[vector];

    descriptor->isr_low    = (uint64_t)isr & 0xFFFF;
    descriptor->kernel_cs  = 0x08; // GDT Kernel Code Descriptor offset
    descriptor->attributes = flags;
    descriptor->isr_high   = (uint32_t)isr >> 16;
    descriptor->reserved   = 0;
}

void idt_init(void)
{
    idtr.base = (uintptr_t)&idt[0];
    idtr.limit = (uint16_t)sizeof(idt_entry_t) * 256 - 1;

    for(uint8_t vector = 0; vector < 32; vector++)
    {
        idt_set_descriptor(vector, isr_stub_table[vector], 0x8E);
        vectors[vector] = true;
    }

    __asm__ volatile("lidt %0" : : "m"(idtr)); // load the new IDT
    __asm__ volatile("sti"); // set the interrupt flag
}
