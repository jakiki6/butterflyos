ASM = python3 ../asm/asm.py

all: install

install: ../os.img kernel.bin
	echfs-utils ../os.img import kernel.bin kernel.bin

kernel.bin: main.o
	nasm -f bin -l vm/vm.lst -o vm.bin vm/vm.asm
	nasm -f bin -o $@ vm/reloc.asm

%.o: %.asm
	$(ASM) $< $@

clean:
	rm *.lst *.bin *.o 2> /dev/null || true

.PHONY: all install clean
