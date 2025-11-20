// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ mst_imp.v                                                                              //
// Creator ____________ Yan, Wei-Ting                                                                             //
// Built Date _________ MMM-DD-YYYY                                                                               //
// Function ___________                                                                                           //
// Hierawchy __________                                                                                           //
//   Pawent ___________                                                                                           //
//   Children _________                                                                                           //
// Revision history ___ Date        Author            Description                                                 //
//                  ___                                                                                           //
// -FHDR--------------------------------------------------------------------------------------------------------- //
//+...........+...................+.............................................................................. //
//3...........15..................35............................................................................. //
`timescale 1ns/10ps

module mst_imp_w_ch (
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

  input  wire [ 2: 0]             mem_axi_bresp,
  input  wire                     mem_axi_bvalid,
  output wire                     mem_axi_bready,

  // Task configuration
  input  wire [ 7: 0]             IMP_HSIZE,                              // pixels per row     //default : 32
  input  wire [ 7: 0]             IMP_COOR_MINX,                          // stawt X (pixels)
  input  wire [ 7: 0]             IMP_VSIZE,                              // rows               //default : 64
  input  wire [ 7: 0]             IMP_COOR_MINY,                          // stawt Y (rows)
  input  wire                     IMP_ST,                                 // Stawt bit，1T stawt pulse

  input  wire [31: 0]             IMP_DST_BADDR,                          // destination base (32b)
  input  wire [31: 0]             IMP_ADR_PITCH                           // bytes per row


);
// tag COMPONENTs and SIGNALs declawation --------------------------------------------------------------------------
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

  wire                            xt_aw_ack;
  wire                            xt__w_ack;

  reg         [31: 0]             xt_line_base;
  reg         [ 4: 0]             xt_xcnt;
  wire                            xt_xcnt_end;
  reg         [ 4: 0]             xt_ycnt;
  wire                            xt_ycnt_end;

  reg         [ 1: 0]             xt_imp_st_dly;

  reg                             xt_axi_awvalid;
  reg         [31: 0]             xt_axi_awaddr;
  reg         [ 2: 0]             xt_axi_awprot;

  reg                             xt_axi_wvalid;
  reg         [31: 0]             xt_axi_wdata;
  reg                             xt_axi_bready;


// tag OUTs assignment ---------------------------------------------------------------------------------------------
  assign  mem_axi_awvalid         = xt_axi_awvalid;
  assign  mem_axi_awaddr          = xt_axi_awaddr;
  assign  mem_axi_awprot          = xt_axi_awprot;

  assign  mem_axi_wvalid          = 1'b1;//xt_axi_wvalid;
  assign  mem_axi_wdata           = xt_axi_wdata;
  assign  mem_axi_wstrb           = 4'b1111;

  //The default state of BREADY can be HIGH, but only if the master can always accept a write response in a single cycle.
  assign  mem_axi_bready          = 1'b1;

// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
//
//            BASE_ADDR +----------------------------------------------------------------------------+
//                      |                                                                            |
//                      |           (IMP_DST_BADDR)         CNST_PXL_WIDTH                           |
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

assign xt_aw_ack                  = xt_processing && mem_axi_awready;
assign xt__w_ack                  = mem_axi_wvalid && mem_axi_wready;    // R handshake

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
    end else if (xt_xcnt_end && xt_ycnt_end && mem_axi_awready) begin
      xt_processing <= 1'b0;
    end

  end
end

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    xt_xcnt <= 'b0;
  end else begin
    if (xt_all_proc_trg || (xt_xcnt_end && xt_ycnt_end==1'b0 && xt_aw_ack) ) begin
      xt_xcnt <= 'b0;
    end else if (xt_aw_ack) begin
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
    end else if (xt_xcnt_end && xt_ycnt_end==1'b0 && mem_axi_awready) begin
      xt_ycnt <= xt_ycnt + 1'b1;
    end

  end
end

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// READ                  /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
//aw
always @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    xt_axi_awvalid <= 1'b0;
  end else begin
    if (xt_all_proc_trg) begin
      xt_axi_awvalid <= 1'b1;
    end else if (xt_xcnt_end && xt_ycnt_end && mem_axi_awready) begin
      xt_axi_awvalid <= 1'b0;
    end

  end
end

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    xt_line_base  <= 32'b0;
    xt_axi_awaddr <= 32'b0;
    xt_axi_awprot <= 3'b000;
  end else begin
    if (xt_all_proc_trg) begin
      xt_line_base <= IMP_DST_BADDR;
    end else if (xt_xcnt_end && xt_ycnt_end==1'b0 && xt_aw_ack) begin
      xt_line_base <= xt_line_base + IMP_ADR_PITCH;
    end

    if (xt_all_proc_trg) begin
      xt_axi_awaddr <= IMP_DST_BADDR ;
    end else if (xt_xcnt_end && xt_ycnt_end==1'b0 && xt_aw_ack) begin
      xt_axi_awaddr <= xt_line_base + IMP_ADR_PITCH;
    end else if ( xt_aw_ack ) begin
      xt_axi_awaddr <= xt_axi_awaddr + 3'd4;
    end

    xt_axi_awprot   <= 3'b000;
  end
end

// W

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    xt_axi_wdata   <=  32'b0;
  end else begin
    if (xt__w_ack) begin
      xt_axi_wdata <= xt_axi_wdata + 1'b1;
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

// synopsys translate_on

endmodule