// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ sim_async_fifo.sv                                                                         //
// Creator ____________ Yan, Wei-Ting                                                                             //
// Built Date _________ MMM-DD-YYYY                                                                               //
// Function ___________                                                                                           //
// Hierarchy __________                                                                                           //
//   Parent ___________                                                                                           //
//   Children _________                                                                                           //
// Revision history ___ Date        Author            Description                                                 //
//                  ___                                                                                           //
//                       基本寫入與讀出

//
// -FHDR--------------------------------------------------------------------------------------------------------- //
//+...........+...................+.............................................................................. //
//3...........15..................35............................................................................. //
//`include "Global_define.sv"
`timescale 1ns/1ps

module sim_async_fifo;
// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  parameter   ADR_BIT             = 3;
  parameter   DAT_BIT             = 8;
  parameter   WEN_BIT             = 1;
  parameter   FAST_PERIOD         = 10;
  parameter   SLOW_PERIOD         = 20;
  // Clocks
  logic                           wr_clk;
  logic                           wr_rst_n;
  logic                           rd_clk;
  logic                           rd_rst_n;
  // FIFO signals
  logic                           wr_req;
  logic       [DAT_BIT-1:0]       wr_data;
  logic                           wr_full;
  logic                           rd_req;
  logic       [DAT_BIT-1:0]       rd_data;
  logic                           rd_empty;

  // Scoreboard for expected data
  int                             error_count;
  logic       [DAT_BIT-1 :  0]    scoreboard[$];  // [$]:sv中 queue 的語法，代表長度會根據 push/pop 動態變化，支援".push_back()", ".pop_front()" 等函式操作
  logic       [DAT_BIT-1 :  0]    expected;


// tag OUTs assignment ---------------------------------------------------------------------------------------------
// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// system clock          /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
tb_clk_gen #( .CLK_PERIOD ( SLOW_PERIOD ) ) tb_clk_gen_rd ( .clk_o (rd_clk) );
tb_clk_gen #( .CLK_PERIOD ( FAST_PERIOD ) ) tb_clk_gen_wr ( .clk_o (wr_clk) );

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// DUT                   /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
async_fifo #(
  .ADR_BIT      ( ADR_BIT     ),
  .DAT_BIT      ( DAT_BIT     ),
  .WEN_BIT      ( WEN_BIT     )
) async_fifo_tb (
  .wr_clk       ( wr_clk      ),
  .wr_rst_n     ( wr_rst_n    ),
  .wr_req       ( wr_req      ),
  .wr_data      ( wr_data     ),
  .rd_clk       ( rd_clk      ),
  .rd_rst_n     ( rd_rst_n    ),
  .rd_req       ( rd_req      ),
  .wr_full      ( wr_full     ),
  .rd_empty     ( rd_empty    ),
  .rd_data      ( rd_data     )
);

`ifdef DEBUG_MONITOR
  debug_fifo_monitor #(
    .ADR_BIT (ADR_BIT),
    .PTR_BIT (ADR_BIT + 1)
  ) monitor_inst (
    .wr_clk           (wr_clk),
    .rd_clk           (rd_clk),
    .wt_wptr_gray     (sim_async_fifo.async_fifo_tb.wt_wptr_gray_o),
    .rt_rptr_gray     (sim_async_fifo.async_fifo_tb.rt_rptr_gray_o),
    .sync_r2w_rptr    (sim_async_fifo.async_fifo_tb.sync_r2w_rptr),
    .sync_w2r_wptr    (sim_async_fifo.async_fifo_tb.sync_w2r_wptr),
    .wr_addr_bin      (sim_async_fifo.async_fifo_tb.wt_addr_bin_o),
    .rd_addr_bin      (sim_async_fifo.async_fifo_tb.rt_addr_bin_o),
    .wr_full          (sim_async_fifo.async_fifo_tb.wr_full),
    .rd_empty         (sim_async_fifo.async_fifo_tb.rd_empty)
  );
`endif

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// Dump for waveform     /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
initial begin
    $fsdbDumpfile("./sim_async_fifo.fsdb");
    $fsdbDumpvars(0, sim_async_fifo, "+mda");
    $fsdbDumpMDA;
  end

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// Test main             /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
initial begin
  error_count = 0;
  wr_rst_n = 1;
  rd_rst_n = 1;
  wr_req   = 0;
  rd_req   = 0;
  wr_data  = 0;

  #20;
  wr_rst_n = 0;
  rd_rst_n = 0;
  #20;
  wr_rst_n = 1;
  rd_rst_n = 1;

  // Write 10 entries
  repeat (7) begin
    @(posedge wr_clk);
    if (!wr_full) begin
      #1 wr_data = $random;
      #1 wr_req  = 1;
      scoreboard.push_back(wr_data);
      $display("[WR] @%0t ns: addr = %0d, data = %0d", $time, sim_async_fifo.async_fifo_tb.wt_addr_bin_o, wr_data);
    end else begin
      #1 wr_req = 0;
    end
  end
  wr_req = 0;


  // Wait before read
  #80;
  $display("\n------------------------");
  $display("[START RD] @%0t ns", $time);
  $display("------------------------\n");


  // Read back 10 entries
  repeat (6) begin
    @(posedge rd_clk);
    if (!rd_empty) begin
      #1 rd_req = 1;
      $display("[rd_req = 1] @%0t ns", $time);
      if (scoreboard.size()) begin
        expected = scoreboard.pop_front();
        $display("[RD] @%0t ns: data = %0d (expect %0d)\n", $time, rd_data, expected);
        if (rd_data !== expected) begin
          $display(" ERROR: Data mismatch!");
          error_count++;
        end
      end
    end else begin
      #1 rd_req = 0;
    end
  end
  rd_req  = 0;

  # 80;
  wr_req  = 1;
  repeat (10) begin
    @(posedge wr_clk);
    if (!wr_full) begin
      #1 wr_data = $random;
      #1 wr_req  = 1;
      scoreboard.push_back(wr_data);
      $display("[WR] @%0t ns: addr = %0d, data = %0d", $time, sim_async_fifo.async_fifo_tb.wt_addr_bin_o, wr_data);
    end else begin
      #1 wr_req = 0;
    end
  end
  wr_req = 0;

  #80;

  rd_req = 1;
  // Read back 10 entries
  repeat (6) begin
    @(posedge rd_clk);
    if (!rd_empty) begin
      #1 rd_req = 1;
      $display("[rd_req = 1] @%0t ns", $time);
      if (scoreboard.size()) begin
        expected = scoreboard.pop_front();
        $display("[RD] @%0t ns: data = %0d (expect %0d)\n", $time, rd_data, expected);
        if (rd_data !== expected) begin
          $display(" ERROR: Data mismatch!");
          error_count++;
        end
      end
    end else begin
      #1 rd_req = 0;
    end
  end
  rd_req  = 0;



  // Final check
  #50;
  if (error_count == 0) begin
    $display("TEST PASS: No mismatches.");
  end else begin
    $display("TEST FAIL: %0d mismatches found.", error_count);
  end
  $finish;
end

endmodule