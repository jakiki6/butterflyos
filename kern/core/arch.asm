global ArchOutB
ArchOutB:
	.bin native ret
.bin:	db 0x52, 0x8b, 0x55, 0x00, 0x83, 0xc5, 0x04, 0x8b, 0x45, 0x00, 0x83, 0xc5, 0x04, 0xee, 0x5a, 0xc3

global ArchInB
ArchInB:
	.bin native ret
.bin:	db 0x52, 0x8b, 0x55, 0x00, 0x83, 0xc5, 0x04, 0xec, 0x25, 0xff, 0x00, 0x00, 0x00, 0x00, 0x83, 0xed, 0x04, 0x89, 0x45, 0x00, 0x5a, 0xc3
