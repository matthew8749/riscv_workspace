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

module picorv_x_pulp_soc #(
  parameter   AXI_TEST            = 0,
  parameter   VERBOSE             = 0
) (
  input                           clk,
  input                           PoR_rst_n,
  output wire                     trap,
  output wire                     trace_valid,
  output wire [35 : 0]            trace_data
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  // axi configurationS
  localparam int unsigned AXI_ADDR_WIDTH = 32'd32;  // Axi Address Width
  localparam int unsigned AXI_DATA_WIDTH = 32'd32;  // Axi Data Width
  localparam int unsigned NO_AXI_MASTERS = 32'd2;   // How many Axi Masters there are
  localparam int unsigned NO_AXI_SLAVES  = 32'd4;   // How many Axi Slaves  there are
                                                   // BUT!! APB Bridge is not included because it is enclosed within it.
  localparam int unsigned AXI_STRB_WIDTH =  AXI_DATA_WIDTH / 32'd8;
  //apb
  localparam int unsigned NO_APB_SLAVES    = 32'd2;
  localparam int unsigned NO_APB_RULES     = 32'd2;    // How many address rules for the APB slaves
  localparam bit          PipelineRequest  = 1'b0;
  localparam bit          PipelineResponse = 1'b0;
  // axi lite reg
  localparam int unsigned AXI_REG_NUM_BYTES   = 32'd100;  // axi_reg's
  //apb reg
  localparam int unsigned NO_APB_REGS    = 32'd32;
  localparam int unsigned APB_ADDR_WIDTH = 32'd32;
  localparam int unsigned APB_DATA_WIDTH = 32'd32;
  localparam int unsigned REG_DATA_WIDTH = 32'd32;   //讀寫的寬度

  typedef logic [AXI_ADDR_WIDTH-1:0]  addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0]  data_t;
  typedef logic [AXI_STRB_WIDTH-1:0]  strb_t;
  typedef axi_pkg::xbar_rule_32_t     rule_t; // Has to be the same width as axi addr
  typedef logic [7:0]                 byte_t; // axi_reg's
  // -------------------------------
  // AXI Interfaces
  // -------------------------------
  // "AXI XBAR" Slave Interfaces (receive data from AXI Masters)
  // "AXI Masters" conect to these Interfaces
  AXI_LITE #( .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH), .AXI_DATA_WIDTH (AXI_DATA_WIDTH) ) axi_mst [ NO_AXI_MASTERS-1: 0] ();
  // "AXI XBAR" Master Interfaces (send data to AXI slaves)
  // "AXI Slaves" connect to these Interfaces
  AXI_LITE #( .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH), .AXI_DATA_WIDTH (AXI_DATA_WIDTH) ) axi_slv  [  NO_AXI_SLAVES-1: 0] ();


// =============================================================================================================
  // CLK
  logic                           G0_CPU_RST_N;
  logic                           AXI_RST_N   ;
  logic                           APB_RST_N   ;
  logic                           I2C_RST_N   ;
  logic                           IMP_RST_N   ;
  logic                           G0_CPU_CLK  ;
  logic                           AXI_CLK     ;
  logic                           APB_CLK     ;
  logic                           I2C_CLK     ;
  logic                           IMP_CLK     ;

  // axi lite reg
  byte_t [AXI_REG_NUM_BYTES-1: 0] reg_q_rdat;
  logic  [15 : 0]                 MST_U0_WR_IMP_HSIZE;
  logic  [15 : 0]                 MST_U0_RD_IMP_HSIZE;
  logic  [ 7 : 0]                 MST_U0_WR_IMP_COOR_MINX;
  logic  [ 7 : 0]                 MST_U0_RD_IMP_COOR_MINX;
  logic  [15 : 0]                 MST_U0_WR_IMP_VSIZE;
  logic  [15 : 0]                 MST_U0_RD_IMP_VSIZE;
  logic  [ 7 : 0]                 MST_U0_WR_IMP_COOR_MINY;
  logic  [ 7 : 0]                 MST_U0_RD_IMP_COOR_MINY;
  logic  [31 : 0]                 MST_U0_WR_IMP_ADR_PITCH;
  logic  [31 : 0]                 MST_U0_RD_IMP_ADR_PITCH;
  logic  [31 : 0]                 MST_U0_WR_IMP_DST_BADDR;
  logic  [31 : 0]                 MST_U0_RD_IMP_SRC_BADDR;
  logic                           MST_U0_WR_IMP_ST;
  logic                           MST_U0_RD_IMP_ST;

  // apb
  logic [AXI_ADDR_WIDTH-1 :0]                       apb_paddr_o;
  logic [NO_APB_SLAVES -1 :0]                       apb_pselx_o;
  logic [               2 :0]                       apb_pprot_o;
  logic                                             apb_penable_o;
  logic                                             apb_pwrite_o;
  logic [AXI_DATA_WIDTH-1 :0]                       apb_pwdata_o;
  logic [AXI_STRB_WIDTH-1 :0]                       apb_pstrb_o;
  logic [NO_APB_SLAVES -1 :0]                       apb_pready_i;
  logic [NO_APB_SLAVES -1 :0] [AXI_DATA_WIDTH-1 :0] apb_prdata_i;
  logic [NO_APB_SLAVES -1 :0]                       apb_pslverr_i;
  logic [REG_DATA_WIDTH-1 :0] [NO_APB_REGS-1    :0] apb_reg_data_o;

  // APB CRG
  wire        [ 3: 0]             REG_CLK_DIV_CPU  ;
  wire                            REG_CLK_TOG_CPU  ;
  wire                            REG_CLK_CKEN_CPU ;
  wire        [ 3: 0]             REG_CLK_DIV_AXI  ;
  wire                            REG_CLK_TOG_AXI  ;
  wire                            REG_CLK_CKEN_AXI ;
  wire        [ 3: 0]             REG_CLK_DIV_APB  ;
  wire                            REG_CLK_TOG_APB  ;
  wire                            REG_CLK_CKEN_APB ;
  wire        [ 3: 0]             REG_CLK_DIV_I2C  ;
  wire                            REG_CLK_TOG_I2C  ;
  wire                            REG_CLK_CKEN_I2C ;
  wire        [ 3: 0]             REG_CLK_DIV_IMP  ;
  wire                            REG_CLK_TOG_IMP  ;
  wire                            REG_CLK_CKEN_IMP ;
  wire                            REG_ICG_ON_CPU;
  wire                            REG_ICG_ON_AXI;
  wire                            REG_ICG_ON_APB;
  wire                            REG_ICG_ON_I2C;
  wire                            REG_ICG_ON_IMP;
  // picorv32_wrapper part
  wire                            tests_passed;
  reg         [31 : 0]            irq = 0;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// clock                 /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
ma_clks_group_gen u0_ma_clks_group_gen (
  .src_clk                        ( clk               ),
  .src_rst_n                      ( PoR_rst_n         ),
  .REG_CLK_DIV_CPU                ( REG_CLK_DIV_CPU   ),
  .REG_CLK_TOG_CPU                ( REG_CLK_TOG_CPU   ),
  .REG_CLK_CKEN_CPU               ( REG_CLK_CKEN_CPU  ),  //reset default : 1'b1
  .REG_CLK_DIV_AXI                ( REG_CLK_DIV_AXI   ),
  .REG_CLK_TOG_AXI                ( REG_CLK_TOG_AXI   ),
  .REG_CLK_CKEN_AXI               ( REG_CLK_CKEN_AXI  ),  //reset default : 1'b1
  .REG_CLK_DIV_APB                ( REG_CLK_DIV_APB   ),
  .REG_CLK_TOG_APB                ( REG_CLK_TOG_APB   ),
  .REG_CLK_CKEN_APB               ( REG_CLK_CKEN_APB  ),  //reset default : 1'b1
  .REG_CLK_DIV_I2C                ( REG_CLK_DIV_I2C   ),
  .REG_CLK_TOG_I2C                ( REG_CLK_TOG_I2C   ),
  .REG_CLK_CKEN_I2C               ( REG_CLK_CKEN_I2C  ),  //reset default : 1'b1
  .REG_CLK_DIV_IMP                ( REG_CLK_DIV_IMP   ),
  .REG_CLK_TOG_IMP                ( REG_CLK_TOG_IMP   ),
  .REG_CLK_CKEN_IMP               ( REG_CLK_CKEN_IMP  ),  //reset default : 1'b1

  .REG_ICG_ON_CPU                 ( REG_ICG_ON_CPU    ),
  .REG_ICG_ON_AXI                 ( REG_ICG_ON_AXI    ),
  .REG_ICG_ON_APB                 ( REG_ICG_ON_APB    ),
  .REG_ICG_ON_I2C                 ( REG_ICG_ON_I2C    ),
  .REG_ICG_ON_IMP                 ( REG_ICG_ON_IMP    ),

  .G0_CPU_RST_N                   ( G0_CPU_RST_N      ),
  .G0_CPU_CLK                     ( G0_CPU_CLK        ),
  .AXI_RST_N                      ( AXI_RST_N         ),
  .AXI_CLK                        ( AXI_CLK           ),
  .APB_RST_N                      ( APB_RST_N         ),
  .APB_CLK                        ( APB_CLK           ),
  .I2C_RST_N                      ( I2C_RST_N         ),
  .I2C_CLK                        ( I2C_CLK           ),
  .IMP_RST_N                      ( IMP_RST_N         ),
  .IMP_CLK                        ( IMP_CLK           )
);


// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
// ************************************************************************************************************** //
//    $$$$$$\   $$\   $$\  $$$$$$\       $$$$$$$\   $$$$$$$$\   $$$$$$\                                           //
//   $$  __$$\  $$ |  $$ | \_$$  _|      $$  __$$\  $$  _____| $$  __$$\                                          //
//   $$ /  $$ | \$$\ $$  |   $$ |        $$ |  $$ | $$ |       $$ /  \__|                                         //
//   $$$$$$$$ |  \$$$$  /    $$ |        $$$$$$$  | $$$$$\     $$ |$$$$\                                          //
//   $$  __$$ |  $$  $$<     $$ |        $$  __$$<  $$  __|    $$ |\_$$ |                                         //
//   $$ |  $$ | $$  /\$$\    $$ |        $$ |  $$ | $$ |       $$ |  $$ |                                         //
//   $$ |  $$ | $$ /  $$ | $$$$$$\       $$ |  $$ | $$$$$$$$\  \$$$$$$  |                                         //
//   \__|  \__| \__|  \__| \______|      \__|  \__| \________|  \______/                                          //
// ************************************************************************************************************** //
axi_lite_reg_intf_wrap #(
  .REG_NUM_BYTE                   ( AXI_REG_NUM_BYTES   ),
  .AXI_ADDR_WIDTH                 ( AXI_ADDR_WIDTH      ),
  .AXI_DATA_WIDTH                 ( AXI_DATA_WIDTH      ),
  .byte_t                         ( byte_t              )
) u0_axi_lite_reg_warp (
  .rst_n                          ( AXI_RST_N                           ),
  .clk                            ( AXI_CLK                             ),
  .slv                            ( axi_slv[`SOC_MEM_MAP_AXI_REGF0_ID]  ),

  .MST_U0_WR_IMP_HSIZE            ( MST_U0_WR_IMP_HSIZE     ),
  .MST_U0_RD_IMP_HSIZE            ( MST_U0_RD_IMP_HSIZE     ),
  .MST_U0_WR_IMP_COOR_MINX        ( MST_U0_WR_IMP_COOR_MINX ),
  .MST_U0_RD_IMP_COOR_MINX        ( MST_U0_RD_IMP_COOR_MINX ),
  .MST_U0_WR_IMP_VSIZE            ( MST_U0_WR_IMP_VSIZE     ),
  .MST_U0_RD_IMP_VSIZE            ( MST_U0_RD_IMP_VSIZE     ),
  .MST_U0_WR_IMP_COOR_MINY        ( MST_U0_WR_IMP_COOR_MINY ),
  .MST_U0_RD_IMP_COOR_MINY        ( MST_U0_RD_IMP_COOR_MINY ),
  .MST_U0_WR_IMP_ADR_PITCH        ( MST_U0_WR_IMP_ADR_PITCH ),
  .MST_U0_RD_IMP_ADR_PITCH        ( MST_U0_RD_IMP_ADR_PITCH ),
  .MST_U0_WR_IMP_DST_BADDR        ( MST_U0_WR_IMP_DST_BADDR ),
  .MST_U0_RD_IMP_SRC_BADDR        ( MST_U0_RD_IMP_SRC_BADDR ),
  .MST_U0_WR_IMP_ST               ( MST_U0_WR_IMP_ST        ),
  .MST_U0_RD_IMP_ST               ( MST_U0_RD_IMP_ST        )
);
// ************************************************************************************************************** //
//    $$$$$$\   $$$$$$$\   $$$$$$$\        $$$$$$$\   $$$$$$$$\   $$$$$$\                                         //
//   $$  __$$\  $$  __$$\  $$  __$$\       $$  __$$\  $$  _____| $$  __$$\                                        //
//   $$ /  $$ | $$ |  $$ | $$ |  $$ |      $$ |  $$ | $$ |       $$ /  \__|                                       //
//   $$$$$$$$ | $$$$$$$  | $$$$$$$\ |      $$$$$$$  | $$$$$\     $$ |$$$$\                                        //
//   $$  __$$ | $$  ____/  $$  __$$\       $$  __$$<  $$  __|    $$ |\_$$ |                                       //
//   $$ |  $$ | $$ |       $$ |  $$ |      $$ |  $$ | $$ |       $$ |  $$ |                                       //
//   $$ |  $$ | $$ |       $$$$$$$  |      $$ |  $$ | $$$$$$$$\  \$$$$$$  |                                       //
//   \__|  \__| \__|       \_______/       \__|  \__| \________|  \______/                                        //
// ************************************************************************************************************** //
apb_regs_intf_wrap #(
  .NO_APB_REGS                    ( NO_APB_REGS           ),
  .APB_ADDR_WIDTH                 ( APB_ADDR_WIDTH        ),
  .APB_DATA_WIDTH                 ( APB_DATA_WIDTH        ),
  .REG_DATA_WIDTH                 ( REG_DATA_WIDTH        )
) i_apb_regs_intf_wrap (
  .p_rst_n                        ( APB_RST_N             ),
  .p_clk                          ( APB_CLK               ),
  .apb_reg_paddr                  ( apb_paddr_o           ),
  .apb_reg_pprot                  ( apb_pprot_o           ),
  .apb_reg_psel                   ( apb_pselx_o[0]        ),
  .apb_reg_penable                ( apb_penable_o         ),
  .apb_reg_pwrite                 ( apb_pwrite_o          ),
  .apb_reg_pwdata                 ( apb_pwdata_o          ),
  .apb_reg_pstrb                  ( apb_pstrb_o           ),
  .apb_reg_pready                 ( apb_pready_i[0]       ),
  .apb_reg_prdata                 ( apb_prdata_i[0]       ),
  .apb_reg_pslverr                ( apb_pslverr_i[0]      ),

  .REG_CLK_DIV_CPU                ( REG_CLK_DIV_CPU       ),                              // fw : 0x0011_0000
  .REG_CLK_TOG_CPU                ( REG_CLK_TOG_CPU       ),                              // fw : 0x0011_0004
  .REG_CLK_CKEN_CPU               ( REG_CLK_CKEN_CPU      ),                              // fw : 0x0011_0004
  .REG_CLK_DIV_AXI                ( REG_CLK_DIV_AXI       ),                              // fw : 0x0011_0000
  .REG_CLK_TOG_AXI                ( REG_CLK_TOG_AXI       ),                              // fw : 0x0011_0004
  .REG_CLK_CKEN_AXI               ( REG_CLK_CKEN_AXI      ),                              // fw : 0x0011_0004
  .REG_CLK_DIV_APB                ( REG_CLK_DIV_APB       ),                              // fw : 0x0011_0000
  .REG_CLK_TOG_APB                ( REG_CLK_TOG_APB       ),                              // fw : 0x0011_0004
  .REG_CLK_CKEN_APB               ( REG_CLK_CKEN_APB      ),                              // fw : 0x0011_0004
  .REG_CLK_DIV_I2C                ( REG_CLK_DIV_I2C       ),                              // fw : 0x0011_0000
  .REG_CLK_TOG_I2C                ( REG_CLK_TOG_I2C       ),                              // fw : 0x0011_0004
  .REG_CLK_CKEN_I2C               ( REG_CLK_CKEN_I2C      ),                              // fw : 0x0011_0004
  .REG_CLK_DIV_IMP                ( REG_CLK_DIV_IMP       ),                              // fw : 0x0011_0000
  .REG_CLK_TOG_IMP                ( REG_CLK_TOG_IMP       ),                              // fw : 0x0011_0004
  .REG_CLK_CKEN_IMP               ( REG_CLK_CKEN_IMP      ),                              // fw : 0x0011_0004
  .REG_ICG_ON_CPU                 ( REG_ICG_ON_CPU        ),                              // fw : 0x0011_0008
  .REG_ICG_ON_AXI                 ( REG_ICG_ON_AXI        ),                              // fw : 0x0011_0008
  .REG_ICG_ON_APB                 ( REG_ICG_ON_APB        ),                              // fw : 0x0011_0008
  .REG_ICG_ON_I2C                 ( REG_ICG_ON_I2C        ),                              // fw : 0x0011_0008
  .REG_ICG_ON_IMP                 ( REG_ICG_ON_IMP        )                               // fw : 0x0011_0008
);
// ************************************************************************************************************** //
//    $$$$$$\    $$$$$$$\    $$\   $$\                                                                            //
//   $$  __$$\   $$  __$$\   $$ |  $$ |                                                                           //
//   $$ /  \__|  $$ |  $$ |  $$ |  $$ |                                                                           //
//   $$ |        $$$$$$$  |  $$ |  $$ |                                                                           //
//   $$ |        $$  ____/   $$ |  $$ |                                                                           //
//   $$ |  $$\   $$ |        $$ |  $$ |                                                                           //
//   \$$$$$$  |  $$ |        \$$$$$$  |                                                                           //
//    \______/   \__|         \______/                                                                            //
// ************************************************************************************************************** //
picorv32_axi #(
`ifndef SYNTH_TEST
  `ifdef SP_TEST
    .ENABLE_REGS_DUALPORT         (0),
  `endif
  `ifdef COMPRESSED_ISA
    .COMPRESSED_ISA               (1),
  `endif
  .ENABLE_MUL                     (1),
  .ENABLE_DIV                     (1),
  .ENABLE_IRQ                     (1),
  .ENABLE_TRACE                   (1)
`endif
) u0_picorv32_axi (
  .resetn                         ( G0_CPU_RST_N        ),
  .clk                            ( G0_CPU_CLK          ),
  .trap                           ( trap                ),
  .mem_axi_awvalid                ( axi_mst[0].aw_valid ), // o
  .mem_axi_awready                ( axi_mst[0].aw_ready ), // i
  .mem_axi_awaddr                 ( axi_mst[0].aw_addr  ), // o
  .mem_axi_awprot                 ( axi_mst[0].aw_prot  ), // o
  .mem_axi_wvalid                 ( axi_mst[0].w_valid  ), // o
  .mem_axi_wready                 ( axi_mst[0].w_ready  ), // i
  .mem_axi_wdata                  ( axi_mst[0].w_data   ), // o
  .mem_axi_wstrb                  ( axi_mst[0].w_strb   ), // o
  .mem_axi_bvalid                 ( axi_mst[0].b_valid  ), // i
  .mem_axi_bready                 ( axi_mst[0].b_ready  ), // o
  .mem_axi_arvalid                ( axi_mst[0].ar_valid ), // o
  .mem_axi_arready                ( axi_mst[0].ar_ready ), // i
  .mem_axi_araddr                 ( axi_mst[0].ar_addr  ), // o
  .mem_axi_arprot                 ( axi_mst[0].ar_prot  ), // o
  .mem_axi_rvalid                 ( axi_mst[0].r_valid  ), // i
  .mem_axi_rready                 ( axi_mst[0].r_ready  ), // o
  .mem_axi_rdata                  ( axi_mst[0].r_data   ), // i
  .irq                            ( irq                            ),
  .trace_valid                    ( trace_valid                    ),
  .trace_data                     ( trace_data                     )
);
//rst_11 = por_rst && fw
//always_ff @(posedge clk or negedge rst_11) begin : proc_
//  if(~rst_11) begin
//    rst_n_vec <= 2'b0;
//  end else begin
//    rst_n_vec <= {rst_n_vec[0] , 1'b1};
//
//  end
//end

// ************************************************************************************************************** //
//   $$$$$$\  $$\      $$\  $$$$$$$\                                                                                //
//   \_$$  _| $$$\    $$$ | $$  __$$\                                                                               //
//     $$ |   $$$$\  $$$$ | $$ |  $$ |                                                                              //
//     $$ |   $$\$$\$$ $$ | $$$$$$$  |                                                                              //
//     $$ |   $$ \$$$  $$ | $$  ____/                                                                               //
//     $$ |   $$ |\$  /$$ | $$ |                                                                                    //
//   $$$$$$\  $$ | \_/ $$ | $$ |                                                                                    //
//   \______| \__|     \__| \__|                                                                                    //
// ************************************************************************************************************** //

mst_imp_wrap #(
  .REG_NUM_BYTES                  ( AXI_REG_NUM_BYTES       ),
  .AXI_ADDR_WIDTH                 ( AXI_ADDR_WIDTH          ),
  .AXI_DATA_WIDTH                 ( AXI_DATA_WIDTH          ),
  //.PITCH_WIDTH                    ( 9                       ),
  .byte_t                         ( byte_t                  )
) u0_mst_imp_wrap (
  .rst_n_IMP                      ( IMP_RST_N               ), // TODO
  .clk_IMP                        ( IMP_CLK                 ),
  //.reg_q_rdat                     ( reg_q_rdat              ), // input from Register File Wrapper Config.
  .mst_imp                        ( axi_mst[1]              ),

  .MST_U0_WR_IMP_HSIZE            ( MST_U0_WR_IMP_HSIZE     ),
  .MST_U0_RD_IMP_HSIZE            ( MST_U0_RD_IMP_HSIZE     ),
  .MST_U0_WR_IMP_COOR_MINX        ( MST_U0_WR_IMP_COOR_MINX ),
  .MST_U0_RD_IMP_COOR_MINX        ( MST_U0_RD_IMP_COOR_MINX ),
  .MST_U0_WR_IMP_VSIZE            ( MST_U0_WR_IMP_VSIZE     ),
  .MST_U0_RD_IMP_VSIZE            ( MST_U0_RD_IMP_VSIZE     ),
  .MST_U0_WR_IMP_COOR_MINY        ( MST_U0_WR_IMP_COOR_MINY ),
  .MST_U0_RD_IMP_COOR_MINY        ( MST_U0_RD_IMP_COOR_MINY ),
  .MST_U0_WR_IMP_ADR_PITCH        ( MST_U0_WR_IMP_ADR_PITCH ),
  .MST_U0_RD_IMP_ADR_PITCH        ( MST_U0_RD_IMP_ADR_PITCH ),
  .MST_U0_WR_IMP_DST_BADDR        ( MST_U0_WR_IMP_DST_BADDR ),
  .MST_U0_RD_IMP_SRC_BADDR        ( MST_U0_RD_IMP_SRC_BADDR ),
  .MST_U0_WR_IMP_ST               ( MST_U0_WR_IMP_ST        ),
  .MST_U0_RD_IMP_ST               ( MST_U0_RD_IMP_ST        )
);

// ************************************************************************************************************** //
//  $$$$$$$\     $$$$$$\     $$$$$$\    $$\   $$\   $$$$$$$\     $$$$$$\    $$\   $$\   $$$$$$$$\                 //
// $$  __$$\   $$  __$$\   $$  __$$\   $$ | $$  |  $$  __$$\   $$  __$$\   $$$\  $$ |  $$  _____|                 //
// $$ |  $$ |  $$ /  $$ |  $$ /  \__|  $$ |$$  /   $$ |  $$ |  $$ /  $$ |  $$$$\ $$ |  $$ |                       //
// $$$$$$$\ |  $$$$$$$$ |  $$ |        $$$$$  /    $$$$$$$\ |  $$ |  $$ |  $$ $$\$$ |  $$$$$\                     //
// $$  __$$\   $$  __$$ |  $$ |        $$  $$<     $$  __$$\   $$ |  $$ |  $$ \$$$$ |  $$  __|                    //
// $$ |  $$ |  $$ |  $$ |  $$ |  $$\   $$ |\$$\    $$ |  $$ |  $$ |  $$ |  $$ |\$$$ |  $$ |                       //
// $$$$$$$  |  $$ |  $$ |  \$$$$$$  |  $$ | \$$\   $$$$$$$  |   $$$$$$  |  $$ | \$$ |  $$$$$$$$\                  //
// \_______/   \__|  \__|   \______/   \__|  \__|  \_______/    \______/   \__|  \__|  \________|                 //
// ************************************************************************************************************** //
BACKBONE #(
  .AXI_ADDR_WIDTH                 ( AXI_ADDR_WIDTH        ),
  .AXI_DATA_WIDTH                 ( AXI_DATA_WIDTH        ),
  .NO_AXI_MASTERS                 ( NO_AXI_MASTERS        ),
  .NO_AXI_SLAVES                  ( NO_AXI_SLAVES         ),
  .NO_APB_SLAVES                  ( NO_APB_SLAVES         ),
  .NO_APB_RULES                   ( NO_APB_RULES          ),
  .PipelineRequest                ( PipelineRequest       ),
  .PipelineResponse               ( PipelineResponse      )
) u0_BACKBONE (
  .ARSTnMS_ACLK                   ( AXI_RST_N             ),
  .ACLKMST_ACLK                   ( AXI_CLK               ),
  .connect_mst                    ( axi_mst               ),
  .connect_slv                    ( axi_slv               ),

  .PRSTnMS_PCLK                   ( APB_RST_N             ),
  .PCLKMST_PCLK                   ( APB_CLK               ),
  .apb_paddr_o                    ( apb_paddr_o           ),
  .apb_pprot_o                    ( apb_pprot_o           ),
  .apb_pselx_o                    ( apb_pselx_o           ),
  .apb_penable_o                  ( apb_penable_o         ),
  .apb_pwrite_o                   ( apb_pwrite_o          ),
  .apb_pwdata_o                   ( apb_pwdata_o          ),
  .apb_pstrb_o                    ( apb_pstrb_o           ),
  .apb_pready_i                   ( apb_pready_i          ), //{NO_APB_SLAVES{1'b1}} ),
  .apb_prdata_i                   ( apb_prdata_i          ), //{NO_APB_SLAVES{'b0}}  ),
  .apb_pslverr_i                  ( apb_pslverr_i         )  //{NO_APB_SLAVES{1'b0}} )
);

// ************************************************************************************************************** //
//                                  $$\           $$\                                    $$\                      //
//                                  \__|          $$ |                                   $$ |                     //
//     $$$$$$\   $$$$$$\   $$$$$$\  $$\  $$$$$$\  $$$$$$$\   $$$$$$\   $$$$$$\  $$$$$$\  $$ |                     //
//    $$  __$$\ $$  __$$\ $$  __$$\ $$ |$$  __$$\ $$  __$$\ $$  __$$\ $$  __$$\ \____$$\ $$ |                     //
//    $$ /  $$ |$$$$$$$$ |$$ |  \__|$$ |$$ /  $$ |$$ |  $$ |$$$$$$$$ |$$ |  \__|$$$$$$$ |$$ |                     //
//    $$ |  $$ |$$   ____|$$ |      $$ |$$ |  $$ |$$ |  $$ |$$   ____|$$ |     $$  __$$ |$$ |                     //
//    $$$$$$$  |\$$$$$$$\ $$ |      $$ |$$$$$$$  |$$ |  $$ |\$$$$$$$\ $$ |     \$$$$$$$ |$$ |                     //
//    $$  ____/  \_______|\__|      \__|$$  ____/ \__|  \__| \_______|\__|      \_______|\__|                     //
//    $$ |                              $$ |                                                                      //
//    $$ |                              $$ |                                                                      //
//    \__|                              \__|                                                                      //
// ************************************************************************************************************** //

  logic [31:0] i2c_prdata_o ;
  logic        i2c_pready_o ;
  logic        i2c_pslverr_o;
  logic        interrupt_o;
  logic        scl_pad_i;
  logic        scl_pad_o;
  logic        scl_padoen_o;
  logic        sda_pad_i;
  logic        sda_pad_o;
  logic        sda_padoen_o;
apb_i2c #(
  .APB_ADDR_WIDTH              ( 12             )
) i_apb_i2c                    (
  .HCLK                        ( I2C_CLK            ),  // i
  .HRESETn                     ( I2C_RST_N          ),  // i
  .PADDR                       ( apb_paddr_o[11:0]  ),  // i
  .PWDATA                      ( apb_pwdata_o       ),  // i
  .PWRITE                      ( apb_pwrite_o       ),  // i
  .PSEL                        ( apb_pselx_o[1]     ),  // i
  .PENABLE                     ( apb_penable_o      ),  // i
  .PRDATA                      ( apb_prdata_i[1]    ),  // o
  .PREADY                      ( apb_pready_i[1]    ),  // o
  .PSLVERR                     ( apb_pslverr_i[1]   ),  // o
  .interrupt_o                 ( /*interrupt_o  */      ),
  .scl_pad_i                   ( /*scl_pad_i    */      ),
  .scl_pad_o                   ( /*scl_pad_o    */      ),
  .scl_padoen_o                ( /*scl_padoen_o */      ),
  .sda_pad_i                   ( /*sda_pad_i    */      ),
  .sda_pad_o                   ( /*sda_pad_o    */      ),
  .sda_padoen_o                ( /*sda_padoen_o */      )
);

// ************************************************************************************************************** //
//   $$\      $$\   $$$$$$$$\   $$\      $$\    $$$$$$\    $$$$$$$\ $  $\     $$\                                 //
//   $$$\    $$$ |  $$  _____|  $$$\    $$$ |  $$  __$$\   $$  __$$\\  $$\   $$  |                                //
//   $$$$\  $$$$ |  $$ |        $$$$\  $$$$ |  $$ /  $$ |  $$ |  $$ |  \$$\ $$  /                                 //
//   $$\$$\$$ $$ |  $$$$$\      $$\$$\$$ $$ |  $$ |  $$ |  $$$$$$$  |   \$$$$  /                                  //
//   $$ \$$$  $$ |  $$  __|     $$ \$$$  $$ |  $$ |  $$ |  $$  __$$<     \$$  /                                   //
//   $$ |\$  /$$ |  $$ |        $$ |\$  /$$ |  $$ |  $$ |  $$ |  $$ |     $$ |                                    //
//   $$ | \_/ $$ |  $$$$$$$$\   $$ | \_/ $$ |   $$$$$$  |  $$ |  $$ |     $$ |                                    //
//   \__|     \__|  \________|  \__|     \__|   \______/   \__|  \__|     \__|                                    //
// ************************************************************************************************************** //
axi4_memory #(
  .AXI_TEST                       ( AXI_TEST          ),
  .VERBOSE                        ( VERBOSE           )
) u0_pulp_axi4_mem (
  .clk                            ( AXI_CLK             ),
  .mem_axi_awvalid                ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].aw_valid ),  // i
  .mem_axi_awready                ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].aw_ready ),  // o
  .mem_axi_awaddr                 ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].aw_addr  ),  // i
  .mem_axi_awprot                 ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].aw_prot  ),  // i
  .mem_axi_wvalid                 ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].w_valid  ),  // i
  .mem_axi_wready                 ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].w_ready  ),  // o
  .mem_axi_wdata                  ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].w_data   ),  // i
  .mem_axi_wstrb                  ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].w_strb   ),  // i
  .mem_axi_bvalid                 ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].b_valid  ),  // o
  .mem_axi_bready                 ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].b_ready  ),  // i
  .mem_axi_bresp                  ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].b_resp   ),  // o
  .mem_axi_arvalid                ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].ar_valid ),  // i
  .mem_axi_arready                ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].ar_ready ),  // o
  .mem_axi_araddr                 ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].ar_addr  ),  // i
  .mem_axi_arprot                 ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].ar_prot  ),  // i
  .mem_axi_rvalid                 ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].r_valid  ),  // o
  .mem_axi_rready                 ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].r_ready  ),  // i
  .mem_axi_rdata                  ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].r_data   ),  // o
  .mem_axi_rresp                  ( axi_slv[`SOC_MEM_MAP_AXI_ROM0_ID].r_resp   ),  // o
  .tests_passed                   ( tests_passed                  )   // o
);

axi_lite_memory u0_axi_lite_memory (
  .rst_n                          ( AXI_RST_N           ),
  .clk                            ( AXI_CLK             ),
  .s_aw_valid                     ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].aw_valid ),
  .s_aw_ready                     ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].aw_ready ),
  .s_aw_addr                      ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].aw_addr  ),
  .s_aw_prot                      ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].aw_prot  ),
  .s_w_valid                      ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].w_valid  ),
  .s_w_ready                      ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].w_ready  ),
  .s_w_data                       ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].w_data   ),
  .s_w_strb                       ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].w_strb   ),
  .s_b_valid                      ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].b_valid  ),
  .s_b_ready                      ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].b_ready  ),
  .s_b_resp                       ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].b_resp   ),
  .s_ar_valid                     ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].ar_valid ),
  .s_ar_ready                     ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].ar_ready ),
  .s_ar_addr                      ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].ar_addr  ),
  .s_ar_prot                      ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].ar_prot  ),
  .s_r_valid                      ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].r_valid  ),
  .s_r_ready                      ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].r_ready  ),
  .s_r_data                       ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].r_data   ),
  .s_r_resp                       ( axi_slv[`SOC_MEM_MAP_AXI_RAM1_ID].r_resp   )
);

axi_lite_imp_memory u0_axi_lite_imp_memory (
  .rst_n                          ( AXI_RST_N           ),
  .clk                            ( AXI_CLK             ),
  .s_aw_valid                     ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].aw_valid ),
  .s_aw_ready                     ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].aw_ready ),
  .s_aw_addr                      ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].aw_addr  ),
  .s_aw_prot                      ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].aw_prot  ),
  .s_w_valid                      ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].w_valid  ),
  .s_w_ready                      ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].w_ready  ),
  .s_w_data                       ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].w_data   ),
  .s_w_strb                       ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].w_strb   ),
  .s_b_valid                      ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].b_valid  ),
  .s_b_ready                      ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].b_ready  ),
  .s_b_resp                       ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].b_resp   ),
  .s_ar_valid                     ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].ar_valid ),
  .s_ar_ready                     ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].ar_ready ),
  .s_ar_addr                      ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].ar_addr  ),
  .s_ar_prot                      ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].ar_prot  ),
  .s_r_valid                      ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].r_valid  ),
  .s_r_ready                      ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].r_ready  ),
  .s_r_data                       ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].r_data   ),
  .s_r_resp                       ( axi_slv[`SOC_MEM_MAP_AXI_IMPI_ID].r_resp   )
);


// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
// moniter
print i_print (
  .clk            ( G0_CPU_CLK          ),
  .mem_axi_awvalid( axi_mst[0].aw_valid ),
  .mem_axi_awaddr ( axi_mst[0].aw_addr  ),
  .mem_axi_wvalid ( axi_mst[0].w_valid  ),
  .mem_axi_wdata  ( axi_mst[0].w_data   )
);

endmodule