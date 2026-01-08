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
    uint32_t test_data;
    //uint32_t apb_data;

    // SET Clock divider
      print_str("\ntest axi to apb\n");
      // *(UV32*)(0x00130000) = 0x00000000;
      // *(UV32*)(0x00130004) = 0x00000000;
      print_str("\ntest axi to apb  PASS\n");

    delay(1000);


    print_str("\nu0_mst_imp_w_ch\n");
    //u0_mst_imp_w_ch                                                                     // AXI regfile's REG
    *(UV32*)(AXIX_SLV_REGF0_BASE_ADDR       )  = AXIX_SLV_RAM1_BASE_ADDR;                 // MST_U0_WR_IMP_DST_BADDR
    *(UV32*)(AXIX_SLV_REGF0_BASE_ADDR + 0x04)  = 0x00000020;                              // MST_U0_WR_IMP_ADR_PITCH
    *(UV8*) (AXIX_SLV_REGF0_BASE_ADDR + 0x08)  = 0x05;                                    // MST_U0_WR_IMP_HSIZE
    *(UV8*) (AXIX_SLV_REGF0_BASE_ADDR + 0x09)  = 0x08;                                    // MST_U0_WR_IMP_VSIZE
    *(UV8*) (AXIX_SLV_REGF0_BASE_ADDR + 0x0A)  = 0x00;                                    // MST_U0_WR_IMP_COOR_MINX
    *(UV8*) (AXIX_SLV_REGF0_BASE_ADDR + 0x0B)  = 0x00;                                    // MST_U0_WR_IMP_COOR_MINY
    *(UV8*) (AXIX_SLV_REGF0_BASE_ADDR + 0x0C)  = 0x01;                                    // MST_U0_WR_IMP_ST

    print_str("\nu0_mst_imp_r_ch\n");
    //u0_mst_imp_r_ch                                                                     // AXI regfile's REG
    *(UV32*)(AXIX_SLV_REGF0_BASE_ADDR + 0x10)  = AXIX_SLV_IMPI_BASE_ADDR;//+ 0x80000;                 // MST_U0_RD_IMP_SRC_BADDR
    *(UV32*)(AXIX_SLV_REGF0_BASE_ADDR + 0x14)  = 0x00000A00;                              // MST_U0_RD_IMP_ADR_PITCH
    *(UV16*)(AXIX_SLV_REGF0_BASE_ADDR + 0x18)  = 0x0280;                                  // MST_U0_RD_IMP_HSIZE
    *(UV16*)(AXIX_SLV_REGF0_BASE_ADDR + 0x1A)  = 0x0002;                                  // MST_U0_RD_IMP_VSIZE
    *(UV8*) (AXIX_SLV_REGF0_BASE_ADDR + 0x1C)  = 0x00;                                    // MST_U0_RD_IMP_COOR_MINX
    *(UV8*) (AXIX_SLV_REGF0_BASE_ADDR + 0x1D)  = 0x00;                                    // MST_U0_RD_IMP_COOR_MINY
    *(UV8*) (AXIX_SLV_REGF0_BASE_ADDR + 0x1E)  = 0x01;                                    // MST_U0_RD_IMP_ST

    //*(UV32*)(0x10000000) = 0x87654321;
    //*(UV32*)(0x00120024) = 0x00000009;
    abd_data = *(UV32*)0x00100014;
    test_data = *(UV32*)AXIX_SLV_REGF0_BASE_ADDR;
    print_hex(abd_data, 8);print_str("\n");
    print_hex(test_data, 8);print_str("\n");
    print_str("\n1111111111111111111111111111\n");

    // Clock test
    //*(UV32*)(0x00130008) = 0x000000F7;    // gated I2C_CLK

    // hello
    print_str("hello world\n");
    print_str("matthew\n");

}