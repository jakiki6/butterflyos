global MmInit
MmInit:	0x410000 MmPtr stw
	ret

global MmAlloc
MmAlloc:
	MmPtr ldw
	MmPtr ldw swap add MmPtr stw
	ret

global MmFree
MmFree:	ret

global MmPtr
MmPtr:	word
