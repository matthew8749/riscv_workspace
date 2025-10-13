//-----------------------------------------------------------------------------
// Title         : SoC Memory Region Definitions
//-----------------------------------------------------------------------------
// File          : soc_mem_map.svh
// Author        : Manuel Eggimann  <meggimann@iis.ee.ethz.ch>
// Created       : 30.10.2020
//-----------------------------------------------------------------------------
// Description :
// This file contains start and end address definitions for the soc_interconnect.
//-----------------------------------------------------------------------------


//`define VENDORRAM
`define ASYNC_FIFO_2PRAM_WIDTH
`define ASYNC_FIFO_2PRAM_DEPTH

`define SLOW_PERIOD 20
`define FAST_PERIOD 10
/*
`define SOC_MEM_MAP_TCDM_START_ADDR          32'h1C01_0000
`define SOC_MEM_MAP_TCDM_END_ADDR            32'h1C09_0000

`define SOC_MEM_MAP_PRIVATE_BANK0_START_ADDR 32'h1C00_0000
`define SOC_MEM_MAP_PRIVATE_BANK0_END_ADDR   32'h1C00_8000
                                              //1C00 7ffC
`define SOC_MEM_MAP_PRIVATE_BANK1_START_ADDR 32'h1C00_8000
`define SOC_MEM_MAP_PRIVATE_BANK1_END_ADDR   32'h1C01_0000

`define SOC_MEM_MAP_BOOT_ROM_START_ADDR      32'h1A00_0000
`define SOC_MEM_MAP_BOOT_ROM_END_ADDR        32'h1A04_0000

`define SOC_MEM_MAP_AXI_PLUG_START_ADDR      32'h1000_0000
`define SOC_MEM_MAP_AXI_PLUG_END_ADDR        32'h1040_0000

`define SOC_MEM_MAP_PERIPHERALS_START_ADDR   32'h1A10_0000
`define SOC_MEM_MAP_PERIPHERALS_END_ADDR     32'h1A40_0000
*/

