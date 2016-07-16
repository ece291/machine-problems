TITLE ECE291:MP3-Constants

COMMENT % TRON LiteCycle Game Constant Declarations
        %
        
;====== Constants =========================================================

;ASCII values for common characters
BEEP    EQU 7
CR      EQU 13
LF      EQU 10
ESCKEY  EQU 27
SPACE   EQU 32

;Player 1 keyboard control scan codes (not ASCII)
P1_U    EQU 17  ;'W'
P1_D    EQU 31  ;'S'
P1_L    EQU 30  ;'A'
P1_R    EQU 32  ;'D'

;Player 2 keyboard control scan codes (not ASCII)
P2_U    EQU 72  ;'8' on num. pad
P2_D    EQU 80  ;'2' "
P2_L    EQU 75  ;'4' "
P2_R    EQU 77  ;'6' "

;Constant values for specifying player direction
;  (used in variables p1NextDir and p2NextDir)
UP      EQU 0
DOWN    EQU 1
LEFT    EQU 2
RIGHT   EQU 3

;Constant values for use in Grid array
GRIDSPACE       EQU     0       ; a point with no walls
P1WALL          EQU     1       ; a point with a wall made by player 1
P2WALL          EQU     2       ; a point with a wall made by player 2
GRIDWALL        EQU     3       ; a point along the outside grid wallkk

;Dimension definitions
SCREENSIZE_X    EQU 80  ;Size of dos screen in x direction
SCREENSIZE_Y    EQU 50  ;Size of dos screen in y direction
GRIDSIZE_X      EQU 80  ;Size of game grid in x direction
GRIDSIZE_Y      EQU 49  ;Size of game grid in y direction

TEXTATTR        EQU 02h ;TxtVid attribute byte for game text
                        ;Currently green on black
GRIDATTR        EQU 01h ;TxtVid attribute byte for game grid
                        ;Currently blue on black
CRASHATTR       EQU 0Eh ;TxtVid attribute byte for crash symbol
                        ;Currently yellow on black
P1ATTR          EQU 79h ;TxtVid attribute byte for player 1 cycle & walls
P2ATTR          EQU 74h ;TxtVid attribute byte for player 2 cycle & walls

CRASHSYMBOL     EQU 0Fh ;ASCII value of symbol to draw at crash site.
PLAYERSYMBOL    EQU 0DBh;ASCII value of symbol to draw for player wall.       
