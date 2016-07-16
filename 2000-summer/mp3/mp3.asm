.MODEL SMALL
.386

PAGE    70, 140
TITLE   MP3 - [Text Mode Mine] - Your Name - Today's Date -

COMMENT *
        In this MP, you will write a text mode video
        version of the ever popular game, MineSweeper

        ECE291 - Machine Problem 3
        Professor Josh Potts
        Guest Authors - Michael Urman and Karan Mehra
        University of Illinois at Urbana Champaign
        Dept. of Electrical & Computer Engineering
        Summer 2000

        Ver 1.0
        *

;--------------------------------------------------------------
;--                   Defining  Constants                    --
;--------------------------------------------------------------

        CR              EQU 0dh
        LF              EQU 0ah
        ESCKEY          EQU 01bh

        MODE_BEGINNER   EQU 0
        MODE_ADVANCED   EQU 1

        BEGINNER_COUNT  EQU 10
        ADVANCED_COUNT  EQU 90

        ADVANCED_GRID   EQU 30
        BEGINNER_GRID   EQU 10

        EMPTY           EQU 0
        REALMINE        EQU 16
        VISIBLE         EQU 32
        GUESS_MINE      EQU 64
        GUESS_MAYBE     EQU 128
        
        LBUTTON         EQU 4
        RBUTTON         EQU 16
        MBUTTON         EQU 20

        TEXT_SEG        EQU 0B800h
        PLAYFIELD_ATTR  EQU 0fh

        COVERED_CHAR    EQU ' '
        COVERED_ATTR    EQU 70h

        UNCOVERED_CHAR  EQU ' '
        UNCOVERED_ATTR  EQU 20h

        FLAG_CHAR       EQU 0E2h
        FLAG_ATTR       EQU 09h

        GUESS_CHAR      EQU '?'
        GUESS_ATTR      EQU 00h

        DIED_ATTR       EQU 40h
        NUMBER_ATTR     EQU 0Eh

        MINE_CHAR       EQU 0fh
        MINE_ATTR       EQU 00h

        MINES_POS       EQU 160*33+17*2
        MINES_ATTR      EQU 09h

        TIMER_POS       EQU 160*16+57*2
        TIME_ATTR       EQU 09h

        MAX_TIMER       EQU 999

        STATUS_POS      EQU 160*45+36*2
        STATUS_ATTR     EQU 09h

        public CR, LF, ESCKEY
        public MODE_BEGINNER, MODE_ADVANCED, BEGINNER_COUNT, ADVANCED_COUNT, ADVANCED_GRID, BEGINNER_GRID
        public EMPTY, REALMINE, VISIBLE, GUESS_MINE, GUESS_MAYBE
        public LBUTTON, RBUTTON, MBUTTON
        public TEXT_SEG, PLAYFIELD_ATTR, COVERED_CHAR, COVERED_ATTR, UNCOVERED_CHAR, UNCOVERED_ATTR
        public FLAG_CHAR, FLAG_ATTR, GUESS_CHAR, GUESS_ATTR, DIED_ATTR, NUMBER_ATTR, MINE_CHAR, MINE_ATTR
        public MINES_POS, MINES_ATTR, TIMER_POS, TIME_ATTR, MAX_TIMER, STATUS_POS, STATUS_ATTR

;--------------------------------------------------------------
;--               Declaring External Procedures              --
;--------------------------------------------------------------

;       Functions in LIB291.LIB These functions are free to 
;       be used by you. Complete descriptions of the LIB291
;       functions can be found in your lab manuals. Use these
;       functions for displaying output on the screen

        extrn dspmsg:near, dspout:near, ascbin:near
        extrn rrest:near, rsave:near, binasc:near, kbdin:near
        extrn dosxit:near

;       Functions in LIBMP3.LIB
;       You will need to write these functions for this program

        extrn libMakeField:near, libSeedRand:near, libResetScreen:near
        extrn libInstallTimer:near, libRemoveTimer:near, libTimerISR:far
        extrn libInstallMouse:near, libRemoveMouse:near, libMouseCallback:far
        extrn libDrawScreen:near, libHandleInput:near, libRevealSquares:near
        extrn libWinLose:near

;       This function terminates the program

        extrn mp3xit:near

;--------------------------------------------------------------
;--                Defining the Stack Segment                --
;--------------------------------------------------------------

stkseg SEGMENT stack
        db  64 dup ('-STACK- ')
stkseg ENDS

;--------------------------------------------------------------
;--                 Defining the Code Segment                --
;--------------------------------------------------------------

cseg SEGMENT PUBLIC 'CODE'
        assume cs:cseg, ds:cseg, ss:stkseg, es:nothing

;--------------------------------------------------------------
;--           Declaring variables for the Procedures         --
;--------------------------------------------------------------

PlayMode        db ?                    ; beginner or advanced
WhatMode        db 20 dup (CR,LF), 20 dup (' ')
                db 'Choose Mode: [B]eginner or [A]dvanced?','$'

Update          db 1                    ; update the screen if 1

MouseX          dw ?                    ; X of mouse at last click
MouseY          dw ?                    ; Y of mouse at last click
MouseClick      db 0                    ; Click has occurred

MineCount       dw 0
UncoveredCount  dw 0

Rand            dd 0

PlayField       db 80*8 dup (' ')
                db 31 dup (' '), 0c9h, 0b5h, 'Text Mode Mine', 0c6h, 0bbh, 31 dup (' ')
                db 24 dup (' '), 0c9h, 6 dup (0cdh), 0cah, 16 dup (0cdh), 0cah, 6 dup (0cdh), 0bbh, 24 dup (' ')
                db 04 dup (24 dup(' '), 0bah, 30 dup (' '), 0bah, 24 dup(' '))
                db 24 dup(' '), 0bah, 30 dup (' '), 0cch, 8 dup (0cdh), 0bbh, 15 dup(' ')
                db 03 dup (24 dup(' '), 0bah, 30 dup (' '), 0bah, 8 dup (' '), 0bah, 15 dup(' '))
                db 24 dup(' '), 0bah, 30 dup (' '), 0cch, 8 dup (0cdh), 0bch, 15 dup(' ')
                db 12 dup (24 dup(' '), 0bah, 30 dup (' '), 0bah, 24 dup(' '))
                db 15 dup(' '), 0c9h, 8 dup (0cdh), 0b9h, 30 dup (' '), 0bah, 24 dup(' ')
                db 03 dup (15 dup(' '), 0bah, 8 dup (' '), 0bah, 30 dup (' '), 0bah, 24 dup(' '))
                db 15 dup(' '), 0c8h, 8 dup (0cdh), 0b9h, 30 dup (' '), 0bah, 24 dup(' ')
                db 04 dup (24 dup(' '), 0bah, 30 dup (' '), 0bah, 24 dup(' '))
                db 24 dup (' '), 0c8h, 19 dup (0cdh), 0cbh, 9 dup (0cdh), 0cbh, 0bch, 24 dup (' ')
                db 44 dup (' '), 0c8h, 0b5h, 0e4h, 9bh, 0eeh, ' 291', 0c6h, 0bch, 25 dup (' ')
                db 80*8 dup (' ')

MineField       db 30*30 dup (EMPTY)

OldTimerV       dd ?

TimerTick       db 0
TimerSeconds    dw 0

WinString       db 'You Won!', '$'

LoseString      db 'You Lost', '$'

buffer          db 7 dup(?), '$'
                
public PlayMode, WhatMode, Update, MouseX, MouseY, MouseClick, MineCount, UncoveredCount
public Rand, PlayField, MineField, OldTimerV, TimerTick, TimerSeconds, WinString, LoseString, buffer
public SeedRand, GetRand, DrawScreen, RevealSquares, MouseCallback

;--------------------------------------------------------------
;--                       Main Procedure                     --
;--------------------------------------------------------------

MAIN PROC FAR
        mov     ax, cseg                ; Initialize ds <= cs
        mov     ds, ax

        ; Put display into 80x50 text mode
        mov     ax, 1202h               ; Sets to 400 line scan mode
        mov     bl, 30h
        int     10h

        mov     ax, 3                   ; Sets to 8x8 font
        int     10h

        mov     ax, 1112h               ; Enter text mode
        mov     bl, 0
        int     10h

        mov     dx, offset WhatMode
        call    dspmsg

        mov     playmode, MODE_ADVANCED

    getinput:
        call    kbdin

        cmp     al, 'A'                 ; Advanced mode on A or a
        je      startgame
        cmp     al, 'a'
        je      startgame

        cmp     al, 'B'                 ; Beginner mode on B or b
        je      beginner
        cmp     al, 'b'
        je      beginner

        cmp     al, ESCKEY              ; Exit on Escape Key
        je      mainexit

        jmp     getinput

    beginner:
        mov     playmode, MODE_BEGINNER

    startgame:
        mov     ax, 0101h               ; Hide cursor
        mov     cx, 2000h
        int     10h

        call    MakeField               ; Initialize the mine array
        call    ResetScreen

        call    InstallTimer
        call    InstallMouse

    playloop:
        mov     ah, 01h                 ; Non-blocking I/O call
        int     16h
        jz      playcontinue

        call    kbdin                   ; Get key from keyboard
        
        cmp     al, ESCKEY
        je      playexit

    playcontinue:
        call    DrawScreen
        call    HandleInput

        cmp     ax, 0
        jg      playloop                ; Loop until player wins or loses

        call    WinLose

    playexit:
        call    RemoveMouse
        call    RemoveTimer

    mainexit:
        mov     ax, 03h                 ; Go back to 80x25 text mode
        int     10h

        call    mp3xit

MAIN ENDP

;--------------------------------------------------------------
;--             Replace Library Calls with your Code!        --
;--             [Save all reg values that you modify]        --
;--             Do not forget to add Function Headers        --
;--------------------------------------------------------------

;--------------------------------------------------------------
;--                       MakeField                          --
;--------------------------------------------------------------
MakeField PROC NEAR

        call    libMakeField
        ret

MakeField ENDP

;--------------------------------------------------------------
;--                        SeedRand                          --
;--------------------------------------------------------------
SeedRand PROC NEAR

        call    libSeedRand
        ret

SeedRand ENDP

;--------------------------------------------------------------
;--                        GetRand                           --
;--                                                          --
;--      This procedure has been taken and modified from     --
;--http://rudeboy.webprovider.com/ -> asm source -> rand.zip --
;--------------------------------------------------------------
GetRand PROC NEAR

        push    ecx
        push    edx

        mov     eax, rand

        mov     ecx, 6255h
        imul    ecx             ; Signed multiply
        mov     ecx, 3619h
        add     eax, ecx        ; Add

        mov     rand, eax

        pop     edx
        pop     ecx
        ret

GetRand ENDP

;--------------------------------------------------------------
;--                      ResetScreen                         --
;--------------------------------------------------------------
ResetScreen PROC NEAR

        call    libResetScreen
        ret

ResetScreen ENDP

;--------------------------------------------------------------
;--                      InstallTimer                        --
;--------------------------------------------------------------
InstallTimer PROC NEAR

        call    libInstallTimer
        ret

InstallTimer ENDP

;--------------------------------------------------------------
;--                      RemoveTimer                         --
;--------------------------------------------------------------
RemoveTimer PROC NEAR

        call    libRemoveTimer
        ret

RemoveTimer ENDP

;--------------------------------------------------------------
;--                       TimerISR                           --
;--------------------------------------------------------------
TimerISR PROC FAR

TimerISR ENDP

;--------------------------------------------------------------
;--                     InstallMouse                         --
;--------------------------------------------------------------
InstallMouse PROC NEAR

        call    libInstallMouse
        ret

InstallMouse ENDP

;--------------------------------------------------------------
;--                     RemoveMouse                          --
;--------------------------------------------------------------
RemoveMouse PROC NEAR

        call    libRemoveMouse
        ret

RemoveMouse ENDP

;--------------------------------------------------------------
;--                    MouseCallback                         --
;--------------------------------------------------------------
MouseCallback PROC FAR

        call    libMouseCallback
        ret

MouseCallback ENDP

;--------------------------------------------------------------
;--                     DrawScreen                           --
;--------------------------------------------------------------
DrawScreen PROC NEAR

        call    libDrawScreen
        ret

DrawScreen ENDP
                         
;--------------------------------------------------------------
;--                    HandleInput                           --
;--------------------------------------------------------------
HandleInput PROC NEAR

        call    libHandleInput
        ret

HandleInput ENDP

;--------------------------------------------------------------
;--                  RevealSquares                           --
;--------------------------------------------------------------
RevealSquares PROC NEAR

        call    libRevealSquares
        ret

RevealSquares ENDP

;--------------------------------------------------------------
;--                     WinLose                              --
;--------------------------------------------------------------
WinLose PROC NEAR

        call    libWinLose
        ret

WinLose ENDP

CSEG ENDS
     END    MAIN

