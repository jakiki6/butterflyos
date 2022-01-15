ASM = python3 ../asm/asm.py

all: install

install: ../os.img kernel.bin
	echfs-utils ../os.img import kernel.bin kernel.bin

kernel.bin: arch/glue.asm main.o
	nasm -f bin -l vm/vm.lst -o vm.bin vm/vm.asm
	nasm -f bin -o $@ vm/reloc.asm -DGIT_COMMIT=0x$(git rev-parse HEAD | head -c 16)

%.o: %.asm
	$(ASM) $< $@

arch/glue.asm:
	python3 arch/build.py

clean:
	rm *.lst *.bin *.o arch/glue.asm 2> /dev/null || true

.PHONY: all install clean
