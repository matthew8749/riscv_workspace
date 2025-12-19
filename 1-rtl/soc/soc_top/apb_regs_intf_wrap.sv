// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ apb_regs_intf_wrap.sv                                                                     //
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


module apb_regs_intf_wrap
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

  input  logic [APB_ADDR_WIDTH-1:0]  apb_reg_paddr,
  input  apb_pkg::prot_t             apb_reg_pprot,
  input  logic                       apb_reg_psel,
  input  logic                       apb_reg_penable,
  input  logic                       apb_reg_pwrite,
  input  logic [APB_DATA_WIDTH-1:0]  apb_reg_pwdata,
  input  strb_t                      apb_reg_pstrb,

  output logic                       apb_reg_pready,
  output logic [APB_DATA_WIDTH-1:0]  apb_reg_prdata,
  output logic                       apb_reg_pslverr,

  output wire [ 3: 0]             REG_CLK_DIV_CPU ,               // fw : 0x0013_0000
  output wire                     REG_CLK_TOG_CPU ,               // fw : 0x0013_0004
  output wire                     REG_CLK_CKEN_CPU,               // fw : 0x0013_0004
  output wire [ 3: 0]             REG_CLK_DIV_AXI ,               // fw : 0x0013_0000
  output wire                     REG_CLK_TOG_AXI ,               // fw : 0x0013_0004
  output wire                     REG_CLK_CKEN_AXI,               // fw : 0x0013_0004
  output wire [ 3: 0]             REG_CLK_DIV_APB ,               // fw : 0x0013_0000
  output wire                     REG_CLK_TOG_APB ,               // fw : 0x0013_0004
  output wire                     REG_CLK_CKEN_APB,               // fw : 0x0013_0004
  output wire [ 3: 0]             REG_CLK_DIV_I2C ,               // fw : 0x0013_0000
  output wire                     REG_CLK_TOG_I2C ,               // fw : 0x0013_0004
  output wire                     REG_CLK_CKEN_I2C,               // fw : 0x0013_0004
  output wire [ 3: 0]             REG_CLK_DIV_IMP ,               // fw : 0x0013_0000
  output wire                     REG_CLK_TOG_IMP ,               // fw : 0x0013_0004
  output wire                     REG_CLK_CKEN_IMP,               // fw : 0x0013_0004

  output wire                     REG_ICG_ON_CPU,                 // fw : 0x0013_0008
  output wire                     REG_ICG_ON_AXI,                 // fw : 0x0013_0008
  output wire                     REG_ICG_ON_APB,                 // fw : 0x0013_0008
  output wire                     REG_ICG_ON_I2C,                 // fw : 0x0013_0008
  output wire                     REG_ICG_ON_IMP                  // fw : 0x0013_0008

);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------

  localparam  G0_CPU_ID           = 0;
  localparam  AXI_ID              = 1;
  localparam  APB_ID              = 2;
  localparam  I2C_ID              = 3;
  localparam  IMP_ID              = 4;

  localparam  REG_CLK_GRP_DIV_ID  = 0;
  localparam  REG_CLK_GRP_DCFG_ID = 1;
  localparam  REG_CLK_GATE_ON_ID  = 2;

  localparam     [APB_ADDR_WIDTH-1 : 0] APB_BASE_ADDR = 32'h0013_0000;
  localparam bit [NO_APB_REGS-1    : 0] READ_ONLY     = 32'h0000_0000;                               // !!  {NO_APB_REGS}'h______

  typedef logic [APB_ADDR_WIDTH-1:0] addr_t;
  typedef logic [APB_DATA_WIDTH-1:0] data_t;
  logic [REG_DATA_WIDTH-1:0] [NO_APB_REGS-1:0]  apb_reg_data_o;
  logic [REG_DATA_WIDTH-1:0] [NO_APB_REGS-1:0]  reg_init_i;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
  assign apb_reg_pready        = apb_reg_slave.pready ;
  assign apb_reg_prdata        = apb_reg_slave.prdata ;
  assign apb_reg_pslverr       = apb_reg_slave.pslverr;

  assign REG_CLK_DIV_CPU         =  apb_reg_data_o [REG_CLK_GRP_DIV_ID] [ 3:  0] ;
  assign REG_CLK_DIV_IMP         =  apb_reg_data_o [REG_CLK_GRP_DIV_ID] [ 7:  4] ;
  assign REG_CLK_DIV_AXI         =  apb_reg_data_o [REG_CLK_GRP_DIV_ID] [11:  8] ;
  assign REG_CLK_DIV_APB         =  apb_reg_data_o [REG_CLK_GRP_DIV_ID] [15: 12] ;
  assign REG_CLK_DIV_I2C         =  apb_reg_data_o [REG_CLK_GRP_DIV_ID] [19: 16] ;
  //assign REG_CLK_DIV_XXX         =  apb_reg_data_o [REG_CLK_GRP_DIV_ID] [23: 20] ;      // Configurable space
  //assign REG_CLK_DIV_XXX         =  apb_reg_data_o [REG_CLK_GRP_DIV_ID] [27: 24] ;      // Configurable space
  //assign REG_CLK_DIV_XXX         =  apb_reg_data_o [REG_CLK_GRP_DIV_ID] [31: 28] ;      // Configurable space

  assign REG_CLK_TOG_CPU         = apb_reg_data_o [REG_CLK_GRP_DCFG_ID][0 ] ;
  assign REG_CLK_CKEN_CPU        = apb_reg_data_o [REG_CLK_GRP_DCFG_ID][1 ] ;
  assign REG_CLK_TOG_AXI         = apb_reg_data_o [REG_CLK_GRP_DCFG_ID][4 ] ;
  assign REG_CLK_CKEN_AXI        = apb_reg_data_o [REG_CLK_GRP_DCFG_ID][5 ] ;
  assign REG_CLK_TOG_APB         = apb_reg_data_o [REG_CLK_GRP_DCFG_ID][8 ] ;
  assign REG_CLK_CKEN_APB        = apb_reg_data_o [REG_CLK_GRP_DCFG_ID][9 ] ;
  assign REG_CLK_TOG_I2C         = apb_reg_data_o [REG_CLK_GRP_DCFG_ID][12] ;
  assign REG_CLK_CKEN_I2C        = apb_reg_data_o [REG_CLK_GRP_DCFG_ID][13] ;
  assign REG_CLK_TOG_IMP         = apb_reg_data_o [REG_CLK_GRP_DCFG_ID][16] ;
  assign REG_CLK_CKEN_IMP        = apb_reg_data_o [REG_CLK_GRP_DCFG_ID][17] ;

  assign REG_ICG_ON_CPU          = apb_reg_data_o [REG_CLK_GATE_ON_ID][0];
  assign REG_ICG_ON_AXI          = apb_reg_data_o [REG_CLK_GATE_ON_ID][1];
  assign REG_ICG_ON_APB          = apb_reg_data_o [REG_CLK_GATE_ON_ID][2];
  assign REG_ICG_ON_I2C          = apb_reg_data_o [REG_CLK_GATE_ON_ID][3];
  assign REG_ICG_ON_IMP          = apb_reg_data_o [REG_CLK_GATE_ON_ID][4];

// tag INs assignment ----------------------------------------------------------------------------------------------
  assign apb_reg_slave.paddr   = apb_reg_paddr  ;
  assign apb_reg_slave.pprot   = apb_reg_pprot  ;
  assign apb_reg_slave.psel    = apb_reg_psel   ;
  assign apb_reg_slave.penable = apb_reg_penable;
  assign apb_reg_slave.pwrite  = apb_reg_pwrite ;
  assign apb_reg_slave.pwdata  = apb_reg_pwdata ;
  assign apb_reg_slave.pstrb   = apb_reg_pstrb  ;
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
  assign reg_init_i [REG_CLK_GRP_DIV_ID ]  = 32'h00000000;                                // REG_CLK_GRP_DIV
  assign reg_init_i [REG_CLK_GRP_DCFG_ID]  = 32'b0000_0000_0000_0011_0011_0011_0011_0011; // REG_CLK_GRP_DCFG
  assign reg_init_i [REG_CLK_GATE_ON_ID ]  = 32'b0000_0000_0000_0000_0000_0000_1111_1111; // REG_CLK_GATE_ON
  // assign reg_init_i [G0_CPU_ID ]  = 32'h00_01_01_00;
  // assign reg_init_i [AXI_ID    ]  = 32'h00_01_01_00;
  // assign reg_init_i [APB_ID    ]  = 32'h00_01_01_00;
  // assign reg_init_i [I2C_ID    ]  = 32'h00_01_01_00;
  // assign reg_init_i [IMP_ID    ]  = 32'h00_01_01_00;
  for (genvar reg_init_id = 3; reg_init_id < NO_APB_REGS; reg_init_id++) begin
    assign reg_init_i[reg_init_id] = 'b0;
  end

// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
  // for (genvar apb_reg_id = 0; apb_reg_id < NO_APB_REGS; apb_reg_id++) begin
  //   assign apb_reg_data_o[apb_reg_id] = reg_q_o[apb_reg_id];
  // end

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
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
  .pclk_i        ( p_clk          ),
  .preset_ni     ( p_rst_n        ),
  .slv           ( apb_reg_slave  ),
  .base_addr_i   ( APB_BASE_ADDR  ),
  .reg_init_i    ( reg_init_i     ),                 // @@TODO
  .reg_q_o       ( apb_reg_data_o )
);



endmodule