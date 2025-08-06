// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ ModuleName.v                                                                              //
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

module sim_sp_ram;

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  parameter                       ADR_BIT =  6;
  parameter                       DAT_BIT = 32;
  parameter                       WEN_BIT =  1;

  logic                           ref_clk_i;
  logic                           slow_clk_i;
  logic                           test_clk_i;
  logic                           rstn_glob_i;


  logic                           cen;
  logic                           wen;
  logic  [ADR_BIT-1:0]            addr;
  logic  [DAT_BIT-1:0]            din;
  logic  [DAT_BIT-1:0]            dout;


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
sp_ram_top i_sp_ram_top (
  .clk    ( ref_clk_i    ),
  .rst_n  ( rstn_glob_i  ),
  .CEN    ( cen          ),
  .WEN    ( wen          ),
  .addr   ( addr         ),
  .w_data ( din          ),
  .r_data ( dout         )
);



// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
initial begin
    $fsdbDumpfile("./sim_sp_ram.fsdb");
    $fsdbDumpvars(0, sim_sp_ram, "+all");
    $fsdbDumpMDA;
  end

// initial begin : timing_format
    // $timeformat(-9, 0, "ns", 9);
// end : timing_format


initial begin
  #1000;
  $finish;
end




initial begin
  rstn_glob_i   = 1'b0;
  #10
  rstn_glob_i   = 1'b1;

end

    initial begin
        $display("Start simulation");
        cen   = 0;
        wen   = 1;
        addr  = 0;
        din   = 0;
        #20
        // Write data to RAM
        @(posedge ref_clk_i);
        wen   = 0;
        addr  = 6'h1;
        din   = 32'h000000FF;

        @(posedge ref_clk_i);
        addr  = 6'hF;
        din   = 32'hFF000000;

        @(posedge ref_clk_i);
        wen   = 1;  // Disable write, start reading

        // Read data from address 1
        @(posedge ref_clk_i);
        addr  = 6'h1;

        @(posedge ref_clk_i);
        $display("Read data from addr 1: %h", dout);

        // Read data from address 2
        @(posedge ref_clk_i);
        addr  = 6'hF;

        @(posedge ref_clk_i);
        $display("Read data from addr 2: %h", dout);

        @(posedge ref_clk_i);
        $finish;
    end

endmodule
