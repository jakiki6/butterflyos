import sys

if len(sys.argv) < 2:
    content = bytes.fromhex(input("Binary: "))
else:
    with open(sys.argv[1], "rb") as file:
        content = file.read()

for char in content:
    print(chr(0x61 + (char >> 4)) + chr(0x61 + (char & 0x0f)), end="")
