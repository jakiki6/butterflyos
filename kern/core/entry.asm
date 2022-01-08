	org 0x230000

extern HwCpuVendor

global KernelEntry
KernelEntry:
	; setup registers
	sps 0x400000 drop
	srs 0x3f0000 drop.r

	; set bp to be equal to the stack
	0 sbp drop

	call SymInit
	call IdtInit
	call SerialInit
	call FbInit

	; logo
	.str1 call SerialWriteString

	; get cpu vendor
	0 0 call ArchCpuID
	; we now have rax rbx rcx rdx on the stack
	HwCpuVendor 4 add sthw
	HwCpuVendor 8 add sthw
	HwCpuVendor sthw
	drop

	.str2 call SerialWriteString
	HwCpuVendor call SerialWriteString
	0x0a call SerialWriteChar

	; get cpu name
	0x80000002 0 call ArchCpuID
	HwCpuBrand 12 add sthw
	HwCpuBrand 8 add sthw
	HwCpuBrand 4 add sthw
	HwCpuBrand 0 add sthw
	0x80000003 0 call ArchCpuID
        HwCpuBrand 28 add sthw
        HwCpuBrand 24 add sthw 
        HwCpuBrand 20 add sthw   
        HwCpuBrand 16 add sthw
	0x80000004 0 call ArchCpuID
        HwCpuBrand 44 add sthw
        HwCpuBrand 40 add sthw 
        HwCpuBrand 36 add sthw   
        HwCpuBrand 32 add sthw

	.str3 call SerialWriteString
        HwCpuBrand call SerialWriteString
        0x0a call SerialWriteChar

.loop:	call RngOneByte
	call RngOneByte
	call RngOneByte
	call RngOne FbCfg.width ldw mod
	call RngOne FbCfg.height ldw mod
	call FbDrawPixel

	jmp .loop

.hlt:	hlt
.str1:	dr 0x0a2020202020202020202020202020202060202020202020202020270a3b2c2c2c20202020202020202020202020602020202020202027202020202020202020202020202c2c2c3b0a6038383838383838626f2e202020202020203a20202020203a202020202020202e6f6438383838383838270a202038383838383838383838622e20202020203a2020203a20202020202e64383838383838383838380a2020383838383859272020605938622e20202060202020272020202e643859272020605938383838380a206a383838382120202e64622e202059622e202720202027202e645920202e64622e20203838383838210a202020603838382020593838592020202060622028202920642720202020593838592020383838270a20202020383838622020272220202020202020202c272c202020202020202022272020643838380a2020206a38383838383838383838382227202020273a2720202060223f673838383838383838386b0a20202020202759272020202e382720202020206427202762202020202027382e2020202759270a202020202020212020202e3827206462202064273b203b6062202064622027382e202020210a20202020202020202064383820206027202038203b203b20382020602720203838620a202020202020202064383849622020202e673820272c272038672e20202064493838620a202020202020203a3838383838383838385927202020202027593838383838383838383a0a2020202020202027212038383838383838272020202020202060383838383838382021270a2020202020202020202027385920206059202020202020202020592720205938270a20202020202020202020205920202020202020202020202020202020202020590a20202020202020202020202120202020202020202020202020202020202020210a0a00
.str2:	db "CPU vendor: ", 0x00
.str3:	db "CPU brand: ", 0x00
