/**********************************************************************/
//      COPYRIGHT (C)  National Chung-Cheng University
//
// MODULE:        To generate image pixel sequence to circuit under test
//
// FILE NAME:     image_source.v
// VERSION:       1.0
// DATE:          Oct. 12, 2009
// AUTHOR:        Chao-Yung Chang
// 
// CODE TYPE:     RTL model
//
// DESCRIPTION:   Use to verify image processing blocks
//
// Revisions:     2009/10/12  created by sunrise          
/**********************************************************************/

`timescale 1ns/1ps

module image_source #(
  parameter     PIC_PATH  = "./image_in/image_01_sp.txt",
  // Bits per pixel
  parameter     BPP                 = 24,
  // Bitmap width
  parameter     BITMAP_WIDTH        = 640,
  // Bitmap height
  parameter     BITMAP_HEIGHT       = 480
)
(
  input  wire                     clk,
  input  wire                     rst_n,
  input  wire [26: 24]            Synci,
  output reg  [26:  0]            DPo,
  output reg                      next_image_signal
);

// Image buffer
reg [BPP-1: 0]                    img_buf_001 [ 0:  BITMAP_WIDTH * BITMAP_HEIGHT -1];
reg [BPP-1: 0]                    img_buf_002 [ 0:  BITMAP_WIDTH * BITMAP_HEIGHT -1];
reg [BPP-1: 0]                    img_buf_003 [ 0:  BITMAP_WIDTH * BITMAP_HEIGHT -1];
reg [BPP-1: 0]                    img_buf_004 [ 0:  BITMAP_WIDTH * BITMAP_HEIGHT -1];
reg [BPP-1: 0]                    img_buf_005 [ 0:  BITMAP_WIDTH * BITMAP_HEIGHT -1];
reg [BPP-1: 0]                    img_buf_006 [ 0:  BITMAP_WIDTH * BITMAP_HEIGHT -1];
reg [BPP-1: 0]                    img_buf_007 [ 0:  BITMAP_WIDTH * BITMAP_HEIGHT -1];
reg [BPP-1: 0]                    img_buf_008 [ 0:  BITMAP_WIDTH * BITMAP_HEIGHT -1];
reg [BPP-1: 0]                    img_buf_009 [ 0:  BITMAP_WIDTH * BITMAP_HEIGHT -1];
// Image buffer index
reg    [31: 0]                    i;
reg    [ 7: 0]                    current_image;


initial begin
      $readmemh("./Image_Data/TT-20240501_image_in/o_20240501_122022_001.txt", img_buf_001);
      $readmemh("./Image_Data/TT-20240501_image_in/o_20240501_122022_002.txt", img_buf_002);
      $readmemh("./Image_Data/TT-20240501_image_in/o_20240501_122022_003.txt", img_buf_003);
      $readmemh("./Image_Data/TT-20240501_image_in/o_20240501_122022_004.txt", img_buf_004);
      $readmemh("./Image_Data/TT-20240501_image_in/o_20240501_122022_005.txt", img_buf_005);
      $readmemh("./Image_Data/TT-20240501_image_in/o_20240501_122022_006.txt", img_buf_006);
      $readmemh("./Image_Data/TT-20240501_image_in/o_20240501_122022_007.txt", img_buf_007);
      $readmemh("./Image_Data/TT-20240501_image_in/o_20240501_122022_008.txt", img_buf_008);
      $readmemh("./Image_Data/TT-20240501_image_in/o_20240501_122022_009.txt", img_buf_009);
      $fsdbDumpMDA;
end

// Image buffer index
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    i <= 32'b0;
  end else begin
      if (Synci[26]) i <= 32'b0;
      if (Synci[24]) i <= i + 1'b1;    // Synci[24]為1表示有效資料，因此當資料有效時才將index位置加1
   end
end

// DPo
always @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    DPo <= 27'b0;
  end else begin
    case (current_image)
      8'd0    :  DPo[23:0] <= (Synci[24]) ? img_buf_001[i] : 'b0;    // Synci[24]為1表示有效資料，因此當資料有效時才將RGB(24bits)的資料輸出
      8'd1    :  DPo[23:0] <= (Synci[24]) ? img_buf_002[i] : 'b0;    // Synci[24]為1表示有效資料，因此當資料有效時才將RGB(24bits)的資料輸出
      8'd2    :  DPo[23:0] <= (Synci[24]) ? img_buf_003[i] : 'b0;    // Synci[24]為1表示有效資料，因此當資料有效時才將RGB(24bits)的資料輸出
      8'd3    :  DPo[23:0] <= (Synci[24]) ? img_buf_004[i] : 'b0;    // Synci[24]為1表示有效資料，因此當資料有效時才將RGB(24bits)的資料輸出
      8'd4    :  DPo[23:0] <= (Synci[24]) ? img_buf_005[i] : 'b0;    // Synci[24]為1表示有效資料，因此當資料有效時才將RGB(24bits)的資料輸出
      8'd5    :  DPo[23:0] <= (Synci[24]) ? img_buf_006[i] : 'b0;    // Synci[24]為1表示有效資料，因此當資料有效時才將RGB(24bits)的資料輸出
      default :  DPo[23:0] <= (Synci[24]) ? img_buf_001[i] : 'b0;    // Synci[24]為1表示有效資料，因此當資料有效時才將RGB(24bits)的資料輸出
    endcase

    DPo[26:24] <= Synci[26:24];

  end
end


always @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
      current_image     <= 8'b0; // 当前图像编号
      next_image_signal <= 1'b0;
   end else begin
      if (Synci[26] && (i >= BITMAP_WIDTH * BITMAP_HEIGHT - 1) && current_image == 8'b0) begin
         // 切换到下一张图像
         next_image_signal <= 1'b1;
         current_image     <= current_image + 1'b1;
//      end else if (Synci[26] && (i >= BITMAP_WIDTH * BITMAP_HEIGHT - 1) && current_image == 8'd1) begin
//         // 切换到下一张图像
//         next_image_signal <= 1'b1;
//         current_image     <= current_image + 1'b1;
//      end else if (Synci[26] && (i >= BITMAP_WIDTH * BITMAP_HEIGHT - 1) && current_image == 8'd2) begin
//         // 切换到下一张图像
//         next_image_signal <= 1'b1;
//         current_image     <= current_image + 1'b1;
//      end else if (Synci[26] && (i >= BITMAP_WIDTH * BITMAP_HEIGHT - 1) && current_image == 8'd3) begin
//         // 切换到下一张图像
//         next_image_signal <= 1'b1;
//         current_image     <= current_image + 1'b1;
//      end else if (Synci[26] && (i >= BITMAP_WIDTH * BITMAP_HEIGHT - 1) && current_image == 8'd4) begin
//         next_image_signal <= 1'b1;
//         current_image     <= current_image + 1'b1;
      end else if (Synci[26] && (i >= BITMAP_WIDTH * BITMAP_HEIGHT - 1) && current_image <= 8'd5) begin
         next_image_signal <= 1'b1;
         current_image     <= current_image + 1'b1;
      end else begin
         current_image     <= current_image;
         next_image_signal <= next_image_signal;
      end
   end
end



endmodule    

  
