; MP3 - Pong 291
; Your Name
; Date
;
; Ryan Chmiel, Summer 2004
; Author: Ryan Chmiel
; University of Illinois, Urbana-Champaign
; Dept. of Electrical and Computer Engineering
;
; Version 1.0

	BITS	16

;====== SECTION 1: Define constants =======================================

	CR		EQU	13
	LF		EQU	10

        ESC		EQU     01
	UPARROW		EQU	72
	DOWNARROW	EQU	80

	NUMBALLS	EQU	5
	PADDLELENGTH	EQU	6

	BALL		EQU	0F07h
	BORDER		EQU	7F20h
	PADDLE		EQU	79DBh

	Ball.X		EQU	0
	Ball.Y		EQU	1
	Ball.Flags	EQU	2
	Ball_size	EQU	3

; the above four constants should have been declared by the STRUC
; below, but the program crashes when it's used... perhaps because
; it's a 16-bit program and not a 32-bit program?

; Ball.X     - X coordinate of ball
; Ball.Y     - Y coordinate of ball
; Ball.Flags - Ball flags
;	       Bit 0 - Set if the ball is visible
;	       Bit 1 - X direction of ball: 0 = left, 1 = right
;	       Bit 2 - Y direction of ball: 0 = up, 1 = down
%if 0
STRUC Ball
.X	resb	1
.Y	resb	1
.Flags	resb	1
ENDSTRUC
%endif

;====== SECTION 2: Declare external routines ==============================

EXTERN dspmsg, mp3xit

GLOBAL MP3Main, CheckGameEnd, CheckCollision, MoveBalls, MovePlayer, MoveComputer, Random
GLOBAL DrawBackground, DrawPaddles, DrawBalls, DrawStats, RefreshScreen
GLOBAL InstallKeyboard, RemoveKeyboard, KeyboardISR
GLOBAL InstallTimer, RemoveTimer, TimerISR

GLOBAL oldKeyboardV, oldTimerV, MoveBallTime, MovePaddleTime, RandomSeed
GLOBAL CoordTable, XOffsetTable, YOffsetTable, DiagOffsetTable, Balls
GLOBAL PlayerPaddle, ComputerPaddle, MPFlags, PlayerScore, ComputerScore
GLOBAL ScreenBuffer, Background, Binascbuffer
GLOBAL TimerTicks, NumSeconds

EXTERN libMP3Main, libMoveBalls, libMovePlayer, libMoveComputer
EXTERN libDrawBackground, libDrawPaddles, libDrawBalls, libDrawStats, libRefreshScreen
EXTERN libInstallKeyboard, libRemoveKeyboard, libKeyboardISR
EXTERN libInstallTimer, libRemoveTimer, libTimerISR

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
MoveBallTime	db	0	        ; Keep track of when players can move
MovePaddleTime	db	0		; Keep track of when balls can move
TimerTicks	db	0		; Keep track of timer ticks during program execution
NumSeconds	dw	0		; Keep track of number of seconds program has run
RandomSeed	dw	0		; Seed for random number generator

CoordTable	db	-1, 1			; Used to update ball X and Y coords: 0 = left/up, 1 = right/down
XOffsetTable	dw	-2, 2			; Used in checking horiz collisions: 0 = left, 1 = right
YOffsetTable	dw	-160, 160		; Used in checking vert collisions: 0 = up, 1 = down
DiagOffsetTable	dw	-162, -158, 158, 162	; Used in checking diagonal collisions:
						; 0 = up-left, 1 = up-right, 2 = down-left, 3 = down-right

Balls		times NUMBALLS*Ball_size db 0	; Ball structure

PlayerPaddle	db	9		; Top row location of player's paddle
ComputerPaddle	db	9		; Top row location of computer's paddle
PlayerScore	db	0		; Player's score
ComputerScore	db	0		; Computer's score
MPFlags		db	0		; MP flags variable
					; Bit 0 - Move direction flag: 0 = up, 1 = down
					; Bit 1 - When set, player wants to move paddle
					; Bit 2 - When set, player wants to quit the program

Binascbuffer	times 7 db 0
ScreenBuffer	times 80*25 dw 0
Background	times 27 dw BORDER
		db	'M', 79h, 'P', 79h, '3', 79h, ' ', 79h, 'S', 79h, 'U', 79h, 'M', 79h, 'M', 79h, 'E', 79h, 'R', 79h
		db	' ', 79h, '2', 79h, '0', 79h, '0', 79h, '4', 79h, ' ', 79h, '-', 79h, ' ', 79h, 'P', 79h, 'O', 79h
		db	'N', 79h, 'G', 79h, ' ', 79h, '2', 79h, '9', 79h, '1', 79h
		times 27 dw BORDER
		times 80*23 dw 0
		db	' ', 79h, 'P', 79h, 'L', 79h, 'A', 79h, 'Y', 79h, 'E', 79h, 'R', 79h, ':', 79h
		times 27 dw BORDER
		db	'T', 79h, 'I', 79h, 'M', 79h, 'E', 79h, ':', 79h, ' ', 79h
		times 27 dw BORDER
		db	'C', 79h, 'O', 79h, 'M', 79h, 'P', 79h, 'U', 79h, 'T', 79h, 'E', 79h, 'R', 79h, ':', 79h
		times  3 dw BORDER


PlayerWinMsg	db	'You win!',CR,LF,'$'
ComputerWinMsg	db	'Computer wins!',CR,LF,'$'
TieMsg		db	'Tie game!',CR,LF,'$'

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

	mov	ah, 02h		; Move cursor to row 25, col 0 (hide it)
	mov	dx, 1A00h
	int	10h

	mov	ah, 2Ch		; Seed random number generator based on system time
	int	21h
	xor	dh, dh
	mov	[RandomSeed], dx

	mov	bx, Balls
	mov	cx, NUMBALLS

.BallLoop			; Initialize the ball structure
	push	cx
	mov	cx, 22
	call	Random
	add	ax, 2
	mov	[bx+Ball.Y], al
	mov	cx, 50
	call	Random
	add	ax, 15
	mov	[bx+Ball.X], al
	mov	cx, 8
	call	Random
	or	al, 01h
	mov	[bx+Ball.Flags], al
	add	bx, Ball_size
	pop	cx
	loop	.BallLoop

	call	MP3Main

        mov     ax, 3		; Reset and clear the video screen
        int     10h

	mov	al, [PlayerScore]
	cmp	al, [ComputerScore]
	jg	.PlayerWin
	jl	.ComputerWin
	mov	dx, TieMsg
	jmp	.PrintWinMsg

.PlayerWin
	mov	dx, PlayerWinMsg
	jmp	.PrintWinMsg

.ComputerWin
	mov	dx, ComputerWinMsg

.PrintWinMsg
	call	dspmsg
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
;--                       MoveBalls()                        --
;--------------------------------------------------------------
MoveBalls
	call	libMoveBalls
	ret

;--------------------------------------------------------------
;--                       MovePlayer()                       --
;--------------------------------------------------------------
MovePlayer
	call	libMovePlayer
	ret

;--------------------------------------------------------------
;--                     MoveComputer()                       --
;--------------------------------------------------------------
MoveComputer
	call	libMoveComputer
	ret

;--------------------------------------------------------------
;--                     DrawBackground()                     --
;--------------------------------------------------------------
DrawBackground
	call	libDrawBackground
	ret

;--------------------------------------------------------------
;--                      DrawPaddles()                       --
;--------------------------------------------------------------
DrawPaddles
	call	libDrawPaddles
	ret

;--------------------------------------------------------------
;--                       DrawBalls()                        --
;--------------------------------------------------------------
DrawBalls
	call	libDrawBalls
	ret

;--------------------------------------------------------------
;--                       DrawStats()                        --
;--------------------------------------------------------------
DrawStats
	call	libDrawStats
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
	jmp	libKeyboardISR

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
	jmp	libTimerISR


;--------------------------------------------------------------
;--         Given code that you will need for the MP         --
;--------------------------------------------------------------


;--------------------------------------------------------------
;--                         Random()                         --
;--------------------------------------------------------------
Random
	push	bx
	push	dx

	; initializations
	mov	ax, word [RandomSeed]
	mov	bx, 16807

	; X(k+1) = [a * X(k) + c] % m
	; X(0) = ?, a = 16807, m = 32767, c = 15031
	mul	bx
	add	ax, 15031   
	adc	dx, 0
	mov	bx, 7fffh
	div	bx
	mov	ax, dx
	mov	word [RandomSeed], dx

	; put the random number within the given range 
	xor	dx, dx
	div	cx
	mov	ax, dx

	pop	dx
	pop	bx
	ret

;--------------------------------------------------------------
;--                     CheckGameEnd()                       --
;--------------------------------------------------------------
CheckGameEnd
	push	bx
	push	cx
	
	xor	al, al

	test	byte [MPFlags], 04h
	jnz	.EndGame

	mov	bx, Balls
	mov	cx, NUMBALLS

.BallLoop
	test	byte [bx+Ball.Flags], 01h
	jnz	.Done
	add	bx, Ball_size
	loop	.BallLoop

.EndGame
	mov	al, 1

.Done
	pop	cx
	pop	bx
	ret

;--------------------------------------------------------------
;--                    CheckCollision()                      --
;--------------------------------------------------------------
CheckCollision
	push	bx
	push	cx
	push	dx
	push	si
	push	di

	; calculate offset of ball in game board
	mov	al, [bx+Ball.Y]
	mov	ah, 80
	mul	ah
	movzx	dx, byte [bx+Ball.X]
	add	ax, dx
	shl	ax, 1
	mov	si, ax
	mov	dx, si

	; set return value to zero, change it if we find a collision
	xor	al, al

	; check collisions with game board
	mov	di, [bx+Ball.Flags]
	and	di, 0006h
	add	si, [DiagOffsetTable+di]
	cmp	word [ScreenBuffer+si], 0
	je	.Done

.CheckVerticalCollision
	mov	di, [bx+Ball.Flags]
	and	di, 0004h
	shr	di, 1
	mov	si, dx
	add	si, [YOffsetTable+di]
	cmp	word [ScreenBuffer+si], 0
	je	.CheckHorizCollision
	xor	byte [bx+Ball.Flags], 04h
	mov	al, 1

.CheckHorizCollision
	mov	di, [bx+Ball.Flags]
	and	di, 0002h
	mov	si, dx
	add	si, [XOffsetTable+di]
	cmp	word [ScreenBuffer+si], 0
	je	.CheckDiagonalCollision
	xor	byte [bx+Ball.Flags], 02h
	mov	al, 1
	jmp	.Done

.CheckDiagonalCollision
	test	al, al
	jnz	.Done
	xor	byte [bx+Ball.Flags], 06h
	mov	al, 1

.Done
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	ret
