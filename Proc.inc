.code
AboutProc PROC hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
  LOCAL ps:PAINTSTRUCT
   
add esp,-50h

.if uMsg == WM_INITDIALOG
mov _a,nHeight
mov _c,0
mov _b,2

invoke GetWindowDC,hWnd
push eax
call DrawProc
invoke SetTimer,hWnd,1,20h,0                           

.elseif uMsg==WM_PAINT 
invoke BeginPaint,hWnd,addr ps
mov edi,eax
push eax
lea ebx,rect
assume ebx:ptr RECT

;lea eax,[ebp-10h]
invoke GetClientRect,hWnd,ebx
invoke CreateSolidBrush,0
invoke FrameRect,edi,ebx,eax
pop eax
invoke BitBlt,eax,0,0,nWidth,nHeight,hDC,0,0,0cc0020h
invoke EndPaint,hWnd,addr ps

.elseif uMsg==WM_TIMER
cmp wParam, 1
jnz _ret
call PixelDraw
mov dword ptr[ebp-10h],0
mov dword ptr[ebp-0ch],0
mov dword ptr[ebp-8],nWidth
mov dword ptr[ebp-4],nHeight
lea eax, [ebp-10h]
invoke InvalidateRect,hWnd,eax,0
                              
.elseif uMsg==WM_CTLCOLORDLG
invoke SetTextColor,wParam,0B48033h
invoke SetBkColor,wParam,0
invoke SetBkMode,wParam,2
invoke CreateSolidBrush,0
ret

.elseif uMsg==WM_LBUTTONDOWN
invoke SendMessage,hWnd,WM_CLOSE,0,0

.elseif uMsg == WM_CLOSE
invoke EndDialog,hWnd,0

.else
xor eax,eax
ret
.endif

_ret:
xor eax,eax
inc eax
ret

AboutProc ENDP

DrawProc     proc near
                               
push ebp
mov ebp,esp
add esp,0FFFFFFD4h
lea eax,[ebp-2ch]
invoke RtlZeroMemory,eax,2ch
mov dword ptr [ebp-2ch],28h

push 20h
call Calc

mov dword ptr[ebp-18h],eax
mov dword ptr[ebp-20h],1
mov dword ptr[ebp-1eh],20h
mov dword ptr[ebp-28h],nWidth
mov dword ptr[ebp-24h],nHeight
mov _void,0
lea eax,[ebp-2ch]
invoke CreateDIBSection,0,eax,0,addr _void,0,0
push eax
invoke CreateCompatibleDC,[ebp+8]
mov hDC, eax
pop edx
invoke SelectObject,eax,edx
invoke CreateFontIndirect,addr szFont

invoke SelectObject,hDC,eax
invoke SetBkMode,hDC,TRANSPARENT
invoke SetTextColor,hDC,COLORTEXT
invoke SetTextAlign,hDC,TA_CENTER
leave
retn 4

DrawProc endp

Calc      proc near

push ebp
mov ebp,esp
mov eax,nWidth
cdq
mul dword ptr[ebp+8]
add eax,1Fh
and eax,0FFFFFFE0h
shr eax,3
cdq
mov ecx,nHeight
mul ecx
leave
retn    4

Calc endp

PixelDraw      proc near

push edi
push esi
push ebx
cld
mov edi,_void
mov ecx,0A6A0h
xor ebx,ebx
xor esi,esi

Y1:
or  ebx,ebx
jz Y2
or esi,esi
jz Y2
cmp ebx,nWidth
jz Y2
cmp esi,nHeight
jnz Y3

Y2:
xor eax, eax
jmp Y4

Y3:
push ecx
push 40h
call SubProc1
add al,40h
mov ah,al
shl eax,40h
mov al, ah
pop ecx

Y4:
stosd
inc ebx
cmp ebx, nWidth
jnz Y5
xor ebx, ebx
inc esi

Y5:
dec ecx
jnz Y1
call SubProc2
xor ecx, ecx
cmp _c, ecx
jnb Y6
inc _c
inc _a
jmp Y7

Y6:
mov _c, 0

Y7:
cld
dec _a
add eax, eax
not eax
cmp _a, eax
jnz Y10
mov edi, lpString
xor eax, eax
or  ecx, 0FFFFFFFFh
repne scasb
cmp byte ptr [edi], 0
jz Y8
mov lpString, edi
jmp Y9

Y8:
push offset szScrText
pop lpString
mov _b, 0

Y9:
mov _a, nHeight

Y10:
pop ebx
pop esi
pop edi
retn
PixelDraw      endp

SubProc1      proc near

push ebp
mov ebp,esp
push edx
push ecx
mov eax,Value
xor edx,edx
mov ecx,1F31Dh
div ecx
mov ecx,eax
mov eax,41A7h
mul edx
mov edx,ecx
mov ecx,eax
mov eax,0B14h
mul edx
sub ecx,eax
xor edx,edx
mov eax,ecx
mov Value,ecx
div dword ptr ds:[ebp+8]
mov eax,edx
pop ecx
pop edx
leave
retn 4

SubProc1      endp

SubProc2      proc near

push ebp
mov ebp,esp
add esp, 0FFFFFFFCh
push esi
push edi
push ebx
mov esi,lpString
invoke lstrlen,esi
mov ebx,eax
inc ebx
push _a
pop [ebp-4]
mov edi,esi

Z1:
cmp byte ptr [esi],0Dh
jz Z2
cmp byte ptr [esi],0
jnz Z3

Z2:
mov cl,[esi]
push ecx
mov byte ptr [esi],0
invoke lstrlen,edi

invoke TextOut,hDC,0a5h,[ebp-4],edi,eax

add dword ptr ds:[ebp-4],0Fh
pop ecx
mov edi,esi
inc edi
mov [esi],cl

Z3:
lodsb
dec ebx
jnz Z1
mov eax,[ebp-4]
sub eax,_a
shr eax, 1
pop ebx
pop edi
pop esi
leave
retn

SubProc2      endp