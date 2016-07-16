
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
