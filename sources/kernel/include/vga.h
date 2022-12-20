#pragma once

#include <stddef.h>
#include <stdint.h>

// Copied from kernel.c on Dec 14 2022

/* Hardware text mode color constants. */
enum vga_color {
	VGA_COLOR_BLACK = 0,
	VGA_COLOR_BLUE = 1,
	VGA_COLOR_GREEN = 2,
	VGA_COLOR_CYAN = 3,
	VGA_COLOR_RED = 4,
	VGA_COLOR_MAGENTA = 5,
	VGA_COLOR_BROWN = 6,
	VGA_COLOR_LIGHT_GREY = 7,
	VGA_COLOR_DARK_GREY = 8,
	VGA_COLOR_LIGHT_BLUE = 9,
	VGA_COLOR_LIGHT_GREEN = 10,
	VGA_COLOR_LIGHT_CYAN = 11,
	VGA_COLOR_LIGHT_RED = 12,
	VGA_COLOR_LIGHT_MAGENTA = 13,
	VGA_COLOR_LIGHT_BROWN = 14,
	VGA_COLOR_WHITE = 15,
};

static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg) 
{
	return fg | bg << 4;
}

static inline uint16_t vga_entry(unsigned char uc, uint8_t color) 
{
	return (uint16_t) uc | (uint16_t) color << 8;
}

size_t strlen(const char* str) 
{
	size_t len = 0;
	while (str[len])
		len++;
	return len;
}

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

size_t terminal_row;
size_t terminal_column;
uint8_t terminal_color;
uint16_t* terminal_buffer;

void terminal_initialize(void) 
{
	terminal_row = 0;
	terminal_column = 0;
	terminal_color = vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
	terminal_buffer = (uint16_t*) 0xC00B8000; //0xB8000; from before higher half mapping
	for (size_t y = 0; y < VGA_HEIGHT; y++) {
		for (size_t x = 0; x < VGA_WIDTH; x++) {
			const size_t index = y * VGA_WIDTH + x;
			terminal_buffer[index] = vga_entry(' ', terminal_color);
		}
	}
}

void terminal_setcolor(uint8_t color) 
{
	terminal_color = color;
}

void terminal_putentryat(char c, uint8_t color, size_t x, size_t y) 
{
	const size_t index = y * VGA_WIDTH + x;
	terminal_buffer[index] = vga_entry(c, color);
}

void terminal_scroll() 
{
	for(size_t row = 1; row < VGA_HEIGHT; row++)
	{
		for(size_t col = 0; col < VGA_WIDTH; col++)
		{
			size_t index = row * VGA_WIDTH + col;
			size_t tmp = row - 1;
			size_t lastrow = tmp * VGA_WIDTH + col;
			terminal_buffer[lastrow] = terminal_buffer[index];
		}
	}	

	for(size_t col = 0; col < VGA_WIDTH; col++)
    {
    	terminal_buffer[terminal_row * VGA_WIDTH + col] = vga_entry(' ', terminal_color);
		terminal_buffer[(terminal_row - 1) * VGA_WIDTH + col] = vga_entry(' ', terminal_color);
    }
	//terminal_column = 0;
}

void newline()
{
	if(++terminal_row == VGA_HEIGHT)
	{
		terminal_scroll();
		terminal_column = 0;
		terminal_row--;
	}
	else
	{
		terminal_column = 0;
		terminal_row++;
	}
}

void terminal_putchar(char c) 
{
	if(c == '\n')
	{
		newline();
	}
	else if(++terminal_column == VGA_WIDTH) 
	{
		newline();
		terminal_putentryat(c, terminal_color, terminal_column, terminal_row);
	}
	else
	{
		terminal_putentryat(c, terminal_color, terminal_column, terminal_row);
	}
}

void terminal_write(const char* data, size_t size) 
{
	for (size_t i = 0; i < size; i++)
	{
		terminal_putchar(data[i]);
	}
}

void terminal_writestring(const char* data) 
{
	terminal_write(data, strlen(data));
}

