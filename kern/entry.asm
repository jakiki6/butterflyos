	org 0x210000

	setps 0x400000
	setrs 0x3f0000
; memory layout:
;   0x00210000-0x002f0000: vm code
;   0x002f0000-0x00300000: reserved space for kernel
;   0x00300000-0xffffffff: memory

global _start
_start: jmp $
