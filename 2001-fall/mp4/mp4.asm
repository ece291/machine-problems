; ECE 291 Fall 2001 MP4    
; -- Paint291 --
;
; Completed By:
;  Your Name
;
; Josh Potts
; Guest Author - Ryan Chmiel
; University of Illinois Urbana Champaign
; Dept. of Electrical & Computer Engineering
;
; Ver 1.0

%include "lib291.inc"
%include "libmp4.inc"

	BITS 32

	GLOBAL _main

; Define functions and variables used by main()
EXTERN _LoadPNG
_LoadPNG_arglen		EQU	18

; Define Contstants

	DOWNARROW	EQU	80
	RIGHTARROW	EQU	77
	LEFTARROW	EQU	75
	UPARROW		EQU	72

	CANVAS_X	EQU	20
	CANVAS_Y	EQU	20

	NUM_MENU_ITEMS	EQU	11

	BKSP		EQU	8
	ESC		EQU	1
	ENTERKEY	EQU	13
	SPACE		EQU	57
	LSHIFT		EQU	42
	RSHIFT		EQU	54


	SECTION .bss


_GraphicsMode	resw	1	; Graphics mode #

_kbINT		resb	1	; Keyboard interrupt #
_kbIRQ		resb	1	; Keyboard IRQ
_kbPort		resw	1	; Keyboard port

_MouseSeg	resw	1       ; real mode segment for MouseCallback
_MouseOff	resw	1	; real mode offset for MouseCallback
_MouseX		resw	1       ; X coordinate position of mouse on screen
_MouseY		resw	1       ; Y coordinate position of mouse on screen
					
_ScreenOff	resd	1	; Screen image offset
_CanvasOff	resd	1	; Canvas image offset
_OverlayOff	resd	1	; Overlay image offset
_FontOff	resd	1	; Font image offset
_MenuOff	resd	1	; Menu image offset
_TitleOff	resd	1	; Title Bar image offset

_MPFlags	resb	1	; program flags
				; Bit 0 - Exit program
				; Bit 1 - Left mouse button (LMB) status: set if down, cleared if up
				; Bit 2 - Change in LMB status: set if button status
				;         moves from pressed->released or vice-versa
				; Bit 3 - Right shift key status: set if down, cleared if up
				; Bit 4 - Left shift key status: set if down, cleared if up
				; Bit 5 - Key other than shift was pressed
				; Bit 6 - Not Used Anymore
				; Bit 7 - Status of chosen color: set if obtained with user input,
                                ;         cleared if obtained with eyedrop (you do not have to deal
				;         with this - the library code uses it)
				
_MenuItem	resb	1	; selected menu item

; line algorithm variables				
_x		resw	1
_y		resw	1
_dx		resw	1
_dy		resw	1
_lineerror	resw	1
_xhorizinc	resw	1
_xdiaginc	resw	1
_yvertinc	resw	1
_ydiaginc	resw	1
_errordiaginc	resw	1
_errornodiaginc	resw	1
 
; circle algorithm variables
_radius		resw	1
_circleerror	resw	1
_xdist		resw	1
_ydist		resw	1

; flood fill variables
_PointQueue	resd	1
_QueueHead	resd	1
_QueueTail	resd	1

_key		resb	1


	SECTION .data

	
; Required image files
_FontFN		db	'font.png',0   
_MenuFN		db	'menu.png',0
_TitleFN	db	'title.png',0

; Defined color values
_CurrentColor	dd	0ffff0000h	; current color
_ColorBlue	dd	0ff0033ffh
_ColorWhite	dd	0ffffffffh
_ColorBlack	dd	0ff000000h
_ColorHalfBlack dd	0cc000000h

_buffer		db	'       ','$'

_ColorString1	db	'Enter numerical values for','$'
_ColorString2	db	'each channel (ARGB), and','$'
_ColorString3	db	'separate each number by a','$'
_ColorString4	db	'space (ex. 127 255 255 0).','$'
 
_QwertyNames
	db	0	; filler
	db	0,'1','2','3','4','5','6','7','8','9','0','-','=',BKSP
	db	0, 'q','w','e','r','t','y','u','i','o','p','[',']',ENTERKEY
	db	0,'a','s','d','f','g','h','j','k','l',';',"'","`"
	db	0,'\','z','x','c','v','b','n','m',",",'.','/',0,'*'
	db	0, ' ', 0, 0,0,0,0,0,0,0,0,0,0 ; F1-F10
	db	0,0	; numlock, scroll lock
	db	0, 0, 0, '-'
	db	0, 0, 0, '+'
	db	0, 0, 0, 0
	db	0, 0; sysrq
_QwertyNames_end resb 0

_QwertyShift
	db	0	; filler
	db	0,'!','@','#','$','%','^','&','*','(',')','_','+',BKSP
	db	0, 'Q','W','E','R','T','Y','U','I','O','P','{','}',ENTERKEY
	db	0,'A','S','D','F','G','H','J','K','L',':','"','~'
	db	0,'|','Z','X','C','V','B','N','M',"<",'>','?',0,'*'
	db	0, ' ', 0, 0,0,0,0,0,0,0,0,0,0 ; F1-F10
	db	0,0	; numlock, scroll lock
	db	0, 0, 0, '-'
	db	0, 0, 0, '+'
	db	0, 0, 0, 0
	db	0, 0; sysrq
_QwertyShift_end resb 0

_TextInputString	times 80 db 0,'$'
_ColorInputString	times 15 db 0,'$'

_RoundingFactor	dd	000800080h, 00000080h


	SECTION .text


_main
	call	_LibInit

	; Allocate Screen Image buffer
	invoke	_AllocMem, dword 640*480*4
	cmp	eax, -1
	je	near .memerror
	mov	[_ScreenOff], eax

	; Allocate Canvas Image buffer
	invoke	_AllocMem, dword 480*400*4
	cmp	eax, -1
	je	near .memerror
	mov	[_CanvasOff], eax

	; Allocate Overlay Image buffer
	invoke	_AllocMem, dword 480*400*4
	cmp	eax, -1
	je	near .memerror
	mov	[_OverlayOff], eax

	; Allocate Font Image buffer
	invoke	_AllocMem, dword 2048*16*4
	cmp	eax, -1
	je	near .memerror
	mov	[_FontOff], eax  

	; Allocate Menu Image buffer
	invoke	_AllocMem, dword 400*100*4
	cmp	eax, -1
	je	near .memerror
	mov	[_MenuOff], eax 

	; Allocate Title Bar Image buffer
	invoke	_AllocMem, dword 640*20*4
	cmp	eax, -1
	je	near .memerror
	mov	[_TitleOff], eax 

	; Allocate Point Queue
	invoke	_AllocMem, dword 480*400*4*40
	cmp	eax, -1
	je	near .memerror
	mov	[_PointQueue], eax

	; Load image files
	invoke	_LoadPNG, dword _FontFN, ds, dword [_FontOff], dword 0, dword 0
	invoke	_LoadPNG, dword _MenuFN, ds, dword [_MenuOff], dword 0, dword 0
	invoke	_LoadPNG, dword _TitleFN, ds, dword [_TitleOff], dword 0, dword 0
 
	; Graphics init
	invoke	_InitGraphics, dword _kbINT, dword _kbIRQ, dword _kbPort
	test	eax, eax
	jnz	near .graphicserror

	; Find graphics mode: 640x480x32, allow driver-emulated modes
	invoke	_FindGraphicsMode, word 640, word 480, word 32, dword 1
	mov	[_GraphicsMode], ax

	; Keyboard/Mouse init
	call	_InstallKeyboard
	test	eax, eax
	jnz	near .keyboarderror
	invoke	_SetGraphicsMode, word [_GraphicsMode]
	test	eax, eax
	jnz	.setgraphicserror
	call	_InstallMouse
	test	eax, eax
	jnz	.mouseerror

	; Show mouse cursor	
	mov	dword [DPMI_EAX], 01h
	mov	bx, 33h
	call	DPMI_Int

	call	_MP4Main	

	; Shutdown and cleanup	      

.mouseerror
	call	_RemoveMouse

.setgraphicserror
	call	_UnsetGraphicsMode

.keyboarderror
	call	_RemoveKeyboard

.graphicserror
	call	_ExitGraphics

.memerror
	call	_MP4LibExit
	call	_LibExit
	ret


;--------------------------------------------------------------
;--          Replace Library Calls with your Code!           --
;--          Do not forget to add Function Headers           --
;--------------------------------------------------------------


;--------------------------------------------------------------
;--                      PointInBox()                        --
;--------------------------------------------------------------
proc _PointInBox
.X		arg	2
.Y		arg	2
.BoxULCornerX	arg	2
.BoxULCornerY	arg	2
.BoxLRCornerX	arg	2
.BoxLRCornerY	arg	2

	invoke	_libPointInBox, word [ebp+.X], word [ebp+.Y], word [ebp+.BoxULCornerX], word [ebp+.BoxULCornerY], word [ebp+.BoxLRCornerX], word [ebp+.BoxLRCornerY]
	ret

endproc
_PointInBox_arglen	EQU	12	   

;--------------------------------------------------------------
;--                       GetPixel()                         --
;--------------------------------------------------------------
proc _GetPixel
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X		arg	2
.Y		arg	2

	invoke	_libGetPixel, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [ebp+.X], word [ebp+.Y]
	ret

endproc
_GetPixel_arglen	EQU	12

;--------------------------------------------------------------
;--                      DrawPixel()                         --
;--------------------------------------------------------------
proc _DrawPixel
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X		arg	2
.Y		arg	2
.Color		arg	4

	invoke	_libDrawPixel, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [ebp+.X], word [ebp+.Y], dword [ebp+.Color]
	ret

endproc
_DrawPixel_arglen	EQU	16

;--------------------------------------------------------------
;--                       DrawLine()                         --
;--------------------------------------------------------------
proc _DrawLine
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X1		arg	2
.Y1		arg	2
.X2		arg	2
.Y2		arg	2
.Color		arg	4

	invoke	_libDrawLine, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [ebp+.X1], word [ebp+.Y1], word [ebp+.X2], word [ebp+.Y2], dword [ebp+.Color]
	ret

endproc
_DrawLine_arglen	EQU	20
	  
;--------------------------------------------------------------
;--                       DrawRect()                         --
;--------------------------------------------------------------
proc _DrawRect
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X1		arg	2
.Y1		arg	2
.X2		arg	2
.Y2		arg	2
.Color		arg	4
.FillRectFlag	arg	4

	invoke	_libDrawRect, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [ebp+.X1], word [ebp+.Y1], word [ebp+.X2], word [ebp+.Y2], dword [ebp+.Color], dword [ebp+.FillRectFlag]
	ret

endproc
_DrawRect_arglen	EQU	24

;--------------------------------------------------------------
;--                      DrawCircle()                        --
;--------------------------------------------------------------
proc _DrawCircle
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X		arg	2
.Y		arg	2
.Radius		arg	2
.Color		arg	4
.FillCircleFlag	arg	4

	invoke	_libDrawCircle, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [ebp+.X], word [ebp+.Y], word [ebp+.Radius], dword [ebp+.Color], dword [ebp+.FillCircleFlag]
	ret

endproc
_DrawCircle_arglen	EQU	22

;--------------------------------------------------------------
;--                        DrawText()                        --
;--------------------------------------------------------------
proc _DrawText
.StringOff	arg	4
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X		arg	2
.Y		arg	2
.Color		arg	4

	invoke	_libDrawText, dword [ebp+.StringOff], dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [ebp+.X], word [ebp+.Y], dword [ebp+.Color]
	ret

endproc
_DrawText_arglen	EQU	20

;--------------------------------------------------------------
;--                       ClearBuffer()                      --
;--------------------------------------------------------------
proc _ClearBuffer
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.Color		arg	4

	invoke	_libClearBuffer, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], dword [ebp+.Color]
	ret

endproc
_ClearBuffer_arglen	EQU	12

;--------------------------------------------------------------
;--                      CopyBuffer()                        --
;--------------------------------------------------------------
proc _CopyBuffer
.SrcOff		arg	4
.SrcWidth	arg	2
.SrcHeight	arg	2
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X		arg	2
.Y		arg	2

	invoke	_libCopyBuffer, dword [ebp+.SrcOff], word [ebp+.SrcWidth], word [ebp+.SrcHeight], dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [ebp+.X], word [ebp+.Y]
	ret

endproc
_CopyBuffer_arglen	EQU	20


;--------------------------------------------------------------
;--                    ComposeBuffers()                      --
;--------------------------------------------------------------
proc _ComposeBuffers
.SrcOff		arg	4
.SrcWidth	arg	2
.SrcHeight	arg	2
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X	        arg	2
.Y		arg	2

	invoke	_libComposeBuffers, dword [ebp+.SrcOff], word [ebp+.SrcWidth], word [ebp+.SrcHeight], dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [ebp+.X], word [ebp+.Y]
	ret

endproc
_ComposeBuffers_arglen	EQU	20

;--------------------------------------------------------------
;--                        BlurBuffer()                      --
;--------------------------------------------------------------
proc _BlurBuffer
.SrcOff		arg	4
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2

	invoke	_libBlurBuffer, dword [ebp+.SrcOff], dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight]
	ret

endproc
_BlurBuffer_arglen	EQU	12

;--------------------------------------------------------------
;--                        FloodFill()                       --
;--------------------------------------------------------------
proc _FloodFill
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X		arg	2
.Y		arg	2
.Color		arg	4
.ComposeFlag	arg	4

	invoke	_libFloodFill, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [ebp+.X], word [ebp+.Y], dword [ebp+.Color], dword [ebp+.ComposeFlag]
	ret

endproc
_FloodFill_arglen	EQU	20

;--------------------------------------------------------------
;--                    InstallKeyboard()                     --
;--------------------------------------------------------------
_InstallKeyboard
        call	_libInstallKeyboard
	ret

;--------------------------------------------------------------
;--                    RemoveKeyboard()                      --
;--------------------------------------------------------------
_RemoveKeyboard
	call	_libRemoveKeyboard
	ret

;--------------------------------------------------------------
;--                        KeyboardISR()                     --
;--------------------------------------------------------------
_KeyboardISR
	call	_libKeyboardISR	
	ret
_KeyboardISR_end

;--------------------------------------------------------------
;--                      InstallMouse()                      --
;--------------------------------------------------------------
_InstallMouse
        call	_libInstallMouse
        ret			    

;--------------------------------------------------------------
;--                        RemoveMouse()                     --
;--------------------------------------------------------------
_RemoveMouse
        call	_libRemoveMouse
        ret

;--------------------------------------------------------------
;--                        MouseCallback()                   --
;--------------------------------------------------------------
proc _MouseCallback
.DPMIRegsPtr   arg     4

	invoke	_libMouseCallback, dword [ebp+.DPMIRegsPtr]
	ret

endproc
_MouseCallback_end
_MouseCallback_arglen	EQU	4
