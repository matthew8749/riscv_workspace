# Copyright 2022 ETH Zurich and University of Bologna
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
include ~/project/riscv_workspace/3-script/makefile/firmware.mk
include ~/project/riscv_workspace/3-script/makefile/set_dir_path.mk

.PHONY:build clean sim simc sim_vcs elb_vcs verdi cverdi clrverdi clrvcs simc opt opt lib clean help


mkfile_path 	:= $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

VSIM					?= vsim
VSIM_FLAGS		= -gLOAD_L2=JTAG
VSIM_SUPPRESS	= -suppress vsim-3009 -suppress vsim-8683 -suppress vsim-8386
VLOG					?= vlog
VLOG_FLAGS    =

# vopt +acc test_counter -o testcounter_opt （使用vopt表示進行設計優化，+acc表示完全可見，-o testcounter_opt表示把優化結果輸出為新的名字。）
# vsim testcounter_opt （vsim表示開始仿真，名字選擇了優化之後的結果)
VOPT            ?= vopt
VOPT_FLAGS      ?= +acc


SVLIB					=  ../1-rtl/tb/remote_bitbang/librbs

# top-level (tesbench)
SIM_TOP      	:= testbench
PROJ_NAME			:=

CFG_PROJ_NAME	 :=
# soc_top, sim_timing_gen_tb, canny_tb, sim_img_processing_top, sim_sync_fifo
#CFG_SIM_TOP			:= sim_$(SIM_TOP)
CFG_SIM_TOP			:= $(SIM_TOP)
CFG_FSDB_FILE		:= $(CFG_SIM_TOP)_tb
SIM_ARG					:=

#list
#LST_SYTM		  	:= 0.system.f
LST_VHDL		  := 0.system_vhdl.f
LST_SYSV		  := 0.system_sv.f
#LST_TOP		  	:= 0.top_filelist.f

# directories
DIR_VCS_HOME   := /opt/synopsys/vcs/Q-2020.03-SP2-7
DIR_VERDI_HOME := /opt/synopsys/verdi/R-2020.12-SP1
DIR_RTL_ROOT	 := $(MY_HOME)/project/riscv_workspace/1-rtl
DIR_LST_ROOT	 := $(MY_HOME)/project/riscv_workspace/1-rtl/file_list


#FSDB_MAX_VAR_ELEM := 3000000
# options
OPT_VCS         := -full64 -override_timescale=1ns/1ps -top $(CFG_SIM_TOP) +vcs+lic+wait +notimingchecks +nospecify +vpi \
							     -P $(DIR_VERDI_HOME)/share/PLI/VCS/LINUX64/verdi.tab $(DIR_VERDI_HOME)/share/PLI/VCS/LINUX64/pli.a -l vcs.log
OPT_VCS         += -LDFLAGS -rdynamic
OPT_VCS         += +lint=TFIPC-L -error=IWNF

#add for picorv32
PICORV32_OPT    := +trace +verbose +noerror +verdi +plusarg_save +define+COMPRESSED_ISA

#add
#OPT_VCS         += +plusarg_save +verbose +verdi

#OPT_VCS         += +plusarg_save +verbose +bootmode=fast_debug_preload +fsdb+max_var_elem=30000000
#+stimuli=./vectors/stim.txt
#+bootmode=jtag +jtag_openocd
#fast_debug_preload

# commands
#CMD_VCS_VHDL_ANA      := $(DIR_VCS_HOME)/bin/vhdlan -full64 -functional_vital
CMD_VCS_VHDL_ANA      := $(DIR_VCS_HOME)/bin/vhdlan -full64

CMD_VCS_VLOG_ANA      := $(DIR_VCS_HOME)/bin/vlogan -full64 +v2k
CMD_VCS_VLOG_ANA      += +define+FSDBDUMP -timescale=1ns/10ps
CMD_VCS_VLOG_ANA      += -debug_access+all +vcs+lic+wait +lint=PCWM

CMD_VCS_SYSV_ANA      := $(DIR_VCS_HOME)/bin/vlogan -full64 -sverilog
CMD_VCS_SYSV_ANA      += +define+TARGET_SIMULATION  +define+TARGET_VCS
CMD_VCS_SYSV_ANA      += -assert svaext -debug_acc+pp
#add for picorv32
CMD_VCS_SYSV_ANA      += $(PICORV32_OPT)


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
#
export ROOT        			= $(MY_HOME)/project/riscv_workspace
export RTL_ROOT    			= $(DIR_RTL_ROOT)
export LST_ROOT    			= $(DIR_LST_ROOT)

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

## Compile RTL with Questasim
all: lib build opt

# build the bitbang library, needed for simulating a jtag bridge to OpenOCD
.PHONY: build-deps
build-deps:
	$(MAKE) -C ../1-rtl/tb/remote_bitbang all

.PHONY: clean-deps
clean-deps:
	$(MAKE) -C ../1-rtl/tb/remote_bitbang clean

## vsim targets
.PHONY: sim
## Simulate RTL with Questasim (GUI)
sim:
	$(VSIM) -64 -gui vopt_tb \
		$(VSIM_SUPPRESS) \
		+UVM_NO_RELNOTES -stats -t ps \
		-sv_lib $(SVLIB) $(VSIM_FLAGS) \
		-do "set StdArithNoWarnings 1; set NumericStdNoWarnings 1"

.PHONY: simc
## vsim targets

.PHONY: cvcs
cvcs: sim_vcs cverdi


.PHONY: sim_vcs
## Simulate RTL with VCS (GUI)
sim_vcs: ana_vcs elb_vcs
	@echo "*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*"
	@echo ".                                                                   ."
	@echo ". #SIMTAG#   simulating                                             ."
	@echo ".                                                                   ."
	@echo "*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*"
	$(CMD_SIMV)
.PHONY: ana_vcs
## ana filelist
ana_vcs:
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/0.share.vlog.f
	$(CMD_VCS_VLOG_ANA) -work work -file $(DIR_LST_ROOT)/0.macro.bhvr.f
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/1.dip_sp_ram.f
ifeq ($(CFG_SIM_TOP), sim_soc)
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/soc_top.f
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/sim_soc.f
endif
ifeq ($(CFG_SIM_TOP), canny_tb)
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/mdl_canny.f
endif
ifeq ($(CFG_SIM_TOP), sim_sync_fifo)
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/1.dip_sync_fifo.f
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/2.mdl_sync_fifo.f
endif
ifeq ($(CFG_SIM_TOP), sim_async_fifo)
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/1.dip_async_fifo.f
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/2.mdl_async_fifo.f
endif
ifeq ($(CFG_SIM_TOP), testbench)
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/1.dip_picorv32.f
	$(CMD_VCS_SYSV_ANA) -work work -file $(DIR_LST_ROOT)/2.mdl_picorv32.f
endif


.PHONY: elb_vcs
## elaborate
elb_vcs:
	$(CMD_VCS_ELB)

.PHONY: verdi
## Simulate RTL wave with verdi (GUI)
verdi: cverdi
	@echo "*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*"
	@echo ".                                                                   ."
	@echo ". #SIMTAG#   creating Verdi                                         ."
	@echo ".                                                                   ."
	@echo "*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*"
ifeq ($(CFG_SIM_TOP), sim_soc)
	@$(CMD_VERDI_ALIAS) -lib work.verdi -top sim_soc -output    extracted.src_alias
	@$(CMD_VERDI)       -lib work.verdi -top sim_soc -aliasFile extracted.src_alias  &
endif
ifeq ($(CFG_SIM_TOP), canny_tb)
	@$(CMD_VERDI_ALIAS) -lib work.verdi -top canny_tb -output    extracted.src_alias
	@$(CMD_VERDI)       -lib work.verdi -top canny_tb -aliasFile extracted.src_alias  &
endif
ifeq ($(CFG_SIM_TOP), sim_sync_fifo)
	@$(CMD_VERDI_ALIAS) -lib work.verdi -top sim_sync_fifo -output    extracted.src_alias
	@$(CMD_VERDI)       -lib work.verdi -top sim_sync_fifo -aliasFile extracted.src_alias  &
endif
ifeq ($(CFG_SIM_TOP), sim_async_fifo)
	@$(CMD_VERDI_ALIAS) -lib work.verdi -top $(CFG_SIM_TOP) -output    extracted.src_alias
	@$(CMD_VERDI)       -lib work.verdi -top $(CFG_SIM_TOP) -aliasFile extracted.src_alias  &
endif
ifeq ($(CFG_SIM_TOP), testbench)
	@$(CMD_VERDI_ALIAS) -lib work.verdi -top $(CFG_SIM_TOP) -output    extracted.src_alias
	@$(CMD_VERDI)       -lib work.verdi -top $(CFG_SIM_TOP) -aliasFile extracted.src_alias  &
endif


cverdi:
#	@$(CMD_VERDI_VHDL_COM) -lib work.verdi -2000 -file $(DIR_RTL_ROOT)/sim/$(LST_VHDL)
#	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv   -file $(DIR_RTL_ROOT)/sim/$(LST_SYSV)
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv  -file $(DIR_LST_ROOT)/0.macro.bhvr.f
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv  -file $(DIR_LST_ROOT)/0.share.vlog.f
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv  -file $(DIR_LST_ROOT)/1.dip_sp_ram.f
ifeq ($(CFG_SIM_TOP), sim_soc)
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv  -file $(DIR_LST_ROOT)/soc_top.f
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv  -file $(DIR_LST_ROOT)/sim_soc.f
endif
ifeq ($(CFG_SIM_TOP), canny_tb)
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv -file $(DIR_LST_ROOT)/mdl_canny.f
endif
ifeq ($(CFG_SIM_TOP), sim_sync_fifo)
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv -file $(DIR_LST_ROOT)/1.dip_sync_fifo.f
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv -file $(DIR_LST_ROOT)/2.mdl_sync_fifo.f
endif
ifeq ($(CFG_SIM_TOP), sim_async_fifo)
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv -file $(DIR_LST_ROOT)/1.dip_async_fifo.f
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv -file $(DIR_LST_ROOT)/2.mdl_async_fifo.f
endif
ifeq ($(CFG_SIM_TOP), testbench)
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv -file $(DIR_LST_ROOT)/1.dip_picorv32.f
	@$(CMD_VERDI_VLOG_COM) -lib work.verdi -sv -file $(DIR_LST_ROOT)/2.mdl_picorv32.f
endif
run_prim:
	./run_prim_assert

.PHONY: simc
## Simulate RTL with Questasim
simc:
	$(VSIM) -64 -c vopt_tb \
		$(VSIM_SUPPRESS) \
		+UVM_NO_RELNOTES -stats -t ps \
		-sv_lib $(SVLIB) $(VSIM_FLAGS) \
		-do "set StdArithNoWarnings 1; set NumericStdNoWarnings 1" \
		-do "run -all" \
		-do "quit -code [examine -radix decimal sim:/tb_pulp/exit_status]"

.PHONY: opt
opt:
	$(VOPT) $(VOPT_FLAGS) -o vopt_tb $(SIM_TOP) -work work

.PHONY: opt
build: build-deps
	$(VSIM) -c -do 'source compile.tcl; quit'

.PHONY: lib
lib:

.PHONY:clrvcs
clrvcs:
	@echo "*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*"
	@echo ".                                                                   ."
	@echo ". #SIMTAG#   clean vcs                                              ."
	@echo ".                                                                   ."
	@echo "*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*"
	@-rm -rf work simv.daidir csrc DVEfiles .vdbg_combination_lock RCORE_log.eis
	@-rm -f simv ucli.key .vlogansetup.args .vlogansetup.env
	@-rm -f $(CFG_ROM_INIT_FILE) $(CFG_0RCORE_INIT_FILE) $(CFG_SPI_INIT_FILE)

.PHONY:clrverdi
clrverdi:
	@echo "*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*"
	@echo ".                                                                   ."
	@echo ". #SIMTAG#   clean verdi                                            ."
	@echo ".                                                                   ."
	@echo "*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*'*'*-.,_,.-*-.,_,.-*"
	@-rm -rf verdiLog vericomLog vhdlcomLog work.verdi.lib++ novas.conf novas_dump.log
	@-rm -rf aliasextractLog extracted.src_alias

.PHONY: clean
## Remove all compiled RTL
clean: clean-deps clrvcs clrverdi
	$(RM) -r work
	$(RM) modelsim.ini
	rm -rf ./fsdb/$(SIM_TOP).fsdb
	rm -rf 64 simv.daidir verdiLog vericomLog vhdlcomLog AN.DB
	rm -rf novas* simv work.* .vhdl_* vcs.log vc_hdrs.h debug.log

.PHONY: vclean
## Remove all compiled RTL
vclean: clrvcs clrverdi
	$(RM) -r work
	$(RM) modelsim.ini
	#rm -rf ./fsdb/$(SIM_TOP).fsdb
	rm -rf 64 simv.daidir verdiLog vericomLog vhdlcomLog AN.DB
	rm -rf novas* simv work.* .vhdl_* vcs.log vc_hdrs.h debug.log
