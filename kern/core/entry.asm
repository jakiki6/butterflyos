	org 0x230000

global KernelEntry
KernelEntry:
	; setup registers
	sps 0x400000 drop
	srs 0x3f0000 drop.r

	; set bp to be equal to the stack
	0 sbp drop

	call SymSetup
	call SerialSetup
	call FramebufferInit

.loop:	0xff 0xff 0xff
	call RngOne FramebufferCfg.width ldw mod
	call RngOne FramebufferCfg.height ldw mod
	call FramebufferDrawPixel
	jmp .loop

.hlt:	hlt
