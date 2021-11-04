	org 0x7c00
	bits 16

jmp stage1

times 58 db 0x69

stage1:	cli
	xor ax, ax
	xor bx, bx
	xor cx, cx
	mov byte [drive], dl
	xor dx, dx
	xor si, si
	xor di, di

	push 0x2000
	pop ss
	mov esp, 0xffff
	
	push cs
	pop ds
	push cs
	pop es
	push cs
	pop gs
	push cs
	pop fs

	sti

	mov ah, 0x01
        mov cx, 0x2607
        int 0x10

        mov ah, 0x02
        xor bx, bx
        xor dx, dx
        int 0x10

.load_all:
	mov ah, 0x42
	mov dl, byte [drive]
	mov si, DAP

	clc
	int 0x13
	jc error

	inc dword [0xa002]

	mov ah, 0x43
	int 0x13

	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor dx, dx
	xor si, si
	xor di, di
	xor bp, bp

	jmp 0xa000

error:	push 0xb800
	pop es
	xor di, di
	mov ax, 0x4f20
	mov cx, 0x07d0
	rep stosw

	mov si, .msg
	call print

.inst:	xor ax, ax
	int 0x16

	cmp al, 'r'
	je .reboot
	cmp al, 'p'
	je .poweroff
	cmp al, 'd'
	je .diagnostic
	cmp al, 'c'
	je .chainload
	cmp al, ' '
	je .continue
	jmp .inst

.reboot:
	jmp 0xffff:0x0000
.continue:
	int 0x18
.poweroff:
	mov ax, 0x5301
	xor bx, bx
	int 0x15

	mov ax, 0x530e
	xor bx, bx
	mov cx, 0x0102
	int 0x15

	mov ax, 0x5307
	mov bx, 0x0001
	mov cx, 0x0003
	int 0x15

	jmp .inst
.diagnostic:
	mov dl, byte [drive]
	mov ah, 0x01
	int 0x13

	mov dl, ah
	mov ah, 0x0e

	mov al, dl
	shr al, 4
	mov bx, .table
	xlat

	mov bx, 0x0007
	int 0x10

	mov al, dl
	and al, 0x0f
	mov bx, .table
	xlat

	mov bx, 0x0007
        int 0x10

	mov al, 0x0a
	int 0x10
	mov al, 0x0d
	int 0x10

	jmp .inst
.chainload:
	mov di, 0xa000
.loop:	call read_one
	mov bl, al

	call read_one
	shl bl, 4
	or al, bl

	stosb

	mov ax, 0x0e00 | '.'
	mov bx, 0x0007
	int 0x10

	jmp .loop
	
.msg:	db "Error while loading stage2", 0x0a, 0x0d, "Actions: (r)eboot, (p)oweroff, (d)iagnostic, (c)hainload or continue (space)", 0x0a, 0x0d, 0x00
.table:	db "0123456789abcdef"

print:	mov ah, 0x0e
	mov bx, 0x0007
.print:	lodsb
	cmp al, 0x00
	je .ret
	int 0x10
	jmp .print
.ret:	ret

read_one:
	xor ax, ax
	int 0x16

	cmp al, 0x0d
	je .boot

	sub al, 'a'

	ret
.boot:	mov si, .msg
	call print
	jmp 0xa000
.msg:	db 0x0a, 0x0d, "jumping ...", 0x0a, 0x0d, 0x00

DAP:
.header:
    db 0x10	; header
.unused:
    db 0x00     ; unused
.count:  
    dw 0x000f   ; number of sectors
.offset_offset:
    dw 0xa000	; offset
.offset_segment:
    dw 0x0000   ; offset
.lba_lower:
    dq 1	; lba
.lba_upper:
    dq 0	; lba
.end:

times 510 - ($ - $$) nop
drive:	equ $
dw 0xaa55
