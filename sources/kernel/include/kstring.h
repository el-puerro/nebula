// string.h implementation for the kernelspace
// 14.12.2022@el-puerro
#pragma once

#include <stdint.h>
#include <stddef.h>

char* itoa(int val, int base){

	// fix missing 0 issue
	if(val == 0)
	{
		return "0";
	}

	static char buf[32] = {0};
	
	int i = 30;
	
	for(; val && i ; --i, val /= base)
	
		buf[i] = "0123456789abcdef"[val % base];
	
	return &buf[i+1];
	
}
