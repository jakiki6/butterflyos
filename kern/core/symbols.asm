global SymSetup
SymSetup:
	; setup pointer
	_EmptyEntry SymPtr stw
	ret

global SymPtr
SymPtr:	word

_EmptyEntry:
	; format:
	;   4 bytes: next (0 -> no next, abort)
	;   n bytes: name (null terminated)
	;   4 bytes: address

.next:	dw 0	; no next
.name:	db 0	; empty name
.addr:	dw 0	; why would you even read this
		; subscribe to technoblade and dwaddy dweam uwu
