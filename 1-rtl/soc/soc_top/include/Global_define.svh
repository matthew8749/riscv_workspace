//-----------------------------------------------------------------------------
// Title         : Global Definitions
//-----------------------------------------------------------------------------
// File          : Global_define.svh
// Author        : Miles Yan
// Created       : 14.11.2025
//-----------------------------------------------------------------------------
// Description :
// Global parameter and address map definitions for the SoC project.
// This file provides centralized macro definitions for memory regions,
// AXI-Lite register mappings, FIFO configuration options, and system-wide
// constants. All modules within the SoC reference these macros to ensure
// consistent address allocation, register layout, and feature enablement.
//-----------------------------------------------------------------------------

//`define VENDORRAM
`define ASYNC_FIFO_2PRAM_WIDTH
`define ASYNC_FIFO_2PRAM_DEPTH
//`define SLOW_PERIOD 20
//`define FAST_PERIOD 10
//`define FAST_PERIOD 10
//`define FAST_PERIOD 10


//================================================================
//  SoC Memory Region Definitions
//================================================================
// u0_picorv32_axi
`define SOC_MEM_MAP_AXI_RAM0_ID              32'd0
`define SOC_MEM_MAP_AXI_RAM0_START_ADDR      32'h0000_0000
`define SOC_MEM_MAP_AXI_RAM0_END_ADDR        32'h0001_FFFF
// u0_axi_lite_memory
`define SOC_MEM_MAP_AXI_RAM1_ID              32'd1
`define SOC_MEM_MAP_AXI_RAM1_START_ADDR      32'h0010_0000
`define SOC_MEM_MAP_AXI_RAM1_END_ADDR        32'h0011_FFFF
// u0_axi_lite_regs
`define SOC_MEM_MAP_AXI_REGF0_ID             32'd2
`define SOC_MEM_MAP_AXI_REGF0_START_ADDR     32'h0012_0000
`define SOC_MEM_MAP_AXI_REGF0_END_ADDR       32'h0012_FFFF

//================================================================
//  AXI LITE REGFILE define
//================================================================
`define  TEST_REG_CNST                       1
`define  MST_U0_WR_IMP_DST_BADDR             `SOC_MEM_MAP_AXI_RAM1_START_ADDR             // reg_q_o[3] - reg_q_o[0]    0x0012_0003 ~ 0x0012_0000
`define  MST_U0_WR_IMP_ADR_PITCH             32'd16                                       // reg_q_o[7] - reg_q_o[4]    0x0012_0007 ~ 0x0012_0004
`define  MST_U0_WR_IMP_HSIZE                 8'd5                                         // reg_q_o[8]                 0x0012_0008
`define  MST_U0_WR_IMP_VSIZE                 8'd6                                         // reg_q_o[9]                 0x0012_0009
`define  MST_U0_WR_IMP_COOR_MINX             8'd0                                         // reg_q_o[10]                0x0012_000A
`define  MST_U0_WR_IMP_COOR_MINY             8'd0                                         // reg_q_o[11]                0x0012_000B
`define  MST_U0_WR_IMP_ST                                                                 // reg_q_o[12]                0x0012_000C

`define  MST_U0_RD_IMP_SRC_BADDR             `SOC_MEM_MAP_AXI_RAM1_START_ADDR             // reg_q_o[19] - reg_q_o[16]  0x0012_0013 ~ 0x0012_0010
`define  MST_U0_RD_IMP_ADR_PITCH             9'd16                                        // reg_q_o[23] - reg_q_o[20]  0x0012_0017 ~ 0x0012_0014
`define  MST_U0_RD_IMP_HSIZE                 8'd5                                         // reg_q_o[24]                0x0012_0018
`define  MST_U0_RD_IMP_VSIZE                 8'd6                                         // reg_q_o[25]                0x0012_0019
`define  MST_U0_RD_IMP_COOR_MINX             8'd0                                         // reg_q_o[26]                0x0012_001A
`define  MST_U0_RD_IMP_COOR_MINY             8'd0                                         // reg_q_o[27]                0x0012_001B
`define  MST_U0_RD_IMP_ST                                                                 // reg_q_o[28]                0x0012_001C
