// *************************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// pulp_common_cells_test  /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// ***********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
+incdir+$RTL_ROOT/soc/dip_pulp_common_cells
+incdir+$RTL_ROOT/soc/dip_pulp_common_cells/include
+incdir+$RTL_ROOT/soc/dip_pulp_common_cells/include/common_cells
// Level 0
$RTL_ROOT/soc/dip_pulp_common_cells/test/addr_decode_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/cb_filter_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/cdc_2phase_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/cdc_2phase_clearable_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/cdc_fifo_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/cdc_fifo_clearable_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/fifo_inst_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/fifo_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/graycode_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/id_queue_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/passthrough_stream_fifo_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/popcount_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/rr_arb_tree_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/stream_test.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/stream_register_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/stream_to_mem_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/sub_per_hash_tb.sv
// Level 1
$RTL_ROOT/soc/dip_pulp_common_cells/test/isochronous_crossing_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/stream_omega_net_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/stream_xbar_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/clk_int_div_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/clk_int_div_static_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/clk_mux_glitch_free_tb.sv
$RTL_ROOT/soc/dip_pulp_common_cells/test/lossy_valid_to_stream_tb.sv

// **********************************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// pulp_common_verification test    /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// ********************************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
$RTL_ROOT/soc/dip_pulp_common_verification/test/tb_clk_rst_gen.sv

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// dip_pulp_apb  TEST    /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
+incdir+$RTL_ROOT/soc/dip_pulp_common_cells/include
+incdir+$RTL_ROOT/soc/dip_pulp_apb/include
+incdir+$RTL_ROOT/soc/dip_pulp_apb/include/apb
//- target: test                  // files:
$RTL_ROOT/soc/dip_pulp_apb/test/tb_apb_regs.sv
$RTL_ROOT/soc/dip_pulp_apb/test/tb_apb_cdc.sv
$RTL_ROOT/soc/dip_pulp_apb/test/tb_apb_demux.sv
//- target: synth_test            // files:
//# Level 0
$RTL_ROOT/soc/dip_pulp_apb/test/synth_bench.sv

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// pulp_axi_test         /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
+incdir+$RTL_ROOT/soc/dip_pulp_axi
+incdir+$RTL_ROOT/soc/dip_pulp_axi/include
+incdir+$RTL_ROOT/soc/dip_pulp_axi/include/axi
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_dw_pkg.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_xbar_pkg.sv
$RTL_ROOT/soc/dip_pulp_axi/test/axi_synth_bench.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_addr_test.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_atop_filter.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_bus_compare.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_cdc.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_delayer.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_dw_downsizer.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_dw_upsizer.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_fifo.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_isolate.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_iw_converter.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_lite_dw_converter.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_lite_mailbox.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_lite_regs.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_lite_to_apb.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_lite_to_axi.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_lite_xbar.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_modify_address.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_serializer.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_sim_mem.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_slave_compare.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_to_axi_lite.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_to_mem_banked.sv
$RTL_ROOT/soc/dip_pulp_axi/test/tb_axi_xbar.sv
//    depend :
//      - ">=pulp-platform.org::common_verification:0.2.5"

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// soc_top               /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
$RTL_ROOT/sim_model/sim_top/sim_soc_top.sv
$RTL_ROOT/sim_model/sim_top/sim_picorv_x_pulp_soc.sv