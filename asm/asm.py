#!/bin/env python3
import sys, os
import asmcore

if len(sys.argv) < 3:
    print(sys.argv[0], "<file>", "<output>")
    exit(1)
if not os.path.isfile(sys.argv[1]):
    print(sys.argv[1], "is not a file")
    exit(1)

cwd = os.getcwd()
with open(sys.argv[1], "r") as file:
    try:
        os.chdir(os.path.dirname(sys.argv[1]))
    except:
        pass
    binary = asmcore.process(file.read())

os.chdir(cwd)
with open(sys.argv[2], "wb") as file:
    file.write(binary)
