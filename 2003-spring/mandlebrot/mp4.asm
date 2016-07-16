; ECE 291 Spring 2002 MP4    
; -- 3D Z-Buffer --
;
; Completed By:
;  Your Name
;  Date
;
; Dimitrios Nikolopoulos
; Guest Author - Ryan Chmiel
; University of Illinois Urbana Champaign
; Dept. of Electrical & Computer Engineering
;
; Ver 1.0

%include "lib291.inc"
%include "libmp4.inc"

	BITS 32

	GLOBAL _main

; Define Keyboard Scancodes
ESC		EQU	1
UPARROW		EQU	72
LEFTARROW	EQU	75
RIGHTARROW	EQU	77
DOWNARROW	EQU	80

; Vector Structure
STRUC Vector
.x	resd	1
.y	resd	1
.z	resd	1
.h	resd	1
ENDSTRUC

; Point Structure
STRUC Point
.x	resw	1
.y	resw	1
.z	resw	1
ENDSTRUC

; Matrix Structure
STRUC Matrix
.r1c1	resd	1
.r1c2	resd	1
.r1c3	resd	1
.r1c4	resd	1
.r2c1	resd	1
.r2c2	resd	1
.r2c3	resd	1
.r2c4	resd	1
.r3c1	resd	1
.r3c2	resd	1
.r3c3	resd	1
.r3c4	resd	1
.r4c1	resd	1
.r4c2	resd	1
.r4c3	resd	1
.r4c4	resd	1
ENDSTRUC

; Bresenham's 3D Line Algorithm Variable Structure
STRUC Bresenham
.x			resw	1
.y			resw	1
.z			resw	1
.xdiaginc		resw	1
.xnodiaginc		resw	1
.ydiaginc		resw	1
.ynodiaginc		resw	1
.zdiaginc		resw	1
.error1			resw	1
.error1diaginc		resw	1
.error1nodiaginc	resw	1
.error2			resw	1
.error2diaginc		resw	1
.error2nodiaginc	resw	1
.length			resw	1
ENDSTRUC

; Absolute Value Macro
; Calculates abs(ax) and stores result in ax, preserves edx
%macro abs 0
push 	edx
cwd
xor	ax, dx
sub	ax, dx
pop	edx
%endmacro

; Sign Macro
; Calculates sign(ax) and stores result in ax, preserves edx
%macro sign 0
push	edx
cwd
shl	dx, 1
inc	dx
test	ax, ax
cmovnz	ax, dx
pop	edx
%endmacro

	SECTION .bss

_ScreenOff	resd	1	; pointer to screen buffer
_ZBufferOff	resd	1	; pointer to z-buffer
_FontOff	resd	1	; pointer to font image buffer
_GraphicsMode	resw	1	; ex291 graphics mode

_kbINT		resb	1	; mapped keyboard interrupt
_kbIRQ		resb	1	; mapped keyboard irq
_kbPort		resw	1	; mapped keyboard port

_MouseSeg	resw	1       ; real mode segment for MouseCallback
_MouseOff	resw	1	; real mode offset for MouseCallback

_CameraPos	resb	1	; Current Camera Position

_MPFlags	resb	1	; MP flags
				; Bit 0 - User Exit Flag
				; Bit 1 - Move Camera Flag
				; Bits 2 & 3 - Move Direction Flags
				;  00 - Move Right
				;  01 - Move Left
				;  10 - Move Forward
				;  11 - Move Backward
				; Bit 4 - Move Camera to Next Location Flag
				; Bit 5 - Return Camera to Original Position Flag

				
; Structures for 3D Bresenham's Line Algorithm
_LineBres	resb	Bresenham_size
_TriangleBres	resb	Bresenham_size

; Camera Configuration Variables
_CameraEye	resb	Vector_size
_CameraLookAt	resb	Vector_size
_CameraUp	resb	Vector_size

; Matrices to convert points from world space to screen space
_CameraMatrix		resb	Matrix_size
_TranslateMatrix	resb	Matrix_size

; Temporary vectors (declare more if you need them)
_TempVectorA	resb	Vector_size
_TempVectorB	resb	Vector_size
_TempVectorC	resb	Vector_size
_TempVectorD	resb	Vector_size

; Temporary points (declare more if you need them)
_TempPointA	resb	Point_size
_TempPointB	resb	Point_size
_TempPointC	resb	Point_size
_TempPointD	resb	Point_size

	SECTION .data

; Floating Point Values Defined for Easy Access
_RealOne	dd	1.0

; Camera Locations
_CameraPositions
		dd	 0.0,    0.0,   -15.0, 0.0	; Camera[0].Eye
		dd	 0.0,    0.0,   -14.0, 0.0	; Camera[0].LookAt
		dd	 0.0,    1.0,     0.0, 0.0	; Camera[0].Up
		dd	 0.0,    8.0,    -8.0, 0.0	; Camera[1].Eye
		dd	 0.0, 7.2929, -7.2929, 0.0	; Camera[1].LookAt
		dd	 0.0,    8.0,     8.0, 0.0	; Camera[1].Up
		dd	-7.0,   10.0,     0.0, 0.0	; Camera[2].Eye
		dd   -6.4265, 9.1808,     0.0, 0.0	; Camera[2].LookAt
		dd	10.0,    7.0,     0.0, 0.0	; Camera[2].Up
		dd	10.0,   10.0,    10.0, 0.0	; Camera[3].Eye
		dd    9.3118, 9.7706,  9.3118, 0.0	; Camera[3].LookAt
		dd   -0.1622, 0.9733, -0.1622, 0.0	; Camera[3].Up

; Defined Points in World Space for Triangles in Scene
_Point1		dd	  0.0,  0.0,   2.0, 1.0		; Red Triangle
_Point2		dd	  2.0,  0.0,  -2.0, 1.0
_Point3		dd	 -2.0,  0.0,  -2.0, 1.0
_Point4		dd	 -4.0, -1.0,  -3.0, 1.0		; Blue Triangle
_Point5		dd	 -6.0,  2.0,  -3.0, 1.0
_Point6		dd	  2.0,  5.0,   2.0, 1.0
_Point7		dd	  4.0, -1.0,  -1.0, 1.0		; White Triangle
_Point8		dd	  6.0,  1.0,  -1.0, 1.0
_Point9		dd	 -1.0,  5.0,   6.0, 1.0
_Point10	dd	 -2.0,  2.0,  -3.0, 1.0		; Green Triangle
_Point11	dd	  2.0,  2.0,  -3.0, 1.0
_Point12	dd	  0.0,  5.0,  -3.0, 1.0
_Point13	dd	 -2.0, -5.0,  -6.0, 1.0		; Gray Triangle
_Point14	dd	  2.0, -5.0,  -6.0, 1.0
_Point15	dd	  0.0, -2.0,  -3.0, 1.0

; Identity Matrix
_IdentityMatrix	dd	1.0, 0.0, 0.0, 0.0
		dd	0.0, 1.0, 0.0, 0.0
		dd	0.0, 0.0, 1.0, 0.0
		dd	0.0, 0.0, 0.0, 1.0

; Perspective Projection Matrix
_PerspectiveMatrix	dd 	0.75, 0.0,   0.0,   0.0
			dd	 0.0, 1.0,   0.0,   0.0
			dd       0.0, 0.0, -1.02, -2.02
			dd	 0.0, 0.0,  -1.0,   0.0

; Vectors to convert projected point to screen coordinates
_NormalCoordsVector	dd	 -1.0,  -1.0,     1.0, 1.0
_ScreenScaleVector	dd	319.5, 239.5, 32767.5, 1.0

; Defined color values
_ColorGray	dd	00666666h
_ColorBlue	dd	00000099h
_ColorGreen	dd	00006600h
_ColorWhite	dd	00ffffffh
_ColorRed	dd	00990000h

; Font Filename
_FontFN		db	'font.png',0

; Title Bar String
_TitleString	db	'MP4 SPRING 2002              3D Z-BUFFER',0

	SECTION .text

; Program Start
_main
	call	_LibInit

	; Allocate Screen Buffer
	invoke	_AllocMem, dword 640*480*4
	cmp	eax, -1
	je	near .memerror
	mov	[_ScreenOff], eax

	; Allocate Z-Buffer
	invoke	_AllocMem, dword 640*480*2
	cmp	eax, -1
	je	near .memerror
	mov	[_ZBufferOff], eax

	; Allocate Font Image Buffer
	invoke	_AllocMem, dword 128*16*16*4
	cmp	eax, -1
	je	near .memerror
	mov	[_FontOff], eax

	; Load blocks and font files
	invoke	_LoadPNG, dword _FontFN, dword [_FontOff], dword 0, dword 0
 
	; Graphics Init
	invoke	_InitGraphics, dword _kbINT, dword _kbIRQ, dword _kbPort
	test	eax, eax
	jnz	near .graphicserror

	; Find Graphics Mode: 640x480x32, allow driver-emulated modes
	invoke	_FindGraphicsMode, word 640, word 480, word 32, dword 1
	mov	[_GraphicsMode], ax

	; Mouse/Keyboard init
	call	_InstallKeyboard
	invoke	_SetGraphicsMode, word [_GraphicsMode]
	call	_InstallMouse
	test	eax, eax
	jnz	.mouseerror

	call	_MP4Main	

.mouseerror
	call	_RemoveMouse
	call	_UnsetGraphicsMode
	call	_RemoveKeyboard

.graphicserror
	call	_ExitGraphics

.memerror
	call	_LibExit
	call	_MP4LibExit
	ret


;--------------------------------------------------------------
;--                       Given Code!                        --
;--------------------------------------------------------------


;--------------------------------------------------------------
;--                        MP4Main()                         --
;--------------------------------------------------------------
_MP4Main
	; Setup camera, draw initial scene
	mov	byte [_CameraPos], 0
	mov	esi, _CameraPositions
	mov	edi, _CameraEye
	mov	ecx, 12
	rep	movsd
	call	_DrawScene

.MPLoop
	test	byte[_MPFlags], 00000001b
	jnz	near .MainDone

	call	_MoveCamera
	test	eax, eax
	jz	.MPLoop
	call	_DrawScene	; Redraw screen when camera moved
	jmp	.MPLoop

.MainDone
	ret

;--------------------------------------------------------------
;--                       DrawScene()                        --
;--------------------------------------------------------------
_DrawScene
	push	edi

	; Clear Screen Buffer
	xor	eax, eax
	mov	edi, [_ScreenOff]
	mov	ecx, 640*480
	rep	stosd

	; Reset Z-Buffer to Infinity
	mov	eax, 0ffffffffh
	mov	edi, [_ZBufferOff]
	mov	ecx, 640*480*2/4
	rep	stosd

	; Draw Triangles in Scene
	invoke	_DrawTriangle, dword [_ScreenOff], dword _Point1,  dword _Point2,  dword _Point3,  dword [_ColorRed]
	invoke	_DrawTriangle, dword [_ScreenOff], dword _Point4,  dword _Point5,  dword _Point6,  dword [_ColorBlue]
	invoke	_DrawTriangle, dword [_ScreenOff], dword _Point7,  dword _Point8,  dword _Point9,  dword [_ColorWhite]
	invoke	_DrawTriangle, dword [_ScreenOff], dword _Point10, dword _Point11, dword _Point12, dword [_ColorGreen]
	invoke	_DrawTriangle, dword [_ScreenOff], dword _Point13, dword _Point14, dword _Point15, dword [_ColorGray]

	; Draw Title Bar
	invoke	_DrawText, dword _TitleString, dword [_ScreenOff], word 0, word 463, dword [_ColorWhite]

	; Update Screen
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

	pop	edi
	ret

;--------------------------------------------------------------
;--                    NormalizeVector()                     --
;--------------------------------------------------------------
proc _NormalizeVector
.Vector		arg	4

	mov	ebx, [ebp+.Vector]
	movups	xmm0, [ebx]			; 0.0     Vz      Vy      Vx   
	movups	xmm1, xmm0

	mulps	xmm0, xmm0			; 0.0     Vz*Vz   Vy*Vy   Vx*Vx
	movups	xmm2, xmm0
	shufps	xmm2, xmm2, 00111001b		; xxxxxxx 0.0     Vz*Vz   Vy*Vy
	addss	xmm0, xmm2			; xxxxxxx xxxxxxx xxxxxxx Vx*Vx+Vy*Vy
	shufps	xmm2, xmm2, 00111001b		; xxxxxxx xxxxxxx 0.0     Vz*Vz
	addss	xmm0, xmm2			; xxxxxxx xxxxxxx xxxxxxx Vx*Vx+Vy*Vy+Vz*Vz
	sqrtss	xmm0, xmm0			; xxxxxxx xxxxxxx xxxxxxx sqrt

	unpcklps	xmm0, xmm0		; xxxxxxx xxxxxxx sqrt    sqrt
	unpcklps	xmm0, xmm0		; sqrt    sqrt    sqrt    sqrt
	divps		xmm1, xmm0		; 0.0	  Vz/sqrt Vy/sqrt Vx/sqrt
	movups		[ebx], xmm1

	ret

endproc
_NormalizeVector_arglen	EQU	4

;--------------------------------------------------------------
;--                   CreateBresenham3D()                    --
;--------------------------------------------------------------
proc _CreateBresenham3D
.Bresenham	arg	4
.PointA		arg	4
.PointB		arg	4

	push	esi
	push	edi

	mov	esi, [ebp + .PointA]
	mov	edi, [ebp + .PointB]

	mov	ax, [edi + Point.x]
	sub	ax, [esi + Point.x]
	abs 
	mov	bx, ax			; bx = |deltax|
	mov	ax, [edi + Point.y]
	sub	ax, [esi + Point.y]
	abs
	mov	cx, ax			; cx = |deltay|
	mov	ax, [edi + Point.z]
	sub	ax, [esi + Point.z]
	abs
	mov	dx, ax			; dx = |deltaz|

	mov	edi, [ebp+.Bresenham]

	cmp	cx, bx
	jg	near .dyGreater

.dxGreater
	mov	ax, cx
	shl	ax, 1
	sub	ax, bx
	mov	[edi + Bresenham.error1], ax		; 2 * dy - dx
	mov	ax, cx
	sub	ax, bx
	shl	ax, 1
	mov	[edi + Bresenham.error1diaginc], ax	; 2 * (dy - dx)
	mov	ax, cx
	shl	ax, 1
	mov	[edi + Bresenham.error1nodiaginc], ax	; 2 * dy

	mov	ax, dx
	shl	ax, 1
	sub	ax, bx
	mov	[edi + Bresenham.error2], ax		; 2 * dz - dx
	mov	ax, dx
	sub	ax, bx
	shl	ax, 1
	mov	[edi + Bresenham.error2diaginc], ax	; 2 * (dz - dx)
	mov	ax, dx
	shl	ax, 1
	mov	[edi + Bresenham.error2nodiaginc], ax	; 2 * dz

	mov	edx, [ebp + .PointB]
	mov	ax, [edx + Point.x]
	sub	ax, [esi + Point.x]
	sign
	mov	[edi + Bresenham.xdiaginc], ax
	mov	[edi + Bresenham.xnodiaginc], ax
	mov	ax, [edx + Point.y]
	sub	ax, [esi + Point.y]
	sign
	mov	[edi + Bresenham.ydiaginc], ax
	mov	[edi + Bresenham.ynodiaginc], word 0
	mov	ax, [edx + Point.z]
	sub	ax, [esi + Point.z]
	sign
	mov	[edi + Bresenham.zdiaginc], ax
	inc	bx
	mov	[edi + Bresenham.length], bx
	jmp	.InitialPointSetup

.dyGreater
	mov	ax, bx
	shl	ax, 1
	sub	ax, cx
	mov	[edi + Bresenham.error1], ax		; 2 * dx - dy
	mov	ax, bx
	sub	ax, cx
	shl	ax, 1
	mov	[edi + Bresenham.error1diaginc], ax	; 2 * ( dx - dy )
	mov	ax, bx
	shl	ax, 1
	mov	[edi + Bresenham.error1nodiaginc], ax	; 2 * dx

	mov	ax, dx
	shl	ax, 1
	sub	ax, cx
	mov	[edi + Bresenham.error2], ax		; 2 * dz - dy
	mov	ax, dx
	sub	ax, cx
	shl	ax, 1
	mov	[edi + Bresenham.error2diaginc], ax	; 2 * ( dz - dy )
	mov	ax, dx
	shl	ax, 1
	mov	[edi + Bresenham.error2nodiaginc], ax	; 2 * dz

	mov	edx, [ebp + .PointB]
	mov	ax, [edx + Point.x]
	sub	ax, [esi + Point.x]
	sign
	mov	[edi + Bresenham.xdiaginc], ax
	mov	[edi + Bresenham.xnodiaginc], word 0
	mov	ax, [edx + Point.y]
	sub	ax, [esi + Point.y]
	sign
	mov	[edi + Bresenham.ydiaginc], ax
	mov	[edi + Bresenham.ynodiaginc], ax
	mov	ax, [edx + Point.z]
	sub	ax, [esi + Point.z]
	sign
	mov	[edi + Bresenham.zdiaginc], ax
	inc	cx
	mov	[edi + Bresenham.length], cx
	
.InitialPointSetup
	mov	ax, [esi + Point.x]
	mov	[edi + Bresenham.x], ax
	mov	ax, [esi + Point.y]
	mov	[edi + Bresenham.y], ax
	mov	ax, [esi + Point.z]
	mov	[edi + Bresenham.z], ax

	pop	edi
	pop	esi
	ret

endproc
_CreateBresenham3D_arglen	EQU	12


;--------------------------------------------------------------
;--          Replace library calls with your code            --
;--         Do not forget to add function headers!           --
;--------------------------------------------------------------


;--------------------------------------------------------------
;--                      CrossProduct()                      --
;--------------------------------------------------------------
proc _CrossProduct
.VectorA	arg	4
.VectorB	arg	4

	invoke	_libCrossProduct, dword [ebp+.VectorA], dword [ebp+.VectorB]
	ret

endproc
_CrossProduct_arglen	EQU	8

;--------------------------------------------------------------
;--                    MulVectorMatrix()                     --
;--------------------------------------------------------------
proc _MulVectorMatrix
.Vector		arg	4
.Matrix		arg	4

	invoke	_libMulVectorMatrix, dword [ebp+.Vector], dword [ebp+.Matrix]
	ret

endproc
_MulVectorMatrix_arglen	EQU	8

;--------------------------------------------------------------
;--                      CreateCamera()                      --
;--------------------------------------------------------------
_CreateCamera

	call	_libCreateCamera
	ret

;--------------------------------------------------------------
;--                      MoveCamera()                        --
;--------------------------------------------------------------
_MoveCamera

	call	_libMoveCamera
	ret

;--------------------------------------------------------------
;--                    ConvertPoint()                        --
;--------------------------------------------------------------
proc _ConvertPoint
.Point	arg	4
.Vector	arg	4

	invoke	_libConvertPoint, dword [ebp+.Point], dword [ebp+.Vector]
	ret

endproc
_ConvertPoint_arglen	EQU	8

;--------------------------------------------------------------
;--                     CalcNextPoint()                      --
;--------------------------------------------------------------
proc _CalcNextPoint
.Bresenham	arg	4

	invoke	_libCalcNextPoint, dword [ebp+.Bresenham]
	ret

endproc
_CalcNextPoint_arglen	EQU	4

;--------------------------------------------------------------
;--                      DrawPixel()                         --
;--------------------------------------------------------------
proc _DrawPixel
.DestOff	arg	4
.ZBufferOff	arg	4
.X		arg	2
.Y		arg	2
.Z		arg	2
.Color		arg	4

	invoke	_libDrawPixel, dword [ebp+.DestOff], dword [ebp+.ZBufferOff], word [ebp+.X], word [ebp+.Y], word [ebp+.Z], dword [ebp+.Color]
	ret

endproc
_DrawPixel_arglen	EQU	18

;--------------------------------------------------------------
;--                        DrawLine()                        --
;--------------------------------------------------------------
proc _DrawLine
.DestOff	arg	4
.PointA		arg	4
.PointB		arg	4
.Color		arg	4

	invoke	_libDrawLine, dword [ebp+.DestOff], dword [ebp+.PointA], dword [ebp+.PointB], dword [ebp+.Color]
	ret

endproc
_DrawLine_arglen	EQU	16

;--------------------------------------------------------------
;--                      DrawTriangle()                      --
;--------------------------------------------------------------
proc _DrawTriangle
.DestOff	arg	4
.PointA		arg	4
.PointB		arg	4
.PointC		arg	4
.Color		arg	4

	invoke	_libDrawTriangle, dword [ebp+.DestOff], dword [ebp+.PointA], dword [ebp+.PointB], dword [ebp+.PointC], dword [ebp+.Color]
	ret

endproc
_DrawTriangle_arglen	EQU	20

;--------------------------------------------------------------
;--                      AlphaCompose()                      --
;--------------------------------------------------------------
proc _AlphaCompose
.Pixel		arg	4

	invoke	_libAlphaCompose, dword [ebp+.Pixel]
	ret

endproc
_AlphaCompose_arglen	EQU	4

;--------------------------------------------------------------
;--                        DrawText()                        --
;--------------------------------------------------------------
proc _DrawText
.StringOff	arg	4
.DestOff	arg	4
.X		arg	2
.Y		arg	2
.Color		arg	4

	invoke	_libDrawText, dword [ebp+.StringOff], dword [ebp+.DestOff], word [ebp+.X], word [ebp+.Y], dword [ebp+.Color]
	ret

endproc
_DrawText_arglen	EQU	16

;--------------------------------------------------------------
;--                    InstallKeyboard()                     --
;--------------------------------------------------------------
_InstallKeyboard

	call	_libInstallKeyboard
	ret

;--------------------------------------------------------------
;--                     RemoveKeyboard()                     --
;--------------------------------------------------------------
_RemoveKeyboard

	call	_libRemoveKeyboard
	ret

;--------------------------------------------------------------
;--                      KeyboardISR()                       --
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

