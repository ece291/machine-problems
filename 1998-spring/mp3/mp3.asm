        PAGE 75, 132
        TITLE   MP3:15-Puzzle   Your_Name_Here          Date

COMMENT *
        The 15-Puzzle

        ECE291: Machine Problem 3
        Spring 1998 / Lockwood
        Guest MP Author: Daniel Restelli
        University of Illinois,
        Dept. of Electrical & Computer Engineering

        Ver 1.0
        *

; =================== External Library Procedures =======================

        ; LIB291 Routines -- Use these for free
          EXTRN DOSXIT:NEAR
          EXTRN RSAVE:NEAR
          EXTRN RREST:NEAR
          EXTRN KBDIN:NEAR
          EXTRN BINASC:NEAR

          EXTRN MP3XIT:NEAR

        ; LIBMP3 routines -- Comment out and replace with your own code!
          EXTRN MouseControl:NEAR
          EXTRN ResetBoard:NEAR
          EXTRN Shuffle:NEAR
          EXTRN MoveHole:NEAR
          EXTRN DrawBoard:NEAR
          EXTRN UpdateScreen:NEAR
          EXTRN Delay:NEAR
          EXTRN Random:NEAR
          EXTRN AutoSolve:NEAR
          EXTRN DrawTile:NEAR
          EXTRN CheckMove:NEAR


; ============================ Stack Segment ============================

stkseg    segment stack
          db   128 dup ('STACK   ')
stkseg    ends

; ============================ Program Data =============================

CSEG      segment public 'CODE'
          assume  cs:CSEG, ds:CSEG, ss:stkseg, es:nothing

; ============================= Variables ===============================

TEXTVIDSEG EQU  0b800h


; == Use these constants in your code, if you change them,
; == your code will not work properly with the library code

BOARDSTART     EQU 980        ; Starting offset of the playing board
TILEWIDTH      EQU 10         ; Width of tiles
TILEHEIGHT     EQU 9          ; Height of tiles
BOARDDIM       EQU 4          ; Dimension of board (4x4)

SHUFFAMOUNT    EQU 200        ; When shuffling board, how many moves to make

ButtonWidth    EQU 16         ; The width of the control panel buttons

MAXDELAY       EQU 20
MINDELAY       EQU 1

; == These are the values corresponding to the different buttons
TileClicked    EQU 0          ; A tile was clicked
ShuffleClk     EQU 1          ; The Shuffle button was clicked
SolveClk       EQU 2          ; The Solve button was clicked
SolveOnceClk   EQU 3          ; The Solve Once button was clicked
DelayUpClk     EQU 4          ; The > Delay button was clicked
DelayDownClk   EQU 5          ; The < Delay button was clicked
QuitClk        EQU 6          ; The Quit button was clicked
ResetClk       EQU 7          ; The Reset button was clicked

; == These are the starting offsets of the different buttons
ShuffleLoc     EQU 2034
SolveLoc       EQU 2514
SolveOnceLoc   EQU 2994
DelayUpLoc     EQU 3480
DelayDownLoc   EQU 3474
QuitLoc        EQU 4274
ResetLoc       EQU 1554

PUBLIC Board, HolePtr, randval, delayc, Moves, MovesPushed

Board     db   01,02,03,04    ; This simple array keeps track of the state
          db   05,06,07,08    ; of the board
          db   09,10,11,12
          db   13,14,15,00
HolePtr   dw   15             ; The location of the hole


; == This is a lookup table of the starting offsets of each tile
; == location in the board.  

BoardLoc  dw   BOARDSTART+0*160*TILEHEIGHT+0*2*TILEWIDTH
          dw   BOARDSTART+0*160*TILEHEIGHT+1*2*TILEWIDTH
          dw   BOARDSTART+0*160*TILEHEIGHT+2*2*TILEWIDTH
          dw   BOARDSTART+0*160*TILEHEIGHT+3*2*TILEWIDTH
          dw   BOARDSTART+1*160*TILEHEIGHT+0*2*TILEWIDTH
          dw   BOARDSTART+1*160*TILEHEIGHT+1*2*TILEWIDTH
          dw   BOARDSTART+1*160*TILEHEIGHT+2*2*TILEWIDTH
          dw   BOARDSTART+1*160*TILEHEIGHT+3*2*TILEWIDTH
          dw   BOARDSTART+2*160*TILEHEIGHT+0*2*TILEWIDTH
          dw   BOARDSTART+2*160*TILEHEIGHT+1*2*TILEWIDTH
          dw   BOARDSTART+2*160*TILEHEIGHT+2*2*TILEWIDTH
          dw   BOARDSTART+2*160*TILEHEIGHT+3*2*TILEWIDTH
          dw   BOARDSTART+3*160*TILEHEIGHT+0*2*TILEWIDTH
          dw   BOARDSTART+3*160*TILEHEIGHT+1*2*TILEWIDTH
          dw   BOARDSTART+3*160*TILEHEIGHT+2*2*TILEWIDTH
          dw   BOARDSTART+3*160*TILEHEIGHT+3*2*TILEWIDTH

; == How might you use these tables to simplify your code?
SlideDir  dw   -160, 2, 160, -2
SlideLen  dw   TILEHEIGHT, TILEWIDTH, TILEHEIGHT, TILEWIDTH
PointDir  dw   -4, 1, 4, -1


randval        dw   3         ; random # generator seed
delayc         db   3         ; delay constant
Moves          dw   0         ; # of moves made
MovesPushed    dw   0         ; # of moves currently on the stack
                              

; ========================== Your Subroutines ==========================

; Uncomment and add your own code here


;MouseControl PROC NEAR
;
;               RET
;MouseControl ENDP


;ResetBoard PROC NEAR
;
;               RET
;ResetBoard ENDP


;Shuffle PROC NEAR
;
;               RET
;Shuffle ENDP


;MoveHole PROC NEAR
;
;               RET
;MoveHole ENDP


;DrawBoard PROC NEAR
;
;               RET
;DrawBoard ENDP


;UpdateScreen PROC NEAR
;
;               RET
;UpdateScreen ENDP


;Delay PROC NEAR
;
;               RET
;Delay ENDP


;Random PROC NEAR
;
;               RET
;random  endp


;AutoSolve PROC NEAR
;
;               RET
;AutoSolve ENDP


;DrawTile Proc NEAR
;
;               RET
;DrawTile ENDP


;CheckMove PROC NEAR
;
;               RET
;CheckMove ENDP





; == Main ================================================================

MAIN Proc FAR

; Initialize DS register
          MOV  AX, CSEG
          MOV  DS, AX

; Put display into 80x50 text mode
          MOV  AX, 1202h                ; Sets to 400 line scan mode
          MOV  BL, 30h
          int  10h
          MOV  AX, 3                    ; Sets to 8x8 font
          INT  10h
          MOV  AX, 1112h                ; Enter text mode
          MOV  BL, 0
          INT  10h

; Initialize the mouse hardware, Function 0000h
          MOV  AX, 0000h
          INT  33h
; Display the mouse cursor, Function 0001h
          MOV  AX, 0001h
          INT  33h

; The Main Program Code
          CALL DrawBoard
          CALL UpdateScreen

MainLoop:
          CALL MouseControl


          CMP  DX, TileClicked
          JNE  @F
               CALL CheckMove
               JMP  MainLoop
@@:       CMP  DX, ResetClk
          JNE  @F
               CALL ResetBoard
               JMP  MainLoop
@@:       CMP  DX, ShuffleClk
          JNE  @F
               CALL ResetBoard
               CALL Shuffle
               JMP  MainLoop
@@:       CMP  DX, SolveClk
          JNE  @F
               MOV  AX, 0
               CALL Autosolve
               JMP  MainLoop
@@:       CMP  DX,  SolveOnceClk
          JNE  @F
               MOV  AX, 1
               CALL AutoSolve
               JMP  MainLoop
@@:       CMP  DX,  DelayUpClk
          JNE @F
               CMP  DelayC, MAXDELAY
               JNL  MainLoop
               INC  DelayC
               CALL UpdateScreen
               JMP  MainLoop
@@:       CMP  DX, DelayDownClk
          JNE  @F
               CMP  DelayC, MINDELAY
               JNG  MainLoop
               DEC  DelayC
               CALL UpdateScreen
               JMP  MainLoop
@@:       CMP  DX, QuitClk
          JNE  MainLoop


; Put display into 80x50 text mode (to reset the screen)
EndIt:    MOV  AX, 1202h
          MOV  BL, 30h
          int  10h
          MOV  AX, 3
          INT  10h
          MOV  AX, 1112h
          MOV  BL, 0
          INT  10h

          CALL MP3Xit
MAIN ENDP

; ===================== End of Proceures & Data ==========================

CSEG    ends
        end    main



