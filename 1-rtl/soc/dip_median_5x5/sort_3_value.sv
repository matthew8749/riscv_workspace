// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project____________                                                                                            //
// File name __________ sort_3_value.sv                                                                           //
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

module sort_3_value #(
  parameter   DAT_WDTH            = 8
)(
  input  wire                     clk,
  input  wire                     rst_n,
  input  wire                     sw_rst_n,

  input  wire [(DAT_WDTH-1): 0]   value_1,
  input  wire [(DAT_WDTH-1): 0]   value_2,
  input  wire [(DAT_WDTH-1): 0]   value_3,

  output wire [(DAT_WDTH-1): 0]   value_max,
  output wire [(DAT_WDTH-1): 0]   value_med,
  output wire [(DAT_WDTH-1): 0]   value_min
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  wire                            cond1;
  wire                            cond2;
  wire                            cond3;
  wire                            cond_and_1_2;
  wire                            cond_and_1_3;
  wire                            cond_and_2_3;

  reg  [(DAT_WDTH-1): 0]          temp_value_max;
  reg  [(DAT_WDTH-1): 0]          temp_value_med;
  reg  [(DAT_WDTH-1): 0]          temp_value_min;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
  assign value_max                = temp_value_max;
  assign value_med                = temp_value_med;
  assign value_min                = temp_value_min;

// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
  assign cond1                    = (value_1 > value_2) ? 1'b1 : 1'b0 ;
  assign cond2                    = (value_1 > value_3) ? 1'b1 : 1'b0 ;
  assign cond3                    = (value_2 > value_3) ? 1'b1 : 1'b0 ;
  assign cond_and_1_2             = (  cond1 &  cond2 );
  assign cond_and_1_3             = ( ~cond1 &  cond3 );
  assign cond_and_2_3             = ~(  cond2 |  cond3 );

// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
always @ ( * ) begin
  if ( ~rst_n) begin
    temp_value_max <= {(DAT_WDTH){1'd0}};
    temp_value_med <= {(DAT_WDTH){1'd0}};
    temp_value_min <= {(DAT_WDTH){1'd0}};
  end else begin
    {temp_value_max, temp_value_med, temp_value_min} = ( {cond_and_1_2, cond3  } == 2'b11) ? { value_1, value_2, value_3 } :
                                                       ( {cond_and_1_2, cond3  } == 2'b10) ? { value_1, value_3, value_2 } :
                                                       ( {cond_and_1_3, cond2  } == 2'b11) ? { value_2, value_1, value_3 } :
                                                       ( {cond_and_1_3, cond2  } == 2'b10) ? { value_2, value_3, value_1 } :
                                                       ( {cond_and_2_3, cond1  } == 2'b11) ? { value_3, value_1, value_2 } :
                                                       ( {cond_and_2_3, cond1  } == 2'b10) ? { value_3, value_2, value_1 } :
                                                                                 {temp_value_max, temp_value_med, temp_value_min};


  end
end

// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****



endmodule