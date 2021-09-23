	bits 32
	org 0x200000

start:	mov esp, 0x1f0000

	mov esi, kernel_file

	; check magic
	lodsd
	cmp eax, 0x6f6a6262
	jne error

	; number of sections
	lodsd
	push eax

.section:
	; origin
	lodsd
	mov edi, eax

	; length of binary
	lodsd
	mov ecx, eax

	; move
	rep movsb

	; skip over relocations since they're not relevant for out kernel
	lodsd
	shl eax, 2
	add esi, eax

	; read symbols and panic if we encounter a 0x00 type
	lodsd
	push eax

.syms:	; read type
	lodsb

	; check type
	cmp al, 0x00
	je error

	; skip over address
	lodsd

	; skip over name
.sn:	lodsb
	cmp al, 0x00
	jne .sn

	; loop
	pop eax
	push eax

	dec eax
	cmp eax, 0
	jne .syms

	; drop value on the stack
	pop eax

	jmp $

error:	lidt [.fake_idt]
	int 0x69
.fake_idt:
	dw 0
	dd 0

kernel_file:
	incbin "main.o"
