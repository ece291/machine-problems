        PAGE 75, 132
        TITLE  MP4:Network Tag Graphics - Your Name

Comment *
        NETWORK TAG - Graphic Routines
        ------------------------------
        ECE291: Machine Problem 4
        Prof. John W. Lockwood
        University of Illinois,
        Dept. of Electrical & Computer Engineering
        Spring 1999
        Revision 2.0
        *

.MODEL LARGE  ; Allow Multiple Segments to be defined
.486          ; Enable code with 32-bit registers and 486 CPU Features



; ===== Handy General MACROS & Constants =================================

CR      EQU 13         ; ASCII Carriage Return
LF      EQU 10         ; ASCII LineFeed

VidGrSEG EQU 0A000h

GMODE MACRO            ; Set VGA to Mode=13h VGA Graphics (320x200)
        PUSH AX
        mov ah,00h
        mov al,13h
        int 10h
        POP AX
ENDM

TMODE MACRO            ; Set VGA for Text Mode (80x25 characters)
        PUSH AX
        mov ah,00h
        mov al,02h
        int 10h
        POP AX
ENDM

;====== Bitmap structure definition =======================================

BMPTYPE STRUC
; --- BitMapFileHeader --- ; 14 bytes
  BFType            DB 'BM' ; File Type
  BFSize            DD   ?  ; File Size (in Bytes)
  BFReserved1       DW   0  ; Reserved 
  BFReserved2       DW   0  ;    "
  BFOffBits         DD   ?  ; Offset to start of image data 
; --- BitMapInfoHeader --- ; 40 bytes
  BISize            DD   ?  ; Size of BitMapInfoHeader (28h = 40d)
  BIWidth           DD   ?  ; # Pixel Rows 
  BIHeight          DD   ?  ; # Pixel Columns
  BIPlanes          DW   1  ;
  BIBitCount        DW   ?  ; Log2(palette size) = 4 for 16-color image
  BICompression     DD   0  ; RGB = 0 = Uncompressed 
  BISizeImage       DD   ?  ; Size of Image (Bytes)
  BIXPelsPerMeter   DD   ?  ;
  BIYPelsPerMeter   DD   ?  ;
  BIColorsUsed      DD   0  ; 0=All
  BIColorsImportant DD   0  ;
; --- Color Table --- ; 64 Bytes
  RGBQuad           DB 16 dup ( 4 dup(?) ) ; Blue, Green, Red, Unused
; --- Image Data Follows ; n Bytes
  ImageData         DB 512 dup(0) ; Image data (bottom row first)
BMPTYPE ENDS

;====== Externals ========================================================

; -- LIB291 Routines (Free) --

extrn dspmsg:near, dosxit:near, kbdin:near

; -- LIBMP4.LIB Routines (Write these) --

extrn LibLoadBMP:near
extrn LibStoreBMP:near
extrn LibDrawBMP:near
extrn LibDrawBox:near
extrn LibDrawEmptyBox:near

extrn MPXit:near

;====== PUBLICs ===========================================================

  PUBLIC bmp        ; Must be available for linkage with LIBMP4 library
  PUBLIC ImageArray

;====== Stack Segment =====================================================

stkseg  segment stack                 ; *** STACK SEGMENT ***

        db      64 dup ('STACK   ')   ; Allocate bytes of stack memory

stkseg  ends

;====== BMP Segment =======================================================

bmpseg  segment public                ; *** BMP Segment ***

  bmp bmptype < >                     ; Allocate bmp to hold 1 BMP image

bmpseg ends

;====== Image Segment =====================================================
                         
imageseg segment public               ; *** IMAGE Segment ***

  ImageArray db 64 dup( 1024 dup(1) ) ; Allocate memory to hold images

    ; 64 Images of 1024 bytes, each colored blue (palette #1)

imageseg ends


;====== Code/Data segment ================================================

cseg    segment public 'CODE'         ; *** CODE SEGMENT ***
        assume  cs:cseg, ds:cseg, ss:stkseg, es:nothing

crlf    db CR,LF,'$'

;====== Procedures =======================================================

; Your code goes here !

LoadBMP  PROC NEAR
         Call LibLoadBMP       ; Replace with your code!
         RET
LoadBMP  ENDP


StoreBMP PROC NEAR
         Call LibStoreBMP      ; Replace with your code!
         RET
StoreBMP ENDP


DrawBMP  PROC NEAR
         Call LibDrawBMP       ; Replace with your code!
         RET
DrawBMP  ENDP


DrawBox  PROC NEAR
         Call LibDrawBox       ; Replace with your code!
         RET                   
DrawBox  ENDP


DrawEmptyBox PROC NEAR
         Call LibDrawEmptyBox  ; Replace with your code!
         RET
DrawEmptyBox ENDP

;====== Main =============================================================

MyImage  db 'MyImage.BMP',0          ; Null-terminated Filename
DogImage db 'Dog.BMP',0

Main PROC far
        MOV AX,CS
        MOV DS,AX

        ; The following code exercises the graphic functions
        ; that you will be using for the network tag game.
        ; Use this code to verify that your routines implement the
        ; same functionality as that of the library routines!

        MOV     DX, offset MyImage
        Call LoadBMP               ; Load MyImage.BMP image from disk

        PUSH    DS
        MOV     AX,Seg BMP
        MOV     DS,AX
        MOV     SI,Offset BMP
        MOV     AX,0
        Call StoreBMP              ; Store and expand BMP image to
        POP     DS                 ; Location 0 of Image array

        MOV DX,offset DogImage
        Call LoadBMP               ; Load Dog.BMP from disk

        PUSH    DS
        MOV     AX,Seg BMP
        MOV     DS,AX
        MOV     SI,Offset BMP
        MOV     AX,5               ; Store and expand BMP image to
        Call StoreBMP              ; Location 5 of Image array
        POP     DS

        GMODE

        MOV     DI,0
        MOV     AL,8+4; Bright Red
        Call DrawBOX               ; Draw box at top-left of screen

        Call KBDin ; Wait for keypress

        MOV     DI,32
        MOV     AL,8+7; Bright White
        Call DrawEmptyBOX          ; Draw White empty box

        Call KBDin ; Wait for keypress

        MOV     DI,64
        MOV     AL,8+1; Bright Blue
        Call DrawBOX               ; Draw Blue box

        Call KBDin ; Wait for keypress

        MOV     AX,5  ; Dog
        MOV     DI,320-32          ; Draw dog at right of screen
        Call DrawBMP

        Call KBDin ; Wait for keypress

        MOV     AX,0  ; MyImage
        MOV     DI,(200-32)*320
        Call DrawBMP               ; Draw MyImage at bottom, left of screen

        Call KBDin ; Wait for keypress


        MOV     DI,(200-32)*320+320-32
        MOV     AL,2  ; Green
        Call DrawBOX               ; Draw Green box at bottom, right of screen

        Call KBDin ; Wait for keypress

        MOV     DI,320*32+16
        MOV     AX,5  ; Dog
        Call DrawBMP

        Call KBDin ; Wait for keypress

        MOV     AL,4  ; Red
        Call DrawEmptyBox          ; Draw dog in empty red box

        Call KBDin ; Wait for keypress

        MOV     DI,320*32+48
        MOV     AX,0  ; Dog
        Call DrawBMP

        Call KBDin ; Wait for keypress

        MOV     AL,2  ; Green      ; Draw MyImage in empty green box
        Call DrawEmptyBox

        Call KBDin ; Wait for keypress

                                     ; Animate image across screen

        MOV DI,320*100 + 320-32      ; Start at Row=100, Right side of screen
        MOV CX,320-32                ; Move across entire width of screen

        MOV AX,0000h
        MOV ES,AX       ; Load ES:SI with addres of system timer
        MOV SI,046Ch    ; (increments 18 times/second)
        MOV EDX,ES:[SI] ; Load EDX with current tick count.


Animate:MOV     AX,5
        Call    DrawBMP

Waiting:CMP EDX,ES:[SI] ; Pause until time increments by one tick
        JE Waiting      ; ( tick will increment every 1/18 of second)
        MOV EDX,ES:[SI]

        MOV     AL,0
        Call    DrawBOX
        DEC DI          ; Animate movement
        LOOP Animate

        Call Kbdin      ; Wait for keypress

        TMODE           ; Switch back to text-mode video

        Call MPXit      ; Exit

Main ENDP

;====================================================================

cseg    ENDS
        END MAIN
