; ECE 291 Spring 2003 MP4    
; Mandlebrot Fractals
;
; Completed By:
;  Your Name
;  Date
;
; Zbigniew Kalbarczyk
; Guest Authors - Michael Urman, Ajay Ladsaria
; University of Illinois Urbana Champaign
; Dept. of Electrical & Computer Engineering
;
; Ver 1.0

%include "lib291.inc"
;%include "libmp4.inc"

	BITS 32

	GLOBAL _main

; Define Keyboard Scancodes
ESC		EQU	1
UPARROW		EQU	72	; maybe slide the window by 1/2? 1/4?
LEFTARROW	EQU	75
RIGHTARROW	EQU	77
DOWNARROW	EQU	80

QUIT_BIT	EQU	1
ZOOM_IN_BIT	EQU	2
ZOOM_OUT_BIT	EQU	4
ZOOM_BITS	EQU	6

; Complex Structure
STRUC Complex
.Real	resq	1
.Imag	resq	1
ENDSTRUC

	SECTION .bss

_ScreenOff	resd	1	; pointer to screen buffer
_MandelOff	resd	1	; pointer to Mandelbrot Buffer
_GraphicsMode	resw	1	; ex291 graphics mode

_kbINT		resb	1	; mapped keyboard interrupt
_kbIRQ		resb	1	; mapped keyboard irq
_kbPort		resw	1	; mapped keyboard port

_MouseSeg	resw	1       ; real mode segment for MouseCallback
_MouseOff	resw	1	; real mode offset for MouseCallback

_CameraPos	resb	1	; Current Camera Position

_MPFlags	resb	1	; MP flags
				; Bit 0 - User Exit Flag
				; Bit 1 - Calculation in progress
				; Bit 2 - Zoom started

				
	SECTION .data

; Floating Point Values Defined for Easy Access
_RealOne	dd	1.0

_MinX		dq	-1.5
_MaxX		dq	1.5
_MinY		dq	-1.5
_MaxY		dq	1.5

_MouseX		dw	0
_MouseY		dw	1

	SECTION .text

; Program Start
_main
	call	_LibInit

	; Allocate Screen Buffer
	invoke	_AllocMem, dword 640*480*4
	cmp	eax, -1
	je	near .memerror
	mov	[_ScreenOff], eax

	; Allocate Buffer
	invoke	_AllocMem, dword 640*480*1
	cmp	eax, -1
	je	near .memerror
	mov	[_MandelOff], eax

	; Allocate Font Image Buffer
;	invoke	_AllocMem, dword 128*16*16*4
;	cmp	eax, -1
;	je	near .memerror
;	mov	[_FontOff], eax

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
	;call	_InstallMouse
	;test	eax, eax
	;jnz	.mouseerror

	finit
	call	_MP4Main	

.mouseerror
	;call	_RemoveMouse
	call	_UnsetGraphicsMode
	call	_RemoveKeyboard

.graphicserror
	call	_ExitGraphics

.memerror
	call	_LibExit
	;call	_MP4LibExit
	ret


;--------------------------------------------------------------
;--                        MP4Main()                         --
;--------------------------------------------------------------
_MP4Main
	
	; calculate mandelbrot
	invoke	_CalcAllPixels, dword [_MandelOff]

	;mov ecx, 640*480
	;mov edi, [_MandelOff]
	;mov al, 80
	;rep stosb

	; copy to the screen buffer
	invoke	_MapBuffer, dword [_MandelOff], dword [_ScreenOff]

	; display
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

.MPLoop
	test	byte[_MPFlags], QUIT_BIT
	jnz	near .MainDone
	test	byte[_MPFlags], ZOOM_BITS
	jz	.MPLoop

	;invoke	SetZoom
	;jmp	short _MP4Main

.MainDone
	ret

;--------------------------------------------------------------
;--          Replace library calls with your code            --
;--         Do not forget to add function headers!           --
;--------------------------------------------------------------

MapTable dw	0, 0ffh, 0bfh, 070fh, 040h, 0ff00h, 0bf00h, 07000h, 04000h 

; MapBuffer
proc _MapBuffer
.src	    arg 4
.dest	    arg 4
	push edi
	push esi

	mov ecx, 640*480
	mov esi, [ebp+.src]
	mov edi, [ebp+.dest]
.mappixel
	lodsb
	; copy al to all lower three bytes
	; - profile against mul by 010101h if you care

%if 0
	shl eax, 8
	mov al, ah
	shl eax, 8
	mov al, ah
%endif
	;jmp .dontusetable

	and eax, 0FFh
	cmp al, 8
	ja .dontusetable
	mov eax, [MapTable + eax*4] 
	jmp .store

.dontusetable
	xor ebx, ebx
	mov edx, eax
	neg al
	shr edx, 1
	jnc .redNotActive
	mov bl, al
.redNotActive
	shr edx, 1
	jnc .greenNotActive
	shl ebx, 8
	mov bl, al
.greenNotActive
	shr edx, 1
	jnc .blueNotActive
	shl ebx, 8
	mov bl, al
.blueNotActive
	mov eax, ebx
.store
	stosd

	dec ecx
	jnz .mappixel

	pop esi
	pop edi

	ret
endproc
_MapBuffer_arglen  EQU	8

;CalcAllPixels
;CalcAllPixels(int *dest) - loop over 640*480 pixels calling CalcPixel to get value; write as bytes into dest

proc _CalcAllPixels
.dest	arg	4

.C	equ	-16		;2 quad word i.e. complex
.dx	equ	-24		;quad word
.dy	equ	-32		;quad word
.d	equ	-36		;dword
.LOCALS equ	36

	sub	esp, .LOCALS

	push	edi
	
	; calculate update intervals for y and x
	; note: this isn't necessarily as accurate as the more expensive
	; recalculating per index due to floating point imprecision
	mov	ecx, 480
	mov	[ebp+.d], ecx
	fild	dword [ebp+.d]		;st0 = 480.0
	fld	qword [_MaxY]		;st0 = 1.0
	fld	qword [_MinY]		;st0 = 0.0
	fsubp	st1	 		;st0 = 1.0 - 0.0 
	fdivrp	st1	; fdivr ?	;result = 1/480.0
	fstp	qword [ebp+.dy]

	mov	edx, 640
	mov	[ebp+.d], edx
	fild	dword [ebp+.d]
	fld	qword [_MaxX]
	fld	qword [_MinX]
	fsubp	st1	; fsubr ?
	fdivrp	st1	; fdivr ?
	fstp	qword [ebp+.dx]		;result = 1/640.0

	mov	edi, [_MandelOff]
	; set up Y0
	fld	qword[_MinY]		;st0 = 0.0
	;mov	ebx, [ebp+.C]
	;fstp	qword[ebx+Complex.Imag]
	fstp	qword[ebp + .C + Complex.Imag]

	; loop 480 times in Y
.loopy
	fld	qword[_MinX]
	;mov	ebx, [ebp+.C]
	;fstp	qword[ebx+Complex.Real]
	fstp	qword[ebp + .C + Complex.Real]
	;   loop 640 times in X
.loopx
	pusha
	;     invoke _CalcPixel on Complex(x,y)
	mov eax, ebp
	add eax, .C
	;invoke	_CalcPixel, dword [ebp+.C]
	invoke	_CalcPixel, eax
	;     write result to .buf
	mov	[edi], al
	popa

	; move right one pixel, one .dx
	inc	edi
	;fld	qword[ebx+Complex.Real]
	fld	qword[ebp + .C + Complex.Real]

	fadd	qword[ebp+.dx]
	;fstp	qword[ebx+Complex.Real]
	fstp	qword[ebp + .C + Complex.Real]

	dec	edx
	jnz	.loopx

	; update screen here, if you do
	; pusha
	; -- update
	; popa
	;jmp .done
	;pusha
	;invoke	_MapBuffer, dword [_MandelOff], dword [_ScreenOff]
	;invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	;popa
	; move down one row - one .dy
	;fld	qword[ebx+Complex.Imag]
	mov edx, 640
	fld	qword[ebp + .C + Complex.Imag]
	fadd	qword[ebp+.dy]
	;fstp	qword[ebx+Complex.Imag]
	fstp	qword[ebp + .C + Complex.Imag]

	dec	ecx
	jnz	.loopy

.done
	pop	edi
	add	esp, .LOCALS
	ret

endproc
_CalcAllPixels_arglen	equ	4



;CalcPixel
;CalcPixel(complex *C) - start Z = 0, and apply Z = (Z-1)^2+C up to 255 times return count taken for |Z| to reach at least 2, or 0 if it does not.
dump	dq	0.0
proc _CalcPixel
.C	arg	4

.tmp	equ	-16
.LOCALS equ	16

	sub	esp, .LOCALS

	; initialize Z to zero
	xor	edx, edx
	mov	[ebp + .tmp + Complex.Real], edx
	mov	[ebp + .tmp + Complex.Real+4], edx
	mov	[ebp + .tmp + Complex.Imag], edx
	mov	[ebp + .tmp + Complex.Imag+4], edx

.iterate
	;fld	qword [ebp+.tmp+Complex.Real]
	;fld	qword [ebp+.tmp+Complex.Imag]

	; Z2 = (Z-1)^2
	push	edx
	mov	eax, ebp
	add	eax, .tmp
	invoke	_ComplexSquare, eax 
	pop	edx
	
	;fld	qword [ebp+.tmp+Complex.Real]
	;fld	qword [ebp+.tmp+Complex.Imag]
	;fstp	qword [dump]
	;fstp	qword [dump]
	;fstp	qword [dump]
	;fstp	qword [dump]
	; find C ?

	; Z2 + C
	; Re(Z2) += Re(C)
	;mov	ebx, [ebp+.Z]
	mov	ecx, [ebp+.C]
	fld	qword [ebp + .tmp + Complex.Real]
	fld	qword [ecx+Complex.Real]
	faddp	st1
	fstp	qword [ebp + .tmp + Complex.Real]

;----------------------change below to above after debugging
	;fst	qword [ebp + .tmp + Complex.Real]
	; Im(Z2) += Im(C)
	fld	qword [ebp + .tmp + Complex.Imag]
	fld	qword [ecx+Complex.Imag]
	faddp	st1
	fstp	qword [ebp + .tmp + Complex.Imag]

;----------------------delete below after debugging
	;fstp	qword [dump]

	;; XXX something here is fishy; this cuts us off too early or
	;;too late, or something i think.  Test it.

	; exit if we're still not done
	inc	dl
	cmp	dl, 100
	jz	.infinity

	push	edx

	mov	eax, ebp
	add	eax, .tmp
	;invoke	_CheckInfinity, qword [ebp+.Z]
	invoke	_CheckInfinity, eax

	pop	edx
	test	eax, eax
	jz	.iterate


	mov	eax, edx
	;add	eax, 50
	jmp	.done
.infinity
	;mov	eax, 140
	xor	eax, eax
.done
	add	esp, .LOCALS
	ret

endproc
_CalcPixel_arglen	EQU	4

;ComplexSquare
;ComplexSquare(complex *Z) - squares Z and writes it back in place
proc _ComplexSquare
.Z	arg	4
	
	mov	ebx, [ebp+.Z]

	; 2 a b
	fld	qword [ebx+Complex.Real]
	fld	qword [ebx+Complex.Imag]
	fmulp	st1
	fadd	st0	; no pop

	; aa - bb
	fld	qword [ebx+Complex.Real]
	fmul	st0
	fld	qword [ebx+Complex.Imag]
	fmul	st0
	fsubp	st1	;
	fstp	qword [ebx+Complex.Real]

	; old 2 a b value from top of stack
	fstp	qword [ebx+Complex.Imag]

	ret
	
endproc
_ComplexSquare_arglen	equ	4

;CheckInfinity
;CheckInfinity(complex *Z) - if |Z| > 2 return 1, else return 0
proc _CheckInfinity
.Z	arg	4

	; aa+bb
	mov	ebx, [ebp+.Z]
	fld	qword [ebx+Complex.Real]
	fmul	st0
	fld	qword [ebx+Complex.Imag]
	fmul	st0
	faddp	st1

	; subtract 4 from aa+bb
	fld1
	fadd	st0
	fadd	st0
	fsubp	st1	; |z| - 2 now in st0

	; use stack location as temporary storage.
	; don't try this at home, kids
	;mov	ebx, [ebp+.Z]
	;fstp	dword [ebx+Complex.Real]
	fstp	dword [ebp+.Z]
	xor	eax, eax
	cmp	dword [ebp+.Z], 0	; sign flag works alike
	;adc	eax, 0			; carry will be set if borrow
	jl	.done
	mov	eax, 1
.done
	ret				; was necessary, i.e. was < 0

endproc
_CheckInfinity_arglen	equ	4

;--------------------------------------------------------------
;--                    InstallKeyboard()                     --
;--------------------------------------------------------------
_InstallKeyboard

;	call	_libInstallKeyboard
        invoke  _LockArea, ds, dword _kbPort, dword 2
        invoke  _LockArea, ds, dword _kbIRQ, dword 1
        invoke  _LockArea, ds, dword _MPFlags, dword 1
        invoke  _LockArea, cs, dword _KeyboardISR, dword _KeyboardISR_end-_KeyboardISR
	movzx	eax, byte [_kbINT]
	invoke	_Install_Int, eax, dword _KeyboardISR
	ret

;--------------------------------------------------------------
;--                     RemoveKeyboard()                     --
;--------------------------------------------------------------
_RemoveKeyboard

	;call	_libRemoveKeyboard
	movzx	eax, byte [_kbINT]
	invoke	_Remove_Int, eax
	ret

;--------------------------------------------------------------
;--                      KeyboardISR()                       --
;--------------------------------------------------------------
_KeyboardISR

	or byte[_MPFlags], QUIT_BIT
;	call	_libKeyboardISR
	ret

_KeyboardISR_end




%if 0

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

%endif
