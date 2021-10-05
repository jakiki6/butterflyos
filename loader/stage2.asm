org 0xa000

%define PAGING_BUFFER 0x4000

stage2:	mov ax, 640
	mov bx, 480
	mov cl, 8
	call vbe_set_mode
	mov bp, errors.vesa
	jc error

	mov eax, dword [0x7c00 + 12]	; total blocks
	shl eax, 3			; times sizeof(uint64_t)
	add eax, dword [0x7c00 + 28]	; plus block size
	sub eax, 1			; minus 1
	div dword [0x7c00 + 28]		; divided by the block size
	add eax, 16			; allocation table starts at block 16

	mov dword [directory_start], eax

	mov dword [DAP.lba_lower], eax	; read first sector of directory
	mov word [DAP.offset_segment], 0
	mov word [DAP.offset_offset], buffer

	push ax
	mov ah, 0x42
	mov dl, byte [0x7d00]
	mov si, DAP

	mov bp, errors.read_directory
	clc
	int 0x13
	pop ax
	jc error

	mov bx, 0
	mov bp, errors.find_directory

	mov eax, dword [directory_start]
	jmp .proc

.next:	add bx, 256
	cmp bh, 1
	jne .skip
	inc dword [DAP.lba_lower]
	xor bx, bx

.skip:	push ax
	mov ah, 0x42
	mov dl, byte [0x7d00]
	mov si, DAP

	clc
	int 0x13
	pop ax
	jc error

.proc:	cmp dword [bx+buffer], 0	; end of directory?
	je error
					; normal entry?
	cmp dword [bx+buffer], 0xfffffffd
	je .next

					; deleted entry?
	cmp dword [bx+buffer], 0xfffffffe
	je .next

	cmp byte [bx+buffer+8], 0	; file?
	jne .next

	mov si, buffer + 9		; is filename our kernel?
	mov di, kernel_name
	call strcmp
	jc .next

	mov eax, dword [bx+buffer+240]	; read starting block
	mov cx, 0			; pointer to other buffer

.rd:	mov dword [DAP.lba_lower], eax
	mov word [DAP.offset_segment], 0x1000
	mov word [DAP.offset_offset], cx

	push ax
	mov ah, 0x42
	mov dl, byte [0x7d00]
	mov si, DAP

	mov bp, errors.read_block
	clc
	int 0x13
	pop ax
	jc error

	add cx, 512

	mov ebx, eax
	shr eax, 6			; get index in allocation table
	add eax, 16

	mov dword [DAP.lba_lower], eax
	mov word [DAP.offset_segment], 0
	mov word [DAP.offset_offset], buffer
	
	push ax
	mov ah, 0x42
	mov dl, byte [0x7d00]
	mov si, DAP

	mov bp, errors.read_chain
	clc
	int 0x13
	pop ax
	jc error

	and ebx, 63			; mask to index in sector
	shl ebx, 3			; times size of qword
	add ebx, buffer			; get index in buffer

	mov eax, dword [ebx]
	mov ebx, eax

	mov bp, errors.found_reserved_block
	cmp eax, 0xfffffff0
	je error

	cmp eax, 0xffffffff
	je .done

	shr ebx, 6			; read chain table
	add ebx, 16
	mov dword [DAP.lba_lower], ebx
	push ax
	mov ah, 0x42
	mov dl, byte [0x7d00]
	mov si, DAP

	mov bp, errors.read_chain
	clc
	int 0x13
	pop ax
	jc error

	jmp .rd

.done:
	in al, 0x92			; enable A20 line
	or al, 0x02
	out 0x92, al

	cli
	mov al, 0xff			; disable all irqs
	out 0xa1, al
	out 0x21, al

	lidt [idt]			; load empty idt
	lgdt [gdt.desc]			; load gdt

	mov eax, cr0
	or eax, 1			; enable protection
	mov cr0, eax

	jmp 0x08:pmode			; JUMP (and survive ig)

	align 8
gdt:
.null:	dd 0, 0
.code:	db 0xff, 0xff, 0, 0, 0, 10011010b, 11001111b, 0
.data:	db 0xff, 0xff, 0, 0, 0, 10010010b, 11001111b, 0
.desc:
	dw gdt.desc - gdt - 1
	dd gdt

	bits 32
pmode:	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	jmp 0x10000

	bits 16
error:
	mov ah, 0x0e
	mov bx, 0x0007
	mov si, bp

.loop:	lodsb
	cmp al, 0
	je .hlt
	int 0x10
	jmp .loop

.hlt:	cli
	hlt
	jmp .hlt

strcmp:	cmp byte [si], 0
	jne .1
	cmp byte [di], 0
	je .success
	jmp .error
.1:	cmpsb
	je strcmp

.error:	stc
.success:
	ret

DAP:
.header:
    db 0x10     ; header
.unused:
    db 0x00     ; unused
.count:  
    dw 0x0001   ; number of sectors
.offset_offset:   
    dw buffer   ; offset
.offset_segment:  
    dw 0x0000   ; offset
.lba_lower:
    dd 0	; lba
.lba_upper:
    dd 0	; lba
.end:


kernel_name:
	db "kernel.bin", 0

directory_start:
	dd 0

buffer:	equ 0xf000

errors:
.read_directory:
	db "Cannot read the directory", 0x0a, 0x0d, 0
.find_directory:
	db "Error while finding file in directory", 0x0a, 0x0d, 0
.read_block:
	db "Error while reading a block", 0x0a, 0x0d, 0
.read_chain:
	db "Error while reading a chain entry", 0x0a, 0x0d, 0
.found_reserved_block:
	db "Found reserved block while reading chain", 0x0a, 0x0d, 0
.vesa:
	db "Your system doesn't seem to support VESA", 0x0a, 0x0d, 0

idt:	dw 0
	dd 0

%include "vesa.asm"
