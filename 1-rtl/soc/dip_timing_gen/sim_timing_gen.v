// Not for HDMI
// just frame count


module sim_timing_gen (
  input                           clk,
  input                           rst_n,
  input       [15: 0]             h_total,
  input       [15: 0]             v_total,

  output      [15: 0]             hcount,
  output      [15: 0]             vcount,
  output                          h_sync,
  output                          v_sync
);

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  reg         [15: 0]             op_start;
  wire                            h_end;
  wire                            v_end;

  reg   ht_sync;
  reg   vt_sync;
  reg   h_de;
  reg   v_de;
  wire  t_de;
  reg   [15:0]  h_cnt;
  reg   [15:0]  v_cnt;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
assign hcount[15: 0] = h_cnt;
assign vcount[15: 0] = v_cnt;


// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
  assign h_end = (h_cnt >= (h_total - 1'b1));
  assign v_end = (v_cnt >= (v_total - 1'b1));
  assign t_de = v_de & h_de;

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// tag_De                /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****



// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// tag_sync              /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****


  always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
      ht_sync <=  1'b0;
    end else begin
      if (op_start[15:14] == 2'b01 || h_end) begin
        ht_sync <= 1'b1;
      //end else if (h_cnt == (h_total - 1'b1)) begin
      end else begin
        ht_sync <= 1'b0;
      end

    end
  end


  always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
      vt_sync <=  1'b0;
    end else begin
      if (op_start[15:14] == 2'b01 || (v_end && h_end) ) begin
        vt_sync <= 1'b1;
      //end else if (v_cnt == (v_total - 1'b1)  && h_end) begin
      end else begin
        vt_sync <= 1'b0;
      end

    end
  end
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
  always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
      op_start <=  16'b0;
    end else begin
      op_start <= {op_start[14:0], 1'b1};

    end
  end


  always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
      h_cnt <=  16'h000;
    end else if (op_start[15]) begin
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
    end else if (op_start[15]) begin
      if (v_end && h_end) begin
        v_cnt <=  16'h000;
      end else if (h_end) begin
        v_cnt <= v_cnt + 1'b1;
      end

    end
  end


endmodule
