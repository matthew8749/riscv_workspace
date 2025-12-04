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
  input                           rst_n,
  output wire                     trap,
  output wire                     trace_valid,
  output wire [35 : 0]            trace_data
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  // axi configurationS
  localparam int unsigned AXI_ADDR_WIDTH = 32'd32;  // Axi Address Width
  localparam int unsigned AXI_DATA_WIDTH = 32'd32;  // Axi Data Width
  localparam int unsigned NO_AXI_MASTERS = 32'd2;   // How many Axi Masters there are
  localparam int unsigned NO_AXI_SLAVES  = 32'd3;   // How many Axi Slaves  there are
                                                   // BUT!! APB Bridge is not included because it is enclosed within it.
  localparam int unsigned AXI_STRB_WIDTH =  AXI_DATA_WIDTH / 32'd8;
  //apb
  localparam int unsigned NO_APB_SLAVES    = 32'd1;
  localparam int unsigned NO_APB_RULES     = 32'd1;    // How many address rules for the APB slaves
  localparam bit          PipelineRequest  = 1'b0;
  localparam bit          PipelineResponse = 1'b0;
  // axi lite reg
  localparam int unsigned TbRegNumBytes    = 32'd100;  // axi_reg's
  //apb reg
  localparam int unsigned NO_APB_REGS    = 32'd32;
  localparam int unsigned APB_ADDR_WIDTH = 32'd32;
  localparam int unsigned APB_DATA_WIDTH = 32'd32;
  localparam int unsigned REG_DATA_WIDTH = 32'd32;

  typedef logic [AXI_ADDR_WIDTH-1:0]  addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0]  data_t;
  typedef logic [AXI_STRB_WIDTH-1:0]  strb_t;
  typedef axi_pkg::xbar_rule_32_t     rule_t; // Has to be the same width as axi addr
  typedef logic [7:0]                 byte_t; // axi_reg's

  // axi lite reg
  byte_t [TbRegNumBytes-1:0]                        reg_q_rdat;

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


  logic [REG_DATA_WIDTH-1:0] [NO_APB_REGS-1:0]  apb_reg_data_o;

  // picorv32_wrapper part
  wire                            tests_passed;
  reg         [31 : 0]            irq = 0;

  // -------------------------------
  // AXI Interfaces
  // -------------------------------
  // "AXI XBAR" Slave Interfaces (receive data from AXI Masters)
  // "AXI Masters" conect to these Interfaces
  AXI_LITE #( .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH), .AXI_DATA_WIDTH (AXI_DATA_WIDTH) ) master_to_backbone [ NO_AXI_MASTERS-1: 0] ();
  // "AXI XBAR" Master Interfaces (send data to AXI slaves)
  // "AXI Slaves" connect to these Interfaces
  AXI_LITE #( .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH), .AXI_DATA_WIDTH (AXI_DATA_WIDTH) ) backbone_to_slave  [  NO_AXI_SLAVES-1: 0] ();

// tag OUTs assignment ---------------------------------------------------------------------------------------------
// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------

// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
// ************************************************************************************************************** //
//    $$$$$$\  $$\   $$\ $$$$$$\       $$$$$$$\  $$$$$$$$\  $$$$$$\                                               //
//   $$  __$$\ $$ |  $$ |\_$$  _|      $$  __$$\ $$  _____|$$  __$$\                                              //
//   $$ /  $$ |\$$\ $$  |  $$ |        $$ |  $$ |$$ |      $$ /  \__|                                             //
//   $$$$$$$$ | \$$$$  /   $$ |        $$$$$$$  |$$$$$\    $$ |$$$$\                                              //
//   $$  __$$ | $$  $$<    $$ |        $$  __$$< $$  __|   $$ |\_$$ |                                             //
//   $$ |  $$ |$$  /\$$\   $$ |        $$ |  $$ |$$ |      $$ |  $$ |                                             //
//   $$ |  $$ |$$ /  $$ |$$$$$$\       $$ |  $$ |$$$$$$$$\ \$$$$$$  |                                             //
//   \__|  \__|\__|  \__|\______|      \__|  \__|\________| \______/                                              //
// ************************************************************************************************************** //
axi_lite_regfile_intf_wrapper #(
  .REG_NUM_BYTE                   ( TbRegNumBytes   ),
  .AXI_ADDR_WIDTH                 ( AXI_ADDR_WIDTH  ),
  .AXI_DATA_WIDTH                 ( AXI_DATA_WIDTH  ),
  .byte_t                         ( byte_t          )
) u0_axi_lite_reg_warpper (
  .rst_n                          ( rst_n                ),
  .clk                            ( clk                  ),
  .reg_q_rdat                     ( reg_q_rdat           ),  //output
  .slv                            ( backbone_to_slave[2] )
);
// ************************************************************************************************************** //
//    $$$$$$\  $$$$$$$\  $$\   $$\                                                                                //
//   $$  __$$\ $$  __$$\ $$ |  $$ |                                                                               //
//   $$ /  \__|$$ |  $$ |$$ |  $$ |                                                                               //
//   $$ |      $$$$$$$  |$$ |  $$ |                                                                               //
//   $$ |      $$  ____/ $$ |  $$ |                                                                               //
//   $$ |  $$\ $$ |      $$ |  $$ |                                                                               //
//   \$$$$$$  |$$ |      \$$$$$$  |                                                                               //
//    \______/ \__|       \______/                                                                                //
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
  .resetn                         ( rst_n              ),
  .clk                            ( clk                ),
  .trap                           ( trap               ),
  .mem_axi_awvalid                ( master_to_backbone[0].aw_valid ), // o
  .mem_axi_awready                ( master_to_backbone[0].aw_ready ), // i
  .mem_axi_awaddr                 ( master_to_backbone[0].aw_addr  ), // o
  .mem_axi_awprot                 ( master_to_backbone[0].aw_prot  ), // o
  .mem_axi_wvalid                 ( master_to_backbone[0].w_valid  ), // o
  .mem_axi_wready                 ( master_to_backbone[0].w_ready  ), // i
  .mem_axi_wdata                  ( master_to_backbone[0].w_data   ), // o
  .mem_axi_wstrb                  ( master_to_backbone[0].w_strb   ), // o
  .mem_axi_bvalid                 ( master_to_backbone[0].b_valid  ), // i
  .mem_axi_bready                 ( master_to_backbone[0].b_ready  ), // o
  .mem_axi_arvalid                ( master_to_backbone[0].ar_valid ), // o
  .mem_axi_arready                ( master_to_backbone[0].ar_ready ), // i
  .mem_axi_araddr                 ( master_to_backbone[0].ar_addr  ), // o
  .mem_axi_arprot                 ( master_to_backbone[0].ar_prot  ), // o
  .mem_axi_rvalid                 ( master_to_backbone[0].r_valid  ), // i
  .mem_axi_rready                 ( master_to_backbone[0].r_ready  ), // o
  .mem_axi_rdata                  ( master_to_backbone[0].r_data   ), // i
  .irq                            ( irq                            ),
  .trace_valid                    ( trace_valid                    ),
  .trace_data                     ( trace_data                     )
);

mst_imp_wrapper #(
  .REG_NUM_BYTES                  ( TbRegNumBytes   ),
  .AXI_ADDR_WIDTH                 ( AXI_ADDR_WIDTH  ),
  .AXI_DATA_WIDTH                 ( AXI_DATA_WIDTH  ),
  .PITCH_WIDTH                    ( 9               ),
  .byte_t                         ( byte_t          )
) u0_mst_imp_wrapper (
  .rst_n                          ( rst_n                  ),
  .clk                            ( clk                    ),
  .reg_q_rdat                     ( reg_q_rdat             ), // input from Register File Wrapper Config.
  .mst_imp                        ( master_to_backbone[1]  )
);

// ************************************************************************************************************** //
//  $$$$$$$\   $$$$$$\   $$$$$$\  $$\   $$\ $$$$$$$\   $$$$$$\  $$\   $$\ $$$$$$$$\                               //
// $$  __$$\ $$  __$$\ $$  __$$\ $$ | $$  |$$  __$$\ $$  __$$\ $$$\  $$ |$$  _____|                               //
// $$ |  $$ |$$ /  $$ |$$ /  \__|$$ |$$  / $$ |  $$ |$$ /  $$ |$$$$\ $$ |$$ |                                     //
// $$$$$$$\ |$$$$$$$$ |$$ |      $$$$$  /  $$$$$$$\ |$$ |  $$ |$$ $$\$$ |$$$$$\                                   //
// $$  __$$\ $$  __$$ |$$ |      $$  $$<   $$  __$$\ $$ |  $$ |$$ \$$$$ |$$  __|                                  //
// $$ |  $$ |$$ |  $$ |$$ |  $$\ $$ |\$$\  $$ |  $$ |$$ |  $$ |$$ |\$$$ |$$ |                                     //
// $$$$$$$  |$$ |  $$ |\$$$$$$  |$$ | \$$\ $$$$$$$  | $$$$$$  |$$ | \$$ |$$$$$$$$\                                //
// \_______/ \__|  \__| \______/ \__|  \__|\_______/  \______/ \__|  \__|\________|                               //
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
  .ARSTnMS_ACLK                   ( rst_n                 ),
  .ACLKMST_ACLK                   ( clk                   ),
  .connect_mst                    ( master_to_backbone    ),
  .connect_slv                    ( backbone_to_slave     ),

  .PRSTnMS_PCLK                   ( rst_n                 ),
  .PCLKMST_PCLK                   ( clk                   ),
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

apb_regs_intf_wrapper #(
  .NO_APB_REGS                    ( NO_APB_REGS           ),
  .APB_ADDR_WIDTH                 ( APB_ADDR_WIDTH        ),
  .APB_DATA_WIDTH                 ( APB_DATA_WIDTH        ),
  .REG_DATA_WIDTH                 ( REG_DATA_WIDTH        )
) i_apb_regs_intf_wrapper (
  .p_rst_n                        ( rst_n                 ),
  .p_clk                          ( clk                   ),
  .apb_reg_paddr                  ( apb_paddr_o           ),
  .apb_reg_pprot                  ( apb_pprot_o           ),
  .apb_reg_psel                   ( apb_pselx_o[0]        ),
  .apb_reg_penable                ( apb_penable_o         ),
  .apb_reg_pwrite                 ( apb_pwrite_o          ),
  .apb_reg_pwdata                 ( apb_pwdata_o          ),
  .apb_reg_pstrb                  ( apb_pstrb_o           ),
  .apb_reg_pready                 ( apb_pready_i          ),
  .apb_reg_prdata                 ( apb_prdata_i          ),
  .apb_reg_pslverr                ( apb_pslverr_i         ),
  .apb_reg_data_o                 ( apb_reg_data_o        )
);
// ************************************************************************************************************** //
// $$\      $$\ $$$$$$$$\ $$\      $$\  $$$$$$\  $$$$$$$\ $$\     $$\                                             //
// $$$\    $$$ |$$  _____|$$$\    $$$ |$$  __$$\ $$  __$$\\$$\   $$  |                                            //
// $$$$\  $$$$ |$$ |      $$$$\  $$$$ |$$ /  $$ |$$ |  $$ |\$$\ $$  /                                             //
// $$\$$\$$ $$ |$$$$$\    $$\$$\$$ $$ |$$ |  $$ |$$$$$$$  | \$$$$  /                                              //
// $$ \$$$  $$ |$$  __|   $$ \$$$  $$ |$$ |  $$ |$$  __$$<   \$$  /                                               //
// $$ |\$  /$$ |$$ |      $$ |\$  /$$ |$$ |  $$ |$$ |  $$ |   $$ |                                                //
// $$ | \_/ $$ |$$$$$$$$\ $$ | \_/ $$ | $$$$$$  |$$ |  $$ |   $$ |                                                //
// \__|     \__|\________|\__|     \__| \______/ \__|  \__|   \__|                                                //
// ************************************************************************************************************** //
axi4_memory #(
  .AXI_TEST                       ( AXI_TEST          ),
  .VERBOSE                        ( VERBOSE           )
) u0_pulp_axi4_mem (
  .clk                            ( clk                           ),
  .mem_axi_awvalid                ( backbone_to_slave[0].aw_valid ),  // i
  .mem_axi_awready                ( backbone_to_slave[0].aw_ready ),  // o
  .mem_axi_awaddr                 ( backbone_to_slave[0].aw_addr  ),  // i
  .mem_axi_awprot                 ( backbone_to_slave[0].aw_prot  ),  // i
  .mem_axi_wvalid                 ( backbone_to_slave[0].w_valid  ),  // i
  .mem_axi_wready                 ( backbone_to_slave[0].w_ready  ),  // o
  .mem_axi_wdata                  ( backbone_to_slave[0].w_data   ),  // i
  .mem_axi_wstrb                  ( backbone_to_slave[0].w_strb   ),  // i
  .mem_axi_bvalid                 ( backbone_to_slave[0].b_valid  ),  // o
  .mem_axi_bready                 ( backbone_to_slave[0].b_ready  ),  // i
  .mem_axi_bresp                  ( backbone_to_slave[0].b_resp   ),  // o
  .mem_axi_arvalid                ( backbone_to_slave[0].ar_valid ),  // i
  .mem_axi_arready                ( backbone_to_slave[0].ar_ready ),  // o
  .mem_axi_araddr                 ( backbone_to_slave[0].ar_addr  ),  // i
  .mem_axi_arprot                 ( backbone_to_slave[0].ar_prot  ),  // i
  .mem_axi_rvalid                 ( backbone_to_slave[0].r_valid  ),  // o
  .mem_axi_rready                 ( backbone_to_slave[0].r_ready  ),  // i
  .mem_axi_rdata                  ( backbone_to_slave[0].r_data   ),  // o
  .mem_axi_rresp                  ( backbone_to_slave[0].r_resp   ),  // o
  .tests_passed                   ( tests_passed                  )   // o
);

axi_lite_memory u0_axi_lite_memory (
  .rst_n                          ( rst_n                         ),
  .clk                            ( clk                           ),
  .s_aw_valid                     ( backbone_to_slave[1].aw_valid ),
  .s_aw_ready                     ( backbone_to_slave[1].aw_ready ),
  .s_aw_addr                      ( backbone_to_slave[1].aw_addr  ),
  .s_aw_prot                      ( backbone_to_slave[1].aw_prot  ),
  .s_w_valid                      ( backbone_to_slave[1].w_valid  ),
  .s_w_ready                      ( backbone_to_slave[1].w_ready  ),
  .s_w_data                       ( backbone_to_slave[1].w_data   ),
  .s_w_strb                       ( backbone_to_slave[1].w_strb   ),
  .s_b_valid                      ( backbone_to_slave[1].b_valid  ),
  .s_b_ready                      ( backbone_to_slave[1].b_ready  ),
  .s_b_resp                       ( backbone_to_slave[1].b_resp   ),
  .s_ar_valid                     ( backbone_to_slave[1].ar_valid ),
  .s_ar_ready                     ( backbone_to_slave[1].ar_ready ),
  .s_ar_addr                      ( backbone_to_slave[1].ar_addr  ),
  .s_ar_prot                      ( backbone_to_slave[1].ar_prot  ),
  .s_r_valid                      ( backbone_to_slave[1].r_valid  ),
  .s_r_ready                      ( backbone_to_slave[1].r_ready  ),
  .s_r_data                       ( backbone_to_slave[1].r_data   ),
  .s_r_resp                       ( backbone_to_slave[1].r_resp   )
);

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
// moniter
print i_print (
  .clk            ( clk                ),
  .mem_axi_awvalid( master_to_backbone[0].aw_valid ),
  .mem_axi_awaddr ( master_to_backbone[0].aw_addr  ),
  .mem_axi_wvalid ( master_to_backbone[0].w_valid  ),
  .mem_axi_wdata  ( master_to_backbone[0].w_data   )
);

// picorv32_wrapper part
reg [15 : 0] count_cycle = 0;
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
          $finish;
        $stop;
      end
    end
  end

endmodule