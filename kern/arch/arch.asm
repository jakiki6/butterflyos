	; doesn't get assembled

	bits 64

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

arch_outb:
	pop_ps rdx
	pop_ps rax

	out dx, al
	ret

arch_inb:
	pop_ps rdx

	in al, dx
	and rax, 0xff
	push_ps rax
	ret

rng_one:
	rdtsc
	shl rdx, 32
	or rax, rdx

	push_ps rax
	ret
