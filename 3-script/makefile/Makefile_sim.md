# Makefile_sim 參數定義

CFG_SIM_PROJ  : 用來設定是跑哪一個專案模擬，會讀哪些filelist
CFG_SIM_TOP   : 在同一個CFG_SIM_PROJ下可以有不同的testbench

```
# CFG set :
#     $(CFG_SIM_PROJ)             | $(CFG_SIM_TOP)            |   Discribe
# --------------------------------|---------------------------|-----------------
# 1.  sim_soc                     | sim_soc_top               |
# --------------------------------|---------------------------|-----------------
# 2.  sim_picorv                  | testbench,                |
#                                 | testbench_ez,             |
#                                 | icebreaker_tb,            |
#                                 | spiflash_tb               |
# --------------------------------|---------------------------|-----------------
# 3.  sim_pulp_axi                | tb_axi_addr_test          |
#                                 | tb_axi_fifo               |
#                                 | tb_axi_lite_xbar          |
#                                 | tb_axi_xbar               |
#                                 | tb_axi_to_axi_lite        |
#                                 | ...... (For more testbenches, see the /test folder)
# --------------------------------|---------------------------|-----------------
# 4.  canny_tb                    | canny_tb                  |
# 5.  sim_sync_fifo               | sim_sync_fifo             |
# 6.  sim_async_fifo              | sim_async_fifo            |
```