	org 0x200000
	setps 0x400000
	setrs 0x3f0000
; memory layout:
;   0x00100000-0x001f0000: vm code
;   0x001f0000-0x00200000: configuration for vm (handlers etc.)
;     0x001f0000: brk handler ip
;     0x001f0004: dei handler ip
;     0x001f000c: deo handler ip
;   0x00200000-0x00300000: kernel reserved space
;   0x00300000-0xffffffff: memory

global _start
_start: jmp $
