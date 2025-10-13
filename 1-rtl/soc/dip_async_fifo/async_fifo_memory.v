// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ async_fifo_memory.sv                                                                      //
// Creator ____________ Yan, Wei-Ting                                                                             //
// Built Date _________ MMM-DD-YYYY                                                                               //
// Function ___________                                                                                           //
// Hierarchy __________                                                                                           //
//   Parent ___________                                                                                           //
//   Children _________                                                                                           //
// Revision history ___ Date        Author            Description                                                 //
//                  ___                                                                                           //
//                      This modules contains the buffer or the moeory of the FIFO,                               //
//                      which has both the clocks. This is a dual port RAM.                                       //
//                      這是FIFO記憶體緩衝區，可透過寫入和讀取時脈域進行存取                                            //
//                      此緩衝區很可能是實例化的"同步雙埠RAM".  可以修改其他記憶體樣式以用作FIFO緩衝區.                   //
// -FHDR--------------------------------------------------------------------------------------------------------- //
//+...........+...................+.............................................................................. //
//3...........15..................35............................................................................. //
`timescale 1ns/10ps

module async_fifo_memory
#(
  parameter                       ADR_BIT = 4,
  parameter                       DAT_BIT = 32,
  parameter                       WEN_BIT =  1
)(
  input  wire                     wr_clk,
  input  wire                     rd_clk,
  input  wire                     rst_n,

  //write
  input  wire [WEN_BIT-1 : 0]     wr_en,
  input  wire [ADR_BIT-1 : 0 ]    wr_addr,
  input  wire [DAT_BIT-1 : 0]     wr_data,

  //read
  input  wire [WEN_BIT-1 : 0]     rd_en,
  input  wire [ADR_BIT-1 : 0 ]    rd_addr,
  output wire [DAT_BIT-1 : 0]     rd_data
);

localparam DEPTH = (1 << ADR_BIT);     // Depth of the FIFO memory
// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  logic       [DAT_BIT-1 : 0]     reg_memory  [0 : DEPTH-1];
  logic       [DAT_BIT-1 : 0]     delay_wr_data;


// tag OUTs assignment ---------------------------------------------------------------------------------------------


// tag INs assignment ----------------------------------------------------------------------------------------------

// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****

`ifdef VENDORRAM
// instantiation of a vendor's dual-port RAM
//vendor_ram mem (
//.dout(rdata),
//.din(wdata),
//.waddr(waddr),
//.raddr(raddr),
//.wclken(wclken),
//.wclken_n(wfull),
//.clk(wclk));
`else

// RTL Verilog memory model

//always @ (posedge wr_clk or negedge rst_n) begin
//  if (~rst_n) begin
//    delay_wr_data <= 'b0;
//  end else begin
//    delay_wr_data <= wr_data;
//  end
//end
assign rd_data                    = reg_memory[rd_addr];

always @ (posedge wr_clk ) begin
  if(wr_en) begin
    reg_memory[wr_addr] <= wr_data;
    $display("[FIFO] Write En: addr = %0d, data = %0d", wr_addr, wr_data);
  end
end


`endif

endmodule