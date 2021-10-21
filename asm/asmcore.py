import sys, math, os
import utils

OPCODES = {
    "nop": 0b00000,
    "drop": 0b00011,
    "dup": 0b00100,
    "swap": 0b00101,
    "over": 0b00110,
    "rot": 0b00111,
    "eq": 0b01000,
    "not": 0b01001,
    "gth": 0b01010,
    "lth": 0b01011,
    "sjmp": 0b01100,
    "sjmpc": 0b01101,
    "scall": 0b01110,
    "sth": 0b01111,
    "add": 0b10000,
    "sub": 0b10001,
    "mul": 0b10010,
    "div": 0b10011,
    "mod": 0b10100,
    "and": 0b10101,
    "or": 0b10110,
    "xor": 0b10111,
    "shl": 0b11000,
    "ldb": 0b11001,
    "ldw": 0b11010,
    "stb": 0b11011,
    "stw": 0b11100,
    "srel": 0b11101,
    "sbp": 0b11110,
    "native": 0b11111
}

CONSUMES = {
    "db": -1,
    "dw": -1,
    "org": 1,
    "%include": -1,
    "%incbin": -1,
    "times": -1,
    "bits": 1,
    "sps": 1,
    "srs": 1,
    "lit": 1,
    "jmp": 1,
    "jmpc": 1,
    "call": 1,
    "ret": 0,
    "hlt": 0,
    "global": 1,
    "extern": 1
}

FLAGS = {
    "r": 0x80,
    "a": 0x40,
    "f": 0x20
}

origin = 0
ws = 8

class OpCode(object):
    def __init__(self, opcode, args):
        self.opcode = opcode
        self.args = args
    def __str__(self):
        return f"OpCode(opcode='{self.opcode}', args={self.args})"
    def __repr__(self):
        return self.__str__()

class Label(object):   
    def __init__(self, name):
        self.name = name
    def __str__(self):
        return f"Label(name='{self.name}')"
    def __repr__(self):
        return self.__str__()

def consumes(opcode):
    if opcode in CONSUMES.keys():
        return CONSUMES[opcode]
    else:
        return 0    # number or non-consuming opcode?

def check_string(char, in_string, in_escape):
    if not in_string:                
        if char == "\"":
            in_string = True
    else:
        if not in_escape:
            if char == "\"":
                in_string = False
            elif char == "\\":   
                in_escape = True 
        else:
            in_escape = False

    return in_string, in_escape

def split_string(string, dil):
    strings = [""]
    in_string = False
    in_escape = False

    for char in string:
        in_string, in_escape = check_string(char, in_string, in_escape)

        if not in_string and char == dil:
            strings.append("")
        else:
            strings[-1] += char

    return strings

def pack_num(num):
    length = math.ceil(num.bit_length() / 8)
    if length == 0:
        length = 1

    num = num % (256 ** length)

    return int.to_bytes(num, length, "little", signed=False)

def replace_whitespaces(line):
    nline = ""
    hit = False
    in_string = False
    in_escape = False
    for char in line:
        in_string, in_escape = check_string(char, in_string, in_escape)

        if char in " \t," and not in_string:
            if not hit:
                nline += " "
                hit = True
            continue
        else:
            hit = False
            nline += char
    return nline

def parse(text):
    opcodes = []
    lline = ""
    is_nl = False
    for line in text.split("\n"):
        if is_nl:
            line = lline + line
            is_nl = False

        line = line.strip()

        in_string = False
        in_escape = False
        _line = line
        line = ""
        for char in _line:
            in_string, in_escape = check_string(char, in_string, in_escape)

            if not in_string and char == ";":
                break
            if not in_string and char == "\t":
                char = "    "

            line += char

        line = replace_whitespaces(line)

        if len(line) == 0:
            continue
        if line[-1] == "\\":
            is_escape = True
            lline = line[:-1]
        else:
            if ":" in line:
                label_name = split_string(line, ":")[0].strip()
                line = split_string(split_string(line, ":")[1], " ")
                opcodes.append(Label(label_name))
                while "" in line:
                    line.remove("")
            else:
                line = split_string(line, " ")

            while len(line) > 0:
                o = line.pop(0)
                cons = consumes(o)

                if cons == -1:
                    opcodes.append(OpCode(o, line))
                    break
                else:
                    args = []
                    for i in range(0, cons):
                        try:
                            args.append(line.pop(0))
                        except IndexError:
                            raise ValueError(f"Too few arguments for opcode '{o}'")
                    opcodes.append(OpCode(o, args))
    copcodes = []
    for opcode in opcodes:
        if isinstance(line, OpCode):
            if opcode.opcode.strip() == "":
                continue

        copcodes.append(opcode)

    return copcodes

def merge(data):
    for index, line in enumerate(data):
        if not isinstance(line, OpCode):
            continue
        if line.opcode == "%include":
            try:
                fn = line.args[0]
                if fn[0] == "\"" and fn[-1] == "\"":
                    fn = fn[1:-1]

                with open(fn, "r") as file:
                    for nline in parse(file.read()):
                        data.insert(index, nline)
                        index += 1
                    data.remove(line)
                    merge(data)
                    break
            except:
                print(f"Cannot open file {line.args[0]}")
                exit(0)

def preprocess(data):
    for index, line in enumerate(data):
        if not isinstance(line, OpCode):
            continue
        if line.opcode == "times":
            num, _ = utils.req_int_const(line.args[0], [], [], b"", 8, "")
            nline = utils.shift_line(line, 2)
            for i in range(0, num):
                data.insert(index, nline)
            data.remove(line)
            preprocess(data)
            break

def clean(data):
    for opcode in data.copy():
        if isinstance(opcode, OpCode):
            if opcode.opcode == "":
                data.remove(opcode)

def process(text):
    global origin, ws
    origin = 0
    ws = 8
    defined_origin = False
    root_label = ""

    binary = bytearray()

    rt0 = "rt0.asm"
    text = f"%include {os.path.join(os.path.dirname(__file__), rt0)}\n" + text

    data = parse(text)
    merge(data)
    preprocess(data)
    clean(data)

    if "DEBUG" in os.environ.keys():
        for opcode in data:
            if isinstance(opcode, OpCode):
                print(repr(opcode.opcode), opcode.args)
            else:
                print(opcode.name + ":")

    tosplice = []
    labels = {}
    globals, externals = [], []

    for opcode in data:
        if isinstance(opcode, OpCode):
            if len(opcode.args) == 0:
                try:
                    if opcode.opcode.startswith("#"):
                        num = opcode.opcode[1:]
                        is_rel = True
                    else:
                        num = opcode.opcode
                        is_rel = False

                    val = utils.req_int_const(num, [], [], bytes(), ws, root_label)
                    if is_rel:
                        binary += bytearray([0x01, *utils.pack_num(val, ws), OPCODES["srel"]])
                    else:
                        binary += bytearray([0x01, *utils.pack_num(val, ws)])
                    continue
                except ValueError:
                    pass

            if opcode.opcode == "db":
                for arg in opcode.args:
                    num = utils.req_int_big(arg, [len(binary)], tosplice, binary, ws, root_label)

                    binary += bytearray(pack_num(num))
            elif opcode.opcode == "dw":
                for arg in opcode.args:
                    num = utils.req_int_big(arg, [len(binary)], tosplice, binary, ws, root_label)

                    binary += bytearray(utils.pack_num(num, ws))
            elif opcode.opcode == "org":
                if not defined_origin:
                    defined_origin = True
                else:
                    print("org: already defined")
                    exit(0)
                    

                if len(opcode.args) != 1:
                    print("org: wrong number of arguments")
                    exit(0)

                num = utils.req_int_const(opcode.args[0], [], tosplice, binary, ws, root_label)

                origin = num % (256 ** ws)
            elif opcode.opcode == "bits":
                if len(opcode.args) != 1:
                    print("bits: wrong number of arguments")
                    exit(0)

                num = utils.req_int_big(opcode.args[0], [], tosplice, binary, 64, True, root_label)

                if num % 8:
                    print(f"bits: {num} is unaligned")
                    exit(0)

                ws = num // 8
            elif opcode.opcode == "%incbin":
                if len(opcode.args) != 1:  
                    print("%incbin: wrong number of arguments")
                    exit(0)
                if len(opcode.args[0]) < 3:
                    print(f"%incbin: '{opcode.args[0]}' is not a file!")

                opcode.args[0] = opcode.args[0][1:-1]

                try:
                    with open(opcode.args[0], "rb") as file:
                        binary += bytearray(file.read())
                except Exception as e:
                    print(f"%incbin: '{opcode.args[0]}' is not a file!")
                    raise e
                    exit(0)
            elif opcode.opcode == "global":
                globals.append(opcode.args[0])
            elif opcode.opcode == "extern":
                externals.append(opcode.args[0])
            elif opcode.opcode == "ret":
                binary += bytearray([OPCODES["sjmp"] | 0x80])
            elif opcode.opcode == "hlt":
                binary += bytearray([OPCODES["nop"] | 0x80])
            elif opcode.opcode == "neq":    
                binary += bytearray([OPCODES["eq"], OPCODES["not"]])
            elif opcode.opcode == "word":
                binary += bytearray(ws)
            else:
                sopcode = opcode.opcode

                flags = 0
                if "." in opcode.opcode:
                    if opcode.opcode.split(".") in (list(OPCODES.keys()) + ["sps", "srs", "lit", "jmp", "jmpc", "call"]):
                        opcode.opcode, oflags = opcode.opcode.split(".")

                        for char in oflags:
                            flags |= FLAGS[char]

                if opcode.opcode == "sps":
                    num = utils.req_int(opcode.args[0], [len(binary) + 1], tosplice, binary, ws, root_label)

                    binary += bytearray([0x02, *utils.pack_num(num, ws)])
                elif opcode.opcode == "srs":
                    num = utils.req_int(opcode.args[0], [len(binary) + 1], tosplice, binary, ws, root_label)

                    binary += bytearray([0x82, *utils.pack_num(num, ws)])
                elif opcode.opcode == "lit":
                    for arg in opcode.args:
                        num = utils.req_int(arg, [len(binary) + 1], tosplice, binary, ws, root_label)

                        binary += bytearray([0x01 | flags, *utils.pack_num(num, ws)])
                elif opcode.opcode == "jmp":
                    num = utils.req_int(opcode.args[0], [len(binary) + 1], tosplice, binary, ws, root_label)
                    num += origin
                    binary += bytearray([0x01 | flags, *utils.pack_num(num, ws)])
                    binary += bytearray([OPCODES["sjmp"] | flags])
                elif opcode.opcode == "jmpc":
                    num = utils.req_int(opcode.args[0], [len(binary) + 1], tosplice, binary, ws, root_label)
                    num += origin
                    binary += bytearray([0x01 | flags, *utils.pack_num(num, ws)])
                    binary += bytearray([OPCODES["sjmpc"] | flags])
                elif opcode.opcode == "call":
                    num = utils.req_int(opcode.args[0], [len(binary) + 1], tosplice, binary, ws, root_label)
                    num += origin
                    binary += bytearray([0x01 | flags, *utils.pack_num(num, ws)])
                    binary += bytearray([OPCODES["scall"] | flags])
                elif opcode.opcode in OPCODES.keys():
                    binary += bytearray([OPCODES[opcode.opcode] | flags])
                else:
                    opcode.opcode = sopcode

                    if opcode.opcode.startswith("."):
                        opcode.opcode = root_label + opcode.opcode
                    else:
                        root_label = opcode.opcode

                    tosplice.append({
                        "label": opcode.opcode,
                        "at": len(binary) + 1,
                        "size": ws
                    })
                    binary += bytearray([0x01, *utils.pack_num(0, ws)])
        else:
            if opcode.name.startswith("."):
                opcode.name = root_label + opcode.name
            else:
                root_label = opcode.name

            labels[opcode.name] = len(binary) + origin

    symbols, relocs = [], []

    for splice in tosplice:
        if not splice["label"] in labels and not splice["label"] == "relbase":
            if splice["label"] in externals:
                symbols.append([0x00, splice["at"] + origin, splice["label"]])
                continue
            print(f"Undefined reference to '{splice['label']}'")
            exit(0)

        if splice["label"] == "relbase":
            relocs.append(splice["at"])
            continue

        at = splice["at"]
        val = labels[splice["label"]]
        size = splice["size"]

        assert size == 8, "Unaligned address while splicing"

        for i in range(0, size):
            binary[at] = val % 256
            val >>= 8
            at += 1

        if val > 0:
            raise ValueError(f"splice at 0x{hex(at)[2:].zfill(2 * size)} is too big")

        relocs.append(splice["at"])

    for glob in globals:
        if not glob in labels.keys():
            print(f"Undefined global reference to '{glob}'")
            exit(0)

        symbols.append([0x01, labels[glob], glob])

    obj = bytes()
    obj += b"techno<3"
    obj += origin.to_bytes(8, byteorder="little")
    obj += (1).to_bytes(8, byteorder="little")

    obj += origin.to_bytes(8, byteorder="little")

    obj += len(binary).to_bytes(8, byteorder="little")
    obj += binary

    obj += len(relocs).to_bytes(8, byteorder="little")
    for reloc in relocs:
        obj += reloc.to_bytes(8, byteorder="little")

    obj += len(symbols).to_bytes(8, byteorder="little")
    for symbol in symbols:
        obj += bytes([symbol[0]])
        obj += symbol[1].to_bytes(8, byteorder="little")
        obj += symbol[2].encode() + b"\x00"

    return obj
