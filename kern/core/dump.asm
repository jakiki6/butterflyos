global DumpStack
DumpStack:
	.msg call SerialWriteString

	sth

.loop:	call DumpWord
	sth.r 1 sub
	dup 0 eq jmpc DumpHalt
	sth
	jmp .loop
.msg:	db "DUMP -- STACK", 0x0a, 0x00

global DumpHalt
DumpHalt:
	.msg call SerialWriteString
	hlt
.msg:	db "DUMP -- HALT", 0x0a, 0x00

global DumpWord
DumpWord:
	dup 56 shr call DumpByte
	dup 48 shr call DumpByte
	dup 40 shr call DumpByte
	dup 32 shr call DumpByte
	dup 24 shr call DumpByte
	dup 16 shr call DumpByte
	dup 8 shr call DumpByte
	call DumpByte
	0x0a call SerialWriteChar
	ret

global DumpByte
DumpByte:
	0xff and
	dup 4 shr .table add ldb call SerialWriteChar
	0x0f and .table add ldb call SerialWriteChar
	ret
.table:	db "0123456789abcdef"
