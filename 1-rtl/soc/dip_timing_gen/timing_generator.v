`timescale 1ns / 1ps
// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ timing_generator.v                                                                        //
// Creator ____________ Yan, Wei-Ting                                                                             //
// Built Date _________ 03-01-2022                                                                                //
// Function ___________                                                                                           //
// Hierarchy __________                                                                                           //
//   Parent ___________                                                                                           //
//   Children _________                                                                                           //
// Revision history ___ Date        Author            Description                                                 //
//                  ___                                                                                           //
// -FHDR--------------------------------------------------------------------------------------------------------- //
//+...........+...................+.............................................................................. //
//3...........15..................35............................................................................. //
module timing_generator(
  input                           clk,
  input                           rst_n,
  input       [15: 0]             h_total,
  input       [15: 0]             h_size,  //width
  input       [15: 0]             h_sync,

  input       [15: 0]             h_start, //h_start = h_sync + hbp
  //input       [15: 0]             h_start, //h_start = h_sync + hbp + hlb



  input       [15: 0]             v_total,
  input       [15: 0]             v_size,
  input       [15: 0]             v_sync,
  input       [15: 0]             v_start,
  input       [22: 0]             vs_reset,

  output      [15: 0]             hcount,
  output      [15: 0]             vcount,
  output      [26: 24]            Synco
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  reg         [2: 0]              op_start;
  wire                            h_end;
  wire                            v_end;
  wire                            VT_boundary;
  wire                            VB_boundary;
  wire                            HR_boundary;
  wire                            HL_boundary;

  reg   ht_sync;
  reg   vt_sync;
  reg   h_de;
  reg   v_de;
  wire  t_de;
  reg   [15:0]  h_cnt;
  reg   [15:0]  v_cnt;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
assign Synco[26:24] = {vt_sync, ht_sync, t_de };
assign hcount[15: 0] = h_cnt;
assign vcount[15: 0] = v_cnt;


// tag INs assignment ---------------------------------------------------------------------------------------------


// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
  assign h_end = (h_cnt >= (h_total - 1'b1));
  assign v_end = (v_cnt >= (v_total - 1'b1));

  assign HR_boundary = (h_cnt == (h_start - 1'b1));
  assign HL_boundary = (h_cnt == (h_start + h_size - 1'b1));

  assign VT_boundary = (v_cnt == (v_start -1));
  assign VB_boundary = (v_cnt == (v_start + v_size - 1'b1));

  assign t_de = v_de & h_de;

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// tag_De                /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****

  always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
      v_de <=  1'b0;
    end else begin
      if (VT_boundary && h_end) begin
        v_de <= 1'b1;
      end else if (VB_boundary && h_end) begin
        v_de <= 1'b0;
      end

    end
  end

  always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
      h_de <=  1'b0;
    end else begin
      if (HR_boundary) begin
        h_de <= 1'b1;
      end else if (HL_boundary) begin
        h_de <= 1'b0;
      end

    end
  end
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// tag_sync              /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****


  always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
      ht_sync <=  1'b0;
    end else begin
      if (op_start[2:1] == 2'b01 || h_end) begin
        ht_sync <= 1'b1;
      end else if (h_cnt == (h_sync - 1'b1)) begin
        ht_sync <= 1'b0;
      end

    end
  end


  always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
      vt_sync <=  1'b0;
    end else begin
      if (op_start[2:1] == 2'b01 || (v_end && h_end) ) begin
        vt_sync <= 1'b1;
      end else if (v_cnt == (v_sync - 1'b1)  && h_end) begin
        vt_sync <= 1'b0;
      end

    end
  end
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
  always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
      op_start <=  3'b0;
    end else begin
      op_start <= {op_start[1:0], 1'b1};

    end
  end


  always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
      h_cnt <=  16'h000;
    end else if (op_start[2]) begin
      if (h_end) begin
        h_cnt <=  16'h000;
      end else begin
        h_cnt <= h_cnt + 1'b1;
      end

    end
  end


  always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
      v_cnt <=  16'h000;
    end else if (op_start[2]) begin
      if (v_end && h_end) begin
        v_cnt <=  16'h000;
      end else if (h_end) begin
        v_cnt <= v_cnt + 1'b1;
      end

    end
  end


endmodule
