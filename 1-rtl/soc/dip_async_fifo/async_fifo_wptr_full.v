// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ asyn_fifo_wptr_full.sv                                                                    //
// Creator ____________ Yan, Wei-Ting                                                                             //
// Built Date _________ MMM-DD-YYYY                                                                               //
// Function ___________                                                                                           //
// Hierarchy __________                                                                                           //
//   Parent ___________                                                                                           //
//   Children _________                                                                                           //
// Revision history ___ Date        Author            Description                                                 //
//                  ___                               負責計算寫入指標(binary & gray)                               //
//                                                    決定是否寫入                                                 //
//                                                    以及偵測 FIFO 是否滿了                                        //
// -FHDR--------------------------------------------------------------------------------------------------------- //
//+...........+...................+.............................................................................. //
//3...........15..................35............................................................................. //
`timescale 1ns/10ps

module asyn_fifo_wptr_full
#(
  parameter                       ADR_BIT = 4,        // PTR MSB not included
  parameter                       DAT_BIT = 32,
  parameter                       WEN_BIT = 1
)(
  input  wire                     wr_clk,
  input  wire                     wr_rst_n,

  input  wire [ADR_BIT   : 0]     sync_r2w_rptr,
  input  wire                     wr_req,

  output wire [ADR_BIT-1 : 0]     wr_addr_bin,
  output wire [ADR_BIT   : 0]     wr_ptr_gray,
  output                          wr_full
);
// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  //temp
  reg                             temp_wr_full;
  reg         [ADR_BIT  : 0]      temp_wr_addr;
  reg         [ADR_BIT  : 0]      temp_wr_ptr;

  wire        [ADR_BIT  : 0]      wadr_next_bin;    // to fifo memory
  wire        [ADR_BIT  : 0]      wptr_next_gray;

  wire                            wr_en;
  wire                            full_flag;
// tag OUTs assignment ---------------------------------------------------------------------------------------------
  assign      wr_full             = temp_wr_full;
  assign      wr_addr_bin         = temp_wr_addr[ADR_BIT-1:0];    // without MSB
  assign      wr_ptr_gray         = temp_wr_ptr;

// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
  assign      wr_en               = (wr_req && ~temp_wr_full);

  // binary 計數與 gray code 計算
  assign      wadr_next_bin       = (wr_en) ? temp_wr_addr + 1'b1 : temp_wr_addr;
  assign      wptr_next_gray      = (wadr_next_bin>>1) ^ wadr_next_bin;


  // Full condition: write pointer (next) == inverted MSBs + rest of synchronized read pointer
  assign      full_flag           = (wptr_next_gray == {(~sync_r2w_rptr[ADR_BIT : ADR_BIT-1] ) , sync_r2w_rptr[ADR_BIT-2 : 0]} );

// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
always @ (posedge wr_clk or negedge wr_rst_n) begin
  if (!wr_rst_n) begin
  	temp_wr_addr  <= 'b0;
    temp_wr_ptr   <= 'b0;
  end else begin
    temp_wr_addr  <= wadr_next_bin;
    temp_wr_ptr   <= wptr_next_gray;

  end
end

//write full
always @ (posedge wr_clk or negedge wr_rst_n) begin
  if (!wr_rst_n) begin
  	temp_wr_full <= 1'b0;
  end else begin
    temp_wr_full <= full_flag;

  end
end

endmodule