target remote localhost:1337

hbreak *0x7c00
hbreak *0x10000
hbreak *0x200000

continue
continue
continue

delete breakpoints

hbreak *0x200027
continue

while ($esi < 0x210100)
	p/x $esi
	continue
end
quit
