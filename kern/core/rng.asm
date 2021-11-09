global RngInit
RngInit:
	RngHw RngSeed stw
	ret

global RngOne
RngOne:	0
	8 shl call RngOneByte or
	8 shl call RngOneByte or
	8 shl call RngOneByte or
	8 shl call RngOneByte or
	8 shl call RngOneByte or
	8 shl call RngOneByte or
	8 shl call RngOneByte or
	8 shl call RngOneByte or
	ret
	
global RngOneByte
RngOneByte:
	call RngHw 3 shr 0xff and ret

global RngHw
RngHw:	.bin native ret
.bin:	db 0x0f, 0x31, 0x48, 0xc1, 0xe2, 0x20, 0x48, 0x09, 0xd0, 0x49, 0x83, 0xe8, 0x08, 0x49, 0x89, 0x00, 0xc3

global RngSeed
RngSeed:
	word
