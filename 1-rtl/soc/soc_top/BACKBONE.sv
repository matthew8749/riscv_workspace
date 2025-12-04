// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ BACKBONE.sv                                                                               //
// Creator ____________ Yan, Wei-Ting                                                                             //
// Built Date _________ NOV-29-2025                                                                               //
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
`include "axi/typedef.svh"
`include "axi/assign.svh"
`include "include/Global_define.svh"

module BACKBONE
#(
  parameter int unsigned AXI_ADDR_WIDTH = 32,
  parameter int unsigned AXI_DATA_WIDTH = 32,
  parameter int unsigned NO_AXI_MASTERS = 2,
  parameter int unsigned NO_AXI_SLAVES  = 3, //APB Bridge is not included because it is enclosed within it.
  //apb
  parameter int unsigned NO_APB_SLAVES    = 7,
  parameter int unsigned NO_APB_RULES     = 8,    // How many address rules for the APB slaves
  parameter bit          PipelineRequest  = 1'b0,
  parameter bit          PipelineResponse = 1'b0,
  // Don't OverWrite
  parameter int unsigned XBAR_INT_NO_SLAVE =  NO_AXI_SLAVES + 1, // Total number of internal slaves in Xbar = external slaves + 1 internal APB Bridge
  parameter int unsigned AXI_STRB_WIDTH    =  AXI_DATA_WIDTH / 32'd8
)(
  input  wire                         ARSTnMS_ACLK,
  input  wire                         ACLKMST_ACLK,
  // AXI Slave Interfaces (From Masters like CPU)
  AXI_LITE.Slave                      connect_mst  [NO_AXI_MASTERS-1:0],
  // AXI Master Interfaces (To Slaves like RAM)
  AXI_LITE.Master                     connect_slv  [NO_AXI_SLAVES-1:0],

  // apb bus
  input  wire                         PRSTnMS_PCLK,
  input  wire                         PCLKMST_PCLK,

  output logic [AXI_ADDR_WIDTH-1 :0]  apb_paddr_o,
  output logic [               2 :0]  apb_pprot_o,
  output logic [NO_APB_SLAVES-1  :0]  apb_pselx_o,
  output logic                        apb_penable_o,
  output logic                        apb_pwrite_o,
  output logic [AXI_DATA_WIDTH-1 :0]  apb_pwdata_o,
  output logic [AXI_STRB_WIDTH-1 :0]  apb_pstrb_o,

  input  logic [NO_APB_SLAVES-1  :0]                       apb_pready_i,
  input  logic [NO_APB_SLAVES-1  :0] [AXI_DATA_WIDTH-1 :0] apb_prdata_i,
  input  logic [NO_APB_SLAVES-1  :0]                       apb_pslverr_i
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  // axi xbar configurationS
    // in the bench can change this variables which are set here freely
    typedef logic [AXI_ADDR_WIDTH-1:0]  addr_t;
    typedef logic [AXI_DATA_WIDTH-1:0]  data_t;
    typedef logic [AXI_STRB_WIDTH-1:0]  strb_t;
    typedef axi_pkg::xbar_rule_32_t     rule_t; // Has to be the same width as axi addr

    localparam axi_pkg::xbar_cfg_t xbar_cfg = '{
      NoSlvPorts   : NO_AXI_MASTERS,
      NoMstPorts   : XBAR_INT_NO_SLAVE,
      MaxMstTrans  : 32'd1,
      MaxSlvTrans  : 32'd1,
      FallThrough  : 1'b1,                // @@
      LatencyMode  : axi_pkg::CUT_ALL_AX,
      AxiAddrWidth : AXI_ADDR_WIDTH,
      AxiDataWidth : AXI_DATA_WIDTH,
      NoAddrRules  : XBAR_INT_NO_SLAVE,
      default      : '0
    };

    localparam rule_t [xbar_cfg.NoAddrRules-1:0] AXI_AddrMap = '{
      '{idx: `SOC_MEM_MAP_AXI_RAM0_ID,  start_addr: `SOC_MEM_MAP_AXI_RAM0_START_ADDR,  end_addr: `SOC_MEM_MAP_AXI_RAM0_END_ADDR  },  /* RAM0  : 32'h0000_0000 ~ 32'h0001_FFFF */
      '{idx: `SOC_MEM_MAP_AXI_RAM1_ID,  start_addr: `SOC_MEM_MAP_AXI_RAM1_START_ADDR,  end_addr: `SOC_MEM_MAP_AXI_RAM1_END_ADDR  },  /* RAM1  : 32'h0010_0000 ~ 32'h0011_FFFF */
      '{idx: `SOC_MEM_MAP_AXI_REGF0_ID, start_addr: `SOC_MEM_MAP_AXI_REGF0_START_ADDR, end_addr: `SOC_MEM_MAP_AXI_REGF0_END_ADDR },  /* REGF0 : 32'h0012_0000 ~ 32'h0012_FFFF */
      '{idx: `SOC_MEM_MAP_AXI_APB_ID,   start_addr: `SOC_MEM_MAP_AXI_APB_START_ADDR,   end_addr: `SOC_MEM_MAP_AXI_APB_END_ADDR   }   /* APB   : 32'h0013_0000 ~ 32'h0013_FFFF */
    };

  // apb configurationS
    // typedef logic [NO_APB_SLAVES-1:0] apb_sel_t;
    // apb_sel_t                       pselx_o;
    localparam rule_t [NO_APB_RULES-1:0] APB_AddrMap = '{
      // '{idx: 32'd6, start_addr: 32'h0013_2000, end_addr: 32'h0013_2FFF},
      // '{idx: 32'd5, start_addr: 32'h0013_1000, end_addr: 32'h0013_1FFF},
      // '{idx: 32'd4, start_addr: 32'h0013_0700, end_addr: 32'h0013_07FF},
      // '{idx: 32'd3, start_addr: 32'h0013_0300, end_addr: 32'h0013_03FF},
      // '{idx: 32'd2, start_addr: 32'h0013_0500, end_addr: 32'h0013_05FF},
      // '{idx: 32'd2, start_addr: 32'h0013_0200, end_addr: 32'h0013_02FF},
      // '{idx: 32'd1, start_addr: 32'h0013_0100, end_addr: 32'h0013_01FF},
      '{idx: 32'd0, start_addr: 32'h0013_0000, end_addr: 32'h0013_00FF}    // apb reg
    };

  // -------------------------------
  // AXI Interfaces Def
  // -------------------------------
  AXI_LITE #( .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH), .AXI_DATA_WIDTH (AXI_DATA_WIDTH) ) slave  [  XBAR_INT_NO_SLAVE-1: 0] ();

// tag OUTs assignment ---------------------------------------------------------------------------------------------
  for (genvar i = 0; i < NO_AXI_SLAVES; i++) begin : gen_connect_axi_slaves
        `AXI_LITE_ASSIGN(connect_slv[i], slave[i])
  end
// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****

// ===========================================================================
//                    master[0] ......  master[n]
//                     (CUP)            (mst_IP)
//                       ^                 ^
//                       |                 |
//       +---------------+-----------------+--------------+
//       |      |   slv_ports (NO_AXI_MASTERS)   |        |
//       |      +--------------------------------+        |
//       |                                                |
//       |               axi_lite_xbar_intf               |
//       |                                                |
//       |      +--------------------------------+        |
//       |      | mst_ports (XBAR_INT_NO_SLAVE)  |        |
//       +---------------+-----------------+--------------+
//                       |                 |
//                       v                 v
//                    slave[0]  ......  slave[n]
//                     (ROM)             (RAM)
// ===========================================================================
  axi_lite_xbar_intf #(
  .Cfg                            ( xbar_cfg      ),
  .rule_t                         ( rule_t        )
) u0_axi_lite_xbar_intf (
  .rst_ni                         ( ARSTnMS_ACLK  ),
  .clk_i                          ( ACLKMST_ACLK  ),
  .test_i                         ( 1'b0          ),
  .slv_ports                      ( connect_mst   ),
  .mst_ports                      ( slave         ),
  .addr_map_i                     ( AXI_AddrMap   ),
  .en_default_mst_port_i          ( '0            ),
  .default_mst_port_i             ( '0            )
);


axi_lite_to_apb_intf #(
  .NoApbSlaves                    ( NO_APB_SLAVES      ), // Number of connected APB slaves
  .NoRules                        ( NO_APB_RULES       ), // Number of APB address rules
  .AddrWidth                      ( AXI_ADDR_WIDTH     ), // Address width                             //same as AXI4-Lite
  .DataWidth                      ( AXI_DATA_WIDTH     ), // Data width                                //same as AXI4-Lite
  .PipelineRequest                ( PipelineRequest    ), // Pipeline request path
  .PipelineResponse               ( PipelineResponse   ), // Pipeline response path
  .rule_t                         ( rule_t             )  // Address Decoder rule from `common_cells`  // Has to be the same width as axi addr
) u0_axi_lite_to_apb_intf (
  .rst_ni                         ( PRSTnMS_PCLK     ),
  .clk_i                          ( PCLKMST_PCLK     ),
  .slv                            ( slave[3]         ),  // Connect to the last port of Xbar !!!
  .paddr_o                        ( apb_paddr_o      ),  // type is as same as AXI4-Lite
  .pprot_o                        ( apb_pprot_o      ),  // type is as same as AXI4-Lite
  .pselx_o                        ( apb_pselx_o      ),
  .penable_o                      ( apb_penable_o    ),
  .pwrite_o                       ( apb_pwrite_o     ),
  .pwdata_o                       ( apb_pwdata_o     ),  // type is as same as AXI4-Lite
  .pstrb_o                        ( apb_pstrb_o      ),  // type is as same as AXI4-Lite
  .pready_i                       ( apb_pready_i     ),
  .prdata_i                       ( apb_prdata_i     ),
  .pslverr_i                      ( apb_pslverr_i    ),
  .addr_map_i                     ( APB_AddrMap      )
);




endmodule