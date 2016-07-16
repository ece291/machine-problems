        PAGE 75, 132
        TITLE ECE291:MP3:Hanoi - Your Name - Date

COMMENT %
        The Bakery of Hanoi
        -------------------
        ECE291: Machine Problem 3
        Prof. John W. Lockwood
        Unversity of Illinois, Dept. of Electrical & Computer Engineering
        Spring 1997
        Documentation: http://www.ece.uiuc.edu/~ece291/mp/mp3/mp3.html
        Revision 1.0
        %

;====== Constants =========================================================

CR      EQU 13
LF      EQU 10
ESCKEY  EQU 27
SPACE   EQU 32

VIDTXTSEG EQU 0B800h  ; VGA Video Segment Adddress (Text Mode)

;====== Externals =========================================================

; -- LIB291 Routines (Free) ---
extrn kbdine:near, kbdin:near, dspout:near   ; LIB291 Routines
extrn dspmsg:near, binasc:near, ascbin:near  ; (Always Free)

; -- LIBMP3 Routines (You need to write these)
extrn MoveTier:near     ; Remove this line to use your own code
extrn DrawScreen:near   ; Remove this line to use your own code
extrn RedrawScreen:near ; Remove this line to use your own code
extrn ResetGame:near    ; Remove this line to use your own code
extrn Distribute:near   ; Remove this line to use your own code
extrn MouseCtrl:near    ; Remove this line to use your own code
extrn AutoSolve:near    ; Remove this line to use your own code
extrn MainLIB:near      ; Remove this line to use your own code

extrn mp3xit:near   

;====== Stack segment ====================================================
stkseg  segment stack                   ; *** STACK SEGMENT ***
        db      64 dup ('STACK   ')     ; 64*8 = 512 Bytes of Stack
stkseg  ends

;====== Code/Data segment ================================================
cseg    segment public                  ; *** CODE SEGMENT ***
        assume  cs:cseg, ds:cseg, ss:stkseg, es:nothing

;====== Variables =========================================================
Moves    DW  0 ; Number of moves required (Reset to zero for each game)
Tiers    DW  4 ; Number of Tiers (Default with 4 tiers)

Bakery DW 0000000000000001b ; -- Sample Bit-mapped array --
Truck  DW 0000000000000010b ;                       ###
Recept DW 0000000000001100b ; #########  #######   #####
                            ;   Bakery    Truck    Recept
                            ;   Dest=0    Dest=1   Dest=2

HanoiMsg db '  ECE291 MP3 ver 1.0        '
         db '  THE BAKERY OF HANOI          '
         db '  Lockwood Spr97','$'

RandSeed DW 13 ; Random Number Seed

PUBLIC HanoiMsg, Moves, Tiers, RandSeed, Bakery, Truck, Recept

;====== Main procedure ====================================================
main proc far
           mov     ax, cseg   ; Initialize DS register
           mov     ds, ax

           mov ax, VIDTXTSEG  ; Segment address of video memory
           mov es, ax

           mov AX, 0002h ; Set 80x25 text mode and clear screen
           int 10h

           mov tiers, 4    ; Start with Default of 4 Cake Tiers
           call Distribute ; Randomly distribute to bakery,truck,recept
           call DrawScreen ; Draw the text-mode video screen

           mov ax,0  ; init mouse
           int 33h  

           mov ax,1  ; Show Mouse
           int 33h

           ; -------------------------------------------
           ; Your MAIN code goes here
           ; -------------------------------------------
           Call MainLIB ; Replace this with your own code

           call    mp3xit ; Exit to DOS
main endp
 
cseg    ends
        end     main

