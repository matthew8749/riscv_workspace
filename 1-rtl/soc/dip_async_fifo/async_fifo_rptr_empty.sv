// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ async_fifo_rptr_empty.sv                                                                  //
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

module async_fifo_rptr_empty
#(
  parameter                       ADR_BIT = 4,         // PTR MSB not included
  parameter                       DAT_BIT = 32,
  parameter                       WEN_BIT = 1
)(
  input  wire                     rd_clk,
  input  wire                     rd_rst_n,

  input  wire [ADR_BIT  : 0]      sync_w2r_wptr,       // gray code
  input  wire                     rd_req,

  output wire [ADR_BIT-1: 0]      rd_addr_bin,
  output wire [ADR_BIT  : 0]      rd_ptr_gray,
  output                          rd_empty
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  //temp
  reg                             temp_rd_empty;
  reg         [ADR_BIT  : 0]      temp_addr_bin;
  reg         [ADR_BIT  : 0]      temp_ptr_gray;

  wire        [ADR_BIT  : 0]      radr_next_bin;       // to fifo memory
  wire        [ADR_BIT  : 0]      rptr_next_gray;

  wire                            rd_en;
  wire                            empty_flag;
// tag OUTs assignment ---------------------------------------------------------------------------------------------
  assign      rd_empty            = temp_rd_empty;
  assign      rd_addr_bin         = temp_addr_bin[ADR_BIT-1:0];    // without MSB
  assign      rd_ptr_gray         = temp_ptr_gray;

// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
  assign      rd_en               = (rd_req && ~temp_rd_empty);

  // binary 計數與 gray code 計算
  assign      radr_next_bin       = (rd_en) ? temp_addr_bin + 1'b1 : temp_addr_bin;
  assign      rptr_next_gray      = (radr_next_bin>>1) ^ radr_next_bin;

  // Empty condition: read pointer (next) == synchronized write pointer
  assign      empty_flag          = (rptr_next_gray == sync_w2r_wptr);

// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
always @ (posedge rd_clk or negedge rd_rst_n) begin
  if (!rd_rst_n) begin
  	temp_addr_bin  <= 'b0;
    temp_ptr_gray  <= 'b0;
  end else begin
    temp_addr_bin  <= radr_next_bin;
    temp_ptr_gray  <= rptr_next_gray;
  end
end

// FIFO empty when the (next rptr == synchronized wptr) or on reset
always @ (posedge rd_clk or negedge rd_rst_n) begin
  if (!rd_rst_n) begin
  	temp_rd_empty <= 1'b0;
  end else begin
    temp_rd_empty <= empty_flag;

  end
end



endmodule