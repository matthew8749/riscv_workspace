// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ axi4_memory_warpper.v                                                                              //
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

module axi4_memory_warpper
#(
  parameter   AAA                 = 2,
  parameter   BBB                 = 5
)(
  input  wire                     hresetn,
  input  wire                     hclk,

  input  wire                     hready,
  input  wire [ 1: 0]             hresp,
  input  wire [31: 0]             hrdata,

  output wire [ 1: 0]             htrans,
  output wire [ 2: 0]             hburst,
  output wire [ 2: 0]             hsize,
  output wire                     hwrite,
  output wire [31: 0]             haddr,
  output wire [31: 0]             hwdata
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

always @ (posedge XCLK or negedge RstN) begin
  if (!RstN) begin
  end else begin

  end
end

  assign slave[0].b_resp = 2'b00;
  assign slave[0].r_resp = 2'b00;
axi4_memory #(
  .AXI_TEST                       ( AXI_TEST          ),
  .VERBOSE                        ( VERBOSE           )
) u0_pulp_axi4_mem (
  .clk                            ( clk               ),
  .mem_axi_awvalid                ( slave[0].aw_valid ),  // i
  .mem_axi_awready                ( slave[0].aw_ready ),  // o
  .mem_axi_awaddr                 ( slave[0].aw_addr  ),  // i
  .mem_axi_awprot                 ( slave[0].aw_prot  ),  // i
  .mem_axi_wvalid                 ( slave[0].w_valid  ),  // i
  .mem_axi_wready                 ( slave[0].w_ready  ),  // o
  .mem_axi_wdata                  ( slave[0].w_data   ),  // i
  .mem_axi_wstrb                  ( slave[0].w_strb   ),  // i
  .mem_axi_bvalid                 ( slave[0].b_valid  ),  // o
  .mem_axi_bready                 ( slave[0].b_ready  ),  // i
  //                                slave[0].b_resp       // o   //assign
  .mem_axi_arvalid                ( slave[0].ar_valid ),  // i
  .mem_axi_arready                ( slave[0].ar_ready ),  // o
  .mem_axi_araddr                 ( slave[0].ar_addr  ),  // i
  .mem_axi_arprot                 ( slave[0].ar_prot  ),  // i
  .mem_axi_rvalid                 ( slave[0].r_valid  ),  // o
  .mem_axi_rready                 ( slave[0].r_ready  ),  // i
  .mem_axi_rdata                  ( slave[0].r_data   ),  // o
  //                                slave[0].r_resp       // o   //assign
  .tests_passed                   ( tests_passed      )   // o
);




endmodule