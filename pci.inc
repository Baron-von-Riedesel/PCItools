
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

;--- capability types
PCICAPID_PM  equ 1	; 1 power management
PCICAPID_AGP equ 2	; 2 AGP controller
PCICAPID_VPD equ 3	; 3 "vital product data"
PCICAPID_SI  equ 4	; 4 slot identification
PCICAPID_MSI equ 5	; 5 message signaled interrupt (MSI)
PCICAPID_HS  equ 6	; 6 CompactPCI hot swap
PCICAPID_PCIX equ 7	; 7 PCI-X
PCICAPID_HT  equ 8	; 8 HyperTransport
PCICAPID_VS  equ 9	; 9 Vendor Specific
PCICAPID_DP  equ 10	;10 Debug port
PCICAPID_CRC equ 11	;11	CompactPCI central resource control
PCICAPID_HP  equ 12	:12 Hot Plug
PCICAPID_BS  equ 13	;13 bridge subsystem
PCICAPID_A8  equ 14	;14 AGP 8x
PCICAPID_SD  equ 15	;15 Secure Device
PCICAPID_PCIE equ 16;16 PCI Express
PCICAPID_MSIX equ 17;17 MSI-X
PCICAPID_DIC equ 18	;18 SATA Data/Index Configuration
PCICAPID_AF  equ 19	;19 Advanced Features

