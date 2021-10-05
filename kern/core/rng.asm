global RngInit
RngInit:
	RngHw RngSeed stw
	ret

global RngOne
RngOne:	RngSeed ldw
	0x0000b0fd mul
	0x0000f32d add
	dup RngSeed stw
	12 shl
	ret

global RngHw
RngHw:	.bin native ret
.bin:	db 0x52, 0x0f, 0x31, 0x5a, 0x83, 0xed, 0x04, 0x89, 0x45, 0x00, 0xc3

global RngSeed
RngSeed:
	word
