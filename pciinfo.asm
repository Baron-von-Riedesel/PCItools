
;--- pciinfo, 16-bit

	.286
	.model tiny
	.stack 4096
	.dosseg
	.386

DISPVENDOR equ 1	;1=display vendor ID/device code
DISPSSID   equ 1	;1=display subsystem vendor/version

	include pci.inc

lf equ 10

PUSHADS struct
_edi dd ?
_esi dd ?
_ebp dd ?
_res dd ?
_ebx dd ?
union
_edx dd ?
_dx  dw ?
ends
_ecx dd ?
_eax dd ?
PUSHADS ends

CStr macro text:vararg
local sym
	.const
sym db text,0
	.code
	exitm <offset sym>
endm

@dstrng macro text
local sym
	.const
sym db text,0
	.data
	dw offset sym
endm

	.data

classes label word
	@dstrng "unclassified"
	@dstrng "mass storage controller"
	@dstrng "network controller"
	@dstrng "display controller"
	@dstrng "multimedia controller"
	@dstrng "memory controller"
	@dstrng "bridge"
	@dstrng "communication controller"
	@dstrng "generic system peripheral"
	@dstrng "input device controller"
	@dstrng "docking station"
	@dstrng "processor"
	@dstrng "serial bus controller"
	@dstrng "wireless controller"
	@dstrng "intelligent controller"
	@dstrng "satellite communication controller"
	@dstrng "encryption controller"
	@dstrng "signal processing controller"
	@dstrng "processing accelerators"
	@dstrng "non-essential instrumentation"
NUMCLASSES equ ($ - offset classes) / sizeof word

cls01 label word
	@dstrng "SCSI"
	@dstrng "IDE"
	@dstrng "Floppy"
	@dstrng "IPI Bus"
	@dstrng "RAID"
	@dstrng "ATA with ADMA"
	@dstrng "SATA"
	@dstrng "SAS"
	@dstrng "NVM"
	@dstrng "UFS"

cls03 label word
	@dstrng "VGA compatible"

cls04 label word
	@dstrng "Video"
	@dstrng "Audio"
	@dstrng "Telephony"
	@dstrng "HDA"

cls06 label word
	@dstrng "Host"
	@dstrng "ISA"
	@dstrng "EISA"
	@dstrng "MCA"
	@dstrng "PCI to PCI"
	@dstrng "PCMCIA"
	@dstrng "NuBus"
	@dstrng "CardBus"
	@dstrng "RaceWAY"
	@dstrng "PCI to PCI semi-transparent"
	@dstrng "Infiniband to PCI"
	@dstrng "Advanced Switching to PCI"

cls0C label word
	@dstrng "IEEE 1394 FireWire"
	@dstrng "ACCESS"
	@dstrng "SSA"
	@dstrng "USB"
	@dstrng "Fibre Channel"
	@dstrng "SMBus"
	@dstrng "InfiniBand"
	@dstrng "IPMI"
	@dstrng "SERCOS"
	@dstrng "CANbus"
	@dstrng "MIPI"

masks label dword
	dd 0
	dd 1111111111b
	dd 0
	dd 1b
	dd 1111b
	dd 0
	dd 111111111111b
	dd 5 dup (0)
	dd 11111111111b
	dd 7 dup (0)

strings label word
	dw 0
	dw offset cls01
	dw 0
	dw offset cls03
	dw offset cls04
	dw 0
	dw offset cls06
	dw 5 dup (0)
	dw offset cls0C
	dw 7 dup (0)

	.code

	include printf16.inc

getclass proc
	mov cx, CStr("unknown class")
	cmp al, NUMCLASSES
	jnc exit
	push bx
	movzx bx, al
	shl bx, 1
	mov cx, [bx][classes]
	pop bx
exit:
	ret
getclass endp

	.const

helptext label byte
	db "PCIINFO v1.1, displays the PCI config space.",lf
	db "Public Domain, written by Japheth 2024.",lf
	db "Columns:",lf
	db "bus dev func = bus device function",lf
	db "cls sub if   = class subclass programming_interface",lf
	db "rv           = revision",lf
if DISPVENDOR
	db "vend/dev     = vendor ID/device ID",lf
 if DISPSSID
	db "subsysID     = subsystem vendor ID/subsystem ID",lf
 endif
endif
	db "INT          = interrupt line/pin",lf
	db "MSI          = MSI status (y=MSI supported, E=MSI enabled)",lf
	db 0

coltext label byte
	db "bus dev func  cls sub if rv "
if DISPVENDOR
	db "vend/dev  "
 if DISPSSID
	db "subsysID  "
 endif
endif
	db "INT  MSI",lf
	db "------------------------------------------------------------------------",lf
	db 0

	.code

;--- display PCI config space

main proc c argc:word, argv:ptr

	.if argc > 1
		invoke printf, CStr("%s"), offset helptext
		ret
	.endif

	invoke printf, CStr("%s"), offset coltext

;--- use port 0CF8h/0CFCh to read config space 

	mov ecx, 80000008h	; read offset 8 (cls/subclass/programming interface/rev
	mov dx, 0cf8h
nextport:
	mov eax, ecx
	out dx, eax
	add dx, 4
	in eax, dx		; get data at port cfch
	sub dx, 4
	cmp eax, -1
	jz skipaddr
	pushad
	shr ecx, 8
	mov dx, cx
	and dx, 7		; bits 10-8=function
	mov bx, cx
	shr bx, 3
	and bx, 1Fh		; bits 11-15=device#
	shr ecx, 8
	and cx, 0ffh	; bits 16-23=bus#
	mov esi, eax
	mov edi, eax
	mov ebp, eax
	shr esi, 24		; class
	shr edi, 16		; subclass
	shr ebp, 8		; programming interface
	and si, 0ffh
	and di, 0ffh
	and bp, 0ffh
	and ax, 0ffh	; revision
	invoke printf, CStr("%3X %2X %2X      %2X %2X  %2X %2X"), cx, bx, dx, si, di, bp, ax
	mov bp, sp
if DISPVENDOR
	mov eax, [bp].PUSHADS._ecx
	mov al, 0
	mov dx, [bp].PUSHADS._dx
	out dx, eax
	add dx, 4
	in eax, dx
	movzx ecx, ax
	shr eax, 16
	invoke printf, CStr(" %4X/%4X"), cx, ax
 if DISPSSID
	mov eax, [bp].PUSHADS._ecx
	mov al, 2Ch
	mov dx, [bp].PUSHADS._dx
	out dx, eax
	add dx, 4
	in eax, dx
	movzx ecx, ax
	shr eax, 16
	mov edx, eax
	or edx, ecx
	.if ZERO?
		invoke printf, CStr("          ")
	.else
		invoke printf, CStr(" %4X/%4X"), cx, ax
	.endif
 endif
endif

;--- get interrupt line/pin
	mov eax, [bp].PUSHADS._ecx
	mov al, 3Ch
	mov dx, [bp].PUSHADS._dx
	out dx, eax
	add dx, 4
	in eax, dx
	.if al != 0 && al != -1
		movzx dx, ah
		movzx ax, al
		invoke printf, CStr(" %2u/%u "), ax, dx
	.else
		invoke printf, CStr("      ")
	.endif

if 1;DISPMSI
	mov eax, [bp].PUSHADS._ecx
	mov al, 4
	mov dx, [bp].PUSHADS._dx
	out dx, eax
	add dx, 4
	in eax, dx		; read cmd & status
	bt eax, 20		; capability list exists?
	.if CARRY?
		mov eax, [bp].PUSHADS._ecx
		mov al, 34h
		sub dx, 4
		out dx, eax
		add dx, 4
		in eax, dx
		movzx eax, al
		.while al
			mov cl, al
			mov eax, [bp].PUSHADS._ecx
			mov al, cl
			sub dx, 4
			out dx, eax
			add dx, 4
			in eax, dx		; type in AL, next cap in AH
			.break .if al == PCICAPID_MSI
			mov al, ah
		.endw
		.if al == PCICAPID_MSI
			bt eax, 16	; MSI enabled?
			.if CARRY?
				invoke printf, CStr(" E")	; MSI enabled
			.else
				invoke printf, CStr(" y")	; MSI exists, disabled
			.endif
		.else
			invoke printf, CStr("  ")	; cap list exists, but no MSI
		.endif
	.else
		invoke printf, CStr("  ")		; no cap list exists
	.endif
endif

;--- display class & subclass names
	mov eax, esi
	call getclass
	invoke printf, CStr(" %s"), cx
	.if si < NUMCLASSES
		mov eax, [bp].PUSHADS._eax
		.if [esi*4][masks]
			shr eax, 8
			movzx eax, ah
			xor ecx, ecx
			bt [esi*4][masks], eax
			.if CARRY?
				mov bx, [esi*2][strings]
				add ax, ax
				add bx, ax
				mov ax, [bx]
				invoke printf, CStr(" (%s)"), ax
			.endif
		.endif
	.endif
	invoke printf, CStr(lf)
	popad
skipaddr:
	add ecx, 100h
	cmp ecx, 81000008h
	jb nextport
	ret

main endp

	include setargv16.inc

start:
	push cs		; setup a tiny memory model (CS=SS=DS=DGROUP)
	pop ds
	mov ax, ss
	mov dx, cs
	sub ax, dx
	shl ax, 4
	push cs
	pop ss
	add sp, ax
	mov bx, sp
	shr bx, 4
	add bx, 10h
	mov ah, 4Ah	; free unused memory
	int 21h
	call _setargv
	invoke main, [_argc], [_argv]
	mov ah,4ch
	int 21h

	END start
