`timescale 1ns/1ps
`include "sim_timing_gen_defines.svh"

module sim_timing_gen;
  parameter REF_CLK_PERIOD = 5;

  reg                             src_clk;
  reg                             rst_n;

//TG
  reg         [22 : 0]            vs_reset;
  logic       [15 : 0]            Hor_Addr_Time;
  logic       [15 : 0]            Hor_Sync_Time;
  logic       [15 : 0]            Hor_Back_Porch;
  logic       [15 : 0]            Hor_Left_Border;
  logic       [15 : 0]            Hor_Right_Border;
  logic       [15 : 0]            Hor_Front_Porch;
  logic       [15 :  0]           Ver_Addr_Time;
  logic       [15 :  0]           Ver_Sync_Time;
  logic       [15 :  0]           Ver_Back_Porch;
  logic       [15 :  0]           Ver_Bottom_Border;
  logic       [15 :  0]           Ver_Top_Border;
  logic       [15 :  0]           Ver_Front_Porch;
  logic       [26 : 24]           Synco;

  wire                            Vsync;
  wire                            Hsync;
  wire                            Den;
  wire [26: 0]                    is_DPo;
  wire [26: 0]                    pass_DPo;

  wire [15: 0]                    hcount;
  wire [15: 0]                    vcount;

  // wire [10: 0]                  gray_DPo;
  // wire [10: 0]                  DPo_img_diff;
  // wire [ 3: 0]                  DPo_dila;
  // wire [10: 0]                  median_DPo;
  // wire [ 2: 0]                  DPi_sync;
  // wire [ 7: 0]                  median_line_0;
  // wire [ 7: 0]                  median_line_1;
  // wire [ 7: 0]                  median_line_2;
  // wire [ 7: 0]                  median_line_3;
  // wire [ 7: 0]                  median_line_4;
  // wire [ 2: 0]                  DPo_sync;

initial begin
  #0  src_clk  = 1'b0;
  #0  rst_n    = 1'b1;
  #10 rst_n    =0;
  #10 rst_n    =1'b1;

end

`ifdef IMG_1920X1080
  parameter   BITMAP_WIDTH        = 1920;
  parameter   BITMAP_HEIGHT       = 1080;
  localparam  PIC_INPUT_PATH      = `PIC_INPUT_PATH_1920X1080_1;
  localparam  PIC_OUTPUT_PATH     = `PIC_OUTPUT_PATH_1920X1080_1;
  //localparam  PIC_INPUT_PATH      = `PIC_INPUT_PATH_1920X1080_BW  ;
  //localparam  PIC_OUTPUT_PATH     = `PIC_OUTPUT_PATH_1920X1080_BW ;

  initial begin
    //vs_reset = 600;
    Hor_Addr_Time                 = 16'd1920;
    Hor_Sync_Time                 = 16'd44;
    Hor_Back_Porch                = 16'd148;
    Hor_Left_Border               = 16'd0;
    Hor_Right_Border              = 16'd0;
    Hor_Front_Porch               = 16'd88;
    Ver_Addr_Time                 = 16'd1080;
    Ver_Sync_Time                 = 16'd5;
    Ver_Back_Porch                = 16'd36;
    Ver_Bottom_Border             = 16'd0;
    Ver_Top_Border                = 16'd0;
    Ver_Front_Porch               = 16'd4;
    #18000000 $finish;
  end
`endif

`ifdef IMG_640X480
  parameter   BITMAP_WIDTH        = 640;
  parameter   BITMAP_HEIGHT       = 480;
  localparam  PIC_INPUT_PATH      = `PIC_INPUT_PATH_640X480   ;
  localparam  PIC_OUTPUT_PATH     = `PIC_OUTPUT_PATH_640X480  ;
  //parameter DATA_WIDTH    = 8;

  initial begin
    vs_reset                      = 23'd0;

    Hor_Addr_Time                 = 16'd640;
    Hor_Sync_Time                 = 16'd96;
    Hor_Back_Porch                = 16'd40;
    Hor_Left_Border               = 16'd8;
    Hor_Right_Border              = 16'd8;
    Hor_Front_Porch               = 16'd8;
    Ver_Addr_Time                 = 16'd480;
    Ver_Sync_Time                 = 16'd2;
    Ver_Back_Porch                = 16'd25;
    Ver_Bottom_Border             = 16'd8;
    Ver_Top_Border                = 16'd8;
    Ver_Front_Porch               = 16'd2;

    #1800000 $finish;

  end
`endif

initial begin
      $fsdbDumpfile("./sim_timing_gen.fsdb");
      $fsdbDumpvars(0, sim_timing_gen, "+all");
      $fsdbDumpMDA;
end


always #(REF_CLK_PERIOD/2) src_clk<=~src_clk;

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//        Image source (read BMP file)         \**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
image_source #(
  .PIC_PATH                       ( PIC_INPUT_PATH      ),
  .BPP                            ( 24                  ),  // Bits per pixel
  .BITMAP_WIDTH                   ( BITMAP_WIDTH        ),  // Bitmap width
  .BITMAP_HEIGHT                  ( BITMAP_HEIGHT       )   // Bitmap height
) image_source(
  .clk                            ( src_clk             ),
  .rst_n                          ( rst_n               ),
  .Synci                          ( {Vsync, Hsync, Den} ),
  .DPo                            ( is_DPo              )
);

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//    Timing generator   /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
timing_gen i_timing_gen (
  .clk                            ( src_clk              ),
  .rst_n                          ( rst_n                ),
  .vs_reset                       ( vs_reset             ),
  .Hor_Addr_Time                  ( Hor_Addr_Time        ),
  .Hor_Sync_Time                  ( Hor_Sync_Time        ),
  .Hor_Back_Porch                 ( Hor_Back_Porch       ),
  .Hor_Left_Border                ( Hor_Left_Border      ),
  .Hor_Right_Border               ( Hor_Right_Border     ),
  .Hor_Front_Porch                ( Hor_Front_Porch      ),
  .Ver_Addr_Time                  ( Ver_Addr_Time        ),
  .Ver_Sync_Time                  ( Ver_Sync_Time        ),
  .Ver_Back_Porch                 ( Ver_Back_Porch       ),
  .Ver_Bottom_Border              ( Ver_Bottom_Border    ),
  .Ver_Top_Border                 ( Ver_Top_Border       ),
  .Ver_Front_Porch                ( Ver_Front_Porch      ),
  .hcount                         ( hcount               ),
  .vcount                         ( vcount               ),
  .Synco                          ( {Vsync, Hsync, Den}  )
);

tmg_pass i_pass (
  .clk                            ( src_clk         ),
  .rst_n                          ( rst_n           ),
  .DPi                            ( is_DPo          ),
  .DPo                            ( pass_DPo        )
);
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//       Image capture (saved to BMP file)     \**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
image_capture #(
  .PIC_PATH                       ( PIC_OUTPUT_PATH )
  )image_capture(
  .clk                            ( src_clk         ),
  .rst_n                          ( rst_n           ),
  .DPi                            ( pass_DPo        ),
  .Hsize                          ( Hor_Addr_Time   ),
  .Vsize                          ( Ver_Addr_Time   )
);

endmodule
