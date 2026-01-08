// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ medain_buffer_5.sv                                                                        //
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
// output to median
module  medain_buffer_5#(
    parameter DATA_WIDTH = 8,
    parameter DATA_DEPTH = 640
)
(
  input wire                      ref_clk,
  input wire                      mem_clk,
  input wire                      rst_n,

  input wire  [10 :0]             DPi,
    
  output wire [ 2: 0]             DPo_sync,
  output wire [DATA_WIDTH - 1 :0] out_line_0,
  output wire [DATA_WIDTH - 1 :0] out_line_1,
  output wire [DATA_WIDTH - 1 :0] out_line_2,
  output wire [DATA_WIDTH - 1 :0] out_line_3,
  output wire [DATA_WIDTH - 1 :0] out_line_4
);
// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------

  wire                            rt_vsync;
  wire                            rt_hsync;
  wire                            rt_den;
  wire        [  7: 0]            rt_data;

  reg         [ 9: 0]             rt_hcnt;
  reg         [ 9: 0]             rt_vcnt;

  reg         [ 9: 0]             rt_ycnt;
  reg         [ 9: 0]             rt_xcnt;
  wire        [ 9: 0]             ram_addr;

  reg         [ 2: 0]             rt_x_state;
  reg         [ 2: 0]             rt_y_state;

  reg         [ 1: 0]             rt_vsync_delay_2t;
  reg         [ 1: 0]             rt_hsync_delay_2t;
  reg         [ 1: 0]             rt_den_delay_2t;

  wire        [ 7: 0]             lbuffer_0_data_out;
  wire        [ 7: 0]             lbuffer_1_data_out;
  wire        [ 7: 0]             lbuffer_2_data_out;
  wire        [ 7: 0]             lbuffer_3_data_out;
  wire        [ 7: 0]             lbuffer_4_data_out;

  wire                            line_0_w_vld;
  wire                            line_1_w_vld;
  wire                            line_2_w_vld;
  wire                            line_3_w_vld;
  wire                            line_4_w_vld;

  reg         [ 7: 0]             rt_make_den;
  reg                             creat_den;
  reg         [ 9: 0]             count_new_den;
// tag OUTs assignment ---------------------------------------------------------------------------------------------
assign  DPo_sync[2]               = rt_vsync_delay_2t[0];
assign  DPo_sync[1]               = rt_hsync_delay_2t[0];
assign  DPo_sync[0]               = rt_den_delay_2t[0];

assign  out_line_0                = ( rt_ycnt >= 10'd480 ) ? lbuffer_4_data_out : lbuffer_0_data_out;
assign  out_line_1                = ( rt_ycnt == 10'd481 ) ? lbuffer_4_data_out : lbuffer_1_data_out;
assign  out_line_2                = lbuffer_2_data_out;
assign  out_line_3                = lbuffer_3_data_out;
assign  out_line_4                = lbuffer_4_data_out;

// tag INs assignment ----------------------------------------------------------------------------------------------
assign rt_vsync                   = DPi[10];
assign rt_hsync                   = DPi[9];
assign rt_den                     = ( DPi[8] || creat_den );
assign rt_data                    = DPi[ 7: 0];

// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
assign ram_addr                   = ( rt_xcnt == 10'd640 ) ? 10'd639 : rt_xcnt;

assign line_0_w_vld               = ( (rt_den | rt_den_delay_2t[1]) && rt_y_state == 3'd0 ) ? 1'b1 : 1'b0;
assign line_1_w_vld               = ( (rt_den | rt_den_delay_2t[1]) && rt_y_state == 3'd1 ) ? 1'b1 : 1'b0;
assign line_2_w_vld               = ( (rt_den | rt_den_delay_2t[1]) && rt_y_state == 3'd2 ) ? 1'b1 : 1'b0;
assign line_3_w_vld               = ( (rt_den | rt_den_delay_2t[1]) && rt_y_state == 3'd3 ) ? 1'b1 : 1'b0;
assign line_4_w_vld               = ( (rt_den | rt_den_delay_2t[1]) && rt_y_state == 3'd4 ) ? 1'b1 : 1'b0;

assign hsync_1pz                  = ( { rt_hsync, rt_hsync_delay_2t[0] } == 2'b01 ) ? 1'b1 : 1'b0 ;

// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------

// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
always @ (posedge ref_clk or negedge rst_n) begin
  if ( ~rst_n ) begin
    rt_xcnt    <= 10'd0;
    rt_x_state <= 2'b0;
  end else begin
    if ( rt_vsync || rt_hsync) begin
      rt_xcnt    <= 10'b0;
      rt_x_state <= 2'b0;
    end else if ( rt_den || creat_den) begin
      rt_xcnt    <= rt_xcnt + 1'b1;
      rt_x_state <= (rt_x_state == 3'd4) ? 3'b0 :  rt_x_state + 1'b1;
    end else begin
      rt_xcnt    <= rt_xcnt;
      rt_x_state <= rt_x_state ;
    end


  end
end

always @ ( posedge ref_clk or negedge rst_n ) begin
  if ( ~rst_n ) begin
    rt_ycnt    <= 10'd0;
    rt_y_state <= 3'b0;
  end else begin
    if ( rt_vsync && rt_hsync ) begin
      rt_ycnt    <= 10'b0;
      rt_y_state <= 3'b0;
    end else if ( rt_hsync && rt_xcnt == 10'd640/*(h_size)*/ ) begin
      rt_ycnt    <= rt_ycnt + 1'b1;
      rt_y_state <= ( rt_y_state == 3'd4 ) ? 3'b0 :  rt_y_state + 1'b1;
    end else begin
      rt_ycnt    <= rt_ycnt;
      rt_y_state <= rt_y_state;
    end


  end
end

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
always @( posedge ref_clk or negedge rst_n ) begin
  if ( ~rst_n ) begin
     rt_make_den <= 8'b0;
  end else begin
    if ( hsync_1pz  && rt_hsync == 1'b0 && rt_ycnt < 10'd482 ) begin
        rt_make_den <= 8'b0;
    end else if ( creat_den ) begin
        rt_make_den <= 8'b0;
    end else begin
        rt_make_den <= rt_make_den + 1'b1;
    end
  end
end

always @ ( posedge ref_clk or negedge rst_n ) begin
  if ( ~rst_n ) begin
     creat_den <= 1'b0;
     count_new_den <= 10'b0;
  end else begin
    if ( rt_ycnt == 10'd480 ) begin
      if ( rt_make_den == 8'd46 ) begin
        count_new_den <= 10'b0;
        creat_den     <= 1'b1;
      end else if ( count_new_den == 10'd639 )begin
        creat_den <= 1'b0;
      end else begin
        count_new_den <= count_new_den + 1'b1;
        creat_den     <= creat_den;
      end
    end else if ( rt_ycnt == 10'd481 && rt_hsync == 1'b0 ) begin
      if ( rt_make_den == 8'd46 ) begin
        count_new_den <= 10'b0;
        creat_den     <= 1'b1;
      end else if ( count_new_den == 10'd639 )begin
        creat_den <= 1'b0;
      end else begin
        count_new_den <= count_new_den + 1'b1;
        creat_den     <= creat_den;
      end
    end else begin
       count_new_den <= 10'b0;
       creat_den     <= 1'b0;
    end


  end
end

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
always @ ( posedge ref_clk or negedge rst_n ) begin
  if (!rst_n) begin
    rt_vsync_delay_2t <= 2'b0;
    rt_hsync_delay_2t <= 2'b0;
    rt_den_delay_2t   <= 2'b0;
  end else begin
    rt_vsync_delay_2t <= { rt_vsync_delay_2t[0], rt_vsync };
    rt_hsync_delay_2t <= { rt_hsync_delay_2t[0], rt_hsync };
    rt_den_delay_2t   <= { rt_den_delay_2t[0],   rt_den   };


  end
end

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
linebuffer_1x640x8 u0_line(
  .clk      ( ref_clk            ),
  .rst_n    ( rst_n              ),
  .wr_en    ( line_0_w_vld       ),
  .rd_en    ( ~line_0_w_vld      ),
  .addr     ( ram_addr           ),
  .data_in  ( rt_data            ),
  .data_out ( lbuffer_0_data_out )
);

linebuffer_1x640x8 u1_line(
  .clk      ( ref_clk            ),
  .rst_n    ( rst_n              ),
  .wr_en    ( line_1_w_vld       ),
  .rd_en    ( ~line_1_w_vld      ),
  .addr     ( ram_addr           ),
  .data_in  ( rt_data            ),
  .data_out ( lbuffer_1_data_out )
);

linebuffer_1x640x8 u2_line(
  .clk      ( ref_clk            ),
  .rst_n    ( rst_n              ),
  .wr_en    ( line_2_w_vld       ),
  .rd_en    ( ~line_2_w_vld      ),
  .addr     ( ram_addr           ),
  .data_in  ( rt_data            ),
  .data_out ( lbuffer_2_data_out )
);

linebuffer_1x640x8 u3_line(
  .clk      ( ref_clk            ),
  .rst_n    ( rst_n              ),
  .wr_en    ( line_3_w_vld       ),
  .rd_en    ( ~line_3_w_vld      ),
  .addr     ( ram_addr           ),
  .data_in  ( rt_data            ),
  .data_out ( lbuffer_3_data_out )
);

linebuffer_1x640x8 u4_line(
  .clk      ( ref_clk            ),
  .rst_n    ( rst_n              ),
  .wr_en    ( line_4_w_vld       ),
  .rd_en    ( ~line_4_w_vld      ),
  .addr     ( ram_addr           ),
  .data_in  ( rt_data            ),
  .data_out ( lbuffer_4_data_out )
);


// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****

endmodule 