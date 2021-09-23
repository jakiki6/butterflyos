ASM = python3 ../asm/asm.py

all: install

install: ../os.img kernel.bin
	echfs-utils ../os.img import kernel.bin kernel.bin

kernel.bin: reloc.asm vm.asm main.o
	nasm -f bin -o vm.bin vm.asm
	nasm -f bin -o $@ reloc.asm

%.o: %.asm
	$(ASM) $< $@

clean:
	rm *.bin *.o 2> /dev/null || true

.PHONY: all install clean
