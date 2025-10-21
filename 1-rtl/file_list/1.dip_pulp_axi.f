// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// pulp_axi              /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
+incdir+$RTL_ROOT/soc/dip_pulp_common_cells
+incdir+$RTL_ROOT/soc/dip_pulp_common_cells/include
+incdir+$RTL_ROOT/soc/dip_pulp_common_cells/include/common_cells
+incdir+$RTL_ROOT/soc/dip_pulp_axi
+incdir+$RTL_ROOT/soc/dip_pulp_axi/include
+incdir+$RTL_ROOT/soc/dip_pulp_axi/include/axi
//- include/axi/assign.svh :  {is_include_file : true, include_path : include}
//      - include/axi/typedef.svh :  {is_include_file : true, include_path : include}
$RTL_ROOT/soc/dip_pulp_axi/src/axi_pkg.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_intf.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_atop_filter.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_burst_splitter_gran.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_burst_unwrap.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_bus_compare.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_cdc_dst.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_cdc_src.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_cut.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_delayer.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_demux_simple.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_dw_downsizer.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_dw_upsizer.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_fifo.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_fifo_delay_dyn.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_id_remap.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_id_prepend.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_inval_filter.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_isolate.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_join.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_lite_demux.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_lite_dw_converter.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_lite_from_mem.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_lite_join.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_lite_lfsr.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_lite_mailbox.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_lite_mux.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_lite_regs.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_lite_to_apb.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_lite_to_axi.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_modify_address.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_mux.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_rw_join.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_rw_split.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_serializer.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_slave_compare.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_throttle.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_to_detailed_mem.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_burst_splitter.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_cdc.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_demux.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_err_slv.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_dw_converter.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_from_mem.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_id_serialize.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_lfsr.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_multicut.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_to_axi_lite.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_to_mem.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_zero_mem.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_interleaved_xbar.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_iw_converter.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_lite_xbar.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_xbar_unmuxed.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_to_mem_banked.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_to_mem_interleaved.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_to_mem_split.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_chan_compare.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_dumper.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_sim_mem.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_test.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_xbar.sv
$RTL_ROOT/soc/dip_pulp_axi/src/axi_xp.sv


// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// pulp_axi_test         /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
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