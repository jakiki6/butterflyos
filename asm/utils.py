bases = {
    "x": 16,
    "b": 2,
    "o": 8
}

ESCAPES = {
    "n": "\n",
    "t": "\t",
    "r": "\r"
}

def shift_line(data, num):
    for i in range(0, num):
        data.opcode = data.args[0]
        data.args.pop(0)
    return data

def req_int(string, splices, tosplice, binary, ws):
    return req_int_big(string, splices, tosplice, binary, ws) % (256 ** ws)

def req_int_const(string, splices, tosplice, binary, ws):
    return req_int_big(string, splices, tosplice, binary, ws, True) % (256 ** ws)

def req_int_big(string, splices, tosplice, binary, ws, const=False):
    try:
        res = int(string)       # number
        return res
    except:
        pass

    if len(string) == 3:
        if string[0] == "'" and string[2] == "'":
            return ord(string[1])

    if string.startswith("\"") and string.endswith("\""):
        val = ""
        escape = False
        for char in string[1:-1]:
            if escape:
                if char in ESCAPES.keys():
                    char = ESCAPES[char]

                val += char
                escape = False
            else:
                if char == "\\":
                    escape = True
                else:
                    val += char

        val = int.from_bytes(val.encode(), "little")
        return val

    if len(string) > 2:
        if string[0] == "0":    # prefix like 0x or 0b
            if string[1] in bases.keys():
                try:
                    res = int(string[2:], bases[string[1]])
                    return res
                except:
                    pass

    if string == "$":
        return len(binary)

    if not const:
        for splice in splices:
            tosplice.append({
                "label": string,
                "at": splice,
                "size": ws
            })
        return 0xffff

    raise ValueError(f"{string} isn't a valid number!")

def pack_num(num, ws):
    res = []
    for i in range(0, ws):
        res.append(num % 256)
        num >>= 8

    if num > 0:
        raise ValueError(f"Value too big for word size of {ws} byte(s)")

    return res
