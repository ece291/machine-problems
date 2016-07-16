        PAGE 75, 132
        TITLE   MP3:MAZE   Your Name   Date

; ================ Constants / Definitions / MACROs =====================

INCLUDE maze.def

; ================== PUBLIC Variables & Procedures ======================

; LIB291 Routines
EXTRN   DOSXIT:near, KBDIN:near, BINASC:near, DSPMSG:near;

; External Routines (called from C)
PUBLIC _FXIT, _MazeManual, _ShowMaze

; Public variables (used by C Program and libmp3)
PUBLIC _POS, _MAZE

; Public variables (used by libmp3)
PUBLIC Movement, mazemode, mazedelay

; =================== External Library Procedures =======================

; LIBMP3 Routines (Comment these out as your write your own code)

EXTRN ShowMaze:near
EXTRN ShowMode:near
EXTRN UpdateTextScreen:near
EXTRN Adv:near
EXTRN AutoAdv:near
EXTRN AutoSolve:near

EXTRN ShowLibUse:near ; (called at the end of the program)

; ============================ Program Data =============================

CSEG    segment public             
        assume  cs:CSEG  ,ds:CSEG

; ============================= Variables ===============================

; The values of _MAZE and _POS are read in by the C program
_MAZE db MAZESIZE dup ('M')
_POS  dw 0

; By default, Start in Manual Mode
mazemode  db 0

; Default Delay Period
mazedelay db 16

; Movement Offsets for fast table-lookup operation
movement dw -80,+1,+80,-1

; ================= Procedures (Your code goes here) ====================

; ShowMaze PROC NEAR

;    Purpose: (1) Draw initial Maze on screen,
;             (2) Show initial Position of mouse (Smiley Character)
;  Variables: _MAZE, _POS, mazemode, mazedelay (no variables modified)

; ShowMaze ENDP

; ------------------------------------------------------------------------


; ShowMode PROC NEAR

; ShowMode ENDP

; ------------------------------------------------------------------------

; Adv PROC NEAR

; Adv ENDP

; ------------------------------------------------------------------------

; UpdateTextScreen PROC NEAR

; UpdateTextScreen ENDP


; ------------------------------------------------------------------------

; AutoAdv PROC NEAR
           
; AutoAdv ENDP

; ------------------------------------------------------------------------

; AutoSolve PROC NEAR

; AutoSolve ENDP


; ============================== Free Code ==============================

_ShowMaze PROC FAR
;    Purpose: (1) Draw initial Maze on screen,
;             (2) Show initial Position of mouse (Smiley Character)
;             (3) Show initial Mode
;  Variables: _MAZE, _POS, mazemode, mazedelay (no variables modified)

           PUSH DS
           PUSH ES

           MOV AX,CS       ; Our DS=CS
           MOV DS,AX

           MOV AX,VIDSEG   ; Use ES=Video Segment
           MOV ES,AX

           Call ShowMaze   ; Display original maze and mouse on screen

           Call ShowMode   ; Display mazemode and mazedelay values on screen

           POP  ES
           POP  DS
           RET

_ShowMaze ENDP

; ------------------------------------------------------------------------

_MazeManual PROC FAR

;   Purpose: Main Program (Called from C and calls to all other routines)
;            Interactively allows user to traverse maze and run AutoSolve
; Variables: _MAZE, mazemode, mazedelay
;     Input: From keyboard
;    Output: None. Preserves ALL registers (else the C program WILL crash)


           PUSH DS
           PUSH ES
           PUSH SI
           PUSH DI
           PUSH BX

           MOV AX,CS       ; Our DS=CS
           MOV DS,AX

           MOV AX,VIDSEG   ; Use ES=Video Segment
           MOV ES,AX

MMLoop:    Call KBDIN

           CMP AL,'Q'
           JE MMDone
           CMP AL,'q'
           JE MMDone

           CMP AL,NORTHKEY
           JE MMNorth
           CMP AL,SOUTHKEY
           JE MMSouth
           CMP AL,WESTKEY
           JE MMWest
           CMP AL,EASTKEY
           JE MMEast
           CMP AL,'M'
           JE MMode
           CMP AL,'m'
           JE MMode
           CMP AL,'+'
           JE MMSlower
           CMP AL,'-'
           JE MMFaster

           JMP MMLoop

; Check for Keyboard Arrow Keys (up, down, left, right)

MMNorth:   MOV AL,NORTH
           JMP MMArrow

MMSouth:   MOV AL,SOUTH
           JMP MMArrow

MMWest:    MOV AL,WEST
           JMP MMArrow

MMEast:    MOV AL,EAST
           JMP MMArrow

; Set Game Mode ('M0','M1','M2','M3')

MMode:     Call KBDIN
           CMP AL,'0'
           JB MMLoop
           CMP AL,'3'
           JA MMLoop
           SUB AL,'0'
           MOV mazemode,AL
           Call ShowMode
           JMP MMLoop

; Control Interactive Speed (Smaller Mazedelay==Faster)

MMFaster:  DEC mazedelay
           Call ShowMode
           JMP MMLoop

MMSlower:  INC mazedelay
           Call Showmode
           JMP MMLoop

MMArrow:   CMP mazemode,3
           JE MMASolve

           CMP mazemode,2
           JE MMAutoAdv


MMAdv:     Call Adv
           Call UpdateTextScreen

           CMP mazemode,0
           JE MMLoop

           CMP _MAZE[DI],HALL
           JNE MMLoop

           CMP AH,1
           JE  MMLoop 

           Call delay
           JMP MMAdv

MMAutoAdv: Call AutoAdv
           JMP MMLoop
MMASolve:  Call AutoSolve
           JMP MMLoop
         
MMDone:    Call ShowLibUse

           MOV AX,0  ; Return value
           POP  BX
           POP  DI
           POP  SI
           POP  ES
           POP  DS
           RET
_MazeManual ENDP

; ------------------------------------------------------------------------

Delay PROC NEAR

; Purpose: Burn CPU cycles between movements
;  Inputs: variable mazedelay (0..255) - Delay constant
; Outputs: None - All Registers Preserved
;   Notes: There is no need to modify this code (it is given for free)

           CMP mazedelay,0
           JE DLoopNone
           PUSH CX
           MOV CX,0FFFFh
DLoop:     PUSH CX
           MOV CH,0
           MOV CL,mazedelay
DLoop2:    NOP
           LOOP DLoop2
           POP CX
           LOOP DLoop
           POP CX
DLoopNone: ret
Delay ENDP

; ------------------------------------------------------------------------

_FXIT PROC FAR

; Purpose: Terminate program and return to DOS.
;          This should be the Last function called by the C program
;   Notes: There is no need to modify this code (it is given for free)

  CALL DOSXIT

_FXIT ENDP


; ===================== End of Proceures & Data ==========================

CSEG    ends
        end 



