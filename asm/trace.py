#!/bin/env python3
import sys

OPCODES = ['nop', 'lit', 'sps', 'drop', 'dup', 'swap', 'over', 'rot', 'eq', 'not', 'gth', 'lth', 'sjmp', 'sjmpc', 'scall', 'sth', 'add', 'sub', 'mul', 'div', 'mod', 'and', 'or', 'xor', 'shl', 'ldb', 'ldw', 'stb', 'stw', 'srel', 'sbp', 'native']

if len(sys.argv) < 3:
    print(sys.argv[0], "<file>", "<log>", "[<origin>]")
    exit(1)

try:
    origin = eval(sys.argv[3])
except:
    origin = 0

with open(sys.argv[2], "r") as file:
    pcs = []
    level = 0

    for line in file.read().split("\n"):
        if len(line.strip()) == 0:
            continue

        try:
            pcs.append(int(line, 16))
        except:
            pass

def _read_byte(buf):
    c = buf.read(1)

    if len(c) == 0:
        exit(0)

    return c[0]

def read_byte(buf, addr):
    buf.seek(addr)
    return _read_byte(buf)

def fetch_word(buf):
    return _read_byte(buf) | (_read_byte(buf) << 8) | (_read_byte(buf) << 16) | (_read_byte(buf) << 24)

with open(sys.argv[1], "rb") as binary:
    for pc in pcs:
        olevel = level

        try:
            ropcode = read_byte(binary, pc - origin)
        except:
            print(f"Out of bounds fetch at 0x{hex(pc)[2:].zfill(16)}")
            exit(1)

        flags = ropcode >> 5
        func = ropcode & 0b11111

        if 0 < func < 3:
            val = fetch_word(binary)
        else:
            val = None

        opcode = OPCODES[func]
        if flags:
            opcode += "."

            if flags & 4:
                opcode += "r"
            if flags & 2:
                opcode += "a"
            if flags & 1:
                opcode += "f"

        if opcode == "scall":
            level += 1
        elif opcode == "sjmp.r":
            level -= 1

        if olevel < 0:
            print("Stack undeflow")
            exit(1)

        prefix = "| " * olevel

        if opcode == "scall":
            prefix += ") "
        elif opcode == "sjmp.r":
            prefix = prefix[:-2] + "\\ "

        print("0x" + hex(pc)[2:].zfill(16) + ": " + prefix + opcode + (" 0x" + hex(val)[2:].zfill(16) if val != None else ""))
