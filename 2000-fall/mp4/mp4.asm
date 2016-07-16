; ECE 291 Fall 2000 MP 4
; -- Truecolor Paint --
;
; Completed By:
;  Your Name
;
; Professor Kalbarczyk
; Guest Authors - Peter Johnson, Michael Urman
; University of Illinois Urbana Champaign
; Dept. of Electrical & Computer Engineering
;
; Ver 1.0

%include "lib291.inc"
%include "libmp4.inc"

	BITS 32

	GLOBAL _main

; Define functions, variables used by main()
EXTERN _LoadPNG
_LoadPNG_arglen		EQU	18
EXTERN _CurrentState
EXTERN _StateHandlers
EXTERN _RubberBandFlag

; Event structure - 8 bytes long so we can address it easily
STRUC Event
.Condition	resw	1	; Condition bitmask (in mouse handler format)
.X		resw	1	; X coordinate in screen pixels from left
.Y		resw	1	; Y coordinate in screen pixels from top
.Buttons	resw	1	; Button status (in mouse handler format)
ENDSTRUC

; Event Queue size (# of elements and size in bytes)
QUEUE_ELEMENTS	equ	13
QUEUE_SIZE	equ	QUEUE_ELEMENTS * Event_size

	SECTION .bss

_ExitFlag	resb	1	; Set to 1 to exit immediately

_MouseSeg	resw	1	; Mouse RMCB segment
_MouseOff	resw	1	; Mouse RMCB offset

_QueueNumEvents	resb	1	; Number of events in the queue
_Queue		resb	(QUEUE_ELEMENTS+1)*Event_size	; The queue itself

_ImageBlock	resw	1	; Non-rubberband image
_OverlayBlock	resw	1	; Overlay images (for alphablit)
_FontBlock	resw	1	; The antialiased font

	SECTION .data

_QueueFirst	dd	_Queue	; Pointer to the head of the queue

; Required files; loaded at startup
_BackgroundFN	db	'paintbg.png',0
_FontFN		db	'font.png',0

; Use this constant in DrawPixelD() to normalize the 0-1.5 range to 0-1 range
_MapTo1		dq	1.5

; Use this constant in AlphaBlit() to round the division by 256 properly.
_RoundingFactor	dd	800080h,	80h

	SECTION .text

; Program Start
_main
	call	_LibInit

	; Change this to 0 to simplify debugging
	; (it disables the "rubberbanding" feature which will call the
	;  respective function every time the mouse moves).
	; During handin, we will test with rubberbanding enabled!
	mov	byte [_RubberBandFlag], 1

	; Graphics init
	invoke	_SetGraphics, word 640, word 480
	test	eax, eax
	jnz	near .quit

	; Mouse/Keyboard init
	call	_InstallMouse
	call	libInstallKeyboard

	; Allocate Back Image buffer
	invoke	_AllocMem, dword 640*480*4
	cmp	ax, -1
	je	near .exit
	mov	[_ImageBlock], ax

	; Allocate Overlay Image buffer
	invoke	_AllocMem, dword 640*480*4
	cmp	ax, -1
	je	near .exit
	mov	[_OverlayBlock], ax

	; Allocate Font Image buffer
	invoke	_AllocMem, dword 2048*16*4
	cmp	ax, -1
	je	.exit
	mov	[_FontBlock], ax

	; Load background, font, set up initial display
	invoke	_LoadPNG, dword _BackgroundFN, word [_ImageBlock], dword 0, dword 0, dword 0
	invoke	_LoadPNG, dword _FontFN, word [_FontBlock], dword 0, dword 0, dword 0
	call	libCopyImageToScreen
	call	_RefreshVideoBuffer

	; Main event processing loop
.loop:
	cmp	byte [_ExitFlag], 0
	jnz	.exit

	call	libCheckEvents
	test	eax, eax
	jz	.loop		; No events

	; Call proper state handler for new event
	movzx	eax, byte [_CurrentState]
	call	[_StateHandlers+eax*4]

	jmp	short .loop

.exit:
	; Shutdown and cleanup
	call	libRemoveKeyboard
	call	_RemoveMouse
	call	_UnsetGraphics
	invoke	_FreeMem, word [_FontBlock]
	invoke	_FreeMem, word [_OverlayBlock]
	invoke	_FreeMem, word [_ImageBlock]
.quit:
	call	MP4LibExit

	call	_LibExit
	ret


;--------------------------------------------------------------
;--                        ClearImage()                      --
;--------------------------------------------------------------
proc _ClearImage
%$Color		arg	4

	invoke	libClearImage, dword [ebp+%$Color]

endproc

;--------------------------------------------------------------
;--                        InstallMouse()                    --
;--------------------------------------------------------------
_InstallMouse

	call	libInstallMouse

	ret

;--------------------------------------------------------------
;--                        RemoveMouse()                     --
;--------------------------------------------------------------
_RemoveMouse

	call	libRemoveMouse

	ret

;--------------------------------------------------------------
;--                        MouseCallback()                   --
;--------------------------------------------------------------
proc _MouseCallback
%$DPMIRegsPtr	arg	4

	invoke	libMouseCallback, dword [ebp+%$DPMIRegsPtr]

endproc
_MouseCallback_end

;--------------------------------------------------------------
;--                        DrawChar()                        --
;--------------------------------------------------------------
proc _DrawChar
%$DestSel	arg	2
%$Dest		arg	4
%$Char		arg	2
%$CharNum	arg	4
%$Color		arg	4

	invoke	libDrawChar, word [ebp+%$DestSel], dword [ebp+%$Dest], word [ebp+%$Char], dword [ebp+%$CharNum], dword [ebp+%$Color]

endproc

;--------------------------------------------------------------
;--                        AlphaBlit()                       --
;--------------------------------------------------------------
proc _AlphaBlit
%$DestSel	arg	2
%$Dest		arg	4
%$DestWidth	arg	4
%$DestX		arg	2
%$DestY		arg	2
%$SrcSel	arg	2
%$Src		arg	4
%$SrcWidth	arg	4
%$SrcHeight	arg	4

	invoke	libAlphaBlit, word [ebp+%$DestSel], dword [ebp+%$Dest], dword [ebp+%$DestWidth], word [ebp+%$DestX], word [ebp+%$DestY], word [ebp+%$SrcSel], dword [ebp+%$Src], dword [ebp+%$SrcWidth], dword [ebp+%$SrcHeight]

endproc

;--------------------------------------------------------------
;--                        AlphaCompose()                    --
;--------------------------------------------------------------
_AlphaCompose

	call	libAlphaCompose

	ret

;--------------------------------------------------------------
;--                        AALine()                          --
;--------------------------------------------------------------
proc _AALine
%$x1	arg 2
%$y1	arg 2
%$x2	arg 2
%$y2	arg 2
%$color	arg 4

; These are local variables.. access them as [ebp+.varname]
; You need to uncomment the sub esp and mov esp lines to use these.
; Notice the last equ is the positive version of the last variable offset.

.du		equ	-4	;4 bytes
.dv		equ	-8	;4
.d		equ	-12	;4
.incrS		equ	-16	;4
.incrD		equ	-20	;4
.twovdu		equ	-24	;4
.u		equ	-28	;4
.v		equ	-32	;4
.invD		equ	-40	;8
.invD2du	equ	-48	;8
.uincr		equ	-52	;4
.vincr		equ	-56	;4
.uend		equ	-60	;4
.addr		equ	-64	;4
.vmax		equ	-68	;4
.temp		equ	-76	;8

.StackFrameSize	equ	76
;	sub	esp, .StackFrameSize

	invoke	libAALine, word [ebp+%$x1], word [ebp+%$y1], word [ebp+%$x2], word [ebp+%$y2], dword [ebp+%$color]

;	mov	esp, ebp
endproc

;--------------------------------------------------------------
;--                        DrawPixelD()                      --
;--------------------------------------------------------------
_DrawPixelD_arglen equ 8
proc _DrawPixelD
%$addr	arg 4
%$color	arg 4

	invoke	libDrawPixelD, dword [ebp+%$addr], dword [ebp+%$color]

endproc

