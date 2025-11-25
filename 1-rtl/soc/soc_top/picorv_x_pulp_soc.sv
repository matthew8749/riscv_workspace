// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ picorv_x_pulp_soc.sv                                                                      //
// Creator ____________ Yan, Wei-Ting                                                                             //
// Built Date _________ Oct-25-2025                                                                               //
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

module picorv_x_pulp_soc
#(
  parameter   AXI_TEST            = 0,
  parameter   VERBOSE             = 0
) (
  input                           clk,
  input                           rst_n,
  output wire                     trap,
  output wire                     trace_valid,
  output wire                     [35:0] trace_data
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  //              _   _ _ _              _
  //    __ ___  _(_) | (_) |_ ___  __  _| |__   __ _ _ __
  //   / _` \ \/ / | | | | __/ _ \ \ \/ / '_ \ / _` | '__|
  //  | (_| |>  <| | | | | ||  __/  >  <| |_) | (_| | |
  //   \__,_/_/\_\_| |_|_|\__\___| /_/\_\_.__/ \__,_|_|
  // Dut parameters
  localparam int unsigned NoMasters         = 32'd2;    // How many Axi Masters there are
  localparam int unsigned NoSlaves          = 32'd4;    // How many Axi Slaves  there are
  // axi configurationS
  localparam int unsigned AxiAddrWidth      =  32'd32;    // Axi Address Width
  localparam int unsigned AxiDataWidth      =  32'd32;    // Axi Data Width
  localparam int unsigned AxiStrbWidth      =  AxiDataWidth / 32'd8;

  // in the bench can change this variables which are set here freely
  localparam axi_pkg::xbar_cfg_t xbar_cfg = '{
    NoSlvPorts:         NoMasters,
    NoMstPorts:         NoSlaves,
    MaxMstTrans:        32'd1,
    MaxSlvTrans:        32'd1,
    FallThrough:        1'b1,                                                             // @@
    LatencyMode:        axi_pkg::CUT_ALL_AX,
    AxiAddrWidth:       AxiAddrWidth,
    AxiDataWidth:       AxiDataWidth,
    NoAddrRules:        NoSlaves,
    default:            '0
  };
  typedef logic [AxiAddrWidth-1:0]      addr_t;
  typedef axi_pkg::xbar_rule_32_t       rule_t; // Has to be the same width as axi addr
  typedef logic [AxiDataWidth-1:0]      data_t;
  typedef logic [AxiStrbWidth-1:0]      strb_t;

  localparam rule_t [xbar_cfg.NoAddrRules-1:0] AddrMap = '{
    '{idx: `SOC_MEM_MAP_AXI_RAM0_ID,  start_addr: `SOC_MEM_MAP_AXI_RAM0_START_ADDR,  end_addr: `SOC_MEM_MAP_AXI_RAM0_END_ADDR  },  /* RAM0  : 32'h0000_0000 ~ 32'h0001_FFFF */
    '{idx: `SOC_MEM_MAP_AXI_RAM1_ID,  start_addr: `SOC_MEM_MAP_AXI_RAM1_START_ADDR,  end_addr: `SOC_MEM_MAP_AXI_RAM1_END_ADDR  },  /* RAM1  : 32'h0010_0000 ~ 32'h0011_FFFF */
    '{idx: `SOC_MEM_MAP_AXI_REGF0_ID, start_addr: `SOC_MEM_MAP_AXI_REGF0_START_ADDR, end_addr: `SOC_MEM_MAP_AXI_REGF0_END_ADDR },  /* REGF0 : 32'h0012_0000 ~ 32'h0012_FFFF */
    '{idx: `SOC_MEM_MAP_AXI_APB_ID,   start_addr: `SOC_MEM_MAP_AXI_APB_START_ADDR,   end_addr: `SOC_MEM_MAP_AXI_APB_END_ADDR   }   /* APB   : 32'h0013_0000 ~ 32'h0013_FFFF */
  };

  //              _   _ _ _
  //    __ ___  _(_) | (_) |_ ___   _ __ ___  __ _
  //   / _` \ \/ / | | | | __/ _ \ | '__/ _ \/ _` |
  //  | (_| |>  <| | | | | ||  __/ | | |  __/ (_| |
  //   \__,_/_/\_\_| |_|_|\__\___| |_|  \___|\__, |
  //                                         |___/
  /// Define the parameter `RegNumBytes` of the DUT.
  parameter int unsigned              TbRegNumBytes  = 32'd100;
  /// Define the parameter `AxiReadOnly` of the DUT.
  parameter logic [TbRegNumBytes-1:0] TbAxiReadOnly  = {{TbRegNumBytes-18{1'b0}}, 18'b0};
  /// Define the parameter `PrivProtOnly` of the DUT.
  parameter bit                       TbPrivProtOnly = 1'b0;
  /// Define the parameter `SecuProtOnly` of the DUT.
  parameter bit                       TbSecuProtOnly = 1'b0;

  typedef logic [7:0]              byte_t;
  typedef logic [AxiAddrWidth-1:0] axi_addr_t;
  typedef logic [AxiDataWidth-1:0] axi_data_t;
  typedef logic [AxiStrbWidth-1:0] axi_strb_t;

  localparam axi_addr_t StartAddr = `SOC_MEM_MAP_AXI_REGF0_START_ADDR;
  localparam axi_addr_t EndAddr   =
      axi_addr_t'(StartAddr + TbRegNumBytes + TbRegNumBytes/5);

  localparam  byte_t [TbRegNumBytes-1:0] RegRstVal = '0;
  localparam  PITCH_SIZE                           = 9;

  // -------------------------------
  // AXI Interfaces
  // -------------------------------
  AXI_LITE #( .AXI_ADDR_WIDTH (AxiAddrWidth), .AXI_DATA_WIDTH (AxiDataWidth) ) master [ NoMasters-1: 0] ();
  AXI_LITE #( .AXI_ADDR_WIDTH (AxiAddrWidth), .AXI_DATA_WIDTH (AxiDataWidth) ) slave  [  NoSlaves-1: 0] ();


  logic       [ 7: 0]             MST_U0_WR_IMP_HSIZE     , MST_U0_RD_IMP_HSIZE;
  logic       [ 7: 0]             MST_U0_WR_IMP_COOR_MINX , MST_U0_RD_IMP_COOR_MINX;
  logic       [ 7: 0]             MST_U0_WR_IMP_VSIZE     , MST_U0_RD_IMP_VSIZE;
  logic       [ 7: 0]             MST_U0_WR_IMP_COOR_MINY , MST_U0_RD_IMP_COOR_MINY;
  logic       [31: 0]             MST_U0_WR_IMP_ADR_PITCH , MST_U0_RD_IMP_ADR_PITCH;
  logic       [32: 0]             MST_U0_WR_IMP_DST_BADDR ;
  logic       [32: 0]             MST_U0_RD_IMP_SRC_BADDR ;
  logic                           MST_U0_WR_IMP_ST        , MST_U0_RD_IMP_ST;

  wire                            imp_done;
  reg                             imp_reg_start_flag;
  reg                             imp_reg_start_flag_rd;

  // picorv32_wrapper part
  wire                            tests_passed;
  reg         [31 : 0]            irq = 0;
  reg         [15 : 0]            count_cycle = 0;

  byte_t      [TbRegNumBytes-1:0] reg_q_o;
  byte_t      [TbRegNumBytes-1:0] reg_q_rdat;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
  assign MST_U0_WR_IMP_DST_BADDR  = {reg_q_rdat[3],  reg_q_rdat[2],  reg_q_rdat[1],  reg_q_rdat[0] }; //32'b0  0x0012_0003 ~ 0x0012_0000
  assign MST_U0_WR_IMP_ADR_PITCH  = {reg_q_rdat[7],  reg_q_rdat[6],  reg_q_rdat[5],  reg_q_rdat[4] } & { {(32-PITCH_SIZE){1'b0}} ,{PITCH_SIZE{1'b1}} };
                                                                                                      //9'd16  0x0012_0007 ~ 0x0012_0004
  assign MST_U0_WR_IMP_HSIZE      =  reg_q_rdat[8];                                                   //8'd4   0x0012_0008
  assign MST_U0_WR_IMP_VSIZE      =  reg_q_rdat[9];                                                   //8'd6   0x0012_0009
  assign MST_U0_WR_IMP_COOR_MINX  =  reg_q_rdat[10];                                                  //8'd0   0x0012_000A
  assign MST_U0_WR_IMP_COOR_MINY  =  reg_q_rdat[11];                                                  //8'd0   0x0012_000B
  assign MST_U0_WR_IMP_ST         =  reg_q_rdat[12];                                                  //       0x0012_000C

  assign MST_U0_RD_IMP_SRC_BADDR  = {reg_q_rdat[19], reg_q_rdat[18], reg_q_rdat[17], reg_q_rdat[16]}; //32'b0  0x0012_0013 ~ 0x0012_0010
  assign MST_U0_RD_IMP_ADR_PITCH  = {reg_q_rdat[23], reg_q_rdat[22], reg_q_rdat[21], reg_q_rdat[20]} & { {(32-PITCH_SIZE){1'b0}} ,{PITCH_SIZE{1'b1}} };
                                                                                                      //9'd16  0x0012_0017 ~ 0x0012_0014
  assign MST_U0_RD_IMP_HSIZE      =  reg_q_rdat[24];                                                  //8'd4   0x0012_0018
  assign MST_U0_RD_IMP_VSIZE      =  reg_q_rdat[25];                                                  //8'd6   0x0012_0019
  assign MST_U0_RD_IMP_COOR_MINX  =  reg_q_rdat[26];                                                  //8'd0   0x0012_001A
  assign MST_U0_RD_IMP_COOR_MINY  =  reg_q_rdat[27];                                                  //8'd0   0x0012_001B
  assign MST_U0_RD_IMP_ST         =  reg_q_rdat[28];                                                  //       0x0012_001C

  assign imp_start                = imp_reg_start_flag;


  axi_lite_xbar_intf #(
  .Cfg                            ( xbar_cfg ),
  .rule_t                         ( rule_t   )
) u0_axi_lite_xbar_intf (
  .rst_ni                         ( rst_n    ),
  .clk_i                          ( clk      ),
  .test_i                         ( 1'b0     ),
  .slv_ports                      ( master   ),
  .mst_ports                      ( slave    ),
  .addr_map_i                     ( AddrMap  ),
  .en_default_mst_port_i          ( '0       ),
  .default_mst_port_i             ( '0       )
);

  // Dut parameters

  localparam int unsigned         NoApbSlaves = 2;    // How many APB Slaves  there are
  localparam int unsigned         NoApbRules  = 2;    // How many address rules for the APB slaves
  localparam bit                  PipelineRequest  = 1'b0;
  localparam bit                  PipelineResponse = 1'b0;

  typedef logic [NoApbSlaves-1:0] apb_sel_t;
  addr_t                          paddr_o;
  logic       [2:0]               pprot_o;
  apb_sel_t                       pselx_o;
  logic                           penable_o;
  logic                           pwrite_o;
  data_t                          pwdata_o;
  strb_t                          pstrb_o;
  logic       [NoApbSlaves-1 :0]  pready_i;
  data_t      [NoApbSlaves-1 :0]  prdata_i;
  logic       [NoApbSlaves-1 :0]  pslverr_i;

  localparam rule_t [NoApbRules-1:0] APB_AddrMap = '{
    //'{idx: 32'd7, start_addr: 32'h0001_0000, end_addr: 32'h0001_1000},
    //'{idx: 32'd6, start_addr: 32'h0000_9000, end_addr: 32'h0001_0000},
    //'{idx: 32'd5, start_addr: 32'h0000_8000, end_addr: 32'h0000_9000},
    //'{idx: 32'd4, start_addr: 32'h0002_0000, end_addr: 32'h0002_1000},
    //'{idx: 32'd4, start_addr: 32'h0000_7000, end_addr: 32'h0000_8000},
    //'{idx: 32'd3, start_addr: 32'h0000_6300, end_addr: 32'h0000_7000},
    //'{idx: 32'd2, start_addr: 32'h0000_4000, end_addr: 32'h0000_6300},
    '{idx: 32'd1, start_addr: 32'h0013_0100, end_addr: 32'h0013_01FF},
    '{idx: 32'd0, start_addr: 32'h0013_0000, end_addr: 32'h0013_00FF}
  };

axi_lite_to_apb_intf #(
  .NoApbSlaves                    ( NoApbSlaves      ), // Number of connected APB slaves
  .NoRules                        ( NoApbRules       ), // Number of APB address rules
  .AddrWidth                      ( AxiAddrWidth     ), // Address width                             //same as AXI4-Lite
  .DataWidth                      ( AxiDataWidth     ), // Data width                                //same as AXI4-Lite
  .PipelineRequest                ( PipelineRequest  ), // Pipeline request path
  .PipelineResponse               ( PipelineResponse ), // Pipeline response path
  .rule_t                         ( rule_t           )  // Address Decoder rule from `common_cells`  // Has to be the same width as axi addr
) u0_axi_lite_to_apb_intf (
  .rst_ni                         ( rst_n            ),
  .clk_i                          ( clk              ),
  .slv                            ( slave[3]         ),
  .paddr_o                        ( paddr_o          ),  // type is as same as AXI4-Lite
  .pprot_o                        ( pprot_o          ),  // type is as same as AXI4-Lite
  .pselx_o                        ( pselx_o          ),
  .penable_o                      ( penable_o        ),
  .pwrite_o                       ( pwrite_o         ),
  .pwdata_o                       ( pwdata_o         ),  // type is as same as AXI4-Lite
  .pstrb_o                        ( pstrb_o          ),  // type is as same as AXI4-Lite
  .pready_i                       ( {NoApbSlaves{1'b1}}        ), //pready_i
  .prdata_i                       ( {NoApbSlaves{'b0}}         ), //prdata_i
  .pslverr_i                      ( {NoApbSlaves{1'b0}}        ), //pslverr_i
  .addr_map_i                     ( APB_AddrMap       )
);

  picorv32_axi #(
`ifndef SYNTH_TEST
`ifdef SP_TEST
  .ENABLE_REGS_DUALPORT(0),
`endif
`ifdef COMPRESSED_ISA
  .COMPRESSED_ISA(1),
`endif
  .ENABLE_MUL(1),
  .ENABLE_DIV(1),
  .ENABLE_IRQ(1),
  .ENABLE_TRACE(1)
`endif
) u0_picorv32_axi (
  .resetn                         ( rst_n              ),
  .clk                            ( clk                ),
  .trap                           ( trap               ),
  .mem_axi_awvalid                ( master[0].aw_valid ), // o
  .mem_axi_awready                ( master[0].aw_ready ), // i
  .mem_axi_awaddr                 ( master[0].aw_addr  ), // o
  .mem_axi_awprot                 ( master[0].aw_prot  ), // o
  .mem_axi_wvalid                 ( master[0].w_valid  ), // o
  .mem_axi_wready                 ( master[0].w_ready  ), // i
  .mem_axi_wdata                  ( master[0].w_data   ), // o
  .mem_axi_wstrb                  ( master[0].w_strb   ), // o
  .mem_axi_bvalid                 ( master[0].b_valid  ), // i
  .mem_axi_bready                 ( master[0].b_ready  ), // o
  //TODO b_resp                   master[0].b_resp = 0  // i
  .mem_axi_arvalid                ( master[0].ar_valid ), // o
  .mem_axi_arready                ( master[0].ar_ready ), // i
  .mem_axi_araddr                 ( master[0].ar_addr  ), // o
  .mem_axi_arprot                 ( master[0].ar_prot  ), // o
  .mem_axi_rvalid                 ( master[0].r_valid  ), // i
  .mem_axi_rready                 ( master[0].r_ready  ), // o
  .mem_axi_rdata                  ( master[0].r_data   ), // i
  //TODO r_resp                   master[0].r_resp = 0  // i
  .irq                            ( irq             ),
  .trace_valid                    (trace_valid    ),
  .trace_data                     (trace_data     )
);

  assign slave[0].b_resp = 2'b00;
  assign slave[0].r_resp = 2'b00;
axi4_memory #(
  .AXI_TEST                       ( AXI_TEST          ),
  .VERBOSE                        ( VERBOSE           )
) u0_pulp_axi4_mem (
  .clk                            ( clk               ),
  .mem_axi_awvalid                ( slave[0].aw_valid ),  // i
  .mem_axi_awready                ( slave[0].aw_ready ),  // o
  .mem_axi_awaddr                 ( slave[0].aw_addr  ),  // i
  .mem_axi_awprot                 ( slave[0].aw_prot  ),  // i
  .mem_axi_wvalid                 ( slave[0].w_valid  ),  // i
  .mem_axi_wready                 ( slave[0].w_ready  ),  // o
  .mem_axi_wdata                  ( slave[0].w_data   ),  // i
  .mem_axi_wstrb                  ( slave[0].w_strb   ),  // i
  .mem_axi_bvalid                 ( slave[0].b_valid  ),  // o
  .mem_axi_bready                 ( slave[0].b_ready  ),  // i
  //                                slave[0].b_resp       // o   //assign
  .mem_axi_arvalid                ( slave[0].ar_valid ),  // i
  .mem_axi_arready                ( slave[0].ar_ready ),  // o
  .mem_axi_araddr                 ( slave[0].ar_addr  ),  // i
  .mem_axi_arprot                 ( slave[0].ar_prot  ),  // i
  .mem_axi_rvalid                 ( slave[0].r_valid  ),  // o
  .mem_axi_rready                 ( slave[0].r_ready  ),  // i
  .mem_axi_rdata                  ( slave[0].r_data   ),  // o
  //                                slave[0].r_resp       // o   //assign
  .tests_passed                   ( tests_passed      )   // o
);

axi_lite_memory u0_axi_lite_memory (
  .rst_n                          ( rst_n             ),
  .clk                            ( clk               ),
  .s_aw_valid                     ( slave[1].aw_valid ),
  .s_aw_ready                     ( slave[1].aw_ready ),
  .s_aw_addr                      ( slave[1].aw_addr  ),
  .s_aw_prot                      ( slave[1].aw_prot  ),
  .s_w_valid                      ( slave[1].w_valid  ),
  .s_w_ready                      ( slave[1].w_ready  ),
  .s_w_data                       ( slave[1].w_data   ),
  .s_w_strb                       ( slave[1].w_strb   ),
  .s_b_valid                      ( slave[1].b_valid  ),
  .s_b_ready                      ( slave[1].b_ready  ),
  .s_b_resp                       ( slave[1].b_resp   ),
  .s_ar_valid                     ( slave[1].ar_valid ),
  .s_ar_ready                     ( slave[1].ar_ready ),
  .s_ar_addr                      ( slave[1].ar_addr  ),
  .s_ar_prot                      ( slave[1].ar_prot  ),
  .s_r_valid                      ( slave[1].r_valid  ),
  .s_r_ready                      ( slave[1].r_ready  ),
  .s_r_data                       ( slave[1].r_data   ),
  .s_r_resp                       ( slave[1].r_resp   )
);

axi_lite_regfile_intf #(
  .REG_NUM_BYTES                  ( TbRegNumBytes  ),
  .AXI_ADDR_WIDTH                 ( AxiAddrWidth   ),
  .AXI_DATA_WIDTH                 ( AxiDataWidth   ),
  .PRIV_PROT_ONLY                 ( TbPrivProtOnly ),
  .SECU_PROT_ONLY                 ( TbSecuProtOnly ),
  .AXI_READ_ONLY                  ( TbAxiReadOnly  ),
  .REG_RST_VAL                    ( RegRstVal      )
) u0_axi_lite_regfile (
  .clk_i                          ( clk       ),
  .rst_ni                         ( rst_n     ),
  .slv                            ( slave[2]  ),
  .wr_active_o                    ( /*wr_active*/ ),
  .rd_active_o                    ( /*rd_active*/ ),
  .reg_d_i                        ( {TbRegNumBytes{8'h00}}/*reg_d*/     ),
  .reg_load_i                     ( {TbRegNumBytes{8'h00}}/*reg_load*/  ),
  .reg_q_o                        ( reg_q_o     ),
  .reg_q_rdat                     ( reg_q_rdat  )
);

mst_imp_r_ch u0_mst_imp_r_ch (
  .rst_n                          ( rst_n                   ),
  .clk                            ( clk                     ),
  .mem_axi_arvalid                ( master[1].ar_valid      ),
  .mem_axi_arready                ( master[1].ar_ready      ),
  .mem_axi_araddr                 ( master[1].ar_addr       ),
  .mem_axi_arprot                 ( master[1].ar_prot       ),
  .mem_axi_rvalid                 ( master[1].r_valid       ),
  .mem_axi_rready                 ( master[1].r_ready       ),
  .mem_axi_rdata                  ( master[1].r_data        ),
  .IMP_HSIZE                      ( MST_U0_RD_IMP_HSIZE     ), //8'd4
  .IMP_VSIZE                      ( MST_U0_RD_IMP_VSIZE     ), //8'd6
  .IMP_COOR_MINX                  ( MST_U0_RD_IMP_COOR_MINX ), //8'd0
  .IMP_COOR_MINY                  ( MST_U0_RD_IMP_COOR_MINY ), //8'd0
  .IMP_SRC_BADDR                  ( MST_U0_RD_IMP_SRC_BADDR ), // 32'h0010_0000
  .IMP_ADR_PITCH                  ( MST_U0_RD_IMP_ADR_PITCH ),
  .IMP_ST                         ( MST_U0_RD_IMP_ST        )
);

mst_imp_w_ch u0_mst_imp_w_ch (
  .rst_n                          ( rst_n                   ),
  .clk                            ( clk                     ),
  .mem_axi_awvalid                ( master[1].aw_valid      ),
  .mem_axi_awready                ( master[1].aw_ready      ),
  .mem_axi_awaddr                 ( master[1].aw_addr       ),
  .mem_axi_awprot                 ( master[1].aw_prot       ),
  .mem_axi_wvalid                 ( master[1].w_valid       ),
  .mem_axi_wready                 ( master[1].w_ready       ),
  .mem_axi_wdata                  ( master[1].w_data        ),
  .mem_axi_wstrb                  ( master[1].w_strb        ),
  .mem_axi_bresp                  ( master[1].b_resp        ),
  .mem_axi_bvalid                 ( master[1].b_valid       ),
  .mem_axi_bready                 ( master[1].b_ready       ),
  .IMP_HSIZE                      ( MST_U0_WR_IMP_HSIZE     ),
  .IMP_VSIZE                      ( MST_U0_WR_IMP_VSIZE     ),
  .IMP_COOR_MINX                  ( MST_U0_WR_IMP_COOR_MINX ),
  .IMP_COOR_MINY                  ( MST_U0_WR_IMP_COOR_MINY ),
  .IMP_DST_BADDR                  ( MST_U0_WR_IMP_DST_BADDR ),
  .IMP_ADR_PITCH                  ( MST_U0_WR_IMP_ADR_PITCH ),
  //.IMP_ST                         ( 1'b0)//imp_start               )
  .IMP_ST                         ( MST_U0_WR_IMP_ST        )
);


// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------

// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****



// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
// moniter
print i_print (
  .clk            ( clk                ),
  .mem_axi_awvalid( master[0].aw_valid ),
  .mem_axi_awaddr ( master[0].aw_addr  ),
  .mem_axi_wvalid ( master[0].w_valid  ),
  .mem_axi_wdata  ( master[0].w_data   )
);

// picorv32_wrapper part
reg [1023:0] firmware_file;
always @(posedge clk) count_cycle <= rst_n ? count_cycle + 1 : 0;
always @* begin
    irq = 0;
    irq[4] = &count_cycle[12:0];
    irq[5] = &count_cycle[15:0];
  end
  initial begin
    if (!$value$plusargs("firmware=%s", firmware_file))
      firmware_file = "/home/matthew/project/riscv_workspace/2-sim/sim_soc/firmware/firmware.hex";
    $readmemh(firmware_file, u0_pulp_axi4_mem.memory);
    $fsdbDumpMDA;
  end

  integer cycle_counter;
  always @(posedge clk) begin
    cycle_counter <= rst_n ? cycle_counter + 1 : 0;
    if (rst_n && trap) begin
`ifndef VERILATOR
      repeat (10) @(posedge clk);
`endif
      $display("TRAP after %1d clock cycles", cycle_counter);
      if (tests_passed) begin
        $display("ALL TESTS PASSED.");
        $finish;
      end else begin
        $display("ERROR!");
        if ($test$plusargs("noerror"))
          //imp_reg_start_flag <= 1'b1;
          $finish;
        $stop;
      end
    end
  end


initial begin
  imp_reg_start_flag    <= 1'b0;
  imp_reg_start_flag_rd <= 1'b0;

  #83400
  imp_reg_start_flag <= 1'b1;

  #10000
  imp_reg_start_flag_rd <= 1'b1;
  // if (imp_done)begin
  //   #10000000
  //   $finish;
  // end
end

endmodule