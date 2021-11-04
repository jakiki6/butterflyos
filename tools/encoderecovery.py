import sys

if len(sys.argv) < 2:
    print(sys.argv[0], "<file>")
    exit(1)

with open(sys.argv[1], "rb") as file:
    for char in file.read():
        print(chr(0x61 + (char >> 4)) + chr(0x61 + (char & 0x0f)), end="")
