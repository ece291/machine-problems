TITLE ECE291:MP4-ZBuffer - Your Name - Date

.MODEL LARGE   ; Allow multiple segments to be defined
.486           ; Allow generation of code which requires an 80486 or better

COMMENT % Z-Buffer

          ECE291: Machine Problem 4
          Prof. John W. Lockwood
          University of Illinois
          Dept. of Electrical & Computer Engineering
          Fall 1998
          
          Ver. 1.1

          Revision History:
          1.0: - Initial release
          1.1: - Avoids infinite loop during benchmarking
               - Library Procedure names prefixed with "lib" to fix link error.
        %



;====== Constants =========================================================

VIDSEG     EQU 0A000h      ; VGA Video Segment Adddress
VIDTEXTSEG EQU 0B800h
CR         EQU 13
LF         EQU 10


KeyPrompt MACRO            ; Optionally wait for user key press
          Local KPEnd
          cmp KeyWait,0    ; KeyWait=0 : No pause
          JE KPEnd         ; KeyWait=1 : Wait for key press
          call kbdin
KPEnd:
ENDM


;====== Segments ==========================================================

PUBLIC ScreenBuffer, ZBuffer, FontMap, Scratchpad
PUBLIC LoadPCX

SBSeg segment 'DATA1'
    ScreenBuffer DB 65535 dup(?)
SBSeg ENDS

ZBSeg segment 'DATA2'
    ZBuffer DB 65535 dup (?)
ZBSeg ENDS

FontSeg segment 'DATA3'
    Fontmap DB 65535 dup (?)
FontSeg ENDS

ScrSeg segment 'DATA4' ; Used by LoadPCX
    Scratchpad DB 65535 dup(?)
ScrSeg ENDS
        
stkseg  segment stack                   ; *** STACK SEGMENT ***
        db      128 dup ('STACK   ')     ; 128*8 = 1024 Bytes of Stack
stkseg  ends

;====== Function type declarations ========================================

extrn kbdin:near                   ; LIB291 routines are always Free
extrn SetStart:near                ; Start Routine
extrn mp4xit:near                  ; Exit Routine

extrn LibLoadPCX:near              ; Load PCX file

LibModeGraph       PROTO near C    ; Switch video mode to graphics (Given)

LibModeText        PROTO near C    ; Switch video mode to text (Given)

LibInitBuf         PROTO near C    ; Initialize ZBuffer

LibDrawScreen      PROTO near C    ; Transfer ZBuffer contents to VRAM

LibDrawPoint       PROTO near C X:word, Y:word, Z:byte, Color:byte

LibDrawText        PROTO near C X:word, Y:word, Z:byte,
                                Color:byte

LibDrawRect        PROTO near C X:word, Y:word, Z:byte,
                                W:word, H:word,
                                Color:byte

LibDrawTriangle    PROTO near C X1:word, Y1:word, Z1:word,
                                X2:word, Y2:word, Z2:word,
                                X3:word, Y3:word, Z3:word,
                                Color:byte

;====== Begin Code/Data segment ==========================================
cseg    segment public 'CODE'  
        assume  cs:cseg, ds:cseg, es:nothing

FontFile db      'letters.pcx',0   ; Filename of PCX file with font images


; FontMap is a 320x200 PCX File containing 8x8 letters
; ABCDEFGHIJKLMNOPQRSTUVWXYZ
; abcdefghijklmnopqrstuvwxyz
; 01234567890
;
; Letters is a 256-word lookup table that
; maps each ASCII value to a location in FontMap
; Our program need only map letters, digits, space, and period.

Letters dw      32 dup ((320*16)+(8*11))
        dw      (320*16)+(8*12) ; ' '
        dw      13 dup ((320*16)+(8*11))
        dw      (320*16)+(8*10) ; '.'
        dw      (320*16)+(8*11)
        dw      (320*16)+(8*0)  ; '0'
        dw      (320*16)+(8*1)  ; '1'
        dw      (320*16)+(8*2)  ; '2'
        dw      (320*16)+(8*3)  ; '3'
        dw      (320*16)+(8*4)  ; '4'
        dw      (320*16)+(8*5)  ; '5'
        dw      (320*16)+(8*6)  ; '6'
        dw      (320*16)+(8*7)  ; '7'
        dw      (320*16)+(8*8)  ; '8'
        dw      (320*16)+(8*9)  ; '9'
        dw      7 dup ((320*16)+(8*11))
        dw      (320*0)+(8*0)   ; 'A'
        dw      (320*0)+(8*1)   ; 'B'
        dw      (320*0)+(8*2)   ; 'C'
        dw      (320*0)+(8*3)   ; 'D'
        dw      (320*0)+(8*4)   ; 'E'
        dw      (320*0)+(8*5)   ; 'F'
        dw      (320*0)+(8*6)   ; 'G'
        dw      (320*0)+(8*7)   ; 'H'
        dw      (320*0)+(8*8)   ; 'I'
        dw      (320*0)+(8*9)   ; 'J'   
        dw      (320*0)+(8*10)  ; 'K'
        dw      (320*0)+(8*11)  ; 'L'
        dw      (320*0)+(8*12)  ; 'M'
        dw      (320*0)+(8*13)  ; 'N'
        dw      (320*0)+(8*14)  ; 'O'
        dw      (320*0)+(8*15)  ; 'P'
        dw      (320*0)+(8*16)  ; 'Q'
        dw      (320*0)+(8*17)  ; 'R'
        dw      (320*0)+(8*18)  ; 'S'
        dw      (320*0)+(8*19)  ; 'T'
        dw      (320*0)+(8*20)  ; 'U'
        dw      (320*0)+(8*21)  ; 'V'
        dw      (320*0)+(8*22)  ; 'W'
        dw      (320*0)+(8*23)  ; 'X'
        dw      (320*0)+(8*24)  ; 'Y'
        dw      (320*0)+(8*25)  ; 'Z'
        dw      6 dup ((320*16)+(8*11))
        dw      (320*8)+(8*0)   ; 'a'
        dw      (320*8)+(8*1)   ; 'b'
        dw      (320*8)+(8*2)   ; 'c'
        dw      (320*8)+(8*3)   ; 'd'
        dw      (320*8)+(8*4)   ; 'e'
        dw      (320*8)+(8*5)   ; 'f'
        dw      (320*8)+(8*6)   ; 'g'
        dw      (320*8)+(8*7)   ; 'h'
        dw      (320*8)+(8*8)   ; 'i'
        dw      (320*8)+(8*9)   ; 'j'   
        dw      (320*8)+(8*10)  ; 'k'
        dw      (320*8)+(8*11)  ; 'l'
        dw      (320*8)+(8*12)  ; 'm'
        dw      (320*8)+(8*13)  ; 'n'
        dw      (320*8)+(8*14)  ; 'o'
        dw      (320*8)+(8*15)  ; 'p'
        dw      (320*8)+(8*16)  ; 'q'
        dw      (320*8)+(8*17)  ; 'r'
        dw      (320*8)+(8*18)  ; 's'
        dw      (320*8)+(8*19)  ; 't'
        dw      (320*8)+(8*20)  ; 'u'
        dw      (320*8)+(8*21)  ; 'v'
        dw      (320*8)+(8*22)  ; 'w'
        dw      (320*8)+(8*23)  ; 'x'
        dw      (320*8)+(8*24)  ; 'y'
        dw      (320*8)+(8*25)  ; 'z'
        dw      132 dup ((320*16)+(8*12))

KeyWait dw 0 ; Control variable for KeyPrompt MACRO
BCount  dw ? ; Benchmark iteration Counter 

public fontfile, letters

;====== Procedures ==========================================

;
; Procedures
;

;;;
;;; ModeGraph
;;;     Switches to 320x200x256 VGA.
;;; 

ModeGraph proc near C uses ax
     mov     ax, 0013h
     int     10h          ; VBIOS call to switch into 
     ret                  ; Mode 13h 320x200, 8-bit color
ModeGraph endp

;;; 
;;; ModeText
;;;     Switches to 80x50 text mode.
;;;

ModeText proc near C uses ax bx
     mov     ax, 1202h
     mov     bl, 30h
     int     10h          ; vBIOS call to switch into
     mov     ax, 3        ; text-mode video w/50 lines
     int     10h
     mov     ax, 1112h
     mov     bl, 0
     int     10h
     ret
ModeText endp

;;;
;;; LoadPCX
;;;     Loads (decompresses) a .PCX image into a specified segment.
;;;
;;; INPUTS
;;;     AX = offset of segment to write into
;;;     DX = offset of string to filename to read from
;;;
;;; NOTES
;;;     See lab manual!

LoadPCX proc near
        call LibLoadPCX ; Replace this line with your own code!
        ret
LoadPCX endp

;;;
;;; InitBuf
;;;     Initializes the ScreenBuffer and the ZBuffer to Black pixels of
;;;     depth 255.
;;;

InitBuf proc near C
        Invoke LibInitBuf ; Replace this line with your own code!
        ret
InitBuf endp

;;;
;;; DrawScreen
;;;     Blasts ScreenBuffer onto the video page.
;;;

DrawScreen proc near C
        Invoke LibDrawScreen ; Replace this line with your own code!
        ret
DrawScreen endp

;;;
;;; DrawPoint
;;;      Draws a point at (x,y,z) with a given color.
;;;

DrawPoint proc near C X:word, Y:word, Z:byte, Color:byte
        Invoke LibDrawPoint, X,Y,Z,Color ; Replace this line with your own code!
        ret
DrawPoint endp

;;;
;;; DrawRect
;;;     Draws a rectangle whose upper left corner is (x,y,z)
;;;     with width W, height H, and a specified color.
;;; 
        
DrawRect proc near C X:word, Y:word, Z:byte, W:word, H:word, Color:byte
        Invoke LibDrawRect, X,Y,Z,W,H,Color ; Replace this line with your own code!
        ret
DrawRect endp

;;;
;;; DrawText
;;;     Draws a text string at (x,y,z) with the specified color.
;;;
;;; INPUTS
;;;     SI = pointer (offset) to string.
;;;

DrawText proc near C X:word, Y:word, Z:byte, Color:byte
        Invoke LibDrawText, X,Y,Z,Color ; Replace this line with your own code!
        ret
DrawText endp

;;;
;;; DrawTriangle
;;;     Draws a triangle with depth gradation, given three points and a solid
;;;     fill color.
;;;

DrawTriangle PROC near C  X1:word, Y1:word, Z1:word,
                          X2:word, Y2:word, Z2:word,
                          X3:word, Y3:word, Z3:word, Color:byte

        Invoke LibDrawTriangle, X1,Y1,Z1, X2,Y2,Z2, X3,Y3,Z3, Color
              ; Replace line above with your own code!
        ret
DrawTriangle endp

;====== Test code ==========================================

;;;
;;; TestZBuf
;;;     Exercises functionality of the ZBuf

String1     db      'ECE291','$'
String2     db      'ZBuffer','$'      ; Strings used in TestZBuf
String3     db      'MP4','$'
String4     db      'Fall 98','$'
String5     db      'Lockwood','$'
String6     db      'Welcome to a 3D world.','$'
StringBench db      'Benchmarking Code ...','$'

; public String1, String2, String3, String4, String5

TestZBuf proc near


        ; Draw a rectangle
        invoke  DrawRect, 20, 20, 30, 60, 50, 12   ; first bright red box
        invoke  DrawScreen
        KeyPrompt

        ; Test Z-Buffering
        invoke  DrawRect, 40, 30, 20, 60, 60, 9    ; bright blue box
        invoke  DrawRect, 30, 40, 10, 40, 40, 10   ; bright green box
        invoke  DrawScreen                         ; refresh display
        invoke  DrawRect, 180, 10, 250, 66, 60, 1  ; dim blue box
        KeyPrompt

        ; Test screen clipping (pixels off the screen should NOT be drawn!)
        invoke  DrawRect, -10, -10, 255, 15, 15, 1 ; upper left corner  (blue)
        invoke  DrawRect, 315, -10, 255, 15, 15, 2 ; upper right corner (green)
        invoke  DrawRect, 315, 195, 255, 15, 15, 4 ; lower right corner (red)
        invoke  DrawRect, -10, 195, 255, 15, 15, 8 ; lower left corner  (white)
        invoke  DrawScreen
        KeyPrompt

        ; Load font segment
        mov     ax, SEG FontSeg
        mov     dx, offset FontFile
        call    LoadPCX                       ; This should change the palette
        KeyPrompt

        ; Test DrawText
        mov     si, offset String1           ; bright red 'ECE291'
        invoke  DrawText, 180, 20, 0, 12
        mov     si, offset String2           ; bright blue 'ZBuffer"
        invoke  DrawText, 180, 30, 10, 9
        mov     si, offset String3           ; bright green 'MP4'
        invoke  DrawText, 180, 40, 30, 10
        mov     si, offset String4           ; bright white 'Fall 98'
        invoke  DrawText, 180, 50, 20, 15
        mov     si, offset String5           ; bright white 'Lockwood'
        invoke  DrawText, 180, 60, 20, 15
        mov     si, offset String6           ; bright yellow 'Welcome' message
        invoke  DrawText, 5, 180, 40, 14

        invoke  DrawScreen
        KeyPrompt

        invoke  DrawRect, 170, 40, 25, 66, 38, 24 ; gray box that covers 'MP4'
        invoke  DrawScreen                        ; but leaves 'Fall 98' visible
        KeyPrompt

        invoke  DrawTriangle, 5, 105, 0,         ; little red triangle
                              5, 106, 0,
                              6, 106, 0, 12
        invoke  DrawTriangle, 16, 116, 0,        ; little green triangle
                              16, 115, 0,
                              15, 115, 0, 10
        invoke  DrawTriangle, 26, 125, 0,        ; little blue triangle
                              26, 126, 0,
                              25, 126, 0, 9
        invoke  DrawTriangle, 35, 136, 0,        ; little white triangle
                              36, 135, 0,
                              35, 135, 0, 15

        invoke  DrawScreen
        KeyPrompt

        invoke  DrawTriangle, 30, 120, 0,    ; this yellow triangle is
                              40, 130, 0,    ; degenerate, so it looks like
                              50, 140, 0, 14 ; a diagonal yellow line

        invoke  DrawTriangle, 50, 110, 20,    ; red obtuse triangle
                              70, 130, 20,
                              100, 130, 20, 12

        invoke  DrawTriangle, 105, 110, 50,   ; green right isoceles triangle
                              105, 130, 50,
                              145, 130, 50, 10

        invoke  DrawTriangle, 160, 110, 80,   ; blue isoceles triangle
                              150, 130, 80,
                              170, 130, 25, 9

        invoke  DrawRect, 60, 135, 150, 110, 30, 12 ; red rectangle beneath
        invoke  DrawScreen                          ; the three triangles
        KeyPrompt

        invoke  DrawTriangle, 60, 140, 0,       ; white scalene triangle should
                              147, 100, 100,    ; intersect the red rectangle
                              173, 170, 200, 15
        invoke  DrawScreen
        KeyPrompt
        
        invoke  DrawTriangle, 180, 100, 0,     ; dark red triangle that makes
                              180, 190, 0,     ; the left side of 3D maze
                              240, 145, 255, 4
        invoke  DrawTriangle, 180, 100, 0,     ; dark blue triangle that makes
                              300, 100, 0,     ; the top of 3D maze
                              240, 145, 255, 1
        invoke  DrawTriangle, 300, 100, 0,     ; dark red triangle that makes
                              300, 190, 0,     ; the right side of 3D maze
                              240, 145, 255, 4
        invoke  DrawTriangle, 300, 190, 0,     ; dark gray triangle that makes
                              180, 190, 0,     ; the left side of 3D maze
                              240, 145, 255, 24
        invoke  DrawRect, 220, 130, 100, 40, 30, 12 ; bright red rectangle
        invoke  DrawScreen                          ; illustrating far distance
        KeyPrompt

        invoke  DrawRect, 200, 115, 75, 80, 60, 12 ; bright red rectangle
        invoke  DrawScreen                         ; illustrating near distance
        KeyPrompt
        ret

TestZBuf endp

;====== MAIN ==========================================

_main PROC FAR
        mov     ax,cseg     ; Set default segment equal to code segment
        mov     ds,ax
        mov     ax,VidSeg   ; Initalize extra segment for Video graphics
        mov     es,ax

        invoke  ModeGraph   ; Switch VGA into grahics mode
        invoke  InitBuf     ; Initialize ZBuffer 

        mov     KeyWait,1   ; Have KeyPrompt pause for keystroke been routines
        call    TestZBuf    ; Test functionality of Z-Buffer


        invoke  InitBuf     ; Initialize ZBuffer
        mov     BCount,100  ; Benchmark performance of code            

        mov     si, offset StringBench     ; Display Benchmark Start Message
        invoke  DrawText, 0, 0, 0, 12      ; (Red text at top-left of screen)

        mov     KeyWait,0
        call    SetStart    ; Optimize your code to reduce running time!
BLoop:  call    TestZBuf   

        dec     BCount
        jnz     BLoop

        invoke  ModeText    ; Return to text-mode video
        call    mp4xit
_main ENDP

cseg    ends
        end    _main
