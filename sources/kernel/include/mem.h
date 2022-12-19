#pragma once 
#include "../include/multiboot.h"
#include <stdint.h>
#include <stddef.h>

// This is actually a mmap entry, not the entire map
typedef multiboot_memory_map_t mmap_entry_t;

multiboot_info_t* multiboot_info;

int pmem_index_free = 0;
int pmem_index_reserved = 0;

mmap_entry_t* pmem_list_free[20];
mmap_entry_t* pmem_list_reserved[20];

void get_memmap(multiboot_info_t* mbd, uint32_t magic);
void memmap_init_lists();
