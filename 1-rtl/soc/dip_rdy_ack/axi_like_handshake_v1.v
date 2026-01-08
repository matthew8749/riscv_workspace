// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ axi_like_handshake_v1.sv                                                                     //
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

module axi_like_handshake (
  input  logic                    clk,
  input  logic                    rst_n,

  input  logic                    valid_i,  // Upstream data valid
  output logic                    ready_o,  // This module ready to receive

  output logic                    valid_o,  // This module data valid
  input  logic                    ready_i   // Downstream ready to receive
);

// |  # | valid_i | ready_o | valid_o | ready_i | tmp_valid | tmp_ready |
// | -: | :-----: | :-----: | :-----: | :-----: | :-------: | :-------: |
// |  0 |    0    |    0    |    0    |    0    |     0     |     1     |
// |  1 |    0    |    0    |    0    |    1    |     0     |     1     |
// |  2 |    0    |    0    |    1    |    0    |     1     |     0     |
// |  3 |    0    |    0    |    1    |    1    |     0     |     1     |
// |  4 |    0    |    1    |    0    |    0    |     0     |     1     |
// |  5 |    0    |    1    |    0    |    1    |     0     |     1     |
// |  6 |    0    |    1    |    1    |    0    |     1     |     0     |
// |  7 |    0    |    1    |    1    |    1    |     0     |     1     |
// |  8 |    1    |    0    |    0    |    0    |     0     |     1     |
// |  9 |    1    |    0    |    0    |    1    |     0     |     1     |
// | 10 |    1    |    0    |    1    |    0    |     1     |     0     |
// | 11 |    1    |    0    |    1    |    1    |     0     |     1     |
// | 12 |    1    |    1    |    0    |    0    |     1     |     0     |
// | 13 |    1    |    1    |    0    |    1    |     1     |     1     |
// | 14 |    1    |    1    |    1    |    0    |     1     |     0     |
// | 15 |    1    |    1    |    1    |    1    |     1     |     1     |

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------

  logic       tmp_valid;
  logic       tmp_ready;
  //Handshake Transfer Enables
  logic       w_en;                                         // when upstream provides and we are ready
  logic       r_en;                                         // when we provide and downstream is ready
// tag OUTs assignment ---------------------------------------------------------------------------------------------
assign valid_o = tmp_valid;                                 // internal data exists
assign ready_o = tmp_ready;
//assign ready_o = !tmp_valid || (tmp_valid && ready_i);      // empty or full but being read
// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
assign w_en = valid_i && ready_o;
assign r_en = valid_o && ready_i;
// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
// State Register
always_ff @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    tmp_valid <= 1'b0;
    tmp_ready <= 1'b1;
  end else begin
    tmp_valid <= (valid_i && ready_o) || (valid_o && !ready_i);
    tmp_ready <=  ready_i || (valid_o == 1'b0 && ready_i == 1'b0 && (!w_en));
  end
end

endmodule