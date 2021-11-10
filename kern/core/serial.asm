global SerialSetup
SerialSetup:
	ret

is_transmit_empty:
	0x03fd	; port
	call ArchInB
	0x20 and
	ret

global SerialWriteChar
SerialWriteChar:
	call is_transmit_empty
	0 eq jmpc SerialWriteChar

	0x03f8	; port
	call ArchOutB
	ret

global SerialWriteString
SerialWriteString:
	dup ldb
	dup 0 eq jmpc .done
	call SerialWriteChar
	1 add
	jmp SerialWriteString

.done:	drop drop ret
