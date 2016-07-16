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

;EXTERN	_LoadPNG

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

_MenuLocations	dw	(CANVAS_X+500), (CANVAS_Y+10), (CANVAS_X+500)+39, (CANVAS_Y+10)+39
		dw	(CANVAS_X+560), (CANVAS_Y+10), (CANVAS_X+560)+39, (CANVAS_Y+10)+39
		dw	(CANVAS_X+500), (CANVAS_Y+70), (CANVAS_X+500)+39, (CANVAS_Y+70)+39
		dw	(CANVAS_X+560), (CANVAS_Y+70), (CANVAS_X+560)+39, (CANVAS_Y+70)+39
		dw	(CANVAS_X+500), (CANVAS_Y+130), (CANVAS_X+500)+39, (CANVAS_Y+130)+39
		dw	(CANVAS_X+560), (CANVAS_Y+130), (CANVAS_X+560)+39, (CANVAS_Y+130)+39
		dw	(CANVAS_X+500), (CANVAS_Y+190), (CANVAS_X+500)+39, (CANVAS_Y+190)+39
		dw	(CANVAS_X+560), (CANVAS_Y+190), (CANVAS_X+560)+39, (CANVAS_Y+190)+39
		dw	(CANVAS_X+500), (CANVAS_Y+250), (CANVAS_X+500)+39, (CANVAS_Y+250)+39
		dw	(CANVAS_X+560), (CANVAS_Y+250), (CANVAS_X+560)+39, (CANVAS_Y+250)+39
		dw	(CANVAS_X+500), (CANVAS_Y+310), (CANVAS_X+500)+39, (CANVAS_Y+310)+39

_ProcessMenu	dd	_MP4Main.HandlePen,  _MP4Main.HandleLine, _MP4Main.HandleRect, _MP4Main.HandleFilledRect, _MP4Main.HandleCircle, _MP4Main.HandleFilledCircle
		dd	_MP4Main.HandleText, _MP4Main.HandleFill, _MP4Main.HandleEyedrop, _MP4Main.HandleBlur, _MP4Main.HandleColor
	
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
	invoke	_LoadPNG, dword _FontFN, dword [_FontOff], dword 0, dword 0 
	invoke	_LoadPNG, dword _MenuFN, dword [_MenuOff], dword 0, dword 0 
	invoke	_LoadPNG, dword _TitleFN, dword [_TitleOff], dword 0, dword 0 
 
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

;--------------------------------------------------------------
;--                    DrawBackground()                      --
;--------------------------------------------------------------
proc _DrawBackground
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2

	invoke	_ClearBuffer, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], dword 0
	invoke	_DrawRect, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word CANVAS_X-2, word CANVAS_Y-2, word CANVAS_X+481, word CANVAS_Y+401, dword [_ColorWhite], dword 0
	invoke	_DrawRect, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word CANVAS_X-1, word CANVAS_Y-1, word CANVAS_X+480, word CANVAS_Y+400, dword [_ColorWhite], dword 0
	invoke	_CopyBuffer, dword [_MenuOff], word 100, word 400, dword [_ScreenOff], word 640, word 480, word CANVAS_X+500, word CANVAS_Y+10
	invoke	_DrawRect, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word (CANVAS_X+560), word (CANVAS_Y+310), word CANVAS_X+599, word CANVAS_Y+349, dword [_ColorWhite], dword 0
	invoke	_DrawRect, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word (CANVAS_X+560)-1, word (CANVAS_Y+310)-1, word CANVAS_X+599+1, word CANVAS_Y+349+1, dword [_ColorWhite], dword 0
	invoke	_CopyBuffer, dword [_TitleOff], word 640, word 20, dword [_ScreenOff], word 640, word 480, word 0, word 440
	movzx	eax, byte [_MPFlags]
	shr	al, 7
	invoke	_FloodFill, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word (CANVAS_X+560)+20, word (CANVAS_Y+310)+20, dword [_CurrentColor], eax
	ret

endproc
_DrawBackground_arglen	EQU	8

;--------------------------------------------------------------
;--                        MP4Main()                         --
;--------------------------------------------------------------
_MP4Main
	; Init MP variables/flags
	mov	byte [_MenuItem], -1		        
	mov	byte [_MPFlags], 10000000b
	
	; Draw initial screen
	invoke	_DrawBackground, dword [_ScreenOff], word 640, word 480
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	
.MPLoop
	; Check for exit
	test	byte [_MPFlags], 00000001b
	jnz	near .MainDone

	; Draw Background
	invoke	_DrawBackground, dword [_ScreenOff], word 640, word 480

	; Check for current menu item
	movsx	esi, byte [_MenuItem]
	cmp	esi, 0
	js	near .CheckLMB

	; Draw rectangles around selected menu item
	mov	ax, [_MenuLocations+esi*8+0]
	mov	bx, [_MenuLocations+esi*8+2]
	mov	cx, [_MenuLocations+esi*8+4]
	mov	dx, [_MenuLocations+esi*8+6]
	sub	ax, 10
	sub	bx, 10
	add	cx, 10
	add	dx, 10
	push	eax
	push	ebx
	push	ecx
	push	edx
	invoke	_DrawRect, dword [_ScreenOff], word 640, word 480, ax, bx, cx, dx, dword [_ColorBlue], dword 0
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	inc	ax
	inc	bx
	dec	cx
	dec	dx
	invoke	_DrawRect, dword [_ScreenOff], word 640, word 480, ax, bx, cx, dx, dword [_ColorBlue], dword 0	

.CheckLMB
	; Check for new mouse press
	test	byte [_MPFlags], 00000100b
	jz	near .CheckSpecialOptions
	test	byte [_MPFlags], 00000010b
	jz	near .NoEventProcess
	jmp	.LMBPress

.CheckSpecialOptions
	; Special options are text and color selection because they don't 
	; require mouse clicks on the canvas to start drawing
	cmp	byte [_MenuItem], 6
	je	near .HandleText
	cmp	byte [_MenuItem], 10
	je	near .HandleColor
	jmp	.NoEventProcess

.LMBPress
	; Clear "change in LMB status" flag
	and	byte [_MPFlags], 11111011b   	
	xor	ecx, ecx

	; Check to see if new menu item was selected
.MenuSelectionLoop
	cmp	ecx, NUM_MENU_ITEMS
	je	near .NoNewMenuSelection
	push	ecx
	invoke	_PointInBox, word [_MouseX], word [_MouseY], word [_MenuLocations+ecx*8+0], word [_MenuLocations+ecx*8+2], word [_MenuLocations+ecx*8+4], word [_MenuLocations+ecx*8+6]
	pop	ecx
	test	eax, eax
	jnz	.NewSelectionMade
	inc	ecx
	jmp	.MenuSelectionLoop

.NewSelectionMade
	mov	[_MenuItem], cl

.NoNewMenuSelection
	movsx	ebx, byte [_MenuItem]
	cmp	ebx, 0
	js	near .NoEventProcess

	; Check to see if mouse is in canvas
	push	ebx
	invoke	_PointInBox, word [_MouseX], word [_MouseY], word CANVAS_X, word CANVAS_Y, word CANVAS_X+479, word CANVAS_Y+399
	pop	ebx
	test	eax, eax
	jz	near .NoEventProcess

	; Draw on the canvas according to the current menu item
	jmp	[_ProcessMenu+ebx*4]	      		

; General comments for the individual menu items
; ***************************************************************************************
;
; Each menu item will have a loop, because while the mouse button is still down, you 
; need to compose the overlay buffer onto the screen, NOT onto the canvas.  You only
; write to the canvas when the mouse button is released.  If you always composed the
; overlay buffer onto the canvas buffer, you would be always overwriting the canvas.
; Consider the example when you are drawing a line, and you drag the line 360 
; degrees around.  Always writing to the canvas buffer would result in multiple lines
; around all 360 degrees instead of one line.
;
; General steps in loop:
; 1.  Clear overlay buffer
; 2.  Draw to overlay buffer
; 3.  Compose overlay buffer onto screen
; 4.  Update screen
;
; Since the canvas is placed at (CANVAS_X,CANVAS_Y) on the screen, you need to
; subtract those values off (MouseX,MouseY) in order to get the correct coordinates
; within the overlay buffer.

; PEN
.HandlePen
	invoke	_ClearBuffer, dword [_OverlayOff], word 480, word 400, dword 0
	
.PenLoop
	test	byte [_MPFlags], 00000100b
	jnz	near .PenDone
	invoke	_CopyBuffer, dword [_CanvasOff], word 480, word 400, dword [_ScreenOff], word 640, word 480, word CANVAS_X, word CANVAS_Y	
	mov	ax, [_MouseX]
	sub	ax, CANVAS_X	
	mov	bx, [_MouseY]
	sub	bx, CANVAS_Y
	invoke	_DrawPixel, dword [_OverlayOff], word 480, word 400, ax, bx, dword [_CurrentColor]
	invoke	_ComposeBuffers, dword [_OverlayOff], word 480, word 400, dword [_ScreenOff], word 640, word 480, word CANVAS_X, word CANVAS_Y
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	jmp	.PenLoop

.PenDone
	invoke	_ComposeBuffers, dword [_OverlayOff], word 480, word 400, dword [_CanvasOff], word 480, word 400, word 0, word 0
	jmp	.MPLoop

; LINE
.HandleLine
	mov	ax, [_MouseX]
	sub	ax, CANVAS_X	
	mov	bx, [_MouseY]
	sub	bx, CANVAS_Y

.LineLoop
	test	byte [_MPFlags], 00000100b
	jnz	near .LineDone
	push	ax
	push	bx
	invoke	_ClearBuffer, dword [_OverlayOff], word 480, word 400, dword 0
	invoke	_CopyBuffer, dword [_CanvasOff], word 480, word 400, dword [_ScreenOff], word 640, word 480, word CANVAS_X, word CANVAS_Y	
	pop	bx
	pop	ax
	mov	cx, [_MouseX]
	sub	cx, CANVAS_X	
	mov	dx, [_MouseY]
	sub	dx, CANVAS_Y
	push	ax
	push	bx
	invoke	_DrawLine, dword [_OverlayOff], word 480, word 400, ax, bx, cx, dx, dword [_CurrentColor]
	invoke	_ComposeBuffers, dword [_OverlayOff], word 480, word 400, dword [_ScreenOff], word 640, word 480, word CANVAS_X, word CANVAS_Y
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	pop	bx
	pop	ax
	jmp	.LineLoop

.LineDone
	invoke	_ComposeBuffers, dword [_OverlayOff], word 480, word 400, dword [_CanvasOff], word 480, word 400, word 0, word 0
	jmp	.MPLoop

; RECT
.HandleFilledRect
	mov	edi, 1
	jmp	.RectSetup

.HandleRect
	xor	edi, edi

.RectSetup
	; Get inital point of mouse click
	mov	ax, [_MouseX]
	sub	ax, CANVAS_X	
	mov	bx, [_MouseY]
	sub	bx, CANVAS_Y

.RectLoop
	test	byte [_MPFlags], 00000100b
	jnz	near .RectDone
	push	ax
	push	bx
	invoke	_ClearBuffer, dword [_OverlayOff], word 480, word 400, dword 0
	invoke	_CopyBuffer, dword [_CanvasOff], word 480, word 400, dword [_ScreenOff], word 640, word 480, word CANVAS_X, word CANVAS_Y	
	pop	bx
	pop	ax
	mov	cx, [_MouseX]
	sub	cx, CANVAS_X	
	mov	dx, [_MouseY]
	sub	dx, CANVAS_Y
	push	ax
	push	bx
	invoke	_DrawRect, dword [_OverlayOff], word 480, word 400, ax, bx, cx, dx, dword [_CurrentColor], edi
	invoke	_ComposeBuffers, dword [_OverlayOff], word 480, word 400, dword [_ScreenOff], word 640, word 480, word CANVAS_X, word CANVAS_Y
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	pop	bx
	pop	ax
	jmp	.RectLoop

.RectDone
	invoke	_ComposeBuffers, dword [_OverlayOff], word 480, word 400, dword [_CanvasOff], word 480, word 400, word 0, word 0		
	jmp	.MPLoop  

; CIRCLE
.HandleFilledCircle
	mov	edi, 1
	jmp	.CircleSetup

.HandleCircle
	xor	edi, edi

.CircleSetup
	; Get inital point of mouse click
	mov	ax, [_MouseX]
	sub	ax, CANVAS_X	
	mov	bx, [_MouseY]
	sub	bx, CANVAS_Y

.CircleLoop
	test	byte [_MPFlags], 00000100b
	jnz	near .CircleDone
	push	ax
	push	bx
	invoke	_ClearBuffer, dword [_OverlayOff], word 480, word 400, dword 0
	invoke	_CopyBuffer, dword [_CanvasOff], word 480, word 400, dword [_ScreenOff], word 640, word 480, word CANVAS_X, word CANVAS_Y	
	pop	bx
	pop	ax

	; calulate distance from initial mouse position to current mouse position
	finit
	sub	word [_MouseX], CANVAS_X
	sub	[_MouseX], ax
	fild	word [_MouseX]
	add	word [_MouseX], CANVAS_X
	add	[_MouseX], ax
	fmul	st0, st0
	sub	word [_MouseY], CANVAS_Y
	sub	[_MouseY], bx
	fild	word [_MouseY]
	add	word [_MouseY], CANVAS_Y
	add	[_MouseY], bx
	fmul	st0, st0
	fadd	st0, st1
	fsqrt
	fistp	word [_radius]

	push	ax
	push	bx
	invoke	_DrawCircle, dword [_OverlayOff], word 480, word 400, ax, bx, word [_radius], dword [_CurrentColor], edi
	invoke	_ComposeBuffers, dword [_OverlayOff], word 480, word 400, dword [_ScreenOff], word 640, word 480, word CANVAS_X, word CANVAS_Y
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	pop	bx
	pop	ax
	jmp	.CircleLoop

.CircleDone
	invoke	_ComposeBuffers, dword [_OverlayOff], word 480, word 400, dword [_CanvasOff], word 480, word 400, word 0, word 0		
	jmp	.MPLoop  

; TEXT
.HandleText
	mov	edi, _TextInputString
	mov	byte [edi], '$'

; Loop that builds string of typed text
.TextLoop
	mov	dl, [_MPFlags]
	and	dl, 00000110b
	cmp	dl, 00000110b
	je	near .TextDone
	test	byte [_MPFlags], 00000001b
	jnz	near .TextDone

	test	byte [_MPFlags], 00100000b
	jz	.DrawText

	and	byte [_MPFlags], 11011111b

	cmp	byte [_key], 0
	je	.TextLoop

	cmp	byte [_key], BKSP
	je	.Backspace
	jmp	.RegularKey

.Backspace
	cmp	edi, _TextInputString
	je	.TextLoop
	dec	edi
	mov	byte [edi], '$'
	jmp	.TextLoop

.RegularKey
	cmp	edi, _TextInputString+80
	je	.TextLoop
	push	eax
	mov	al, [_key]
	mov	[edi], al
	pop	eax
	inc	edi
	mov	byte [edi], '$'

.DrawText
	; Draw text to screen
	invoke	_ClearBuffer, dword [_OverlayOff], word 480, word 400, dword 0
	invoke	_CopyBuffer, dword [_CanvasOff], word 480, word 400, dword [_ScreenOff], word 640, word 480, word CANVAS_X, word CANVAS_Y
	mov	ax, [_MouseX]
	sub	ax, 10
	mov	bx, [_MouseY]
	sub	bx, 20
	invoke	_DrawText, dword _TextInputString, dword [_OverlayOff], word 480, word 400, ax, bx, dword [_CurrentColor]
	invoke	_ComposeBuffers, dword [_OverlayOff], word 480, word 400, dword [_ScreenOff], word 640, word 480, word CANVAS_X, word CANVAS_Y
	push	edi
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	pop	edi
	jmp	.TextLoop

.TextDone
	invoke	_ComposeBuffers, dword [_OverlayOff], word 480, word 400, dword [_CanvasOff], word 480, word 400, word 0, word 0		
	jmp	.MPLoop

; FLOOD FILL
.HandleFill
	mov	bx, [_MouseX]
	sub	bx, CANVAS_X	
	mov	cx, [_MouseY]
	sub	cx, CANVAS_Y

	invoke	_FloodFill, dword [_CanvasOff], word 480, word 400, word bx, word cx, dword [_CurrentColor], dword 1
	jmp	.MPLoop

; EYEDROP
.HandleEyedrop
	mov	bx, [_MouseX]
	sub	bx, CANVAS_X	
	mov	cx, [_MouseY]
	sub	cx, CANVAS_Y

	invoke	_GetPixel, dword [_CanvasOff], word 480, word 400, bx, cx
	mov	[_CurrentColor], eax
	and	byte [_MPFlags], 01111111b
	jmp	.MPLoop

; BLUR 
.HandleBlur
	invoke	_CopyBuffer, dword [_CanvasOff], word 480, word 400, dword [_OverlayOff], word 480, word 400, word 0, word 0
	invoke	_BlurBuffer, dword [_OverlayOff], dword [_CanvasOff], word 480, word 400
	invoke	_ClearBuffer, dword [_OverlayOff], word 480, word 400, dword 0
	jmp	.MPLoop

; COLOR INPUT
.HandleColor
	mov	edi, _ColorInputString
	mov	byte [edi], '$'
	mov	byte [_key], 0

	; Draw dialog box
	invoke	_ClearBuffer, dword [_OverlayOff], word 480, word 400, dword 0
	invoke	_CopyBuffer, dword [_CanvasOff], word 480, word 400, dword [_ScreenOff], word 640, word 480, word CANVAS_X, word CANVAS_Y
	invoke	_DrawRect, dword [_OverlayOff], word 480, word 400, word 20, word 100, word 460, word 300, dword [_ColorBlue], dword 0
	invoke	_DrawRect, dword [_OverlayOff], word 480, word 400, word 21, word 101, word 459, word 299, dword [_ColorBlue], dword 0
	invoke	_DrawRect, dword [_OverlayOff], word 480, word 400, word 22, word 102, word 458, word 200, dword [_ColorHalfBlack], dword 1
	invoke	_DrawRect, dword [_OverlayOff], word 480, word 400, word 22, word 201, word 458, word 298, dword [_ColorHalfBlack], dword 1
	invoke	_DrawRect, dword [_OverlayOff], word 480, word 400, word 110, word 220, word 370, word 255, dword [_ColorBlue], dword 0
	invoke	_DrawRect, dword [_OverlayOff], word 480, word 400, word 109, word 219, word 371, word 256, dword [_ColorBlue], dword 0
	invoke	_ComposeBuffers, dword [_OverlayOff], word 480, word 400, dword [_ScreenOff], word 640, word 480, word CANVAS_X, word CANVAS_Y	
	invoke	_ClearBuffer, dword [_OverlayOff], word 480, word 400, dword 0
	invoke	_DrawText, dword _ColorString1, dword [_OverlayOff], word 480, word 400, word 32, word 115, dword [_ColorWhite]
	invoke	_DrawText, dword _ColorString2, dword [_OverlayOff], word 480, word 400, word 32, word 135, dword [_ColorWhite]
	invoke	_DrawText, dword _ColorString3, dword [_OverlayOff], word 480, word 400, word 32, word 155, dword [_ColorWhite]
	invoke	_DrawText, dword _ColorString4, dword [_OverlayOff], word 480, word 400, word 32, word 175, dword [_ColorWhite]
	invoke	_DrawRect, dword [_OverlayOff], word 480, word 400, word 111, word 221, word 369, word 254, dword [_ColorBlack], dword 1
	invoke	_ComposeBuffers, dword [_OverlayOff], word 480, word 400, dword [_ScreenOff], word 640, word 480, word CANVAS_X, word CANVAS_Y	
	invoke	_ClearBuffer, dword [_OverlayOff], word 480, word 400, dword 0
	invoke	_DrawText, dword _ColorInputString, dword [_OverlayOff], word 480, word 400, word 120, word 230, dword [_ColorWhite]
	invoke	_ComposeBuffers, dword [_OverlayOff], word 480, word 400, dword [_ScreenOff], word 640, word 480, word CANVAS_X, word CANVAS_Y
	push	edi
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	pop	edi

; Loop that builds string of typed text
.ColorInputLoop
	cmp	byte [_key], ENTERKEY
	je	near .ColorInputDone
	test	byte [_MPFlags], 00000001b
	jnz	near .ColorDone
	test	byte [_MPFlags], 00100000b
	jz	.DrawColor

	and	byte [_MPFlags], 11011111b

	cmp	byte [_key], 0
	je	.ColorInputLoop

	cmp	byte [_key], BKSP
	je	.ColorBackspace
	jmp	.ColorRegularKey

.ColorBackspace
	cmp	edi, _ColorInputString
	je	.ColorInputLoop
	dec	edi
	mov	byte [edi], '$'
	jmp	.ColorInputLoop

.ColorRegularKey
	cmp	edi, _ColorInputString+15
	je	.ColorInputLoop
	push	eax
	mov	al, [_key]
	mov	[edi], al
	pop	eax
	inc	edi
	mov	byte [edi], '$'

.DrawColor
	; Update string of text on the screen	
	invoke	_ClearBuffer, dword [_OverlayOff], word 480, word 400, dword 0
	invoke	_CopyBuffer, dword [_OverlayOff], word 15*16, word 16, dword [_ScreenOff], word 640, word 480, word 120+CANVAS_X, word 230+CANVAS_Y
	invoke	_DrawText, dword _ColorInputString, dword [_OverlayOff], word 480, word 400, word 120, word 230, dword [_ColorWhite]
	invoke	_ComposeBuffers, dword [_OverlayOff], word 480, word 400, dword [_ScreenOff], word 640, word 480, word CANVAS_X, word CANVAS_Y
	push	edi
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 120+CANVAS_X, dword 230+CANVAS_Y, dword 15*16, dword 16, dword 120+CANVAS_X, dword 230+CANVAS_Y
	pop	edi
	jmp	.ColorInputLoop

.ColorInputDone
	mov	ebx, _ColorInputString
	xor	ecx, ecx
	xor	edx, edx

; Loop over input string, parse it, and check for valid input
.ColorParseLoop	
	cmp	ecx, 4
	je	.ColorParseDone
	push	edx
	call	AscBin
	test	dl, dl
	pop	edx
	jnz	near .HandleColor
	cmp	ax, 255
	jg	near .HandleColor
	cmp	ax, 0
	jl	near .HandleColor
	shl	edx, 8
	mov	dl, al
	inc	ecx
	jmp	.ColorParseLoop

.ColorParseDone
	mov	[_CurrentColor], edx

.ColorDone
	mov	byte [_key], 0
	mov	byte [_MenuItem], -1
	and	byte [_MPFlags], 11111110b
	or	byte [_MPFlags], 10000000b
	jmp	.MPLoop

.NoEventProcess
	; Copy canvas to screen and update screen
	invoke	_CopyBuffer, dword [_CanvasOff], word 480, word 400, dword [_ScreenOff], word 640, word 480, word CANVAS_X, word CANVAS_Y
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	jmp	.MPLoop

.MainDone
	ret
