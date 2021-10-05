	; doesn't get assembled

	bits 32

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

arch_outb:
	push edx
	pop_ps edx
	pop_ps eax

	out dx, al
	pop edx
	ret

arch_inb:
	push edx
	pop_ps edx

	in al, dx
	and eax, 0xff
	push_ps eax
	pop edx
	ret

rng_one:
	push edx
	rdtsc
	pop edx
	push_ps eax
	ret
