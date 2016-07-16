; ECE 291 Spring 2004 MP4    
; -- Gravity Blocks --
;
; Completed By:
;  Your Name
;
; Zbigniew Kalbarczyk
; Guest Author - Ryan Chmiel
; University of Illinois Urbana Champaign
; Dept. of Electrical & Computer Engineering
;
; Ver 1.0

%include "lib291.inc"
%include "libmp4.inc"

	BITS 32

	GLOBAL _main

; Define Contstants

DOWNARROW	EQU	80
RIGHTARROW	EQU	77
LEFTARROW	EQU	75
UPARROW		EQU	72

	SECTION .bss

_seed		resw	1	; seed value for random number generator

_GraphicsMode	resw	1	; Graphics mode #

_kbINT		resb	1	; Keyboard interrupt #
_kbIRQ		resb	1	; Keyboard IRQ
_kbPort		resw	1	; Keyboard port

_ScreenOff	resd	1	; Screen offset
_BlocksOff	resd	1	; Blocks offset
_FontOff	resd	1	; Font offset

_CurrentPiece	resb	16      ; Current Piece
_TempPiece	resb	16	; Temporary piece used in rotations
_XPos		resw	1	; X coordinate position of CurrentPiece in GameBoard
_YPos		resw	1	; Y coordinate position of CurrentPiece in GameBoard
			 
_NumBlocks	resw	1	; Number of blocks cleared
_Score		resw	1	; Current score
_Level		resb	1	; Game Level

_MouseSeg	resw	1       ; real mode segment for MouseCallback
_MouseOff	resw	1	; real mode offset for MouseCallback
_MouseX		resw	1       ; X coordinate position of mouse on screen
_MouseY		resw	1       ; Y coordinate position of mouse on screen

_TimerTick	resd	1       ; variable to keep track of each tick of the timer
_MoveDownTime	resd	1	; variable to keep track of time at which piece moves down
_GameFlags      resb	1     	; Flags used in game
				; Bit 0 - User Exit Flag 
				; Bit 1 - Piece cannot move down anymore flag
				; Bit 2 - End of Game Flag
                                ; Bits 3 & 4 - Direction bits for MovePiece()
				; Encoding:
				;  00 - Do Not Move
				;  01 - Move Right
				;  10 - Move Left
				;  11 - Move Down
				; Bit 5 - Rotate Piece Flag
				; Bit 6 - Enable flag for mouse
				; Bit 7 - Flag to denote change in mouse status
				;         (enabled->disabled or vice-versa)

	SECTION .data
	
; Required image files
_BlocksFN	db	'blocks.png',0   
_FontFN		db	'font.png',0   

_Pieces		db	0h, 0h, 0h, 0h	; 4 X 4 x 7 Array of Pieces
		db	1h, 1h, 1h, 0h
		db	0h, 0h, 1h, 0h
		db	0h, 0h, 0h, 0h

		db	0h, 0h, 0h, 0h
		db	0h, 1h, 1h, 1h
		db	0h, 1h, 0h, 0h
		db	0h, 0h, 0h, 0h

		db	0h, 0h, 0h, 0h
		db	0h, 1h, 1h, 0h
		db	1h, 1h, 0h, 0h
		db	0h, 0h, 0h, 0h

		db	0h, 0h, 0h, 0h
		db	0h, 1h, 1h, 0h
		db	0h, 0h, 1h, 1h
		db	0h, 0h, 0h, 0h

		db	0h, 0h, 0h, 0h
		db	0h, 1h, 1h, 0h
		db	0h, 1h, 1h, 0h	      
		db	0h, 0h, 0h, 0h

		db	0h, 0h, 0h, 0h
		db	1h, 1h, 1h, 0h
		db	0h, 1h, 0h, 0h
		db	0h, 0h, 0h, 0h

		db	0h, 0h, 0h, 0h
		db	1h, 1h, 1h, 1h
		db	0h, 0h, 0h, 0h 
		db	0h, 0h, 0h, 0h

_GameBoard	times 16 db 0h      	; 16 x 24 Array representing game board
		times 16 db 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h 
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h, 1h
		times 12 db 0h
		db 	1h, 0h
		db	0h
		times 14 db 1h
		db 	0h
		times 16 db 0h

; Lookup table of relative offsets of neighboring pieces
_BlockPosArray	db	-16, 16, -15, 15, -1, 1, -17, 17

; Text strings used in the game
_GameString	db	' Gravity Blocks         MP4 Spring 2004','$'
_BlockString	db	'Blocks:','$'
_ScoreString	db	'Score:','$'
_LevelString	db	'Level:','$'
_MouseString	db	'Mouse:','$'
_DisabledString	db	'Disabled','$'
_EnabledString	db	'Enabled','$'
_InfoString1	db	' Use keyboard arrows','$'
_InfoString2	db	'  and mouse to move','$'
_InfoString3	db	'  and rotate pieces','$'
_GameOverString db	'GAME OVER','$'
_binascBuffer	db	'       ','$'

; Defined color values
_ColorGray	dd	00999999h
_ColorBlue	dd	000066cch     
_ColorWhite	dd	00ffffffh
_ColorYellow	dd	00cccc00h

	SECTION .text

; Program Start
_main
	call	_LibInit

	; Allocate Back Image buffer
	invoke	_AllocMem, dword 640*480*4
	cmp	eax, -1
	je	near .quit
	mov	[_ScreenOff], eax

	; Allocate Blocks Image buffer
	invoke	_AllocMem, dword 7*20*20*4
	cmp	eax, -1
	je	near .quit
	mov	[_BlocksOff], eax

	; Allocate Font Image buffer
	invoke	_AllocMem, dword 2048*16*4
	cmp	eax, -1
	je	near .quit
	mov	[_FontOff], eax

	; Load blocks and font files
	invoke	_LoadPNG, dword _BlocksFN, dword [_BlocksOff], dword 0, dword 0
	invoke	_LoadPNG, dword _FontFN, dword [_FontOff], dword 0, dword 0
 
	; Graphics init
	invoke	_InitGraphics, dword _kbINT, dword _kbIRQ, dword _kbPort
	test	eax, eax
	jnz	near .graphicserror

	; Find graphics mode: 640x480x32, allow driver-emulated modes
	invoke	_FindGraphicsMode, word 640, word 480, word 32, dword 1
	mov	[_GraphicsMode], ax

	; Mouse/Keyboard/Timer init
	call	_InstallTimer
	call	_InstallKeyboard
	invoke	_SetGraphicsMode, word [_GraphicsMode]
	call	_InstallMouse
	test	eax, eax
	jnz	.mouseerror

	; Show mouse cursor	
	mov	dword [DPMI_EAX], 01h
	mov	bx, 33h
	call	DPMI_Int

	; Randomly set seed based on system time
	mov	ah, 2ch
	int	21h
	xor	ax, ax
	mov	al, dl
	mov	[_seed], ax

	call	_MP4Main	

	; Shutdown and cleanup

.mouseerror
	call	_RemoveMouse
	call	_UnsetGraphicsMode
	call	_RemoveKeyboard
	call	_RemoveTimer

.graphicserror
	call	_ExitGraphics

.quit
	call	_LibExit
	call	MP4LibExit
	ret




;--------------------------------------------------------------
;--          Replace Library Calls with your Code!           --
;--          Do not forget to add Function Headers           --
;--------------------------------------------------------------





;--------------------------------------------------------------
;--                        Initialize()                      --
;--------------------------------------------------------------
_Initialize
	call	_libInitialize
	ret

;--------------------------------------------------------------
;--                       GetNextPiece()                     --
;--------------------------------------------------------------
_GetNextPiece	
	call	_libGetNextPiece
	ret

;--------------------------------------------------------------
;--                      MovePiece()                         --
;--------------------------------------------------------------
_MovePiece	
	call	_libMovePiece
	ret

;--------------------------------------------------------------
;--                     RotatePieceCW()                      --
;--------------------------------------------------------------
_RotatePieceCW	
	call	_libRotatePieceCW
	ret

;--------------------------------------------------------------
;--                  CheckPieceCollision()                   --
;--------------------------------------------------------------
_CheckPieceCollision
	call	_libCheckPieceCollision
	ret

;--------------------------------------------------------------
;--                   PutPieceOnBoard()                      --
;--------------------------------------------------------------
_PutPieceOnBoard	
	call	_libPutPieceOnBoard
	ret

;-------------------------------------------------------------
;--                       MarkBlocks()                      --
;-------------------------------------------------------------
_MarkBlocks	
	call	_libMarkBlocks
	ret

;-------------------------------------------------------------
;--                      ClearBlocks()                      --
;-------------------------------------------------------------
_ClearBlocks	
	call	_libClearBlocks
	ret

;-------------------------------------------------------------
;--                    ClearAllBlocks()                     --
;-------------------------------------------------------------
_ClearAllBlocks	
	call	_libClearAllBlocks
	ret
	
;-------------------------------------------------------------
;--                       DropBlocks()                      --
;-------------------------------------------------------------
_DropBlocks	
	call	_libDropBlocks
	ret

;-------------------------------------------------------------
;--                      UpdateStats()                      --
;-------------------------------------------------------------
proc _UpdateStats
.NumBlocks	arg	2
.SequenceNum	arg	2
	invoke	_libUpdateStats, word [ebp+.NumBlocks], word [ebp+.SequenceNum]
	ret

endproc
_UpdateStats_arglen	EQU	4

;-------------------------------------------------------------
;--                          Delay()                        --
;-------------------------------------------------------------
proc _Delay
.NumTicks	arg	4
	invoke	_libDelay, dword [ebp+.NumTicks]
	ret

endproc
_Delay_arglen	EQU	4

;--------------------------------------------------------------
;--                       ClearScreen()                      --
;--------------------------------------------------------------
proc _ClearScreen
.DestImage	arg	4
	invoke	_libClearScreen, dword [ebp+.DestImage]
	ret

endproc
_ClearScreen_arglen	EQU	4

;--------------------------------------------------------------
;--                         DrawBlock()                      --
;--------------------------------------------------------------
proc _DrawBlock
.BlockNum	arg	4
.DestImage	arg	4
.DestOffset	arg	4
	invoke	_libDrawBlock, dword [ebp+.BlockNum], dword [ebp+.DestImage], dword [ebp+.DestOffset]
	ret

endproc
_DrawBlock_arglen	EQU	12

;--------------------------------------------------------------
;--                     DrawGameBoard()                      --
;--------------------------------------------------------------
proc _DrawGameBoard
.DestImage	arg	4
.DestOffset	arg	4
	invoke	_libDrawGameBoard, dword [ebp+.DestImage], dword [ebp+.DestOffset]
	ret

endproc
_DrawGameBoard_arglen	EQU	8

;--------------------------------------------------------------
;--                    DrawCurrentPiece()                    --
;--------------------------------------------------------------
proc _DrawCurrentPiece
.DestImage	arg	4
.DestOffset	arg	4
.YPos		arg	2
.XPos		arg	2
	invoke	_libDrawCurrentPiece, dword [ebp+.DestImage], dword [ebp+.DestOffset], word [ebp+.YPos], word [ebp+.XPos]
	ret

endproc
_DrawCurrentPiece_arglen	EQU	12

;--------------------------------------------------------------
;--                        DrawText()                        --
;--------------------------------------------------------------
proc _DrawText
.StringOffset	arg	4
.DestImage	arg	4
.DestOffset	arg	4
.Color		arg	4
	invoke	_libDrawText, dword [ebp+.StringOffset], dword [ebp+.DestImage], dword [ebp+.DestOffset], dword [ebp+.Color]
	ret

endproc
_DrawText_arglen	EQU	16

;--------------------------------------------------------------
;--                      AlphaCompose()                      --
;--------------------------------------------------------------
proc _AlphaCompose
.Pixel		arg	4
	invoke	_libAlphaCompose, dword [ebp+.Pixel]
	ret

endproc
_AlphaCompose_arglen	EQU	4

;--------------------------------------------------------------
;--                        InstallKeyboard()                 --
;--------------------------------------------------------------
_InstallKeyboard
        call	_libInstallKeyboard
	ret

;--------------------------------------------------------------
;--                        RemoveKeyboard()                  --
;--------------------------------------------------------------
_RemoveKeyboard
	call	_libRemoveKeyboard
	ret

;--------------------------------------------------------------
;--                        KeyboardISR()                     --
;--------------------------------------------------------------
_KeyboardISR
	call	_libKeyboardISR
	ret

_KeyboardISR_end

;--------------------------------------------------------------
;--                        InstallMouse()                    --
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

;--------------------------------------------------------------
;--                    SetMousePos()                         --
;--------------------------------------------------------------
_SetMousePos
	call	_libSetMousePos
	ret

;--------------------------------------------------------------
;--                 UpdateMouseVisibility()                  --
;--------------------------------------------------------------
_UpdateMouseVisibility
	call	_libUpdateMouseVisibility
	ret




;--------------------------------------------------------------
;--     Given Functions - You do not have to write them      --
;--------------------------------------------------------------




;--------------------------------------------------------------
;--                        MP4Main()                         --
;--------------------------------------------------------------
_MP4Main
	call	_Initialize
	
.MainGameLoop:
	test	byte [_GameFlags], 00000001b
	jnz	near .EndGameLoop

	mov	eax, [_MoveDownTime]
	mov	ebx, [_TimerTick]
	cmp	eax, ebx
	je	.TimerMove
	jmp	.CheckPlayerMove

.TimerMove
	mov	eax, 14
	movzx	ebx, byte [_Level]
	sub	eax, ebx
	cmp	eax, 4
	jge	.NoAdjustTime
	mov	eax, 4

.NoAdjustTime
	add	dword [_MoveDownTime], eax
	or	byte [_GameFlags], 00011000b

.CheckPlayerMove   	 
	call	_MovePiece
 	call	_RotatePieceCW
	call	_UpdateMouseVisibility
        
	test	byte [_GameFlags], 00000010b
	jz	near .MainGameLoop

	call	_ClearAllBlocks

	call	_GetNextPiece
	invoke	_DrawAll, dword 1
	call	_CheckPieceCollision
	test	eax, eax
        jz      near .MainGameLoop

	or	byte [_GameFlags], 00000100b

.EndGameLoop
	test	byte [_GameFlags], 00000001b
	jnz	.ExitGame

.GameOverLoop
	test	byte [_GameFlags], 00000001b
	jnz	.ExitGame

	invoke	_DrawAll, dword 1
	jmp	.GameOverLoop

.ExitGame
	ret

;--------------------------------------------------------------
;--                      InstallTimer()                      --
;--------------------------------------------------------------
_InstallTimer
        invoke  _LockArea, ds, dword _TimerTick, dword 4
        invoke  _LockArea, cs, dword _TimerISR, dword _TimerISR_end-_TimerISR
	invoke	_Install_Int, dword 8, dword _TimerISR
	ret

;--------------------------------------------------------------
;--                      RemoveTimer()                       --
;--------------------------------------------------------------
_RemoveTimer
	invoke	_Remove_Int, dword 8
	ret

;--------------------------------------------------------------
;--                        TimerISR()                        --
;--------------------------------------------------------------
_TimerISR
	inc	dword [_TimerTick]
	mov	eax, 1
	ret
_TimerISR_end

;--------------------------------------------------------------
;--                         DrawAll()                        --
;--------------------------------------------------------------
proc _DrawAll
.DCPFlag	arg	4
	push	esi
	push	edi
	
	invoke	_ClearScreen, dword [_ScreenOff]

	invoke	_DrawGameBoard, dword [_ScreenOff], dword 16*20*4

	invoke	_DrawText, dword _GameString, dword [_ScreenOff], dword 5*640*4, dword [_ColorBlue]

	invoke	_DrawText, dword _InfoString1, dword [_ScreenOff], dword 335*640*4, dword [_ColorGray]
	invoke	_DrawText, dword _InfoString2, dword [_ScreenOff], dword 360*640*4, dword [_ColorGray]
	invoke	_DrawText, dword _InfoString3, dword [_ScreenOff], dword 385*640*4, dword [_ColorGray]

	cmp	dword [ebp+.DCPFlag], 0
	je	.NoDrawCP
	invoke	_DrawCurrentPiece, dword [_ScreenOff], dword 16*20*4, word [_YPos], word [_XPos]

.NoDrawCP

	mov	ax, [_NumBlocks]
	mov	ebx, _binascBuffer
	call	BinAsc
	invoke	_DrawText, ebx, dword [_ScreenOff], dword (100*640+160)*4, dword [_ColorWhite]
	invoke	_DrawText, dword _BlockString, dword [_ScreenOff], dword (100*640+40)*4, dword [_ColorWhite]
						    

	mov	ax, [_Score]
	mov	ebx, _binascBuffer
	call	BinAsc
	invoke	_DrawText, ebx, dword [_ScreenOff], dword (150*640+160)*4, dword [_ColorWhite]
	invoke	_DrawText, dword _ScoreString, dword [_ScreenOff], dword (150*640+40)*4, dword [_ColorWhite]

   	movzx	ax, byte [_Level]
	mov	ebx, _binascBuffer
	call	BinAsc
	invoke	_DrawText, ebx, dword [_ScreenOff], dword (200*640+160)*4, dword [_ColorWhite]
	invoke	_DrawText, dword _LevelString, dword [_ScreenOff], dword (200*640+40)*4, dword [_ColorWhite]


	invoke	_DrawText, dword _MouseString, dword [_ScreenOff], dword (250*640+40)*4, dword [_ColorWhite]

	test	byte [_GameFlags], 01000000b
	jnz	.DrawEnabled
	invoke	_DrawText, dword _DisabledString, dword [_ScreenOff], dword (250*640+160)*4, dword [_ColorWhite]
	jmp	.TestGameOver

.DrawEnabled
	invoke	_DrawText, dword _EnabledString, dword [_ScreenOff], dword (250*640+160)*4, dword [_ColorWhite]

.TestGameOver	
	test	byte [_GameFlags], 00000100b
	jz	.RefreshScreen

	invoke	_DrawText, dword _GameOverString, dword [_ScreenOff], dword (295*640+95)*4, dword [_ColorYellow]

.RefreshScreen
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	
	pop	edi
	pop	esi
	ret
endproc
_DrawAll_arglen		EQU	4

;--------------------------------------------------------------
;--                         Random()                         --
;--------------------------------------------------------------
proc _Random
.MaxNum		arg	2

        mov     ax, word [_seed]
        mov     bx, 37549                                                     

        mul     bx
        add     ax, 37747
        adc     dx, 0
        mov     bx, 65535
        div     bx
        mov     ax, dx    
 	mov     word [_seed], dx

        xor     dx, dx
	mov	cx, [ebp+.MaxNum]
        div     cx
        mov     ax, dx

        ret
endproc
_Random_arglen		EQU	2
