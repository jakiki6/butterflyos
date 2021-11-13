global SymInit
SymInit:
	; setup pointer
	_EmptyEntry SymPtr stw
	ret

global SymPtr
SymPtr:	word

_EmptyEntry:
	; format:
	;   n bytes: name (null terminated)
	;   4 bytes: next (0 -> no next, abort)
	;   4 bytes: address

.name:	db 0	; empty name
.next:	dw 0	; no next
.addr:	dw 0	; why would you even read this
		; subscribe to technoblade and dwaddy dweam uwu
