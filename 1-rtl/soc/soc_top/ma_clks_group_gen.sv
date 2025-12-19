// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ ma_clks_group_gen.sv                                                                      //
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

module ma_clks_group_gen #(
  parameter   DIV_DW = 4                                 //Divider width control
)(
  input  wire                     src_clk,
  input  wire                     src_rst_n,

  input  wire [ DIV_DW-1 : 0]     REG_CLK_DIV_CPU  ,
  input  wire                     REG_CLK_TOG_CPU  ,
  input  wire                     REG_CLK_CKEN_CPU ,
  input  wire [ DIV_DW-1 : 0]     REG_CLK_DIV_AXI  ,
  input  wire                     REG_CLK_TOG_AXI  ,
  input  wire                     REG_CLK_CKEN_AXI ,
  input  wire [ DIV_DW-1 : 0]     REG_CLK_DIV_APB  ,
  input  wire                     REG_CLK_TOG_APB  ,
  input  wire                     REG_CLK_CKEN_APB ,
  input  wire [ DIV_DW-1 : 0]     REG_CLK_DIV_I2C  ,
  input  wire                     REG_CLK_TOG_I2C  ,
  input  wire                     REG_CLK_CKEN_I2C ,
  input  wire [ DIV_DW-1 : 0]     REG_CLK_DIV_IMP  ,
  input  wire                     REG_CLK_TOG_IMP  ,
  input  wire                     REG_CLK_CKEN_IMP ,

  input  wire                     REG_ICG_ON_CPU ,
  input  wire                     REG_ICG_ON_AXI ,
  input  wire                     REG_ICG_ON_APB ,
  input  wire                     REG_ICG_ON_I2C ,
  input  wire                     REG_ICG_ON_IMP ,

  output wire                     G0_CPU_CLK,
  output wire                     AXI_CLK,
  output wire                     APB_CLK,
  output wire                     I2C_CLK,
  output wire                     IMP_CLK,

  output wire                     ICG_G0_CPU_CLK,
  output wire                     ICG_AXI_CLK,
  output wire                     ICG_APB_CLK,
  output wire                     ICG_I2C_CLK,
  output wire                     ICG_IMP_CLK
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------

// tag OUTs assignment ---------------------------------------------------------------------------------------------
// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****

ma_clk_div_n  #(
  .DW                             ( DIV_DW              )
)
u0_g0_cpu_ma_clk_div (
  .rst_n                          ( src_rst_n           ),
  .clk_in                         ( src_clk             ),
  .cr_div                         ( REG_CLK_DIV_CPU     ),
  .cr_tog                         ( REG_CLK_TOG_CPU     ),
  .cr_cken                        ( REG_CLK_CKEN_CPU    ),
  .test_mode                      ( 1'b0                ),
  .clk_out                        ( G0_CPU_CLK          )  );

ma_clk_div_n  #(
  .DW                             ( DIV_DW              )
)
u1_axi_ma_clk_div (
  .rst_n                          ( src_rst_n           ),
  .clk_in                         ( src_clk             ),
  .cr_div                         ( REG_CLK_DIV_AXI     ),
  .cr_tog                         ( REG_CLK_TOG_AXI     ),
  .cr_cken                        ( REG_CLK_CKEN_AXI    ),
  .test_mode                      ( 1'b0                ),
  .clk_out                        ( AXI_CLK             )  );

ma_clk_div_n  #(
  .DW                             ( DIV_DW              )
)
u2_apb_ma_clk_div (
  .rst_n                          ( src_rst_n           ),
  .clk_in                         ( src_clk             ),
  .cr_div                         ( REG_CLK_DIV_APB     ),
  .cr_tog                         ( REG_CLK_TOG_APB     ),
  .cr_cken                        ( REG_CLK_CKEN_APB    ),
  .test_mode                      ( 1'b0                ),
  .clk_out                        ( APB_CLK             )  );

ma_clk_div_n  #(
  .DW                             ( DIV_DW              )
)
u3_i2c_ma_clk_div (
  .rst_n                          ( src_rst_n           ),
  .clk_in                         ( src_clk             ),
  .cr_div                         ( REG_CLK_DIV_I2C     ),
  .cr_tog                         ( REG_CLK_TOG_I2C     ),
  .cr_cken                        ( REG_CLK_CKEN_I2C    ),
  .test_mode                      ( 1'b0                ),
  .clk_out                        ( I2C_CLK             )  );

ma_clk_div_n  #(
  .DW                             ( DIV_DW              )
)
u4_imp_ma_clk_div (
  .rst_n                          ( src_rst_n           ),
  .clk_in                         ( src_clk             ),
  .cr_div                         ( REG_CLK_DIV_IMP     ),
  .cr_tog                         ( REG_CLK_TOG_IMP     ),
  .cr_cken                        ( REG_CLK_CKEN_IMP    ),
  .test_mode                      ( 1'b0                ),
  .clk_out                        ( IMP_CLK             )  );


ICG_posedge u0_ICG_CPU (.ck_in(G0_CPU_CLK), .enable(REG_ICG_ON_CPU), .test(1'b0), .ck_out(ICG_G0_CPU_CLK));
ICG_posedge u1_ICG_AXI (.ck_in(AXI_CLK   ), .enable(REG_ICG_ON_AXI), .test(1'b0), .ck_out(ICG_AXI_CLK   ));
ICG_posedge u2_ICG_APB (.ck_in(APB_CLK   ), .enable(REG_ICG_ON_APB), .test(1'b0), .ck_out(ICG_APB_CLK   ));
ICG_posedge u3_ICG_I2C (.ck_in(I2C_CLK   ), .enable(REG_ICG_ON_I2C), .test(1'b0), .ck_out(ICG_I2C_CLK   ));
ICG_posedge u4_ICG_IMP (.ck_in(IMP_CLK   ), .enable(REG_ICG_ON_IMP), .test(1'b0), .ck_out(ICG_IMP_CLK   ));


endmodule