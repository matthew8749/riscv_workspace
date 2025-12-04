## +FHDR--------------------------------------------------------------------------------------------------------- ##
## -------------------------------------------------------------------------------------------------------------- ##
## Project ____________                                                                                           ##
## File name __________ makefile                                                                                  ##
## Creator ____________ miles.Yan                                                                                 ##
## Built Date _________ Aug-15-2025                                                                               ##
## Function ___________ Simulation Makefile                                                                       ##
## Hierarchy __________                                                                                           ##
##   Parent ___________                                                                                           ##
##   Children _________                                                                                           ##
## Revision history ___ Date        Author            Description                                                 ##
##                  ___                                                                                           ##
## -FHDR--------------------------------------------------------------------------------------------------------- ##
include ~/project/riscv_workspace/3-script/makefile/set_dir_path.mk

.PHONY: help
.PHONY: sim_r sim_r_clr
.PHONY: sim_vcs sim_vcs_all elb_vcs
.PHONY: verdi cverdi
.PHONY: clr_verdi clr_vcs clr_sim clr_fw clean

mkfile_path 	:= $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

# ========================================================================================
# 	       _ _
# 	  __ _| (_) __ _ ___
# 	 / _` | | |/ _` / __|
# 	| (_| | | | (_| \__ \
# 	 \__,_|_|_|\__,_|___/
# ========================================================================================
synth         := 0
SYNTH         := $(synth)

# ========================================================================================
# 	                  __ _                       _   _
# 	  ___ ___  _ __  / _(_) __ _ _   _ _ __ __ _| |_(_) ___  _ __  ___
# 	 / __/ _ \| '_ \| |_| |/ _` | | | | '__/ _` | __| |/ _ \| '_ \/ __|
# 	| (_| (_) | | | |  _| | (_| | |_| | | | (_| | |_| | (_) | | | \__ \
# 	 \___\___/|_| |_|_| |_|\__, |\__,_|_|  \__,_|\__|_|\___/|_| |_|___/
# 	                       |___/
# ========================================================================================
# configurations

# CFG set :
#     $(CFG_SIM_PROJ)             | $(CFG_SIM_TOP)            |   Discribe
# --------------------------------|---------------------------|-----------------
# 1.  sim_soc                     | sim_soc_top               |
#                                 | sim_picorv_x_pulp_soc     |
# --------------------------------|---------------------------|-----------------
# 2.  sim_picorv                  | testbench                 |
#                                 | testbench_ez              |
#                                 | icebreaker_tb             |
#                                 | spiflash_tb               |
# --------------------------------|---------------------------|-----------------
# 3.  sim_pulp_axi                | tb_axi_addr_test          |
#                                 | tb_axi_fifo               |
#                                 | tb_axi_lite_xbar          |
#                                 | tb_axi_xbar               |
#                                 | tb_axi_to_axi_lite        |
#                                 | ...... (For more testbenches, see the /test folder)
# --------------------------------|---------------------------|-----------------
# 4.  sim_pulp_apb                | tb_apb_regs               |
#                                 | tb_apb_cdc                |
#                                 | tb_apb_demux              |
#                                 | synth_bench               |
# --------------------------------|---------------------------|-----------------
# 5.  canny_tb                    | canny_tb                  |
# 6.  sim_sync_fifo               | sim_sync_fifo             |
# 7.  sim_async_fifo              | sim_async_fifo            |

CFG_SIM_PROJ  := sim_soc
CFG_SIM_TOP   := sim_picorv_x_pulp_soc
CFG_FSDB_FILE := $(CFG_SIM_TOP)_tb
SIM_ARG       :=

CFG_PICORV32  := 0
CFG_PROJ_NAME :=                                                                        # @@unused

# ========================================================================================
# 	 _ _     _
# 	| (_)___| |_
# 	| | / __| __|
# 	| | \__ \ |_
# 	|_|_|___/\__|
# ========================================================================================
#list

#LST_SYTM                         := 0.system.f
LST_VHDL                          := 0.system_vhdl.f
LST_SYSV                          := 0.system_sv.f
LST_MCRB                          := 0.macro.bhvr.f
LST_IPSH                          := 0.share.vlog.f
LST_IPRM                          := 1.dip_sp_ram.f
#LST_TOP                          := 0.top_filelist.f

# ========================================================================================
# 	     _ _               _             _
# 	  __| (_)_ __ ___  ___| |_ ___  _ __(_) ___  ___
# 	 / _` | | '__/ _ \/ __| __/ _ \| '__| |/ _ \/ __|
# 	| (_| | | | |  __/ (__| || (_) | |  | |  __/\__ \
# 	 \__,_|_|_|  \___|\___|\__\___/|_|  |_|\___||___/
# ========================================================================================
# directories
DIR_VCS_HOME   					  := /opt/synopsys/vcs/Q-2020.03-SP2-7
DIR_VERDI_HOME 					  := /opt/synopsys/verdi/R-2020.12-SP1
DIR_RTL_ROOT	 				  := $(MY_HOME)/project/riscv_workspace/1-rtl
DIR_LST_ROOT	 				  := $(MY_HOME)/project/riscv_workspace/1-rtl/file_list
DIR_SHR_ROOT                      := $(MY_HOME)/project/riscv_workspace/1-rtl/share

export ROOT                       = $(MY_HOME)/project/riscv_workspace
export RTL_ROOT                   = $(DIR_RTL_ROOT)
export LST_ROOT                   = $(DIR_LST_ROOT)

#FSDB_MAX_VAR_ELEM := 3000000

# ========================================================================================
# 	             _   _
# 	  ___  _ __ | |_(_) ___  _ __  ___
# 	 / _ \| '_ \| __| |/ _ \| '_ \/ __|
# 	| (_) | |_) | |_| | (_) | | | \__ \
# 	 \___/| .__/ \__|_|\___/|_| |_|___/
# 	      |_|
# ========================================================================================
# options
OPT_VCS       := -full64 -timescale=1ns/1ps -top $(CFG_SIM_TOP) \
			 		+vcs+lic+wait +notimingchecks +nospecify +vpi \
				    -P $(DIR_VERDI_HOME)/share/PLI/VCS/LINUX64/verdi.tab $(DIR_VERDI_HOME)/share/PLI/VCS/LINUX64/pli.a -l vcs.log
OPT_VCS       += -LDFLAGS -rdynamic
OPT_VCS       += +lint=TFIPC-L -error=IWNF

#OPT_VCS       +=  +verdi +plusarg_save


#add for picorv32
#PICORV32_OPT  := +trace +verbose +noerror +verdi +plusarg_save +define+COMPRESSED_ISA
PICORV32_OPT  := +verbose +noerror +verdi +plusarg_save +define+COMPRESSED_ISA




#OPT_VCS       += +plusarg_save +verbose +bootmode=fast_debug_preload +fsdb+max_var_elem=30000000
#+stimuli=./vectors/stim.txt
#+bootmode=jtag +jtag_openocd
#fast_debug_preload



# ========================================================================================
# 	                                               _
# 	  ___ ___  _ __ ___  _ __ ___   __ _ _ __   __| |___
# 	 / __/ _ \| '_ ` _ \| '_ ` _ \ / _` | '_ \ / _` / __|
# 	| (_| (_) | | | | | | | | | | | (_| | | | | (_| \__ \
# 	 \___\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|\__,_|___/
# ========================================================================================

#CMD_VCS_VHDL_ANA      := $(DIR_VCS_HOME)/bin/vhdlan -full64 -functional_vital
CMD_VCS_VHDL_ANA      := $(DIR_VCS_HOME)/bin/vhdlan -full64

CMD_VCS_VLOG_ANA      := $(DIR_VCS_HOME)/bin/vlogan -full64 +v2k
CMD_VCS_VLOG_ANA      += +define+FSDBDUMP -timescale=1ns/10ps
CMD_VCS_VLOG_ANA      += -debug_access+all +vcs+lic+wait +lint=PCWM +plusarg_save

CMD_VCS_SYSV_ANA      := $(DIR_VCS_HOME)/bin/vlogan -full64 -sverilog -sv
CMD_VCS_SYSV_ANA      += +define+TARGET_SIMULATION  +define+TARGET_VCS
CMD_VCS_SYSV_ANA      += -debug_access+all -assert svaext -debug_acc+pp +plusarg_save
#add for picorv32

ifdef CFG_PICORV32
	CMD_VCS_SYSV_ANA    += $(PICORV32_OPT)
ifeq ($(CFG_SIM_TOP), icebreaker_tb)
  CMD_VCS_SYSV_ANA    += +define+NO_ICE40_DEFAULT_ASSIGNMENTS +firmware=picorvsoc_iceb_firmware/icebreaker_fw.hex
  OPT_VCS             += +firmware=picorvsoc_iceb_firmware/icebreaker_fw.hex
else ifeq ($(CFG_SIM_TOP), spiflash_tb)
  CMD_VCS_SYSV_ANA    += +firmware=picorvsoc_iceb_firmware/icebreaker_fw.hex
  OPT_VCS             += +firmware=picorvsoc_iceb_firmware/icebreaker_fw.hex
endif

endif

CMD_VERDI_VHDL_COM    := $(DIR_VERDI_HOME)/bin/vhdlcom
CMD_VERDI_VLOG_COM    := $(DIR_VERDI_HOME)/bin/vericom
CMD_VERDI_VLOG_COM    += +define+TARGET_SIMULATION  +define+TARGET_VCS
CMD_VERDI_VHDL_COM    += +define+FSDBDUMP
CMD_VERDI_VLOG_COM    += -assert svaext


CMD_VERDI_ALIAS       := $(DIR_VERDI_HOME)/bin/aliasextract
CMD_VERDI             := $(DIR_VERDI_HOME)/bin/verdi

CMD_VCS_ELB           := vcs $(OPT_VCS) $(SIM_ARG)
CMD_SIMV              := ./simv -l simv.log
CMD_SIMV              += $(PICORV32_OPT)




.PHONY: help
help: Makefile
	@printf "Available targets\n"
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "%-15s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)





## RE simulate RTL and update verdi
sim_r: sim_r_clr cverdi

# 區別有沒有clean
sim_r_clr:
	$(MAKE) sim_vcs_all | tee ./LOG/sim_vcs.log


## Simulate RTL with VCS even do "clr_sim" first
sim_vcs:  clr_sim
	$(MAKE) sim_vcs_all | tee ./LOG/sim_vcs.log

sim_vcs_all: ana_vcs elb_vcs
	@echo "*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*"
	@echo ".                                                                   ."
	@echo ". #SIMTAG#   simulating                                             ."
	@echo ".                                                                   ."
	@echo "*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*"
	$(CMD_SIMV)

## ana filelist
ana_vcs:
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/$(LST_IPSH)
	$(CMD_VCS_VLOG_ANA) -work work -file $(DIR_LST_ROOT)/$(LST_MCRB)
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/$(LST_IPRM)

ifeq ($(CFG_SIM_PROJ), sim_soc)
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/soc_top.f
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/sim_soc.f
endif

ifeq ($(CFG_SIM_PROJ), sim_pulp_apb)
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/1.dip_pulp_common_cells.f
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/1.dip_pulp_common_verification.f
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/1.dip_pulp_apb.f
endif

ifeq ($(CFG_SIM_PROJ), sim_pulp_axi)
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/1.dip_pulp_common_cells.f
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/1.dip_pulp_common_verification.f
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/1.dip_pulp_axi.f
endif

ifeq ($(CFG_SIM_PROJ), canny_tb)
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/mdl_canny.f
endif

ifeq ($(CFG_SIM_PROJ), sim_sync_fifo)
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/1.dip_sync_fifo.f
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/2.mdl_sync_fifo.f
endif

ifeq ($(CFG_SIM_PROJ), sim_async_fifo)
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/1.dip_async_fifo.f
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/2.mdl_async_fifo.f
endif

ifeq ($(CFG_SIM_PROJ), sim_picorv)
ifneq (,$(filter $(CFG_SIM_TOP), icebreaker_tb spiflash_tb))
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/0.share.yosys.vlog.f
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/1.dip_picorvsoc.f
endif
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/1.dip_picorv32.f
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/2.mdl_picorv32.f
endif


## elaborate
elb_vcs:
	$(CMD_VCS_ELB)

## Simulate RTL wave with verdi (GUI)
verdi: cverdi
	@echo "*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*"
	@echo ".                                                                   ."
	@echo ". #SIMTAG#   creating Verdi                                         ."
	@echo ".                                                                   ."
	@echo "*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*"
	@$(CMD_VERDI_ALIAS) -lib work.verdi -top $(CFG_SIM_TOP) -output    extracted.src_alias
	@$(CMD_VERDI)       -lib work.verdi -top $(CFG_SIM_TOP) -aliasFile extracted.src_alias  -ssf $(CFG_SIM_TOP).fsdb &

ifeq ($(CFG_SIM_PROJ), sim_picorv)
	@$(CMD_VERDI_ALIAS) -lib work.verdi -top $(CFG_SIM_TOP) -output    extracted.src_alias
	@$(CMD_VERDI)       -lib work.verdi -top $(CFG_SIM_TOP) -aliasFile extracted.src_alias  -ssf $(CFG_SIM_TOP).fsdb &
endif


cverdi:
#	@$(CMD_VERDI_VHDL_COM) -lib work.verdi -2000 -file $(DIR_RTL_ROOT)/sim/$(LST_VHDL)
#	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv   -file $(DIR_RTL_ROOT)/sim/$(LST_SYSV)
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv  -file $(DIR_LST_ROOT)/$(LST_MCRB)
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv  -file $(DIR_LST_ROOT)/$(LST_IPSH)
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv  -file $(DIR_LST_ROOT)/$(LST_IPRM)
ifeq ($(CFG_SIM_PROJ), sim_soc)
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv  -file $(DIR_LST_ROOT)/soc_top.f
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv  -file $(DIR_LST_ROOT)/sim_soc.f
endif
ifeq ($(CFG_SIM_PROJ), sim_pulp_apb)
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv  -file $(DIR_LST_ROOT)/1.dip_pulp_common_cells.f
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv  -file $(DIR_LST_ROOT)/1.dip_pulp_common_verification.f
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv  -file $(DIR_LST_ROOT)/1.dip_pulp_common_cells_tb.f
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv  -file $(DIR_LST_ROOT)/1.dip_pulp_apb.f
endif
ifeq ($(CFG_SIM_PROJ), sim_pulp_axi)
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv  -file $(DIR_LST_ROOT)/1.dip_pulp_common_cells.f
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv  -file $(DIR_LST_ROOT)/1.dip_pulp_common_verification.f
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv  -file $(DIR_LST_ROOT)/1.dip_pulp_common_cells_tb
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv  -file $(DIR_LST_ROOT)/1.dip_pulp_axi.f
endif
ifeq ($(CFG_SIM_PROJ), canny_tb)
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv -file $(DIR_LST_ROOT)/mdl_canny.f
endif
ifeq ($(CFG_SIM_PROJ), sim_sync_fifo)
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv -file $(DIR_LST_ROOT)/1.dip_sync_fifo.f
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv -file $(DIR_LST_ROOT)/2.mdl_sync_fifo.f
endif
ifeq ($(CFG_SIM_PROJ), sim_async_fifo)
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv -file $(DIR_LST_ROOT)/1.dip_async_fifo.f
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv -file $(DIR_LST_ROOT)/2.mdl_async_fifo.f
endif
ifeq ($(CFG_SIM_PROJ), sim_picorv)
ifneq (,$(filter $(CFG_SIM_TOP), icebreaker_tb spiflash_tb))
	#@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv -file $(DIR_LST_ROOT)/0.share.yosys.vlog.f  #讀入會有error
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv -file $(DIR_LST_ROOT)/1.dip_picorvsoc.f
endif
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv -file $(DIR_LST_ROOT)/1.dip_picorv32.f
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv -file $(DIR_LST_ROOT)/2.mdl_picorv32.f
endif


.PHONY:clr_vcs
clr_vcs:
	@echo "*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*"
	@echo ".                                                                   ."
	@echo ". #SIMTAG#   clean vcs                                              ."
	@echo ".                                                                   ."
	@echo "*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*"
	@-rm -rf work simv.daidir csrc DVEfiles .vdbg_combination_lock RCORE_log.eis
	@-rm -f simv ucli.key .vlogansetup.args .vlogansetup.env
	@-rm -f $(CFG_ROM_INIT_FILE) $(CFG_0RCORE_INIT_FILE) $(CFG_SPI_INIT_FILE)

.PHONY:clr_verdi
clr_verdi:
	@echo "*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*"
	@echo ".                                                                   ."
	@echo ". #SIMTAG#   clean verdi                                            ."
	@echo ".                                                                   ."
	@echo "*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*"
	@-rm -rf verdiLog vericomLog vhdlcomLog work.verdi.lib++ novas.conf novas_dump.log
	@-rm -rf aliasextractLog extracted.src_alias


## Remove all compiled RTL
clr_sim: clr_vcs clr_verdi
	rm -rf 64 AN.DB
	rm -rf novas* simv work.* .vhdl_* vcs.log vc_hdrs.h debug.log

## Remove all
clean: clr_vcs clr_verdi clr_fw
	$(RM) -r work
	$(RM) modelsim.ini
	rm -rf 64 simv.daidir verdiLog vericomLog vhdlcomLog AN.DB
	rm -rf novas* simv work.* .vhdl_* vcs.log vc_hdrs.h debug.log



# ███████╗██╗██████╗ ███╗   ███╗██╗    ██╗ █████╗ ██████╗ ███████╗
# ██╔════╝██║██╔══██╗████╗ ████║██║    ██║██╔══██╗██╔══██╗██╔════╝
# █████╗  ██║██████╔╝██╔████╔██║██║ █╗ ██║███████║██████╔╝█████╗
# ██╔══╝  ██║██╔══██╗██║╚██╔╝██║██║███╗██║██╔══██║██╔══██╗██╔══╝
# ██║     ██║██║  ██║██║ ╚═╝ ██║╚███╔███╔╝██║  ██║██║  ██║███████╗
# ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
# reference : YosysHQ---picorv32 Makefile
PYTHON 									= python3
COMPRESSED_ISA 							= C
RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX 		= /opt/riscv
TOOLCHAIN_PREFIX 						= $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)/bin/riscv32-unknown-elf-

TEST_OBJS 		= $(addsuffix .o,$(basename $(wildcard tests/*.S)))
FIRMWARE_OBJS   = firmware/start.o firmware/irq.o firmware/print.o firmware/main.o firmware/sieve.o firmware/multest.o firmware/stats.o

GCC_WARNS  		= -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS 		+= -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic # -Wconversion

## Run
gen_trace: showtrace.py
	$(PYTHON) showtrace.py testbench.trace firmware/firmware.elf | tee ./LOG/showtrace.log

## generate picorv32 firmware
gen_fw: clr_fw
	$(MAKE) firmware/firmware.hex | tee ./LOG/gen_fw.log

firmware/firmware.hex: firmware/firmware.bin firmware/makehex.py
	$(PYTHON) firmware/makehex.py $< 32768 > $@

firmware/firmware.bin: firmware/firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@
	chmod -x $@

# picorvsoc_iceb_firmware/icebreaker_fw.bin: picorvsoc_iceb_firmware/icebreaker_fw.elf
# 	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@
# 	chmod -x $@

firmware/firmware.elf: $(FIRMWARE_OBJS) $(TEST_OBJS) firmware/sections.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -mabi=ilp32 -march=rv32im$(subst C,c,$(COMPRESSED_ISA)) -ffreestanding -nostdlib -o $@ \
		-Wl,--build-id=none,-Bstatic,-T,firmware/sections.lds,-Map,firmware/firmware.map,--strip-debug \
		$(FIRMWARE_OBJS) $(TEST_OBJS) -lgcc
	chmod -x $@

firmware/start.o: firmware/start.S
	$(TOOLCHAIN_PREFIX)gcc -c -mabi=ilp32 -march=rv32im$(subst C,c,$(COMPRESSED_ISA)) -o $@ $<

firmware/%.o: firmware/%.c
	$(TOOLCHAIN_PREFIX)gcc -c -mabi=ilp32 -march=rv32i$(subst C,c,$(COMPRESSED_ISA)) -Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -o $@ $<

tests/%.o: tests/%.S tests/riscv_test.h tests/test_macros.h
	$(TOOLCHAIN_PREFIX)gcc -c -mabi=ilp32 -march=rv32im -o $@ -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $<


## ## Remove all compiled firmware
clr_fw:
	rm -vrf $(FIRMWARE_OBJS) $(TEST_OBJS)  \
		firmware/firmware.elf firmware/firmware.bin firmware/firmware.hex firmware/firmware.map \
		firmware/*.o \
		estbench.trace \
		testbench_verilator testbench_verilator_dir \
		LOG/showtrace.log