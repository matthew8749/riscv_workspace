// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ alu_cop.v                                                                                 //
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

module alu_cop
#(
  parameter   ADR_BIT             =  3,
  parameter   DAT_BIT             = 24
)(
  input  wire                     rst_n,
  input  wire                     clk,

  input  wire                     alu_cop_wr_en,
  input  wire                     alu_cop_rd_en,
  input  wire [DAT_BIT-1 : 0]     alu_cop_data_in,
  input  wire [DAT_BIT-1 : 0]     alu_cop_result,

  //dbg
  output wire                     prf_full,
  output wire                     prf_empty,
  output wire                     prf_pre_full,
  output wire                     prf_pre_empty

);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  wire [7:0] val_a;
  wire [7:0] val_b;
  wire [7:0] val_c;

  reg alu_wr_rdy;

  wire alu_wr_ack;
  //wire alu_rd_ack;
  //wire alu_rd_rdy;
  wire                     pof_wr_ack;
  wire                     pof_empty;
  wire                     pof_full;
  reg                      pof_rd_en;
  reg                      pof_wr_en;
  reg  [ 16       : 0]     pof_data_in;
  wire                     alu_rd_rdy;
  wire [ 16       : 0]     alu_result;

  wire [DAT_BIT-1 : 0]     prf_data_out;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
assign prf_rd_en  = ( prf_empty==1'b0 && (alu_wr_rdy == 1'b0  || (alu_wr_rdy == 1'b1 && alu_wr_ack ==1'b1) ) );
assign pof_wr_ack = alu_rd_rdy && !pof_full;

assign  val_a = prf_data_out [   DAT_BIT-1       : (DAT_BIT/3)*2 ];
assign  val_b = prf_data_out [ ((DAT_BIT/3)*2)-1 : (DAT_BIT/3)*1 ];
assign  val_c = prf_data_out [ ((DAT_BIT/3)*1)-1 :             0 ];


// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****

sync_fifo #(
  .ADR_BIT    ( ADR_BIT           ),
  .DAT_BIT    ( DAT_BIT           )
) pre_fifo    (
  .rst_n      ( rst_n             ),
  .clk        ( clk               ),
  .wr_en      ( alu_cop_wr_en     ),
  .rd_en      ( prf_rd_en         ),
  .data_in    ( alu_cop_data_in   ),
  .data_out   ( prf_data_out      ),// o
  .empty      ( prf_empty         ),// o
  .full       ( prf_full          ),// o
  .pre_full   ( prf_pre_full      ),// o  (just output  mabye dont needed)
  .pre_empty  ( prf_pre_empty     ) // o  (just output  mabye dont needed)
);

alu u0_alu (
  .rst_n      ( rst_n             ),
  .clk        ( clk               ),
  .val_a      ( val_a             ),
  .val_b      ( val_b             ),
  .val_c      ( val_c             ),
  .alu_wr_rdy ( alu_wr_rdy        ),        // i
  .alu_wr_ack ( alu_wr_ack        ),        // o
  .alu_rd_ack ( pof_wr_ack        ),        // i
  .alu_rd_rdy ( alu_rd_rdy        ),        // o
  .alu_result ( alu_result        )         // o
);
sync_fifo #(
  .ADR_BIT    ( ADR_BIT           ),
  .DAT_BIT    ( DAT_BIT           )
) post_fifo   (
  .rst_n      ( rst_n             ),
  .clk        ( clk               ),
  .wr_en      ( pof_wr_en         ),
  .rd_en      ( pof_rd_en         ),
  .data_in    ( pof_data_in       ),
  .data_out   ( alu_cop_result    ),// o
  .empty      ( pof_empty         ),// o
  .full       ( pof_full          ),// o
  .pre_full   (                   ),// o  (just output  mabye dont needed)
  .pre_empty  (                   ) // o  (just output  mabye dont needed)
);


// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    alu_wr_rdy <= 1'b0;
  end else begin
    alu_wr_rdy <= prf_rd_en ;

  end
end

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    pof_wr_en   <= 1'b0;
    pof_rd_en   <= 1'b0;
    pof_data_in <= 'b0;
  end else begin
    pof_wr_en   <= alu_rd_rdy    && !pof_full;
    pof_rd_en   <= alu_cop_rd_en && !pof_empty;
    pof_data_in <= (alu_rd_rdy  &&  !pof_full) ? alu_result : pof_data_in;
  end
end


endmodule