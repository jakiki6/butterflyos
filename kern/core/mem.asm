global MemInit
MemInit:
	0x410000 MemPtr stw
	ret

global MemAlloc
MemAlloc:
	MemPtr ldw
	MemPtr ldw swap add MemPtr stw
	ret

global MemFree
MemFree:	ret

global MemPtr
MemPtr:	word
