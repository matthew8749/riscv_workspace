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

module mst_imp_r_ch (
  input  wire                     PoR_rst_n,
  input  wire                     fw_rst_n,
  input  wire                     sw_rst_n,
  input  wire                     clk,
  // AXI4-lite master memory interface

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
  input  logic [31: 0]            IMP_ADR_PITCH                           // bytes per row


);
// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  reg                             ip_rst_n;

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
  wire                            xt__r_ack;

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


// tag OUTs assignment ---------------------------------------------------------------------------------------------
  assign  mem_axi_arvalid         = xt_axi_arvalid;
  assign  mem_axi_araddr          = xt_axi_araddr;
  assign  mem_axi_arprot          = xt_axi_arprot;
  assign  mem_axi_rready          = 1'b1;

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
assign xt__r_ack                  = mem_axi_rvalid  & mem_axi_rready;    // R handshake

// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
always_ff @(posedge clk or negedge PoR_rst_n) begin
  if (!PoR_rst_n) begin
    xt_imp_st_dly <= 2'b0;
  end else begin
    xt_imp_st_dly <= {xt_imp_st_dly[0], IMP_ST};

  end
end

always_ff @(posedge clk or negedge PoR_rst_n) begin
  if(~PoR_rst_n) begin
    xt_processing <= 1'b0;
  end else begin
    if (xt_all_proc_trg ) begin
      xt_processing <= 1'b1;
    end else if (xt_xcnt_end && xt_ycnt_end && mem_axi_arready) begin
      xt_processing <= 1'b0;
    end

  end
end

always @ (posedge clk or negedge PoR_rst_n) begin
  if (!PoR_rst_n) begin
    xt_xcnt <= 'b0;
  end else begin
    if (xt_all_proc_trg || (xt_xcnt_end && xt_ycnt_end==1'b0 && xt_ar_ack) ) begin
      xt_xcnt <= 'b0;
    end else if (xt_ar_ack) begin
      xt_xcnt <= xt_xcnt + 1'b1;
    end

  end
end

always_ff @(posedge clk or negedge PoR_rst_n) begin
  if (!PoR_rst_n) begin
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
always @ (posedge clk or negedge PoR_rst_n) begin
  if (!PoR_rst_n) begin
    xt_axi_arvalid <= 1'b0;
  end else begin
    if (xt_all_proc_trg) begin
      xt_axi_arvalid <= 1'b1;
    end else if (xt_xcnt_end && xt_ycnt_end && mem_axi_arready) begin
      xt_axi_arvalid <= 1'b0;
    end

  end
end

always @ (posedge clk or negedge PoR_rst_n) begin
  if (!PoR_rst_n) begin
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
always @ (posedge clk or negedge PoR_rst_n) begin
  if (!PoR_rst_n) begin
    xt_axi_rdata   <=  32'b0;
  end else begin
    if (xt__r_ack) begin
      xt_axi_rdata <= mem_axi_rdata;
    end

  end
end


// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// WRITE                 /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****


// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// dbg                   /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
// synopsys translate_off
  reg         [11: 0]             xt_cnt_rdata;

  assign      CNST_ALL_DSIZE      = IMP_HSIZE * IMP_VSIZE;
  assign      imp_done            = (xt_cnt_rdata >= CNST_ALL_DSIZE);

  always @ (posedge clk or negedge PoR_rst_n) begin
    if (!PoR_rst_n) begin
      xt_cnt_rdata   <=  12'b0;
    end else begin
      if (xt__r_ack && (xt_cnt_rdata <= CNST_ALL_DSIZE)) begin
        xt_cnt_rdata <= xt_cnt_rdata + 1'b1;
      end

    end
  end
// synopsys translate_on

endmodule