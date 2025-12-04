`timescale 1ns/1ps

`include "sim_timing_gen_defines.sv"
//`define IMG_640X480
`define DEBUG_OUT

module sim_timing_gen_tb;

localparam  PIC_INPUT_PATH    =   "./image_in/o_20240115_113015_255.txt"          ;
localparam  PIC_OUTPUT_PATH   =   "./image_out/R_20240115_113015_256_verilog_dila.bmp"     ;


  parameter REF_CLK_PERIOD = 5;

  reg                             src_clk;
  wire                            ref_clk;
  wire                            mem_clk;
  reg                             rst_n;
  reg                             star;

//TG
  reg  [15: 0]                    v_total;
  reg  [15: 0]                    v_size;
  reg  [15: 0]                    v_start, v_sync;
  reg  [15: 0]                    h_total;
  reg  [15: 0]                    h_size;
  reg  [15: 0]                    h_start, h_sync;
  reg  [22: 0]                    vs_reset;


  wire                            Vsync;
  wire                            Hsync;
  wire                            Den;
  wire [26: 0]                    is_DPo;
  wire [26: 0]                    pass_DPo;
  wire [10: 0]                    gray_DPo;
  wire [10: 0]                    DPo_img_diff;
  wire [ 3: 0]                    DPo_dila;

  wire [10: 0]                    median_DPo;
  wire [ 2: 0]                    DPi_sync;
  wire [ 7: 0]                    median_line_0;
  wire [ 7: 0]                    median_line_1;
  wire [ 7: 0]                    median_line_2;
  wire [ 7: 0]                    median_line_3;
  wire [ 7: 0]                    median_line_4;
  wire [ 2: 0]                    DPo_sync;

  wire [15: 0]                    hcount;
  wire [15: 0]                    vcount;
  wire                            sim_Vsync;
  wire                            sim_Hsync;

`ifdef IMG_1920X1080
  parameter BITMAP_WIDTH  = 1920;
  parameter BITMAP_HEIGHT = 1080;

  initial begin
    /********** Timing parameter **********/

  h_size  = 16'd1920;
  v_size  = 16'd1080;
  h_total = 16'd2200;
  v_total = 16'd1125;
  h_sync  = 16'd44;
  v_sync  = 16'd5;
  h_start = 16'd192;
  v_start = 16'd41;
  //vs_reset = 600;
  end
`endif

`ifdef IMG_640X480
  parameter BITMAP_WIDTH  = 640;
  parameter BITMAP_HEIGHT = 480;
  parameter DATA_WIDTH    = 8;

  initial begin
    /********** Timing parameter **********/

  h_size   = 16'd640;
  v_size   = 16'd480;
  h_total  = 16'd800;
  v_total  = 16'd525;
  h_sync   = 16'd96;
  v_sync   = 16'd2;
  h_start  = 16'd144;
  v_start  = 16'd35;
  vs_reset = 23'd0;
  end
`endif
  //Width  = 16'd640;
  //Height = 16'd480;
  //HRB    = 16'd8;
  //HFP    = 16'd8;
  //HSYNC  = 16'd96;
  //HBP    = 16'd40;
  //HLB    = 16'd8;
  //VBB    = 16'd8;
  //VFP    = 16'd2;
  //VSYNC  = 16'd2;
  //VBP    = 16'd35;
  //VTB    = 16'd8;
  //h_start = HSYNC + HBP + HLB;
  //v_start = VSYNC + VBP + VTB;
  //h_total = Width + HSYNC + HBP + HLB + HRB + HFP;
  //v_total = Height + VSYNC + VBP + VTB + VBB + VFP;

initial begin

/********** Timing parameter **********/

  #0  src_clk  = 1'b0;
  #0  rst_n    = 1'b1;

  #10 rst_n    =0;
  #10 rst_n    =1'b1;
  #13800000 $finish;

end

always #(REF_CLK_PERIOD/2) src_clk<=~src_clk;

wire [26: 0] DPi;
wire next_image_signal;
assign DPi = {gray_DPo,gray_DPo[7:0],gray_DPo[7:0]};

/********** Waveform output **********/

initial begin
      $fsdbDumpfile("./sim_timing_gen_tb_20240204.fsdb");
      $fsdbDumpvars(0, sim_timing_gen_tb, "+all");
      $fsdbDumpMDA;
end


clk_gen i_clk_gen (
  .src_clk ( src_clk ),
  .rst_n   ( rst_n   ),
  .mem_clk ( mem_clk ),
  .ref_clk ( ref_clk )
);



// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//        Image source (read BMP file)         \**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
image_source #(
  .PIC_PATH      ( PIC_INPUT_PATH      ),
  .BPP           ( 24                  ),  // Bits per pixel
  .BITMAP_WIDTH  ( BITMAP_WIDTH        ),  // Bitmap width
  .BITMAP_HEIGHT ( BITMAP_HEIGHT       )   // Bitmap height
) image_source(
  .clk               ( ref_clk             ),
  .rst_n             ( rst_n               ),
  .Synci             ( {Vsync, Hsync, Den} ),
  .DPo               ( is_DPo              ),
  .next_image_signal ( next_image_signal   )
);

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//    Timing generator   /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
timing_generator timing_generator(
  .Synco    ( {Vsync, Hsync, Den} ),
  .clk      ( ref_clk             ),
  .rst_n    ( rst_n               ),
  .v_total  ( v_total             ),
  .v_sync   ( v_sync              ),
  .v_start  ( v_start             ),
  .v_size   ( v_size              ),
  .h_total  ( h_total             ),
  .h_sync   ( h_sync              ),
  .h_start  ( h_start             ),
  .h_size   ( h_size              ),
  .hcount   (                     ),
  .vcount   (                     ),
  .vs_reset (                     )
);


/********** Function to be verified (DUT) **********/

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//      rgb2grayscale    /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
rgb2grayscale i_rgb2grayscale (
.clk           ( ref_clk  ),
.rst_n         ( rst_n    ),
.pass2gray_flag( 1'b1     ),
.RGB2GRAY_DPi  ( is_DPo   ),
.gray_DPo      ( gray_DPo )
) ;


// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
img_diff i_img_diff (
  .ref_clk      ( ref_clk      ),
  .mem_clk      ( mem_clk      ),
  .rst_n        ( rst_n        ),
  .DPi          ( gray_DPo     ),
  .Img_Diff_DPo ( DPo_img_diff )
);


// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//      median_5x5       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
medain_buffer_5 u0_medain_buffer_5 (
  .ref_clk           (ref_clk           ),
  .mem_clk           (mem_clk           ),
  .rst_n             (rst_n             ),
  .DPi               ( DPo_img_diff          ),
  .DPo_sync          ( DPo_sync      ),
  .out_line_0        ( median_line_0        ),
  .out_line_1        ( median_line_1        ),
  .out_line_2        ( median_line_2        ),
  .out_line_3        ( median_line_3        ),
  .out_line_4        ( median_line_4        )
);

median_5x5 i_median_5x5 (
  .ref_clk      (ref_clk      ),
  .mem_clk      (mem_clk      ),
  .rst_n        (rst_n        ),
  .DPi_sync     (DPo_sync     ),
  .median_line_0(median_line_0),
  .median_line_1(median_line_1),
  .median_line_2(median_line_2),
  .median_line_3(median_line_3),
  .median_line_4(median_line_4),
  .median_DPo   (median_DPo   )
);

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//        dilation       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
  wire        [ 2: 0]             DPo_2dila_sync;
  wire                            out_line_0;
  wire                            out_line_1;
  wire                            out_line_2;
  wire                            out_line_3;
  wire                            out_line_4;
  wire                            out_line_5;
  wire                            out_line_6;
  wire                            out_line_7;
  wire                            out_line_8;
  wire                            out_line_9;
  wire                            out_line_10;
  wire                            out_line_11;
  wire                            out_line_12;
  wire                            out_line_13;
  wire                            out_line_14;

closing_buffer_15 i_closing_buffer_15 (
  .ref_clk     ( ref_clk          ),
  .mem_clk     ( mem_clk          ),
  .rst_n       ( rst_n            ),
  .DPi         ( {median_DPo[10],median_DPo[9],median_DPo[8],median_DPo[0]} ),
  .DPo_sync    ( DPo_2dila_sync   ),
  .out_line_0  ( out_line_0       ),
  .out_line_1  ( out_line_1       ),
  .out_line_2  ( out_line_2       ),
  .out_line_3  ( out_line_3       ),
  .out_line_4  ( out_line_4       ),
  .out_line_5  ( out_line_5       ),
  .out_line_6  ( out_line_6       ),
  .out_line_7  ( out_line_7       ),
  .out_line_8  ( out_line_8       ),
  .out_line_9  ( out_line_9       ),
  .out_line_10 ( out_line_10      ),
  .out_line_11 ( out_line_11      ),
  .out_line_12 ( out_line_12      ),
  .out_line_13 ( out_line_13      ),
  .out_line_14 ( out_line_14      )
);

dilation i_dilation (
  .ref_clk      ( ref_clk         ),
  .mem_clk      ( mem_clk         ),
  .rst_n        ( rst_n           ),
  .DPi_sync     ( DPo_2dila_sync  ),
  .in_line_0    ( out_line_0      ),
  .in_line_1    ( out_line_1      ),
  .in_line_2    ( out_line_2      ),
  .in_line_3    ( out_line_3      ),
  .in_line_4    ( out_line_4      ),
  .in_line_5    ( out_line_5      ),
  .in_line_6    ( out_line_6      ),
  .in_line_7    ( out_line_7      ),
  .in_line_8    ( out_line_8      ),
  .in_line_9    ( out_line_9      ),
  .in_line_10   ( out_line_10     ),
  .in_line_11   ( out_line_11     ),
  .in_line_12   ( out_line_12     ),
  .in_line_13   ( out_line_13     ),
  .in_line_14   ( out_line_14     ),
  .DPo_dila     ( DPo_dila        )
);

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
/*
  wire                            matrix_frame_vsync;
  wire                            matrix_frame_href;
  wire                            matrix_frame_clken;
  wire [DATA_WIDTH - 1 :0]        matrix_p11;
  wire [DATA_WIDTH - 1 :0]        matrix_p12;
  wire [DATA_WIDTH - 1 :0]        matrix_p13;
  wire [DATA_WIDTH - 1 :0]        matrix_p21;
  wire [DATA_WIDTH - 1 :0]        matrix_p22;
  wire [DATA_WIDTH - 1 :0]        matrix_p23;
  wire [DATA_WIDTH - 1 :0]        matrix_p31;
  wire [DATA_WIDTH - 1 :0]        matrix_p32;
  wire [DATA_WIDTH - 1 :0]        matrix_p33;

matrix_generate_3x3#(
.DATA_WIDTH ( DATA_WIDTH ) ,
.DATA_DEPTH ( 640        )
) u0_matrix_generate_3x3(
  //input
  .clk                  ( ref_clk            ),
  .rst_n                ( rst_n              ),
  .per_frame_vsync      ( gray_DPo[10]       ),
  .per_frame_href       ( gray_DPo[9]        ), //hsync
  .per_frame_clken      ( gray_DPo[8]        ),
  .per_img_y            ( gray_DPo[7:0]      ),
  //output
  .matrix_frame_vsync   ( matrix_frame_vsync ),
  .matrix_frame_href    ( matrix_frame_href  ),
  .matrix_frame_clken   ( matrix_frame_clken ),
  .matrix_p11           ( matrix_p11         ),
  .matrix_p12           ( matrix_p12         ),
  .matrix_p13           ( matrix_p13         ),
  .matrix_p21           ( matrix_p21         ),
  .matrix_p22           ( matrix_p22         ),
  .matrix_p23           ( matrix_p23         ),
  .matrix_p31           ( matrix_p31         ),
  .matrix_p32           ( matrix_p32         ),
  .matrix_p33           ( matrix_p33         )
) ;
*/
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
  wire                            gauss_vsync;
  wire                            gauss_hsync;
  wire                            gauss_de;
  wire [ 7: 0]                    img_gauss;

image_gaussian_filter u_image_gaussian_filter
(
  .clk                (ref_clk   ),
  .rst_n              (rst_n     ),

  .per_frame_vsync    ( gray_DPo[10]  ),
  .per_frame_href     ( gray_DPo[9]   ),
  .per_frame_clken    ( gray_DPo[8]   ),
  .per_img_gray       ( gray_DPo[7:0] ),

  .post_frame_vsync   ( gauss_vsync   ),
  .post_frame_href    ( gauss_hsync   ),
  .post_frame_clken   ( gauss_de      ),
  .post_img_gray      ( img_gauss     )
);

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//          PASS         /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
`ifndef DEBUG_OUT
  pass o_pass (
    .clk      ( ref_clk      ),
    .rst_n    ( rst_n    ),
    .DPi      ( /*is_DPo*/ {DPo_dila[3], DPo_dila[2], DPo_dila[1], 7'b0, DPo_dila[0], 7'b0, DPo_dila[0], 7'b0, DPo_dila[0]}  ),
    .DPo      ( pass_DPo )
  );


`else
  wire         [ 7: 0]            out_255;

  assign out_255 = (DPo_dila[0] == 1'b1) ? 8'd255 : 8'd0;

  pass o_pass (
    .clk      ( ref_clk      ),
    .rst_n    ( rst_n    ),
    .DPi      ( /*is_DPo*/ {DPo_dila[3], DPo_dila[2], DPo_dila[1], out_255, out_255, out_255}  ),
    .DPo      ( pass_DPo )
  );

`endif

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//       Image capture (saved to BMP file)     \**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
image_capture #(
  .PIC_PATH    ( PIC_OUTPUT_PATH )

  )image_capture(
  .clk   ( ref_clk  ),
  .rst_n ( rst_n    ),
  .DPi   ( pass_DPo/*{gauss_vsync,gauss_hsync,gauss_de,img_gauss,img_gauss,img_gauss}*//*DPi*/  ),
  .Hsize ( h_size   ),
  .Vsize ( v_size   )
);

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
/*
sim_timing_gen i_sim_timing_gen (
  .clk    (ref_clk),
  .rst_n  (rst_n  ),
  .h_total(BITMAP_WIDTH),
  .v_total(BITMAP_HEIGHT),
  .hcount (hcount ),
  .vcount (vcount ),
  .v_sync ( sim_Vsync ),
  .h_sync ( sim_Hsync )
);
*/


endmodule
