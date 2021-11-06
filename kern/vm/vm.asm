	bits 64
	org 0x200000

SERIAL_PORT: \
	equ 0x03f8
DISABLE_TRACE: \
	equ 0x202000

MASK_RS: \
	equ 0
MASK_ALT: \
	equ 1
MASK_FLOAT: \
	equ 2

%macro push_ps 1
	sub r8, 8
	mov qword [r8], %1
%endmacro
%macro pop_ps 1
	mov %1, qword [r8]
	add r8, 8
%endmacro
%macro push_rs 1
        sub r9, 8
	mov qword [r9], %1
%endmacro
%macro pop_rs 1
        mov %1, qword [r9]
        add r9, 8
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

start:	mov rsp, 0x1f0000

	call init_serial

	call upgrade_paging

	mov rsi, kernel_file

	; check magic
	lodsq
	mov rbx, 0x333c6f6e68636574
	cmp rax, rbx
	jne error

	; crc32
	lodsd

	; flags
	lodsd

	; entry
	lodsq
	mov qword [entry], rax

	; skip over number of sections
	lodsq

	; origin
	lodsq
	mov rdi, rax

	; length of binary
	lodsq
	mov rcx, rax

	; move
	rep movsb

vm:	; registers:
	; rsi=pc r8=ps r9=rs r10=bp r11=flags r12=cfg

	; setup registers
	mov r8, 0x400000
	mov r9, 0x3f0000
	mov r10, 0x400000
	xor r11, r11
	mov r12, 0xffffffffffffffff
	mov rsi, qword [entry]

	; self test
	rdtsc
	push_ps rax
	pop_ps rbx
	cmp rax, rbx
	jne error

	rdtsc
        push_rs rax
        pop_rs rbx
        cmp rax, rbx
        jne error

	; burn "setup completed" in cfg
	and r12, ~(1)

.main:	cmp byte [DISABLE_TRACE], 1
	je .notrace

	xchg rax, rsi
	call write_hex
	xchg rax, rsi
.notrace:

	cmp rsi, 0x200000
	jb error

	; clean up
	bt r11, MASK_RS
	jnc .flags
	xchg r8, r9

.flags:	; clean up flags
	xor r11, r11

	lodsb

.isr:	bt ax, 7
	jnc .isa
	or r11, (1 << MASK_RS)
	xchg r8, r9
.isa:	bt ax, 6
	jnc .isf
	or r11, (1 << MASK_ALT)
.isf:	bt ax, 5
	jnc .nois
	or r11, (1 << MASK_FLOAT)
.nois:

.execute:
	; mask out function
	and al, 0b11111

	; get pointer into function table
	xor rbx, rbx
	mov bl, al
	shl rbx, 3
	add rbx, func_table
	mov rbx, qword [rbx]

	; call it
	push .main
	push rbx
	ret

eqtorax:
	; convert equal flag to rax
	jne .no
	mov rax, 1
	ret
.no:	xor rax, rax
	ret

belowtorax:
        ; convert below flag to rax
        jnb .no   
        mov rax, 1
        ret
.no:    xor rax, rax
        ret

abovetorax:
        ; convert above flag to rax
        jna .no   
        mov rax, 1
        ret
.no:    xor rax, rax
        ret

error:	mov rsi, .msg
.print:	lodsb

	cmp al, 0
	je .reboot

	call write_serial
	jmp .print

.reboot:
	lidt [.fake_idt]
	int 0x69
.fake_idt:
	dw 0
	dd 0
.msg:	db "fuck", 0x0a, 0

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
	jne error.reboot

	outb SERIAL_PORT + 4, 0x0f
	ret

write_serial:
	push rdx

	push rax
.cw:	inb SERIAL_PORT + 5
	and al, 0x20
	jz .cw
	pop rax

	outb SERIAL_PORT + 0, al

	pop rdx
	ret

read_serial:
	push rdx

.cr:	inb SERIAL_PORT + 5
	and al, 0x01
	jz .cr

	inb SERIAL_PORT + 0

	pop rdx
	ret

write_hex:
	push rax
	push rbx
	push rcx

	xchg rax, rbx

	mov rcx, 8
.loop:	mov rax, rbx
	shr rax, (64 - 8)
	call write_hex_byte
	shl rbx, 8
	loop .loop

	mov al, 0x0a
	call write_serial

	pop rcx
	pop rbx
	pop rax
	ret

write_hex_byte:
	push rax
	push rbx
	push rcx
	push rdx

	xchg rdx, rax

	xor rbx, rbx
	mov bl, dl
	shr bl, 4
	add rbx, .table
	mov al, byte [rbx]
	call write_serial

	xor rbx, rbx
	mov bl, dl
	and bl, 0x0f
	add rbx, .table
	mov al, byte [rbx]
        call write_serial

	pop rdx
	pop rcx
	pop rbx
	pop rax
	ret
.table:	db "0123456789abcdef"

upgrade_paging:
	mov rdi, 0x210000
	push rdi

	push rdi
	mov rcx, 0x1000 * (1 + 8)
	xor rax, rax
	rep stosb
	pop rdi

	push rdi
	mov rax, rdi
	or rax, 0b11
	add rax, 0x1000

	mov rcx, 8
.l4:	stosq
	add rax, 0x1000
	loop .l4

	pop rdi

	add rdi, 0x1000
	mov rax, 0b10000011

	mov rcx, 512 * 8
.l3:	stosq
	add rax, 0x1000
	loop .l3

	pop rdi
	mov cr3, rdi
	ret

kernel_file:
	incbin "main.o"

entry:	dq 0

func_table:
        dq func_nop     ; 0b00000
        dq func_lit     ; 0b00001
        dq func_sstack  ; 0b00010
        dq func_drop    ; 0b00011
        dq func_dup     ; 0b00100
        dq func_swap    ; 0b00101
        dq func_over    ; 0b00110
        dq func_rot     ; 0b00111
        dq func_eq      ; 0b01000
        dq func_not     ; 0b01001
        dq func_gth     ; 0b01010
        dq func_lth     ; 0b01011
        dq func_jmp     ; 0b01100
        dq func_jmpc    ; 0b01101
        dq func_call    ; 0b01110
        dq func_stash   ; 0b01111
        dq func_add     ; 0b10000
        dq func_sub     ; 0b10001
        dq func_mul     ; 0b10010
        dq func_div     ; 0b10011
        dq func_mod     ; 0b10100
        dq func_and     ; 0b10101
        dq func_or      ; 0b10110
        dq func_xor     ; 0b10111
        dq func_shift   ; 0b11000
        dq func_ldb     ; 0b11001
        dq func_ldw     ; 0b11010
        dq func_stb     ; 0b11011
        dq func_stw     ; 0b11100
        dq func_srel    ; 0b11101
        dq func_sbp     ; 0b11110
        dq func_native  ; 0b11111

func_nop:
	bt r11, MASK_ALT
	jnc .hlt
	ret
.hlt:	cli
	pause
	hlt
	jmp .hlt

func_lit:
	lodsq
	push_ps rax
	ret

func_sstack:
	lodsq
	mov rbx, r8
	mov r8, rax
	push_ps rbx
	ret

func_drop:
	pop_ps rax
	ret

func_dup:
	pop_ps rax
	push_ps rax
	push_ps rax
	ret

func_swap:
	pop_ps rbx
	pop_ps rax
	push_ps rbx
	push_ps rax
	ret

func_over:
	pop_ps rbx
	pop_ps rax
	push_ps rax
	push_ps rbx
	push_ps rax
	ret

func_rot:
	pop_ps rcx
	pop_ps rbx
	pop_ps rax
	push_ps rbx
	push_ps rcx
	push_ps rax
	ret

func_eq:
	pop_ps rbx
	pop_ps rax
	cmp rax, rbx
	call eqtorax
	push_ps rax
	ret

func_not:
	pop_ps rax
	xor rax, 1
	push_ps rax
	ret

func_gth:
	pop_ps rbx
        pop_ps rax
        cmp rax, rbx
        call abovetorax
        push_ps rax
        ret

func_lth:
        pop_ps rbx
        pop_ps rax
        cmp rax, rbx
        call belowtorax
        push_ps rax
        ret

func_jmp:
	pop_ps rsi
	ret

func_jmpc:
	pop_ps rbx
	pop_ps rax

	cmp rax, 0
	je .ret

	mov rsi, rbx

.ret:	ret

func_call:
	push_rs rsi
	pop_ps rsi
	ret

func_stash:
	pop_ps rax
	push_rs rax
	ret

func_add:
	pop_ps rbx
	pop_ps rax
	add rax, rbx
	push_ps rax
	ret

func_sub:
        pop_ps rbx
        pop_ps rax
        sub rax, rbx
        push_ps rax
        ret

func_mul:
	xor rdx, rdx

	pop_ps rbx
	pop_ps rax

	mul rbx

	push_ps rax
	ret

func_div:  
        xor rdx, rdx

        pop_ps rbx
        pop_ps rax

        div rbx

        push_ps rax
        ret

func_mod:  
        xor rdx, rdx

        pop_ps rbx
        pop_ps rax

        div rbx

        push_ps rdx
        ret

func_and:
	pop_ps rbx
	pop_ps rax
	and rax, rbx
	push_ps rax
	ret

func_or:
        pop_ps rbx
        pop_ps rax
        or rax, rbx
        push_ps rax
        ret

func_xor:
        pop_ps rbx
        pop_ps rax
        xor rax, rbx
        push_ps rax
        ret

func_shift:
	pop_ps rbx
	pop_ps rax

	mov rcx, rbx
	mov rdx, 0x7fffffffffffffff
	and rcx, rdx

	bt rbx, 63
	jc .shr

	shl rax, cl
	jmp .ret
.shr:	shr rax, cl

.ret:	push_ps rax
	ret

func_ldb:
	xor rax, rax
	pop_ps rbx
	mov al, byte [rbx]
	push_ps rax
	ret

func_ldw:
	pop_ps rbx
	mov rax, qword [rbx]
	push_ps rax
	ret

func_stb:
	pop_ps rbx
	pop_ps rax

	mov byte [rbx], al
	ret

func_stw:
	pop_ps rbx
	pop_ps rax

	mov qword [rbx], rax
	ret

func_srel:
	pop_ps rax

	bt r11, MASK_ALT
	jne .n
.p:	add rax, rsi
	jmp .r
.n:	add rax, r10
.r:	push_ps rax
	ret

func_sbp:
	mov rax, r10
	pop_ps r10
	add r10, r8
	push_ps rax
	ret

func_native:
	ret
	pop_ps rax
	call rax
	ret
