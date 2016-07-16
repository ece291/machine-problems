
; Additions to MAZE3D.ASM for MP4

; External Routines (called from C)
PUBLIC _TestGeometry

; Public variables (used by C Program and libmp4)
PUBLIC View3d, Side3d, P3d, X3d, W3d, VidMode

; Public variables (used by libmp3)
PUBLIC updatescreen

; =================== External Library Procedures =======================

; LIBMP4 Routines (Comment these out to use your own code)

EXTRN DrawBox:near
EXTRN DrawTrap:near
EXTRN DrawBackWall:near
EXTRN DrawSides:near
EXTRN DrawFloorCeiling:near
EXTRN DrawGrScreen:near
EXTRN UpdateGrScreen:near
       
; ============================= Variables ===============================

VidMode db TEXTMODE ; Can be TEXTMODE (default) or GRMODE

; Pointed Mouse Attribute:Character Lookup Table (North, East, South, West)
mousech  dw MNCH, MECH, MSCH, MWCH

View3d  db HALL,HALL,HALL,HALL,HALL,HALL,HALL,HALL,HALL,HALL,WALL
  ; The elements in _MAZE, looking down a direction
  ; Sample data (your program will change these)

Side3d  db LSW, LRSW,LRSW,LSW, RSW, LRSW, 0  ,LRSW, 0  ,LRSW,LRSW
  ; The elements to the side (Bit7=1=LeftSideWall | Bit6=1=RightSideWall)
  ; Sample data (your program will change these)

; 3D Coordinate Arrays 

; Widths of walls for each depth (Large at front, small in back)
w3d   dw  20, 30, 24, 20, 16, 14, 12, 10,  8,  4,  2 

; Sum of W3d (i.e., total size at each depth)
X3d   dw 160,140,110, 86, 66, 50, 36, 24, 14,  6,  2

; Position Along the upper-left diagonal (screen offset)
; Example: At Level 2, Top-Left corner is at Column 20, Row 10
P3d   dw 0
      dw 20+320*10
      dw 20+30+320*(10+15)
      dw 20+30+24+320*(10+15+12)
      dw 20+30+24+20+320*(10+15+12+10)
      dw 20+30+24+20+16+320*(10+15+12+10+8)
      dw 20+30+24+20+16+14+320*(10+15+12+10+8+7)
      dw 20+30+24+20+16+14+12+320*(10+15+12+10+8+7+6)
      dw 20+30+24+20+16+14+12+10+320*(10+15+12+10+8+7+6+5)
      dw 20+30+24+20+16+14+12+10+8+320*(10+15+12+10+8+7+6+5+4)
      dw 20+30+24+20+16+14+12+10+8+4+320*(10+15+12+10+8+7+6+5+4+2)
      dw 20+30+24+20+16+14+12+10+8+4+2+320*(10+15+12+10+8+7+6+5+4+2+1)
                           
; ================= Procedures (Your code goes here) ====================



; ============================== Free Code ==============================
  
_TestGeometry proc far
         ; Geometry Test Cases
         ; This routine is called when you run "mazec -t"
         ; Use and modify this routine to debug your code.

         PUSH AX
         PUSH BX          ; Save Registers
         PUSH CX
         PUSH DX
         PUSH DS
         PUSH ES

         MOV AX,CS        ; Set DS=CS
         MOV DS,AX

         GMODE ; Switch to 320x200 Graphics-Mode (MACRO)

         ; --- Draw a Rectangular Box ---

         mov dx,160-20
         mov cx,40        ; 20 Pixels Wide
         mov bx,40        ; 20 Pixels Tall
         mov AL,RED       ; Colored Red
         call drawbox     ; Width unchanged


         ; --- Draw a Left-Sided Trapezoid at left of screen ----

         mov dx,0 ; Position
         mov bx,80        ; 40 Pixels Tall
         mov AL,GREEN     ; Colored green
         mov AH,0         ; Left-Sided trapezoid
         call drawtrap    ; Width (CX) unchanged

         ; --- Draw a Right-Sided Trapezoid at right of screen ---

         add dx,320 - 2  ; Position (with -2 correction)
         mov AH,1         ; Right-Sided
         mov AL,BLUE      ; Colored blue
         call drawtrap    ; Width (CX), Height(BX), and Color(AL) Unchanged


         ; --- Wait for a keypress while we look at the screen ---

         call kbdin

         TMODE ; Switch back to 80x25 Text-Mode (MACRO)

         call showlibuse

         POP ES
         POP DS
         POP DX
         POP CX
         POP BX           ; Restore Registers
         POP AX

         ret
_TestGeometry endp

; ------------------------------------------------------------------------

UpdateScreen PROC NEAR
           cmp VidMode,TEXTMODE
           jne USGrMode
           call UpdateTextScreen
           ret
USGrMode:  Call UpdateGrScreen
           ret
UpdateScreen ENDP

