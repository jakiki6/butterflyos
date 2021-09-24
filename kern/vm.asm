	bits 32
	org 0x200000

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

	; set entry point
	cmp dword [entry], 0
	jne .entryalreadyset
	mov dword [entry], eax
.entryalreadyset:

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

vm:	; registers:
	; esi=pc ebp=ps edi=rs edx=bp

	; setup registers
	mov esi, dword [entry]

	; no swap
	push 0

.main:	; clean up
	cmp byte [.flag_rs], 1
	jne .flags
	xchg ebp, edi

.flags:	; clean up the flag
	mov byte [.flag_rs], 0

	lodsb
	test al, 0b10000000
	jne .chk_fetch
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

	; call it
	call [ebx]
	jmp .main
	

.flag_rs:
	db 0


error:	lidt [.fake_idt]
	int 0x69
.fake_idt:
	dw 0
	dd 0

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
	mov ebp, eax
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
