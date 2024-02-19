
PCIHDR struct
wDevice dw ?	;+0
wVendor dw ?
wCmd    dw ?	;+4
wStatus dw ?	;+6 bit 4: 1=capability list exists ( offset 34h )
bRevision db ?	;+8
bPI		db ?	;+9
bSubClass db ?	;+10
bClass	db ?	;+11
		db ?	;+12 cache line size
		db ?	;+13 latency timer
bHdrType db ?	;+14 header type
		db ?	;+15 self-test result
PCIHDR ends

MSICAP struct
bCapID	db ?	; 5=MSI
bNextCap db ?	; offset of next cap in config space
wControl dw ?	; bit 0: MSI enabled, bit 7: 64-bit address, 1-3: mult msg capable, 4-6:mult msg enable
dwAddr  dd ?	; bits 2-31: physical address of MSI write transaction; bits 0-1: 0
		dd ?	; for 64-bit address
wData   dw ?	; msg data; may be 1/2/4/8/16/32 
MSICAP ends
