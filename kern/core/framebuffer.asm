global FramebufferInit
FramebufferInit:
	0x202004 ldw FramebufferCfg.width stw
	0x202008 ldw FramebufferCfg.height stw
	0x20200c ldw FramebufferCfg.buf stw
	0x202010 ldw FramebufferCfg.bpl stw

	FramebufferCfg.buf ldw
.loop:	dup 0xff swap stb
	1 add
	jmp .loop

global FramebufferCfg
FramebufferCfg:
.width:	dw 0
.height:
	dw 0
.buf:	dw 0
.bpl:	dw 0
