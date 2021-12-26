global BufRead
BufRead:
	0 add ldw sjmp

global BufWrite
BufWrite:
        8 add ldw sjmp

global BufSeek
BufSeek:
        16 add ldw sjmp

global BufTell
BufTell:
        24 add ldw sjmp

global BufClose
BufClose:
        32 add ldw sjmp
