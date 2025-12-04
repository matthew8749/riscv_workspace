// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// dip_pulp_apb          /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
//  - include
+incdir+$RTL_ROOT/soc/dip_pulp_common_cells/include
+incdir+$RTL_ROOT/soc/dip_pulp_apb/include
+incdir+$RTL_ROOT/soc/dip_pulp_apb/include/apb
//# Level 0
$RTL_ROOT/soc/dip_pulp_apb/src/apb_pkg.sv
//# Level 1
$RTL_ROOT/soc/dip_pulp_apb/src/apb_intf.sv
//# Level 2
$RTL_ROOT/soc/dip_pulp_apb/src/apb_err_slv.sv
$RTL_ROOT/soc/dip_pulp_apb/src/apb_regs.sv
$RTL_ROOT/soc/dip_pulp_apb/src/apb_cdc.sv
$RTL_ROOT/soc/dip_pulp_apb/src/apb_demux.sv
$RTL_ROOT/soc/dip_pulp_apb/src/apb_regs_intf_wrapper.sv
//- target: simulation            // files:
$RTL_ROOT/soc/dip_pulp_apb/src/apb_test.sv

// ***********************/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**\**\****/**/**
// dip_pulp_apb  TEST    /**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/****\**\**/**/***
// *********************/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/******\**\/**/****
//- target: test                  // files:
$RTL_ROOT/soc/dip_pulp_apb/test/tb_apb_regs.sv
$RTL_ROOT/soc/dip_pulp_apb/test/tb_apb_cdc.sv
$RTL_ROOT/soc/dip_pulp_apb/test/tb_apb_demux.sv
//- target: synth_test            // files:
//# Level 0
$RTL_ROOT/soc/dip_pulp_apb/test/synth_bench.sv
