// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ mst_imp.v                                                                              //
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

module mst_imp (
  input  wire                     rst_n,
  input  wire                     clk,
  // AXI4-lite master memory interface

  // AW
  output wire                     mem_axi_awvalid,
  input  wire                     mem_axi_awready,
  output wire [31: 0]             mem_axi_awaddr,
  output wire [ 2: 0]             mem_axi_awprot,

  output wire                     mem_axi_wvalid,
  input  wire                     mem_axi_wready,
  output wire [31: 0]             mem_axi_wdata,
  output wire [ 3: 0]             mem_axi_wstrb,

  input  wire                     mem_axi_bvalid,
  output wire                     mem_axi_bready,

  // AR
  output wire                     mem_axi_arvalid,
  input  wire                     mem_axi_arready,
  output wire [31: 0]             mem_axi_araddr,
  output wire [ 2: 0]             mem_axi_arprot,

  input  wire                     mem_axi_rvalid,
  output wire                     mem_axi_rready,
  input  wire [31: 0]             mem_axi_rdata,

  // Task configuration
  input  logic [ 7: 0]            IMP_HSIZE,                              // pixels per row     //default : 32
  input  logic [ 7: 0]            IMP_COOR_MINX,                          // start X (pixels)
  input  logic [ 7: 0]            IMP_VSIZE,                              // rows               //default : 64
  input  logic [ 7: 0]            IMP_COOR_MINY,                          // start Y (rows)
  input  logic                    IMP_ST,                                 // Start bit，1T start pulse

  input  logic [31: 0]            IMP_SRC_BADDR,                          // source base (32b)
  input  logic [31: 0]            IMP_DST_BADDR,                          // destination base (32b)
  input  logic [ 8: 0]            IMP_ADR_PITCH,                          // bytes per row

  // Status
  output logic                    imp_done

);
// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  wire        [ 7: 0]             CNST_PXL_WIDTH;
  wire        [ 7: 0]             CNST_PXL_HIGHT;
  wire        [ 7: 0]             CNST_PXL_X_STA;
  wire        [ 7: 0]             CNST_PXL_Y_STA;
  wire        [ 8: 0]             CNST_PXL_X_END;
  wire        [ 8: 0]             CNST_PXL_Y_END;
  wire        [15: 0]             CNST_ALL_DSIZE;

  reg                             xt_processing;
  wire                            xt_all_proc_trg;
  wire                            xt_sub_proc_end;

  wire                            xt_ar_ack;
  wire                            R_xf_en;

  reg         [31: 0]             xt_line_base;
  reg         [ 4: 0]             xt_xcnt;
  wire                            xt_xcnt_end;
  reg         [ 4: 0]             xt_ycnt;
  wire                            xt_ycnt_end;

  reg         [ 1: 0]             xt_imp_st_dly;

  reg                             xt_axi_arvalid;
  reg         [31: 0]             xt_axi_araddr;
  reg         [ 2: 0]             xt_axi_arprot;
  reg         [31: 0]             xt_axi_rdata;

  reg         [11: 0]             xt_cnt_rdata;
// tag OUTs assignment ---------------------------------------------------------------------------------------------
  //assign                        mem_axi_awvalid = 1'b0
  //assign [31: 0]                mem_axi_awaddr  = 32'b0
  //assign [ 2: 0]                mem_axi_awprot  = 3'b000;
  //assign                        mem_axi_wvalid  = 1'b0
  //assign [31: 0]                mem_axi_wdata   = 'z
  //assign [ 3: 0]                mem_axi_wstrb   = 4'b0
  //assign                        mem_axi_bready  = 1'b0
  assign  mem_axi_arvalid         = xt_axi_arvalid;
  assign  mem_axi_araddr          = xt_axi_araddr;
  assign  mem_axi_arprot          = xt_axi_arprot;
  assign  mem_axi_rready          = 1'b1;
  assign  imp_done                = (xt_cnt_rdata >= CNST_ALL_DSIZE);


// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
//
//            BASE_ADDR +----------------------------------------------------------------------------+
//                      |                                                                            |
//                      |           (IMP_SRC_BADDR)         CNST_PXL_WIDTH                           |
//                      |            CNST_PXL_X_STA +--------------------------+ CNST_PXL_X_END      |
//                      |                           |**************************|                     |
//     iIMP_pxl_y_cur   |   processing this line -> |**************************|                     |
//                      |                           |**************************|                     |
//                      |                           |**************************|                     |
//                      |               xt_ycnt_end +--------------------------+                     |
//                      |                                                                            |
//                      +----------------------------------------------------------------------------+
//
assign CNST_PXL_WIDTH             = IMP_HSIZE;
assign CNST_PXL_HIGHT             = IMP_VSIZE;
assign CNST_PXL_X_STA             = IMP_COOR_MINX;                               //default : 0
assign CNST_PXL_Y_STA             = IMP_COOR_MINY;                               //default : 0
assign CNST_PXL_X_END             = IMP_COOR_MINX + IMP_HSIZE - 1'b1;
assign CNST_PXL_Y_END             = IMP_COOR_MINY + IMP_VSIZE - 1'b1;

assign xt_all_proc_trg            = ( xt_imp_st_dly == 2'b01 );

assign xt_xcnt_end                = ( xt_xcnt >= CNST_PXL_X_END );
assign xt_ycnt_end                = ( xt_ycnt >= CNST_PXL_Y_END );

assign xt_ar_ack                  = xt_processing && mem_axi_arready;
assign R_xf_en                    = mem_axi_rvalid  & mem_axi_rready;    // R handshake

// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    xt_imp_st_dly <= 2'b0;
  end else begin
    xt_imp_st_dly <= {xt_imp_st_dly[0], IMP_ST};

  end
end

always_ff @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    xt_processing <= 1'b0;
  end else begin
    if (xt_all_proc_trg ) begin
      xt_processing <= 1'b1;
    end else if (xt_xcnt_end && xt_ycnt_end && mem_axi_arready) begin
      xt_processing <= 1'b0;
    end

  end
end

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    xt_xcnt <= 'b0;
  end else begin
    if (xt_all_proc_trg || (xt_xcnt_end && xt_ycnt_end==1'b0 && xt_ar_ack) ) begin
      xt_xcnt <= 'b0;
    end else if (xt_ar_ack) begin
      xt_xcnt <= xt_xcnt + 1'b1;
    end

  end
end

always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    xt_ycnt <= 8'b0;
  end else begin
    if (xt_all_proc_trg) begin
      xt_ycnt <= CNST_PXL_Y_STA;
    end else if (xt_xcnt_end && xt_ycnt_end==1'b0 && mem_axi_arready) begin
      xt_ycnt <= xt_ycnt + 1'b1;
    end

  end
end

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// READ                  /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
//AR
always @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    xt_axi_arvalid <= 1'b0;
  end else begin
    if (xt_all_proc_trg) begin
      xt_axi_arvalid <= 1'b1;
    end else if (xt_xcnt_end && xt_ycnt_end && mem_axi_arready) begin
      xt_axi_arvalid <= 1'b0;
    end

  end
end

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    xt_line_base  <= 32'b0;
    xt_axi_araddr <= 32'b0;
    xt_axi_arprot <= 3'b000;
  end else begin
    if (xt_all_proc_trg) begin
      xt_line_base <= IMP_SRC_BADDR;
    end else if (xt_xcnt_end && xt_ycnt_end==1'b0 && xt_ar_ack) begin
      xt_line_base <= xt_line_base + IMP_ADR_PITCH;
    end

    if (xt_all_proc_trg) begin
      xt_axi_araddr <= IMP_SRC_BADDR ;
    end else if (xt_xcnt_end && xt_ycnt_end==1'b0 && xt_ar_ack) begin
      xt_axi_araddr <= xt_line_base + IMP_ADR_PITCH;
    end else if ( xt_ar_ack ) begin
      xt_axi_araddr <= xt_axi_araddr + 3'd4;
    end

    xt_axi_arprot   <= 3'b000;
  end
end

// R
always @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    xt_axi_rdata   <=  32'b0;
  end else begin
    if (R_xf_en && (xt_cnt_rdata <= CNST_ALL_DSIZE)) begin
      xt_axi_rdata <= mem_axi_rdata;
    end

  end
end

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// dbg                   /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
// synopsys translate_off
  assign CNST_ALL_DSIZE             = IMP_HSIZE * IMP_VSIZE;

  always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      xt_cnt_rdata   <=  12'b0;
    end else begin
      if (R_xf_en && (xt_cnt_rdata <= CNST_ALL_DSIZE)) begin
        xt_cnt_rdata <= xt_cnt_rdata + 1'b1;
      end

    end
  end
// synopsys translate_on

endmodule