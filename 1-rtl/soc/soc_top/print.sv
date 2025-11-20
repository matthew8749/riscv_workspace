module print (

  input             clk,
  input             mem_axi_awvalid,
  input      [31:0] mem_axi_awaddr,

  input             mem_axi_wvalid,
  input      [31:0] mem_axi_wdata
);

  reg latched_raddr_en = 0;
  reg latched_waddr_en = 0;
  reg latched_wdata_en = 0;

  reg fast_raddr = 0;
  reg fast_waddr = 0;
  reg fast_wdata = 0;

  reg [31:0] latched_waddr;
  reg [31:0] latched_wdata;

  event       print_ok;

  task handle_axi_awvalid; begin
    latched_waddr = mem_axi_awaddr;
    latched_waddr_en <= 1;
    fast_waddr <= 1;
  end endtask

  task handle_axi_wvalid; begin
    latched_wdata = mem_axi_wdata;
    latched_wdata_en = 1;
    fast_wdata <= 1;
  end endtask

  task handle_axi_bvalid; begin
    -> print_ok;
    if (latched_waddr == 32'h1000_0000) begin
        $write("%c", latched_wdata[7:0]);
        $fflush();
    end
    latched_waddr_en = 0;
    latched_wdata_en = 0;
  end endtask

  always @(negedge clk) begin
    if (mem_axi_awvalid && !(latched_waddr_en || fast_waddr) ) handle_axi_awvalid;
    if (mem_axi_wvalid  && !(latched_wdata_en || fast_wdata) ) handle_axi_wvalid;
    if ( latched_waddr_en && latched_wdata_en ) handle_axi_bvalid;
  end

  always @(posedge clk) begin

    fast_waddr <= 0;
    fast_wdata <= 0;


    if (mem_axi_awvalid && !fast_waddr) begin
      latched_waddr    = mem_axi_awaddr;
      latched_waddr_en = 1;
    end

    if (mem_axi_wvalid  && !fast_wdata) begin
      latched_wdata = mem_axi_wdata;
      latched_wdata_en = 1;
    end

    if (mem_axi_awvalid && !(latched_waddr_en || fast_waddr) ) handle_axi_awvalid;
    if (mem_axi_wvalid  && !(latched_wdata_en || fast_wdata) ) handle_axi_wvalid;

    if ( latched_waddr_en && latched_wdata_en ) handle_axi_bvalid;
  end
endmodule
