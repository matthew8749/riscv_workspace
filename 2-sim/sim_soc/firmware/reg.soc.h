typedef volatile unsigned int   UV32;
typedef volatile unsigned short UV16;
typedef volatile unsigned char  UV8;

//================================================================
//   SimCtrl register and message define
//================================================================
// // u0_picorv32_axi
// #define SOC_MEM_MAP_AXI_RAM0_ID              0x0
// #define SOC_MEM_MAP_AXI_RAM0_START_ADDR      0x0000_0000
// #define SOC_MEM_MAP_AXI_RAM0_END_ADDR        0x0001_FFFF
// // u0_axi_lite_memory
// #define SOC_MEM_MAP_AXI_RAM1_ID              0x1
// #define SOC_MEM_MAP_AXI_RAM1_START_ADDR      0x0010_0000
// #define SOC_MEM_MAP_AXI_RAM1_END_ADDR        0x0011_FFFF
// // u0_axi_lite_regs
// #define SOC_MEM_MAP_AXI_REGF0_ID             0x2
// #define SOC_MEM_MAP_AXI_REGF0_START_ADDR     0x0012_0000
// #define SOC_MEM_MAP_AXI_REGF0_END_ADDR       0x0012_FFFF

//#define    SIMCTRL_ADDR_BASE                    (UV32*)0x80000000
//#define    SIMCTRL_ADDR_GENERIC                 (UV32*)0x80000000
//
//#define    SIMCTRL_MSG_SIM_START                0x00000000
//#define    SIMCTRL_MSG_FW_INITIAL               0x11111111
//#define    SIMCTRL_MSG_SIM_PASS                 0x55555555
//#define    SIMCTRL_MSG_SIM_PASSCNT              0x66666666
//#define    SIMCTRL_MSG_SIM_FAIL                 0xaaaaaaaa
//#define    SIMCTRL_MSG_SIM_FINISH               0xffffffff
//#define    SIMCTRL_MSG_SIM_RESET                0xeeeeeeee
//#define    SIMCTRL_MSG_SIM_WAIT                 0x00310031
//#define    SIMCTRL_MSG_SIM_RESUME               0x00311688
//
//#define    SIMCTRL_POST_SIM_FORCE               0x22222222
//#define    SIMCTRL_POST_SIM_RELEASE             0x33333333
