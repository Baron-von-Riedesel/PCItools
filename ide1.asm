
	.386
	.model flat

@pe_file_flags = @pe_file_flags and not 1	;create binary with base relocations

PUSHADS struct
_edi dd ?
_esi dd ?
_ebp dd ?
_res dd ?
_ebx dd ?
_edx dd ?
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

	.data

	.code

	include printf.inc

IsAHCIdisabled proc stdcall uses esi edi ebx pAHCI:ptr

	mov cx, word ptr pAHCI+0
	mov bx, word ptr pAHCI+2
	mov di, 100h
	mov si, 0
	mov ax, 800h
	int 31h
	jc error
	push bx
	push cx
	pop eax
	mov eax, [eax+4]  ; HBA.GHC, bit 31: AHCI enabled?
	and eax, eax
	js error
	or eax, -1
	ret
error:
	xor eax, eax
	ret

IsAHCIdisabled endp

main proc

local dwBase1:dword
local dwBase2:dword
local dwBase3:dword
local dwBase4:dword
local dwBase5:dword

	invoke printf, CStr("Busmaster IDE controllers:",10)
	mov ecx, 80000008h
	mov dx, 0cf8h
nextport:
	mov eax, ecx
	out dx, eax
	add dx, 4
	in eax, dx
	sub dx, 4
	cmp eax, -1
	jz skipaddr
	shr eax, 8
	mov esi, eax
	cmp eax, 10601h ; AHCI device?
	jz @F
	and al,80h
	cmp eax, 10180h
	jnz skipaddr
@@:
	pushad
	shr ecx, 8
	mov edx, ecx
	and edx, 7		; bits 10-8=function
	mov ebx, ecx
	shr ebx, 3
	and ebx, 1Fh	; bits 11-15=device#
	shr ecx, 8
	and ecx, 0ffh	; bits 16-23=bus#
	invoke printf, CStr("bus/dev/fn=%u/%u/%u: class=%X "), ecx, ebx, edx, esi
	mov ecx, [esp].PUSHADS._ecx
	mov edx, [esp].PUSHADS._edx
	cmp esi,10601h
	jnz @F
	mov cl,16+5*4
	call getbase
	invoke IsAHCIdisabled, eax
	mov ecx, [esp].PUSHADS._ecx
	mov edx, [esp].PUSHADS._edx
	and eax, eax
	jnz @F
	invoke printf, CStr("SATA controller, AHCI mode enabled",10)
	jmp dispdone
@@:
	mov cl,16+0*4
	call getbase
	mov dwBase1, eax
	call getbase
	mov dwBase2, eax
	call getbase
	mov dwBase3, eax
	call getbase
	mov dwBase4, eax
	call getbase
	mov dwBase5, eax
	invoke printf, CStr("pri=%X/%X sec=%X/%X dma=%X",10), dwBase1, dwBase2, dwBase3, dwBase4, dwBase5
dispdone:
	popad
skipaddr:
	add ecx, 100h
	cmp ecx, 81000008h
	jb nextport
	ret
getbase:
	mov eax, ecx
	out dx, eax
	add dl, 4
	in eax, dx
	sub dl, 4
	add cl, 4
	and al, 0feh
	retn
main endp

start:
	call main
	mov ah,4ch
	int 21h

	END start
