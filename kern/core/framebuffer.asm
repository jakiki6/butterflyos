global FramebufferInit
FramebufferInit:
	0x202008 ldw FramebufferCfg.width stw
	0x202010 ldw FramebufferCfg.height stw
	0x202018 ldw FramebufferCfg.buf stw
	0x202020 ldw FramebufferCfg.bpl stw

	FramebufferCfg.buf ldw
.loop:	dup .ptr ldw ldw swap stw
	1 add
	.ptr ldw 1 add .ptr stw
	jmp .loop

.ret:	ret
.ptr:	dw 0xd0000

global FramebufferCfg
FramebufferCfg:
.width:	dw 0
.height:
	dw 0
.buf:	dw 0
.bpl:	dw 0
