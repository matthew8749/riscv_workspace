/*
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.
*/

/*
整體記憶體是 128KB。
LENGTH = 96KB (0x18000) 指的是分配給程式的部分。
留下來的 32KB（128KB - 96KB）是給 stack 用的，可能在其他段落或用程式碼動態配置。
0x18000 = 98,304(bytes)
98,304 ÷ 1024 = 96 KB
*/

MEMORY {
	/* the memory in the testbench is 128k in size;
	 * set LENGTH=96k and leave at least 32k for stack */
	mem : ORIGIN = 0x00000000, LENGTH = 0x00018000
}

SECTIONS {
	.memory : {
		. = 0x000000;
		start*(.text);
		*(.text);
		*(*);
		end = .;
		. = ALIGN(4);
	} > mem
}


/*   記憶體區域：0x00000000 ~ 0x00020000（128KB）

┌────────────────────────────┐ ← 0x00020000
│         Stack 區塊          │   ↑ 32KB 空出來讓 stack 用
│      手動在 start.S 設定     │   ↓ (sp從這裡往下長)
├────────────────────────────┤ ← 0x00018000
│        可用程式空間          │
│        （96 KB）            │
│ .text, .data, .bss, rodata │
│     全都集中在.memory        │
├────────────────────────────┤ ← 0x00000000

*/