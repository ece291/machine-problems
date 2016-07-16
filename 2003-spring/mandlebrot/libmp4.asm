; ECE 291 Spring 2002 MP4 SOLUTION 
; -- 3D Z-Buffer Engine --
;
; Dimitrios Nikolopoulos
; Guest Author - Ryan Chmiel
; University of Illinois at Urbana-Champaign
; Dept. of Electrical & Computer Engineering
;
; Ver 1.0

%include "lib291.inc"

; GLOBAL Library Function Calls
GLOBAL _libCrossProduct	
GLOBAL _libMulVectorMatrix
GLOBAL _libCreateCamera
GLOBAL _libMoveCamera
GLOBAL _libConvertPoint
GLOBAL _libCalcNextPoint
GLOBAL _libDrawPixel
GLOBAL _libDrawLine
GLOBAL _libDrawTriangle
GLOBAL _libAlphaCompose
GLOBAL _libDrawText
GLOBAL _libInstallKeyboard
GLOBAL _libRemoveKeyboard
GLOBAL _libKeyboardISR
GLOBAL _libInstallMouse
GLOBAL _libRemoveMouse
GLOBAL _libMouseCallback
GLOBAL _MP4LibExit

; EXTERN Function Calls
EXTERN _NormalizeVector
EXTERN _CrossProduct	
EXTERN _MulVectorMatrix
EXTERN _CreateCamera
EXTERN _MoveCamera
EXTERN _ConvertPoint
EXTERN _CreateBresenham3D
EXTERN _CalcNextPoint
EXTERN _DrawPixel
EXTERN _DrawLine
EXTERN _DrawTriangle
EXTERN _DrawText
EXTERN _AlphaCompose
EXTERN _InstallKeyboard
EXTERN _RemoveKeyboard
EXTERN _KeyboardISR
EXTERN _InstallMouse
EXTERN _RemoveMouse
EXTERN _MouseCallback

; EXTERN Variables
EXTERN _ScreenOff
EXTERN _ZBufferOff
EXTERN _FontOff
EXTERN _GraphicsMode
EXTERN _kbINT
EXTERN _kbIRQ
EXTERN _kbPort
EXTERN _MouseSeg
EXTERN _MouseOff
EXTERN _CameraPos
EXTERN _MPFlags
EXTERN _LineBres
EXTERN _TriangleBres
EXTERN _CameraEye
EXTERN _CameraLookAt
EXTERN _CameraUp
EXTERN _CameraMatrix
EXTERN _TranslateMatrix
EXTERN _TempVectorA
EXTERN _TempVectorB
EXTERN _TempVectorC
EXTERN _TempVectorD
EXTERN _TempPointA
EXTERN _TempPointB
EXTERN _TempPointC
EXTERN _TempPointD
EXTERN _RealOne
EXTERN _CameraPositions
EXTERN _IdentityMatrix
EXTERN _PerspectiveMatrix
EXTERN _NormalCoordsVector
EXTERN _ScreenScaleVector

; Declare arlgen constants
_NormalizeVector_arglen		EQU	4
_CrossProduct_arglen		EQU	8
_MulVectorMatrix_arglen		EQU	8
_ConvertPoint_arglen		EQU	8
_CreateBresenham3D_arglen	EQU	12
_CalcNextPoint_arglen		EQU	4
_DrawPixel_arglen		EQU	18
_DrawLine_arglen		EQU	16
_DrawTriangle_arglen		EQU	20
_DrawText_arglen		EQU	16
_AlphaCompose_arglen		EQU	4
_MouseCallback_arglen		EQU	4

	BITS 32

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

%macro Garbage1 0

        ; Perserves registers

        jmp     %%GarbageDone

        pusha
        mov     eax,ebx
        xor     eax,ebx
        jmp     %%Lable1
        mov     eax, 100
        mov     dx, cs
        call    _AllocMem
%%Lable2:
        db      'I am not really sure why you are looking here!!!','$'
        dw      100,200,300,400
%%LableTable
        dd      %%Lable1      ;12
        dd      %%Lable2      ;13
        dd      %%Lable3      ;14
        dd      %%Lable4      ;15
        db      'Dont you think your time would be better spent'
        db      '  if you just wrote the code... plus you would do'
        db      ' much better on tests....','$'
%%Lable1:
        mov     ebx,2
        shl     ebx,1
        cmp     eax,0
        jmp     [%%LableTable+ebx]
        xor     eax, eax
        jmp     %%Lable1
%%Lable4:
        call    _SaveBMP
        cmp     ecx, -5
        jl      %%Lable1
        jge     %%Lable3
%%Lable3:
        jmp     %%Lable5
        or      ecx, 1001h
        shl     ecx, 1
        shr     ebx, cl
%%Lable5:
        jmp     %%Mexit
        lea     edx, [%%Lable4]
        db      'Hats off to all the ECE291 professors...','$'
        dw      100,200,300,400                                  ;37
        db      'ECE291 is a great class!!!','$'
        test    eax, 35
        jne     %%Lable3
        jg      %%Lable5
%%Mexit:
        popa
%%GarbageDone
%endmacro

	SECTION .data

ExitMsg         db 'libMP4 * ver 1.0 * calls:',0
ExitMsgCoord    dw 0, 0

Msg0    db '-libCrossProduct()',0
Msg1    db '-libMulVectorMatrix()',0
Msg2    db '-libCreateCamera()',0
Msg3    db '-libMoveCamera()',0
Msg4    db '-libProjectPoint()',0
Msg5    db '-libCalcNextPoint()',0
Msg6    db '-libDrawPixel()',0
Msg7    db '-libDrawLine()',0
Msg8    db '-libDrawTriangle()',0
Msg9    db '-libAlphaCompose()',0
Msg10   db '-libDrawText()',0
Msg11   db '-libInstallKeyboard()',0
Msg12   db '-libRemoveKeyboard()',0
Msg13   db '-libKeyboardISR()',0
Msg14   db '-libInstallMouse()',0
Msg15   db '-libRemoveMouse()',0
Msg16   db '-libMouseCallback()',0

OriginalMsg     	db '(All Original Code)',0
OriginalMsgCoord        dw 0, 2

ModUsed     dd 0
ModAddr     dd Msg0, Msg1,  Msg2,  Msg3,  Msg4,  Msg5,  Msg6,  Msg7,  Msg8
            dd Msg9, Msg10, Msg11, Msg12, Msg13, Msg14, Msg15, Msg16

	SECTION .text

;--------------------------------------------------------------
;--                      MP4LibExit()                        --
;--------------------------------------------------------------
_MP4LibExit

        Garbage1

        push    esi
        push    edi
        push    es

        mov     es, [_textsel]

        call    _SetModeC80
        invoke  _TextSetPage, word 0
        call    _TextClearScreen

        invoke  _TextWriteString, word [ExitMsgCoord], word [ExitMsgCoord+2], dword ExitMsg, word 0Fh
        
        mov     ecx, 17         ; Loop for all bits in first doubleword of ModUsed
        mov	edx, 1
	xor     edi, edi
        xor     esi, esi        ; Use as offset to address table

.FinalLoop:
        ror     dword [ModUsed], 1      ; Rotate variable
        jnc     .NotUsed
        mov     ebx, [ModAddr+esi*4]

	inc	edx	
	xor	eax, eax

        push    eax
	push	ebx
        push    ecx
        push    edx
        invoke  _TextWriteString, ax, dx, ebx, word 0Fh
        pop     edx
        pop     ecx
	pop	ebx
        pop     eax

        inc     edi             	; Flag library as being used

.NotUsed:
        inc     esi             	; Next location in table
        dec     ecx
        jnz     .FinalLoop

        cmp     edi, 0          ; Check if all Original Code
        jne     .done
        invoke  _TextWriteString, word [OriginalMsgCoord], word [OriginalMsgCoord+2], dword OriginalMsg, word 0Fh

.done:
	; Set ending cursor position
	mov	ah, 2h
	xor	bh, bh
	mov	dh, 21
	xor	dl, dl
	int	10h

        pop     es
        pop     edi
        pop     esi
        ret

;--------------------------------------------------------------
;--                      CrossProduct()                      --
;--------------------------------------------------------------
proc _libCrossProduct
.VectorA	arg	4
.VectorB	arg	4

	Garbage1
	or	dword [ModUsed], 00000001h

	mov	eax, [ebp+.VectorA]
	mov	ebx, [ebp+.VectorB]

	movups		xmm0, [eax]		; 0	A.z	A.y	A.x
	movups		xmm1, xmm0
	movups		xmm2, [ebx]		; 0	B.z	B.y	B.x

	shufps		xmm0, xmm0, 11010010b	; 0     A.y     A.x     A.z
	mulps		xmm0, xmm2		; 0     A.y*B.z A.x*B.y B.x*A.z
	shufps		xmm1, xmm1, 11001001b	; 0     A.x     A.z     A.y
	mulps		xmm1, xmm2		; 0     A.x*B.z B.y*A.z B.x*A.y
	shufps		xmm1, xmm1, 11010010b	; 0     B.y*A.z B.x*A.y A.x*B.Z
	subps		xmm0, xmm1
	shufps		xmm0, xmm0, 11010010b
	movups		[eax], xmm0

	ret

endproc
_libCrossProduct_arglen	EQU	8

;--------------------------------------------------------------
;--                    MulVectorMatrix()                     --
;--------------------------------------------------------------
proc _libMulVectorMatrix
.Vector		arg	4
.Matrix		arg	4

	Garbage1
	or	dword [ModUsed], 00000002h

	mov	ebx, [ebp+.Vector]
	movups	xmm0, [ebx]
	mov	edx, [ebp+.Matrix]
	mov	ecx, 3*4

.MulLoop
	movups	xmm1, [edx+4*ecx]
	mulps	xmm1, xmm0		; Result.h Result.z Result.y Result.x
	movups	xmm2, xmm1
	shufps	xmm2, xmm2, 01001110b   ; xxxxxxxx xxxxxxxx Result.h Result.z
	addps	xmm2, xmm1		; xxxxxxxx xxxxxxxx R.y+R.h  R.x+R.z
	movups	xmm1, xmm2		;
	shufps	xmm1, xmm1, 00000001b	; xxxxxxxx xxxxxxxx xxxxxxxx R.y+R.h		 		
	addps	xmm1, xmm2		; xxxxxxxx xxxxxxxx xxxxxxxx R.y+R.h+R.x+R.z
	movss	[ebx+ecx], xmm1
	sub	ecx, 4
	jns	.MulLoop

	ret

endproc
_libMulVectorMatrix_arglen	EQU	8

;--------------------------------------------------------------
;--                      CreateCamera()                      --
;--------------------------------------------------------------
_libCreateCamera

	Garbage1
	or	dword [ModUsed], 00000004h

	push	esi
	push	edi

	; Calculate b = norm(Up)
	mov	esi, _CameraUp
	mov	edi, _TempVectorB
	mov	ecx, 4
	rep	movsd
	invoke	_NormalizeVector, dword _TempVectorB

	; Calculate a = norm(LookAt-Eye), negate, store to camera matrix
	movups	xmm0, [_CameraLookAt]
	movups	xmm1, [_CameraEye]
	subps	xmm0, xmm1
	movups	[_TempVectorA], xmm0
	invoke	_NormalizeVector, dword _TempVectorA
	movups	xmm0, [_TempVectorA]
	xorps	xmm1, xmm1
	subps	xmm1, xmm0
	movups	[_CameraMatrix+Matrix.r3c1], xmm1

	; Calculate c = a x b, b = c x a, store to camera matrix
	mov	esi, _TempVectorA
	mov	edi, _TempVectorC
	mov	ecx, 4
	rep	movsd
	invoke	_CrossProduct, dword _TempVectorC, dword _TempVectorB
	movups	xmm0, [_TempVectorC]
	movups	[_CameraMatrix+Matrix.r1c1], xmm0
	invoke	_CrossProduct, dword _TempVectorC, dword _TempVectorA
	movups	xmm0, [_TempVectorC]
	movups	[_CameraMatrix+Matrix.r2c1], xmm0

	; Store 0.0 0.0 0.0 1.0 to last row of camera matrix
	; Remember h coordinate is highest order dword
	movss	xmm0, [_RealOne]
	shufps	xmm0, xmm0, 00111001b
	movups	[_CameraMatrix+Matrix.r4c1], xmm0	

	pop	edi
	pop	esi
	ret

;--------------------------------------------------------------
;--                      MoveCamera()                        --
;--------------------------------------------------------------
_libMoveCamera

	Garbage1
	or	dword [ModUsed], 00000008h
	
	xor	eax, eax
	mov	bl, [_MPFlags]
	test	bl, 00110010b
	jz	near .NoMove
	test	bl, 00000010b
	jnz	.Move
	movzx	edx, byte [_CameraPos]
	test	bl, 00100000b
	jnz	.Return

.Next
	inc	edx
	cmp	edx, 4
	jl	.Return
	xor	edx, edx

.Return
	mov	[_CameraPos], dl
	shl	edx, 4
	mov	eax, edx
	shl	edx, 1
	add	eax, edx
	mov	esi, _CameraPositions
	add	esi, eax
	mov	edi, _CameraEye
	mov	ecx, 12
	rep	movsd
	jmp	.MoveDone

.Move
	movups	xmm0, [_CameraEye]
	movups	xmm1, [_CameraLookAt]
	movups	xmm2, xmm1
	subps	xmm2, xmm0
	and	bl, 00001100b
	cmp	bl, 00001000b
	jb	.LeftorRight

.ForwardorBackward
	test	bl, 00000100b
	jz	.Forward

.Backward
	movups	[_CameraLookAt], xmm0
	subps	xmm0, xmm2
	movups	[_CameraEye], xmm0
	jmp	.MoveDone

.Forward
	movups	[_CameraEye], xmm1
	addps	xmm1, xmm2
	movups	[_CameraLookAt], xmm1
	jmp	.MoveDone

.LeftorRight
	xorps	xmm3, xmm3
	movss	xmm4, [_RealOne]
	shufps	xmm4, xmm4, 10010011b
	test	bl, 00000100b
	jz	.Right
	addps	xmm3, xmm4
	jmp	.Strafe

.Right
	subps	xmm3, xmm4

.Strafe
	movups	[_TempVectorA], xmm2
	movups	[_TempVectorB], xmm3
	invoke	_CrossProduct, dword _TempVectorA, dword _TempVectorB
	invoke	_NormalizeVector, dword _TempVectorA
	movups	xmm0, [_CameraEye]
	movups	xmm1, [_CameraLookAt]
	movups	xmm3, [_TempVectorA]
	addps	xmm0, xmm3
	movups	[_CameraEye], xmm0
	addps	xmm1, xmm3
	movups	[_CameraLookAt], xmm1

.MoveDone
	and	byte [_MPFlags], 11000001b
	mov	eax, 1

.NoMove
	ret

;--------------------------------------------------------------
;--                    ConvertPoint()                        --
;--------------------------------------------------------------
proc _libConvertPoint
.Point	arg	4
.Vector	arg	4

	Garbage1
	or	dword [ModUsed], 00000010h

	push	esi
	push	edi

	; Create Translation Matrix
	mov	esi, _IdentityMatrix
	mov	edi, _TranslateMatrix
	mov	ecx, 16
	rep	movsd					; Load identity matrix
	movups	xmm0, [_CameraEye]
	xorps	xmm1, xmm1
	subps	xmm1, xmm0
	movss	[_TranslateMatrix+Matrix.r1c4], xmm1
	shufps	xmm1, xmm1, 00111001b
	movss	[_TranslateMatrix+Matrix.r2c4], xmm1
	shufps	xmm1, xmm1, 00111001b
	movss	[_TranslateMatrix+Matrix.r3c4], xmm1	; Load negative eye coords

	; Point = Pers * (Camera * (Translate * Point))
	mov	esi, [ebp+.Vector]
	mov	edi, _TempVectorD
	mov	ecx, 4
	rep	movsd
	sub	edi, 16
	invoke	_MulVectorMatrix, edi, dword _TranslateMatrix
	call	_CreateCamera
	invoke	_MulVectorMatrix, edi, dword _CameraMatrix
	invoke	_MulVectorMatrix, edi, dword _PerspectiveMatrix

	; Convert Point to Screen Coordinates
	movups		xmm0, [edi]
	movups		xmm1, xmm0
	shufps		xmm1, xmm1, 11111111b
	divps		xmm0, xmm1
	movups		xmm1, [_NormalCoordsVector]
	mulps		xmm0, xmm1
	movss		xmm1, [_RealOne]
	shufps		xmm1, xmm1, 01000000b
	addps		xmm0, xmm1
	movups		xmm1, [_ScreenScaleVector]
	mulps		xmm0, xmm1

	; Round Point to Integer Values
	mov		edi, [ebp + .Point]
	cvtps2pi	mm0, xmm0
	movd		eax, mm0
	mov		[edi + Point.x], ax
	psrlq		mm0, 32
	movd		eax, mm0
	mov		[edi + Point.y], ax
	shufps		xmm0, xmm0, 01001110b
	cvtps2pi	mm0, xmm0
	movd		eax, mm0
	mov		[edi + Point.z], ax
	emms

	pop	edi
	pop	esi
	ret

endproc
_libConvertPoint_arglen	EQU	8

;--------------------------------------------------------------
;--                     CalcNextPoint()                      --
;--------------------------------------------------------------
proc _libCalcNextPoint
.Bresenham	arg	4

	Garbage1
	or	dword [ModUsed], 00000020h

	push	edi
	mov	edi, [ebp+.Bresenham]

	cmp	word [edi + Bresenham.error1], 0
	jl	.NoDiag1
	
.Diag1
	mov	ax, [edi + Bresenham.xdiaginc]
	add	[edi + Bresenham.x], ax
	mov	ax, [edi + Bresenham.ydiaginc]
	add	[edi + Bresenham.y], ax
	mov	ax, [edi + Bresenham.error1diaginc]
	add	[edi + Bresenham.error1], ax
	jmp	.Bres2

.NoDiag1
	mov	ax, [edi + Bresenham.xnodiaginc]
	add	[edi + Bresenham.x], ax
	mov	ax, [edi + Bresenham.ynodiaginc]
	add	[edi + Bresenham.y], ax
	mov	ax, [edi + Bresenham.error1nodiaginc]
	add	[edi + Bresenham.error1], ax

.Bres2
	cmp	word [edi + Bresenham.error2], 0
	jl	.NoDiag2

.Diag2
	mov	ax, [edi + Bresenham.zdiaginc]
	add	[edi + Bresenham.z], ax
	mov	ax, [edi + Bresenham.error2diaginc]
	add	[edi + Bresenham.error2], ax
	jmp	.Done

.NoDiag2
	mov	ax, [edi + Bresenham.error2nodiaginc]
	add	[edi + Bresenham.error2], ax

.Done
	pop	edi
	ret

endproc
_libCalcNextPoint_arglen	EQU	4

;--------------------------------------------------------------
;--                      DrawPixel()                         --
;--------------------------------------------------------------
proc _libDrawPixel
.DestOff	arg	4
.ZBufferOff	arg	4
.X		arg	2
.Y		arg	2
.Z		arg	2
.Color		arg	4

	Garbage1
	or	dword [ModUsed], 00000040h

	push	esi
	push	edi

	mov	ax, [ebp+.X]
	cmp	ax, 0
	jl	.Done
	cmp	ax, 640
	jge	.Done
	mov	ax, [ebp+.Y]
	cmp	ax, 0
	jl	.Done
	cmp	ax, 480
	jge	.Done

	mov	esi, [ebp+.ZBufferOff]
	mov	ecx, esi
	mov	edi, [ebp+.DestOff]
	movzx	edx, word [ebp+.Y]
	shl	edx, 7
	mov	eax, edx
	shl	edx, 2
	add	eax, edx
	movzx	edx, word [ebp+.X]
	add	eax, edx
	shl	eax, 1
	add	esi, eax
	shl	eax, 1
	add	edi, eax

	mov	ax, [ebp+.Z]
	cmp	ax, [esi]
	ja	.Done
	
	mov	[esi], ax
	mov	eax, [ebp+.Color]
	mov	[edi], eax	

.Done
	pop	edi
	pop	esi
	ret

endproc
_libDrawPixel_arglen	EQU	18

;--------------------------------------------------------------
;--                        DrawLine()                        --
;--------------------------------------------------------------
proc _libDrawLine
.DestOff	arg	4
.PointA		arg	4
.PointB		arg	4
.Color		arg	4

	Garbage1
	or	dword [ModUsed], 00000080h

	push	esi
	push	edi

	invoke	_CreateBresenham3D, dword _LineBres, dword [ebp+.PointA], dword [ebp+.PointB]
	movzx	ecx, word [_LineBres + Bresenham.length]

.LineLoop
	push	ecx
	invoke	_DrawPixel, dword [ebp+.DestOff], dword [_ZBufferOff], word [_LineBres + Bresenham.x], word [_LineBres + Bresenham.y], word [_LineBres + Bresenham.z], dword [ebp+.Color]
	invoke	_CalcNextPoint, dword _LineBres
	pop	ecx
	loop	.LineLoop

	pop	edi
	pop	esi
	ret

endproc
_libDrawLine_arglen	EQU	16

;--------------------------------------------------------------
;--                      DrawTriangle()                      --
;--------------------------------------------------------------
proc _libDrawTriangle
.DestOff	arg	4
.PointA		arg	4
.PointB		arg	4
.PointC		arg	4
.Color		arg	4

	Garbage1
	or	dword [ModUsed], 000000100h

	push	esi
	push	edi

	; Convert Points
	invoke	_ConvertPoint, dword _TempPointA, dword [ebp + .PointA]
	invoke	_ConvertPoint, dword _TempPointB, dword [ebp + .PointB]
	invoke	_ConvertPoint, dword _TempPointC, dword [ebp + .PointC]

	; Draw Triangle 1
	invoke	_CreateBresenham3D, dword _TriangleBres, dword _TempPointA, dword _TempPointB
	movzx	ecx, word [_TriangleBres + Bresenham.length]
.TriangleLoop1
	push	ecx
	invoke	_DrawLine, dword [ebp + .DestOff], dword _TempPointC, dword _TriangleBres, dword [ebp + .Color]
	invoke	_CalcNextPoint, dword _TriangleBres
	pop	ecx
	loop	.TriangleLoop1

	; Draw Triangle 2
	invoke	_CreateBresenham3D, dword _TriangleBres, dword _TempPointC, dword _TempPointA
	movzx	ecx, word [_TriangleBres + Bresenham.length]
.TriangleLoop2
	push	ecx
	invoke	_DrawLine, dword [ebp + .DestOff], dword _TempPointB, dword _TriangleBres, dword [ebp + .Color]
	invoke	_CalcNextPoint, dword _TriangleBres
	pop	ecx
	loop	.TriangleLoop2

	; Draw Triangle 3
	invoke	_CreateBresenham3D, dword _TriangleBres, dword _TempPointB, dword _TempPointC
	movzx	ecx, word [_TriangleBres + Bresenham.length]
.TriangleLoop3
	push	ecx
	invoke	_DrawLine, dword [ebp + .DestOff], dword _TempPointA, dword _TriangleBres, dword [ebp + .Color]
	invoke	_CalcNextPoint, dword _TriangleBres
	pop	ecx
	loop	.TriangleLoop3

	pop	edi
	pop	esi
	ret

endproc
_libDrawTriangle_arglen	EQU	20

;--------------------------------------------------------------
;--                      AlphaCompose()                      --
;--------------------------------------------------------------
proc _libAlphaCompose
.Pixel		arg	4

	Garbage1
	or	dword [ModUsed], 00000200h

	mov	eax, [ebp+.Pixel]
	mov	ebx, eax
	shr	ebx, 24
	movd	mm0, ebx
	movd	mm1, eax
	pxor	mm2, mm2

	punpcklbw	mm0, mm2
	punpcklwd	mm0, mm0
	punpckldq	mm0, mm0	
	punpcklbw       mm1, mm2	
	pmullw		mm0, mm1
	psrlw		mm0, 8
	packuswb	mm0, mm2

	movd	eax, mm0
	ret

endproc
_libAlphaCompose_arglen	EQU	4

;--------------------------------------------------------------
;--                        DrawText()                        --
;--------------------------------------------------------------
proc _libDrawText
.StringOff	arg	4
.DestOff	arg	4
.X		arg	2
.Y		arg	2
.Color		arg	4

	Garbage1
	or	dword [ModUsed], 00000400h

	push	esi
	push	edi

	mov	ebx, [ebp+.StringOff]
	mov	edi, [ebp+.DestOff]

	movzx	edx, word [ebp+.Y]
	shl	edx, 7
	mov	eax, edx
	shl	edx, 2
	add	eax, edx
	movzx	edx, word [ebp+.X]
	add	eax, edx
	shl	eax, 2
	add	edi, eax	

.DrawTextLoop
	cmp	byte [ebx], 0
	je	.DrawTextDone

	movzx	eax, byte [ebx]
	shl	eax, 6
	mov	esi, eax
	add	esi, [_FontOff]
	mov	ecx, 16
	push	edi

.RowLoop
	push	ecx
	mov	ecx, 16

.ColLoop
	mov	eax, [esi]
	or	eax, [ebp+.Color]
	push	ebx
	push	ecx
	invoke	_AlphaCompose, eax
	pop	ecx
	pop	ebx
	mov	[edi], eax
	add	esi, 4
	add	edi, 4
	loop	.ColLoop

	pop	ecx
	add	esi, 127*16*4
	add	edi, 624*4
	loop	.RowLoop

	pop	edi
	add	edi, 64
	inc	ebx
	jmp	.DrawTextLoop

.DrawTextDone
	pop	edi
	pop	esi
	emms
	ret

endproc
_libDrawText_arglen	EQU	16

;--------------------------------------------------------------
;--                    InstallKeyboard()                     --
;--------------------------------------------------------------
_libInstallKeyboard

	Garbage1
	or	dword [ModUsed], 00000800h


        invoke  _LockArea, ds, dword _kbPort, dword 2
        invoke  _LockArea, ds, dword _kbIRQ, dword 1
        invoke  _LockArea, ds, dword _MPFlags, dword 1
        invoke  _LockArea, cs, dword _libKeyboardISR, dword _libKeyboardISR_end-_libKeyboardISR
	movzx	eax, byte [_kbINT]
	invoke	_Install_Int, eax, dword _libKeyboardISR
	ret

;--------------------------------------------------------------
;--                     RemoveKeyboard()                     --
;--------------------------------------------------------------
_libRemoveKeyboard

	Garbage1
	or	dword [ModUsed], 00001000h

	movzx	eax, byte [_kbINT]
	invoke	_Remove_Int, eax
	ret

;--------------------------------------------------------------
;--                      KeyboardISR()                       --
;--------------------------------------------------------------
_libKeyboardISR
	push	edx

	Garbage1
	or	dword [ModUsed], 00002000h

	mov	dx, [_kbPort]
	in	al, dx

	cmp	al, ESC
	je	.Exit
	cmp	al, RIGHTARROW
	je	.Right
	cmp	al, LEFTARROW
	je	.Left
	cmp	al, UPARROW
	je	.Up
	cmp	al, DOWNARROW
	je	.Down
	jmp	.Done

.Exit
	or	byte [_MPFlags], 00000001b
	jmp	.Done

.Right
	or	byte [_MPFlags], 00000010b
	jmp	.Done

.Left
	or	byte [_MPFlags], 00000110b
	jmp	.Done

.Up
	or	byte [_MPFlags], 00001010b
	jmp	.Done

.Down
	or	byte [_MPFlags], 00001110b

.Done
        mov     al, 20h
	cmp	byte [_kbIRQ], 8
	jb	.LowIRQ
	out	0A0h, al

.LowIRQ
        out     20h, al

        xor     eax, eax	; Don't chain original handler
	pop	edx
	ret
_libKeyboardISR_end

;--------------------------------------------------------------
;--                      InstallMouse()                      --
;--------------------------------------------------------------
_libInstallMouse

	Garbage1
	or	dword [ModUsed], 00004000h

	invoke  _LockArea, ds, dword _MPFlags, dword 1
        invoke  _LockArea, cs, dword _MouseCallback, dword _libMouseCallback_end-_libMouseCallback

        invoke  _Get_RMCB, dword _MouseSeg, dword _MouseOff, dword _libMouseCallback, dword 1
       	test	eax, eax
	jnz	.MouseDone

        mov     dword [DPMI_EAX], 0Ch
        mov     dword [DPMI_ECX], 0Ah
        xor     edx, edx
        mov     dx, [_MouseOff]
        mov     [DPMI_EDX], edx
        mov     ax, [_MouseSeg]
        mov     [DPMI_ES], ax
        mov     bx, 33h
        call    DPMI_Int
        xor     eax, eax

.MouseDone
        ret			    

;--------------------------------------------------------------
;--                        RemoveMouse()                     --
;--------------------------------------------------------------
_libRemoveMouse

	Garbage1
	or	dword [ModUsed], 00008000h


        mov     dword [DPMI_EAX], 0Ch
        xor     edx, edx
        mov     [DPMI_ECX], edx
        mov     [DPMI_EDX], edx
        mov     [DPMI_ES], dx
        mov     bx, 33h
        call    DPMI_Int
        invoke  _Free_RMCB, word [_MouseSeg], word [_MouseOff]
        ret

;--------------------------------------------------------------
;--                        MouseCallback()                   --
;--------------------------------------------------------------
proc _libMouseCallback
.DPMIRegsPtr   arg     4

	Garbage1
	or	dword [ModUsed], 00010000h

	push	eax
	push	edx
	push    esi
	mov	esi, [ebp+.DPMIRegsPtr]

	mov	eax, [es:esi+DPMI_EAX_off]
	test	eax, 02h
	jnz	.Next
	test	eax, 08h
	jnz	.Return
	jmp	.Done

.Next
	or	byte [_MPFlags], 00010000b
	jmp	.Done

.Return
	or	byte [_MPFlags], 00100000b

.Done
        pop     esi
	pop	edx
	pop	eax
	ret

endproc
_libMouseCallback_end
_libMouseCallback_arglen	EQU	4

