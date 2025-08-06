// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ async_fifo.sv                                                                             //
// Creator ____________ Yan, Wei-Ting                                                                             //
// Built Date _________ MMM-DD-YYYY                                                                               //
// Function ___________ Top-level module for asynchronous FIFO with separated read/write clocks.                  //
// Hierarchy __________                                                                                           //
//   Parent ___________                                                                                           //
//   Children _________ async_fifo_mem, async_fifo_wptr_ctrl, async_fifo_rptr_ctrl, sync_r2w_rptr, sync_w2r_wptr  //
// Revision history ___ Date        Author            Description                                                 //
//                  ___                                                                                           //
// -FHDR--------------------------------------------------------------------------------------------------------- //
//+...........+...................+.............................................................................. //
//3...........15..................35............................................................................. //
`timescale 1ns/10ps

module async_fifo
#(
  parameter                       ADR_BIT = 4,
  parameter                       DAT_BIT = 32,
  parameter                       WEN_BIT =  1
)(
  // Write Clock Domain
  input  wire                     wr_clk,
  input  wire                     wr_rst_n,
  input  wire                     wr_req,
  input  wire [DAT_BIT-1 : 0]     wr_data,
  // Read Clock Domain
  input  wire                     rd_clk,
  input  wire                     rd_rst_n,
  input  wire                     rd_req,
  // Output
  output wire                     wr_full,
  output wire                     rd_empty,
  output wire [DAT_BIT-1 : 0]     rd_data
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  parameter  PTR_BIT             =  ADR_BIT + 1;
  // =========================================================================
  // Memory Interface Signals (clear naming for memory connections)
  // =========================================================================
  wire                            mem_wr_en_i;
  wire [DAT_BIT-1:0]              mem_wr_data_i;
  wire [ADR_BIT-1:0]              mem_wr_addr_bin_i;
  wire                            mem_rd_en_i;
  wire [ADR_BIT-1:0]              mem_rd_addr_bin_i;
  wire [DAT_BIT-1:0]              mem_rd_data_o;
  // =========================================================================
  // Write Clock Domain Signals
  // =========================================================================
  wire                            wt_wr_req_i;
  wire                            wt_full_o;       // FIFO full flag
  wire  [ADR_BIT-1 : 0]           wt_addr_bin_o;   // Write address derived from pointer
  wire  [PTR_BIT-1 : 0]           wt_wptr_gray_o;  // Gray write pointer in write domain
  // =========================================================================
  // Read Clock Domain Signals
  // =========================================================================
  wire                            rt_rd_req_i;
  wire                            rt_empty_o;      // FIFO empty flag
  wire  [ADR_BIT-1 : 0]           rt_addr_bin_o;   // Read address derived from pointer
  wire  [PTR_BIT-1 : 0]           rt_rptr_gray_o;  // Gray read pointer in read domain
  wire  [PTR_BIT-1 : 0]           rt_sync_wptr_i; // Write pointer synchronized to read domain
  // =========================================================================
  // Cross-Domain Synchronization Signals
  // =========================================================================
  wire  [PTR_BIT-1 : 0]           sync_w2r_wptr;
  wire  [PTR_BIT-1 : 0]           sync_r2w_rptr;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
  assign      rd_data             = mem_rd_data_o;
  assign      wr_full             = wt_full_o;
  assign      rd_empty            = rt_empty_o;

// tag INs assignment ----------------------------------------------------------------------------------------------
  assign      mem_wr_data_i       = wr_data;
  assign      wt_wr_req_i         = wr_req;
  assign      rt_rd_req_i         = rd_req;

// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------

  // Memory interface assignments
  assign      mem_wr_addr_bin_i   =  wt_addr_bin_o;
  assign      mem_rd_addr_bin_i   =  rt_addr_bin_o;

  assign      mem_wr_en_i         = (wt_wr_req_i && ~wt_full_o);
  assign      mem_rd_en_i         = (rt_rd_req_i && ~rt_empty_o);
// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
async_fifo_memory #(
  .ADR_BIT                        (  ADR_BIT         ),
  .DAT_BIT                        (  DAT_BIT         ),
  .WEN_BIT                        (  WEN_BIT         )
) fifo_memory (
  .wr_clk                         (  wr_clk          ),
  .rd_clk                         (  rd_clk          ),
  .rst_n                          (  wr_rst_n        ),
  .wr_en                          (  mem_wr_en_i     ),
  .wr_addr                        (  mem_wr_addr_bin_i   ),
  .wr_data                        (  mem_wr_data_i   ),
  .rd_en                          (  mem_rd_en_i     ),
  .rd_addr                        (  mem_rd_addr_bin_i   ),
  .rd_data                        (  mem_rd_data_o   )
);

asyn_fifo_wptr_full #(
  .ADR_BIT                        ( ADR_BIT          ),
  .DAT_BIT                        ( DAT_BIT          ),
  .WEN_BIT                        ( WEN_BIT          )
) wptr_full (
  .wr_clk                         ( wr_clk           ),
  .wr_rst_n                       ( wr_rst_n         ),
  .sync_r2w_rptr                  ( sync_r2w_rptr    ),
  .wr_req                         ( wt_wr_req_i      ),
  .wr_addr_bin                    ( wt_addr_bin_o    ),
  .wr_ptr_gray                    ( wt_wptr_gray_o   ),
  .wr_full                        ( wt_full_o        )
);
async_fifo_rptr_empty #(
  .ADR_BIT                        ( ADR_BIT          ),
  .DAT_BIT                        ( DAT_BIT          ),
  .WEN_BIT                        ( WEN_BIT          )
) rptr_empty (
  .rd_clk                         ( rd_clk           ),
  .rd_rst_n                       ( rd_rst_n         ),
  .sync_w2r_wptr                  ( sync_w2r_wptr    ),
  .rd_req                         ( rt_rd_req_i      ),
  .rd_addr_bin                    ( rt_addr_bin_o    ),
  .rd_ptr_gray                    ( rt_rptr_gray_o   ), // Gray read pointer in read domain
  .rd_empty                       ( rt_empty_o       )
);

async_fifo_SYNC_2T #(
  .SYNC_VAL_BIT                   ( PTR_BIT          )
) sync_w2r (
  .clk                            ( rd_clk           ),
  .rst_n                          ( rd_rst_n         ),
  .i_sync_data                    ( wt_wptr_gray_o   ),
  .o_sync_data                    ( sync_w2r_wptr    )
);

async_fifo_SYNC_2T #(
  .SYNC_VAL_BIT                   ( PTR_BIT          )
) sync_r2w (
  .clk                            ( wr_clk           ),
  .rst_n                          ( wr_rst_n         ),
  .i_sync_data                    ( rt_rptr_gray_o   ),
  .o_sync_data                    ( sync_r2w_rptr    )
);

endmodule