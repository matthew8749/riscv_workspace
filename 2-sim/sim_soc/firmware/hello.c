// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "firmware.h"

uint32_t abd_data;

void hello(void)
{
	print_str("hello world\n");
    print_str("matthew\n");



    *(UV32*)(0x00120010) = 0x12345678;
    //*(UV32*)(0x10000000) = 0x87654321;
    //*(UV32*)(0x00120024) = 0x00000009;
    abd_data = *(UV32*)0x00120010;
    print_hex(abd_data, 8);
    print_str("\n1111111111111111111111111111\n");
}

