#include "../include/mem.h"

// Global variables
multiboot_info_t* multiboot_info;

int pmem_index_free;
int pmem_index_reserved;

mmap_entry_t* pmem_list_free[20];
mmap_entry_t* pmem_list_reserved[20];

/** 
 * @brief we only get the memory map from grub if we take it immediately
 * @param[in] mbd Memory Map
 * @param[in] magic magic number from the multiboot header
 */
void get_memmap(multiboot_info_t* mbd, uint32_t magic)
{
    if(magic == MULTIBOOT_BOOTLOADER_MAGIC)
    {
        if(mbd->flags >> 6&0x61)
        {
            multiboot_info = mbd;
        }
    }
}

void memmap_init_lists()
{
    pmem_index_free = 0;
    pmem_index_reserved = 0;
    for(int i = 0; i < multiboot_info->mmap_length; i += sizeof(mmap_entry_t))
    {
        mmap_entry_t* entry = (mmap_entry_t*)(multiboot_info->mmap_addr + i);
        if(entry->type == MULTIBOOT_MEMORY_AVAILABLE)
        {
            pmem_list_free[pmem_index_free] = entry;
            pmem_index_free++;
        }

        else if(entry->type == MULTIBOOT_MEMORY_RESERVED)
        {
            pmem_list_reserved[pmem_index_reserved] = entry;
        }
    }
}
