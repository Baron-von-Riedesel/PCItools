
;--- XHCI CAPability Registers

XHCICAP struct
bLength db ?	;+00
		db ?
wVersion dw ?	;+02 Interface Version Numver (BCD)
dwSParams1 dd ?	;+04 Structural Params 1
dwSParams2 dd ?	;+08 Structural Params 2
dwSParams3 dd ?	;+0C Structural Params 3
dwCParams1 dd ?	;+10 Capability Params 1
dwDBOfs dd ?	;+14 Doorbell Offset
dwRTSOfs dd ?	;+18 Runtime Registers Space Offset
dwCParams2 dd ?	;+1C Capability Params 2
XHCICAP ends

;--- XHCI OPerational Registers:

XHCIOP struct
dwUsbCmd dd ?	; +00 USB command
dwUsbSts dd ?	; +04 USB status
dwPgSize dd ?	; +08 supported page sizes in bits 0-15; 2^(n+12)
		dd ?,?
dwDNCtrl dd ?	; +14 Device Notification
dwCRC	 dd ?	; +18 Command Ring Control
		dd ?,?,?,?,?
dwDCBAAP dd ?	; +30 Device Context Base Address Array Pointer
		dd ?
dwConfig dd ?	; +38 Configure
;--- ofs 3C-3FF reserved
;--- 400h-13ffh Port Register Set 1 - MaxPorts
XHCIOP ends

;--- Port Register Set

XHCIPRS struct
dwSC	dd ?	; Port Status & Control
dwPMSC	dd ?	; Port Power Management Status & Control
dwLI	dd ?	; Port Link Info
dwHLPMC	dd ?	; Port Hardware LPM Control
XHCIPRS ends

;--- XHCI RunTime Registers:

XHCIRT struct
XHCIRT ends

;--- Structural Params 1
;--- 0-7: Number of Device Slots (MaxSlots)
;--- 8-18: Number of Interruptors
;--- 19-23: reserved
;--- 23-31: Number of Ports

;--- Structural Params 2
;--- ß-3: IST
;--- 4-7: ERST
;--- 8-20: rsvd.
;--- 21-25: Max Scratchpad Buffers High
;--- 26: SPR
;--- 27-31: Max Scratchpad Buffers Low

;--- Capability Params 1
;--- 0: AC64 - 1=64bit addressing capability
;--- 1: BNC - 1=Bandwidth Negotiation implemented
;--- 2: CSZ - 1=64-byte context data structs, 0=32-byte
;--- 3: PPC - Port Power Control
;--- 4: PIND - Port Indicators
;--- 5: LHRC - Light HC Reset Capability
;--- 6: LTC - Latency Tolerance Messageing Capability
;--- 7: NSS - No Secondary SID Support
;--- 8: PAE - Parse All Event Data
;--- 9: SPC - Stopped - Short Packet Capability
;--- 10: SEC - Stopped EDTLA Capability
;--- 11: CFC - Contiguous Frame ID Capability
;--- 12-15 MaxPSASize - Maximum Primary Stream Array Size
;--- 16-31: xECP - XHCI Extended Capabilities Pointer ( rel. offset in dwords! )

;--- USB Command Register:
;--- 0: RW; Run/Stop
;--- 1: RW; Host Controller Reset ( write 1 to this bit ).
;--- 2: RW; Interrupt Enable 
;--- 3: RW; Host System Error Enable
;--- 7: RW/RO: Light Host Controller Reset
;--- 8: RW; Controller Save State
;--- 9: RW; Controller Restore State
;--- 10: RW; Enable Wrap Event
;--- 11: RW; Enable U3 MFINDEX Stop
;--- 13: RW; CEM Enable
;--- 14: Extended TBC Enable
;--- 15: Extended TBC TRB Status Enable
;--- 16: RW; VTIO Enable

;--- PCI header, offset 0D0h
;--- USB3_PSSEN <- -1 to switch to superspeed
;--- PCI header, offset 0D8h
;--- XUSP2PR <- -1 to switch to USB2

