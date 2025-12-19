## List of Modules

| Name                                                                       | Description                                                                                          | Doc                              |
|----------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|----------------------------------|
| [`sim_picorv_x_pulp_soc`](sim_model/sim_top/sim_picorv_x_pulp_soc.sv)      |                                                                                                      |                                  |
| [`picorv_x_pulp_soc`](soc/soc_top/picorv_x_pulp_soc.sv)                    |                                                                                                      |                                  |
| [`BACKBONE`](soc/soc_top/BACKBONE.sv)                                      |                                                                                                      |                                  |
| [`axi_lite_reg_intf_wrap`](soc/soc_top/axi_lite_reg_intf_wrap.sv)          |                                                                                                      |                                  |
| [`apb_regs_intf_wrap`](soc/soc_top/apb_regs_intf_wrap.sv)                  |                                                                                                      |                                  |
| [`mst_imp_r_ch`](soc/soc_top/mst_imp_r_ch.sv)                              |                                                                                                      |                                  |
| [`mst_imp_w_ch`](soc/soc_top/mst_imp_w_ch.sv)                              |                                                                                                      |                                  |
| [`mst_imp_wrap`](soc/soc_top/mst_imp_wrap.sv)                              |                                                                                                      |                                  |
| [`axi_lite_memory`](soc/soc_top/axi_lite_memory.sv)                        |                                                                                                      |                                  |
| [`icg_posedge`](soc/soc_top/icg_posedge.sv)                                |                                                                                                      |                                  |
| [`sync_xxxt`]()                                                            |                                                                                                      |                                  |
| [`ma_clk_div_n`]()                                                         |                                                                                                      | [Doc]()                          |
| [`ma_sync_rst`]()                                                          |                                                                                                      |                                  |
| [`ma_clks_group_gen`]()                                                    |                                                                                                      |                                  |

## Synthesizable Verification Modules

The following modules are meant to be used for verification purposes only but are synthesizable to be used in FPGA environments.

| Name                                                 | Description                                                                                             |
|------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| [``]()                                               |                                                                                                         |
| [``]()                                               |                                                                                                         |
| [``]()                                               |                                                                                                         |


### Simulation-Only Modules

In addition to the modules above, which are available in synthesis and simulation, the following modules are available only in simulation.  Those modules are widely used in our testbenches, but they are also suitable to build testbenches for AXI modules and systems outside this repository.

| Name                                                 | Description                                                                                             |
|------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| [``]()                                               |                                                                                                         |
| [``]()                                               |                                                                                                         |
| [``]()                                               |                                                                                                         |




##### Reference Format : pulp_axi/README.md