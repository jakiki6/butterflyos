global FramebufferInit
FramebufferInit:
	0xa0000
.wipe:	dup call RngOne swap stb
	1 add
	dup 0xc0000 neq jmpc .wipe
	drop ret
