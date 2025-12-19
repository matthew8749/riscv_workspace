// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "firmware.h"

static void delay(int time)
{
  int i;
  for (i=0;i<time;i++) {}
}

void main(void)
{
    uint32_t abd_data;
    //uint32_t apb_data;

    // SET Clock divider
      print_str("\ntest axi to apb\n");
      // *(UV32*)(0x00130000) = 0x00000000;
      // *(UV32*)(0x00130004) = 0x00000000;
      // *(UV32*)(0x00130008) = 0x00000000;
      // *(UV32*)(0x0013000C) = 0x00000000;
      // *(UV32*)(0x00130010) = 0x00000000;

      // *(UV32*)(0x00130000) = 0x00010000;
      // *(UV32*)(0x00130004) = 0x00010000;
      // *(UV32*)(0x00130008) = 0x00010000;
      // *(UV32*)(0x0013000C) = 0x00010000;
      // *(UV32*)(0x00130010) = 0x00010000;

      // *(UV32*)(0x00130000) = 0x00010100;
      // *(UV32*)(0x00130004) = 0x00010100;
      // *(UV32*)(0x00130008) = 0x00010100;
      // *(UV32*)(0x0013000C) = 0x00010100;
      // *(UV32*)(0x00130010) = 0x00010100;

      // // G0_CPU_CLK
      // *(UV32*)(0x00130000) = 0x00000000;                    // REG_CLK_CKEN_U0, REG_CLK_TOG_U0, REG_CLK_DIV_U0
      // *(UV32*)(0x00130000) = 0x00010000;                    // REG_CLK_CKEN_U0, REG_CLK_TOG_U0, REG_CLK_DIV_U0
      // *(UV32*)(0x00130000) = 0x00010100;                    // REG_CLK_CKEN_U0, REG_CLK_TOG_U0, REG_CLK_DIV_U0
      // // AXI_CLK
      // *(UV32*)(0x00130004) = 0x00010100;                    // REG_CLK_CKEN_U1, REG_CLK_TOG_U1, REG_CLK_DIV_U1
      // // APB_CLK
      // *(UV32*)(0x00130008) = 0x00010104;                    // REG_CLK_CKEN_U2, REG_CLK_TOG_U2, REG_CLK_DIV_U2
      // // I2C_CLK
      // *(UV32*)(0x0013000C) = 0x00010100;                    // REG_CLK_CKEN_U3, REG_CLK_TOG_U3, REG_CLK_DIV_U3
      // // IMP_CLK
      // *(UV32*)(0x00130010) = 0x00010100;                    // REG_CLK_CKEN_U4, REG_CLK_TOG_U4, REG_CLK_DIV_U4
      // // _CLK
      // //*(UV32*)(0x0013000C) = 0x00010100;                    // REG_CLK_CKEN_U5, REG_CLK_TOG_U5, REG_CLK_DIV_U5
      print_str("\ntest axi to apb  PASS\n");

    delay(1000);
    print_str("\nu0_mst_imp_r_ch\n");
    //u0_mst_imp_r_ch
    *(UV32*)(0x00120000) = 0x00100000;    // MST_U0_WR_IMP_DST_BADDR
    *(UV32*)(0x00120004) = 0x00000010;    // MST_U0_WR_IMP_ADR_PITCH
    *(UV8*)(0x00120008)  = 0x04;          // MST_U0_WR_IMP_HSIZE
    *(UV8*)(0x00120009)  = 0x06;          // MST_U0_WR_IMP_VSIZE
    *(UV8*)(0x0012000A)  = 0x00;          // MST_U0_WR_IMP_COOR_MINX
    *(UV8*)(0x0012000B)  = 0x00;          // MST_U0_WR_IMP_COOR_MINY
    *(UV8*)(0x0012000C)  = 0x01;          // MST_U0_WR_IMP_ST

    print_str("\nu0_mst_imp_w_ch\n");
    *(UV32*)(0x00120010) = 0x00100000;    // MST_U0_RD_IMP_SRC_BADDR
    *(UV32*)(0x00120014) = 0x00000010;    // MST_U0_RD_IMP_ADR_PITCH
    *(UV8*)(0x00120018)  = 0x04;          // MST_U0_RD_IMP_HSIZE
    *(UV8*)(0x00120019)  = 0x06;          // MST_U0_RD_IMP_VSIZE
    *(UV8*)(0x0012001A)  = 0x00;          // MST_U0_RD_IMP_COOR_MINX
    *(UV8*)(0x0012001B)  = 0x00;          // MST_U0_RD_IMP_COOR_MINY
    *(UV8*)(0x0012001C)  = 0x01;          // MST_U0_RD_IMP_ST

    //*(UV32*)(0x10000000) = 0x87654321;
    //*(UV32*)(0x00120024) = 0x00000009;
    abd_data = *(UV32*)0x00120010;
    print_hex(abd_data, 8);
    print_str("\n1111111111111111111111111111\n");





    // hello
    print_str("hello world\n");
    print_str("matthew\n");
}