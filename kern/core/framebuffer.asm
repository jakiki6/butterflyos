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
	; (r=4, g=3, b=2, x=1, y=0) -> ()
	0 sbp

	; pos = ((y * bpl + (x * 3)) + fbase
	#0 srel ldw		; y
	FbCfg.bpl ldw mul	; * bpl
	#1 srel ldw 3 mul add	; + (x * 3)
	FbCfg.buf ldw add	; + fbase

	dup #4 srel ldw swap stb 1 add
	dup #3 srel ldw swap stb 1 add
	dup #2 srel ldw swap stb drop

	#5 #0 leave ret

global FbDrawBlock
FbDrawBlock:
	; (r=6, g=5, b=4, x1=3, y1=2, x2=1, y2=0) -> ()
	0 sbp

	#2 srel ldw	; y
.yl:	#3 srel ldw	; x
.xl:	#6 ldw
	#5 ldw
	#4 ldw
	%2 ldw
	%1 ldw
;	call FbDrawPixel
	5 call DumpStack
	1 add
	dup #1 neq jmpc .xl
	drop
	1 add
	dup #0 neq jmpc .yl
	drop

	#7 #0 leave ret


global FbDrawLine
FbDrawLine:
	; (r=6, g=5, b=4, x1=3, x2=2, y1=1, y1=0) -> ()
	0 sbp

	#7 #0 leave ret

global FbCfg
FbCfg:
.width:	dw 0
.height:
	dw 0
.buf:	dw 0
.bpl:	dw 0
