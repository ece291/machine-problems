; MP3 - Nybbles
;
; Your Name
; Today's Date
;
; Dimitrios Nikolopoulos, Spring 2002
; Author: Justin Quek, Michael Urman
; University of Illinois, Urbana-Champaign
; Dept. of Electrical and Computer Engineering
;
; Version 1.0

	BITS	16

;====== SECTION 1: Define constants =======================================

; Everything below here *should* be changable
; Colors
	DEF_COLOR	EQU	007h	; Default color, DON'T CHANGE THIS!
	PLR_COLOR	EQU	090h	; Player's color
	OPP_COLOR	EQU	0A0h	; Opponent's color
	WORMCOLOR	EQU	020h	; Worm body 'color'

; Gameplay variables
	SEGSIZE		EQU	4
	SEGMENTS	EQU	10
	MAXLENGTH	EQU	SEGMENTS*SEGSIZE
	DELAYTICKS	EQU	4

; Movement Keys
	UPARROW		EQU	72
	DOWNARROW	EQU	80
	LEFTARROW	EQU	75
	RIGHTARROW	EQU	77
; Don't change anything past here

; Border characters
	ULCORNER	EQU	0C9h
	URCORNER	EQU	0BBh
	LLCORNER	EQU	0C8h
	LRCORNER	EQU	0BCh
	HORIZBAR	EQU	0CDh
	VERT_BAR	EQU	0BAh

; Directions
	MOVE_UP		EQU	00000001b
	MOVE_DOWN	EQU	00000010b
	MOVE_LEFT	EQU	00000100b
	MOVE_RIGHT	EQU	00001000b
	MOVE_FWD	EQU	00010000b

; Constants
	ESCKEY		EQU	1
        CR      	EQU     0Dh
        LF      	EQU     0Ah

;====== SECTION 2: Declare external procedures ============================

; Declare external library routines
EXTERN	kbdin, dspmsg, dspout

; Declare external libmp3 routines
EXTERN libMP3Main, libMoveWorm, libRedrawWorm
EXTERN libAddHeadSeg, libDelTailSeg, libGetWormHead
EXTERN libHandleCollisions, libCreateNumber, libAIWorm
EXTERN libKeyboardISR, libTimerISR, libInstallInt, libRemoveInt
EXTERN mp3xit

; Declare global routines and variables for libmp3
	; routines
GLOBAL rand, MP3Main, MoveWorm, RedrawWorm
GLOBAL AddHeadSeg, DelTailSeg, GetWormHead
GLOBAL HandleCollisions, CreateNumber, AIWorm
GLOBAL KeyboardISR, TimerISR, InstallInt, RemoveInt
	; variables
GLOBAL KbdV, TimerV
GLOBAL Map, PlrWorm, OppWorm
GLOBAL level, counter, quit, update, winlose, numloc

; These variables make the changable EQUs above visible to libmp3
EXTERN lib_def_color, lib_plr_color, lib_opp_color, lib_wormcolor
EXTERN lib_segsize, lib_segments, lib_maxlength, lib_delayticks
EXTERN lib_uparrow, lib_downarrow, lib_leftarrow, lib_rightarrow
EXTERN lib_worm_body, lib_worm_head, lib_worm_tail, lib_worm_size
EXTERN lib_worm_grow, lib_worm_move, lib_worm_color

; Worm structure
STRUC Worm
.body	resw	MAXLENGTH
.head	resw	1
.tail	resw	1
.size	resw	1
.grow	resw	1
.move	resw	1
.color	resw	1
ENDSTRUC

;====== SECTION 3: Define stack segment ===================================

SEGMENT stkseg STACK                    ; *** STACK SEGMENT ***
        resb      64*8
stacktop:
        resb      0                     ; work around NASM bug

;====== SECTION 4: Define code segment ====================================

SEGMENT code                            ; *** CODE SEGMENT ***

;====== SECTION 5: Declare variables for main procedure ===================
KbdV	resd 1				; stores old keyboard vector
TimerV	resd 1				; stores old timer vector

; collision map
Map	resw 80*50

; player worm data
PlrWorm resw MAXLENGTH			; segment coordinates
	dw PlrWorm+2			; head pointer
	dw PlrWorm			; tail pointer
	dw 2				; current size
	dw SEGSIZE-2			; needed worm growth
	dw 0				; movement direction
	db WORMCOLOR, PLR_COLOR		; player's worm color

; opponent worm data
OppWorm	resw MAXLENGTH			; segment coordinates
	dw OppWorm+2			; head pointer
	dw OppWorm			; tail pointer
	dw 2				; current size
	dw SEGSIZE-2			; needed worm growth
	dw 0				; movement direction
	db WORMCOLOR, OPP_COLOR		; opponent's worm color

; flags, counters, etc
level	db 0				; current level (1-9)
counter	db 0				; timer counter
quit	db 0				; quit 'flag'
update	db 0				; redraw 'flag'
winlose	db 0				; win 'flag'; win = 2, lose = 1
numloc	dw 0				; x,y (within map) of current number

seed	dw 27				; random number seed

WinMsg	db "You WIN!", CR, LF, '$'
LoseMsg	db "You LOSE!", CR, LF, '$'
TieMsg	db "It's a TIE!", CR, LF, '$'
MsgTab	dw LoseMsg, LoseMsg, WinMsg, TieMsg

Return	db CR, LF, '$'
	
;====== SECTION 6: Program initialization =================================

..start:
        mov     ax, cs                  ; Initialize Default Segment register
        mov     ds, ax  
        mov     ax, stkseg              ; Initialize Stack Segment register
        mov     ss, ax
        mov     sp, stacktop            ; Initialize Stack Pointer register

;====== SECTION 7: Main procedure =========================================

MAIN:
; setup library variables
	call	libInit

; install timer isr
	mov	al, 8
	mov	dx, TimerISR
	mov	si, TimerV
	call	InstallInt

; install keyboard isr
	mov	al, 9
	mov	dx, KeyboardISR
	mov	si, KbdV
	call	InstallInt

; randomize seed
	mov	ah, 2ch
	int	21h
	mov	ah, cl
	mov	al, dh
	xor	dx, dx
	mov	bx, 50
	div	bx
	mov	word [seed], dx

; change video mode
	; set to 400 line scan mode
	mov	ax, 1202h
	mov	bl, 30h
	int	10h

	; set to 8x8 font
	mov	ax, 3
	int	10h

	; enter text mode
	mov	ax, 1112h
	xor	bx, bx
	int	10h

	; hide cursor
	mov	ah, 1
	mov	cx, 2000h
	int	10h

	; the text-mode segment address
	mov	ax, 0B800h
	mov	es, ax

	call	DrawBorder

; initialize worm starting locations
	; player
	mov	word [PlrWorm+0], 2802h
	mov	word [PlrWorm+2], 2803h
	; opponent
	mov	word [OppWorm+0], 292Fh
	mov	word [OppWorm+2], 292Eh

; spawn the first number
	call	CreateNumber

; main loop
	mov	byte [update], 0
	call	MP3Main

; return to 80x25 text mode
	mov	ax, 2
	int	10h

; figure out if we won and display the appropriate message
	cmp	byte [winlose], 0
	jne	.whowon

	mov	ax, word [PlrWorm+Worm.size]
	cmp	ax, word [OppWorm+Worm.size]
	je	.tie
	jge	.wewon

.welost
	mov	byte [winlose], 1
	jmp	.whowon

.wewon
	mov	byte [winlose], 2
	jmp	.whowon

.tie
	mov	byte [winlose], 3

.whowon
	movzx	si, byte [winlose]
	shl	si, 1
	mov	dx, word [MsgTab+si]
	call	dspmsg

; remove timer isr
	mov	al, 8
	mov	si, TimerV
	call	RemoveInt

; remove keyboard isr
	mov	al, 9
	mov	si, KbdV
	call	RemoveInt

; quit
;	call	dosxit
	call	mp3xit


; ===============
; === MP3Main ===
; ===============
MP3Main:

	call	libMP3Main
	ret

; === MP3Main ===


; ================
; === MoveWorm ===
; ================
MoveWorm:

	call	libMoveWorm
	ret

; === MoveWorm ===


; ==================
; === RedrawWorm ===
; ==================
RedrawWorm:

	call	libRedrawWorm
	ret

; === RedrawWorm ===


; ==================
; === AddHeadSeg ===
; ==================
AddHeadSeg:

	call	libAddHeadSeg
	ret

; === AddHeadSeg ===


; ==================
; === DelTailSeg ===
; ==================
DelTailSeg:

	call	libDelTailSeg
	ret

; === DelTailSeg ===


; ===================
; === GetWormHead ===
; ===================
GetWormHead:

	call	libGetWormHead
	ret

; === GetWormHead ===


; ========================
; === HandleCollisions ===
; =========-==============
HandleCollisions:

	call	libHandleCollisions
	ret

; === HandleCollisions ===


; ====================
; === CreateNumber ===
; ====================
CreateNumber:

	call	libCreateNumber
	ret

; === CreateNumber ===


; ==============
; === AIWorm ===
; ==============
AIWorm:

	call	libAIWorm
	ret

; === AIWorm ===


; ===================
; === KeyboardISR ===
; ===================
KeyboardISR:

	jmp	libKeyboardISR

; === KeyboardISR ===


; ================
; === TimerISR ===
; ================
TimerISR:

	jmp	libTimerISR

; === TimerISR ===


; ==================
; === InstallInt ===
; ==================
InstallInt:

	call	libInstallInt
	ret

; === InstallInt ===


; =================
; === RemoveInt ===
; =================
RemoveInt:

	call	libRemoveInt
	ret

; === RemoveInt ===


;******************************************************************************


; ============
; === rand ===
; ============
; Inputs:
;  cx = upper bound on number
; Outputs:
;  ax = (pseudo-)random number between 0 and cx-1, inclusive
rand:

; save registers to stack
;	push	ax
	push	bx
	push	dx

; initializations
	mov	ax, word [seed]
	mov	bx, 16807

; X(k+1) = [a * X(k) + c] % m
;  X(0) = 9, a = 16807, m = 32767, c = 15031
	mul	bx
	add	ax, 15031
	adc	dx, 0
	mov	bx, 7fffh
	div	bx
	mov	ax, dx
	mov	word [seed], dx

; put the random number within the given range 
	xor	dx, dx
	div	cx
	mov	ax, dx

; restore registers from stack
	pop	dx
	pop	bx
;	pop	ax

	ret
; === rand ===


; ==================
; === DrawBorder ===
; ==================
DrawBorder:

; save registers to stack
	push	ax
	push	cx
	push	si
	push	di

; initializations
	mov	ah, DEF_COLOR

; draw the 4 corners
	mov	al, ULCORNER
	mov	word [es:0], ax
	mov	word [Map+0], -1
	mov	al, URCORNER
	mov	word [es:79*2], ax
	mov	word [Map+79*2], -1
	mov	al, LLCORNER
	mov	word [es:49*80*2], ax
	mov	word [Map+(49*80)*2], -1
	mov	al, LRCORNER
	mov	word [es:(49*80+79)*2], ax
	mov	word [Map+(49*80+79)*2], -1

; draw the top and bottom sides
	mov	al, HORIZBAR
	mov	si, 2
	mov	di, (49*80+1)*2
	mov	cx, 78
.horizLoop
	mov	word [es:si], ax
	mov	word [es:di], ax
	mov	word [Map+si], -1
	mov	word [Map+di], -1
	add	si, 2
	add	di, 2
	dec	cx
	jnz	.horizLoop

; draw the left and right sides
	mov	al, VERT_BAR
	mov	si, 80*2
	mov	di, (80+79)*2
	mov	cx, 48
.vertLoop
	mov	word [es:si], ax
	mov	word [es:di], ax
	mov	word [Map+si], -1
	mov	word [Map+di], -1
	add	si, 80*2
	add	di, 80*2
	dec	cx
	jnz	.vertLoop

; restore registers from stack
	pop	di
	pop	si
	pop	cx
	pop	ax

	ret
; === DrawBorder ===


; ===============
; === libInit ===
; ===============
libInit:

; Colors
	mov	word [lib_def_color], DEF_COLOR
	mov	word [lib_plr_color], PLR_COLOR
	mov	word [lib_opp_color], OPP_COLOR
	mov	word [lib_wormcolor], WORMCOLOR

; Gameplay variables
	mov	word [lib_segsize], SEGSIZE
	mov	word [lib_segments], SEGMENTS
	mov	word [lib_maxlength], MAXLENGTH
	mov	word [lib_delayticks], DELAYTICKS

; Movement Keys
	mov	word [lib_uparrow], UPARROW
	mov	word [lib_downarrow], DOWNARROW
	mov	word [lib_leftarrow], LEFTARROW
	mov	word [lib_rightarrow], RIGHTARROW

; Worm struct offsets
	mov	word [lib_worm_body], Worm.body
	mov	word [lib_worm_head], Worm.head
	mov	word [lib_worm_tail], Worm.tail
	mov	word [lib_worm_size], Worm.size
	mov	word [lib_worm_grow], Worm.grow
	mov	word [lib_worm_move], Worm.move
	mov	word [lib_worm_color], Worm.color

	ret
; === libInit ===
