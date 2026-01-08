// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project____________                                                                                            //
// File name __________ sort_4_value.sv                                                                           //
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

module sort_4_value #(
  parameter   DAT_WDTH            = 8
)(
  input  wire                     clk,
  input  wire                     rst_n,
  input  wire                     sw_rst_n,

  input  wire [(DAT_WDTH-1): 0]   value_1,
  input  wire [(DAT_WDTH-1): 0]   value_2,
  input  wire [(DAT_WDTH-1): 0]   value_3,
  input  wire [(DAT_WDTH-1): 0]   value_4,

  output wire [(DAT_WDTH-1): 0]   value_Max,
  output wire [(DAT_WDTH-1): 0]   value_Second,
  output wire [(DAT_WDTH-1): 0]   value_Third,
  output wire [(DAT_WDTH-1): 0]   value_Fourth
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  wire [(DAT_WDTH-1): 0]          u0_value_max;
  wire [(DAT_WDTH-1): 0]          u0_value_med;
  wire [(DAT_WDTH-1): 0]          u0_value_min;
  wire [(DAT_WDTH-1): 0]          u1_value_max;
  wire [(DAT_WDTH-1): 0]          u1_value_med;
  wire [(DAT_WDTH-1): 0]          u1_value_min;
  wire [(DAT_WDTH-1): 0]          u2_value_max;
  wire [(DAT_WDTH-1): 0]          u2_value_med;
  wire [(DAT_WDTH-1): 0]          u2_value_min;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
  assign value_Max                = u1_value_max;
  assign value_Second             = u2_value_max;
  assign value_Third              = u2_value_med;
  assign value_Fourth             = u2_value_min;

// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
sort_3_value #(
  .DAT_WDTH          ( DAT_WDTH     )
) u0_4sorter_3_value (
  .clk               ( clk          ),
  .rst_n             ( rst_n        ),
  .sw_rst_n          ( sw_rst_n     ),

  .value_1           ( value_1      ),
  .value_2           ( value_2      ),
  .value_3           ( value_3      ),

  .value_min         ( u0_value_min ),
  .value_med         ( u0_value_med ),
  .value_max         ( u0_value_max )
);

sort_3_value #(
  .DAT_WDTH          ( DAT_WDTH     )
) u1_4sorter_3_value (
  .clk               ( clk          ),
  .rst_n             ( rst_n        ),
  .sw_rst_n          ( sw_rst_n     ),

  .value_1           ( value_4      ),
  .value_2           ( u0_value_med ),
  .value_3           ( u0_value_max ),

  .value_min         ( u1_value_min ),
  .value_med         ( u1_value_med ),
  .value_max         ( u1_value_max )
);

sort_3_value #(
  .DAT_WDTH          ( DAT_WDTH     )
) u2_4sorter_3_value (
  .clk               ( clk          ),
  .rst_n             ( rst_n        ),
  .sw_rst_n          ( sw_rst_n     ),

  .value_1           ( u1_value_min ),
  .value_2           ( u1_value_med ),
  .value_3           ( u0_value_min ),

  .value_min         ( u2_value_min ),
  .value_med         ( u2_value_med ),
  .value_max         ( u2_value_max )
);

endmodule