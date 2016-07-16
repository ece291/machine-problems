; MP3 - 291hack
;  Your Name
;  Today's Date
;
; Ryan Chmiel, Summer 2002
; Author: Peter Johnson, Michael Urman
; University of Illinois, Urbana-Champaign
; Dept. of Electrical and Computer Engineering
;
; Version 1.0

%include "lib291.inc"
;%include "libmp4.inc"

	BITS	32

	GLOBAL _main

;====== SECTION 1: Define constants =======================================

	ESC		EQU 01h	; scancode, not ascii

	TILE_VISIBLE	EQU 80h
	TILE_SEEN	EQU 40h
	TILE_SOLID	EQU 20h	; sight AND walking

	ATTR_SEEN	EQU 00h
	ATTR_VISIBLE	EQU 80h

	MAX_POCKET	EQU 26
	MAX_TYPES	EQU 32

	MAP_WIDTH	EQU 80
	MAP_HEIGHT	EQU 40

	ITEM_INPOCKET	EQU 80h
	POCKET_EMPTY	EQU -1

	PLAYER_ITEM	EQU 9

	VIS_TILE_WIDTH	EQU 20
	VIS_TILE_HEIGHT	EQU 15
	TILE_WIDTH	EQU 32
	TILE_HEIGHT	EQU 32
	MAP_CENTER_OFF	EQU 7*MAP_WIDTH+9

	FONT_DATA_SIZE	EQU 8+256*8+256*256
	FONT_WIDTH_OFF  EQU 0
	FONT_HEIGHT_OFF EQU 4
	FONT_LOOKUP_OFF EQU 8
	FONT_KERN_OFF   EQU 8+256*8

	MAP_TILES_WIDTH	EQU 512
	ITEMS_WIDTH	EQU 320
	SCREEN_WIDTH	EQU 640
	SCREEN_HEIGHT	EQU 480

	MSG_X		EQU 10
	MSG_Y		EQU 6

	; directional scancodes
	INPUT_UPLEFT	EQU 47h ; home
	INPUT_UP	EQU 48h	; up arrow
	INPUT_UPRIGHT	EQU 49h ; pgup
	INPUT_DOWNLEFT	EQU 4Fh	; end
	INPUT_LEFT	EQU 4Bh	; left arrow
	INPUT_RIGHT	EQU 4Dh	; right arrow
	INPUT_DOWN	EQU 50h	; down arrow
	INPUT_DOWNRIGHT	EQU 51h	; pgdn

;====== SECTION 2: Declare external routines ==============================

; Declare external library routines
EXTERN _libDrawMap, _libDrawString, _MoveChar, _PickUp, _DropItem
EXTERN _libInstallKeyboard, _libRemoveKeyboard 
_libDrawString_arglen	EQU	12
_MoveChar_arglen	EQU	8
_DropItem_arglen 	EQU	4

; Declare local routines global (so library routines can use them)
GLOBAL _DrawMap, _DrawString
GLOBAL _InstallKeyboard, _RemoveKeyboard

; Make program variables global (so library routines can use them)
GLOBAL _ItemDesc, _Items, _Items.end, _Pockets, _Input, _Player,
GLOBAL _CantPickUp, _PickedUp, _Dropped, _CantDrop, _PocketsFull, _KeyMsg,
GLOBAL _CantGo, _ShadowWork, _WhitePixel, _RoundingFactor
GLOBAL _ScreenOff, _FontOff, _FDatOff, _TileOff, _ItemOff
GLOBAL _kbINT, _kbPort, _kbIRQ

; External program variables
EXTERN _Map		; The game map (see map.asm)
EXTERN _ShadowMaps	; Precalculated shadow maps for vis check (shadows.asm)

SECTION .bss

_kbINT		resb	1
_kbIRQ		resb	1
_kbPort		resw	1

_GraphicsMode	resw	1	; ex291 graphics mode

; Temporary calculation space for shadow map
_ShadowWork  resb 6*6

_ScreenOff	resd	1
_FontOff	resd	1
_FDatOff	resd	1
_TileOff	resd	1
_ItemOff	resd	1

SECTION .data

;====== SECTION 5: Declare variables for main procedure ===================

_FN_Font	db 'arialbd.png',0
_FN_FDat	db 'arialbd.dat',0
_FN_Tile	db 'maptiles.png',0
_FN_Item	db 'itemtile.png',0

align 4
_ItemDesc
	dd .0, .1, .2, .3, .4, .5, .6
	times 19 dd .x
    .0	db 'A Delicious Apple',0
    .1	db 'A Poisonous Mushroom',0
    .2	db 'An MP3 File',0
    .3  db 'A Spider',0
    .4  db 'A National Semiconductor AND Chip',0
    .5  db 'Power for your ECE110 Car',0
    .6  db 'A Wrench: the ultimate debugger',0
    .x	db 'Nothing',0

; Item structure (describes the byte organization of the Items array)
STRUC Item
.Type		resd	1	; MSB (bit 7) is 1 if in pocket
				;  (the constant ITEM_INPOCKET is or'ed in)
				; Bits 6-0 are index into _ItemOff and
				;  ItemDesc arrays.
.MapOff		resd	1	; Offset into the map array (Y*MAP_WIDTH+X)
ENDSTRUC
align 4
_Items
    dd 2, 6*MAP_WIDTH+25
    dd 3, 5*MAP_WIDTH+28
    dd 1, 6*MAP_WIDTH+25
    dd 0, 9*MAP_WIDTH+55
    dd 2,18*MAP_WIDTH+60
    dd 4,24*MAP_WIDTH+15
    dd 5,32*MAP_WIDTH+72
    dd 6,36*MAP_WIDTH+20
.end
NUM_MAP_ITEMS	EQU ($-_Items)/8

_Player	dd 14*MAP_WIDTH+35

_Pockets	times MAX_POCKET db POCKET_EMPTY

_Input	db 0

_WhitePixel	dd 00FFFFFFh
_RoundingFactor dd 00800080h, 00800080h

_CantPickUp	db 'Nothing to pick up',0
_PickedUp	db 'Picked Up ',0
_Dropped	db 'Dropped ',0
_CantDrop	db "Can't drop that",0
_PocketsFull	db 'Pockets full',0
_KeyMsg		db ' ( )',0
_CantGo		db "Can't go that way",0

; Keyboard lookup table (ascii). starts at 10h
ASCIILookup_start	equ	10h
ASCIILookup
db 'qwertyuiop'
db 0,0,0,0
db 'asdfghjkl'
db 0,0,0,0,0
db 'zxcvbnm'
db 0,0,0,0,0,0
db ' '
.end

; Keyboard lookup table 2 (keypad), starts at 47h
KeypadLookup_start	equ	47h
KeypadLookup
dd -1, -1	; home
dd  0, -1	; up
dd  1, -1	; pgup
dd  0,  0
dd -1,  0	; left
dd  0,  0
dd  1,  0	; right
dd  0,  0
dd -1,  1	; end
dd  0,  1	; down
dd  1,  1	; pgdn
.end

;====== SECTION 7: Main procedure =========================================

_main:
	call	_LibInit

	; Alocate Screen Buffer
	invoke	_AllocMem, dword SCREEN_WIDTH*SCREEN_HEIGHT*4
	cmp	eax, -1
	je	near .memerror
	mov	[_ScreenOff], eax

	; Allocate Data and Image Buffers (except for Font image)
	invoke	_AllocMem, dword FONT_DATA_SIZE + (MAP_TILES_WIDTH*TILE_HEIGHT + ITEMS_WIDTH*TILE_HEIGHT)*4
	cmp	eax, -1
	je	near .memerror
	mov	[_FDatOff], eax
	add	eax, FONT_DATA_SIZE
	mov	[_TileOff], eax
	add	eax, MAP_TILES_WIDTH*TILE_HEIGHT*4
	mov	[_ItemOff], eax

	; Load font data.. do this first so we know how big the font image is
	invoke  _OpenFile, dword _FN_FDat, word 0
	push	eax
	invoke	_ReadFile, eax, dword [_FDatOff], dword FONT_DATA_SIZE
	pop	eax
	invoke	_CloseFile, eax

	; Allocate Font Image
	mov	eax, [_FDatOff]
	mov	edx, [eax+FONT_WIDTH_OFF]	; width
	imul	edx, dword [eax+FONT_HEIGHT_OFF]; width*height
	shl	edx, 2				; width*height*4
	invoke	_AllocMem, edx
	cmp	eax, -1
	je	near .memerror
	mov	[_FontOff], eax

	; Load font and tile images
	invoke	_LoadPNG, dword _FN_Font, dword [_FontOff], dword 0, dword 0
	invoke	_LoadPNG, dword _FN_Tile, dword [_TileOff], dword 0, dword 0
	invoke	_LoadPNG, dword _FN_Item, dword [_ItemOff], dword 0, dword 0

	; Graphics Init
	invoke	_InitGraphics, dword _kbINT, dword _kbIRQ, dword _kbPort
	test	eax, eax
	jnz	near .graphicserror

	; Find Graphics Mode: 640x480x32, allow driver-emulated modes
	invoke	_FindGraphicsMode, word SCREEN_WIDTH, word SCREEN_HEIGHT, word 32, dword 1
	mov	[_GraphicsMode], ax

	invoke	_InstallKeyboard
	invoke	_SetGraphicsMode, word [_GraphicsMode]

	call	_MP4Main
	call	_RemoveKeyboard

.graphicserror
	call	_ExitGraphics

.memerror
	call	_LibExit
	ret

;====== MP4Main ===========================================================
_MP4Main:
	push	edi

	; Set up initial visibility
	xor	edx, edx		; No movement
	invoke	_MoveChar, dword edx, dword edx

	call	_DrawMap
.loop:
	invoke	_CopyToScreen, dword [_ScreenOff], dword SCREEN_WIDTH*4, dword 0, dword 0, dword SCREEN_WIDTH, dword SCREEN_HEIGHT, dword 0, dword 0

.wait:
	; Wait for new input
	movzx	ebx, byte [_Input]
	test	ebx, ebx
	jz	.wait
	mov	byte [_Input], 0	; Clear input

	; Clear the status line (overkill this way)
	push	ebx
	call	_DrawMap
	pop	ebx

	; Check for a-z and space characters
	cmp	bl, ASCIILookup_start
	jb	.notascii
	cmp	bl, ASCIILookup_start+ASCIILookup.end-ASCIILookup
	ja	.notascii
	mov	bl, [ASCIILookup+ebx-ASCIILookup_start]
	cmp	bl, ' '
	je	.pickup
	test	ebx, ebx
	jz	.loop

	sub	ebx, 'a'
	invoke	_DropItem, ebx
	jmp	short .loop

.pickup:
	call	_PickUp
	jmp	short .loop

.notascii:
	cmp	bl, ESC
	je	.done

	; Check for keypad movement characters
	cmp	bl, KeypadLookup_start
	jb	.loop
	cmp	bl, KeypadLookup_start+(KeypadLookup.end-KeypadLookup)/8
	ja	.loop
	sub	ebx, KeypadLookup_start
	invoke	_MoveChar, dword [KeypadLookup+ebx*8], dword [KeypadLookup+ebx*8+4]
	test	eax, eax
	jz	.loop
	call	_DrawMap
	jmp	.loop

.done:
	pop	edi
	ret

;====== SECTION 8: Your subroutines =======================================

;====== DrawMap ===========================================================
proc _DrawMap
	invoke _libDrawMap
	ret
endproc

;====== DrawString ========================================================
proc _DrawString
.x	arg	4
.y	arg	4
.str	arg	4

	invoke _libDrawString, dword[ebp+.x], dword[ebp+.y], dword[ebp+.str]
	ret
endproc
_DrawString_arglen	EQU	12

;====== InstallKeyboard ===================================================
_InstallKeyboard
	call _libInstallKeyboard	; This only installs _libKeyboardISR
	ret

;====== RemoveKeyboard ====================================================
_RemoveKeyboard:
	call _libRemoveKeyboard
	ret

;====== KeyboardISR =======================================================
_KeyboardISR
	; your code here
_KeyboardISR_end
