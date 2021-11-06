global RngInit
RngInit:
	RngHw RngSeed stw
	ret

global RngOne
RngOne:	call RngOneByte	56 shl
	call RngOneByte 48 shl
	call RngOneByte 40 shl
	call RngOneByte 32 shl
	call RngOneByte 24 shl
	call RngOneByte 16 shl
	call RngOneByte 8 shl
	call RngOneByte

	or or or or or or or
	ret

global RngOneByte
RngOneByte:
	RngSeed ldw
	0x5deece66d mul
	0xb add
	dup RngSeed stw
	17 shr 0xff and
	ret

global RngHw
RngHw:	.bin native ret
.bin:	db 0x0f, 0x31, 0x48, 0xc1, 0xe2, 0x20, 0x48, 0x09, 0xd0, 0x49, 0x83, 0xe8, 0x08, 0x49, 0x89, 0x00, 0xc3

global RngSeed
RngSeed:
	word
