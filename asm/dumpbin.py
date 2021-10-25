#!/bin/env python3
import sys

if len(sys.argv) < 3:
    print(sys.argv[0], "<input>", "<output>")
    exit(1)

with open(sys.argv[1], "rb") as infile:
    with open(sys.argv[2], "wb") as outfile:
        assert infile.read(8) == b"techno<3", "Not an object file"

        infile.read(24) # skip over boring stuff

        length = int.from_bytes(infile.read(8), "little")
        outfile.write(infile.read(length))
