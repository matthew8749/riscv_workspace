# SoC
### Memory map:
<!-- 原pulp的表個，先留這註解，參考用
| Address Range              | Description                             |
| -------------------------- | --------------------------------------- |
| 0x0000_0000 .. 0x000F_FFFF | Internal SRAM                           |
| 0x0100_0000 .. 0x01FF_FFFF | External Serial Flash                   |
| 0x0200_0000 .. 0x0200_0003 | SPI Flash Controller Config Register    |
| 0x0200_0004 .. 0x0200_0007 | UART Clock Divider Register             |
| 0x0200_0008 .. 0x0200_000B | UART Send/Recv Data Register            |
| 0x0300_0000 .. 0xFFFF_FFFF | Memory mapped user peripherals          |
-->


| Address Range              | Description                             | Size      |
| -------------------------- | --------------------------------------- | --------- |  
| 0x0000_0000 .. 0x000F_FFFF | ROM0 (program)                          | 1     MB  |
| 0x0010_0000 .. 0x0010_FFFF | AXI Register File (REGF0)               | 64    KB  |
| 0x0011_0000 .. 0x0011_FFFF | APB_Bus                                 | 64    KB  |
| 0x0012_0000 .. 0x0013_FFFF | RAM1 : u0_axi_lite_memory               | 128   KB  |
| 0x0014_0000 .. 0x~~~~~~~~~ | ** unUSED                               |           |
| 0x4000_0000 .. 0x412B_FFFF | IMP MEM : IMP read Memory (16frames)    | 18.75 MB  |

#
```txt
這邊預設一個pixel有4byte , 一個地址佔1byte
frame     : 640*480 = 307200(pixels = 4bytes = ARGB888)           = 1228800 bytes = 1.171 MB
BRAM(MAX) : addr(2^17) * data(4bytes = 32bits) = 131072 * 4 bytes = 524288  bytes = 512 KB

524288(dec) bytes = 80000(hex) bytes

1228800*16(frame) / 524288 = 37.5 
so 16 frames need 38 BRAMs

19660800 bytes (640*480 *16 frames space)
19660800 (dec) = 12C_0000(hex) 

如果Base Addr = 0x4000_0000
地址範圍 : 0x4000_0000 ~ 0x412B_FFFF
```

> NOTE:
> 
> - 資料寬度：
>   
>       當 SoC 去讀取記憶體時，通常一次會抓取 32 bits（4 bytes）。
>
>       在硬體實作（如 Verilog）中，你可能會看到 mem[0] 裡面就存了一個像素（32 bits）。
> 
> - 軟體角度：
>
>       在 C 語言中，如果你定義 uint32_t *p，
>
>       當你執行 p++ 時，指針數值雖然增加了 1，
>
>       但實際上的物理地址增加了 4。


# BACKBONE Address Map
```txt
BACKBONE Address Map (Complete System)
===========================================
0xFFFF_FFFF  ┌─────────────────────────────┐
             │  unUSED                     │
             │                             │
             │                             │
             │                             │
             │                             │
             │                             │
0x412C_0000  ├─────────────────────────────┤
0x412B_FFFF  │                             │
             │  IMP MEM(r)                 │
             │  (IMP read Memory)          │
             │  (19660800 bytes)           │
             │  (640*480 *16 frames space) │
             │                             │
             │                             │
0x4000_0000  ├─────────────────────────────┤
             │ unUSED                      │
             │                             │
             │                             │
             │                             │
0x0014_0000  ├─────────────────────────────┤
0x0013_FFFF  │                             │
             │   RAM1                      │
             │   (u0_axi_lite_memory)      │
             │   (128 KB)                  │
             │                             │
             │                             │
0x0012_0000  ├─────────────────────────────┤ 
0x0011_FFFF  │   APB_Bus                   │ But ID is the last always  
             │   (64 KB)                   │ 
             │                             │
0x0011_0000  ├─────────────────────────────┤
0x0010_FFFF  │   REGF0                     │
             │   (AXI Register File)       │
             │   (64 KB)                   │
             │                             │
0x0010_0000  ├─────────────────────────────┤
0x000F_FFFF  │                             │
             │                             │
             │                             │
             │  ROM0 (program)             │
             │  (Main Memory)              │
             │  (1 MB)                     │
             │                             │
             │                             │
             │                             │
0x0000_0000  └─────────────────────────────┘

```
# AXI REGF0 Address Map
```txt
      ---------------------- 0x0010_FFFF
      |
      |
      |
      |
      |
      |
      |
      |
      |
REGF0 ---------------------- 0x0010_0000

```

# APB BUS Address Map
```txt
    ---------------------- 0x0011_FFFF
    |
    |
    |
    |
    |
    |
    |
    |
    |
APB ---------------------- 0x0011_0000
```



