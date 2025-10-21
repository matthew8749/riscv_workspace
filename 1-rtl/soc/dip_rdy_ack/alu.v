// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ alu.v                                                                                     //
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

module  alu (
  input  wire                     rst_n,
  input  wire                     clk,

  input  wire   [ 7: 0]           val_a,
  input  wire   [ 7: 0]           val_b,
  input  wire   [ 7: 0]           val_c,
  input  wire                     alu_wr_rdy,           // 我已準備好接資料
  output wire                     alu_wr_ack,           // 回復"確認收到資料" (one-cycle pulse)

  input  wire                     alu_rd_ack,           // 接收"確認收到資料" (one-cycle pulse)
  output reg                      alu_rd_rdy,           // 下游準備好收資料

  output wire   [16: 0]           alu_result
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  reg [15: 0] xt_mul_ab;
  reg [16: 0] xt_add_ab_c;
  reg [7 : 0] xt_c_1t;

  wire        rd_rdy_mul;
  wire        wr_ack_add;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
  assign  alu_result = xt_add_ab_c;

// tag INs assignment ----------------------------------------------------------------------------------------------

// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------

// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------

// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
rdy_ack_handshake u_rdy_ack_mul (.wr_rdy(alu_wr_rdy), .wr_ack(alu_wr_ack),   .rd_rdy(rd_rdy_mul), .rd_ack(wr_ack_add), .rst_n(rst_n), .clk(clk));
rdy_ack_handshake u_rdy_ack_add (.wr_rdy(rd_rdy_mul), .wr_ack(wr_ack_add),   .rd_rdy(alu_rd_rdy), .rd_ack(alu_rd_ack), .rst_n(rst_n), .clk(clk));


always @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    xt_mul_ab <= 16'b0;
    xt_c_1t   <= 8'b0;
  end else begin
    if ( alu_wr_ack ) begin
      xt_mul_ab <= val_a * val_b;
      xt_c_1t   <= val_c;
    end

  end
end

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    xt_add_ab_c <= 17'b0;
  end else begin
    if ( wr_ack_add ) begin
      xt_add_ab_c <= xt_mul_ab + xt_c_1t;
    end

  end
end



endmodule