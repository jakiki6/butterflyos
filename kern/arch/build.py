import os

out = open(os.path.join(os.path.dirname(__file__), "glue.asm"), "w")

with open("/tmp/out.inc", "w") as file:
    file.write("""bits 64

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

""")

for root, _, fns in os.walk(os.path.join(os.path.dirname(__file__), "snippets")):
    for fn in fns:
        print(f"Building {fn}...")

        filen = os.path.join(root, fn)

        cmd = f"nasm -f bin -o /tmp/out.bin {filen} -p /tmp/out.inc"
        assert os.system(cmd) == 0, f"'{cmd}' failed"

        with open("/tmp/out.bin", "rb") as file:
            out.write(f"{fn}:\t.bin native ret\n.bin:\t\tdb ")

            for chr in file.read():
                out.write(f"0x{hex(chr)[2:].zfill(2)}, ")

            out.write("0x0f, 0x0b\n\n")
