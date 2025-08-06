// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ sync_fifo.sv                                                                              //
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

module sync_fifo
#(
  parameter                       ADR_BIT =  6,
  parameter                       DAT_BIT = 32,
  parameter                       WEN_BIT =  1
)(
  input  logic                    clk,
  input  logic                    rst_n,

  input  logic [WEN_BIT-1: 0]     cs_en,          // higi activ
  input  logic [WEN_BIT-1: 0]     wr_en,          // higi activ
  input  logic [DAT_BIT-1: 0]     wr_dat,


  output logic [DAT_BIT-1: 0]     rd_dat,
  output logic                    fifo_full,
  output logic                    fifo_empty,
  output logic [ADR_BIT : 0]      fifo_count      // for testbench display
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------

  //
  logic    [ADR_BIT     : 0]      wr_ptr;
  logic    [ADR_BIT     : 0]      rd_ptr;

  // RAM 控制信號
  logic    [WEN_BIT-1   : 0]      ram_cen;
  logic    [WEN_BIT-1   : 0]      ram_wen;
  logic    [ADR_BIT-1   : 0]      ram_addr;
  logic    [DAT_BIT-1   : 0]      ram_wdata;
  logic    [DAT_BIT-1   : 0]      ram_rdata;

  // base on cs_en & wr_en
  logic                           rd_req;
  logic                           wr_req;
  logic                           wr_actual;
  logic                           rd_actual;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
assign rd_dat      = ram_rdata;

// tag INs assignment ----------------------------------------------------------------------------------------------


// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------

//當 cs_en 為高且 wr_en 為高時，表示一個寫入請求。
//當 cs_en 為高且 wr_en 為低時，表示一個讀取請求。
//當 cs_en 為低時，表示沒有任何操作請求。
assign        rd_req              = (cs_en == 1'b1 && wr_en == 1'b0 );
assign        wr_req              = (cs_en == 1'b1 && wr_en == 1'b1 );

assign        wr_actual           = wr_req && !fifo_full;
assign        rd_actual           = !wr_actual && rd_req && !fifo_empty;

assign fifo_full   = ( wr_ptr[ADR_BIT] != rd_ptr[ADR_BIT]) && ( wr_ptr[ADR_BIT-1 : 0] == rd_ptr[ADR_BIT-1 : 0] );
assign fifo_empty  = ( wr_ptr == rd_ptr);
assign fifo_count  = wr_ptr - rd_ptr;                 // for testbench display

// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
always_comb begin
  ram_cen                         = {WEN_BIT{1'b1}};
  ram_wen                         = {WEN_BIT{1'b1}};
  ram_addr                        = 'd0;
  ram_wdata                       = 'd0;

  if ( wr_actual ) begin
  ram_cen                         = {WEN_BIT{1'b0}};
  ram_wen                         = {WEN_BIT{1'b0}};
  ram_addr                        = wr_ptr[ADR_BIT-1:0];
  ram_wdata                       = wr_dat;
  end else if ( rd_actual ) begin
  ram_cen                         = {WEN_BIT{1'b0}};
  ram_wen                         = {WEN_BIT{1'b1}};
  ram_addr                        = rd_ptr[ADR_BIT-1:0];
  end

end

// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
 sp_ram_top #(
  .ADR_BIT ( ADR_BIT       ),
  .DAT_BIT ( DAT_BIT       ),
  .WEN_BIT ( WEN_BIT       )
) u0_sp_ram (
  .clk     ( clk       ),
  .rst_n   ( rst_n     ),
  .CEN     ( ram_cen   ),  //low activ
  .WEN     ( ram_wen   ),  //low activ
  .addr    ( ram_addr  ),
  .w_data  ( ram_wdata ),
  .r_data  ( ram_rdata )
);

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// 讀寫指針更新            /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
always_ff @ ( posedge clk or negedge rst_n) begin
  if ( !rst_n ) begin
    wr_ptr <= {ADR_BIT{1'b0}};
  end else begin
    if ( wr_actual ) begin
      wr_ptr <= wr_ptr + 1'b1;
    end else begin
      wr_ptr <= wr_ptr;
    end


  end
end

always_ff @ ( posedge clk or negedge rst_n) begin
  if ( !rst_n ) begin
    rd_ptr <= {ADR_BIT{1'b0}};
  end else begin
    if ( rd_actual ) begin
      rd_ptr <= rd_ptr + 1'b1;
    end else begin
      rd_ptr <= rd_ptr;
    end


  end
end
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****


endmodule