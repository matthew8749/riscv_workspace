// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ mst_imp_wrapper.v                                                                              //
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

module mst_imp_wrapper
#(
  parameter int unsigned REG_NUM_BYTES  = 100,
  parameter int unsigned AXI_ADDR_WIDTH = 32'd32,
  parameter int unsigned AXI_DATA_WIDTH = 32'd32,
  parameter              PITCH_WIDTH    = 9,
  parameter type  byte_t                = logic [7:0]  // DEPENDENT PARAMERETS, DO NOT OVERWRITE!
)(
  input  wire                       rst_n,
  input  wire                       clk,
  input  byte_t [REG_NUM_BYTES-1:0] reg_q_rdat, // from Register File Wrapper Config.
  AXI_LITE.Master                   mst_imp     // AXI Master Interface
);


// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  logic       [ 7 : 0]            MST_U0_WR_IMP_HSIZE     , MST_U0_RD_IMP_HSIZE;
  logic       [ 7 : 0]            MST_U0_WR_IMP_COOR_MINX , MST_U0_RD_IMP_COOR_MINX;
  logic       [ 7 : 0]            MST_U0_WR_IMP_VSIZE     , MST_U0_RD_IMP_VSIZE;
  logic       [ 7 : 0]            MST_U0_WR_IMP_COOR_MINY , MST_U0_RD_IMP_COOR_MINY;
  logic       [31 : 0]            MST_U0_WR_IMP_ADR_PITCH , MST_U0_RD_IMP_ADR_PITCH;
  logic       [31 : 0]            MST_U0_WR_IMP_DST_BADDR ;
  logic       [31 : 0]            MST_U0_RD_IMP_SRC_BADDR ;
  logic                           MST_U0_WR_IMP_ST        , MST_U0_RD_IMP_ST;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
assign MST_U0_WR_IMP_DST_BADDR  = {reg_q_rdat[3],  reg_q_rdat[2],  reg_q_rdat[1],  reg_q_rdat[0] }; //32'b0  0x0012_0003 ~ 0x0012_0000
assign MST_U0_WR_IMP_ADR_PITCH  = {reg_q_rdat[7],  reg_q_rdat[6],  reg_q_rdat[5],  reg_q_rdat[4] } & { {(32-PITCH_WIDTH){1'b0}} ,{PITCH_WIDTH{1'b1}} };
                                                                                                      //9'd16  0x0012_0007 ~ 0x0012_0004
assign MST_U0_WR_IMP_HSIZE      =  reg_q_rdat[8];                                                   //8'd4   0x0012_0008
assign MST_U0_WR_IMP_VSIZE      =  reg_q_rdat[9];                                                   //8'd6   0x0012_0009
assign MST_U0_WR_IMP_COOR_MINX  =  reg_q_rdat[10];                                                  //8'd0   0x0012_000A
assign MST_U0_WR_IMP_COOR_MINY  =  reg_q_rdat[11];                                                  //8'd0   0x0012_000B
assign MST_U0_WR_IMP_ST         =  reg_q_rdat[12];                                                  //       0x0012_000C

assign MST_U0_RD_IMP_SRC_BADDR  = {reg_q_rdat[19], reg_q_rdat[18], reg_q_rdat[17], reg_q_rdat[16]}; //32'b0  0x0012_0013 ~ 0x0012_0010
assign MST_U0_RD_IMP_ADR_PITCH  = {reg_q_rdat[23], reg_q_rdat[22], reg_q_rdat[21], reg_q_rdat[20]} & { {(32-PITCH_WIDTH){1'b0}} ,{PITCH_WIDTH{1'b1}} };
                                                                                                      //9'd16  0x0012_0017 ~ 0x0012_0014
assign MST_U0_RD_IMP_HSIZE      =  reg_q_rdat[24];                                                  //8'd4   0x0012_0018
assign MST_U0_RD_IMP_VSIZE      =  reg_q_rdat[25];                                                  //8'd6   0x0012_0019
assign MST_U0_RD_IMP_COOR_MINX  =  reg_q_rdat[26];                                                  //8'd0   0x0012_001A
assign MST_U0_RD_IMP_COOR_MINY  =  reg_q_rdat[27];                                                  //8'd0   0x0012_001B
assign MST_U0_RD_IMP_ST         =  reg_q_rdat[28];                                                  //       0x0012_001C

// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****

mst_imp_r_ch u0_mst_imp_r_ch (
  .rst_n                          ( rst_n                   ),
  .clk                            ( clk                     ),
  .mem_axi_arvalid                ( mst_imp.ar_valid      ),
  .mem_axi_arready                ( mst_imp.ar_ready      ),
  .mem_axi_araddr                 ( mst_imp.ar_addr       ),
  .mem_axi_arprot                 ( mst_imp.ar_prot       ),
  .mem_axi_rvalid                 ( mst_imp.r_valid       ),
  .mem_axi_rready                 ( mst_imp.r_ready       ),
  .mem_axi_rdata                  ( mst_imp.r_data        ),
  .IMP_HSIZE                      ( MST_U0_RD_IMP_HSIZE     ), //8'd4
  .IMP_VSIZE                      ( MST_U0_RD_IMP_VSIZE     ), //8'd6
  .IMP_COOR_MINX                  ( MST_U0_RD_IMP_COOR_MINX ), //8'd0
  .IMP_COOR_MINY                  ( MST_U0_RD_IMP_COOR_MINY ), //8'd0
  .IMP_SRC_BADDR                  ( MST_U0_RD_IMP_SRC_BADDR ), // 32'h0010_0000
  .IMP_ADR_PITCH                  ( MST_U0_RD_IMP_ADR_PITCH ),
  .IMP_ST                         ( MST_U0_RD_IMP_ST        )
);

mst_imp_w_ch u0_mst_imp_w_ch (
  .rst_n                          ( rst_n                   ),
  .clk                            ( clk                     ),
  .mem_axi_awvalid                ( mst_imp.aw_valid      ),
  .mem_axi_awready                ( mst_imp.aw_ready      ),
  .mem_axi_awaddr                 ( mst_imp.aw_addr       ),
  .mem_axi_awprot                 ( mst_imp.aw_prot       ),
  .mem_axi_wvalid                 ( mst_imp.w_valid       ),
  .mem_axi_wready                 ( mst_imp.w_ready       ),
  .mem_axi_wdata                  ( mst_imp.w_data        ),
  .mem_axi_wstrb                  ( mst_imp.w_strb        ),
  .mem_axi_bresp                  ( mst_imp.b_resp        ),
  .mem_axi_bvalid                 ( mst_imp.b_valid       ),
  .mem_axi_bready                 ( mst_imp.b_ready       ),
  .IMP_HSIZE                      ( MST_U0_WR_IMP_HSIZE     ),
  .IMP_VSIZE                      ( MST_U0_WR_IMP_VSIZE     ),
  .IMP_COOR_MINX                  ( MST_U0_WR_IMP_COOR_MINX ),
  .IMP_COOR_MINY                  ( MST_U0_WR_IMP_COOR_MINY ),
  .IMP_DST_BADDR                  ( MST_U0_WR_IMP_DST_BADDR ),
  .IMP_ADR_PITCH                  ( MST_U0_WR_IMP_ADR_PITCH ),
  .IMP_ST                         ( MST_U0_WR_IMP_ST        )
);




endmodule