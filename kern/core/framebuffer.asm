global FbInit
FbInit:
	0x202008 ldw FbCfg.width stw
	0x202010 ldw FbCfg.height stw
	0x202018 ldw FbCfg.buf stw

	0x202020 ldw
	FbCfg.width ldw 3 mul add
	FbCfg.bpl stw

.ret:	ret

global FbDrawPixel
FbDrawPixel:
	; (r, g, b, x, y) -> ()
	0 sbp

	; pos = ((y * bpl + (x * 3)) + fbase
	0 srel ldw			; y
	FbCfg.bpl ldw mul	; * bpl
	8 srel ldw 3 mul add		; + (x * 3)
	FbCfg.buf ldw add	; + fbase

	dup 32 srel ldw swap stb 1 add
	dup 24 srel ldw swap stb 1 add
	dup 16 srel ldw swap stb drop

	swap drop swap drop swap drop swap drop swap drop

	sbp drop ret

global FbCfg
FbCfg:
.width:	dw 0
.height:
	dw 0
.buf:	dw 0
.bpl:	dw 0
