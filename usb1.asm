
;--- display USB PCI devices

	.386
	.MODEL FLAT, stdcall
	option casemap:none
	option proc:private

lf	equ 10

CStr macro text:vararg
local sym
	.const
sym db text,0
	.code
	exitm <offset sym>
endm

@pe_file_flags = @pe_file_flags and not 1	;create binary with base relocations

	include dpmi.inc

	.data

rmstack dd ?
bVerbose db 0

	.CODE

	include printf.inc

int_1a proc
local rmcs:RMCS
	mov rmcs.rEDI,edi
	mov rmcs.rESI,esi
	mov rmcs.rEBX,ebx
	mov rmcs.rECX,ecx
	mov rmcs.rEDX,edx
	mov rmcs.rEAX,eax
	mov rmcs.rFlags,3202h
	mov rmcs.rES,0
	mov rmcs.rDS,0
	mov rmcs.rFS,0
	mov rmcs.rGS,0
	mov eax,rmstack
	mov rmcs.rSSSP,eax
	lea edi,rmcs
	mov bx,1Ah
	mov cx,0
	mov ax,0300h
	push ebp
	int 31h
	pop ebp
	jc @F
	mov ah,byte ptr rmcs.rFlags
	sahf
@@:
	mov edi,rmcs.rEDI
	mov esi,rmcs.rESI
	mov ebx,rmcs.rEBX
	mov ecx,rmcs.rECX
	mov edx,rmcs.rEDX
	mov eax,rmcs.rEAX
	ret
int_1a endp

displayuhci proc uses ebx esi edi dwAddr:dword
	ret
displayuhci endp

displayohci proc uses ebx esi edi dwAddr:dword
	ret
displayohci endp

displayehci proc uses ebx esi edi dwAddr:dword
	ret
displayehci endp

displayxhci proc uses ebx esi edi dwAddr:dword
	ret
displayxhci endp


disppci proc uses ebx esi edi dwClass:dword, path:dword

local dwPhysBase:dword
local satacap:byte
local status:word

	mov ebx,path
	mov edi,0
	mov ax,0B10Ah
	call int_1a
	.if ah == 0
		movzx eax,cx
		shr ecx,16
		invoke printf, CStr("  vendor=0x%X, device=0x%X",lf), eax, ecx
	.endif
if 1
	mov edi,4		;PCI CMD
	mov ax,0B109h
	call int_1a
	.if ah == 0
		movzx ecx,cx
		invoke printf, CStr("  CMD=0x%X ([0]=IOSE,[1]=MSE (Memory Space Enable),[2]=BME (Bus Master Enable)",lf), ecx
	.endif
endif
	mov edi,6		;PCI STS (device status
	mov ax,0B109h
	call int_1a
	.if ah == 0
		mov status,cx
	.else
		mov status,0
	.endif

	.if status & 10h	;new capabilities present?
		mov edi,34h
		mov ax,0B108h
		call int_1a
		.if ah == 0
			movzx ecx,cl
			mov edi,ecx
			.repeat
				mov ax,0B109h
				call int_1a
				.break .if ah != 0
				movzx eax,ch
				movzx ecx,cl
				mov edi, eax
				invoke printf, CStr("  capabilities ID=0x%X, next pointer=0x%X",lf), ecx, eax
				.break .if edi == 0
			.until 0
		.endif
	.endif

	mov edi,3Ch
	mov ax,0B108h
	call int_1a
	.if ah == 0
		movzx eax,cl
		invoke printf, CStr("  interrupt line=%u",lf), eax
	.endif

	mov edi,4*4
	mov ax,0B10Ah
	call int_1a
	jc exit
	and cl,0F8h
	mov dwPhysBase, ecx
	push ecx
	invoke printf, CStr("  Controller Base Address=0x%X",lf), ecx
	pop bx
	pop cx
	mov si,0000h
	mov di,1000h
	mov ax,0800h
	int 31h
	jc exit
	push bx
	push cx
	pop ebx

	mov eax,dwClass
	and al,0F0h
	.if al == 00h
		invoke displayuhci, ebx
	.elseif al == 10h
		invoke displayohci, ebx
	.elseif al == 20h
		invoke displayehci, ebx
	.elseif al == 30h
		invoke displayxhci, ebx
	.else
		invoke printf, CStr("unknown USB controller type (class=0x%06X)",lf), dwClass
	.endif
exit:
	ret
disppci endp

finddevice proc uses ebx esi edi dwClass:dword, pszType:ptr, bSilent:byte

	xor esi,esi
	.repeat
		mov ecx,dwClass
		mov ax,0B103h
		call int_1a
		.break .if ah != 0
		.if bVerbose
			movzx eax,ax
			invoke printf, CStr("Int 1ah, ax=B103h, ecx=%X, si=%u: ax=%X, ebx=%X",lf),dwClass,esi,eax,ebx
		.endif
		mov ecx,dwClass
		and cl,0F0h
		.if cl == 0
			mov edi,CStr("UHCI")
		.elseif cl == 10h
			mov edi,CStr("OHCI")
		.elseif cl == 20h
			mov edi,CStr("EHCI")
		.elseif cl == 30h
			mov edi,CStr("XHCI")
		.else
			mov edi,CStr("???")
		.endif
		movzx eax,bh
		movzx ecx,bl
		shr ecx,3
		movzx edx,bl
		and dl,7
		invoke printf, CStr("%s (%s) device (class=0x%06X) found at bus/device/function=%u/%u/%u:",lf),pszType,edi,dwClass,eax,ecx,edx
		invoke disppci, dwClass, ebx
		inc esi
	.until 0
	.if esi==0 && !bSilent
		invoke printf, CStr("no %s device (class=0x%06X) found",lf), pszType, dwClass
	.endif
	mov eax, esi
	ret

finddevice endp

main proc near c argc:dword,argv:dword,envp:dword

local dwClass:dword
local pszType:dword

	mov ebx, argv
	add ebx, 4
	.while argc > 1
		mov esi, [ebx]
		lodsb
		.if al == '-' || al == '/'
			lodsb
			or al,20h
			.if al == 'v'
				mov bVerbose, 1
			.else
				jmp disphelp
			.endif
		.else
			jmp disphelp
		.endif
		add ebx, 4
		dec argc
	.endw
	
	mov ax,100h
	mov bx,40h
	int 31h
	jc exit
	mov word ptr rmstack+0,400h
	mov word ptr rmstack+2,ax

	xor edi,edi
	mov ax,0B101h
	call int_1a
	movzx eax,ax
	.if bVerbose
		push edx
		push eax
		movzx ebx,bx
		movzx ecx,cl
		invoke printf, CStr("Int 1ah, ax=B101h: ax=%X (ok if ah=0), edi=%X (PM entry), edx=%X ('PCI'), bx=%X (Version), cl=%X (last bus)",lf),eax,edi,edx,ebx,ecx
		pop eax
		pop edx
	.endif
	cmp ah,0
	jnz error1
	cmp edx," ICP"
	jnz error1

	mov dwClass, 0C0300h	;search USB
	xor ebx,ebx
	mov pszType, CStr("USB")
	.repeat
		invoke finddevice, dwClass, pszType, 1
		add ebx,eax
		inc dwClass
	.until byte ptr dwClass == 0
	.if !ebx
		invoke printf, CStr("no %s controller (class=0x0C03xx) found",lf), pszType
	.endif
exit:
	ret
disphelp:
	invoke printf, CStr("usb1 - display USB controllers",lf)
	invoke printf, CStr("usage: usb1 [options]",lf)
	invoke printf, CStr("options:",lf)
	invoke printf, CStr("    -v: verbose",lf)
	jmp exit
error1:
	invoke printf, CStr("no PCI BIOS implemented",lf)
	ret
main endp

	include setargv.inc

start32 proc c public
	call _setargv
	invoke main, [_argc], [_argv], 0
	mov ax,4c00h
	int 21h
start32 endp

	END start32

