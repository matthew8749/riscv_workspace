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
// u0_picorv32_axi_ROM
`define SOC_MEM_MAP_AXI_ROM0_ID              0
`define SOC_MEM_MAP_AXI_ROM0_START_ADDR      32'h0000_0000
`define SOC_MEM_MAP_AXI_ROM0_END_ADDR        32'h000F_FFFF
// u0_axi_lite_regs
`define SOC_MEM_MAP_AXI_REGF0_ID             1
`define SOC_MEM_MAP_AXI_REGF0_START_ADDR     32'h0010_0000
`define SOC_MEM_MAP_AXI_REGF0_END_ADDR       32'h0010_FFFF
// u0_axi_lite_to_apb_intf (APB BUS)                                                      // !! ID is always the last
`define SOC_MEM_MAP_AXI_APB_ID               4                                            // !! ID is always the last
`define SOC_MEM_MAP_AXI_APB_START_ADDR       32'h0011_0000                                // !! ID is always the last
`define SOC_MEM_MAP_AXI_APB_END_ADDR         32'h0011_FFFF                                // !! ID is always the last
// u0_axi_lite_memory
`define SOC_MEM_MAP_AXI_RAM1_ID              2
`define SOC_MEM_MAP_AXI_RAM1_START_ADDR      32'h0012_0000
`define SOC_MEM_MAP_AXI_RAM1_END_ADDR        32'h0013_FFFF
// u1_axi_lite_memory_imp
`define SOC_MEM_MAP_AXI_IMPI_ID              3
`define SOC_MEM_MAP_AXI_IMPI_START_ADDR      32'h4000_0000
`define SOC_MEM_MAP_AXI_IMPI_END_ADDR        32'h412F_FFFF
//// u2_axi_lite_memory_imp                                                                 // !! unUSED
//`define SOC_MEM_MAP_AXI_IMPO_ID              4                                            // !! unUSED
//`define SOC_MEM_MAP_AXI_IMPO_START_ADDR      32'h082C_0000                                // !! unUSED
//`define SOC_MEM_MAP_AXI_IMPO_END_ADDR        32'h084B_FFFF                                // !! unUSED






















//================================================================
//  AXI LITE REGFILE define
//================================================================
//`define  TEST_REG_CNST                       1
//`define  MST_U0_WR_IMP_DST_BADDR             `SOC_MEM_MAP_AXI_RAM1_START_ADDR             // reg_q_o[3]  - reg_q_o[0]   0x0010_0003 ~ 0x0010_0000
//`define  MST_U0_WR_IMP_ADR_PITCH             32'd16                                       // reg_q_o[7]  - reg_q_o[4]   0x0010_0007 ~ 0x0010_0004
//`define  MST_U0_WR_IMP_HSIZE                 8'd5                                         // reg_q_o[9]  - reg_q_o[8]   0x0010_0009 ~ 0x0010_0008
//`define  MST_U0_WR_IMP_VSIZE                 8'd6                                         // reg_q_o[11] - reg_q_o[10]  0x0010_000B ~ 0x0010_000A
//`define  MST_U0_WR_IMP_COOR_MINX             8'd0                                         // reg_q_o[12]                0x0010_000C
//`define  MST_U0_WR_IMP_COOR_MINY             8'd0                                         // reg_q_o[13]                0x0010_000D
//`define  MST_U0_WR_IMP_ST                                                                 // reg_q_o[14]                0x0010_000E

//`define  MST_U0_RD_IMP_SRC_BADDR             `SOC_MEM_MAP_AXI_RAM1_START_ADDR             // reg_q_o[19] - reg_q_o[16]  0x0010_0013 ~ 0x0010_0010
//`define  MST_U0_RD_IMP_ADR_PITCH             9'd16                                        // reg_q_o[23] - reg_q_o[20]  0x0010_0017 ~ 0x0010_0014
//`define  MST_U0_RD_IMP_HSIZE                 8'd5                                         // reg_q_o[25] - reg_q_o[24]  0x0010_0019 ~ 0x0010_0018
//`define  MST_U0_RD_IMP_VSIZE                 8'd6                                         // reg_q_o[27] - reg_q_o[26]  0x0010_001B ~ 0x0010_001A
//`define  MST_U0_RD_IMP_COOR_MINX             8'd0                                         // reg_q_o[28]                0x0010_001C
//`define  MST_U0_RD_IMP_COOR_MINY             8'd0                                         // reg_q_o[29]                0x0010_001D
//`define  MST_U0_RD_IMP_ST                                                                 // reg_q_o[30]                0x0010_001E
