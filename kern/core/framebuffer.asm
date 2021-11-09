global FramebufferInit
FramebufferInit:
	0x202008 ldw FramebufferCfg.width stw
	0x202010 ldw FramebufferCfg.height stw
	0x202018 ldw FramebufferCfg.buf stw

	0x202020 ldw
	FramebufferCfg.width ldw 3 mul add
	FramebufferCfg.bpl stw

.ret:	ret

global FramebufferDrawPixel
FramebufferDrawPixel:
	; (r, g, b, x, y) -> ()
	0 sbp

	; pos = ((y * bpl + (x * 3)) + fbase
	0 srel ldw			; y
	FramebufferCfg.bpl ldw mul	; * bpl
	8 srel ldw 3 mul add		; + (x * 3)
	FramebufferCfg.buf ldw add	; + fbase

	dup 32 srel ldw swap stb 1 add
	dup 24 srel ldw swap stb 1 add
	dup 16 srel ldw swap stb drop

	swap drop swap drop swap drop swap drop swap drop

	sbp drop ret

global FramebufferCfg
FramebufferCfg:
.width:	dw 0
.height:
	dw 0
.buf:	dw 0
.bpl:	dw 0
