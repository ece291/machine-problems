; MP3 - Your Name - Today's Date
;
;
;
;
; Josh Potts, Summer 2001
; Guest Author: Ajay Ladsaria
; Resources: MP3, MP4 Spring 2001 Michael Urman, Ryan Chmiel
; University of Illinois, Urbana-Champaign
; Dept. of Electrical and Computer Engineering

	BITS	16

;====== SECTION 1: Define constants =======================================

        CR      	EQU     0Dh
        LF      	EQU     0Ah
        BEL     	EQU     07h
	DOWNARROW	EQU	80
	RIGHTARROW	EQU	77
	LEFTARROW	EQU	75
	UPARROW		EQU	72
	SPACEBAR	EQU	57

	PALETTE_OFF	EQU	740
	GAMEBOARD_OFF	EQU	30
	SCORE_OFF	EQU	1060
	ARROW_OFF	EQU	24*160+GAMEBOARD_OFF+4
	PAL_ARROW_OFF	EQU	PALETTE_OFF+160

	ARROW		EQU	0618h
	PAL_ARROW	EQU	0618h
	NUM_COLORS	EQU	6

;====== SECTION 2: Declare external procedures ============================

EXTERN  kbdine, dspout, dspmsg, mp3xit, ascbin, binasc
EXTERN  kbdin, dosxit
EXTERN  libDrawGameboard, libDrawPalette, libDrawArrow, libDrawPaletteArrow
EXTERN  libInstallTimer, libRemoveTimer, libTimerISR, libDelay
EXTERN	libInstallKeyboard, libRemoveKeyboard, libKeyboardISR
EXTERN	libPercolateUp, libCheckShot, libChangeColor, libMoveArrow


GLOBAL DrawGameboard, DrawPalette, DrawArrow, DrawPaletteArrow
GLOBAL InstallTimer, RemoveTimer, TimerISR, Delay
GLOBAL InstallKeyboard, RemoveKeyboard, KeyboardISR
GLOBAL PercolateUp, CheckShot, ChangeColor, MoveArrow

GLOBAL	GameFlags, APos, PAPos, Gameboard, TimerV, KeyboardV, Colors
GLOBAL	MoveUpTime, TimerTick

;====== SECTION 3: Define stack segment ===================================

SEGMENT stkseg STACK                    ; *** STACK SEGMENT ***
        resb      64*8
stacktop:
        resb      0                     ; work around NASM bug

;====== SECTION 4: Define code segment ====================================

SEGMENT code                            ; *** CODE SEGMENT ***

;====== SECTION 5: Declare variables for main procedure ===================
GameFlags	db	0	;bottom 4 for directions
APos		dw	0
PAPos		dw	0


Colors		dw	0, 4000h, 2000h, 1000h, 6000h, 5000h, 3000h, '$'

MoveUpTime	dw	4
TimerTick	dw	0

Gameboard	db	0h, 1h		;40 x 16
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 0h
		db	1h, 0h
		db	0h, 1h
		times	20 db 1h
		db	1h, 0h



KeyboardV	resd 	1	;holds address of orig keyboardISR
TimerV		resd 	1	;holds address of orig timerISR

;====== SECTION 6: Program initialization =================================

..start:
        mov     ax, cs                  ; Initialize Default Segment register
        mov     ds, ax  
        mov     ax, stkseg              ; Initialize Stack Segment register
        mov     ss, ax
        mov     sp, stacktop            ; Initialize Stack Pointer register

;====== SECTION 7: Main procedure =========================================

MAIN:
        mov     ax, 3
        int     10h         
    
	call	InstallKeyboard
	call	InstallTimer
	

	call DrawGameboard
	

	call DrawPalette
	call DrawPaletteArrow
	


	call	DrawArrow
.gameloop
	test byte [GameFlags], 01h
	jnz	.gamedone

	mov	ax, [MoveUpTime]
	mov	bx, [TimerTick]
	cmp	ax, bx
	jle	.TimerMove
	jmp	.CheckPlayerMove
.TimerMove
	add	word [MoveUpTime], 4
	or	byte [GameFlags], 00000100b

.CheckPlayerMove
	mov     ax, 2
	call	Delay
	call	MoveArrow
	call 	ChangeColor
	call	CheckShot
	call	PercolateUp
	call	DrawGameboard
	jmp .gameloop
	
.gamedone
	call	RemoveTimer
	call	RemoveKeyboard

        mov     ax, 3		; setting the video mode here is a cheap and easy
	int	10h		; way to clear the screen - it does it for you

	call	mp3xit

;====== SECTION 8: Your subroutines =======================================

;--------------------------------------------------------------
;--          Replace library calls with your code!           --
;--          [Save all reg values that you modify]           --
;--          Do not forget to add function headers           --
;--------------------------------------------------------------



;--------------------------------------------------------------
;--                     DrawArrow                      --
;--------------------------------------------------------------

DrawArrow
	call libDrawArrow
	ret
	
;--------------------------------------------------------------
;--                     DrawPaletteArrow                      --
;--------------------------------------------------------------
DrawPaletteArrow
	call libDrawPaletteArrow
	ret

;--------------------------------------------------------------
;--                     DrawPalette                      --
;--------------------------------------------------------------
DrawPalette 
	call libDrawPalette
	ret


;--------------------------------------------------------------
;--                     DrawGameboard                      --
;--------------------------------------------------------------
DrawGameboard
	call libDrawGameboard
	ret
 
;--------------------------------------------------------------
;--                     PercolateUp			--
;--------------------------------------------------------------
PercolateUp
	call libPercolateUp
	ret


;--------------------------------------------------------------
;--                     CheckShot		--
;--------------------------------------------------------------
CheckShot
	call libCheckShot
	ret


;--------------------------------------------------------------
;--                    ChangeColor 
;--------------------------------------------------------------
ChangeColor
	call libChangeColor
	ret

;--------------------------------------------------------------
;--                     MoveArrow                      --
;--------------------------------------------------------------
MoveArrow
	;call libMoveArrow
	ret
	
;Inputs  Ax = #ticks to delay for
;--------------------------------------------------------------
;--                     Delay                         --
;--------------------------------------------------------------
Delay
	call libDelay
	ret	
        
;--------------------------------------------------------------
;--                     InstallTimer                   --
;--------------------------------------------------------------
InstallTimer
	call libInstallTimer
        ret

;--------------------------------------------------------------
;--                     RemoveTimer                    --
;--------------------------------------------------------------

RemoveTimer
	call libRemoveTimer
	ret

;--------------------------------------------------------------
;--                     TimerISR                      --
;--------------------------------------------------------------
TimerISR
	;call libTimerISR
	;ret
	jmp libTimerISR
	
;--------------------------------------------------------------
;--                     InstallKeyboard                --
;--------------------------------------------------------------
InstallKeyboard
	call libInstallKeyboard
        ret

;--------------------------------------------------------------
;--                     RemoveKeyboard                 --
;--------------------------------------------------------------
RemoveKeyboard
	call libRemoveKeyboard
	ret


;--------------------------------------------------------------
;--                     KeyboardISR                    --
;--------------------------------------------------------------
KeyboardISR
;	call libKeyboardISR
	;ret
	jmp libKeyboardISR






