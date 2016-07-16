; MP3 - Conway's Game of Life
; Your Name
; Date
;
; Zbigniew Kalbarczyk, Spring 2004
; Author: Ryan Chmiel
; University of Illinois, Urbana-Champaign
; Dept. of Electrical and Computer Engineering
;
; Version 1.0

	BITS	16

;====== SECTION 1: Define constants =======================================

        ESCKEY  	EQU     01
	SKEY		EQU	31
	NKEY		EQU	49
	BORDERCOLOR	EQU	4000h
	EMPTYCOLOR	EQU	7000h
	OCCUPIEDCOLOR	EQU	6000h
	NUMROWS		EQU	25
	NUMCOLS		EQU	40

;====== SECTION 2: Declare external routines ==============================

; Declare external library routines
EXTERN mp3xit
EXTERN libMP3Main, libUpdateBoard, libNextGeneration, libDrawScreen, libRefreshScreen
EXTERN libInstallKeyboard, libRemoveKeyboard, libKeyboardISR
EXTERN libInstallMouse, libRemoveMouse, libMouseCallback
EXTERN libInstallTimer, libRemoveTimer, libTimerISR

; GLOBAL program routines and variables
GLOBAL MP3Main, UpdateBoard, NextGeneration, DrawScreen, RefreshScreen
GLOBAL InstallKeyboard, RemoveKeyboard, KeyboardISR
GLOBAL InstallMouse, RemoveMouse, MouseCallback
GLOBAL InstallTimer, RemoveTimer, TimerISR

GLOBAL oldKeyboardV, oldTimerV, TimerTick
GLOBAL CurrentBoard, NewBoard, ScreenBuffer, ColorTable
GLOBAL MouseXPos, MouseYPos, MPFlags, Menu

;====== SECTION 3: Define stack segment ===================================

SEGMENT stkseg STACK                    ; *** STACK SEGMENT ***
        resb      64*16
stacktop:
        resb      0                     ; work around NASM bug

;====== SECTION 4: Define code segment ====================================

SEGMENT code                            ; *** CODE SEGMENT ***

;====== SECTION 5: Declare variables for main procedure ===================

oldKeyboardV    dd      0              	; Address of old keyboard handler
oldTimerV       dd      0              	; Address of old timer handler
TimerTick	db	0	        ; variable to keep track of each tick of the timer

CurrentBoard	times	NUMROWS*NUMCOLS db 0
NewBoard	times	NUMROWS*NUMCOLS db 0
ScreenBuffer 	times	80*50 dw 0

ColorTable	dw	EMPTYCOLOR, OCCUPIEDCOLOR, BORDERCOLOR

MouseXPos	dw	0
MouseYPos	dw	0
MPFlags		db	0		; Bit 0 - End Game Flag
					; Bit 1 - Calculate Next Generation
					; Bit 2 - Auto-Calculate Next Generation
					; Bit 3 - LMB Status (High if Held Down)

Menu		times	400	dw	0

		times	48	dw	0
		db	0E4h, 0Fh, 9Bh, 0Fh, 0E4h, 0Fh, ' ', 00h, '2', 0Fh, '9', 0Fh, '1', 0Fh, ' ', 00h
		db	'M', 0Fh, 'P', 0Fh, '3', 0Fh, ' ', 00h, 'S', 0Fh, 'P', 0Fh, 'R', 0Fh, 'I', 0Fh
		db	'N', 0Fh, 'G', 0Fh, ' ', 00h, '2', 0Fh, '0', 0Fh, '0', 0Fh, '4', 0Fh
		times	9	dw	0
	
		times	49	dw	0
		db	'C', 0Fh, 'O', 0Fh, 'N', 0Fh, 'W', 0Fh, 'A', 0Fh, 'Y', 0Fh, 27h, 0Fh, 'S', 0Fh
		db	' ', 00h, 'G', 0Fh, 'A', 0Fh, 'M', 0Fh, 'E', 0Fh, ' ', 00h, 'O', 0Fh, 'F', 0Fh
		db	' ', 00h, 'L', 0Fh, 'I', 0Fh, 'F', 0Fh, 'E', 0Fh
		times	10	dw	0

		times	240	dw	0

		times	48	dw	0
		db	'P', 0Fh, 'L', 0Fh, 'A', 0Fh, 'C', 0Fh, 'E', 0Fh, ' ', 0Fh, 'C', 0Fh, 'E', 0Fh
		db	'L', 0Fh, 'L', 0Fh, 'S', 0Fh, ' ', 0Fh, 'O', 0Fh, 'N', 0Fh, ' ', 0Fh, 'T', 0Fh
		db	'H', 0Fh, 'E', 0Fh, ' ', 0Fh, 'B', 0Fh, 'O', 0Fh, 'A', 0Fh, 'R', 0Fh, 'D', 0Fh
		times	8	dw	0

		times	47	dw	0
		db	'T', 0Fh, 'O', 0Fh, ' ', 0Fh, 'T', 0Fh, 'H', 0Fh, 'E', 0Fh, ' ', 0Fh, 'L', 0Fh
		db	'E', 0Fh, 'F', 0Fh, 'T', 0Fh, ' ', 0Fh, 'W', 0Fh, 'I', 0Fh, 'T', 0Fh, 'H', 0Fh
		db	' ', 0Fh, 'T', 0Fh, 'H', 0Fh, 'E', 0Fh, ' ', 0Fh, 'M', 0Fh, 'O', 0Fh, 'U', 0Fh
		db	'S', 0Fh, 'E', 0Fh
		times	7	dw	0

		times	240	dw	0

		times	47	dw	0
		db	'N', 0Fh, ' ', 0Fh, '-', 0Fh, ' ', 0Fh, 'C', 0Fh, 'R', 0Fh, 'E', 0Fh, 'A', 0Fh
		db	'T', 0Fh, 'E', 0Fh, ' ', 0Fh, 'N', 0Fh, 'E', 0Fh, 'X', 0Fh, 'T', 0Fh, ' ', 0Fh
		db	'G', 0Fh, 'E', 0Fh, 'N', 0Fh, 'E', 0Fh, 'R', 0Fh, 'A', 0Fh, 'T', 0Fh, 'I', 0Fh
		db	'O', 0Fh, 'N', 0Fh
		times	7	dw	0

		times	80	dw	0

		times	47	dw	0
		db	'S', 0Fh, ' ', 0Fh, '-', 0Fh, ' ', 0Fh, 'S', 0Fh, 'T', 0Fh, 'A', 0Fh, 'R', 0Fh
		db	'T', 0Fh, '/', 0Fh, 'S', 0Fh, 'T', 0Fh, 'O', 0Fh, 'P', 0Fh, ' ', 0Fh, 'A', 0Fh
		db	'U', 0Fh, 'T', 0Fh, 'O', 0Fh, '-', 0Fh, 'G', 0Fh, 'E', 0Fh, 'N', 0Fh, 'E', 0Fh
		db	'R', 0Fh, 'A', 0Fh, 'T', 0Fh, 'E', 0Fh
		times	5	dw	0

		times	80	dw	0

		times	47	dw	0
		db	'E', 0Fh, 'S', 0Fh, 'C', 0Fh, ' ', 0Fh, '-', 0Fh, ' ', 0Fh, 'E', 0Fh, 'X', 0Fh
		db	'I', 0Fh, 'T', 0Fh, ' ', 0Fh, 'T', 0Fh, 'H', 0Fh, 'E', 0Fh, ' ', 0Fh, 'P', 0Fh
		db	'R', 0Fh, 'O', 0Fh, 'G', 0Fh, 'R', 0Fh, 'A', 0Fh, 'M', 0Fh
		times	11	dw	0

		times	400	dw	0

;====== SECTION 6: Program initialization =================================

..start:
        mov     ax, cs                  ; Initialize Default Segment register
        mov     ds, ax  
        mov     ax, stkseg              ; Initialize Stack Segment register
        mov     ss, ax
        mov     sp, stacktop            ; Initialize Stack Pointer register

;====== SECTION 7: Main procedure =========================================

MAIN:      
        mov     ax, 3		; Set up and clear the video screen
        int     10h		

	mov	ah, 02h		; move cursor to row 25, col 0 (hide it)
	mov	dx, 1900h
	int	10h

       	call	MP3Main

        mov     ax, 3		; Reset and clear the video screen
        int     10h		
          
        call    mp3xit

;--------------------------------------------------------------
;--           Replace Library Calls with your Code!          --
;--           Save all reg values that you modify            -- 
;--           Don't forget to add Function Headers           --
;--------------------------------------------------------------

;--------------------------------------------------------------
;--                        MP3Main()                         --
;--------------------------------------------------------------
MP3Main
	call	libMP3Main
	ret

;--------------------------------------------------------------
;--                       UpdateBoard()                      --
;--------------------------------------------------------------
UpdateBoard
	call	libUpdateBoard
	ret

;--------------------------------------------------------------
;--                     NextGeneration()                     --
;--------------------------------------------------------------
NextGeneration
	call	libNextGeneration
	ret

;--------------------------------------------------------------
;--                      DrawScreen()                        --
;--------------------------------------------------------------
DrawScreen
	call	libDrawScreen
	ret

;--------------------------------------------------------------
;--                      RefreshScreen()                     --
;--------------------------------------------------------------
RefreshScreen
	call	libRefreshScreen
	ret

;--------------------------------------------------------------
;--                     InstallKeyboard()                    --
;--------------------------------------------------------------
InstallKeyboard
	call	libInstallKeyboard
        ret

;--------------------------------------------------------------
;--                      RemoveKeyboard()                    --
;--------------------------------------------------------------
RemoveKeyboard
	call	libRemoveKeyboard
        ret
        
;--------------------------------------------------------------
;--                      KeyboardISR()                       --
;--------------------------------------------------------------
KeyboardISR
	call	libKeyboardISR
	iret

;--------------------------------------------------------------
;--                     InstallMouse()                       --
;--------------------------------------------------------------
InstallMouse
	call	libInstallMouse
	ret

;--------------------------------------------------------------
;--                       RemoveMouse()                      --
;--------------------------------------------------------------
RemoveMouse
	call	libRemoveMouse
	ret

;--------------------------------------------------------------
;--                     MouseCallback()                      --
;--------------------------------------------------------------
MouseCallback
	call	libMouseCallback
        retf

;--------------------------------------------------------------
;--                       InstallTimer()                     --
;--------------------------------------------------------------
InstallTimer
	call	libInstallTimer
        ret

;--------------------------------------------------------------
;--                       RemoveTimer()                      --
;--------------------------------------------------------------
RemoveTimer
	call	libRemoveTimer
        ret
        
;--------------------------------------------------------------
;--                        TimerISR()                        --
;--------------------------------------------------------------
TimerISR
	call	libTimerISR
        jmp	far [oldTimerV]
