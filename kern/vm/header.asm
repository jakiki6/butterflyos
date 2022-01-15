header:	jmp short .end
.p1:	times 8 - ($ - header) nop
.magic:	db "bttrflyk"
.ver:	dq 0x0000000000000001		; 0x00000000MMmmPPPP, M=major, m=minor, p=patch
.bid:	dq GIT_COMMIT
.obj:	dq 0				; not defined yet
times 128 - ($ - header) db 0
.end: