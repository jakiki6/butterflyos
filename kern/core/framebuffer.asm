global FramebufferInit
FramebufferInit:
	0x202008 ldw FramebufferCfg.width stw
	0x202010 ldw FramebufferCfg.height stw
	0x202018 ldw FramebufferCfg.buf stw
	0x202020 ldw FramebufferCfg.bpl stw

	FramebufferCfg.buf ldw
.loop:	dup call RngOne swap stb
	1 add swap 1 sub swap
	jmp .loop

.ret:	ret

global FramebufferCfg
FramebufferCfg:
.width:	dw 0
.height:
	dw 0
.buf:	dw 0
.bpl:	dw 0
