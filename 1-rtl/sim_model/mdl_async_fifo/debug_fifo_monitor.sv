// +FHDR ---------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ debug_fifo_monitor.sv                                                                     //
// Creator ____________ GPT Verilog Expert                                                                        //
// Description ________ Monitor module to observe internal state of async FIFO                                    //
// -FHDR ---------------------------------------------------------------------------------------------------------- //
`timescale 1ns/1ps

module debug_fifo_monitor #(
  parameter ADR_BIT = 4,
  parameter PTR_BIT = ADR_BIT + 1
)(
  input  logic                  wr_clk,
  input  logic                  rd_clk,
  input  logic [PTR_BIT-1:0]    wt_wptr_gray,
  input  logic [PTR_BIT-1:0]    rt_rptr_gray,
  input  logic [PTR_BIT-1:0]    sync_r2w_rptr,
  input  logic [PTR_BIT-1:0]    sync_w2r_wptr,
  input  logic [ADR_BIT-1:0]    wr_addr_bin,
  input  logic [ADR_BIT-1:0]    rd_addr_bin,
  input  logic                  wr_full,
  input  logic                  rd_empty
);

  // Function: Gray to binary conversion
  function automatic [PTR_BIT-1:0] gray2bin(input [PTR_BIT-1:0] gray);
    integer i;
    begin
      gray2bin[PTR_BIT-1] = gray[PTR_BIT-1];
      for (i = PTR_BIT-2; i >= 0; i = i - 1)
        gray2bin[i] = gray2bin[i+1] ^ gray[i];
    end
  endfunction

  logic [PTR_BIT-1:0] bin_wptr, bin_rptr;

  always_comb begin
    bin_wptr = gray2bin(wt_wptr_gray);
    bin_rptr = gray2bin(rt_rptr_gray);
  end

  // monitor from write clock domain
  always @(posedge wr_clk) begin
    $display("[WR_CLK] @%0t ns | wr_addr=%0d | wptr_gray=%b | sync_r2w_rptr=%b | wr_full=%0b", 
              $time, wr_addr_bin, wt_wptr_gray, sync_r2w_rptr, wr_full);
  end

  // monitor from read clock domain
  always @(posedge rd_clk) begin
    $display("[RD_CLK] @%0t ns | rd_addr=%0d | rptr_gray=%b | sync_w2r_wptr=%b | rd_empty=%0b", 
              $time, rd_addr_bin, rt_rptr_gray, sync_w2r_wptr, rd_empty);
  end

  // FIFO current fill-level estimation (non-synthesizable)
  always @(posedge wr_clk) begin
    int fifo_level = gray2bin(wt_wptr_gray) - gray2bin(sync_r2w_rptr);
    $display("[INFO]  FIFO LEVEL (write domain) = %0d", fifo_level);
  end

endmodule