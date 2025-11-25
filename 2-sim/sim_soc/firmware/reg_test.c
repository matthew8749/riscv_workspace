// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "firmware.h"

void    wr_reg(int addr, int wdata)
{
  *(UV32*)addr = wdata;
}

void    wrh_reg(int addr, short wdata)
{
  *(UV16*)addr = wdata;
}

void    wrb_reg(int addr, char wdata)
{
  *(UV8*)addr = wdata;
}
