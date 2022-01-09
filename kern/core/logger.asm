global LogInfoNNl
LogInfoNNl:
	call SerialWriteString
	.sep call SerialWriteString
	call SerialWriteString
	ret
.sep:	db ": ", 0x00

global LogInfo
LogInfo:
	call LogInfoNNl
	call LogNl
	ret

global LogAppend
LogAppend:
	call SerialWriteString
	ret

global LogNl
LogNl:
	0x0a call SerialWriteChar
	ret
