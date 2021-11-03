import sys

if len(sys.argv) < 2:
    print(sys.argv[0], "<file>")
    exit(1)

with open(sys.argv[1], "rb") as file:
    file.seek(0x202)
    print(int.from_bytes(file.read(4), "little"))
