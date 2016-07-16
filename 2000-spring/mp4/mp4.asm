; ECE 291 Spring 2000 MP 4/5
; -- Networked Gauntlet --
;
; Completed By:
;  Your Name
;
; Professor Polychronopoulos
; Guest Authors - Peter Johnson, Michael Urman
; Univeristy of Illinois Urbana Champaign
; Dept. of Electrical & Computer Engineering
;
; Ver 1.0

%include "lib291.inc"
%include "libmp4.inc"

	BITS 32

	GLOBAL _main

MAX_PLAYERS		equ	32
MAX_PLAYER_ARROWS	equ	8
MAX_ARROWS		equ	MAX_PLAYER_ARROWS*MAX_PLAYERS
START_ARROW_DISTLEFT	equ	5
MAPSIZE_X		equ	40
MAPSIZE_Y		equ	20
RESPAWN_NUM		equ	8

; Special Keycodes
ESCKEY		equ	01h

; Network Message Types
HELLO		equ	33
UPDATE		equ	21
GOODBYE		equ	22

; Arrow structure
STRUC Arrow
.Flags		resb	1	; Flags is subdivided into 4 fields (msb to lsb):
				;  |Active|Dir|dy|dx|.
				;  Active is 1 bit, 1->arrow is "alive".
				;  Dir is 3 bits (see doc page for encoding)
				;  dy and dx are 2 bit signed numbers telling
				;  the direction of the arrow.
.MapX		resb	1	; Current X position of arrow (on map).
.MapY		resb	1	; Current Y position of arrow (on map).
.DistLeft	resb	1	; Dist remaining that arrow can travel.
ENDSTRUC

; Player structure
STRUC Player
.Flags		resb	1	; Flags is subdivided into 3 fields (msb to lsb):
				;  |Active|Model|Number|.
				;  Active is 1 bit, 1->player is active.
				;  Model is 2 bits (see doc page for encoding)
				;  Number is 6 bits, the player number (on the network).
.MapX		resb	1	; Current X position of player (on map).
.MapY		resb	1	; Current Y position of player (on map).
.Score		resb	1	; Current player score.
ENDSTRUC

; Network message structures

STRUC GenericMsg		; Generic Message
.MsgType	resb	1	; 1-byte packet type identifier
.PlayerNum	resb	1	; Player that transmitted the message
ENDSTRUC

STRUC HelloMsg			; Hello Message
.MsgType	resb	1
.PlayerNum	resb	1
.PlayerInfo	resb	Player_size	; Player structure of player transmitting
ENDSTRUC

STRUC UpdateMsg			; Update Message
.MsgType	resb	1
.PlayerNum	resb	1
.PlayerInfo	resb	Player_size	; Player structure of player transmitting
.ArrowInfo	resb	MAX_ARROWS*Arrow_size	; Arrows of player
ENDSTRUC

STRUC GoodbyeMsg		; Goodbye Message
.MsgType	resb	1
.PlayerNum	resb	1
ENDSTRUC

	SECTION .bss

MouseSeg	resw	1	; Mouse RMCB segment
MouseOff	resw	1	; Mouse RMCB offset

RespawnPoints	resb	RESPAWN_NUM*2
				; coordinates of respawn points (X,Y)

Map		resb	MAPSIZE_X*MAPSIZE_Y
				; Playing Map, each byte is encoded as follows:
				;  |Not Passable|Type| (msb to lsb).
				;  Not Passable is 1 bit, 0->block can be walked on.
				;  Type is 7 bits, indicating what the block
				;   looks like.
PlayerMap	resb	MAPSIZE_X*MAPSIZE_Y
				; Map, each byte contains either a player number
				;  (if a player is occupying that space) or -1.
				; Set up in _UpdatePlayerMap and used in _MovePlayerLocal
				;  and _MoveArrows.
Players		resb	MAX_PLAYERS*Player_size
				; Players array.  Up to MAX_PLAYERS can play at once.
LocalPlayerNum  resb	1	; Local player number (index into Players array)

Arrows		resb	MAX_ARROWS*Arrow_size
				; Arrows array.  Each player can have up to
				;  MAX_PLAYER_ARROWS arrows in the air at once.
				;  This array is grouped by player.

NetworkPlayers  resb	MAX_PLAYERS*Player_size
				; Network Players array updated by NetworkCallback and
				; selectively copied to Players array by UpdateFromNetwork
NetworkArrows	resb	MAX_ARROWS*Arrow_size
				; Network Arrows array updated by NetworkCallback and
				; selectively copied to Arrows array by UpdateFromNetwork

FontMap		resb	128*8*8 ; 8x8 images of font characters

GraphicsSel	resw	1	; Graphics selector (points to 320x200 screen)

BackBufSel	resw	1	; Back buffer selector

PaletteData	resb	256*3	; Palette

TileImages	resb	128*16*16
PlayerImages	resb	32*16*16
ArrowImages	resb	8*16*16
MouseImage	resb	16*16
        
MouseX		resw	1
MouseY		resw	1
MouseButtons	resb	1

CurrentKey	resb	1	; Key currently depressed (set in keyboard handler)
ExitFlag	resb	1

LastPlayerMoveTime resd 1	; Last player movement timestamp (set and checked in main loop)

LastFireTime	resd	1	; Last fire timestamp (set and checked in main loop)
LastArrowMoveTime resd  1	; Last arrow movement timestamp (set and checked in main loop)

LastHelloTime	resd	1	; Last hello message timestamp
LastUpdateTime  resd	1	; Last update message timestamp

CurrentTime	resd	1	; Current time (incremented in TimerHandler)

NetworkDisabled resb	1	; Network disabled?

ArrowFired	resb	1	; Has an arrow been fired?

NumPlayers	resb	1	; Number of players playing

	SECTION .data

; Network group and base machine names
GroupName	db	'ECE291MP5Spr2K$$'
LocalName	db	'ECE291MP5Ply00$$'	

; Image filenames
MapFilename	db	"Map1.MAP",0
FontFilename	db	"Font.PCX",0
TilesFilename	db	"Tiles.PCX",0
MouseFilename	db	"Mouse.PCX",0
PlayersFilename db	"Players.PCX",0
ArrowsFilename  db	"Arrows.PCX",0

; Screen text strings
CaptionStr	db	"ECE 291 Networked Quake2D    Spring 2000",0
ScoreStr	db	"Players                Your Score       ",0

KeyMap		; Each entry in table is x and y movement deltas
		db	-1, -1  ; 47h (Home)
		db	 0, -1  ; 48h (Up)
		db	 1, -1  ; 49h (PgUp)
		db	 0,  0  ; 4Ah
		db	-1,  0  ; 4Bh (Left)
		db	 0,  0  ; 4Ch
		db	 1,  0  ; 4Dh (Right)
		db	 0,  0  ; 4Eh
		db	-1,  1  ; 4Fh (End)
		db	 0,  1  ; 50h (Down)
		db	 1,  1  ; 51h (PgDn)
KeyMap_end

ArrowDirMap	; Decodes dy/dx pair of bits to 0-7 direction.  Used in
		;  MouseHandler to determine arrow direction.
		; This value is OR'ed into the Flags for Arrow, so the high
		;  bit (active) is set for correct direction decodings, and
		;  the low 4 bits are 0 so as not to overwrite the dydx bits.
		db	00h,0A0h, 00h,0E0h,0C0h,0B0h, 00h,0D0h
		db	00h, 00h, 00h, 00h, 80h, 90h, 00h,0F0h
ArrowDirMap_end

	SECTION .text

; Program start
_main:
	call	_LibInit

	; Datafile load
	invoke  _LoadMap, dword MapFilename
	invoke  _LoadFont, dword FontFilename
	call	_LoadGraphics
        
	; Graphics init
	call	_SetMode13
	call	_GraphicsInit

	invoke  _DrawText, dword 0, dword 2, dword CaptionStr

	; Mouse/Keyboard/Timer init
	call	_MouseInit
	call	_InstallMouse
	call	_InstallKeyboard
	call	_InstallTimer

	; Network setup
	call	_InstallNetwork
	cmp	eax, -1
	jne	.networkenabled

	mov	byte [NetworkDisabled], 1

.networkenabled:
        
.loop:
	call	_DrawMap
	call	_DrawPlayers
	call	_DrawArrows
	call	_DrawMouse

	; Update bottom score line
	xor	ah, ah
	mov	al, [NumPlayers]
	mov	ebx, ScoreStr+7
	call	BinAsc
	xor	ebx, ebx
	mov	bl, [LocalPlayerNum]
	xor	ah, ah
	mov	al, [Players+ebx*4+Player.Score]
	mov	ebx, ScoreStr+33
	call	BinAsc
	invoke  _DrawText, dword 0, dword 192, dword ScoreStr

	call	_RefreshScreen

	call	_UpdatePlayerMap

	xor	eax, eax
	mov	al, [LocalPlayerNum]
	test	byte [Players+eax*4+Player.Flags], 80h
	jnz	.DontRespawn

	call	_PlayerRespawn
        
.DontRespawn:

	; Allow player moving 6 times/sec
	mov	eax, [CurrentTime]
	sub	eax, [LastPlayerMoveTime]
	cmp	eax, 3
	jb	.NoAllowPlayerMove
	call	_MovePlayerLocal
	cmp	eax, 0
	jz	.NoAllowPlayerMove
	mov	eax, [CurrentTime]
	mov	[LastPlayerMoveTime], eax
.NoAllowPlayerMove:

	; Allow arrow firing 2 times/sec
	mov	eax, [CurrentTime]
	sub	eax, [LastFireTime]
	cmp	eax, 9
	jb	.NoAllowFire
	call	_FireArrowLocal
	cmp	eax, 0
	jz	.NoAllowFire
	and	byte [MouseButtons], 11111110b  ; If arrow fired, release the button.
	mov	byte [ArrowFired], 1
	mov	eax, [CurrentTime]
	mov	[LastFireTime], eax
.NoAllowFire:

	; Move arrows 18.2 times/second
	mov	eax, [CurrentTime]
	sub	eax, [LastArrowMoveTime]
	cmp	eax, 1
	jb	.NoArrowMove
	call	_MoveArrows
	inc	dword [LastArrowMoveTime]
.NoArrowMove:

	cmp	byte [NetworkDisabled], 1
	je	near .NoNetwork

	; Send HELLO message every 2 seconds
	mov	eax, [CurrentTime]
	sub	eax, [LastHelloTime]
	cmp	eax, 36
	jb	.NoHelloSend
	push	es
	mov	es, [_NetTransferSel]	     
	mov	byte [es:TXBuffer+HelloMsg.MsgType], HELLO
	xor	eax, eax
	mov	al, [LocalPlayerNum]
	mov	[es:TXBuffer+HelloMsg.PlayerNum], al
	mov	eax, [Players+eax*4]
	mov	[es:TXBuffer+HelloMsg.PlayerInfo], eax
	pop	es
	invoke  _SendPacket, dword HelloMsg_size
	mov	eax, [CurrentTime]
	mov	[LastHelloTime], eax
.NoHelloSend:

	; Send UPDATE message 9 times/sec or when arrow fired
	cmp	byte [ArrowFired], 1
	je	.UpdateSend
	mov	eax, [CurrentTime]
	sub	eax, [LastUpdateTime]
	cmp	eax, 2
	jb	.NoUpdateSend
.UpdateSend:
	push	es
	mov	es, [_NetTransferSel]	     
	mov	byte [es:TXBuffer+UpdateMsg.MsgType], UPDATE
	xor	eax, eax
	mov	al, [LocalPlayerNum]
	mov	[es:TXBuffer+UpdateMsg.PlayerNum], al
	mov	edx, [Players+eax*4]
	mov	[es:TXBuffer+UpdateMsg.PlayerInfo], edx
	push	esi
	push	edi
	xor	ebx, ebx
	mov	bl, [LocalPlayerNum]
	shl	ebx, 5			; MAX_PLAYER_ARROWS*Arrow_size=32 bytes
	lea	esi, [Arrows+ebx]
	mov	edi, TXBuffer+UpdateMsg.ArrowInfo
	mov	ecx, MAX_ARROWS		; each arrow is 4 bytes
	rep movsd
	pop	edi
	pop	esi
	pop	es
	invoke  _SendPacket, dword UpdateMsg_size
	mov	byte [ArrowFired], 0
	mov	eax, [CurrentTime]
	mov	[LastUpdateTime], eax
.NoUpdateSend:

	; Update local structures from network updates
	call	_UpdateFromNetwork
.NoNetwork:

	cmp	byte [ExitFlag], 0
	je	near .loop			; Loop while not exit

	; Close network first
	cmp	byte [NetworkDisabled], 1
	je	.DontRemoveNetwork
	call	_RemoveNetwork
.DontRemoveNetwork:
.error:
	; Shutdown and cleanup
	call	_RemoveTimer
	call	_RemoveKeyboard
	call	_RemoveMouse
	call	_GraphicsExit
	call	_SetModeC80

        call    _MP4LibExit

	call	_LibExit
	ret

;--------------------------------------------------------------
;--             Replace Library Calls with your Code!        --
;--             Do not forget to add Function Headers        --
;--------------------------------------------------------------

;--------------------------------------------------------------
;--                        GraphicsInit()                    --
;--------------------------------------------------------------
_GraphicsInit

	call	_GraphicsInitLib
	ret

;--------------------------------------------------------------
;--                        GraphicsExit()                    --
;--------------------------------------------------------------
_GraphicsExit

	call	_GraphicsExitLib
	ret


;--------------------------------------------------------------
;--                        SetMode13()                       --
;--------------------------------------------------------------
_SetMode13

	call	_SetMode13Lib
	ret


;--------------------------------------------------------------
;--                        DrawMap()                         --
;--------------------------------------------------------------
_DrawMap

	call	_DrawMapLib
	ret


;--------------------------------------------------------------
;--                        DrawPlayers()                     --
;--------------------------------------------------------------
_DrawPlayers

	call	_DrawPlayersLib
	ret


;--------------------------------------------------------------
;--                        DrawArrows()                      --
;--------------------------------------------------------------
_DrawArrows

	call	_DrawArrowsLib
	ret


;--------------------------------------------------------------
;--                        DrawMouse()                       --
;--------------------------------------------------------------
_DrawMouse

	call	_DrawMouseLib
	ret


;--------------------------------------------------------------
;--                        DrawText()                        --
;--------------------------------------------------------------
proc _DrawText

%$X	arg	4
%$Y	arg	4
%$Text  arg	4

	invoke  _DrawTextLib, dword [ebp+%$X], dword [ebp+%$Y], dword [ebp+%$Text]

endproc
_DrawText_arglen	equ	12


;--------------------------------------------------------------
;--                        TransparentBlit()                 --
;--------------------------------------------------------------
proc _TransparentBlit

%$x		arg	4
%$y		arg	4
%$image		arg	4
%$sourcewidth	arg	4

	invoke  _TransparentBlitLib, dword [ebp+%$x], dword [ebp+%$y], dword [ebp+%$image], dword [ebp+%$sourcewidth]

endproc
_TransparentBlit_arglen equ	16


;--------------------------------------------------------------
;--                        RefreshScreen()                   --
;--------------------------------------------------------------
_RefreshScreen

	call	_RefreshScreenLib
	ret


;--------------------------------------------------------------
;--                        LoadGraphics()                    --
;--------------------------------------------------------------
_LoadGraphics

	call	_LoadGraphicsLib
	ret


;--------------------------------------------------------------
;--                        LoadMap()                         --
;--------------------------------------------------------------
proc _LoadMap

%$Filename	arg	4

	invoke  _LoadMapLib, dword [ebp+%$Filename]

endproc
_LoadMap_arglen		equ	4


;--------------------------------------------------------------
;--                        LoadFont()                        --
;--------------------------------------------------------------
proc _LoadFont

%$Filename	arg	4

	invoke  _LoadFontLib, dword [ebp+%$Filename]

endproc
_LoadFont_arglen	equ	4


;--------------------------------------------------------------
;--                        DecodePCX()                       --
;--------------------------------------------------------------
proc _DecodePCX

%$SrcSel	arg	2
%$Src		arg	4
%$DestSel	arg	2
%$Dest		arg	4
%$SrcLen	arg	4
%$DestLen	arg	4

	invoke  _DecodePCXLib, word [ebp+%$SrcSel], dword [ebp+%$Src], word [ebp+%$DestSel], dword [ebp+%$Dest], dword [ebp+%$SrcLen], dword [ebp+%$DestLen]

endproc
_DecodePCX_arglen	equ	20


;--------------------------------------------------------------
;--                        InstallKeyboard()                 --
;--------------------------------------------------------------
_InstallKeyboard

	call	_InstallKeyboardLib
	ret


;--------------------------------------------------------------
;--                        RemoveKeyboard()                  --
;--------------------------------------------------------------
_RemoveKeyboard

	call	_RemoveKeyboardLib
	ret


;--------------------------------------------------------------
;--                        MouseInit()                       --
;--------------------------------------------------------------
_MouseInit

	call	_MouseInitLib
	ret


;--------------------------------------------------------------
;--                        InstallMouse()                    --
;--------------------------------------------------------------
_InstallMouse

	call	_InstallMouseLib
	ret


;--------------------------------------------------------------
;--                        RemoveMouse()                     --
;--------------------------------------------------------------
_RemoveMouse

	call	_RemoveMouseLib
	ret


;--------------------------------------------------------------
;--                        InstallTimer()                    --
;--------------------------------------------------------------
_InstallTimer

	call	_InstallTimerLib
	ret


;--------------------------------------------------------------
;--                        RemoveTimer()                     --
;--------------------------------------------------------------
_RemoveTimer

	call	_RemoveTimerLib
	ret


;--------------------------------------------------------------
;--                        KeyboardISR()                     --
;--------------------------------------------------------------
KeyboardISR

	call	KeyboardISRLib
	ret
KeyboardISR_end


;--------------------------------------------------------------
;--                        MouseCallback()                   --
;--------------------------------------------------------------
proc MouseCallback
%$DPMIRegsPtr	arg	4

	invoke  MouseCallbackLib, dword [ebp+%$DPMIRegsPtr]

endproc
MouseCallback_end


;--------------------------------------------------------------
;--                        TimerISR()                        --
;--------------------------------------------------------------
TimerISR

	call	TimerISRLib
	ret
TimerISR_end


;--------------------------------------------------------------
;--                        MoveArrows()                      --
;--------------------------------------------------------------
_MoveArrows

	call	_MoveArrowsLib
	ret


;--------------------------------------------------------------
;--                        MovePlayerLocal()                 --
;--------------------------------------------------------------
_MovePlayerLocal

	call	_MovePlayerLocalLib
	ret


;--------------------------------------------------------------
;--                        FireArrowLocal()                  --
;--------------------------------------------------------------
_FireArrowLocal

	call	_FireArrowLocalLib
	ret


;--------------------------------------------------------------
;--                        PlayerRespawn()                   --
;--------------------------------------------------------------
_PlayerRespawn

	call	_PlayerRespawnLib
	ret


;--------------------------------------------------------------
;--                        UpdatePlayerMap()                 --
;--------------------------------------------------------------
_UpdatePlayerMap

	call	_UpdatePlayerMapLib
	ret


;--------------------------------------------------------------
;--                        InstallNetwork()                  --
;--------------------------------------------------------------
_InstallNetwork
        
	; Sample non-network player init
        ; Comment this out when you start working on network code!
;	mov	 dword [LocalPlayerNum], 0
;	mov	 byte [Players+0*4+Player.MapX], 20
;	mov	 byte [Players+0*4+Player.MapY], 10
;	or	 byte [Players+0*4+Player.Flags], 80h
        
;	mov	 byte [Players+1*4+Player.MapX], 30
;	mov	 byte [Players+1*4+Player.MapY], 5
;	or	 byte [Players+1*4+Player.Flags], 80h

;	mov	eax, -1
;	ret

	call	_InstallNetworkLib
	ret


;--------------------------------------------------------------
;--                        RemoveNetwork()                   --
;--------------------------------------------------------------
_RemoveNetwork

	call	_RemoveNetworkLib
	ret


;--------------------------------------------------------------
;--                        NetworkCallback()                 --
;--------------------------------------------------------------
proc NetworkCallback
%$ReceivePtr	arg	4
%$MessageLength arg	4

	invoke  NetworkCallbackLib, dword [ebp+%$ReceivePtr], dword [ebp+%$MessageLength]

endproc
NetworkCallback_end

;--------------------------------------------------------------
;--                        UpdateFromNetwork()               --
;--------------------------------------------------------------
_UpdateFromNetwork

	call	_UpdateFromNetworkLib
	ret
