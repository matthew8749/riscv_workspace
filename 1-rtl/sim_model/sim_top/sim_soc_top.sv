// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ ModuleName.v                                                                              //
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


module sim_soc_top;

// tag COMPONENTs and SIGNALs declaration --------------------------------------------------------------------------
  localparam FSDBFILE = "./soc_top_force_ld.fsdb";
  //localparam STIM = "./vectors/stim_zero.txt";
  parameter                       ADR_BIT =  3;
  parameter                       DAT_BIT = 24;
  parameter                       WEN_BIT =  1;

  logic                           ref_clk_i;
  logic                           slow_clk_i;
  logic                           test_clk_i;
  reg                             rstn_glob_i;
  reg                             rst_n;

  //sim_sync_fifo
  reg                             wr_en;
  reg         [DAT_BIT-1:0]       data_in;
  reg                             rd_en;
  wire        [DAT_BIT-1:0]       data_out;
  reg         [DAT_BIT-1:0]       rdata;
  reg                             empty;
  wire                            full;
  reg                             stop;

  // alu_cop
  reg                             clk;
  reg                             alu_cop_wr_en;
  reg         [DAT_BIT-1:0]       alu_cop_data_in;
  reg                             alu_cop_rd_en;
  wire        [ 16      :0]       alu_cop_result;

  wire                            prf_full;
  wire                            prf_empty;
  wire                            prf_pre_full;
  wire                            prf_pre_empty;
  wire                            alu_cop_rd_rdy;

// tag OUTs assignment ---------------------------------------------------------------------------------------------
// tag INs assignment ----------------------------------------------------------------------------------------------
// tag COMBINATIONAL LOGIC -----------------------------------------------------------------------------------------
// tag COMBINATIONAL PROCESS ---------------------------------------------------------------------------------------
// tag SEQUENTIAL LOGIC --------------------------------------------------------------------------------------------

always #10 clk <= ~clk;
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
initial begin
    $fsdbDumpfile("./soc_top_sync_fifo_test.fsdb");
    $fsdbDumpvars(0, sim_soc_top, "+all");
    $fsdbDumpMDA;
  end

initial begin
  clk              <= 0;
  rst_n            <= 0;
  wr_en            <= 0;
  rd_en            <= 0;
  stop             <= 0;
  alu_cop_data_in  <= {8'b00000011, 8'b00000011, 8'b00000000};
  #50 rst_n        <= 1;
end


// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
// clock gen
tb_clk_gen #(
    //.CLK_PERIOD(REF_CLK_PERIOD)
    .CLK_PERIOD(3.33)   // 5 --> 200MHz
  ) i_ref_clk_gen (
    .clk_o(ref_clk_i)
  );

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// fifo                /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
sync_fifo #(.ADR_BIT(ADR_BIT),.DAT_BIT(DAT_BIT)) i_sync_fifo (
  .rst_n   ( rst_n         ),
  .clk     ( clk     ),
  .wr_en   ( wr_en         ),
  .rd_en   ( rd_en         ),
  .data_in ( data_in       ),
  .data_out( data_out      ),
  .empty   ( empty         ),
  .full    ( full          )
);

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// alu_cop               /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
alu_cop#(
  .ADR_BIT (ADR_BIT),
  .DAT_BIT (DAT_BIT)
)u0_alu_cop(
   .rst_n              ( rst_n              ) ,                          // i
   .clk                ( clk                ) ,                          // i
   .alu_cop_wr_en      ( alu_cop_wr_en      ) ,                          // i
   .alu_cop_rd_en      ( alu_cop_rd_en      ) ,                          // i  ctrl by me
   .alu_cop_data_in    ( alu_cop_data_in    ) ,                          // i
   .alu_cop_result     ( alu_cop_result     ) ,                          // o

   .prf_full           ( prf_full           ) ,                          // o
   .prf_empty          ( prf_empty          ) ,                          // o
   .prf_pre_full       ( prf_pre_full       ) ,                          // o
   .prf_pre_empty      ( prf_pre_empty      )                            // o
);

initial begin
  alu_cop_rd_en <= 0;
  #70
  //alu_cop_rd_en <= 1;
  for (int i = 0; i < 5; i = i+1) begin
    @ (posedge clk);
    if (~prf_full) begin
      alu_cop_wr_en   = 1'b1;
      //alu_cop_data_in[23 : 16] = alu_cop_data_in[23 : 16] + 8'b00000000;
      //alu_cop_data_in[15 :  8] = alu_cop_data_in[15 :  8] + 8'b00000001;
      //alu_cop_data_in[ 7 :  0] = alu_cop_data_in[ 7 :  0] + 8'b00000001;
      alu_cop_data_in = alu_cop_data_in + {8'b00000000, 8'b00000001, 8'b00000001};
    end else begin
      alu_cop_wr_en       = 1'b0;
      alu_cop_data_in     = alu_cop_data_in;
    end
  end
  @ (posedge clk);
  alu_cop_wr_en   = 1'b0;


  #2300
  $finish;

end





// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// alu                   /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
reg [7:0] val_a;
reg [7:0] val_b;
reg [7:0] val_c;
reg alu_wr_rdy;
reg alu_rd_ack;
wire alu_wr_ack;
wire alu_rd_rdy;
wire [16:0] alu_result;

alu i_alu (
  .rst_n     (rst_n     ),
  .clk       (clk       ),
  .val_a     (val_a     ),      // i
  .val_b     (val_b     ),      // i
  .val_c     (val_c     ),      // i
  .alu_wr_rdy(alu_wr_rdy),        // i
  .alu_wr_ack(alu_wr_ack),        // 0
  .alu_rd_ack(alu_rd_ack),        // i
  .alu_rd_rdy(alu_rd_rdy),        // o
  .alu_result(alu_result)         // o
);

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****

initial begin
alu_wr_rdy = 1'b0;
alu_rd_ack = 1'b0;
#70
val_a = 7'd2;
val_b = 7'd3;
val_c = 7'd10;
alu_wr_rdy = 1'b1;
alu_rd_ack = 1'b0;
#20
//alu_rd_ack = 1'b1;
val_a = 7'd4;
val_b = 7'd5;
#20
//alu_rd_ack = 1'b1;
val_a = 7'd6;
val_b = 7'd7;

end

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
task automatic write_one (input reg [DAT_BIT-1:0] din);
  begin
    @(posedge clk);
    if (!full) begin
      #1 wr_en   <= 1;
      #1 data_in  = din;
    end else begin
      #1 wr_en   <= 0;
      #1 data_in  = 'x;
    end
  end
endtask

task automatic read_one();
  begin
    @(posedge clk);
    if (!empty) begin
      #1 rd_en      <= 1;
    end else begin
      #1 rd_en      <= 0;
    end
  end
endtask
// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
reg [DAT_BIT-1 : 0] reg_data ;
// initial begin
//   reg_data <= 'd0;
//   #50
//   @(posedge clk);
//   //for (int i = 0; i < (2**ADR_BIT); i = i+1) begin
//   for (int i = 0; i < 20; i = i+1) begin
//     write_one(reg_data);
//     reg_data = reg_data + 3'd5;
//   end
//   wr_en <= 0;
//   #100

//   @(posedge clk);
//   if (!empty) begin
//     rd_en      <= 1;
//   end else begin
//     rd_en      <= 0;
//   end


//   #230
//   $finish;

// end

initial begin
  reg_data <= 'd0;
  #70
  reg_data = reg_data + 3'd5;
  wr_en    = 1;
  data_in  = reg_data;

  #20
  reg_data = reg_data + 3'd5;
  wr_en    = 1;
  data_in  = reg_data;
  #20
  reg_data = reg_data + 3'd5;
  wr_en    = 1;
  data_in  = reg_data;
  #20
  wr_en    = 0;

  @(posedge clk);
  #100
  @(posedge clk);
  rd_en <=1;
  //#40
  //rd_en <=0;




  #230
  $finish;

end


// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
//                       /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
`ifdef TEST_SYNC_FIFO
initial begin
  #50
  @ (posedge clk);
  for (int i = 0; i < 200; i = i+1) begin
    // Wait until there is space in fifo
    while (full) begin
      @ (posedge clk);
      $display("[%0t] FIFO is full, wait for reads to happen", $time);
    end;

    // Drive new values into FIFO
    wr_en     <= $random;
    data_in   <= data_in + 3'd5;
    $display("[%0t] clk i=%0d wr_en=%0d data_in=0x%0h ", $time, i, wr_en, data_in);

    // Wait for next clock edge
    @ (posedge clk);
  end

  stop = 1;
  //#100 $finish;

end

initial begin
  #50
  @ (posedge clk);

  while (!stop) begin
    // Wait until there is data in fifo
    while (empty) begin
      rd_en <= 0;
      $display("[%0t] FIFO is empty, wait for writes to happen", $time);
      @ (posedge clk);
    end;

    // Sample new values from FIFO at random pace
    rd_en <= $random;
    @ (posedge clk);
    rdata <= data_out;
    $display("[%0t] clk rd_en=%0d rdata=0x%0h ", $time, rd_en, rdata);
  end

  #2000 $finish;
end
`endif







endmodule
