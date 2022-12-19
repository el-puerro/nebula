#include "../include/gdt.h"

//extern LOAD_GDT(limit, base);
uint32_t *create_descriptor(uint32_t base, uint32_t limit, uint16_t flag)
{
    uint64_t d;
    // create the high 32bit segment
    d = limit & 0x000F0000;             // limit bits 19:16
    d |= (flag << 8) & 0x00F0FF00;      // set type, p, dpl, s, g, d/b, l, avl
    d |= (base >> 16) & 0x000000FF;     // base bits 32:16
    d |= base & 0xFF000000;             // base bits 31:24

    // shift by 32 bits to allow for lower part of segment
    d <<= 32;

    d |= base << 16;                   // base bits 15:0
    d |= limit & 0x0000FFFF;           // limit bits 15:0

    // return a pointer to the descriptor
    uint32_t *desc = (uint32_t*)&d; //(uint32_t*)(&d << 32);
    return desc;
}

void gdt_init()
{
    uint32_t *base = create_descriptor(0, 0, 0);
    create_descriptor(0, 0x000FFFFF, (GDT_CODE_PL0));
    create_descriptor(0, 0x000FFFFF, (GDT_DATA_PL0));
    create_descriptor(0, 0x000FFFFF, (GDT_CODE_PL3));
    create_descriptor(0, 0x000FFFFF, (GDT_DATA_PL3));
    LOAD_GDT((sizeof(uint64_t) * 5), *base);
    //TODO: Task State Segment
}
