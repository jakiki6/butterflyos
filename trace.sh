#!/bin/sh

./asm/dumpbin.py kern/main.o main.bin && ./asm/trace.py main.bin trace.log 0x230000 | less
