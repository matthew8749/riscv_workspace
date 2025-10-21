// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ sim_ram_top.sv                                                                              //
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
`default_nettype none

module sp_ram #(
  parameter                       ADR_BIT =  6,
  parameter                       DAT_BIT = 32,
  parameter                       WEN_BIT =  1
)(
  input  wire                    clk,
  //input  wire                    rst_n,
  input  wire [WEN_BIT-1: 0]     CEN,  // like rd_en

  input  wire [WEN_BIT-1: 0]     WEN,
  input  wire [DAT_BIT-1: 0]     wr_data,

  input  wire [ADR_BIT-1: 0]     addr,

  output wire [DAT_BIT-1: 0]     rd_data
);

localparam DEPTH = (1 << ADR_BIT);     // Depth of the FIFO memory

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  reg [DAT_BIT-1:  0]     Q;
  reg [DAT_BIT-1 : 0]     reg_memory  [0 : DEPTH-1];

// tag OUTs assignment ---------------------------------------------------------------------------------------------
  assign rd_data                    = reg_memory[addr];
// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
// `ifdef VENDORRAM
// // instantiation of a vendor's dual-port RAM
// //vendor_ram mem (
// //.dout(rdata),
// //.din(wdata),
// //.waddr(waddr),
// //.raddr(raddr),
// //.wclken(wclken),
// //.wclken_n(wfull),
// //.clk(wclk));
//   RF1SHD_64x32 i_RF1SHD_64x32 (
//     .CLK ( clk      ),
//     .CEN ( CEN      ),
//     .WEN ( WEN      ),
//     .A   ( addr     ),
//     .D   ( wr_data   ),
//     .Q   ( Q        )
//   );
//   assign      rd_data            = Q;

// `else

  // RTL Verilog memory model
  always @ (posedge clk ) begin
    if( (~CEN) && (~WEN) ) begin
      reg_memory[addr] <= wr_data;
      //$display("[FIFO] Write En: addr = %0d, data = %0d", addr, wr_data);
    end
  end


// `endif




endmodule