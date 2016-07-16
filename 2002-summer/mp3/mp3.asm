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

	BITS	16

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
	MAP_HEIGHT	EQU 20

	ITEM_INPOCKET	EQU 80h
	POCKET_EMPTY	EQU -1

	PLAYER_CHAR	EQU 02h
	PLAYER_ATTR	EQU 0Fh

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
EXTERN dosxit
;EXTERN kbdin, dspout, dspmsg, binasc, ascbin;, mp3xit
;EXTERN libMP3Main, libDrawMap, libMoveChar, libPickUp, libDropItem
;EXTERN libDisplay, libInstallKeyboard, libRemoveKeyboard, libKeyboardISR

; Declare local routines
GLOBAL MP3Main, DrawMap, MoveChar, PickUp, DropItem, Display
GLOBAL InstallKeyboard, RemoveKeyboard, KeyboardISR

; Make program variables global
GLOBAL MapTiles, ItemTiles, ItemDesc, Map, Items, Pockets, Input, Player,
GLOBAL KeyboardV

EXTERN Map		; The game map (see map.asm)
EXTERN ShadowMaps	; Precalculated shadow maps for vis check (shadows.asm)

;====== SECTION 3: Define stack segment ===================================

SEGMENT stkseg STACK class=STACK        ; *** STACK SEGMENT ***
        resb      64*8
stacktop:
        resb      0                     ; work around NASM bug

;====== SECTION 4: Define code segment ====================================

SEGMENT code                            ; *** CODE SEGMENT ***

;====== SECTION 5: Declare variables for main procedure ===================
MapTiles
	db ' ', 070h	; empty space (x)
	db 0B0h, 010h	; room floor (r)
	db 0B1h, 030h	; path (o)
	db 0BAh, 060h	; vertical wall (l)
	db 0CDh, 060h	; horizontal wall (m)
	db 0C9h, 060h	; UL corner wall (p)
	db 0BBh, 060h	; UR corner wall (q)
	db 0C8h, 060h	; BL corner wall (b)
	db 0BCh, 060h	; BR corner wall (d)
	db 0FEh, 050h	; Door (e)
	times 6 db ' ', 070h ; filler to 16

ItemTiles
	db 0E5h, 0Ch	; red apple
	db 0F5h, 0Eh	; yellow banana
	db 00Dh, 0Ah	; musical note
	db  '*', 07h	; grey lint
	times 22 db ' ', 07h ; fillter to 26

ItemDesc
	dw .0, .1, .2, .3,
	times 22 dw .x
    .0	db 'A Delicious Apple',0
    .1	db 'A Scrumptious Banana',0
    .2	db 'An MP3 File',0
    .3  db 'Pocket Lint',0
    .x	db 'Nothing',0

; Item structure (describes the byte organization of the Items array)
STRUC Item
.Type		resb	1	; MSB (bit 7) is 1 if in pocket
				;  (the constant ITEM_INPOCKET is or'ed in)
				; Bits 6-0 are index into ItemTiles and
				;  ItemDesc arrays.
.MapOff		resw	1	; Offset into the map array (Y*MAP_WIDTH+X)
ENDSTRUC

Items
    db 2
    dw 6*MAP_WIDTH+25
    db 3
    dw 5*MAP_WIDTH+28
    db 1
    dw 6*MAP_WIDTH+25
    db 0
    dw 9*MAP_WIDTH+55
    db 2
    dw 13*MAP_WIDTH+50
NUM_MAP_ITEMS	EQU ($-Items)/3

Pockets	times MAX_POCKET db POCKET_EMPTY

Input	db 0
Player	dw 5*MAP_WIDTH+23

KeyboardV   resw 2	; stores old keyboard vector

CantPickUp  db 'Nothing to pick up',0
PickedUp    db 'Picked Up ',0
Dropped	    db 'Dropped ',0
CantDrop    db "Can't drop that",0
PocketsFull db 'Pockets full',0
KeyMsg      db ' ( )',0
CantGo      db "Can't go that way",0

; Temporary calculation space for shadow map
ShadowWork  resb 6*6

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
dw 0FFFFh	; home
dw 0FF00h	; up
dw 0FF01h	; pgup
dw 0
dw 000FFh	; left
dw 0
dw 00001h	; right
dw 0
dw 001FFh	; end
dw 00100h	; down
dw 00101h	; pgdn
.end

;====== SECTION 6: Program initialization =================================

..start:
        mov     ax, cs                  ; Initialize Default Segment register
        mov     ds, ax  
        mov     ax, stkseg              ; Initialize Stack Segment register
        mov     ss, ax
        mov     sp, stacktop            ; Initialize Stack Pointer register

;====== SECTION 7: Main procedure =========================================

MAIN:
        ; Put display into 80x50 text mode
        mov     ax, 3                   ; Enter text mode
        int     10h
        mov     ax, 1112h               ; Set to 8x8 font
        xor     bx, bx
        int     10h

	; Turn on background intensity (rather than blink)
	mov	ax, 1003h
	int	10h

	; Remember old cursor shape
	mov	ah, 3
	int	10h
	push	cx
	
        mov     ah, 1			; hide text cursor
	xor	bx, bx
        mov     cx, 2000h
        int     10h

	call	InstallKeyboard
	call	MP3Main
	call	RemoveKeyboard

	; Restore text cursor
	pop	cx
	mov	ah, 1
	int	10h

	; Put display back into 80x25 text mode
        mov     ax, 1114h               ; Set to 8x16 font
        xor     bx, bx
        int     10h
        mov     ax, 3                   ; Enter text mode (to clear screen)
        int     10h

	call	dosxit			; Exit MP3

;====== SECTION 8: Your subroutines =======================================

;====== MP3Main ===========================================================
MP3Main:
	push	ax
	push	bx
	push	cx
	push	dx
	push	di

	; Set up initial visibility
	xor	dx, dx			; No movement
	call	MoveChar

	call	DrawMap

	xor	bh, bh

.loop:
	; Wait for new input
	mov	bl, [Input]
	test	bl, bl
	jz	.loop
	mov	byte [Input], 0		; Clear input

	; Clear the status line
	push	es
	mov	ax, 0B800h
	mov	es, ax
	mov	ax, 0007h
	mov	cx, 80
	mov	di, 80*49*2
	rep stosw
	pop	es

	; Check for a-z and space characters
	cmp	bl, ASCIILookup_start
	jb	.notascii
	cmp	bl, ASCIILookup_start+ASCIILookup.end-ASCIILookup
	ja	.notascii
	mov	bl, [ASCIILookup+bx-ASCIILookup_start]
	cmp	bl, ' '
	je	.pickup

	sub	bl, 'a'
	call	DropItem
	jmp	short .loop

.pickup:
	call	PickUp
	jmp	short .loop

.notascii:
	cmp	bl, ESC
	je	.done

	; Check for keypad movement characters
	cmp	bl, KeypadLookup_start
	jb	.loop
	cmp	bl, KeypadLookup_start+KeypadLookup.end-KeypadLookup
	ja	.loop
	sub	bl, KeypadLookup_start
	shl	bl, 1
	mov	dx, [KeypadLookup+bx]
	test	dx, dx			; no movement
	jz	.loop
	call	MoveChar
	call	DrawMap
	jmp	short .loop

.done:
	pop	di
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret

;====== DrawMap ===========================================================
DrawMap:
	push	ax
	push	bx
	push	si
	push	di
	push	es

	mov	ax, 0B800h
	mov	es, ax

	; Draw the map first
	xor	si, si
	xor	di, di
	xor	bh, bh

.maploop:
	xor	ax, ax
	mov	bl, [Map+si]
	test	bl, TILE_VISIBLE
	jz	.notvisible
	or	ah, ATTR_VISIBLE
	jmp	short .drawmaptile

.notvisible:
	test	bl, TILE_SEEN
	jz	.notseen
	or	ah, ATTR_SEEN

.drawmaptile:
	and	bl, 0Fh
	shl	bx, 1
	or	ax, [MapTiles+bx]
	mov	[es:di], ax

.notseen:
	inc	si
	add	di, 2
	cmp	si, MAP_WIDTH*MAP_HEIGHT
	jl	.maploop

	; Draw items on visible tiles and not in pocket
	xor	si, si
	xor	bh, bh

.itemloop:
	mov	bl, [Items+si+Item.Type]
	test	bl, ITEM_INPOCKET
	jnz	.loopnext
	mov	di, [Items+si+Item.MapOff]
	test	byte [Map+di], TILE_VISIBLE
	jz	.loopnext

	shl	bx, 1
	mov	ax, [ItemTiles+bx]
	shl	di, 1
;	mov	[es:di], ax
	mov	[es:di], al
	or	[es:di+1], ah
	
.loopnext:
	add	si, Item_size
	cmp	si, NUM_MAP_ITEMS*Item_size
	jl	.itemloop

	; Draw player
	mov	di, [Player]
	shl	di, 1
	mov	byte [es:di], PLAYER_CHAR
	or	byte [es:di+1], PLAYER_ATTR

	pop	es
	pop	di
	pop	si
	pop	bx
	pop	ax
	ret

;====== MoveChar ==========================================================
MoveChar:
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	push	es

	mov	ax, ds
	mov	es, ax

	mov	bx, [Player]		; Get current player position

	test	dx, dx			; Check for no movement
	jz	.notsolid

	; Calculate new position, but don't store it
	test	dh, 80h
	jnz	.up
	test	dh, 01h
	jz	.finishcalc
	add	bx, MAP_WIDTH*2
.up:
	sub	bx, MAP_WIDTH

.finishcalc:
	mov	al, dl
	cbw
	add	bx, ax

	; If tile is solid, display message and exit
	test	byte [Map+bx], TILE_SOLID
	jz	.notsolid

	mov	dx, 3101h
	mov	bx, CantGo
	call	DrawString
	jmp	.done

.notsolid:
	; First clear visible bits from map
	mov	di, MAP_WIDTH*MAP_HEIGHT
.clearvisloop:
	dec	di
	and	byte [Map+di], ~TILE_VISIBLE
	test	di, di
	jnz	.clearvisloop

	mov	[Player], bx		; Update player position

	; Recalculate visibility using shadow maps
	mov	ax, MAP_WIDTH-5		; Y movement delta (from EOL)
	mov	dx, 1			; X movement delta
	call	.doquadrant

	mov	bx, [Player]
	mov	ax, -(MAP_WIDTH+5)	; Y movement delta (from EOL)
	mov	dx, 1			; X movement delta
	call	.doquadrant

	mov	bx, [Player]
	mov	ax, -(MAP_WIDTH-5)	; Y movement delta (from EOL)
	mov	dx, -1			; X movement delta
	call	.doquadrant

	mov	bx, [Player]
	mov	ax, MAP_WIDTH+5		; Y movement delta (from EOL)
	mov	dx, -1			; X movement delta
	call	.doquadrant

	jmp	.done

.doquadrant:
	; First copy base shadow map to work area
	mov	cx, 6*6
	mov	si, ShadowMaps
	mov	di, ShadowWork
	rep movsb

	; OR in successive shadow maps
	mov	ch, 5
.loop:
	cmp	bx, 0
	jl	.nextcoord
	cmp	bx, MAP_WIDTH*MAP_HEIGHT
	jge	.nextcoord
	test	byte [Map+bx], TILE_SOLID
	jz	.nextcoord

	; OR in one shadow map
.orshadow:
	mov	di, ShadowWork
	sub	si, 6*6		; Get back to the beginning of shadow map
.orshadowloop:
	mov	cl, [si]
	inc	si
	or	[di], cl
	inc	di
	cmp	di, ShadowWork+6*6
	jb	.orshadowloop

	; Move to next map coordinate and shadow map
.nextcoord:
	add	si, 6*6
	cmp	si, ShadowMaps+5*5*6*6
	jae	.updatevis

	dec	ch
	jnz	.notnextrow

	mov	ch, 5
	add	bx, ax
	add	bx, dx		; Adjust for 5/6 difference
	jmp	short .loop

.notnextrow:
	add	bx, dx
	jmp	short .loop

.updatevis:
	; Update map visibility/seen from shadow map
	mov	bx, [Player]
	mov	si, ShadowWork
	mov	cx, 0605h
.updatevisloop:
	cmp	bx, 0
	jl	.nextvisloop
	cmp	bx, MAP_WIDTH*MAP_HEIGHT
	jge	.nextvisloop

	cmp	byte [si], 01Fh
	je	.nextvisloop
	or	byte [Map+bx], TILE_VISIBLE | TILE_SEEN

.nextvisloop:
	inc	si
	dec	ch
	jnz	.notnextrowvisloop

	test	cl, cl
	jz	.nextquadrant

	dec	cl
	mov	ch, 6
	add	bx, ax
	jmp	short .updatevisloop

.notnextrowvisloop:
	add	bx, dx
	jmp	short .updatevisloop

.nextquadrant:
	ret

.done:
	pop	es
	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret

;====== PickUp ============================================================
PickUp:
	push	ax
	push	bx
	push	dx
	push	si

	; Scan the items list for items at the player location
	mov	ax, [Player]
	xor	bx, bx			; Offset
	xor	dx, dx			; Index
.loop:
	test	byte [Items+bx+Item.Type], ITEM_INPOCKET
	jnz	.loopnext
	cmp	[Items+bx+Item.MapOff], ax
	je	.found
.loopnext:
	add	bx, Item_size
	inc	dx
	cmp	bx, NUM_MAP_ITEMS*Item_size
	jl	.loop

	; Didn't find one, tell the user about it
	mov	dx, 3101h
	mov	bx, CantPickUp
	call	DrawString
	jmp	short .done

.found:
	; Find the first open pocket
	xor	si, si
.loop2:
	cmp	byte [Pockets+si], POCKET_EMPTY
	je	.found2
	inc	si
	cmp	si, MAX_POCKET
	jl	.loop2

	; Didn't find an empty pocket, tell the user about it
	mov	dx, 3101h
	mov	bx, PocketsFull
	call	DrawString
	jmp	short .done

.found2:
	; Store into our pocket
	xor	ah, ah
	mov	al, [Items+bx+Item.Type]	; Remember the type
	shl	ax, 1
	or	byte [Items+bx+Item.Type], ITEM_INPOCKET
	mov	[Pockets+si], dl	; Save index
	mov	dx, si
	add	dl, 'a'			; Convert to letter (key)
	mov	[KeyMsg+2], dl		; Save into KeyMsg
	mov	si, ax

	; Tell the user about it
	mov	dx, 3101h
	mov	bx, PickedUp
	call	DrawString
	mov	bx, [ItemDesc+si]
	call	DrawString
	mov	bx, KeyMsg
	call	DrawString

.done:
	pop	si
	pop	dx
	pop	bx
	pop	ax
	ret

;====== DropItem ==========================================================
DropItem:
	push	ax
	push	bx
	push	dx
	push	di

	; Pocket already empty?
	xor	ah, ah
	mov	dl, POCKET_EMPTY
	mov	al, [Pockets+bx]
	cmp	al, dl
	jne	.notempty

	; Yes, tell the user about it
	mov	dx, 3101h
	mov	bx, CantDrop
	call	DrawString
	jmp	short .done

.notempty:
	; Empty the pocket
	mov	[Pockets+bx], dl
	mov	di, ax
	shl	di, 1
	add	di, ax

	; Update the Items data structure
	mov	bx, [Player]
	mov	[Items+di+Item.MapOff], bx
	xor	bh, bh
	mov	bl, [Items+di+Item.Type]
	and	bl, ~ITEM_INPOCKET
	mov	[Items+di+Item.Type], bl
	shl	bx, 1
	mov	ax, [ItemDesc+bx]

	; Tell the user what we just did
	mov	dx, 3101h
	mov	bx, Dropped
	call	DrawString
	mov	bx, ax
	call	DrawString

.done:
	pop	di
	pop	dx
	pop	bx
	pop	ax
	ret

;====== DrawString ========================================================
DrawString:
	push	ax
	push	bx
	push	di
	push	es

	mov	ax, 0B800h
	mov	es, ax

	; Convert coordinate in dl/dh to screen offset in di
	xor	ah, ah
	mov	al, dh
	xor	dh, dh
	mov	di, ax
	shl	di, 2		; *= 5
	add	di, ax
	shl	di, 4		; *= 16 -> *=80 total
	add	di, dx
	shl	di, 1		; *= 2 for char/attrib

	mov	ah, 07h
	; Copy the string until 0 termination.
.loop:
	mov	al, [bx]
	inc	bx
	test	al, al
	jz	.done
	mov	[es:di], ax
	add	di, 2
	jmp	short .loop

.done:
	; Convert ending screen offset to dl/dh coordinate
	mov	ax, di
	shr	ax, 1
	mov	dl, 80
	div	dl
	mov	dh, al
	mov	dl, ah

	pop	es
	pop	di
	pop	bx
	pop	ax
	ret

;====== InstallKeyboard ===================================================
InstallKeyboard:
	push	ax
	push	bx
	push	dx
	push	es

; [DOS] get interrupt vector
	mov	ax, 3509h
	int	21h

; save old vector
	mov	[KeyboardV], bx
	mov	[KeyboardV+2], es

; [DOS] set interrupt vector
	mov	dx, KeyboardISR
	mov	ax, 2509h
	int	21h

; restore registers from stack
	pop	es
	pop	dx
	pop	bx
	pop	ax

	ret

;====== RemoveKeyboard ====================================================
RemoveKeyboard:
	push	ax
	push	dx
	push	ds

; restore old vector
	mov	dx, [KeyboardV]
	mov	ds, [KeyboardV+2]

; [DOS] set interrupt vector
	mov	ax, 2509h
	int	21h

; restore registers from stack
	pop	ds
	pop	dx
	pop	ax

	ret

;====== KeyboardISR =======================================================
KeyboardISR:
	push	ax
	in	al, 60h
	test	al, 80h			; Skip key releases
	jnz	.skip
	mov	[cs:Input], al
.skip
	mov	al, 20h
	out	20h, al
	pop	ax
	iret


