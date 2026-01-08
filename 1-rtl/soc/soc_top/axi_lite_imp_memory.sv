// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ ModuleName.v                                                                              //
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

module axi_lite_imp_memory #(
  parameter   ADDR_WIDTH          = 32,
  parameter   DATA_WIDTH          = 32,
  parameter   STRB_WIDTH          = 4
)(
  input  wire                     rst_n,
  input  wire                     clk,

  // AXI4-Lite slave
  // AW
  input  wire                     s_aw_valid,
  output wire                     s_aw_ready,        //
  input  wire  [ADDR_WIDTH-1: 0]  s_aw_addr,
  input  wire  [ 2: 0]            s_aw_prot,
  // W
  input  wire                     s_w_valid,
  output wire                     s_w_ready,
  input  wire  [DATA_WIDTH-1: 0]  s_w_data,
  input  wire  [STRB_WIDTH-1: 0]  s_w_strb,
  // B
  output wire                     s_b_valid,
  input  wire                     s_b_ready,
  output wire  [ 1: 0]            s_b_resp,
  // AR
  input  wire                     s_ar_valid,
  output wire                     s_ar_ready,         //
  input  wire  [ADDR_WIDTH-1: 0]  s_ar_addr,
  input  wire  [ 2: 0]            s_ar_prot,

  // R
  output wire                     s_r_valid,           //
  input  wire                     s_r_ready,
  output logic [DATA_WIDTH-1: 0]  s_r_data,            //
  output wire  [ 1: 0]            s_r_resp
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  // constants
  wire         xt_aw_valid;
  wire         xt_w_valid;
  wire [37:0]  xt_aw_ready;

  wire [37: 0] xt_aw_w_vld;
  reg          xt_r_valid;
  wire [37: 0] xt_ar_valid;
  reg  [5 : 0] s_ar_addr_deco_1t;

  reg  [31: 0] xt_wr_addr;
  reg  [31: 0] xt_wr_data;
  reg  [31: 0] xt_rd_addr;
  reg  [31: 0] xt_rd_data;
  reg  [31: 0] xt_r_data;

  wire [31: 0] xt_r_data_0,  xt_r_data_1,  xt_r_data_2,  xt_r_data_3,  xt_r_data_4;
  wire [31: 0] xt_r_data_5,  xt_r_data_6,  xt_r_data_7,  xt_r_data_8,  xt_r_data_9;
  wire [31: 0] xt_r_data_10, xt_r_data_11, xt_r_data_12, xt_r_data_13, xt_r_data_14;
  wire [31: 0] xt_r_data_15, xt_r_data_16, xt_r_data_17, xt_r_data_18, xt_r_data_19;
  wire [31: 0] xt_r_data_20, xt_r_data_21, xt_r_data_22, xt_r_data_23, xt_r_data_24;
  wire [31: 0] xt_r_data_25, xt_r_data_26, xt_r_data_27, xt_r_data_28, xt_r_data_29;
  wire [31: 0] xt_r_data_30, xt_r_data_31, xt_r_data_32, xt_r_data_33, xt_r_data_34;
  wire [31: 0] xt_r_data_35, xt_r_data_36, xt_r_data_37;
// tag OUTs assignment ---------------------------------------------------------------------------------------------
  assign s_b_valid   = 1'b1;
  assign s_b_resp    = 2'b00;

  assign s_ar_ready  = 1'b1;

  assign s_r_valid   = xt_r_valid;

  assign s_r_resp    = 2'b00;

  assign xt_ar_valid[0]  = (s_ar_valid && s_ar_addr[24:19]==6'd0  );
  assign xt_ar_valid[1]  = (s_ar_valid && s_ar_addr[24:19]==6'd1  );
  assign xt_ar_valid[2]  = (s_ar_valid && s_ar_addr[24:19]==6'd2  );
  assign xt_ar_valid[3]  = (s_ar_valid && s_ar_addr[24:19]==6'd3  );
  assign xt_ar_valid[4]  = (s_ar_valid && s_ar_addr[24:19]==6'd4  );
  assign xt_ar_valid[5]  = (s_ar_valid && s_ar_addr[24:19]==6'd5  );
  assign xt_ar_valid[6]  = (s_ar_valid && s_ar_addr[24:19]==6'd6  );
  assign xt_ar_valid[7]  = (s_ar_valid && s_ar_addr[24:19]==6'd7  );
  assign xt_ar_valid[8]  = (s_ar_valid && s_ar_addr[24:19]==6'd8  );
  assign xt_ar_valid[9]  = (s_ar_valid && s_ar_addr[24:19]==6'd9  );
  assign xt_ar_valid[10] = (s_ar_valid && s_ar_addr[24:19]==6'd10 );
  assign xt_ar_valid[11] = (s_ar_valid && s_ar_addr[24:19]==6'd11 );
  assign xt_ar_valid[12] = (s_ar_valid && s_ar_addr[24:19]==6'd12 );
  assign xt_ar_valid[13] = (s_ar_valid && s_ar_addr[24:19]==6'd13 );
  assign xt_ar_valid[14] = (s_ar_valid && s_ar_addr[24:19]==6'd14 );
  assign xt_ar_valid[15] = (s_ar_valid && s_ar_addr[24:19]==6'd15 );
  assign xt_ar_valid[16] = (s_ar_valid && s_ar_addr[24:19]==6'd16 );
  assign xt_ar_valid[17] = (s_ar_valid && s_ar_addr[24:19]==6'd17 );
  assign xt_ar_valid[18] = (s_ar_valid && s_ar_addr[24:19]==6'd18 );
  assign xt_ar_valid[19] = (s_ar_valid && s_ar_addr[24:19]==6'd19 );
  assign xt_ar_valid[20] = (s_ar_valid && s_ar_addr[24:19]==6'd20 );
  assign xt_ar_valid[21] = (s_ar_valid && s_ar_addr[24:19]==6'd21 );
  assign xt_ar_valid[22] = (s_ar_valid && s_ar_addr[24:19]==6'd22 );
  assign xt_ar_valid[23] = (s_ar_valid && s_ar_addr[24:19]==6'd23 );
  assign xt_ar_valid[24] = (s_ar_valid && s_ar_addr[24:19]==6'd24 );
  assign xt_ar_valid[25] = (s_ar_valid && s_ar_addr[24:19]==6'd25 );
  assign xt_ar_valid[26] = (s_ar_valid && s_ar_addr[24:19]==6'd26 );
  assign xt_ar_valid[27] = (s_ar_valid && s_ar_addr[24:19]==6'd27 );
  assign xt_ar_valid[28] = (s_ar_valid && s_ar_addr[24:19]==6'd28 );
  assign xt_ar_valid[29] = (s_ar_valid && s_ar_addr[24:19]==6'd29 );
  assign xt_ar_valid[30] = (s_ar_valid && s_ar_addr[24:19]==6'd30 );
  assign xt_ar_valid[31] = (s_ar_valid && s_ar_addr[24:19]==6'd31 );
  assign xt_ar_valid[32] = (s_ar_valid && s_ar_addr[24:19]==6'd32 );
  assign xt_ar_valid[33] = (s_ar_valid && s_ar_addr[24:19]==6'd33 );
  assign xt_ar_valid[34] = (s_ar_valid && s_ar_addr[24:19]==6'd34 );
  assign xt_ar_valid[35] = (s_ar_valid && s_ar_addr[24:19]==6'd35 );
  assign xt_ar_valid[36] = (s_ar_valid && s_ar_addr[24:19]==6'd36 );
  assign xt_ar_valid[37] = (s_ar_valid && s_ar_addr[24:19]==6'd37 );

// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
  assign xt_aw_w_vld[0]  =  (xt_wr_addr[24:19] == 6'd0   ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[1]  =  (xt_wr_addr[24:19] == 6'd1   ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[2]  =  (xt_wr_addr[24:19] == 6'd2   ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[3]  =  (xt_wr_addr[24:19] == 6'd3   ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[4]  =  (xt_wr_addr[24:19] == 6'd4   ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[5]  =  (xt_wr_addr[24:19] == 6'd5   ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[6]  =  (xt_wr_addr[24:19] == 6'd6   ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[7]  =  (xt_wr_addr[24:19] == 6'd7   ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[8]  =  (xt_wr_addr[24:19] == 6'd8   ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[9]  =  (xt_wr_addr[24:19] == 6'd9   ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[10] =  (xt_wr_addr[24:19] == 6'd10  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[11] =  (xt_wr_addr[24:19] == 6'd11  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[12] =  (xt_wr_addr[24:19] == 6'd12  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[13] =  (xt_wr_addr[24:19] == 6'd13  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[14] =  (xt_wr_addr[24:19] == 6'd14  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[15] =  (xt_wr_addr[24:19] == 6'd15  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[16] =  (xt_wr_addr[24:19] == 6'd16  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[17] =  (xt_wr_addr[24:19] == 6'd17  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[18] =  (xt_wr_addr[24:19] == 6'd18  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[19] =  (xt_wr_addr[24:19] == 6'd19  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[20] =  (xt_wr_addr[24:19] == 6'd20  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[21] =  (xt_wr_addr[24:19] == 6'd21  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[22] =  (xt_wr_addr[24:19] == 6'd22  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[23] =  (xt_wr_addr[24:19] == 6'd23  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[24] =  (xt_wr_addr[24:19] == 6'd24  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[25] =  (xt_wr_addr[24:19] == 6'd25  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[26] =  (xt_wr_addr[24:19] == 6'd26  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[27] =  (xt_wr_addr[24:19] == 6'd27  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[28] =  (xt_wr_addr[24:19] == 6'd28  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[29] =  (xt_wr_addr[24:19] == 6'd29  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[30] =  (xt_wr_addr[24:19] == 6'd30  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[31] =  (xt_wr_addr[24:19] == 6'd31  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[32] =  (xt_wr_addr[24:19] == 6'd32  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[33] =  (xt_wr_addr[24:19] == 6'd33  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[34] =  (xt_wr_addr[24:19] == 6'd34  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[35] =  (xt_wr_addr[24:19] == 6'd35  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[36] =  (xt_wr_addr[24:19] == 6'd36  ) ? xt_aw_valid && xt_w_valid : 1'b0;
  assign xt_aw_w_vld[37] =  (xt_wr_addr[24:19] == 6'd37  ) ? xt_aw_valid && xt_w_valid : 1'b0;

// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
always_comb begin
  //case (xt_ar_valid_dly_4t[151: 114])
  case (s_ar_addr_deco_1t)
    6'd0  : s_r_data = xt_r_data_0;
    6'd1  : s_r_data = xt_r_data_1;
    6'd2  : s_r_data = xt_r_data_2;
    6'd3  : s_r_data = xt_r_data_3;
    6'd4  : s_r_data = xt_r_data_4;
    6'd5  : s_r_data = xt_r_data_5;
    6'd6  : s_r_data = xt_r_data_6;
    6'd7  : s_r_data = xt_r_data_7;
    6'd8  : s_r_data = xt_r_data_8;
    6'd9  : s_r_data = xt_r_data_9;
    6'd10 : s_r_data = xt_r_data_10;
    6'd11 : s_r_data = xt_r_data_11;
    6'd12 : s_r_data = xt_r_data_12;
    6'd13 : s_r_data = xt_r_data_13;
    6'd14 : s_r_data = xt_r_data_14;
    6'd15 : s_r_data = xt_r_data_15;
    6'd16 : s_r_data = xt_r_data_16;
    6'd17 : s_r_data = xt_r_data_17;
    6'd18 : s_r_data = xt_r_data_18;
    6'd19 : s_r_data = xt_r_data_19;
    6'd20 : s_r_data = xt_r_data_20;
    6'd21 : s_r_data = xt_r_data_21;
    6'd22 : s_r_data = xt_r_data_22;
    6'd23 : s_r_data = xt_r_data_23;
    6'd24 : s_r_data = xt_r_data_24;
    6'd25 : s_r_data = xt_r_data_25;
    6'd26 : s_r_data = xt_r_data_26;
    6'd27 : s_r_data = xt_r_data_27;
    6'd28 : s_r_data = xt_r_data_28;
    6'd29 : s_r_data = xt_r_data_29;
    6'd30 : s_r_data = xt_r_data_30;
    6'd31 : s_r_data = xt_r_data_31;
    6'd32 : s_r_data = xt_r_data_32;
    6'd33 : s_r_data = xt_r_data_33;
    6'd34 : s_r_data = xt_r_data_34;
    6'd35 : s_r_data = xt_r_data_35;
    6'd36 : s_r_data = xt_r_data_36;
    6'd37 : s_r_data = xt_r_data_37;
    default: s_r_data = 32'b0;
  endcase
end
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****

// =======================================================================================================
// =======================================================================================================
always @ (posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    xt_wr_addr <= 32'b0;
    xt_wr_data <= 32'b0;
  end else begin
    if ( s_aw_valid && s_aw_ready ) begin
      xt_wr_addr <= s_aw_addr;
    end

    if ( s_w_valid && s_w_ready ) begin
      xt_wr_data <= s_w_data;
    end

  end
end


always_ff @ (posedge clk or negedge rst_n) begin
  if ( ~rst_n) begin
    xt_r_valid <= 1'b0;
    s_ar_addr_deco_1t <= 'd0;
  end else begin
    //xt_r_valid <= s_ar_valid;
    xt_r_valid <= |xt_ar_valid;
    s_ar_addr_deco_1t <= s_ar_addr[24:19];
  end
end

axi_like_handshake u0_aw_handshake (
  .rst_n      ( rst_n       ),
  .clk        ( clk         ),
  .valid_i    ( s_aw_valid  ),
  .ready_o    ( s_aw_ready  ),

  .valid_o    ( xt_aw_valid ),
  .ready_i    ( |xt_aw_w_vld )
);

axi_like_handshake u0_w_handshake (
  .rst_n      ( rst_n       ),
  .clk        ( clk         ),
  .valid_i    ( s_w_valid   ),
  .ready_o    ( s_w_ready   ),

  .valid_o    ( xt_w_valid  ),
  .ready_i    ( |xt_aw_w_vld )
);


Xilinx_SRAM1R1W_32X131072 u0_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[0]       ),
  .wea   ( {4{xt_aw_w_vld[0]}}  ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[0]       ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_0          )
);

Xilinx_SRAM1R1W_32X131072 u1_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[1]       ),
  .wea   ( {4{xt_aw_w_vld[1]}}  ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[1]       ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_1          )
);

Xilinx_SRAM1R1W_32X131072 u2_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[2]       ),
  .wea   ( {4{xt_aw_w_vld[2]}}  ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[2]       ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_2          )
);

Xilinx_SRAM1R1W_32X131072 u3_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[3]       ),
  .wea   ( {4{xt_aw_w_vld[3]}}  ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[3]       ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_3          )
);

Xilinx_SRAM1R1W_32X131072 u4_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[4]       ),
  .wea   ( {4{xt_aw_w_vld[4]}}  ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[4]       ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_4          )
);

Xilinx_SRAM1R1W_32X131072 u5_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[5]       ),
  .wea   ( {4{xt_aw_w_vld[5]}}  ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[5]       ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_5          )
);

Xilinx_SRAM1R1W_32X131072 u6_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[6]       ),
  .wea   ( {4{xt_aw_w_vld[6]}}  ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[6]       ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_6          )
);

Xilinx_SRAM1R1W_32X131072 u7_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[7]       ),
  .wea   ( {4{xt_aw_w_vld[7]}}  ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[7]       ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_7          )
);

Xilinx_SRAM1R1W_32X131072 u8_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[8]       ),
  .wea   ( {4{xt_aw_w_vld[8]}}  ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[8]       ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_8          )
);

Xilinx_SRAM1R1W_32X131072 u9_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[9]       ),
  .wea   ( {4{xt_aw_w_vld[9]}}  ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[9]       ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_9          )
);

Xilinx_SRAM1R1W_32X131072 u10_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[10]      ),
  .wea   ( {4{xt_aw_w_vld[10]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[10]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_10         )
);

Xilinx_SRAM1R1W_32X131072 u11_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[11]      ),
  .wea   ( {4{xt_aw_w_vld[11]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[11]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_11         )
);

Xilinx_SRAM1R1W_32X131072 u12_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[12]      ),
  .wea   ( {4{xt_aw_w_vld[12]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[12]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_12         )
);

Xilinx_SRAM1R1W_32X131072 u13_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[13]      ),
  .wea   ( {4{xt_aw_w_vld[13]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[13]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_13         )
);

Xilinx_SRAM1R1W_32X131072 u14_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[14]      ),
  .wea   ( {4{xt_aw_w_vld[14]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[14]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_14         )
);

Xilinx_SRAM1R1W_32X131072 u15_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[15]      ),
  .wea   ( {4{xt_aw_w_vld[15]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[15]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_15         )
);

Xilinx_SRAM1R1W_32X131072 u16_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[16]      ),
  .wea   ( {4{xt_aw_w_vld[16]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[16]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_16         )
);

Xilinx_SRAM1R1W_32X131072 u17_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[17]      ),
  .wea   ( {4{xt_aw_w_vld[17]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[17]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_17         )
);

Xilinx_SRAM1R1W_32X131072 u18_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[18]      ),
  .wea   ( {4{xt_aw_w_vld[18]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[18]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_18         )
);

Xilinx_SRAM1R1W_32X131072 u19_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[19]      ),
  .wea   ( {4{xt_aw_w_vld[19]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[19]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_19         )
);

Xilinx_SRAM1R1W_32X131072 u20_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[20]      ),
  .wea   ( {4{xt_aw_w_vld[20]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[20]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_20         )
);

Xilinx_SRAM1R1W_32X131072 u21_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[21]      ),
  .wea   ( {4{xt_aw_w_vld[21]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[21]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_21         )
);

Xilinx_SRAM1R1W_32X131072 u22_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[22]      ),
  .wea   ( {4{xt_aw_w_vld[22]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[22]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_22         )
);

Xilinx_SRAM1R1W_32X131072 u23_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[23]      ),
  .wea   ( {4{xt_aw_w_vld[23]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[23]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_23         )
);

Xilinx_SRAM1R1W_32X131072 u24_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[24]      ),
  .wea   ( {4{xt_aw_w_vld[24]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[24]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_24         )
);

Xilinx_SRAM1R1W_32X131072 u25_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[25]      ),
  .wea   ( {4{xt_aw_w_vld[25]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[25]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_25         )
);

Xilinx_SRAM1R1W_32X131072 u26_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[26]      ),
  .wea   ( {4{xt_aw_w_vld[26]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[26]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_26         )
);

Xilinx_SRAM1R1W_32X131072 u27_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[27]      ),
  .wea   ( {4{xt_aw_w_vld[27]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[27]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_27         )
);

Xilinx_SRAM1R1W_32X131072 u28_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[28]      ),
  .wea   ( {4{xt_aw_w_vld[28]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[28]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_28         )
);

Xilinx_SRAM1R1W_32X131072 u29_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[29]      ),
  .wea   ( {4{xt_aw_w_vld[29]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[29]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_29         )
);

Xilinx_SRAM1R1W_32X131072 u30_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[30]      ),
  .wea   ( {4{xt_aw_w_vld[30]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[30]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_30         )
);

Xilinx_SRAM1R1W_32X131072 u31_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[31]      ),
  .wea   ( {4{xt_aw_w_vld[31]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[31]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_31         )
);

Xilinx_SRAM1R1W_32X131072 u32_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[32]      ),
  .wea   ( {4{xt_aw_w_vld[32]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[32]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_32         )
);

Xilinx_SRAM1R1W_32X131072 u33_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[33]      ),
  .wea   ( {4{xt_aw_w_vld[33]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[33]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_33         )
);

Xilinx_SRAM1R1W_32X131072 u34_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[34]      ),
  .wea   ( {4{xt_aw_w_vld[34]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[34]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_34         )
);

Xilinx_SRAM1R1W_32X131072 u35_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[35]      ),
  .wea   ( {4{xt_aw_w_vld[35]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[35]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_35         )
);

Xilinx_SRAM1R1W_32X131072 u36_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[36]      ),
  .wea   ( {4{xt_aw_w_vld[36]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[36]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_36         )
);

Xilinx_SRAM1R1W_32X131072 u37_SRAM1R1W_32X131072 (
  .clka  ( clk                  ),
  .ena   ( xt_aw_w_vld[37]      ),
  .wea   ( {4{xt_aw_w_vld[37]}} ),
  .addra ( xt_wr_addr           ),
  .dina  ( xt_wr_data           ),

  .clkb  ( clk                  ),
  .rstb  ( 1'b0                 ),
  .enb   ( xt_ar_valid[37]      ),
  .addrb ( s_ar_addr            ),
  .doutb ( xt_r_data_37         )
);

//rdy_ack_handshake u0_aw_handshake (
//  .rst_n      ( rst_n       ),
//  .clk        ( clk         ),
//  .wr_rdy     ( s_aw_valid  ),
//  .wr_ack     ( s_aw_ready  ),
//  .rd_rdy     ( xt_aw_valid ),
//  .rd_ack     ( xt_aw_w_vld )
//);
//
//rdy_ack_handshake u0_w_handshake (
//  .rst_n      ( rst_n       ),
//  .clk        ( clk         ),
//  .wr_rdy     ( s_w_valid   ),
//  .wr_ack     ( s_w_ready   ),
//  .rd_rdy     ( xt_w_valid  ),
//  .rd_ack     ( xt_aw_w_vld )
//);





endmodule