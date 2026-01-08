// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ axi_like_handshake.sv                                                                     //
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
  // Upstream (Input) Interface
  input  logic                    valid_i,  // Upstream data valid
  output logic                    ready_o,  // This module ready to receive
  // Downstream (Output) Interface
  output logic                    valid_o,  // This module data valid
  input  logic                    ready_i  // Downstream ready to receive
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------

  logic       buf_valid;          // Internal state register: tracks whether Buffer has valid data
  //Handshake Transfer Enables (Combinational)
  logic       w_en;               // Write enable: when upstream provides and we are ready
  logic       r_en;               // Read enable: when we provide and downstream is ready
// tag OUTs assignment ---------------------------------------------------------------------------------------------
assign valid_o = buf_valid;                                 // internal data exists
assign ready_o = !buf_valid || (buf_valid && ready_i);      // empty or full but simultaneously being read
// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
//assign w_en = valid_i && ready_o;
//assign r_en = valid_o && ready_i;

assign w_en = valid_i && (!buf_valid || (buf_valid && ready_i));
assign r_en = buf_valid && ready_i;
// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------

// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****

// State Register
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    buf_valid <= 1'b0;
  end else begin
    if (w_en) begin               // Write priority: whenever write occurs, Buffer next state is full (1)
      buf_valid <= 1'b1;
    end else if (r_en) begin      // Read only: if no write but read occurs, Buffer next state is empty (0)
      buf_valid <= 1'b0;
    end else begin                // Idle: neither read nor write, maintain current state
      buf_valid <= buf_valid;
    end
  end
end


endmodule