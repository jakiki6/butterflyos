	bits 32
	org 0x200000

SERIAL_PORT: \
	equ 0x03f8

%macro push_ps 1
	sub ebp, 4
	mov dword [ebp], %1
%endmacro
%macro pop_ps 1
	mov %1, dword [ebp]
	add ebp, 4
%endmacro
%macro push_rs 1
        mov dword [edi], %1
        add edi, 4
%endmacro
%macro pop_rs 1
        sub edi, 4
        mov %1, dword [edi]
%endmacro

%macro outb 2
	mov dx, %1
	mov al, %2
	out dx, al
%endmacro
%macro inb 1
	mov dx, %1
	in al, dx
%endmacro

start:	mov esp, 0x1f0000

	call init_serial

	mov esi, kernel_file

	; check magic
	lodsd
	cmp eax, 0x6f6a6262
	jne error

	; entry
	lodsd
	mov dword [entry], eax

	; skip over number of sections
	lodsd

	; origin
	lodsd
	mov edi, eax

	; length of binary
	lodsd
	mov ecx, eax

	; move
	rep movsb

vm:	; registers:
	; esi=pc ebp=ps edi=rs edx=bp

	; setup registers
	mov esi, dword [entry]

.main:	xchg eax, esi
	call write_hex
	xchg eax, esi

	; clean up
	cmp byte [.flag_rs], 1
	jne .flags
	xchg ebp, edi

.flags:	; clean up the flag
	mov byte [.flag_rs], 0

	lodsb
	test al, 0b10000000
	jne .execute
	mov byte [.flag_rs], 1
	xchg ebp, edi

.execute:
	; mask out function
	and al, 0b11111

	; get pointer into function table
	xor ebx, ebx
	mov bl, al
	shl ebx, 2
	add ebx, func_table
	mov ebx, dword [ebx]

	; call it
	push .main
	push ebx
	ret

.flag_rs:
	db 0

eqtoeax:
	; convert equal flag to eax
	jne .no
	mov eax, 1
	ret
.no:	xor eax, eax
	ret

belowtoeax:  
        ; convert below flag to eax
        jnb .no   
        mov eax, 1
        ret
.no:    xor eax, eax
        ret

abovetoeax:  
        ; convert above flag to eax
        jna .no   
        mov eax, 1
        ret
.no:    xor eax, eax
        ret

error:	lidt [.fake_idt]
	int 0x69
.fake_idt:
	dw 0
	dd 0

init_serial:
	outb SERIAL_PORT + 1, 0x00
	outb SERIAL_PORT + 3, 0x80
        outb SERIAL_PORT + 0, 0x03
        outb SERIAL_PORT + 1, 0x00
        outb SERIAL_PORT + 3, 0x03
        outb SERIAL_PORT + 2, 0xc7
        outb SERIAL_PORT + 4, 0x0b
        outb SERIAL_PORT + 4, 0x1e
        outb SERIAL_PORT + 0, 0xae

	inb SERIAL_PORT + 0
	cmp al, 0xae
	jne error

	outb SERIAL_PORT + 4, 0x0f
	ret

write_serial:
	push edx

	push eax
.cw:	inb SERIAL_PORT + 5
	and al, 0x20
	jz .cw
	pop eax

	outb SERIAL_PORT + 0, al

	pop edx
	ret

read_serial:
	push edx

.cr:	inb SERIAL_PORT + 5
	and al, 0x01
	jz .cr

	out SERIAL_PORT + 0, al

	pop edx
	ret

write_hex:
	pushad
	xchg eax, ebx

	mov ecx, 4
.loop:	mov eax, ebx
	shr eax, 24
	call write_hex_byte
	shl ebx, 8
	loop .loop

	mov al, 0x0a
	call write_serial

	popad
	ret

write_hex_byte:
	pushad
	xchg edx, eax

	xor ebx, ebx
	mov bl, dl
	shr bl, 4
	add ebx, .table
	mov al, byte [ebx]
	call write_serial

	xor ebx, ebx
	mov bl, dl
	and bl, 0x0f
	add ebx, .table
	mov al, byte [ebx]
        call write_serial

	popad
	ret
.table:	db "0123456789abcdef"

kernel_file:
	incbin "main.o"

entry:	dd 0

func_table:
        dd func_nop     ; 0b00000
        dd func_lit     ; 0b00001
        dd func_sstack  ; 0b00010
        dd func_drop    ; 0b00011
        dd func_dup     ; 0b00100
        dd func_swap    ; 0b00101
        dd func_over    ; 0b00110
        dd func_rot     ; 0b00111
        dd func_eq      ; 0b01000
        dd func_not     ; 0b01001
        dd func_gth     ; 0b01010
        dd func_lth     ; 0b01011
        dd func_jmp     ; 0b01100
        dd func_jmpc    ; 0b01101
        dd func_call    ; 0b01110
        dd func_stash   ; 0b01111
        dd func_add     ; 0b10000
        dd func_sub     ; 0b10001
        dd func_mul     ; 0b10010
        dd func_div     ; 0b10011
        dd func_mod     ; 0b10100
        dd func_and     ; 0b10101
        dd func_or      ; 0b10110
        dd func_xor     ; 0b10111
        dd func_shift   ; 0b11000
        dd func_ldb     ; 0b11001
        dd func_ldw     ; 0b11010
        dd func_stb     ; 0b11011
        dd func_stw     ; 0b11100
        dd func_srel    ; 0b11101
        dd func_sbp     ; 0b11110
        dd func_native  ; 0b11111

func_nop:
	ret

func_lit:
	lodsd
	push_ps eax
	ret

func_sstack:
	lodsd
	mov ebx, ebp
	mov ebp, eax
	push_ps ebx
	ret

func_drop:
	pop_ps eax
	ret

func_dup:
	pop_ps eax
	push_ps eax
	push_ps eax
	ret

func_swap:
	pop_ps ebx
	pop_ps eax
	push_ps ebx
	push_ps eax
	ret

func_over:
	pop_ps ebx
	pop_ps eax
	push_ps eax
	push_ps ebx
	push_ps eax
	ret

func_rot:
	pop_ps ecx
	pop_ps ebx
	pop_ps eax
	push_ps ebx
	push_ps ecx
	push_ps eax
	ret

func_eq:
	pop_ps ebx
	pop_ps eax
	cmp eax, ebx
	call eqtoeax
	push_ps eax
	ret

func_not:
	pop_ps eax
	xor eax, 1
	push_ps eax
	ret

func_gth:
	pop_ps ebx
        pop_ps eax
        cmp eax, ebx
        call abovetoeax
        push_ps eax
        ret

func_lth:
        pop_ps ebx
        pop_ps eax
        cmp eax, ebx
        call belowtoeax
        push_ps eax
        ret

func_jmp:
	pop_ps esi
	ret

func_jmpc:
	pop_ps eax
	pop_ps ebx

	cmp eax, 0
	je .ret

	mov esi, ebx

.ret:	ret

func_call:
	push_rs esi
	pop_ps esi
	ret

func_stash:
	pop_ps eax
	push_rs eax
	ret

func_add:
	pop_ps ebx
	pop_ps eax
	add eax, ebx
	push_ps eax
	ret

func_sub:
        pop_ps ebx
        pop_ps eax
        sub eax, ebx
        push_ps eax
        ret

func_mul:
	; protect edx
	mov ecx, edx
	xor edx, edx

	pop_ps ebx
	pop_ps eax

	mul ebx

	push_ps eax

	; unprotect edx
	mov edx, ecx
	ret

func_div:  
        ; protect edx
        mov ecx, edx
        xor edx, edx

        pop_ps ebx
        pop_ps eax

        div ebx

        push_ps eax

        ; unprotect edx
        mov edx, ecx
        ret

func_mod:  
        ; protect edx
        mov ecx, edx
        xor edx, edx

        pop_ps ebx
        pop_ps eax

        div ebx

        push_ps edx

        ; unprotect edx
        mov edx, ecx
        ret

func_and:
	pop_ps ebx
	pop_ps eax
	and eax, ebx
	push_ps eax
	ret

func_or:
        pop_ps ebx
        pop_ps eax
        or eax, ebx
        push_ps eax
        ret

func_xor:
        pop_ps ebx
        pop_ps eax
        xor eax, ebx
        push_ps eax
        ret

func_shift:
	pop_ps ebx
	pop_ps eax

	mov ecx, ebx
	and ecx, 0x7fffffff

	test ebx, 0x80000000
	je .shr

	shl eax, cl
	jmp .ret
.shr:	shr eax, cl

.ret:	push_ps eax
	ret

func_ldb:
	xor eax, eax
	pop_ps ebx
	mov al, byte [ebx]
	push_ps eax
	ret

func_ldw:
	pop_ps ebx
	mov eax, dword [ebx]
	push_ps eax
	ret

func_stb:
	pop_ps ebx
	pop_ps eax

	mov byte [ebx], al
	ret

func_stw:
	pop_ps ebx
	pop_ps eax

	mov dword [ebx], eax
	ret

func_srel:
	pop_ps eax
	add eax, edx
	push_ps eax
	ret

func_sbp:
	pop_ps edx
	add edx, ebp
	ret

func_native:
	ret
	pop_ps eax
	call eax
	ret
