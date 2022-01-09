all: run

run: os.img
	qemu-system-x86_64 -hda $< -D log.txt -d int,cpu_reset -machine smm=off -serial stdio -enable-kvm | tee boot.log
rundb: os.img
	qemu-system-x86_64 -hda $< -no-reboot -gdb tcp::1337 -S

os.img:
	make -C loader all
	make -C kern install

clean:
	rm log.txt os.img *.log *.bin 2> /dev/null || true
	make -C loader clean
	make -C kern clean

.PHONY: all run clean rundb
