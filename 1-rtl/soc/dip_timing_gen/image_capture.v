/**********************************************************************/
//      COPYRIGHT (C)  National Chung-Cheng University
//
// MODULE:        To Capture image pixel sequence generated from DUT
//
// FILE NAME:     image_capture.v
// CODE TYPE:     RTL model
//
// DESCRIPTION:   Use to verify image processing blocks
//                Capture output of Circuit Under Test into .tbl file
//                then convert to *.bmp file for comparing
//      
/**********************************************************************/

`timescale 1ns/1ps

module image_capture# (
  parameter   PIC_PATH = "./image_out/image_01_sp_out.bmp"
  )(
  input wire                      clk,
  input wire                      rst_n,
  input wire  [26: 0]             DPi,
  input wire  [ 2: 0]             OUT_select,
  input wire  [15: 0]             Hsize,
  input wire  [15: 0]             Vsize
  );

// Output filename
parameter file_name = PIC_PATH;

// Output channels control
// (R, G, B) or (Y, Cb, Cr) or (Y, U, V) or (Y, I, Q) channels
parameter r_channel = 1;
parameter g_channel = 1;
parameter b_channel = 1;

// File handle
integer fp_001;
integer fp_002;
integer fp_003;
integer fp_004;
integer fp_005;
integer fp_006;

// Pixel position
integer x, y, count;

// Image size
wire [31:0] img_size = Hsize*Vsize*3;

// Header size (file header + DIB header)
// Windows and OS/2 Bitmap headers: 14 bytes (file header)
// Windows BITMAPINFOHEADER: 40 bytes (DIB header)

parameter file_header_size = 14;
parameter DIB_header_size = 40;
parameter header_size = file_header_size+DIB_header_size;

initial #1 begin


 //fp = $fopen ("./Image_Data/test_boundary_image_out/image_01_orig_out.bmp", "wb");
 //$display ("File %s opened for writing", "./Image_Data/test_boundary_image_out/image_01_orig_out.bmp");



   fp_001 = $fopen (file_name, "wb");
   $display ("File %s opened for writing", file_name);

   // BMP Header
   $fwrite (fp_001, "%s", "BM");                 // MB header
   $fwrite (fp_001, "%u", img_size+header_size); // File size
   $fwrite (fp_001, "%u", "");                   // Reserved 1 and 2 (4 bytes in total)
   $fwrite (fp_001, "%u", header_size);          // Starting address of the bitmap image
   $fwrite (fp_001, "%u", DIB_header_size);      // DIB header size
   $fwrite (fp_001, "%u", Hsize);                // The bitmap width in pixels (4 bytes signed integer)
   $fwrite (fp_001, "%u", Vsize);                // The bitmap height in pixels (4 bytes signed integer)
   $fwrite (fp_001, "%c", 8'h01);                // The number of color planes must be 1 (2 bytes in total)
   $fwrite (fp_001, "%c", 8'h00);                // 16'h00_01 in little endian => 16'h01_00
   $fwrite (fp_001, "%c", 8'h18);                // The number of bits per pixel, which is the color depth of the image. (2 bytes in total)
   //$fwrite (fp_001, "%c", 8'h08);                // The number of bits per pixel, which is the color depth of the image. (2 bytes in total)
   $fwrite (fp_001, "%c", 8'h00);                // 16'h00_18 in little endian => 4'h18_00
   $fwrite (fp_001, "%u", "");                   // Compression method being used (4 bytes in total)
   $fwrite (fp_001, "%u", img_size);             // The image size. (size of the raw bitmap data)
   $fwrite (fp_001, "%u", 32'd3780);             // The horizontal resolution of the image. (pixel per meter, signed integer) => 96 dpi = 3780 ppm
   $fwrite (fp_001, "%u", 32'd3780);             // The vertical resolution of the image. (pixel per meter, signed integer) => 96 dpi = 3780 ppm
   $fwrite (fp_001, "%u", "");                   // The number of colors in the color palette, or 0 to default
   $fwrite (fp_001, "%u", "");                   // The number of important colors used, or 0 when every color is important; generally ignored

   count = 0;

   for (y=0;y<Vsize;y=y+1) begin
      @(posedge DPi[24]); // wait for data enable
      x = 0;
      for (x=0;x<Hsize;x=x+1) begin
         @(posedge clk); // wait for clk edge
         if (b_channel) $fwrite (fp_001, "%c", DPi[ 7: 0]);
         else $fwrite (fp_001, "%c", 8'b0);
         if (g_channel) $fwrite (fp_001, "%c", DPi[15: 8]);
         else $fwrite (fp_001, "%c", 8'b0);
         if (r_channel) $fwrite (fp_001, "%c", DPi[23:16]);
         else $fwrite (fp_001, "%c", 8'b0);
         count = count + 1;
      end
   end

   $fclose (fp_001);


 if ( OUT_select == 3'd0 ) begin
   fp_002 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_002_gray.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Gray image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_002_gray.bmp");

 end else if ( OUT_select == 3'd1 ) begin
   fp_002 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_002_diff.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Diff image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_002_diff.bmp");

 end else if ( OUT_select == 3'd2 ) begin
   fp_002 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_002_median.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Median image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_002_median.bmp");

 end else if ( OUT_select == 3'd3 ) begin
   fp_002 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_002_dila.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Dilation image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_002_dila.bmp");

 end else if ( OUT_select == 3'd4 ) begin
   fp_002 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_002_erosion.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Erosion image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_002_erosion.bmp");

 // end else if ( OUT_select == 3'd5 ) begin
 //   fp_002 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_002_label.bmp", "wb");
 //   $display(" ======> OUT_select : %d, out: Labeling image", OUT_select);
 //   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_002_label.bmp");

 // end else if ( OUT_select == 3'd6 ) begin
 //   fp_002 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_002_dila.bmp", "wb");
 //   $display(" ======> OUT_select : %d, out: Gray image", OUT_select);
 //   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_002_dila.bmp");

 // end else if ( OUT_select == 3'd7 ) begin
 //   fp_002 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_002_dila.bmp", "wb");
 //   $display(" ======> OUT_select : %d, out: Gray image", OUT_select);
 //   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_002_dila.bmp");

 end else begin
   fp_002 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_002_gray.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Defualt(GRAY) image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_002_gray.bmp");
 end


   // BMP Header
   $fwrite (fp_002, "%s", "BM");                 // MB header
   $fwrite (fp_002, "%u", img_size+header_size); // File size
   $fwrite (fp_002, "%u", "");                   // Reserved 1 and 2 (4 bytes in total)
   $fwrite (fp_002, "%u", header_size);          // Starting address of the bitmap image
   $fwrite (fp_002, "%u", DIB_header_size);      // DIB header size
   $fwrite (fp_002, "%u", Hsize);                // The bitmap width in pixels (4 bytes signed integer)
   $fwrite (fp_002, "%u", Vsize);                // The bitmap height in pixels (4 bytes signed integer)
   $fwrite (fp_002, "%c", 8'h01);                // The number of color planes must be 1 (2 bytes in total)
   $fwrite (fp_002, "%c", 8'h00);                // 16'h00_01 in little endian => 16'h01_00
   $fwrite (fp_002, "%c", 8'h18);                // The number of bits per pixel, which is the color depth of the image. (2 bytes in total)
   $fwrite (fp_002, "%c", 8'h00);                // 16'h00_18 in little endian => 4'h18_00
   $fwrite (fp_002, "%u", "");                   // Compression method being used (4 bytes in total)
   $fwrite (fp_002, "%u", img_size);             // The image size. (size of the raw bitmap data)
   $fwrite (fp_002, "%u", 32'd3780);             // The horizontal resolution of the image. (pixel per meter, signed integer) => 96 dpi = 3780 ppm
   $fwrite (fp_002, "%u", 32'd3780);             // The vertical resolution of the image. (pixel per meter, signed integer) => 96 dpi = 3780 ppm
   $fwrite (fp_002, "%u", "");                   // The number of colors in the color palette, or 0 to default
   $fwrite (fp_002, "%u", "");                   // The number of important colors used, or 0 when every color is important; generally ignored

   count = 0;

   for (y=0;y<Vsize;y=y+1) begin
      @(posedge DPi[24]); // wait for data enable
      x = 0;
      for (x=0;x<Hsize;x=x+1) begin
         @(posedge clk); // wait for clk edge
         if (b_channel) $fwrite (fp_002, "%c", DPi[7:0]);
         else $fwrite (fp_002, "%c", 8'b0);
         if (g_channel) $fwrite (fp_002, "%c", DPi[15:8]);
         else $fwrite (fp_002, "%c", 8'b0);
         if (r_channel) $fwrite (fp_002, "%c", DPi[23:16]);
         else $fwrite (fp_002, "%c", 8'b0);
         count = count + 1;
      end
   end

   $fclose (fp_002);


  if ( OUT_select == 3'd0 ) begin
   fp_003 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_003_gray.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Gray image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_003_gray.bmp");

 end else if ( OUT_select == 3'd1 ) begin
   fp_003 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_003_diff.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Diff image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_003_diff.bmp");

 end else if ( OUT_select == 3'd2 ) begin
   fp_003 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_003_median.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Median image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_003_median.bmp");

 end else if ( OUT_select == 3'd3 ) begin
   fp_003 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_003_dila.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Dilation image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_003_dila.bmp");

 end else if ( OUT_select == 3'd4 ) begin
   fp_003 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_003_erosion.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Erosion image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_003_erosion.bmp");

 // end else if ( OUT_select == 3'd5 ) begin
 //   fp_003 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_003_label.bmp", "wb");
 //   $display(" ======> OUT_select : %d, out: Labeling image", OUT_select);
 //   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_003_label.bmp");

 // end else if ( OUT_select == 3'd6 ) begin
 //   fp_003 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_003_dila.bmp", "wb");
 //   $display(" ======> OUT_select : %d, out: Gray image", OUT_select);
 //   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_003_dila.bmp");

 // end else if ( OUT_select == 3'd7 ) begin
 //   fp_003 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_003_dila.bmp", "wb");
 //   $display(" ======> OUT_select : %d, out: Gray image", OUT_select);
 //   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_003_dila.bmp");

 end else begin
   fp_003 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_003_gray.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Defualt(GRAY) image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_003_gray.bmp");
 end


   // BMP Header
   $fwrite (fp_003, "%s", "BM");                 // MB header
   $fwrite (fp_003, "%u", img_size+header_size); // File size
   $fwrite (fp_003, "%u", "");                   // Reserved 1 and 2 (4 bytes in total)
   $fwrite (fp_003, "%u", header_size);          // Starting address of the bitmap image
   $fwrite (fp_003, "%u", DIB_header_size);      // DIB header size
   $fwrite (fp_003, "%u", Hsize);                // The bitmap width in pixels (4 bytes signed integer)
   $fwrite (fp_003, "%u", Vsize);                // The bitmap height in pixels (4 bytes signed integer)
   $fwrite (fp_003, "%c", 8'h01);                // The number of color planes must be 1 (2 bytes in total)
   $fwrite (fp_003, "%c", 8'h00);                // 16'h00_01 in little endian => 16'h01_00
   $fwrite (fp_003, "%c", 8'h18);                // The number of bits per pixel, which is the color depth of the image. (2 bytes in total)
   $fwrite (fp_003, "%c", 8'h00);                // 16'h00_18 in little endian => 4'h18_00
   $fwrite (fp_003, "%u", "");                   // Compression method being used (4 bytes in total)
   $fwrite (fp_003, "%u", img_size);             // The image size. (size of the raw bitmap data)
   $fwrite (fp_003, "%u", 32'd3780);             // The horizontal resolution of the image. (pixel per meter, signed integer) => 96 dpi = 3780 ppm
   $fwrite (fp_003, "%u", 32'd3780);             // The vertical resolution of the image. (pixel per meter, signed integer) => 96 dpi = 3780 ppm
   $fwrite (fp_003, "%u", "");                   // The number of colors in the color palette, or 0 to default
   $fwrite (fp_003, "%u", "");                   // The number of important colors used, or 0 when every color is important; generally ignored

   count = 0;

   for (y=0;y<Vsize;y=y+1) begin
      @(posedge DPi[24]); // wait for data enable
      x = 0;
      for (x=0;x<Hsize;x=x+1) begin
         @(posedge clk); // wait for clk edge
         if (b_channel) $fwrite (fp_003, "%c", DPi[7:0]);
         else $fwrite (fp_003, "%c", 8'b0);
         if (g_channel) $fwrite (fp_003, "%c", DPi[15:8]);
         else $fwrite (fp_003, "%c", 8'b0);
         if (r_channel) $fwrite (fp_003, "%c", DPi[23:16]);
         else $fwrite (fp_003, "%c", 8'b0);
         count = count + 1;
      end
   end

   $fclose (fp_003);

   if (OUT_select == 3'd0) begin
   fp_004 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_004_gray.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Gray image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_004_gray.bmp");
end else if (OUT_select == 3'd1) begin
   fp_004 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_004_diff.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Diff image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_004_diff.bmp");
end else if (OUT_select == 3'd2) begin
   fp_004 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_004_median.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Median image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_004_median.bmp");
end else if (OUT_select == 3'd3) begin
   fp_004 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_004_dila.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Dilation image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_004_dila.bmp");
end else if (OUT_select == 3'd4) begin
   fp_004 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_004_erosion.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Erosion image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_004_erosion.bmp");
end else begin
   fp_004 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_004_gray.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Default(GRAY) image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_004_gray.bmp");
end
// BMP Header
   $fwrite (fp_004, "%s", "BM");                 // MB header
   $fwrite (fp_004, "%u", img_size+header_size); // File size
   $fwrite (fp_004, "%u", "");                   // Reserved 1 and 2 (4 bytes in total)
   $fwrite (fp_004, "%u", header_size);          // Starting address of the bitmap image
   $fwrite (fp_004, "%u", DIB_header_size);      // DIB header size
   $fwrite (fp_004, "%u", Hsize);                // The bitmap width in pixels (4 bytes signed integer)
   $fwrite (fp_004, "%u", Vsize);                // The bitmap height in pixels (4 bytes signed integer)
   $fwrite (fp_004, "%c", 8'h01);                // The number of color planes must be 1 (2 bytes in total)
   $fwrite (fp_004, "%c", 8'h00);                // 16'h00_01 in little endian => 16'h01_00
   $fwrite (fp_004, "%c", 8'h18);                // The number of bits per pixel, which is the color depth of the image. (2 bytes in total)
   $fwrite (fp_004, "%c", 8'h00);                // 16'h00_18 in little endian => 4'h18_00
   $fwrite (fp_004, "%u", "");                   // Compression method being used (4 bytes in total)
   $fwrite (fp_004, "%u", img_size);             // The image size. (size of the raw bitmap data)
   $fwrite (fp_004, "%u", 32'd3780);             // The horizontal resolution of the image. (pixel per meter, signed integer) => 96 dpi = 3780 ppm
   $fwrite (fp_004, "%u", 32'd3780);             // The vertical resolution of the image. (pixel per meter, signed integer) => 96 dpi = 3780 ppm
   $fwrite (fp_004, "%u", "");                   // The number of colors in the color palette, or 0 to default
   $fwrite (fp_004, "%u", "");                   // The number of important colors used, or 0 when every color is important; generally ignored
   count = 0;
   for (y=0;y<Vsize;y=y+1) begin
      @(posedge DPi[24]); // wait for data enable
      x = 0;
      for (x=0;x<Hsize;x=x+1) begin
         @(posedge clk); // wait for clk edge
         if (b_channel) $fwrite (fp_004, "%c", DPi[7:0]);
         else $fwrite (fp_004, "%c", 8'b0);
         if (g_channel) $fwrite (fp_004, "%c", DPi[15:8]);
         else $fwrite (fp_004, "%c", 8'b0);
         if (r_channel) $fwrite (fp_004, "%c", DPi[23:16]);
         else $fwrite (fp_004, "%c", 8'b0);
         count = count + 1;
      end
   end
   $fclose (fp_004);

if (OUT_select == 3'd0) begin
   fp_005 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_005_gray.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Gray image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_005_gray.bmp");
end else if (OUT_select == 3'd1) begin
   fp_005 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_005_diff.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Diff image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_005_diff.bmp");
end else if (OUT_select == 3'd2) begin
   fp_005 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_005_median.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Median image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_005_median.bmp");
end else if (OUT_select == 3'd3) begin
   fp_005 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_005_dila.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Dilation image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_005_dila.bmp");
end else if (OUT_select == 3'd4) begin
   fp_005 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_005_erosion.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Erosion image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_005_erosion.bmp");
end else begin
   fp_005 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_005_gray.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Default(GRAY) image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_005_gray.bmp");
end
// BMP Header
   $fwrite (fp_005, "%s", "BM");                 // MB header
   $fwrite (fp_005, "%u", img_size+header_size); // File size
   $fwrite (fp_005, "%u", "");                   // Reserved 1 and 2 (4 bytes in total)
   $fwrite (fp_005, "%u", header_size);          // Starting address of the bitmap image
   $fwrite (fp_005, "%u", DIB_header_size);      // DIB header size
   $fwrite (fp_005, "%u", Hsize);                // The bitmap width in pixels (4 bytes signed integer)
   $fwrite (fp_005, "%u", Vsize);                // The bitmap height in pixels (4 bytes signed integer)
   $fwrite (fp_005, "%c", 8'h01);                // The number of color planes must be 1 (2 bytes in total)
   $fwrite (fp_005, "%c", 8'h00);                // 16'h00_01 in little endian => 16'h01_00
   $fwrite (fp_005, "%c", 8'h18);                // The number of bits per pixel, which is the color depth of the image. (2 bytes in total)
   $fwrite (fp_005, "%c", 8'h00);                // 16'h00_18 in little endian => 4'h18_00
   $fwrite (fp_005, "%u", "");                   // Compression method being used (4 bytes in total)
   $fwrite (fp_005, "%u", img_size);             // The image size. (size of the raw bitmap data)
   $fwrite (fp_005, "%u", 32'd3780);             // The horizontal resolution of the image. (pixel per meter, signed integer) => 96 dpi = 3780 ppm
   $fwrite (fp_005, "%u", 32'd3780);             // The vertical resolution of the image. (pixel per meter, signed integer) => 96 dpi = 3780 ppm
   $fwrite (fp_005, "%u", "");                   // The number of colors in the color palette, or 0 to default
   $fwrite (fp_005, "%u", "");                   // The number of important colors used, or 0 when every color is important; generally ignored
   count = 0;
   for (y=0;y<Vsize;y=y+1) begin
      @(posedge DPi[24]); // wait for data enable
      x = 0;
      for (x=0;x<Hsize;x=x+1) begin
         @(posedge clk); // wait for clk edge
         if (b_channel) $fwrite (fp_005, "%c", DPi[7:0]);
         else $fwrite (fp_005, "%c", 8'b0);
         if (g_channel) $fwrite (fp_005, "%c", DPi[15:8]);
         else $fwrite (fp_005, "%c", 8'b0);
         if (r_channel) $fwrite (fp_005, "%c", DPi[23:16]);
         else $fwrite (fp_005, "%c", 8'b0);
         count = count + 1;
      end
   end
   $fclose (fp_005);

   if (OUT_select == 3'd0) begin
   fp_006 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_006_gray.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Gray image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_006_gray.bmp");
end else if (OUT_select == 3'd1) begin
   fp_006 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_006_diff.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Diff image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_006_diff.bmp");
end else if (OUT_select == 3'd2) begin
   fp_006 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_006_median.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Median image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_006_median.bmp");
end else if (OUT_select == 3'd3) begin
   fp_006 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_006_dila.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Dilation image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_006_dila.bmp");
end else if (OUT_select == 3'd4) begin
   fp_006 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_006_erosion.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Erosion image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_006_erosion.bmp");
end else begin
   fp_006 = $fopen ("./Image_Data/TT-20240501_image_out/o_20240501_122022_006_gray.bmp", "wb");
   $display(" ======> OUT_select : %d, out: Default(GRAY) image", OUT_select);
   $display ("File %s opened for writing", "./Image_Data/TT-20240501_image_out/o_20240501_122022_006_gray.bmp");
end
// BMP Header
   $fwrite (fp_006, "%s", "BM");                 // MB header
   $fwrite (fp_006, "%u", img_size+header_size); // File size
   $fwrite (fp_006, "%u", "");                   // Reserved 1 and 2 (4 bytes in total)
   $fwrite (fp_006, "%u", header_size);          // Starting address of the bitmap image
   $fwrite (fp_006, "%u", DIB_header_size);      // DIB header size
   $fwrite (fp_006, "%u", Hsize);                // The bitmap width in pixels (4 bytes signed integer)
   $fwrite (fp_006, "%u", Vsize);                // The bitmap height in pixels (4 bytes signed integer)
   $fwrite (fp_006, "%c", 8'h01);                // The number of color planes must be 1 (2 bytes in total)
   $fwrite (fp_006, "%c", 8'h00);                // 16'h00_01 in little endian => 16'h01_00
   $fwrite (fp_006, "%c", 8'h18);                // The number of bits per pixel, which is the color depth of the image. (2 bytes in total)
   $fwrite (fp_006, "%c", 8'h00);                // 16'h00_18 in little endian => 4'h18_00
   $fwrite (fp_006, "%u", "");                   // Compression method being used (4 bytes in total)
   $fwrite (fp_006, "%u", img_size);             // The image size. (size of the raw bitmap data)
   $fwrite (fp_006, "%u", 32'd3780);             // The horizontal resolution of the image. (pixel per meter, signed integer) => 96 dpi = 3780 ppm
   $fwrite (fp_006, "%u", 32'd3780);             // The vertical resolution of the image. (pixel per meter, signed integer) => 96 dpi = 3780 ppm
   $fwrite (fp_006, "%u", "");                   // The number of colors in the color palette, or 0 to default
   $fwrite (fp_006, "%u", "");                   // The number of important colors used, or 0 when every color is important; generally ignored
   count = 0;
   for (y=0;y<Vsize;y=y+1) begin
      @(posedge DPi[24]); // wait for data enable
      x = 0;
      for (x=0;x<Hsize;x=x+1) begin
         @(posedge clk); // wait for clk edge
         if (b_channel) $fwrite (fp_006, "%c", DPi[7:0]);
         else $fwrite (fp_006, "%c", 8'b0);
         if (g_channel) $fwrite (fp_006, "%c", DPi[15:8]);
         else $fwrite (fp_006, "%c", 8'b0);
         if (r_channel) $fwrite (fp_006, "%c", DPi[23:16]);
         else $fwrite (fp_006, "%c", 8'b0);
         count = count + 1;
      end
   end
   $fclose (fp_006);

end

endmodule
