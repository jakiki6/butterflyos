	org 0x210000

; memory layout:
;   0x00210000-0x002f0000: vm code
;   0x002f0000-0x00300000: reserved space for kernel
;   0x00300000-0xffffffff: memory

global KernelEntry
KernelEntry:
	; setup registers
	sps 0x400000
	srs 0x3f0000

	; set bp to be equal to the stack
	0 sbp

	call SymSetup
	call SerialSetup
	call FramebufferInit

.hlt:	hlt
