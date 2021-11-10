import binascii, sys

if len(sys.argv) < 2:
    print(sys.argv[0], "<file>")
    exit(1)

with open(sys.argv[1], "rb") as file:
    file.read(8)    # magic

    fcrc = int.from_bytes(file.read(4), "little")
    rcrc = binascii.crc32(file.read()) % (1<<32)

    if fcrc == rcrc:
        print(f"verification passed :) ({hex(fcrc)[2:].zfill(8)} == {hex(rcrc)[2:].zfill(8)})")
    else:
        print(f"verification failed :( ({hex(fcrc)[2:].zfill(8)} != {hex(rcrc)[2:].zfill(8)})")
