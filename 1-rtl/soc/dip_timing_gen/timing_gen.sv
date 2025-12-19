`timescale 1ns / 1ps
// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ timing_gen.v                                                                              //
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
module timing_gen(
  input                           clk,
  input                           rst_n,
  input       [22: 0]             vs_reset,

  input       [15 : 0]            Hor_Addr_Time,             //= 16'd640;
  input       [15 : 0]            Hor_Sync_Time,             //= 16'd96;
  input       [15 : 0]            Hor_Back_Porch,            //= 16'd40;
  input       [15 : 0]            Hor_Left_Border,           //= 16'd8;
  input       [15 : 0]            Hor_Right_Border,          //= 16'd8;
  input       [15 : 0]            Hor_Front_Porch,           //= 16'd8;

  input       [15 : 0]            Ver_Addr_Time,             //= 16'd480;
  input       [15 : 0]            Ver_Sync_Time,             //= 16'd2;
  input       [15 : 0]            Ver_Back_Porch,            //= 16'd35;
  input       [15 : 0]            Ver_Bottom_Border,         //= 16'd8;
  input       [15 : 0]            Ver_Top_Border,            //= 16'd8;
  input       [15 : 0]            Ver_Front_Porch,           //= 16'd2;

  output      [15: 0]             hcount,
  output      [15: 0]             vcount,
  output      [26: 24]            Synco
  //input       [15: 0]             h_sync,
  //input       [15: 0]             h_start, //h_start = h_sync + hbp
  //input       [15: 0]             h_start, //h_start = h_sync + hbp + hlb
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  wire        [15 : 0]            Hor_total;
  wire        [15 : 0]            Ver_total;
  wire        [15 : 0]            Hor_start;
  wire        [15 : 0]            Ver_start;

  reg         [2: 0]              op_start;
  wire                            h_end;
  wire                            v_end;
  wire                            VT_boundary;
  wire                            VB_boundary;
  wire                            HR_boundary;
  wire                            HL_boundary;

  reg                             ht_sync;
  reg                             vt_sync;
  reg                             h_de;
  reg                             v_de;
  wire                            t_de;
  reg         [15 : 0]            h_cnt;
  reg         [15 : 0]            v_cnt;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
assign Synco[26:24] = {vt_sync, ht_sync, t_de };
assign hcount[15: 0] = h_cnt;
assign vcount[15: 0] = v_cnt;


// tag INs assignment ---------------------------------------------------------------------------------------------


// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
  assign Hor_total = Hor_Addr_Time + Hor_Sync_Time + Hor_Back_Porch + Hor_Left_Border + Hor_Right_Border  + Hor_Front_Porch;
  assign Ver_total = Ver_Addr_Time + Ver_Sync_Time + Ver_Back_Porch + Ver_Top_Border  + Ver_Bottom_Border + Ver_Front_Porch;
  assign Hor_start = Hor_Sync_Time + Hor_Back_Porch + Hor_Left_Border;
  assign Ver_start = Ver_Sync_Time + Ver_Back_Porch + Ver_Top_Border;

  assign h_end = (h_cnt >= (Hor_total - 1'b1));
  assign v_end = (v_cnt >= (Ver_total - 1'b1));

  assign HR_boundary = (h_cnt == (Hor_start - 1'b1));
  assign HL_boundary = (h_cnt == (Hor_start + Hor_Addr_Time - 1'b1));

  assign VT_boundary = (v_cnt == (Ver_start -1));
  assign VB_boundary = (v_cnt == (Ver_start + Ver_Addr_Time - 1'b1));

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
      end else if (h_cnt == (Hor_Sync_Time - 1'b1)) begin
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
      end else if (v_cnt == (Ver_Sync_Time - 1'b1)  && h_end) begin
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
