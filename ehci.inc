
;--- EHCI CAPability Registers

EHCICAP struct
bLength db ?	;+0
		db ?
wVersion dw ?	;+2 Interface Version Numver (BCD)
dwSParams dd ?	;+4 Structural Params
dwCParams dd ?	;+8 Capability Params
dwCPRD	dd ?	;+12 Companion Port Route Description
EHCICAP ends

;--- EHCI OPerational Registers

EHCIOP struct
dwUsbCmd dd ?	; +00 USB command
dwUsbSts dd ?	; +04 USB status
dwUsbIntr dd ?	; +08 USB Interrupt Enable
dwFrmIdx  dd ?	; +0C USB Frame Index
dwCDS	dd ?	; +10 4G Segment Selector
dwFLBA	dd ?	; +14 Frame List Base Address
dwNALA	dd ?	; +18 Next Asynchronous List Address
	dd ?,?,?,?,?,?,?,?,?
dwCfgFlg dd ?	; +40 Configured Flag Register
dwPSCR	dd ?	; +44 Port Status/Control Register
EHCIOP ends

;--- bits USB command:
;--- 31-24  Reserved
;--- 23-16  Interrupt Threshold                     Number of micro frames to process between interrupts
;--- 15-12  Reserved
;--- 11     Async Schedule Park Mode Enable
;--- 10     Reserved
;--- 9-8    Async Schedule Park Mode Count
;--- 7      Light Host Controller Reset             Resets the controller without affecting connected devices
;--- 6      Interrupt On Async Advance Doorbell     Allows software to trigger interrupt
;--- 5      Async Schedule Enable
;--- 4      Periodic Schedule Enable
;--- 3-2    Programmable Frame List Size
;--- 1      Host Controller Reset
;--- 0      Run

;--- bits USB Status Register:
;--- 31-16  Reserved
;--- 15     Async Schedule Status
;--- 14     Periodic Schedule Status
;--- 13     Reclamation
;--- 12     Halted
;--- 11-6   Reserved
;--- 5      Doorbell Interrupt
;--- 4      Host System Error
;--- 3      Frame List Rollover
;--- 2      Port Change Detect
;--- 1      USB Error Interrupt
;--- 0      USB Transfer Interrupt

;--- bits USB Interrupt Enable Register:
;--- 31-6   Reserved
;--- 5      Async Advance Interrupt Enable
;--- 4      Host System Error Interrupt Enable
;--- 3      Frame List Rollover Interrupt Enable
;--- 2      Port Change Interrupt Enable
;--- 1      USB Error Interrupt Enable
;--- 0      USB Transfer Interrupt Enable

;--- bits Port Status/Control Register:
;--- 31-23  Reserved
;--- 22     Wake On Overcurrent Enable
;--- 21     Wake On Disconnect Enable
;--- 20     Wake On Connect Enable
;--- 19-16  Port Test Control
;--- 15-14  Port Indicator Control  0 = Off, 1 = Amber, 2 = Green
;--- 13     Companion Port Control  0 = Local, 1 = Companion Host Controller
;--- 12     Port Power
;--- 11-10  Line Status
;--- 9      Reserved
;--- 8      Port Reset
;--- 7      Suspend
;--- 6      Force Port Resume
;--- 5      Overcurrent Change
;--- 4      Overcurrent
;--- 3      Port Enabled Changed
;--- 2      Port Enabled
;--- 1      Connect Changed
;--- 0      Connected

