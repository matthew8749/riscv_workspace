// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ apb_regs_intf_wrapper.sv                                                                              //
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
`include "apb/assign.svh"
`include "apb/typedef.svh"


module apb_regs_intf_wrapper
#(
  parameter int unsigned NO_APB_REGS    = 32'd342,
  parameter int unsigned APB_ADDR_WIDTH = 32'd32,
  parameter int unsigned APB_DATA_WIDTH = 32'd32,
  parameter int unsigned REG_DATA_WIDTH = 32'd16,
  // Don't OverWrite
  parameter int unsigned STRB_WIDTH = cf_math_pkg::ceil_div(APB_DATA_WIDTH, 8),
  parameter type strb_t = logic [STRB_WIDTH-1:0]
)(
  input  wire                     p_rst_n,
  input  wire                     p_clk,

  input  [APB_ADDR_WIDTH-1:0]     apb_reg_paddr,
  input  apb_pkg::prot_t          apb_reg_pprot,
  input  logic                    apb_reg_psel,
  input  logic                    apb_reg_penable,
  input  logic                    apb_reg_pwrite,
  input  [APB_DATA_WIDTH-1:0]     apb_reg_pwdata,
  input  strb_t                   apb_reg_pstrb,

  output logic                    apb_reg_pready,
  output [APB_DATA_WIDTH-1:0]     apb_reg_prdata,
  output logic                    apb_reg_pslverr,

  output logic [REG_DATA_WIDTH-1:0] [NO_APB_REGS-1:0]  apb_reg_data_o

);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  typedef logic [APB_ADDR_WIDTH-1:0] addr_t;
  typedef logic [APB_DATA_WIDTH-1:0] data_t;

  localparam logic [NO_APB_REGS-1:0] READ_ONLY = 32'h0000;                               // !!  {NO_APB_REGS}'h______

  logic [REG_DATA_WIDTH-1:0] [NO_APB_REGS-1:0]  reg_q_o;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
  assign apb_reg_pready        = apb_reg_slave.pready ;
  assign apb_reg_prdata        = apb_reg_slave.prdata ;
  assign apb_reg_pslverr       = apb_reg_slave.pslverr;

// tag INs assignment ----------------------------------------------------------------------------------------------
  assign apb_reg_slave.paddr   = apb_reg_paddr  ;
  assign apb_reg_slave.pprot   = apb_reg_pprot  ;
  assign apb_reg_slave.psel    = apb_reg_psel   ;
  assign apb_reg_slave.penable = apb_reg_penable;
  assign apb_reg_slave.pwrite  = apb_reg_pwrite ;
  assign apb_reg_slave.pwdata  = apb_reg_pwdata ;
  assign apb_reg_slave.pstrb   = apb_reg_pstrb  ;
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
  for (genvar apb_reg_id = 0; apb_reg_id < NO_APB_REGS; apb_reg_id++) begin
    assign apb_reg_data_o[apb_reg_id] = reg_q_o[apb_reg_id];
  end

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****

localparam [APB_ADDR_WIDTH-1:0] APB_BASE_ADDR = 32'h0013_0000;

APB #(
  .ADDR_WIDTH ( APB_ADDR_WIDTH ),
  .DATA_WIDTH ( APB_DATA_WIDTH )
) apb_reg_slave();

apb_regs_intf #(
  .NO_APB_REGS   ( NO_APB_REGS    ),
  .APB_ADDR_WIDTH( APB_ADDR_WIDTH ),
  .ADDR_OFFSET   ( 32'd4          ),
  .APB_DATA_WIDTH( APB_DATA_WIDTH ),
  .REG_DATA_WIDTH( REG_DATA_WIDTH ),
  .READ_ONLY     ( READ_ONLY      )
) u0_apb_regs_intf (
  .pclk_i        ( p_clk         ),
  .preset_ni     ( p_rst_n       ),
  .slv           ( apb_reg_slave ),
  .base_addr_i   ( APB_BASE_ADDR ),
  .reg_init_i    ( {NO_APB_REGS{'b0}}/*reg_init_i*/ ),
  .reg_q_o       ( reg_q_o       )
);



endmodule