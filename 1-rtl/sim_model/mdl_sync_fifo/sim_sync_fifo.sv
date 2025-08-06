// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ sim_sync_fifo.v                                                                              //
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
//`timescale 1ns/10ps

// test pattern
//1. 寫入測試：連續寫入數據直到 FIFO 滿
//2. 讀取測試：連續讀取直到 FIFO 空
//3. 讀寫交替測試


module sim_sync_fifo;

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  //localparam STIM = "./vectors/stim_zero.txt";
  parameter                       ADR_BIT =  6;
  parameter                       DAT_BIT = 32;
  parameter                       WEN_BIT =  1;

  logic                           ref_clk_i;
  logic                           slow_clk_i;
  logic                           test_clk_i;
  logic                           rstn_glob_i;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
// clock gen
tb_clk_gen #(
    //.CLK_PERIOD(REF_CLK_PERIOD)
    .CLK_PERIOD(3.33)   // 5 --> 200MHz
  ) i_ref_clk_gen (
    .clk_o(ref_clk_i)
  );
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****

  //fufo input
  logic       [WEN_BIT-1   : 0]   cs_en;
  logic       [WEN_BIT-1   : 0]   wr_en;
  logic       [DAT_BIT-1   : 0]   wr_dat;
  logic       [DAT_BIT-1   : 0]   rd_dat;

  //fifo optput
  logic                           fifo_full;
  logic                           fifo_empty;
  logic       [ADR_BIT : 0]       fifo_count;

sync_fifo #(
  .ADR_BIT    (   ADR_BIT         ),
  .DAT_BIT    (   DAT_BIT         ),
  .WEN_BIT    (   WEN_BIT         )
) i_sync_fifo (
  .clk        (   ref_clk_i       ),
  .rst_n      (   rstn_glob_i     ),
  .cs_en      (   cs_en           ), // high activ
  .wr_en      (   wr_en           ), // high activ
  .wr_dat     (   wr_dat          ),
  .rd_dat     (   rd_dat          ),
  .fifo_full  (   fifo_full       ),
  .fifo_empty (   fifo_empty      ),
  .fifo_count (   fifo_count      )
);

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
initial begin
    $fsdbDumpfile("./sim_sync_fifo.fsdb");
    $fsdbDumpvars(0, sim_sync_fifo, "+all");
    $fsdbDumpMDA;
  end

initial begin
  rstn_glob_i   = 1'b0;
  #15
  rstn_glob_i   = 1'b1;
end


// test pattern
//1. 寫入測試：連續寫入數據直到 FIFO 滿
//2. 讀取測試：連續讀取直到 FIFO 空
//3. 讀寫交替測試

initial begin
  cs_en        = 1'b0;
  wr_en        = 1'b0;
  wr_dat       = 'd0;
  #20


  for (int i = 0; i <66 ; i++)begin
    @(posedge ref_clk_i);
    if ( ~fifo_full ) begin
      cs_en  = 1'b1;
      wr_en  = 1'b1;
      wr_dat = i;
      $display("Time=%0t, -----  FIFO Not Full at %0d", $time, wr_dat);
    end else begin
      wr_en  = 1'b0;
      wr_dat = 0;
      $display("Time=%0t, -----  FIFO full at %0d", $time, wr_dat);
      break;
    end
  end


  wr_en  = 1'b0;
  for (int i = 0; i <66 ; i++)begin
    @(posedge ref_clk_i);
    if ( ~fifo_empty ) begin
      cs_en  = 1'b1;
      //@(posedge ref_clk_i);
      $display("Time=%0t, -----  Read data: %0d", $time, rd_dat);
    end else begin
      $display("Time=%0t, -----  Read data: %0d", $time, rd_dat);
      $display("Time=%0t, -----  FIFO empty at %0d", $time, i);
      break;
    end
  end

  #30
  $finish;

end


  // 監控 FIFO 狀態
  initial begin
    forever begin
      @(posedge ref_clk_i);
      $display("Time=%0t, Full=%0d, Empty=%0d, Count=%0d",
               $time, fifo_full, fifo_empty, fifo_count);
    end
  end

endmodule
