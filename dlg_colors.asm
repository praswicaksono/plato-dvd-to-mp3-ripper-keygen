
;******************************************************************************
;* PROTOTYPES                                                                 *
;******************************************************************************
DrawWindowColors			PROTO :DWORD,:DWORD,:DWORD,:DWORD	
DrawControlFrame			PROTO :DWORD,:DWORD,:DWORD,:DWORD
DrawControlColor			PROTO :DWORD,:DWORD,:DWORD
DrawButtonColor				PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MakeOwnerDraw				PROTO :DWORD,:DWORD
MakeDialogTransparent			PROTO :DWORD,:DWORD


;******************************************************************************
;* CODE                                                                       *
;******************************************************************************
.code

;---use on WM_PAINT for each control---
align 16
DrawControlFrame proc uses ebx esi edi _handle:dword,_hdc:dword,_control_id:dword,_frame_color:dword

	LOCAL rect_dlg		:RECT
	LOCAL rect_window	:RECT
	LOCAL hdc		:dword
			
	invoke GetDlgItem,_handle,_control_id
	mov esi,eax
	
	lea ebx,rect_dlg
	assume ebx:ptr RECT
	
	invoke GetWindowRect,esi,ebx
	
	;---get relative position of the control to our window--
	lea edi,rect_window
	assume edi:ptr RECT
	invoke GetWindowRect,_handle,edi
	
	mov eax,[edi].left
	sub [ebx].left,eax
	mov eax,[edi].top
	sub [ebx].top,eax
	
	push [ebx].left
	push [ebx].top
	
	;---get size of our control---
	invoke GetClientRect,esi,ebx
	
	;---add position to dlg rect struct---
	pop [ebx].top
	pop [ebx].left
	
	mov eax,[ebx].top
	add [ebx].bottom,eax
	
	mov eax,[ebx].left
	add [ebx].right,eax
	
	;---make rect bigger---
	sub [ebx].left,1
	sub [ebx].top,1
	add [ebx].right,1
	add [ebx].bottom,1
	
	;---draw frame---
	invoke CreateSolidBrush,_frame_color
	invoke FrameRect,_hdc,ebx,eax
	
	assume ebx:nothing
	assume edi:nothing
	
	ret
DrawControlFrame endp


;---use on WM_PAINT---
align 16
DrawWindowColors proc uses ebx _handle:dword,_hdc:dword,_background_color:dword,_frame_color:dword

	LOCAL rect	:RECT
	LOCAL hdc	:dword
	
	lea ebx,rect
	assume ebx:ptr RECT
	
	invoke GetClientRect,_handle,ebx

	invoke CreateSolidBrush,_background_color	;Dialog BackgroundColor    
	invoke FillRect,_hdc,ebx,eax
	
	invoke CreateSolidBrush,_frame_color
	invoke FrameRect,_hdc,ebx,eax
	
	assume ebx:nothing
	ret
DrawWindowColors endp


;---use on WM_CTLCOLOREDIT---
align 16
DrawControlColor proc _wparam:dword,_background_color:dword,_text_color:dword
	;---set custom colors of the EDIT boxes---
	invoke SetTextColor,_wparam,_text_color		;TextColor
	invoke SetBkMode,_wparam,TRANSPARENT		;Background of Text or SetBkColor
	invoke CreateSolidBrush,_background_color	;BackgroundColor
	ret
DrawControlColor endp


;---use on WM_INITDIALOG
align 16
MakeOwnerDraw proc _dlghandle:dword,_id:dword
	pushad
	
	;---make button owner draw---
	invoke GetDlgItem,_dlghandle,_id
	invoke SendMessage,eax,BM_SETSTYLE,BS_OWNERDRAW,TRUE
	
	popad
	ret
MakeOwnerDraw endp


;---use on WM_DRAWITEM---
align 16
DrawButtonColor proc uses esi _dialoghandle:dword,_lparam:dword,_background_color:dword,_text_color:dword,_frame_color:dword

	LOCAL sBtnText [256]:BYTE
	
	;use "MakeOwnerDraw" function on WM_INITDIALOG before!
	
	;---Button Colors---
	mov esi,_lparam
	assume esi:ptr DRAWITEMSTRUCT
	
	.if [esi].CtlType==ODT_BUTTON
	
		;---frame color---
		invoke CreatePen,PS_INSIDEFRAME,1,_frame_color
		invoke SelectObject,[esi].hdc,eax
		
		;---Background Color---
		invoke CreateSolidBrush,_background_color		
		invoke SelectObject,[esi].hdc,eax
		
		;---draw frame---
		invoke RoundRect,[esi].hdc,[esi].rcItem.left,[esi].rcItem.top,[esi].rcItem.right,[esi].rcItem.bottom,5,5
		
		.if [esi].itemState & ODS_SELECTED
		    invoke OffsetRect,addr [esi].rcItem,1,1
		.endif
		
		;---write the text---
		invoke GetDlgItemText,_dialoghandle,[esi].CtlID,addr sBtnText,sizeof sBtnText
		invoke SetBkMode,[esi].hdc,TRANSPARENT
		invoke SetTextColor,[esi].hdc,_text_color		;ButtonText Color
		invoke DrawText,[esi].hdc,addr sBtnText,-1,addr [esi].rcItem,DT_CENTER or DT_VCENTER or DT_SINGLELINE
		
		;---move text when button pressed---
		.if [esi].itemState & ODS_SELECTED
		    invoke OffsetRect,addr [esi].rcItem,-1,-1
		.endif
		
	.endif
	
	assume esi:nothing
	
	mov eax,TRUE
	ret
DrawButtonColor endp


;---use on WM_INITDIALOG---
align 16
MakeDialogTransparent proc _handle:dword,_transvalue:dword
	
	LOCAL local_retvalue:byte
	
	pushad
	mov local_retvalue,0
	
	invoke GetModuleHandle,chr$("user32.dll")
	invoke GetProcAddress,eax,chr$("SetLayeredWindowAttributes")
	.if eax!=0
		mov edi,eax
		mov esi,_handle
		
		invoke	GetWindowLong,esi,GWL_EXSTYLE			;get EXSTYLE
		.if eax!=0
			or eax,WS_EX_LAYERED				;eax = oldstlye + new style(WS_EX_LAYERED)
			
			invoke SetWindowLong,esi,GWL_EXSTYLE,eax
			.if eax!=0
				push LWA_ALPHA
				push _transvalue			;set level of transparency
				push 0					;transparent color 0-255 (0=transparent)
				push esi				;window handle
				call edi				;call SetLayeredWindowAttributes
				.if eax!=0
					mov local_retvalue,1
				.endif	
			.endif
		.endif
	.endif	
	
	popad
	movzx eax,local_retvalue
	ret
MakeDialogTransparent endp