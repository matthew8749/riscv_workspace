typedef volatile unsigned int   UV32;
typedef volatile unsigned short UV16;
typedef volatile unsigned char  UV8;

//================================================================
//   SimCtrl register and message define
//================================================================
// // u0_picorv32_axi
// #define SOC_MEM_MAP_AXI_RAM0_ID              0x0
// #define SOC_MEM_MAP_AXI_RAM0_START_ADDR      0x0000_0000
// #define SOC_MEM_MAP_AXI_RAM0_END_ADDR        0x0001_FFFF
// // u0_axi_lite_memory
// #define SOC_MEM_MAP_AXI_RAM1_ID              0x1
// #define SOC_MEM_MAP_AXI_RAM1_START_ADDR      0x0010_0000
// #define SOC_MEM_MAP_AXI_RAM1_END_ADDR        0x0011_FFFF
// // u0_axi_lite_regs
// #define SOC_MEM_MAP_AXI_REGF0_ID             0x2
// #define SOC_MEM_MAP_AXI_REGF0_START_ADDR     0x0012_0000
// #define SOC_MEM_MAP_AXI_REGF0_END_ADDR       0x0012_FFFF

//#define    SIMCTRL_ADDR_BASE                    (UV32*)0x80000000
//#define    SIMCTRL_ADDR_GENERIC                 (UV32*)0x80000000
//
//#define    SIMCTRL_MSG_SIM_START                0x00000000
//#define    SIMCTRL_MSG_FW_INITIAL               0x11111111
//#define    SIMCTRL_MSG_SIM_PASS                 0x55555555
//#define    SIMCTRL_MSG_SIM_PASSCNT              0x66666666
//#define    SIMCTRL_MSG_SIM_FAIL                 0xaaaaaaaa
//#define    SIMCTRL_MSG_SIM_FINISH               0xffffffff
//#define    SIMCTRL_MSG_SIM_RESET                0xeeeeeeee
//#define    SIMCTRL_MSG_SIM_WAIT                 0x00310031
//#define    SIMCTRL_MSG_SIM_RESUME               0x00311688
//
//#define    SIMCTRL_POST_SIM_FORCE               0x22222222
//#define    SIMCTRL_POST_SIM_RELEASE             0x33333333



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

//#define VENDORRAM
#define ASYNC_FIFO_2PRAM_WIDTH
#define ASYNC_FIFO_2PRAM_DEPTH
//#define SLOW_PERIOD 20
//#define FAST_PERIOD 10
//#define FAST_PERIOD 10
//#define FAST_PERIOD 10


//================================================================
//  SoC Memory Region Definitions
//================================================================
// u0_picorv32_axi4_rom
//#define AXIX_SLV_ROM0_ID              0x0
#define AXIX_SLV_ROM0_BASE_ADDR       0x00000000 //0x0000_0000
#define AXIX_SLV_ROM0_END_ADDR        0x000FFFFF //0x0001_FFFF
// u0_axi_lite_regs
//#define AXIX_SLV_REGF0_ID             0x1
#define AXIX_SLV_REGF0_BASE_ADDR      0x00100000 //0x0010_0000
#define AXIX_SLV_REGF0_END_ADDR       0x0010FFFF //0x0010_FFFF
// u0_axi_lite_to_apb_intf                                                                // !! ID is always the last
//#define AXIX_SLV_APB_ID               0x4                                                 // !! ID is always the last
#define AXIX_SLV_APB_BASE_ADDR        0x00110000 //0x0011_0000                            // !! ID is always the last
#define AXIX_SLV_APB_END_ADDR         0x0011FFFF //0x0011_FFFF                            // !! ID is always the last
// u0_axi_lite_memory
//#define AXIX_SLV_RAM1_ID              0x2
#define AXIX_SLV_RAM1_BASE_ADDR       0x00120000 //0x0012_0000
#define AXIX_SLV_RAM1_END_ADDR        0x0013FFFF //0x0013_FFFF
// u1_axi_lite_memory_imp
//#define AXIX_SLV_IMPI_ID              0x3
#define AXIX_SLV_IMPI_BASE_ADDR       0x40000000 //0x4000_0000
#define AXIX_SLV_IMPI_END_ADDR        0x412BFFFF //0x402B_FFFF
// u2_axi_lite_memory_imp                                                                 // !! unUSED
//#define AXIX_SLV_IMPO_ID              0x4                                                 // !! unUSED
//#define AXIX_SLV_IMPO_BASE_ADDR       0x082C0000 //0x012C_0000                            // !! unUSED
//#define AXIX_SLV_IMPO_END_ADDR        0x084BFFFF //0x014B_FFFF                            // !! unUSED

//#define    SIMCTRL_ADDR_BASE                    (UV32*)0x80000000
//#define    SIMCTRL_ADDR_GENERIC                 (UV32*)0x80000000
//
//#define    SIMCTRL_MSG_SIM_START                0x00000000
//#define    SIMCTRL_MSG_FW_INITIAL               0x11111111
//#define    SIMCTRL_MSG_SIM_PASS                 0x55555555
//#define    SIMCTRL_MSG_SIM_PASSCNT              0x66666666
//#define    SIMCTRL_MSG_SIM_FAIL                 0xaaaaaaaa
//#define    SIMCTRL_MSG_SIM_FINISH               0xffffffff
//#define    SIMCTRL_MSG_SIM_RESET                0xeeeeeeee
//#define    SIMCTRL_MSG_SIM_WAIT                 0x00310031
//#define    SIMCTRL_MSG_SIM_RESUME               0x00311688
//
//#define    SIMCTRL_POST_SIM_FORCE               0x22222222
//#define    SIMCTRL_POST_SIM_RELEASE             0x33333333
