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
  // Dut parameters
  localparam int unsigned NoMasters         = 32'd2;    // How many Axi Masters there are
  localparam int unsigned NoSlaves          = 32'd1;    // How many Axi Slaves  there are
  // axi configuration
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
    NoAddrRules:        32'd1,
    default:            '0
  };
  typedef logic [AxiAddrWidth-1:0]      addr_t;
  typedef axi_pkg::xbar_rule_32_t       rule_t; // Has to be the same width as axi addr
  typedef logic [AxiDataWidth-1:0]      data_t;
  typedef logic [AxiStrbWidth-1:0]      strb_t;

  localparam rule_t [xbar_cfg.NoAddrRules-1:0] AddrMap = '{
    '{idx: 32'd0, start_addr: 32'h0000_0000, end_addr: 32'h0001_FFFF}
    //'{idx: 32'd1, start_addr: 32'h0002_0000, end_addr: 32'h0002_FFFF}
  };

  // -------------------------------
  // AXI Interfaces
  // -------------------------------
  AXI_LITE #( .AXI_ADDR_WIDTH (AxiAddrWidth), .AXI_DATA_WIDTH (AxiDataWidth) ) master [ NoMasters-1: 0] ();
  AXI_LITE #( .AXI_ADDR_WIDTH (AxiAddrWidth), .AXI_DATA_WIDTH (AxiDataWidth) ) slave  [  NoSlaves-1: 0] ();


  logic       [ 7: 0]             IMP_HSIZE;
  logic       [ 7: 0]             IMP_COOR_MINX;
  logic       [ 7: 0]             IMP_VSIZE;
  logic       [ 7: 0]             IMP_COOR_MINY;
  logic       [32: 0]             IMP_SRC_BADDR;
  logic       [32: 0]             IMP_DST_BADDR;
  logic       [ 7: 0]             IMP_ADR_PITCH;
  wire                            imp_done;
  reg                             imp_reg_stsrt_flag;

  // picorv32_wrapper part
  wire                            tests_passed;
  reg         [31 : 0]            irq = 0;
  reg         [15 : 0]            count_cycle = 0;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------

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
  .resetn                         ( rst_n             ),
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

axi4_memory #(
  .AXI_TEST (AXI_TEST),
  .VERBOSE  (VERBOSE)
) pulp_axi4_mem (
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
  assign slave[0].b_resp = 2'b00;
  assign slave[0].r_resp = 2'b00;

axi_lite_xbar_intf #(
  .Cfg                            ( xbar_cfg ),
  .rule_t                         ( rule_t   )
) soc_xbar_dut (
  .rst_ni                         ( rst_n   ),
  .clk_i                          ( clk      ),
  .test_i                         ( 1'b0     ),
  .slv_ports                      ( master   ),
  .mst_ports                      ( slave    ),
  .addr_map_i                     ( AddrMap  ),
  .en_default_mst_port_i          ( '0       ),
  .default_mst_port_i             ( '0       )
);

  assign IMP_HSIZE                = 8'd4;
  assign IMP_COOR_MINX            = 8'd0;
  assign IMP_VSIZE                = 8'd6;
  assign IMP_COOR_MINY            = 8'd0;
  assign IMP_SRC_BADDR            = 32'b0;
  assign IMP_DST_BADDR            = 32'b0;
  assign IMP_ADR_PITCH            = 9'd16;
  assign imp_start                = imp_reg_stsrt_flag;

mst_imp i_mst_imp (
  .rst_n                          ( rst_n               ),
  .clk                            ( clk                 ),
  .mem_axi_awvalid                ( master[1].aw_valid  ),
  .mem_axi_awready                ( master[1].aw_ready  ),
  .mem_axi_awaddr                 ( master[1].aw_addr   ),
  .mem_axi_awprot                 ( master[1].aw_prot   ),
  .mem_axi_wvalid                 ( master[1].w_valid   ),
  .mem_axi_wready                 ( master[1].w_ready   ),
  .mem_axi_wdata                  ( master[1].w_data    ),
  .mem_axi_wstrb                  ( master[1].w_strb    ),
  .mem_axi_bvalid                 ( master[1].b_valid   ),
  .mem_axi_bready                 ( master[1].b_ready   ),
  .mem_axi_arvalid                ( master[1].ar_valid  ),
  .mem_axi_arready                ( master[1].ar_ready  ),
  .mem_axi_araddr                 ( master[1].ar_addr   ),
  .mem_axi_arprot                 ( master[1].ar_prot   ),
  .mem_axi_rvalid                 ( master[1].r_valid   ),
  .mem_axi_rready                 ( master[1].r_ready   ),
  .mem_axi_rdata                  ( master[1].r_data    ),
  .IMP_HSIZE                      ( 8'd4                ),
  .IMP_COOR_MINX                  ( 8'd0                ),
  .IMP_VSIZE                      ( 8'd6                ),
  .IMP_COOR_MINY                  ( 8'd0                ),
  .IMP_ST                         ( imp_start           ),
  .IMP_SRC_BADDR                  ( IMP_SRC_BADDR       ),
  .IMP_DST_BADDR                  ( IMP_DST_BADDR       ),
  .IMP_ADR_PITCH                  ( IMP_ADR_PITCH       ),
  .imp_done                       ( imp_done            )
);


// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------

// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****



// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
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
      firmware_file = "/home/matthew/project/riscv_workspace/2-sim/sim_picorv32/firmware/firmware.hex";
    $readmemh(firmware_file, pulp_axi4_mem.memory);
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
          imp_reg_stsrt_flag <= 1'b1;
          //$finish;
        //$stop;
      end
    end
  end


initial begin
  imp_reg_stsrt_flag = 1'b0;
  if (imp_done)begin
    #100
    $finish;
  end
end

endmodule