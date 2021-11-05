import sys

if len(sys.argv) < 2:
    content = input("Content: ")
else:
    with open(sys.argv[1], "r") as file:
        content = file.read()

binary = b""
i = 0

try:
    while True:
        binary += bytes([((ord(content[i]) - 0x61) << 4 | (ord(content[i+1]) - 0x61)) & 0xff])
        i += 2
except IndexError:
    pass

print(binary.hex())
