	bits 64
	org 0x10000

%include "vm/header.asm"

_start: call .ip
.ip:	pop rsi
	add rsi, vm - .ip
	mov rdi, 0x200000
	mov rcx, vm.end - vm
	rep movsb

	jmp 0x200000

vm:	incbin "vm.bin"
.end:
