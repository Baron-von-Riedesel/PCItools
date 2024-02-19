
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

displayvga proc uses ebx esi edi dwPath:dword

local dwPhysBase:dword
local dwBaseL:dword
local dwBaseH:dword

	mov edi, 4*4
	mov ebx,dwPath
	mov ax,0B10Ah
	call int_1a
	jc exit
	mov dwPhysBase, ecx
	invoke printf, CStr("  BAR0=0x%X",lf), ecx

	mov edi, 5*4
	mov ax,0B10Ah
	call int_1a
	jc exit
	mov dwBaseL,ecx
	mov edi, 6*4
	mov ax,0B10Ah
	call int_1a
	jc exit
	mov dwBaseH,ecx

	.if dwBaseL & 4
		mov edx,dwBaseH
		mov eax,dwBaseL
		and al,0F0h
		invoke printf, CStr("  BAR1=0x%lX (64-bit)",lf), edx::eax
	.else
		invoke printf, CStr("  BAR1=0x%X",lf), dwBaseL
		invoke printf, CStr("  BAR2=0x%X",lf), dwBaseH
	.endif

	mov edi, 7*4
	mov ax,0B10Ah
	call int_1a
	jc exit
	mov dwBaseL, ecx

	mov edi, 8*4
	mov ax,0B10Ah
	call int_1a
	jc exit
	mov dwBaseH, ecx

	.if dwBaseL & 4
		mov edx,dwBaseH
		mov eax,dwBaseL
		and al,0F0h
		invoke printf, CStr("  BAR3=0x%lX (64-bit)",lf), edx::eax
	.else
		invoke printf, CStr("  BAR3=0x%X",lf), dwBaseL
		invoke printf, CStr("  BAR4=0x%X",lf), dwBaseH
	.endif

	mov edi, 9*4
	mov ax,0B10Ah
	call int_1a
	jc exit
	.if cl & 1
		and cl,0F0h
		invoke printf, CStr("  BAR5=0x%X (IO-Port)",lf), ecx
	.else
		invoke printf, CStr("  BAR5=0x%X",lf), ecx
	.endif

exit:
	ret
displayvga endp

disppci proc uses ebx edi dwClass:dword, path:dword

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

	invoke displayvga, ebx
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
		movzx eax,bh
		movzx ecx,bl
		shr ecx,3
		movzx edx,bl
		and dl,7
		invoke printf, CStr("%s device (class=0x%06X) found at bus/device/function=%u/%u/%u:",lf),pszType,dwClass,eax,ecx,edx
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

	mov pszType, CStr("VGA")
	mov dwClass, 000100h
	.repeat
		invoke finddevice, dwClass, pszType, 1
		add ebx,eax
		inc dwClass
	.until byte ptr dwClass == 0

	mov pszType, CStr("VGA")
	mov dwClass, 030000h
	.repeat
		invoke finddevice, dwClass, pszType, 1
		add ebx,eax
		inc dwClass
	.until byte ptr dwClass == 0

exit:
	ret
error1:
	invoke printf, CStr("no PCI BIOS implemented",lf)
	ret
main endp

start32 proc c public
	call main
	mov ax,4c00h
	int 21h
start32 endp

	END start32

