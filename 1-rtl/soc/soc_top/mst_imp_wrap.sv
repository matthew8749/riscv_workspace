// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ mst_imp_wrap.v                                                                              //
// Creator ____________ Yan, Wei-Ting                                                                             //
// Built Date _________ MMM-DD-YYYY                                                                               //
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

module mst_imp_wrap
#(
  parameter int unsigned REG_NUM_BYTES  = 100,
  parameter int unsigned AXI_ADDR_WIDTH = 32'd32,
  parameter int unsigned AXI_DATA_WIDTH = 32'd32,
  //parameter              PITCH_WIDTH    = 9,
  parameter type  byte_t                = logic [7:0]  // DEPENDENT PARAMERETS, DO NOT OVERWRITE!
)(
  input  wire                           rst_n_IMP,
  input  wire                           clk_IMP,
  AXI_LITE.Master                       mst_imp,     // AXI Master Interface

  input logic       [15 : 0]            MST_U0_WR_IMP_HSIZE,
  input logic       [15 : 0]            MST_U0_RD_IMP_HSIZE,
  input logic       [ 7 : 0]            MST_U0_WR_IMP_COOR_MINX,
  input logic       [ 7 : 0]            MST_U0_RD_IMP_COOR_MINX,
  input logic       [15 : 0]            MST_U0_WR_IMP_VSIZE,
  input logic       [15 : 0]            MST_U0_RD_IMP_VSIZE,
  input logic       [ 7 : 0]            MST_U0_WR_IMP_COOR_MINY,
  input logic       [ 7 : 0]            MST_U0_RD_IMP_COOR_MINY,
  input logic       [31 : 0]            MST_U0_WR_IMP_ADR_PITCH,
  input logic       [31 : 0]            MST_U0_RD_IMP_ADR_PITCH,
  input logic       [31 : 0]            MST_U0_WR_IMP_DST_BADDR,
  input logic       [31 : 0]            MST_U0_RD_IMP_SRC_BADDR,
  input logic                           MST_U0_WR_IMP_ST,
  input logic                           MST_U0_RD_IMP_ST

);
// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
// tag OUTs assignment ---------------------------------------------------------------------------------------------
// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****

mst_imp_r_ch u0_mst_imp_r_ch (
  .rst_n_IMP                      ( rst_n_IMP               ),
  .clk_IMP                        ( clk_IMP                 ),
  .mem_axi_arvalid                ( mst_imp.ar_valid        ),
  .mem_axi_arready                ( mst_imp.ar_ready        ),
  .mem_axi_araddr                 ( mst_imp.ar_addr         ),
  .mem_axi_arprot                 ( mst_imp.ar_prot         ),
  .mem_axi_rvalid                 ( mst_imp.r_valid         ),
  .mem_axi_rready                 ( mst_imp.r_ready         ),
  .mem_axi_rdata                  ( mst_imp.r_data          ),
  .IMP_HSIZE                      ( MST_U0_RD_IMP_HSIZE     ), //16'd4
  .IMP_VSIZE                      ( MST_U0_RD_IMP_VSIZE     ), //16'd6
  .IMP_COOR_MINX                  ( MST_U0_RD_IMP_COOR_MINX ), //8'd0
  .IMP_COOR_MINY                  ( MST_U0_RD_IMP_COOR_MINY ), //8'd0
  .IMP_SRC_BADDR                  ( MST_U0_RD_IMP_SRC_BADDR ), // 32'h0010_0000
  .IMP_ADR_PITCH                  ( MST_U0_RD_IMP_ADR_PITCH ),
  .IMP_ST                         ( MST_U0_RD_IMP_ST        )
);

mst_imp_w_ch u0_mst_imp_w_ch (
  .rst_n_IMP                      ( rst_n_IMP               ),
  .clk_IMP                        ( clk_IMP                 ),
  .mem_axi_awvalid                ( mst_imp.aw_valid        ),
  .mem_axi_awready                ( mst_imp.aw_ready        ),
  .mem_axi_awaddr                 ( mst_imp.aw_addr         ),
  .mem_axi_awprot                 ( mst_imp.aw_prot         ),
  .mem_axi_wvalid                 ( mst_imp.w_valid         ),
  .mem_axi_wready                 ( mst_imp.w_ready         ),
  .mem_axi_wdata                  ( mst_imp.w_data          ),
  .mem_axi_wstrb                  ( mst_imp.w_strb          ),
  .mem_axi_bresp                  ( mst_imp.b_resp          ),
  .mem_axi_bvalid                 ( mst_imp.b_valid         ),
  .mem_axi_bready                 ( mst_imp.b_ready         ),
  .IMP_HSIZE                      ( MST_U0_WR_IMP_HSIZE     ),
  .IMP_VSIZE                      ( MST_U0_WR_IMP_VSIZE     ),
  .IMP_COOR_MINX                  ( MST_U0_WR_IMP_COOR_MINX ),
  .IMP_COOR_MINY                  ( MST_U0_WR_IMP_COOR_MINY ),
  .IMP_DST_BADDR                  ( MST_U0_WR_IMP_DST_BADDR ),
  .IMP_ADR_PITCH                  ( MST_U0_WR_IMP_ADR_PITCH ),
  .IMP_ST                         ( MST_U0_WR_IMP_ST        )
);




endmodule