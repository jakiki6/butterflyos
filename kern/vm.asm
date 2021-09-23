	bits 32
	org 0x200000

start:	mov esp, 0x1f0000

	mov esi, kernel_file

	; check magic
	lodsd
	cmp eax, 0x6f6a6262
	jne error

	jmp $

error:	lidt [.fake_idt]
	int 0x69
.fake_idt:
	dw 0
	dd 0

kernel_file:
	incbin "main.o"