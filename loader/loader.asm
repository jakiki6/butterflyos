	org 0x7c00
	bits 16

jmp stage1

times 58 db 0x69

stage1:
	cli
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
	mov ax, 0x4f65
	mov cx, 0x07d0
	rep stosw

.inst:	xor ax, ax
	int 0x16

	cmp al, 'r'
	je .reboot
	cmp al, 'p'
	je .poweroff
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

times 256 - ($ - $$) nop

drive:	db 0

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
dw 0xaa55
