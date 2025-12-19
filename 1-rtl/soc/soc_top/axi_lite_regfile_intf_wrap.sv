// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ axi_lite_reg_intf_wrap.sv                                                                 //
// Creator ____________ Yan, Wei-Ting                                                                             //
// Built Date _________ NOV-26-2025                                                                               //
// Function ___________                                                                                           //
// Hierarchy __________                                                                                           //
//   Parent ___________                                                                                           //
//   Children _________                                                                                           //
// Revision history ___ Date        Author            Description                                                 //
//                  ___                                                                                           //
// -FHDR--------------------------------------------------------------------------------------------------------- //
//+...........+...................+.............................................................................. //
//3...........15..................35............................................................................. //
`timescale 1ns/10ps
`include "axi/typedef.svh"
`include "axi/assign.svh"
`include "include/Global_define.svh"

module axi_lite_reg_intf_wrap #(

  parameter int unsigned REG_NUM_BYTE   = 32'd100,     // Define the parameter `RegNumBytes` of the DUT.
  parameter int unsigned AXI_ADDR_WIDTH = 32'd32,      // Same as axi configurationS
  parameter int unsigned AXI_DATA_WIDTH = 32'd32,      // Same as axi configurationS
  parameter type  byte_t                = logic [7:0]  // DEPENDENT PARAMERETS, DO NOT OVERWRITE!
)(
  input  wire                       rst_n,
  input  wire                       clk,
  //output byte_t [REG_NUM_BYTE-1:0]  reg_q_rdat,
  AXI_LITE.Slave                    slv,

  output logic  [ 7 : 0]            MST_U0_WR_IMP_HSIZE,
  output logic  [ 7 : 0]            MST_U0_RD_IMP_HSIZE,
  output logic  [ 7 : 0]            MST_U0_WR_IMP_COOR_MINX,
  output logic  [ 7 : 0]            MST_U0_RD_IMP_COOR_MINX,
  output logic  [ 7 : 0]            MST_U0_WR_IMP_VSIZE,
  output logic  [ 7 : 0]            MST_U0_RD_IMP_VSIZE,
  output logic  [ 7 : 0]            MST_U0_WR_IMP_COOR_MINY,
  output logic  [ 7 : 0]            MST_U0_RD_IMP_COOR_MINY,
  output logic  [31 : 0]            MST_U0_WR_IMP_ADR_PITCH,
  output logic  [31 : 0]            MST_U0_RD_IMP_ADR_PITCH,
  output logic  [31 : 0]            MST_U0_WR_IMP_DST_BADDR,
  output logic  [31 : 0]            MST_U0_RD_IMP_SRC_BADDR,
  output logic                      MST_U0_WR_IMP_ST,
  output logic                      MST_U0_RD_IMP_ST
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  typedef     logic [AXI_ADDR_WIDTH-1:0] axi_addr_t;

  localparam logic [REG_NUM_BYTE-1:0] TbAxiReadOnly  = {{REG_NUM_BYTE-18{1'b0}}, 18'b0};  /// Define the parameter `AxiReadOnly` of the DUT.
  localparam bit                      TbPrivProtOnly = 1'b0;  //Define the parameter `PrivProtOnly` of the DUT.
  localparam bit                      TbSecuProtOnly = 1'b0;  //Define the parameter `SecuProtOnly` of the DUT.

  localparam  axi_addr_t StartAddr = `SOC_MEM_MAP_AXI_REGF0_START_ADDR;
  localparam  axi_addr_t EndAddr   =  axi_addr_t'(StartAddr + REG_NUM_BYTE + REG_NUM_BYTE/5);

  localparam  byte_t [REG_NUM_BYTE-1:0] RegRstVal  = '0;
  localparam  PITCH_SIZE                           = 9;

  byte_t      [REG_NUM_BYTE-1:0]  reg_q_o;
// tag OUTs assignment ---------------------------------------------------------------------------------------------
// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
  assign MST_U0_WR_IMP_DST_BADDR  = {reg_q_o[3],  reg_q_o[2],  reg_q_o[1],  reg_q_o[0] }; //32'b0  0x0012_0003 ~ 0x0012_0000
  assign MST_U0_WR_IMP_ADR_PITCH  = {reg_q_o[7],  reg_q_o[6],  reg_q_o[5],  reg_q_o[4] }; //9'd16  0x0012_0007 ~ 0x0012_0004
  assign MST_U0_WR_IMP_HSIZE      =  reg_q_o[8];                                                   //8'd4   0x0012_0008
  assign MST_U0_WR_IMP_VSIZE      =  reg_q_o[9];                                                   //8'd6   0x0012_0009
  assign MST_U0_WR_IMP_COOR_MINX  =  reg_q_o[10];                                                  //8'd0   0x0012_000A
  assign MST_U0_WR_IMP_COOR_MINY  =  reg_q_o[11];                                                  //8'd0   0x0012_000B
  assign MST_U0_WR_IMP_ST         =  reg_q_o[12];                                                  //       0x0012_000C

  assign MST_U0_RD_IMP_SRC_BADDR  = {reg_q_o[19], reg_q_o[18], reg_q_o[17], reg_q_o[16]}; //32'b0  0x0012_0013 ~ 0x0012_0010
  assign MST_U0_RD_IMP_ADR_PITCH  = {reg_q_o[23], reg_q_o[22], reg_q_o[21], reg_q_o[20]}; //9'd16  0x0012_0017 ~ 0x0012_0014
  assign MST_U0_RD_IMP_HSIZE      =  reg_q_o[24];                                                  //8'd4   0x0012_0018
  assign MST_U0_RD_IMP_VSIZE      =  reg_q_o[25];                                                  //8'd6   0x0012_0019
  assign MST_U0_RD_IMP_COOR_MINX  =  reg_q_o[26];                                                  //8'd0   0x0012_001A
  assign MST_U0_RD_IMP_COOR_MINY  =  reg_q_o[27];                                                  //8'd0   0x0012_001B
  assign MST_U0_RD_IMP_ST         =  reg_q_o[28];                                                  //       0x0012_001C
// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
// // Register logic.
//   assign reg_q_rdat[0]  = reg_q_o[0];               // MST_U0_WR_IMP_DST_BADDR[  7:  0]   // 0x0012_0000
//   assign reg_q_rdat[1]  = reg_q_o[1];               // MST_U0_WR_IMP_DST_BADDR[ 15:  8]   // 0x0012_0001
//   assign reg_q_rdat[2]  = reg_q_o[2];               // MST_U0_WR_IMP_DST_BADDR[ 23: 16]   // 0x0012_0002
//   assign reg_q_rdat[3]  = reg_q_o[3];               // MST_U0_WR_IMP_DST_BADDR[ 31: 24]   // 0x0012_0003
//   assign reg_q_rdat[4]  = reg_q_o[4];               // MST_U0_WR_IMP_ADR_PITCH[  7:  0]   // 0x0012_0004
//   assign reg_q_rdat[5]  = reg_q_o[5];               // MST_U0_WR_IMP_ADR_PITCH[ 15:  8]   // 0x0012_0005
//   assign reg_q_rdat[6]  = reg_q_o[6];               // MST_U0_WR_IMP_ADR_PITCH[ 23: 16]   // 0x0012_0006
//   assign reg_q_rdat[7]  = reg_q_o[7];               // MST_U0_WR_IMP_ADR_PITCH[ 31: 24]   // 0x0012_0007
//   assign reg_q_rdat[8]  = reg_q_o[8];               // MST_U0_WR_IMP_HSIZE                // 0x0012_0008
//   assign reg_q_rdat[9]  = reg_q_o[9];               // MST_U0_WR_IMP_VSIZE                // 0x0012_0009
//   assign reg_q_rdat[10] = reg_q_o[10];              // MST_U0_WR_IMP_COOR_MINX            // 0x0012_000A
//   assign reg_q_rdat[11] = reg_q_o[11];              // MST_U0_WR_IMP_COOR_MINY            // 0x0012_000B
//   assign reg_q_rdat[12] = reg_q_o[12];              // MST_U0_WR_IMP_ST                   // 0x0012_000C
//   assign reg_q_rdat[13] = reg_q_o[13];              //                                    // 0x0012_000D
//   assign reg_q_rdat[14] = reg_q_o[14];              //                                    // 0x0012_000E
//   assign reg_q_rdat[15] = reg_q_o[15];              //                                    // 0x0012_000F

//   assign reg_q_rdat[16] = reg_q_o[16];              // MST_U0_RD_IMP_SRC_BADDR[  7:  0]   // 0x0012_0010
//   assign reg_q_rdat[17] = reg_q_o[17];              // MST_U0_RD_IMP_SRC_BADDR[ 15:  8]   // 0x0012_0011
//   assign reg_q_rdat[18] = reg_q_o[18];              // MST_U0_RD_IMP_SRC_BADDR[ 23: 16]   // 0x0012_0012
//   assign reg_q_rdat[19] = reg_q_o[19];              // MST_U0_RD_IMP_SRC_BADDR[ 31: 24]   // 0x0012_0013
//   assign reg_q_rdat[20] = reg_q_o[20];              // MST_U0_RD_IMP_ADR_PITCH[  7:  0]   // 0x0012_0014
//   assign reg_q_rdat[21] = reg_q_o[21];              // MST_U0_RD_IMP_ADR_PITCH[ 15:  8]   // 0x0012_0015
//   assign reg_q_rdat[22] = reg_q_o[22];              // MST_U0_RD_IMP_ADR_PITCH[ 23: 16]   // 0x0012_0016
//   assign reg_q_rdat[23] = reg_q_o[23];              // MST_U0_RD_IMP_ADR_PITCH[ 31: 24]   // 0x0012_0017
//   assign reg_q_rdat[24] = reg_q_o[24];              // MST_U0_RD_IMP_HSIZE                // 0x0012_0018
//   assign reg_q_rdat[25] = reg_q_o[25];              // MST_U0_RD_IMP_VSIZE                // 0x0012_0019
//   assign reg_q_rdat[26] = reg_q_o[26];              // MST_U0_RD_IMP_COOR_MINX            // 0x0012_001A
//   assign reg_q_rdat[27] = reg_q_o[27];              // MST_U0_RD_IMP_COOR_MINY            // 0x0012_001B
//   assign reg_q_rdat[28] = reg_q_o[28];              // MST_U0_RD_IMP_ST                   // 0x0012_001C
//   assign reg_q_rdat[29] = reg_q_o[29];              //                                    // 0x0012_001D
//   assign reg_q_rdat[30] = reg_q_o[30];              //                                    // 0x0012_001E
//   assign reg_q_rdat[31] = reg_q_o[31];              //                                    // 0x0012_001F
//   for (genvar reg_i = 32; reg_i < REG_NUM_BYTE; reg_i++) begin
//     assign reg_q_rdat[reg_i] = reg_q_o[reg_i];
//   end


axi_lite_regfile_intf #(
  .REG_NUM_BYTES                  ( REG_NUM_BYTE   ),
  .AXI_ADDR_WIDTH                 ( AXI_ADDR_WIDTH ),
  .AXI_DATA_WIDTH                 ( AXI_DATA_WIDTH ),
  .PRIV_PROT_ONLY                 ( TbPrivProtOnly ),
  .SECU_PROT_ONLY                 ( TbSecuProtOnly ),
  .AXI_READ_ONLY                  ( TbAxiReadOnly  ),
  .REG_RST_VAL                    ( RegRstVal      )
) u0_axi_lite_regfile (
  .rst_ni                         ( rst_n     ),
  .clk_i                          ( clk       ),
  .slv                            ( slv  ),
  .wr_active_o                    ( /*wr_active*/ ),
  .rd_active_o                    ( /*rd_active*/ ),
  .reg_d_i                        ( {REG_NUM_BYTE{8'h00}}/*reg_d*/     ),
  .reg_load_i                     ( {REG_NUM_BYTE{8'h00}}/*reg_load*/  ),
  .reg_q_o                        ( reg_q_o     )
);

endmodule