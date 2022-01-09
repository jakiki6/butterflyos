global IdtInit
IdtInit:
	; 16 * 256 bytes -> 256 entries
	4096 call MmAlloc
	IdtEntriesPtr stw

	; copy
	IdtEntriesPtr ldw
	IdtDesc stw

	; load it
;	IdtDesc call ArchLIdt

	ret
global IdtDesc
IdtDesc:
	dw 0
	ddb 0xffff
global IdtEntriesPtr
IdtEntriesPtr:
	word
