; MP3 - Your Name - Today's Date
;
; Simple snake game
; Written by Nicholas Chen
; Forward all questions to webboard
;
; This mp has the following objectives:
; 1) Understand how queues and similar data structures are done in assembly
; 2) Understand how to load/ unload interrupts and service them
; 3) Understand how to load write directly to video memory
; 4) Expose the capabilities of various int routines
; 5) Expose the capabilities of string instructions

	BITS	16

;====== SECTION 1: Define constants =======================================

	CR        EQU  0Dh
	LF        EQU  0Ah
	ESC       EQU  1Bh
	BS        EQU  08h	

	; remember that these are not ASCII representations
	; they are the keyboard scancodes
	; this key is to exit the game at any time
	ESCKEY		EQU	01
	; this key tells the program that you are done designing
	; the gameboard and want to [S]tart
	SPACEKEY	EQU	57
	; these are the direction keys to control the snake
	UPARROWKEY	EQU	72
	DOWNARROWKEY	EQU	80
	LEFTARROWKEY	EQU	75
	RIGHTARROWKEY	EQU	77

	; these define the dimensions of the maze
	; we are dealing in text mode so our max. dimesions
	; will be 80 x 25. we leave the last row to display 
	; status message
	NUMROWS		EQU	24
	NUMCOLS		EQU	80

	; these are the colors we will be using to define the 
	; borders, snake and apple
	; they have been conveniently converted to be a block
	; with the appropriate color so just put them into video 
	; memory
	EMPTYCOLOR	EQU     0000h	
	SNAKECOLOR	EQU	6000h
	APPLECOLOR	EQU	0C000h
	BRICKCOLOR	EQU	1000h	
	BORDERCOLOR	EQU	7000h

	; these are the representations in the gameboard
	EMPTY		EQU	0
	SNAKE		EQU	1
	APPLE		EQU	2
	BRICK		EQU	3
	BORDER		EQU	4			

	; maximum length of the snake
	; this is bounded by the size of the segment too	
	SNAKESIZE	EQU	50

	; the locations of the interrupt vectors in the table
	KEYBOARDINT	EQU	9
	TIMERINT	EQU	1Ch

	; this section is specific for the queue
	; these are the !!offsets!! to be used in accessing the queue
	; so [bx+QBEG] gets us to the beginning of the queue,
	; [bx+QDATA] gets us to the data of the queue, etc
	QBEG		EQU	0	; beginning offset of queue area
	QCAP		EQU     2	; capacity of the queue
	QFRONT		EQU	4	; index of front item
	QREAR		EQU	6	; index of rear item
	QCOUNT		EQU	8	; how many items in the queue
	QDATA		EQU	10	; word to input or output

	SPEED		EQU	5	; how fast to move

;====== SECTION 2: Declare external procedures ============================


EXTERN  kbdine, dspout, dspmsg, dosxit, binasc

GLOBAL	MAIN, mainSnakeLoop, installMouse, mouseCallback, removeMouse
GLOBAL	drawScreen, fillBorders, Rand

EXTERN	mp3xit, libinstallKeyboard1, libinstallKeyboard2, libinstallTimer
EXTERN	libremoveKeyboard, libremoveTimer, libkeyboardISR1, libkeyboardISR2
EXTERN	libtimerISR, libdelay, libupdateBoard, libgenerateApple, libenqueue
EXTERN	libdequeue, libpeek, libcheckMovement, libdrawSnake, libshowStatus
EXTERN	libdisplayGameOver, libinitGame, libinstallMouse, libmouseCallback
EXTERN	libremoveMouse

GLOBAL	installKeyboard1, installKeyboard2, installTimer, removeMouse
GLOBAL	removeKeyboard, removeTimer, keyboardISR1, keyboardISR2
GLOBAL	timerISR, delay, updateBoard, generateApple, enqueue
GLOBAL	dequeue, peek, checkMovement, drawSnake, showStatus
GLOBAL	displayGameOver, initGame, installMouse, mouseCallback

GLOBAL	_oldKeyboardV, _oldTimerV, _timerTicks, _currentBoard, _colorTable
GLOBAL	_mouseX, _mouseY, _newSnakeHead, _mpStatus, _rNum, _hitSpaceMsg
GLOBAL	_scoreMsg, _scoreBuffer, _gameOverMsg, _snakeQList, _snakeBeg
GLOBAL	_snakeCap, _snakeFront, _snakeRear, _snakeCount, _snakeData
GLOBAL	_snakeArea, _score


;====== SECTION 3: Define stack segment ===================================

SEGMENT stkseg STACK        ; *** STACK SEGMENT ***
        resb	64*16
stacktop:
	resb	0

;====== SECTION 4: Define code segment ====================================

SEGMENT code                            ; *** CODE SEGMENT ***

;====== SECTION 5: Declare variables for main procedure ===================

; placeholders of old interrupt handlers
_oldKeyboardV	dd	0
_oldTimerV	dd	0

_timerTicks	db	0	; used to keep track of each timer tick

; this is the simplified version of the gameboard
; 0 represents empty
; 1 represents snake
; 2 represents apple
; 3 represents brick
; 4 represents the border
_currentBoard	times	NUMCOLS*NUMROWS	db 0
_colorTable	dw      EMPTYCOLOR, SNAKECOLOR, APPLECOLOR, BRICKCOLOR, BORDERCOLOR	

; current mouse positions
_mouseX	dw	0
_mouseY	dw	0

; next position to move the snake head
_newSnakeHead	dw	0

; use a "bit vector" to encode information about the game status
; bit 7 - most significant bit
; bit 7 & bit 6: 00 => moving right
;		 01 => moving up
;		 10 => moving left
;		 11 => moving down
; bit 5 : gameover? 1=>yes, 0=>no
; bit 4 : eaten apple? 1=>yes, 0=>no
; bit 3 : left mouse button down? 1=>yes, 0=>no
; bit 2	: add new snake segment? 1=>yes, 0=>no
; bit 0 : has the user completed drawing? 1=>yes, 0=>no
_mpStatus	db	0

; this is used to generate the random number
_rNum	dw	1

; different messages to be displayed
_hitSpaceMsg	db 'Hit space when ready','$'
_scoreMsg	db 'Current score for the game: ','$'
_scoreBuffer	resb	7
_gameOverMsg	db 'GAME  OVER','$'

; this is the real queue
_snakeQList	RESB	0	; parameter list for snake queue
_snakeBeg	DW	_snakeArea
_snakeCap	DW	SNAKESIZE*2
_snakeFront	DW	0
_snakeRear	DW	-2
_snakeCount	DW	0	; nothing in snake yet
_snakeData	RESW	1
_snakeArea	RESW	SNAKESIZE

_score	dw	0

_topLeft	dw	1600+60

; Declare additional variables here

;====== SECTION 6: Program initialization =================================

..start:
        mov     ax, cs                  ; Initialize Default Segment register
        mov     ds, ax  
        mov     ax, stkseg              ; Initialize Stack Segment register
        mov     ss, ax
        mov     sp, stacktop            ; Initialize Stack Pointer register

;====== SECTION 7: Main procedure =========================================

;==========================================================================
; This is the main program that just sets up text mode
; It is also responsible for handling the mouse interrupts
; This is where you design the gameboard and save the output
; to a file conveniently called gameboard. After this the mouse should
; be ignored
;==========================================================================
MAIN:
        mov     ax, 3		; Set up and clear the video screen
        int     10h		

	mov	ah, 02h		; move cursor to row 25, col 0 (hide it)
	mov	dx, 1900h
	int	10h
	
	; get new random seed from time
	mov	ah, 2ch
	int 	21h
	mov	[_rNum],dx
	
	; install the interrupts
	call 	installKeyboard1
	call 	installMouse
	call    fillBorders

	; display some instructions
	; moves the cursor to the right position
	mov	ah, 02h
	mov 	bh, 0
	mov	dh, 24
	mov	dl, 0
	int 	10h
	mov	dx, _hitSpaceMsg
	call 	dspmsg
	
	; move the cursor out of the position
	mov	ah, 02h
	mov	bh, 0
	mov	dh, NUMROWS+2
	mov	dl, 0
	int 	10h

.userDrawingBoard
	; this is the only place where you should call drawScreen
	; everywhere else you need to update the video memory
	; it is more efficient to do it locally to the affected area only
	call 	drawScreen
	test 	byte[_mpStatus], 00001000b	; was there a mouse event?
	jz	.noMouseEvent
	call 	updateBoard
	and	byte[_mpStatus], 11110111b	; reset mouse event loop
.noMouseEvent
	test	byte[_mpStatus], 00000001b 
	jz	.userDrawingBoard	
	
	call 	removeMouse
	call 	removeKeyboard

       	call	mainSnakeLoop

	
        mov     ax, 3		; Reset and clear the video screen
        int     10h	 

.FinalExit:
        call    mp3xit                  ; Exit to DOS

;==========================================================================
; This controls the main game
;==========================================================================
; This is in-charge of generating the snake, apple, etc.
mainSnakeLoop:
	pusha
	call 	installKeyboard2
	call 	installTimer
	
	call 	initGame	
.mainLoop		
	call	checkMovement
	test	byte[_mpStatus], 00100000b ; knock a border?
	jnz	.gameOver
	call  	drawSnake
	test	byte[_mpStatus], 00010000b ; eaten an apple?
	jz	.noNewApple
	call 	generateApple
.noNewApple
	call    showStatus
	call	delay
	test	byte[_mpStatus], 00100000b
	jz	.mainLoop

.gameOver
	call 	removeTimer
	call 	removeKeyboard
	call	displayGameOver
	call 	kbdine
	popa
	ret

;==========================================================================
; This draws the gameboard onto the video memory
; It just maps everything accordingly
;==========================================================================
; Should not call this unless you want to do a hard reset of the entire
; game screen. It should suffice to clear the snake and the apple individually
; from video memory
drawScreen:
	pusha

	; es:di to be the [d]estination (explicit)
	mov	ax, 0B800h
	mov 	es, ax
	mov     di, 0
	
	mov	si, 0
	.drawGameBoard
		mov     bx, si
		mov     bl, byte[_currentBoard+bx]
		shl     bx, 1
		mov     bh, 0
		mov	bx, [_colorTable + bx]
		mov	[es:di], bx
		add  	di, 2	; words in video memory
		inc     si	
	cmp     si, NUMCOLS*NUMROWS
	jl 	.drawGameBoard	
	
	popa
	ret

;==========================================================================
; This fills the borders of the game board
;==========================================================================
; Use string instructions
; Border is defined to be 4 as stated in the variables section
fillBorders:
	pusha
	
	; set up the CLD bit so that the string instuction
	; auto-increments the current position
	; sets di to point to the [d]estination	
	cld
	mov 	ax, cs
	mov	es, ax
	mov     di, _currentBoard

	; this is not supposed to change throughout this subroutine	
	mov	al, BORDER


	; top row
	mov	cx, NUMCOLS
	rep     stosb
	
	; middle rows
	; not using string instructions here
	; value of di has been set to the corect
	; position by the string instructions
	mov	cx, NUMROWS-2
	.beginDrawingBorders
		; draw far left
		mov	byte[di], BORDER
		; draw far right
		add     di, NUMCOLS-1
		mov     byte[di], BORDER
		; prepare for next iteration
		inc 	di 	
	loop .beginDrawingBorders	
	; bottom row
	mov     cx, NUMCOLS
	rep	stosb
	
	popa
	ret

;==========================================================================
; This generates the random number for the location of the apple
;==========================================================================
; Code taken from Prof. Loui's Rand Subroutine Fall 2004
; input: cx -- range of random number
; output: ax -- random number in range 0..(cx)-1

C2053	dw	2053
C13849	dw	13849
C216M1	dw	0FFFFh
RandOut	resw	1	
Rand:
	pusha
	mov	ax, [_rNum]
	mul 	word[C2053]
	add 	ax, [C13849]
	adc	dx, 0	; propagate carry to dx
	div	word[C216M1]
	mov	[_rNum], dx
	mov	ax, dx
	mov	dx, 0
	div	cx
	mov	[RandOut], dx
	popa
	mov	ax, [RandOut]
	ret

;Your code starts here.

installKeyboard1:
	call	libinstallKeyboard1
	ret

keyboardISR1:
	jmp	libkeyboardISR1
	
removeKeyboard:
	call	libremoveKeyboard
	ret

installMouse:
	call	libinstallMouse
	ret

mouseCallback:
	jmp	libmouseCallback

removeMouse:
	call	libremoveMouse
	ret

installKeyboard2:
	call	libinstallKeyboard2
	ret

keyboardISR2:
	jmp	libkeyboardISR2

installTimer:
	call	libinstallTimer
	ret
	
timerISR:
	jmp	libtimerISR

delay:
	call	libdelay
	ret

removeTimer:
	call	libremoveTimer
	ret

updateBoard:
	call	libupdateBoard
	ret

generateApple:
	call	libgenerateApple
	ret

enqueue:
	call	libenqueue
	ret

dequeue:
	call	libdequeue
	ret

peek:
	call	libpeek
	ret

checkMovement:	
	call	libcheckMovement
	ret

drawSnake:	
	call	libdrawSnake
	ret

showStatus:
	call	libshowStatus
	ret

displayGameOver:
	call	libdisplayGameOver
	ret

initGame:
	call	libinitGame
	ret