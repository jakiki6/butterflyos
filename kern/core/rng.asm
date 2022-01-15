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
	call RngHw 1 shr 0xff and ret

global RngSeed
RngSeed:
	word
