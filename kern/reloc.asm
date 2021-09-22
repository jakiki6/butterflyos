	bits 32
	org 0x10000

_start:	mov esi, vm
	mov edi, 0x200000
	mov ecx, vm.end - vm
	rep movsb

	jmp 0x200000

vm:	incbin "vm.bin"
.end:
