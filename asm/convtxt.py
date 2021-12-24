#!/bin/env python3
import sys, math

if len(sys.argv) < 2:
    print(sys.argv[0], "<mode>")
    exit(1)

mode = sys.argv[1]

if mode == "e":
    with open("/dev/stdin", "r") as file:
        data = file.read()

    for char in data:
        i = ord(char)
        while i:
            p = i & 0b01111111
            i >>= 7
            if i:
                p |= 0b10000000

            sys.stdout.write(chr(p))
elif mode == "d":
    i = 0
    j = 0

    with open("/dev/stdout", "wb") as out:
        with open("/dev/stdin", "rb") as inf:
            while True:
                c = inf.read(1)
                if len(c) == 0:
                    break
                c = c[0]

                i |= (c & 0b01111111) << j
                j += 7

                if not (c & 0b10000000):
                    out.write(i.to_bytes(math.ceil(i.bit_length() / 8), "big"))
                    i = 0
                    j = 0
