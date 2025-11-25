// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Testbench for different FIFO configurations
module fifo_tb #(
    // TB parameters
    parameter int unsigned  N_CHECKS        = 100000,
    parameter time          TCLK            = 10ns,
    parameter time          TA              = TCLK * 1/4,
    parameter time          TT              = TCLK * 3/4
);

    logic       clk,
                rst_n;

    logic [5:0] done;

    clk_rst_gen #(.ClkPeriod(TCLK), .RstClkCycles(10)) i_clk_rst_gen (
        .clk_o    (clk),
        .rst_no   (rst_n)
    );

    fifo_inst_tb #(
        .FALL_THROUGH   (1'b0),
        .DEPTH          (8),
        .N_CHECKS       (N_CHECKS),
        .TA             (TA),
        .TT             (TT)
    ) i_tb_8 (
        .clk_i  (clk),
        .rst_ni (rst_n),
        .done_o (done[0])
    );

    fifo_inst_tb #(
        .FALL_THROUGH   (1'b1),
        .DEPTH          (8),
        .N_CHECKS       (N_CHECKS),
        .TA             (TA),
        .TT             (TT)
    ) i_tb_ft_8 (
        .clk_i  (clk),
        .rst_ni (rst_n),
        .done_o (done[1])
    );

    fifo_inst_tb #(
        .FALL_THROUGH   (1'b0),
        .DEPTH          (1),
        .N_CHECKS       (N_CHECKS),
        .TA             (TA),
        .TT             (TT)
    ) i_tb_1 (
        .clk_i  (clk),
        .rst_ni (rst_n),
        .done_o (done[2])
    );

    fifo_inst_tb #(
        .FALL_THROUGH   (1'b1),
        .DEPTH          (1),
        .N_CHECKS       (N_CHECKS),
        .TA             (TA),
        .TT             (TT)
    ) i_tb_ft_1 (
        .clk_i  (clk),
        .rst_ni (rst_n),
        .done_o (done[3])
    );

    fifo_inst_tb #(
        .FALL_THROUGH   (1'b0),
        .DEPTH          (9),
        .N_CHECKS       (N_CHECKS),
        .TA             (TA),
        .TT             (TT)
    ) i_tb_9 (
        .clk_i  (clk),
        .rst_ni (rst_n),
        .done_o (done[4])
    );

    fifo_inst_tb #(
        .FALL_THROUGH   (1'b1),
        .DEPTH          (9),
        .N_CHECKS       (N_CHECKS),
        .TA             (TA),
        .TT             (TT)
    ) i_tb_ft_9 (
        .clk_i  (clk),
        .rst_ni (rst_n),
        .done_o (done[5])
    );

    initial begin
      $fsdbDumpfile("sim_fifo_tb.fsdb");
      $fsdbDumpvars(0, fifo_tb, "+mda");
      $fsdbDumpMDA();
    end
    initial begin
        wait ((&done));
        $finish();
    end

endmodule
