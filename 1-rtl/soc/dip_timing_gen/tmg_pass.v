/**********************************************************************/
//      COPYRIGHT (C)  National Chung-Cheng University
//
// MODULE:        pass Circuit
//
// FILE NAME:     pass.v
// VERSION:       1.0
// DATE:          May. 28, 2013
// AUTHOR:        Chao-Yung Chang
// 
// CODE TYPE:     RTL model
//
// DESCRIPTION:   input pass to output  
//         
/**********************************************************************/
`timescale 1ns/1ps

module tmg_pass(
input             clk,
input             rst_n,
input      [26:0] DPi,
output reg [26:0] DPo
);
  
  reg [23:0] test [3:0];
  
  
always@ ( posedge clk or negedge rst_n ) begin
  if ( ~rst_n )begin
    DPo <= 27'b0;
  end else begin
    DPo <= DPi;


  end
end

always @ ( posedge clk ) begin
      test[0] <= DPi[23: 0];
      test[1] <= test[0];
      test[2] <= test[1];
      test[3] <= test[2];
end
     
     
endmodule     
