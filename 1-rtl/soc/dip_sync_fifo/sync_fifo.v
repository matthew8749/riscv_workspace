// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ sync_fifo.v                                                                              //
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

module sync_fifo #(
  parameter   ADR_BIT    = 8,
  parameter   DAT_BIT    = 16,

  // DO NOT OVERWRITE THIS PARAMETER (number of bits for the pointer)
  parameter int unsigned DEPTH = 2**ADR_BIT
)(
  input  wire                     rst_n,        // Active low reset
  input  wire                     clk,          // Clock
  input  wire                     wr_en,        // Write enable
  input  wire                     rd_en,        // Read enable
  input  wire [DAT_BIT-1: 0]      data_in,      // Data written into FIFO
  output reg  [DAT_BIT-1: 0]      data_out,     // Data read from FIFO
  output wire                     empty,        // FIFO is empty when high
  output wire                     full,         // FIFO is full when high

  output reg                      pre_full,
  output reg                      pre_empty

);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  reg         [ ADR_BIT   : 0]    wptr;
  reg         [ ADR_BIT   : 0]    rptr;
  wire        [ ADR_BIT   : 0]    pre_wptr;
  wire        [ ADR_BIT   : 0]    pre_rptr;

  reg         [ DAT_BIT-1 : 0]    fifo [0 : DEPTH-1];
  wire        wrap_around;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
assign wrap_around = wptr[ADR_BIT] ^ rptr[ADR_BIT];
assign full        =  wrap_around && (wptr[ADR_BIT-1 :0] == rptr[ADR_BIT-1 :0]);
assign empty       = ~wrap_around && (wptr[ADR_BIT-1 :0] == rptr[ADR_BIT-1 :0]);


assign pre_wptr  = wptr + 2'd2;
assign pre_rptr  = rptr + 2'd2;
// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wptr <= 0;
    end else begin
      if (wr_en && !full) begin
        fifo[ wptr[ADR_BIT-1:0] ] <= data_in;
        wptr       <= wptr + 1;
      end
    end
  end

  always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      //data_out <= {DAT_BIT{1'b0}};
      rptr     <= 0;
    end else begin
      if (rd_en && !empty) begin
        data_out <= fifo[ rptr[ADR_BIT-1:0]];
        rptr     <= rptr + 1;
      end
    end
  end

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
     pre_full  <= 0;
     pre_empty <= 0;
  end else begin
     pre_full  <=  (pre_wptr[ADR_BIT] ^     rptr[ADR_BIT]) && (pre_wptr[ADR_BIT-1 :0] ==     rptr[ADR_BIT-1 :0]);
     pre_empty <= ~(    wptr[ADR_BIT] ^ pre_rptr[ADR_BIT]) && (    wptr[ADR_BIT-1 :0] == pre_rptr[ADR_BIT-1 :0]);
  end
end

endmodule