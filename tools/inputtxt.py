import sys, time, pynput

if len(sys.argv) < 2:
    print(sys.argv[0], "<file>")
    exit(1)

cnt = pynput.keyboard.Controller()

with open(sys.argv[1], "r") as file:
    time.sleep(2)

    for char in file.read():
        cnt.press(char)
        cnt.release(char)

        time.sleep(0.05)
