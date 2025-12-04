// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ ModuleName.v                                                                              //
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

module axi_lite_memory #(
  parameter   ADDR_WIDTH          = 32,
  parameter   DATA_WIDTH          = 32,
  parameter   STRB_WIDTH          = 4
)(
  input  wire                     rst_n,
  input  wire                     clk,

  // AXI4-Lite slave
  // AW
  input  wire                     s_aw_valid,
  output wire                     s_aw_ready,        //
  input  wire  [ADDR_WIDTH-1: 0]  s_aw_addr,
  input  wire  [ 2: 0]            s_aw_prot,
  // W
  input  wire                     s_w_valid,
  output wire                     s_w_ready,
  input  wire  [DATA_WIDTH-1: 0]  s_w_data,
  input  wire  [STRB_WIDTH-1: 0]  s_w_strb,
  // B
  output wire                     s_b_valid,
  input  wire                     s_b_ready,
  output wire  [ 1: 0]            s_b_resp,
  // AR
  input  wire                     s_ar_valid,
  output wire                     s_ar_ready,         //
  input  wire  [ADDR_WIDTH-1: 0]  s_ar_addr,
  input  wire  [ 2: 0]            s_ar_prot,

  // R
  output wire                     s_r_valid,           //
  input  wire                     s_r_ready,
  output wire  [DATA_WIDTH-1: 0]  s_r_data,            //
  output wire  [ 1: 0]            s_r_resp
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  // constants
  wire         xt_aw_valid;
  wire         xt_w_valid;

  wire         xt_aw_w_vld;
  reg          xt_r_valid;
  wire         xt_ar_valid;
  reg  [31: 0] xt_wr_addr;
  reg  [31: 0] xt_wr_data;
  reg  [31: 0] xt_rd_addr;
  reg  [31: 0] xt_rd_data;
  reg  [31: 0] xt_r_data;
// tag OUTs assignment ---------------------------------------------------------------------------------------------
  assign s_b_valid   = 1'b1;
  assign s_b_resp    = 2'b00;

  assign s_ar_ready  = 1'b1;

  assign s_r_valid   = xt_r_valid;

  assign s_r_resp    = 2'b00;


// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
  assign xt_aw_w_vld = xt_aw_valid && xt_w_valid;

// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****

always @ (posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    xt_wr_addr <= 32'b0;
    xt_wr_data <= 32'b0;
  end else begin
    if ( s_aw_valid && s_aw_ready ) begin
      xt_wr_addr <= s_aw_addr;
    end

    if ( s_w_valid && s_w_ready ) begin
      xt_wr_data <= s_w_data;
    end

  end
end


always_ff @ (posedge clk or negedge rst_n) begin
  if ( ~rst_n) begin
    xt_r_valid <= 1'b0;
  end else begin
    xt_r_valid <= s_ar_valid;
  end
end


Xilinx_SRAM1R1W_32X32768 u0_SRAM1R1W_32X32768 (
  .clka ( clk           ),
  .ena  ( xt_aw_w_vld   ),
  .wea  ( xt_aw_w_vld   ),
  .addra( xt_wr_addr    ),
  .dina ( xt_wr_data    ),

  .clkb ( clk   ),
  .rstb ( 1'b0  ),
  .enb  ( s_ar_valid ),
  .addrb( s_ar_addr  ),
  .doutb( s_r_data   )
);

rdy_ack_handshake u0_aw_handshake (
  .rst_n      ( rst_n       ),
  .clk        ( clk         ),
  .wr_rdy     ( s_aw_valid  ),
  .wr_ack     ( s_aw_ready  ),
  .rd_rdy     ( xt_aw_valid ),
  .rd_ack     ( xt_aw_w_vld )
);

rdy_ack_handshake u0_w_handshake (
  .rst_n      ( rst_n       ),
  .clk        ( clk         ),
  .wr_rdy     ( s_w_valid   ),
  .wr_ack     ( s_w_ready   ),
  .rd_rdy     ( xt_w_valid  ),
  .rd_ack     ( xt_aw_w_vld )
);



endmodule