#!/bin/env python3
import sys

if len(sys.argv) < 2:
    print(sys.argv[0], "<input>")
    exit(1)

types = {0x00: "NEEDS", 0x01: "PROVIDES"}

with open(sys.argv[1], "rb") as infile:
    assert infile.read(8) == b"bttrflyo", "Not an object file"

    crc = infile.read(8)[:4]
    print(f"crc: {crc.hex()}")
    entry = int.from_bytes(infile.read(8), "little")
    print(f"entry at 0x{hex(entry)[2:].zfill(16)}")
    numsecs = int.from_bytes(infile.read(8), "little")
    print(f"{numsecs} section(s)")

    for sn in range(0, numsecs):
        print(f"section {sn}:")
        addr = int.from_bytes(infile.read(8), "little")
        print(f"\tloads at 0x{hex(addr)[2:].zfill(16)}")
        length = int.from_bytes(infile.read(8), "little")
        print(f"\t{length} bytes of binary")
        infile.read(length)
        length = int.from_bytes(infile.read(8), "little") * 8
        print(f"\t{length} bytes of reloc")
        infile.read(length)

        syms = []
        length = int.from_bytes(infile.read(8), "little")
        print(f"\t{length} symbol(s)")

        for i in range(0, length):
            type = infile.read(1)[0]
            addr = int.from_bytes(infile.read(8), "little")

            name = b""
            while True:
                char = infile.read(1)

                if char[0] == 0x00:
                    break

                name += char

            syms.append((type, name, addr))


        for type, name, addr in syms:
            print("\t", end="")

            if type in types:
                print(types[type], end=" ")
            else:
                print("UNKNOWN", end=" ")

            print(name.decode(), end=" ")
            print("0x" + hex(addr)[2:].zfill(16))
