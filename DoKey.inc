SetClipboard	proto	:DWORD

include	Crypto\biglib.inc
includelib Crypto\biglib.lib


.data
_N1	db	"A327A73178897C09",0
_D1	db	"6F93C7A74DE5B00D",0
_N2	db	"A327A73178897C09",0
_D2	db	"6F93C7A74DE5B00D",0
_N3	db	"A3C62260C8029F61",0
_D3	db	"41C14681A2594835",0

PlainBuff	dd	4 dup(?)

.data?
NameBuffer		db	100 dup(?)
NameLen			dd	?
RandBuff	db	100 dup(?)
FinalSerial	db	100 dup(?)
hashedName  MD5RESULT     <?>
MD5Result	db	50 dup(?)
Tick			dd	?
szFinalSerial		db	128 dup(?)

.code

_rand	proc	Var:DWORD
push ebx
mov eax,Var
xor ebx,ebx
imul edx,dword ptr ds:[ebx+Tick],08088405h
inc edx
mov dword ptr ds:[ebx+Tick],edx
mul edx
mov eax,edx
pop ebx
	Ret
_rand EndP

DoKey	proc	hWnd:DWORD
local	Big_N1:DWORD
local	Big_N2:DWORD
local	Big_N3:DWORD
local	Big_D3:DWORD
local	Big_D2:DWORD
local	Big_D1:DWORD

VMProtectBegin
invoke _BigCreate,0
mov Big_D1,eax
invoke _BigCreate,0
mov Big_D2,eax
invoke _BigCreate,0
mov Big_D3,eax
invoke _BigCreate,0
mov Big_N1,eax
invoke _BigCreate,0
mov Big_N2,eax
invoke _BigCreate,0
mov Big_N3,eax

invoke GetTickCount
add eax,Tick
xor eax,'Jowy'
mov ebx,eax
shl ebx,2
mov Tick,eax
mov PlainBuff,2
mov PlainBuff+4,eax
mov PlainBuff+8,ebx
mov word ptr [PlainBuff+10],3031h
mov byte ptr [PlainBuff+9],'a'
invoke _BigIn,addr _N1,16,Big_N1
invoke _BigIn,addr _D1,16,Big_D1
invoke _BigPowMod,addr PlainBuff, Big_D1, Big_N1, addr PlainBuff
mov esi, offset PlainBuff+11
mov edi, offset szFinalSerial
call _hex_to_string

mov word ptr [PlainBuff+10],3031h
mov byte ptr [PlainBuff+9],'a'
invoke _BigIn,addr _N2,16,Big_N2
invoke _BigIn,addr _D2,16,Big_D2
invoke _BigPowMod,addr PlainBuff, Big_D2, Big_N2, addr PlainBuff
mov esi, offset PlainBuff+11
mov edi, offset szFinalSerial+16
call _hex_to_string
	
mov word ptr [PlainBuff+10],3032h
mov byte ptr [PlainBuff+9],'a'
invoke _BigIn,addr _N3,16,Big_N3
invoke _BigIn,addr _D3,16,Big_D3
invoke _BigPowMod,addr PlainBuff, Big_D3, Big_N3, addr PlainBuff
mov esi, offset PlainBuff+11
mov edi, offset szFinalSerial+32
call _hex_to_string
invoke SetDlgItemText,hWnd,EditSerial,addr szFinalSerial
invoke SetClipboard,addr szFinalSerial
invoke RtlZeroMemory,addr szFinalSerial,sizeof szFinalSerial
invoke _BigDestroy,Big_N1
invoke _BigDestroy,Big_N2
invoke _BigDestroy,Big_N3
invoke _BigDestroy,Big_D1
invoke _BigDestroy,Big_D2
invoke _BigDestroy,Big_D3
VMProtectEnd
	Ret
DoKey EndP

DestroyKey	proc
invoke RtlZeroMemory,addr FinalSerial,sizeof FinalSerial
;invoke RtlZeroMemory,addr szOther,sizeof szOther
	Ret
DestroyKey EndP

_hex_to_string proc
mov ecx, 8
_loop1:
movzx eax, byte ptr [esi]
mov ebx,eax
and eax,15
cmp eax, 9
jg _jg1
add eax,30h
jmp _jmp1
_jg1:
add eax,37h
_jmp1:
shr ebx,4
cmp ebx, 9
jg _jg2
add ebx,30h
jmp _jmp2
_jg2:
add ebx,37h
_jmp2:
shl eax,8
or eax,ebx
stosw
dec esi
loop _loop1
retn
_hex_to_string EndP

SetClipboard	proc	txtSerial:DWORD
local	sLen:DWORD
local	hMem:DWORD
local	pMem:DWORD
	
invoke lstrlen, txtSerial
inc eax
mov sLen, eax
invoke OpenClipboard, 0
invoke GlobalAlloc, GHND, sLen
mov hMem, eax
invoke GlobalLock, eax
mov pMem, eax
mov esi, txtSerial
mov edi, eax
mov ecx, sLen
rep movsb
invoke EmptyClipboard
invoke GlobalUnlock, hMem
invoke SetClipboardData, CF_TEXT, hMem
invoke CloseClipboard
	
ret

SetClipboard endp