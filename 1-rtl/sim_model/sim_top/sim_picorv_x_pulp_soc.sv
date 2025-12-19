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
  reg PoR_rst_n = 0;
  wire trap;

  always #5 clk = ~clk;

  initial begin
    repeat (100) @(posedge clk);
    PoR_rst_n <= 1;
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
    repeat (1000000) @(posedge i_soc.G0_CPU_CLK/*clk*/);
    $display("TIMEOUT");
    $finish;
  end

  wire trace_valid;
  wire [35:0] trace_data;
  integer trace_file;

  initial begin
    if ($test$plusargs("trace")) begin
      trace_file = $fopen("sim_picorv_x_pulp_soc.trace", "w");
      repeat (10) @(posedge i_soc.G0_CPU_CLK/*clk*/);
      while (!trap) begin
        @(posedge i_soc.G0_CPU_CLK/*clk*/);
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

// picorv32_wrapper part
reg [15 : 0] count_cycle = 0;
reg [1023:0] firmware_file;
always @(posedge i_soc.G0_CPU_CLK/*clk*/) count_cycle <= i_soc.G0_CPU_RST_N ? count_cycle + 1 : 0;
always @* begin
    i_soc.irq = 0;
    i_soc.irq[4] = &count_cycle[12:0];
    i_soc.irq[5] = &count_cycle[15:0];
  end

  initial begin
    if (!$value$plusargs("firmware=%s", firmware_file))
      firmware_file = "/home/matthew/project/riscv_workspace/2-sim/sim_soc/firmware/firmware.hex";
    $readmemh(firmware_file, i_soc.u0_pulp_axi4_mem.memory);
    $fsdbDumpMDA;
  end

  integer cycle_counter;
  always @(posedge i_soc.G0_CPU_CLK/*clk*/) begin
    cycle_counter <= i_soc.G0_CPU_RST_N ? cycle_counter + 1 : 0;
    if (i_soc.G0_CPU_RST_N && trap) begin
`ifndef VERILATOR
      repeat (10) @(posedge i_soc.G0_CPU_CLK/*clk*/);
`endif
      $display("TRAP after %1d clock cycles", cycle_counter);
      if (i_soc.tests_passed) begin
        $display("ALL TESTS PASSED.");
        $finish;
      end else begin
        $display("ERROR!");
        if ($test$plusargs("noerror"))
          $finish;
        $stop;
      end
    end
  end

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
  picorv_x_pulp_soc #(
  .AXI_TEST    ( AXI_TEST     ),
  .VERBOSE     ( VERBOSE      )
) i_soc        (
  .clk         ( clk          ),
  .PoR_rst_n   ( PoR_rst_n    ),
  .trap        ( trap         ),
  .trace_valid ( trace_valid  ),
  .trace_data  ( trace_data   )
);

endmodule
//`endif



// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****


