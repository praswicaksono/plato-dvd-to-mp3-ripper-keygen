.686
.model flat,stdcall
option casemap:none

include	windows.inc
include	kernel32.inc
include	user32.inc
include	gdi32.inc
include comctl32.inc
include	masm32.inc
include	macros.inc
include	VMProtectSDK.inc

includelib	kernel32.lib
includelib	user32.lib
includelib	gdi32.lib
includelib	comctl32.lib
includelib	masm32.lib

include dlg_colors.asm

DlgProc		proto	:DWORD,:DWORD,:DWORD,:DWORD
AboutProc	proto	:DWORD,:DWORD,:DWORD,:DWORD
DoKey		proto	:DWORD

.const
MainDlg	= 100
EditName	= 101
EditSerial	= 102
GenBtn	= 201
AboutBtn	= 202
ExitBtn	= 203
COLORTEXT	equ	Green

DIALOG_BACKGROUND_COLOR	equ 00DD9500h
DIALOG_FRAME_COLOR	equ 00000000h
DIALOG_TEXT_COLOR	equ 00FCFEFCh

EDIT_BOX_COLOR		equ 0062B0FFh
EDIT_BOX_TEXT_COLOR	equ 001E591Eh
EDIT_BOX_FRAME_COLOR	equ 00530000h

BUTTON_COLOR		equ 00C080FFh
BUTTON_TEXT_COLOR	equ 00713800h
BUTTON_FRAME_COLOR	equ 00FCFEFCh

nHeight	=	07ch
nWidth	=	158h
.data
lpString        dd offset szScrText
szScrText		db "The [R]everse [E]ngineers [D]ream TeaM",13,13
				db "proudly to presents",13
				db "another quality release",0
				db "Plato DVD To MP3 Ripper 7.85",13
				db "*KeyMaker*",13,13
				db "Keygenner : H!X",13
				db "Protection : Triple RSA-64",0
				db "[G]reetings [T]o",13
				db "All The RED TeaM",13,0
				db 0	; end value

szFont LOGFONT <-11,0,0,0,FW_NORMAL,0,0,0,0,-1,0,0,02,"Verdana">

Value		dd 4F47452Fh
_void	 	dd ?
_a			dd ?
_b    		dd ?
_c    		dd ?
hDC			HDC	?
rect		RECT	<?>

.data?
hInstance	dd	?
hIcon		dd	?

include	DoKey.inc
include proc.inc

.code
start:
invoke GetModuleHandle,0
mov hInstance,eax

invoke LoadIcon,eax,200
mov hIcon,eax

invoke InitCommonControls
invoke DialogBoxParam,hInstance,MainDlg,0,addr DlgProc,0
invoke ExitProcess,NULL

DlgProc	proc	hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
LOCAL ps:PAINTSTRUCT

.if uMsg == WM_INITDIALOG
invoke SetWindowPos,hWnd,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE + SWP_NOSIZE
invoke SetWindowText,hWnd,chr$("The [R]everse [E]ngineers [D]ream TeaM")
invoke SetDlgItemText,hWnd,EditName,chr$("H!X [RED TeaM]")

invoke MakeOwnerDraw,hWnd,GenBtn
invoke MakeOwnerDraw,hWnd,AboutBtn
invoke MakeOwnerDraw,hWnd,ExitBtn

invoke MakeDialogTransparent,hWnd,225

mov eax,TRUE
ret

.elseif uMsg == WM_PAINT
invoke BeginPaint,hWnd,addr ps
mov ebx,eax

invoke DrawWindowColors,hWnd,ebx,DIALOG_BACKGROUND_COLOR,DIALOG_FRAME_COLOR
invoke DrawControlFrame,hWnd,ebx,MainDlg,EDIT_BOX_FRAME_COLOR

invoke EndPaint,hWnd,addr ps

.elseif uMsg == WM_CTLCOLOREDIT
invoke DrawControlColor,wParam,EDIT_BOX_COLOR,EDIT_BOX_TEXT_COLOR
ret
	
.elseif uMsg == WM_CTLCOLORSTATIC 	
invoke DrawControlColor,wParam,DIALOG_BACKGROUND_COLOR,DIALOG_TEXT_COLOR
ret

.elseif uMsg == WM_DRAWITEM
invoke DrawButtonColor,hWnd,lParam,BUTTON_COLOR,BUTTON_TEXT_COLOR,BUTTON_FRAME_COLOR
ret

.elseif uMsg == WM_MOUSEMOVE
;---enable window movement by click on any position---
mov eax,wParam
.if eax==1
invoke SendMessage,hWnd,WM_SYSCOMMAND,0F012h,0
.endif

.elseif uMsg == WM_COMMAND
.if wParam == GenBtn
invoke GetDlgItemText,hWnd,EditName,addr NameBuffer,sizeof NameBuffer
.if eax < 4
invoke SetDlgItemText,hWnd,EditSerial,chr$("Your Name Is Too Short...")
.elseif eax > 20
invoke SetDlgItemText,hWnd,EditSerial,chr$("Your Name Is Too Long...")
.else
mov NameLen,eax
invoke DoKey,hWnd
.endif

.elseif wParam == AboutBtn
invoke DialogBoxParam,hInstance,744,hWnd,addr AboutProc,0

.elseif wParam == ExitBtn
invoke SendMessage,hWnd,WM_CLOSE,0,0
.endif

.elseif uMsg == WM_CLOSE
invoke EndDialog,hWnd,0
.endif

xor eax,eax
	Ret
DlgProc EndP
end start