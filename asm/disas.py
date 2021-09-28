#!/bin/env python3
import sys

OPCODES = ['nop', 'lit', 'sps', 'drop', 'dup', 'swap', 'over', 'rot', 'eq', 'not', 'gth', 'lth', 'sjmp', 'sjmpc', 'scall', 'sth', 'add', 'sub', 'mul', 'div', 'mod', 'and', 'or', 'xor', 'shl', 'ldb', 'ldw', 'stb', 'stw', 'srel', 'sbp', 'native']

if len(sys.argv) < 2:
    print(sys.argv[0], "<file>", "[<origin>]")
    exit(1)

try:
    origin = eval(sys.argv[2])
except:
    origin = 0

def read_byte(buf):
    c = buf.read(1)

    if len(c) == 0:
        exit(0)

    return c[0]

def read_word(buf):
    return read_byte(buf) | (read_byte(buf) << 8) | (read_byte(buf) << 16) | (read_byte(buf) << 24)

with open(sys.argv[1], "rb") as file:
    while True:
        at = file.tell()

        opcode = read_byte(file)
        is_rs = (opcode & 0b10000000) > 0
        func = opcode & 0b11111

        name = "0x" + hex(at + origin)[2:].zfill(8) + ": " + OPCODES[func]
        if is_rs:
            name += "r"
        if 0 < func < 3:
            name += " 0x" + hex(read_word(file))[2:]

        print(name)
