// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.
//`define VERILATOR

`timescale 1 ns / 1 ps

//`ifndef VERILATOR
module sim_picorv_x_pulp_soc #(
  parameter AXI_TEST = 0,
  parameter VERBOSE = 0
);
  localparam TESTPAR = $clog2(1);
  reg clk = 1;
  reg rst_n = 0;
  wire trap;

  always #5 clk = ~clk;

  initial begin
    repeat (100) @(posedge clk);
    rst_n <= 1;
  end

  initial begin
    if ($test$plusargs("vcd")) begin
      $dumpfile("sim_picorv_x_pulp_soc.vcd");
      $dumpvars(0, sim_picorv_x_pulp_soc);
    end else begin
      $fsdbDumpfile("sim_picorv_x_pulp_soc.fsdb");
      $fsdbDumpvars(0, sim_picorv_x_pulp_soc, "+mda");
      $fsdbDumpMDA();
    end
    repeat (1000000) @(posedge clk);
    $display("TIMEOUT");
    //force i_soc.imp_reg_stsrt_flag = 1'b1;
    $finish;
  end

  wire trace_valid;
  wire [35:0] trace_data;
  integer trace_file;

  initial begin
    if ($test$plusargs("trace")) begin
      trace_file = $fopen("sim_picorv_x_pulp_soc.trace", "w");
      repeat (10) @(posedge clk);
      while (!trap) begin
        @(posedge clk);
        if (trace_valid)
          $fwrite(trace_file, "%x\n", trace_data);
      end
      $fclose(trace_file);
      $display("Finished writing sim_picorv_x_pulp_soc.trace.");
    end
  end


// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
  picorv_x_pulp_soc #(
    .AXI_TEST (AXI_TEST),
    .VERBOSE  (VERBOSE)
  ) i_soc (
    .clk(clk),
    .rst_n(rst_n),
    .trap(trap),
    .trace_valid(trace_valid),
    .trace_data(trace_data)
  );

endmodule
//`endif



// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****


