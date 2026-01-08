// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ median_5x5.sv                                                                             //
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
module  median_5x5#(
    parameter DATA_WIDTH = 8,
    parameter DATA_DEPTH = 640
)
(
  input wire                      ref_clk,
  input wire                      mem_clk,
  input wire                      rst_n,

  input wire  [ 2: 0]             DPi_sync,
    
  input wire  [DATA_WIDTH - 1 :0] median_line_0,
  input wire  [DATA_WIDTH - 1 :0] median_line_1,
  input wire  [DATA_WIDTH - 1 :0] median_line_2,
  input wire  [DATA_WIDTH - 1 :0] median_line_3,
  input wire  [DATA_WIDTH - 1 :0] median_line_4,
  output wire [ 10: 0]            Median_DPo
);
// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  wire        [ 7: 0]             matrix_p00;
  wire        [ 7: 0]             matrix_p01;
  wire        [ 7: 0]             matrix_p02;
  wire        [ 7: 0]             matrix_p03;
  wire        [ 7: 0]             matrix_p04;
  wire        [ 7: 0]             matrix_p10;
  wire        [ 7: 0]             matrix_p11;
  wire        [ 7: 0]             matrix_p12;
  wire        [ 7: 0]             matrix_p13;
  wire        [ 7: 0]             matrix_p14;
  wire        [ 7: 0]             matrix_p20;
  wire        [ 7: 0]             matrix_p21;
  wire        [ 7: 0]             matrix_p22;
  wire        [ 7: 0]             matrix_p23;
  wire        [ 7: 0]             matrix_p24;
  wire        [ 7: 0]             matrix_p30;
  wire        [ 7: 0]             matrix_p31;
  wire        [ 7: 0]             matrix_p32;
  wire        [ 7: 0]             matrix_p33;
  wire        [ 7: 0]             matrix_p34;
  wire        [ 7: 0]             matrix_p40;
  wire        [ 7: 0]             matrix_p41;
  wire        [ 7: 0]             matrix_p42;
  wire        [ 7: 0]             matrix_p43;
  wire        [ 7: 0]             matrix_p44;
  reg         [ 7: 0]             rt_mtx [ 0: 4] [ 0: 4] ;

  wire        [ 9: 0]             ram_addr;
  reg         [ 9: 0]             rt_hcnt;
  reg         [ 9: 0]             rt_vcnt;
  reg         [ 9: 0]             rt_ycnt;
  reg         [ 9: 0]             rt_xcnt;

  wire                            rt_vsync;
  wire                            rt_hsync;
  wire                            rt_den;
  wire        [ 7: 0]             rt_line_0;
  wire        [ 7: 0]             rt_line_1;
  wire        [ 7: 0]             rt_line_2;
  wire        [ 7: 0]             rt_line_3;
  wire        [ 7: 0]             rt_line_4;

  reg         [ 7: 0]             rt_data_delay_1t;
  reg         [ 1: 0]             rt_vsync_delay_2t;
  reg         [ 1: 0]             rt_hsync_delay_2t;
  reg         [ 1: 0]             rt_den_delay_2t;


  reg         [ 2: 0]             rt_x_state;
  reg         [ 2: 0]             rt_y_state;

  wire                            sw_rst_n;
  wire        [ 7: 0]             value_Max;
  wire        [ 7: 0]             value_Second;
  wire        [ 7: 0]             value_Med;
  wire        [ 7: 0]             value_Fourth;
  wire        [ 7: 0]             value_Min;


  reg         [ 7: 0]             rt_make_den;
  reg                             creat_den;
  reg         [ 16: 0]            count_new_den;

  wire        [ 2: 0]             regen_Synco;
  wire                            regen_rst_n;
  reg         [ 8: 0]             regen_cnt;
  reg         [ 2: 0]             regen_vsync_dly;
  reg         [ 2: 0]             regen_hsync_dly;
  reg         [ 2: 0]             regen_den_dly;
  reg                             value_Med_to_threshold;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
assign Median_DPo[10]             = regen_vsync_dly[2];
assign Median_DPo[9]              = regen_hsync_dly[2];
assign Median_DPo[8]              = regen_den_dly[2];
assign Median_DPo[ 7: 0]          = { 7'b0, value_Med_to_threshold};

assign matrix_p00                 = rt_mtx[0][0];
assign matrix_p01                 = rt_mtx[0][1];
assign matrix_p02                 = rt_mtx[0][2];
assign matrix_p03                 = rt_mtx[0][3];
assign matrix_p04                 = rt_mtx[0][4];
assign matrix_p10                 = rt_mtx[1][0];
assign matrix_p11                 = rt_mtx[1][1];
assign matrix_p12                 = rt_mtx[1][2];
assign matrix_p13                 = rt_mtx[1][3];
assign matrix_p14                 = rt_mtx[1][4];
assign matrix_p20                 = rt_mtx[2][0];
assign matrix_p21                 = rt_mtx[2][1];
assign matrix_p22                 = rt_mtx[2][2];
assign matrix_p23                 = rt_mtx[2][3];
assign matrix_p24                 = rt_mtx[2][4];
assign matrix_p30                 = rt_mtx[3][0];
assign matrix_p31                 = rt_mtx[3][1];
assign matrix_p32                 = rt_mtx[3][2];
assign matrix_p33                 = rt_mtx[3][3];
assign matrix_p34                 = rt_mtx[3][4];
assign matrix_p40                 = rt_mtx[4][0];
assign matrix_p41                 = rt_mtx[4][1];
assign matrix_p42                 = rt_mtx[4][2];
assign matrix_p43                 = rt_mtx[4][3];
assign matrix_p44                 = rt_mtx[4][4];

// tag INs assignment ----------------------------------------------------------------------------------------------
assign rt_vsync                   = DPi_sync[2];
assign rt_hsync                   = DPi_sync[1];
assign rt_den                     = ( DPi_sync[0] | creat_den );
assign rt_line_0                  = median_line_0;
assign rt_line_1                  = median_line_1;
assign rt_line_2                  = median_line_2;
assign rt_line_3                  = median_line_3;
assign rt_line_4                  = median_line_4;

// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
assign ram_addr                   = ( rt_xcnt == 10'd640 ) ? 10'd639 : rt_xcnt;

assign hsync_1pz                  = ( { rt_hsync, rt_hsync_delay_2t[0] } == 2'b01 ) ? 1'b1 : 1'b0 ;
assign vsync_1pz                  = rt_vsync ^ rt_vsync_delay_2t[0];

assign  regen_rst_n               = ( regen_cnt < 9'd2 ) ? 1'b0 : 1'b1;

// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------


// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
always @ ( posedge ref_clk or negedge rst_n ) begin
  if ( !rst_n ) begin
    rt_xcnt    <= 10'd0;
    rt_x_state <= 2'b0;
  end else begin
    if ( rt_vsync || rt_hsync) begin
      rt_xcnt    <= 10'b0;
      rt_x_state <= 2'b0;
    end else if ( rt_den || creat_den || rt_den_delay_2t[0] ) begin
      rt_xcnt    <= rt_xcnt + 1'b1;
      rt_x_state <= (rt_x_state == 3'd4) ? 3'b0 :  rt_x_state + 1'b1;
    end else begin
      rt_xcnt    <= rt_xcnt;
      rt_x_state <= rt_x_state ;
    end


  end
end


always @ ( posedge ref_clk or negedge rst_n ) begin
  if ( !rst_n ) begin
    rt_ycnt    <= 10'd0;
    rt_y_state <= 3'b0;
  end else begin
    if ( rt_vsync && rt_hsync ) begin
      rt_ycnt    <= 10'b0;
      rt_y_state <= 3'b0;
    end else if ( rt_hsync && rt_xcnt == 10'd641/*(h_size)*/ ) begin
      rt_ycnt    <= rt_ycnt + 1'b1;
      rt_y_state <= ( rt_y_state == 3'd4 ) ? 3'b0 :  rt_y_state + 1'b1;
    end else begin
      rt_ycnt    <= rt_ycnt;
      rt_y_state <= rt_y_state;
    end


  end
end

always @ ( posedge ref_clk or negedge rst_n) begin
  if ( !rst_n ) begin
    rt_vsync_delay_2t <= 2'b0;
    rt_hsync_delay_2t <= 2'b0;
    rt_den_delay_2t   <= 2'b0;
  end else begin
    rt_vsync_delay_2t <= { rt_vsync_delay_2t[0], rt_vsync};
    rt_hsync_delay_2t <= { rt_hsync_delay_2t[0], rt_hsync};
    rt_den_delay_2t   <= { rt_den_delay_2t[0],   rt_den};


  end
end

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
always @ ( posedge ref_clk or negedge rst_n ) begin
  if ( !rst_n ) begin
     rt_make_den <= 8'b0;
  end else begin
    if ( hsync_1pz  && rt_hsync == 1'b0 && rt_ycnt < 10'd482) begin
        rt_make_den <= 8'b0;
    end else if ( creat_den ) begin
        rt_make_den <= 8'b0;
    end else begin
        rt_make_den <= rt_make_den + 1'b1;
    end


  end
end

always @ ( posedge ref_clk or negedge rst_n) begin
  if ( !rst_n ) begin
     creat_den <= 1'b0;
     count_new_den <= 16'b0;
  end else begin
    if ( rt_ycnt == 10'd480 ) begin
      if ( rt_make_den == 8'd46 ) begin
        count_new_den <= 16'b0;
        creat_den     <= 1'b1;
      end else if ( count_new_den == 16'd639 )begin
        creat_den <= 1'b0;
      end else begin
        count_new_den <= count_new_den + 1'b1;
        creat_den     <= creat_den;
      end
    end else if ( rt_ycnt == 10'd481 && rt_hsync == 1'b0 ) begin
      if ( rt_make_den == 8'd46) begin
        count_new_den <= 16'b0;
        creat_den     <= 1'b1;
      end else if ( count_new_den == 16'd639 )begin
        creat_den <= 1'b0;
      end else begin
        count_new_den <= count_new_den + 1'b1;
        creat_den     <= creat_den;
      end
    end else begin
       count_new_den <= 16'b0;
       creat_den     <= 1'b0;
    end


  end
end

always @ ( posedge ref_clk or negedge rst_n ) begin
  if ( !rst_n ) begin
    regen_cnt   <= 9'b0;
  end else begin
    if ( vsync_1pz ) begin
      regen_cnt <= ( regen_cnt == 9'b11 ) ? 9'b11 : regen_cnt + 1'b1;
    end else begin
      regen_cnt <= regen_cnt;
    end


  end
end

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
always @ ( posedge ref_clk or negedge rst_n) begin
  if ( !rst_n ) begin
    rt_mtx[0][0] <= 8'b0;  rt_mtx[0][1] <= 8'b0;  rt_mtx[0][2] <= 8'b0;  rt_mtx[0][3] <= 8'b0;  rt_mtx[0][4] <= 8'b0;
    rt_mtx[1][0] <= 8'b0;  rt_mtx[1][1] <= 8'b0;  rt_mtx[1][2] <= 8'b0;  rt_mtx[1][3] <= 8'b0;  rt_mtx[1][4] <= 8'b0;
    rt_mtx[2][0] <= 8'b0;  rt_mtx[2][1] <= 8'b0;  rt_mtx[2][2] <= 8'b0;  rt_mtx[2][3] <= 8'b0;  rt_mtx[2][4] <= 8'b0;
    rt_mtx[3][0] <= 8'b0;  rt_mtx[3][1] <= 8'b0;  rt_mtx[3][2] <= 8'b0;  rt_mtx[3][3] <= 8'b0;  rt_mtx[3][4] <= 8'b0;
    rt_mtx[4][0] <= 8'b0;  rt_mtx[4][1] <= 8'b0;  rt_mtx[4][2] <= 8'b0;  rt_mtx[4][3] <= 8'b0;  rt_mtx[4][4] <= 8'b0;
  end else begin
    if ( rt_ycnt == 10'd2 ) begin
      if ( rt_xcnt == 10'd2 ) begin
        rt_mtx[0][0] <= rt_mtx[0][3];  rt_mtx[0][1] <= rt_mtx[0][3];  rt_mtx[0][2] <= rt_mtx[0][3];  rt_mtx[0][3] <= rt_mtx[0][4];  rt_mtx[0][4] <= rt_line_0;
        rt_mtx[1][0] <= rt_mtx[1][3];  rt_mtx[1][1] <= rt_mtx[1][3];  rt_mtx[1][2] <= rt_mtx[1][3];  rt_mtx[1][3] <= rt_mtx[1][4];  rt_mtx[1][4] <= rt_line_0;
        rt_mtx[2][0] <= rt_mtx[2][3];  rt_mtx[2][1] <= rt_mtx[2][3];  rt_mtx[2][2] <= rt_mtx[2][3];  rt_mtx[2][3] <= rt_mtx[2][4];  rt_mtx[2][4] <= rt_line_0;
        rt_mtx[3][0] <= rt_mtx[3][3];  rt_mtx[3][1] <= rt_mtx[3][3];  rt_mtx[3][2] <= rt_mtx[3][3];  rt_mtx[3][3] <= rt_mtx[3][4];  rt_mtx[3][4] <= rt_line_1;
        rt_mtx[4][0] <= rt_mtx[4][3];  rt_mtx[4][1] <= rt_mtx[4][3];  rt_mtx[4][2] <= rt_mtx[4][3];  rt_mtx[4][3] <= rt_mtx[4][4];  rt_mtx[4][4] <= rt_line_2;
      end else if ( rt_xcnt == 10'd3 ) begin
        rt_mtx[0][0] <= rt_mtx[0][2];  rt_mtx[0][1] <= rt_mtx[0][2];  rt_mtx[0][2] <= rt_mtx[0][3];  rt_mtx[0][3] <= rt_mtx[0][4];  rt_mtx[0][4] <= rt_line_0;
        rt_mtx[1][0] <= rt_mtx[1][2];  rt_mtx[1][1] <= rt_mtx[1][2];  rt_mtx[1][2] <= rt_mtx[1][3];  rt_mtx[1][3] <= rt_mtx[1][4];  rt_mtx[1][4] <= rt_line_0;
        rt_mtx[2][0] <= rt_mtx[2][2];  rt_mtx[2][1] <= rt_mtx[2][2];  rt_mtx[2][2] <= rt_mtx[2][3];  rt_mtx[2][3] <= rt_mtx[2][4];  rt_mtx[2][4] <= rt_line_0;
        rt_mtx[3][0] <= rt_mtx[3][2];  rt_mtx[3][1] <= rt_mtx[3][2];  rt_mtx[3][2] <= rt_mtx[3][3];  rt_mtx[3][3] <= rt_mtx[3][4];  rt_mtx[3][4] <= rt_line_1;
        rt_mtx[4][0] <= rt_mtx[4][2];  rt_mtx[4][1] <= rt_mtx[4][2];  rt_mtx[4][2] <= rt_mtx[4][3];  rt_mtx[4][3] <= rt_mtx[4][4];  rt_mtx[4][4] <= rt_line_2;
      end else begin
      rt_mtx[0][0] <= rt_mtx[0][1];  rt_mtx[0][1] <= rt_mtx[0][2];  rt_mtx[0][2] <= rt_mtx[0][3];  rt_mtx[0][3] <= rt_mtx[0][4];  rt_mtx[0][4] <= rt_line_0;
      rt_mtx[1][0] <= rt_mtx[1][1];  rt_mtx[1][1] <= rt_mtx[1][2];  rt_mtx[1][2] <= rt_mtx[1][3];  rt_mtx[1][3] <= rt_mtx[1][4];  rt_mtx[1][4] <= rt_line_0;
      rt_mtx[2][0] <= rt_mtx[2][1];  rt_mtx[2][1] <= rt_mtx[2][2];  rt_mtx[2][2] <= rt_mtx[2][3];  rt_mtx[2][3] <= rt_mtx[2][4];  rt_mtx[2][4] <= rt_line_0;
      rt_mtx[3][0] <= rt_mtx[3][1];  rt_mtx[3][1] <= rt_mtx[3][2];  rt_mtx[3][2] <= rt_mtx[3][3];  rt_mtx[3][3] <= rt_mtx[3][4];  rt_mtx[3][4] <= rt_line_1;
      rt_mtx[4][0] <= rt_mtx[4][1];  rt_mtx[4][1] <= rt_mtx[4][2];  rt_mtx[4][2] <= rt_mtx[4][3];  rt_mtx[4][3] <= rt_mtx[4][4];  rt_mtx[4][4] <= rt_line_2;
      end
    end else if ( rt_ycnt == 10'd3 ) begin
      if ( rt_xcnt == 10'd2 ) begin
        rt_mtx[0][0] <= rt_mtx[1][3];  rt_mtx[0][1] <= rt_mtx[1][3];  rt_mtx[0][2] <= rt_mtx[1][3];  rt_mtx[0][3] <= rt_mtx[1][4];  rt_mtx[0][4] <= rt_line_0;
        rt_mtx[1][0] <= rt_mtx[1][3];  rt_mtx[1][1] <= rt_mtx[1][3];  rt_mtx[1][2] <= rt_mtx[1][3];  rt_mtx[1][3] <= rt_mtx[1][4];  rt_mtx[1][4] <= rt_line_0;
        rt_mtx[2][0] <= rt_mtx[2][3];  rt_mtx[2][1] <= rt_mtx[2][3];  rt_mtx[2][2] <= rt_mtx[2][3];  rt_mtx[2][3] <= rt_mtx[2][4];  rt_mtx[2][4] <= rt_line_1;
        rt_mtx[3][0] <= rt_mtx[3][3];  rt_mtx[3][1] <= rt_mtx[3][3];  rt_mtx[3][2] <= rt_mtx[3][3];  rt_mtx[3][3] <= rt_mtx[3][4];  rt_mtx[3][4] <= rt_line_2;
        rt_mtx[4][0] <= rt_mtx[4][3];  rt_mtx[4][1] <= rt_mtx[4][3];  rt_mtx[4][2] <= rt_mtx[4][3];  rt_mtx[4][3] <= rt_mtx[4][4];  rt_mtx[4][4] <= rt_line_3;
      end else if ( rt_xcnt == 10'd3 ) begin
        rt_mtx[0][0] <= rt_mtx[1][2];  rt_mtx[0][1] <= rt_mtx[1][2];  rt_mtx[0][2] <= rt_mtx[1][3];  rt_mtx[0][3] <= rt_mtx[1][4];  rt_mtx[0][4] <= rt_line_0;
        rt_mtx[1][0] <= rt_mtx[1][2];  rt_mtx[1][1] <= rt_mtx[1][2];  rt_mtx[1][2] <= rt_mtx[1][3];  rt_mtx[1][3] <= rt_mtx[1][4];  rt_mtx[1][4] <= rt_line_0;
        rt_mtx[2][0] <= rt_mtx[2][2];  rt_mtx[2][1] <= rt_mtx[2][2];  rt_mtx[2][2] <= rt_mtx[2][3];  rt_mtx[2][3] <= rt_mtx[2][4];  rt_mtx[2][4] <= rt_line_1;
        rt_mtx[3][0] <= rt_mtx[3][2];  rt_mtx[3][1] <= rt_mtx[3][2];  rt_mtx[3][2] <= rt_mtx[3][3];  rt_mtx[3][3] <= rt_mtx[3][4];  rt_mtx[3][4] <= rt_line_2;
        rt_mtx[4][0] <= rt_mtx[4][2];  rt_mtx[4][1] <= rt_mtx[4][2];  rt_mtx[4][2] <= rt_mtx[4][3];  rt_mtx[4][3] <= rt_mtx[4][4];  rt_mtx[4][4] <= rt_line_3;
      end else begin
      rt_mtx[0][0] <= rt_mtx[0][1];  rt_mtx[0][1] <= rt_mtx[0][2];  rt_mtx[0][2] <= rt_mtx[0][3];  rt_mtx[0][3] <= rt_mtx[0][4];  rt_mtx[0][4] <= rt_line_0;
      rt_mtx[1][0] <= rt_mtx[1][1];  rt_mtx[1][1] <= rt_mtx[1][2];  rt_mtx[1][2] <= rt_mtx[1][3];  rt_mtx[1][3] <= rt_mtx[1][4];  rt_mtx[1][4] <= rt_line_0;
      rt_mtx[2][0] <= rt_mtx[2][1];  rt_mtx[2][1] <= rt_mtx[2][2];  rt_mtx[2][2] <= rt_mtx[2][3];  rt_mtx[2][3] <= rt_mtx[2][4];  rt_mtx[2][4] <= rt_line_1;
      rt_mtx[3][0] <= rt_mtx[3][1];  rt_mtx[3][1] <= rt_mtx[3][2];  rt_mtx[3][2] <= rt_mtx[3][3];  rt_mtx[3][3] <= rt_mtx[3][4];  rt_mtx[3][4] <= rt_line_2;
      rt_mtx[4][0] <= rt_mtx[4][1];  rt_mtx[4][1] <= rt_mtx[4][2];  rt_mtx[4][2] <= rt_mtx[4][3];  rt_mtx[4][3] <= rt_mtx[4][4];  rt_mtx[4][4] <= rt_line_3;
      end

    end else if ( rt_y_state == 3'd0) begin
      rt_mtx[0][0] <= rt_mtx[0][1];  rt_mtx[0][1] <= rt_mtx[0][2];  rt_mtx[0][2] <= rt_mtx[0][3];  rt_mtx[0][3] <= rt_mtx[0][4];  rt_mtx[0][4] <= rt_line_1;
      rt_mtx[1][0] <= rt_mtx[1][1];  rt_mtx[1][1] <= rt_mtx[1][2];  rt_mtx[1][2] <= rt_mtx[1][3];  rt_mtx[1][3] <= rt_mtx[1][4];  rt_mtx[1][4] <= rt_line_2;
      rt_mtx[2][0] <= rt_mtx[2][1];  rt_mtx[2][1] <= rt_mtx[2][2];  rt_mtx[2][2] <= rt_mtx[2][3];  rt_mtx[2][3] <= rt_mtx[2][4];  rt_mtx[2][4] <= rt_line_3;
      rt_mtx[3][0] <= rt_mtx[3][1];  rt_mtx[3][1] <= rt_mtx[3][2];  rt_mtx[3][2] <= rt_mtx[3][3];  rt_mtx[3][3] <= rt_mtx[3][4];  rt_mtx[3][4] <= rt_line_4;
      rt_mtx[4][0] <= rt_mtx[4][1];  rt_mtx[4][1] <= rt_mtx[4][2];  rt_mtx[4][2] <= rt_mtx[4][3];  rt_mtx[4][3] <= rt_mtx[4][4];  rt_mtx[4][4] <= rt_line_0;

    end else if ( rt_y_state == 3'd1 ) begin
      rt_mtx[0][0] <= rt_mtx[0][1];  rt_mtx[0][1] <= rt_mtx[0][2];  rt_mtx[0][2] <= rt_mtx[0][3];  rt_mtx[0][3] <= rt_mtx[0][4];  rt_mtx[0][4] <= rt_line_2;
      rt_mtx[1][0] <= rt_mtx[1][1];  rt_mtx[1][1] <= rt_mtx[1][2];  rt_mtx[1][2] <= rt_mtx[1][3];  rt_mtx[1][3] <= rt_mtx[1][4];  rt_mtx[1][4] <= rt_line_3;
      rt_mtx[2][0] <= rt_mtx[2][1];  rt_mtx[2][1] <= rt_mtx[2][2];  rt_mtx[2][2] <= rt_mtx[2][3];  rt_mtx[2][3] <= rt_mtx[2][4];  rt_mtx[2][4] <= rt_line_4;
      rt_mtx[3][0] <= rt_mtx[3][1];  rt_mtx[3][1] <= rt_mtx[3][2];  rt_mtx[3][2] <= rt_mtx[3][3];  rt_mtx[3][3] <= rt_mtx[3][4];  rt_mtx[3][4] <= rt_line_0;
      rt_mtx[4][0] <= rt_mtx[4][1];  rt_mtx[4][1] <= rt_mtx[4][2];  rt_mtx[4][2] <= rt_mtx[4][3];  rt_mtx[4][3] <= rt_mtx[4][4];  rt_mtx[4][4] <= rt_line_1;

    end else if ( rt_y_state == 3'd2 ) begin
      rt_mtx[0][0] <= rt_mtx[0][1];  rt_mtx[0][1] <= rt_mtx[0][2];  rt_mtx[0][2] <= rt_mtx[0][3];  rt_mtx[0][3] <= rt_mtx[0][4];  rt_mtx[0][4] <= rt_line_3;
      rt_mtx[1][0] <= rt_mtx[1][1];  rt_mtx[1][1] <= rt_mtx[1][2];  rt_mtx[1][2] <= rt_mtx[1][3];  rt_mtx[1][3] <= rt_mtx[1][4];  rt_mtx[1][4] <= rt_line_4;
      rt_mtx[2][0] <= rt_mtx[2][1];  rt_mtx[2][1] <= rt_mtx[2][2];  rt_mtx[2][2] <= rt_mtx[2][3];  rt_mtx[2][3] <= rt_mtx[2][4];  rt_mtx[2][4] <= rt_line_0;
      rt_mtx[3][0] <= rt_mtx[3][1];  rt_mtx[3][1] <= rt_mtx[3][2];  rt_mtx[3][2] <= rt_mtx[3][3];  rt_mtx[3][3] <= rt_mtx[3][4];  rt_mtx[3][4] <= rt_line_1;
      rt_mtx[4][0] <= rt_mtx[4][1];  rt_mtx[4][1] <= rt_mtx[4][2];  rt_mtx[4][2] <= rt_mtx[4][3];  rt_mtx[4][3] <= rt_mtx[4][4];  rt_mtx[4][4] <= rt_line_2;

    end else if ( rt_y_state == 3'd3 ) begin
      rt_mtx[0][0] <= rt_mtx[0][1];  rt_mtx[0][1] <= rt_mtx[0][2];  rt_mtx[0][2] <= rt_mtx[0][3];  rt_mtx[0][3] <= rt_mtx[0][4];  rt_mtx[0][4] <= rt_line_4;
      rt_mtx[1][0] <= rt_mtx[1][1];  rt_mtx[1][1] <= rt_mtx[1][2];  rt_mtx[1][2] <= rt_mtx[1][3];  rt_mtx[1][3] <= rt_mtx[1][4];  rt_mtx[1][4] <= rt_line_0;
      rt_mtx[2][0] <= rt_mtx[2][1];  rt_mtx[2][1] <= rt_mtx[2][2];  rt_mtx[2][2] <= rt_mtx[2][3];  rt_mtx[2][3] <= rt_mtx[2][4];  rt_mtx[2][4] <= rt_line_1;
      rt_mtx[3][0] <= rt_mtx[3][1];  rt_mtx[3][1] <= rt_mtx[3][2];  rt_mtx[3][2] <= rt_mtx[3][3];  rt_mtx[3][3] <= rt_mtx[3][4];  rt_mtx[3][4] <= rt_line_2;
      rt_mtx[4][0] <= rt_mtx[4][1];  rt_mtx[4][1] <= rt_mtx[4][2];  rt_mtx[4][2] <= rt_mtx[4][3];  rt_mtx[4][3] <= rt_mtx[4][4];  rt_mtx[4][4] <= rt_line_3;

    end else if ( rt_y_state == 3'd4 ) begin
      rt_mtx[0][0] <= rt_mtx[0][1];  rt_mtx[0][1] <= rt_mtx[0][2];  rt_mtx[0][2] <= rt_mtx[0][3];  rt_mtx[0][3] <= rt_mtx[0][4];  rt_mtx[0][4] <= rt_line_0;
      rt_mtx[1][0] <= rt_mtx[1][1];  rt_mtx[1][1] <= rt_mtx[1][2];  rt_mtx[1][2] <= rt_mtx[1][3];  rt_mtx[1][3] <= rt_mtx[1][4];  rt_mtx[1][4] <= rt_line_1;
      rt_mtx[2][0] <= rt_mtx[2][1];  rt_mtx[2][1] <= rt_mtx[2][2];  rt_mtx[2][2] <= rt_mtx[2][3];  rt_mtx[2][3] <= rt_mtx[2][4];  rt_mtx[2][4] <= rt_line_2;
      rt_mtx[3][0] <= rt_mtx[3][1];  rt_mtx[3][1] <= rt_mtx[3][2];  rt_mtx[3][2] <= rt_mtx[3][3];  rt_mtx[3][3] <= rt_mtx[3][4];  rt_mtx[3][4] <= rt_line_3;
      rt_mtx[4][0] <= rt_mtx[4][1];  rt_mtx[4][1] <= rt_mtx[4][2];  rt_mtx[4][2] <= rt_mtx[4][3];  rt_mtx[4][3] <= rt_mtx[4][4];  rt_mtx[4][4] <= rt_line_4;

      //rt_mtx[0][0] <= rt_mtx[0][0];  rt_mtx[0][1] <= rt_mtx[0][1];  rt_mtx[0][2] <= rt_mtx[0][2];  rt_mtx[0][3] <= rt_mtx[0][3];  rt_mtx[0][4] <= rt_mtx[0][4];
      //rt_mtx[1][0] <= rt_mtx[1][0];  rt_mtx[1][1] <= rt_mtx[1][1];  rt_mtx[1][2] <= rt_mtx[1][2];  rt_mtx[1][3] <= rt_mtx[1][3];  rt_mtx[1][4] <= rt_mtx[1][4];
      //rt_mtx[2][0] <= rt_mtx[2][0];  rt_mtx[2][1] <= rt_mtx[2][1];  rt_mtx[2][2] <= rt_mtx[2][2];  rt_mtx[2][3] <= rt_mtx[2][3];  rt_mtx[2][4] <= rt_mtx[2][4];
      //rt_mtx[3][0] <= rt_mtx[3][0];  rt_mtx[3][1] <= rt_mtx[3][1];  rt_mtx[3][2] <= rt_mtx[3][2];  rt_mtx[3][3] <= rt_mtx[3][3];  rt_mtx[3][4] <= rt_mtx[3][4];
      //rt_mtx[4][0] <= rt_mtx[4][0];  rt_mtx[4][1] <= rt_mtx[4][1];  rt_mtx[4][2] <= rt_mtx[4][2];  rt_mtx[4][3] <= rt_mtx[4][3];  rt_mtx[4][4] <= rt_mtx[4][4];
    end
  end
end



// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
always @ ( posedge ref_clk or negedge rst_n ) begin
  if ( !rst_n ) begin
    regen_vsync_dly <= 3'b0;
    regen_hsync_dly <= 3'b0;
    regen_den_dly   <= 3'b0;
  end else begin
    regen_vsync_dly <= { regen_vsync_dly[1], regen_vsync_dly[0], regen_Synco[2] };
    regen_hsync_dly <= { regen_hsync_dly[1], regen_hsync_dly[0], regen_Synco[1] };
    regen_den_dly   <= { regen_den_dly[1],   regen_den_dly[0],   regen_Synco[0] };


  end
end

always @ ( posedge ref_clk or negedge rst_n ) begin
  if ( !rst_n ) begin
    value_Med_to_threshold <= 1'b0;
  end else begin
    value_Med_to_threshold <= (value_Med > 8'd5) ? 1'b1 : 1'b0;
  end
end

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
timing_generator regen_timing (
  .clk                            ( ref_clk       ),
  .rst_n                          ( regen_rst_n   ),
  .h_total                        ( 16'd800       ),
  .h_size                         ( 16'd640       ),
  .h_sync                         ( 16'd96        ),
  .h_start                        ( 16'd144       ),
  .v_total                        ( 16'd525       ),
  .v_size                         ( 16'd480       ),
  .v_sync                         ( 16'd2         ),
  .v_start                        ( 16'd35        ),
  .vs_reset                       ( 23'b0         ),
  .hcount                         ( /*UNCONNECT*/ ),
  .vcount                         ( /*UNCONNECT*/ ),
  .Synco                          ( regen_Synco   )
) ;

LLMF_5x5 i_LLMF_5x5 (
  .ref_clk                        ( ref_clk       ),
  .mem_clk                        ( mem_clk       ),
  .rst_n                          ( rst_n         ),
  .sw_rst_n                       ( sw_rst_n      ),
  .value_p00                      ( matrix_p00    ),
  .value_p01                      ( matrix_p01    ),
  .value_p02                      ( matrix_p02    ),
  .value_p03                      ( matrix_p03    ),
  .value_p04                      ( matrix_p04    ),
  .value_p10                      ( matrix_p10    ),
  .value_p11                      ( matrix_p11    ),
  .value_p12                      ( matrix_p12    ),
  .value_p13                      ( matrix_p13    ),
  .value_p14                      ( matrix_p14    ),
  .value_p20                      ( matrix_p20    ),
  .value_p21                      ( matrix_p21    ),
  .value_p22                      ( matrix_p22    ),
  .value_p23                      ( matrix_p23    ),
  .value_p24                      ( matrix_p24    ),
  .value_p30                      ( matrix_p30    ),
  .value_p31                      ( matrix_p31    ),
  .value_p32                      ( matrix_p32    ),
  .value_p33                      ( matrix_p33    ),
  .value_p34                      ( matrix_p34    ),
  .value_p40                      ( matrix_p40    ),
  .value_p41                      ( matrix_p41    ),
  .value_p42                      ( matrix_p42    ),
  .value_p43                      ( matrix_p43    ),
  .value_p44                      ( matrix_p44    ),
  .value_Max                      ( value_Max     ),
  .value_Med                      ( value_Med     ),
  .value_Min                      ( value_Min     )
);



endmodule 