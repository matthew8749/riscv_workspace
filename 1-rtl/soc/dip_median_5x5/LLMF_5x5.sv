// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project____________                                                                                            //
// File name __________ sort_5_value.sv                                                                           //
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

module LLMF_5x5(
  input  wire                     ref_clk,
  input  wire                     mem_clk,
  input  wire                     rst_n,
  input  wire                     sw_rst_n,

  input  wire [ 7: 0]             value_p00,
  input  wire [ 7: 0]             value_p01,
  input  wire [ 7: 0]             value_p02,
  input  wire [ 7: 0]             value_p03,
  input  wire [ 7: 0]             value_p04,
  input  wire [ 7: 0]             value_p10,
  input  wire [ 7: 0]             value_p11,
  input  wire [ 7: 0]             value_p12,
  input  wire [ 7: 0]             value_p13,
  input  wire [ 7: 0]             value_p14,
  input  wire [ 7: 0]             value_p20,
  input  wire [ 7: 0]             value_p21,
  input  wire [ 7: 0]             value_p22,
  input  wire [ 7: 0]             value_p23,
  input  wire [ 7: 0]             value_p24,
  input  wire [ 7: 0]             value_p30,
  input  wire [ 7: 0]             value_p31,
  input  wire [ 7: 0]             value_p32,
  input  wire [ 7: 0]             value_p33,
  input  wire [ 7: 0]             value_p34,
  input  wire [ 7: 0]             value_p40,
  input  wire [ 7: 0]             value_p41,
  input  wire [ 7: 0]             value_p42,
  input  wire [ 7: 0]             value_p43,
  input  wire [ 7: 0]             value_p44,

  output wire [ 7: 0]             value_Max,
  output wire [ 7: 0]             value_Med,
  output wire [ 7: 0]             value_Min
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  integer                         row_num;
  integer                         col_num;

  wire        [ 7: 0]             o_value_max;
  wire        [ 7: 0]             o_value_med;
  wire        [ 7: 0]             o_value_min;


  wire        [ 7: 0]             First_row  [ 4: 0];
  wire        [ 7: 0]             Second_row [ 4: 0];
  wire        [ 7: 0]             Third_row  [ 4: 0];
  wire        [ 7: 0]             Fourth_row [ 4: 0];
  wire        [ 7: 0]             Fifth_row  [ 4: 0];
  reg         [ 7: 0]             pip_First_row  [ 4: 0];
  reg         [ 7: 0]             pip_Second_row [ 4: 0];
  reg         [ 7: 0]             pip_Third_row  [ 4: 0];
  reg         [ 7: 0]             pip_Fourth_row [ 4: 0];
  reg         [ 7: 0]             pip_Fifth_row  [ 4: 0];

  wire        [ 7: 0]             First_col  [ 4: 0];
  wire        [ 7: 0]             Second_col [ 4: 0];
  wire        [ 7: 0]             Third_col  [ 4: 0];
  wire        [ 7: 0]             Fourth_col [ 4: 0];
  wire        [ 7: 0]             Fifth_col  [ 4: 0];
  reg         [ 7: 0]             pip_First_col  [ 4: 0];
  reg         [ 7: 0]             pip_Second_col [ 4: 0];
  reg         [ 7: 0]             pip_Third_col  [ 4: 0];
  reg         [ 7: 0]             pip_Fourth_col [ 4: 0];
  reg         [ 7: 0]             pip_Fifth_col  [ 4: 0];

  wire        [ 7: 0]             value_Max_dia_0;
  wire        [ 7: 0]             value_Med_dia_1;
  wire        [ 7: 0]             value_Min_dia_2;
  reg         [ 7: 0]             pip_value_Max_dia_0;
  reg         [ 7: 0]             pip_value_Med_dia_1;
  reg         [ 7: 0]             pip_value_Min_dia_2;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
  assign value_Max                = o_value_max;
  assign value_Med                = o_value_med;
  assign value_Min                = o_value_min;
// tag INs assignment ----------------------------------------------------------------------------------------------

// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------

// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------

// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
always_ff @ ( posedge ref_clk or negedge rst_n ) begin : row_reg
  if ( ~rst_n ) begin
    for ( row_num = 0; row_num < 5; row_num++ ) begin
      pip_First_row  [row_num] <= 8'b0;
      pip_Second_row [row_num] <= 8'b0;
      pip_Third_row  [row_num] <= 8'b0;
      pip_Fourth_row [row_num] <= 8'b0;
      pip_Fifth_row  [row_num] <= 8'b0;
    end
  end else begin
    for ( row_num = 0; row_num < 5; row_num++ ) begin
      pip_First_row  [row_num] <= First_row  [row_num];
      pip_Second_row [row_num] <= Second_row [row_num];
      pip_Third_row  [row_num] <= Third_row  [row_num];
      pip_Fourth_row [row_num] <= Fourth_row [row_num];
      pip_Fifth_row  [row_num] <= Fifth_row  [row_num];
    end
  end
end


always_ff @ ( posedge ref_clk or negedge rst_n ) begin : col_reg
  if ( ~rst_n ) begin
    for ( col_num = 0; col_num < 5; col_num++ ) begin
      pip_First_col  [col_num] <= 8'b0;
      pip_Second_col [col_num] <= 8'b0;
      pip_Third_col  [col_num] <= 8'b0;
      pip_Fourth_col [col_num] <= 8'b0;
      pip_Fifth_col  [col_num] <= 8'b0;
    end
  end else begin
    for ( col_num = 0; col_num < 5; col_num++ ) begin
      pip_First_col  [col_num] <= First_col  [col_num];
      pip_Second_col [col_num] <= Second_col [col_num];
      pip_Third_col  [col_num] <= Third_col  [col_num];
      pip_Fourth_col [col_num] <= Fourth_col [col_num];
      pip_Fifth_col  [col_num] <= Fifth_col  [col_num];
    end
  end
end

always_ff @ ( posedge ref_clk or negedge rst_n ) begin : dia
  if ( ~rst_n ) begin
    pip_value_Max_dia_0 <= 8'b0;
    pip_value_Med_dia_1 <= 8'b0;
    pip_value_Min_dia_2 <= 8'b0;
  end else begin
    pip_value_Max_dia_0 <= value_Max_dia_0;
    pip_value_Med_dia_1 <= value_Med_dia_1;
    pip_value_Min_dia_2 <= value_Min_dia_2;
  end
end

sort_5_value sort_row_0     (
  .clk                        ( ref_clk             ),
  .rst_n                      ( rst_n               ),
  .sw_rst_n                   ( sw_rst_n            ),

  .value_1                    ( value_p00           ),
  .value_2                    ( value_p01           ),
  .value_3                    ( value_p02           ),
  .value_4                    ( value_p03           ),
  .value_5                    ( value_p04           ),

  .value_Max                  ( First_row[0]        ),
  .value_Second               ( Second_row[0]       ),
  .value_Med                  ( Third_row[0]        ),
  .value_Fourth               ( Fourth_row[0]       ),
  .value_Min                  ( Fifth_row[0]        )
);

sort_5_value sort_row_1     (
  .clk                        ( ref_clk             ),
  .rst_n                      ( rst_n               ),
  .sw_rst_n                   ( sw_rst_n            ),

  .value_1                    ( value_p10           ),
  .value_2                    ( value_p11           ),
  .value_3                    ( value_p12           ),
  .value_4                    ( value_p13           ),
  .value_5                    ( value_p14           ),

  .value_Max                  ( First_row[1]        ),
  .value_Second               ( Second_row[1]       ),
  .value_Med                  ( Third_row[1]        ),
  .value_Fourth               ( Fourth_row[1]       ),
  .value_Min                  ( Fifth_row[1]        )
);

sort_5_value sort_row_2     (
  .clk                        ( ref_clk             ),
  .rst_n                      ( rst_n               ),
  .sw_rst_n                   ( sw_rst_n            ),

  .value_1                    ( value_p20           ),
  .value_2                    ( value_p21           ),
  .value_3                    ( value_p22           ),
  .value_4                    ( value_p23           ),
  .value_5                    ( value_p24           ),

  .value_Max                  ( First_row[2]        ),
  .value_Second               ( Second_row[2]       ),
  .value_Med                  ( Third_row[2]        ),
  .value_Fourth               ( Fourth_row[2]       ),
  .value_Min                  ( Fifth_row[2]        )
);

sort_5_value sort_row_3     (
  .clk                        ( ref_clk             ),
  .rst_n                      ( rst_n               ),
  .sw_rst_n                   ( sw_rst_n            ),

  .value_1                    ( value_p30           ),
  .value_2                    ( value_p31           ),
  .value_3                    ( value_p32           ),
  .value_4                    ( value_p33           ),
  .value_5                    ( value_p34           ),

  .value_Max                  ( First_row[3]        ),
  .value_Second               ( Second_row[3]       ),
  .value_Med                  ( Third_row[3]        ),
  .value_Fourth               ( Fourth_row[3]       ),
  .value_Min                  ( Fifth_row[3]        )
);

sort_5_value sort_row_4     (
  .clk                        ( ref_clk             ),
  .rst_n                      ( rst_n               ),
  .sw_rst_n                   ( sw_rst_n            ),

  .value_1                    ( value_p40           ),
  .value_2                    ( value_p41           ),
  .value_3                    ( value_p42           ),
  .value_4                    ( value_p43           ),
  .value_5                    ( value_p44           ),

  .value_Max                  ( First_row[4]        ),
  .value_Second               ( Second_row[4]       ),
  .value_Med                  ( Third_row[4]        ),
  .value_Fourth               ( Fourth_row[4]       ),
  .value_Min                  ( Fifth_row[4]        )
);


//Max
sort_5_value sort_col_0     (
  .clk                        ( ref_clk             ),
  .rst_n                      ( rst_n               ),
  .sw_rst_n                   ( sw_rst_n            ),

  .value_1                    ( pip_First_row[0]    ),
  .value_2                    ( pip_First_row[1]    ),
  .value_3                    ( pip_First_row[2]    ),
  .value_4                    ( pip_First_row[3]    ),
  .value_5                    ( pip_First_row[4]    ),

  .value_Max                  ( First_col[0]        ),
  .value_Second               ( Second_col[0]       ),
  .value_Med                  ( Third_col[0]        ),
  .value_Fourth               ( Fourth_col[0]       ),
  .value_Min                  ( Fifth_col[0]        )
);

sort_5_value sort_col_1     (
  .clk                        ( ref_clk             ),
  .rst_n                      ( rst_n               ),
  .sw_rst_n                   ( sw_rst_n            ),

  .value_1                    ( pip_Second_row[0]   ),
  .value_2                    ( pip_Second_row[1]   ),
  .value_3                    ( pip_Second_row[2]   ),
  .value_4                    ( pip_Second_row[3]   ),
  .value_5                    ( pip_Second_row[4]   ),

  .value_Max                  ( First_col[1]        ),
  .value_Second               ( Second_col[1]       ),
  .value_Med                  ( Third_col[1]        ),
  .value_Fourth               ( Fourth_col[1]       ),
  .value_Min                  ( Fifth_col[1]        )
);
sort_5_value sort_col_2     (
  .clk                        ( ref_clk             ),
  .rst_n                      ( rst_n               ),
  .sw_rst_n                   ( sw_rst_n            ),

  .value_1                    ( pip_Third_row[0]    ),
  .value_2                    ( pip_Third_row[1]    ),
  .value_3                    ( pip_Third_row[2]    ),
  .value_4                    ( pip_Third_row[3]    ),
  .value_5                    ( pip_Third_row[4]    ),

  .value_Max                  ( First_col[2]        ),
  .value_Second               ( Second_col[2]       ),
  .value_Med                  ( Third_col[2]        ),
  .value_Fourth               ( Fourth_col[2]       ),
  .value_Min                  ( Fifth_col[2]        )
);
sort_5_value sort_col_3     (
  .clk                        ( ref_clk             ),
  .rst_n                      ( rst_n               ),
  .sw_rst_n                   ( sw_rst_n            ),

  .value_1                    ( pip_Fourth_row[0]   ),
  .value_2                    ( pip_Fourth_row[1]   ),
  .value_3                    ( pip_Fourth_row[2]   ),
  .value_4                    ( pip_Fourth_row[3]   ),
  .value_5                    ( pip_Fourth_row[4]   ),

  .value_Max                  ( First_col[3]        ),
  .value_Second               ( Second_col[3]       ),
  .value_Med                  ( Third_col[3]        ),
  .value_Fourth               ( Fourth_col[3]       ),
  .value_Min                  ( Fifth_col[3]        )
);
sort_5_value sort_col_4     (
  .clk                        ( ref_clk             ),
  .rst_n                      ( rst_n               ),
  .sw_rst_n                   ( sw_rst_n            ),

  .value_1                    ( pip_Fifth_row[0]    ),
  .value_2                    ( pip_Fifth_row[1]    ),
  .value_3                    ( pip_Fifth_row[2]    ),
  .value_4                    ( pip_Fifth_row[3]    ),
  .value_5                    ( pip_Fifth_row[4]    ),

  .value_Max                  ( First_col[4]        ),
  .value_Second               ( Second_col[4]       ),
  .value_Med                  ( Third_col[4]        ),
  .value_Fourth               ( Fourth_col[4]       ),
  .value_Min                  ( Fifth_col[4]        )
);


sort_4_value sorter_dia_0   (
  .clk                        ( ref_clk             ),
  .rst_n                      ( rst_n               ),
  .sw_rst_n                   ( sw_rst_n            ),

  .value_1                    ( pip_Fifth_col[1]    ),
  .value_2                    ( pip_Fourth_col[2]   ),
  .value_3                    ( pip_Third_col[3]    ),
  .value_4                    ( pip_Second_col[4]   ),

  .value_Max                  ( value_Max_dia_0     ),
  .value_Second               ( /*UNCONNECT*/       ),
  .value_Third                ( /*UNCONNECT*/       ),
  .value_Fourth               ( /*UNCONNECT*/       )
);

sort_5_value sorter_dia_1   (
  .clk                        ( ref_clk             ),
  .rst_n                      ( rst_n               ),
  .sw_rst_n                   ( sw_rst_n            ),

  .value_1                    ( pip_Fifth_col[0]    ),
  .value_2                    ( pip_Fourth_col[1]   ),
  .value_3                    ( pip_Third_col[2]    ),
  .value_4                    ( pip_Second_col[3]   ),
  .value_5                    ( pip_First_col[4]    ),

  .value_Max                  ( /*UNCONNECT*/       ),
  .value_Second               ( /*UNCONNECT*/       ),
  .value_Med                  ( value_Med_dia_1     ),
  .value_Fourth               ( /*UNCONNECT*/       ),
  .value_Min                  ( /*UNCONNECT*/       )
);

sort_4_value sorter_dia_2   (
  .clk                        ( ref_clk             ),
  .rst_n                      ( rst_n               ),
  .sw_rst_n                   ( sw_rst_n            ),

  .value_1                    ( pip_Fourth_col[0]   ),
  .value_2                    ( pip_Third_col[2]    ),
  .value_3                    ( pip_Second_col[2]   ),
  .value_4                    ( pip_First_col[3]    ),

  .value_Max                  ( /*UNCONNECT*/       ),
  .value_Second               ( /*UNCONNECT*/       ),
  .value_Third                ( /*UNCONNECT*/       ),
  .value_Fourth               ( value_Min_dia_2     )
);

sort_3_value i_sort_3_value (
  .clk                        ( ref_clk             ),
  .rst_n                      ( rst_n               ),
  .sw_rst_n                   ( sw_rst_n            ),

  .value_1                    ( pip_value_Max_dia_0 ),
  .value_2                    ( pip_value_Med_dia_1 ),
  .value_3                    ( pip_value_Min_dia_2 ),

  .value_max                  ( o_value_max         ),
  .value_med                  ( o_value_med         ),
  .value_min                  ( o_value_min         )
);



endmodule