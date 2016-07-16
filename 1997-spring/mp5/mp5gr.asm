        PAGE 75, 132
        TITLE  Network_Tag_Graphics - Your Name Here! - 3/97

Comment *
        NETWORK TAG - Graphic Routines
        ------------------------------
        ECE291: Machine Problem 5-1
        Prof. John W. Lockwood
        University of Illinois, Dept. of Electrical & Computer Engineering
        Spring 1997
        Documentation: http://www.ece.uiuc.edu/~ece291/mp/mp5/mp5.html
        Revision 1.0
        *

.MODEL COMPACT  ; Allow Multiple Segments
.486            ; Enable use of 32-bit registers and 286/386/486 Registers

OPTION NOOLDMACROS  ; Only commas count as whitespaces

; ===== Handy General MACROS & Constants =================================

        CR        EQU 13      ; ASCII Carriage Return
        LF        EQU 10      ; ASCII LineFeed

        VidGrSEG EQU 0A000h

GMODE MACRO ; Set Mode13h VGA Graphics
        PUSH AX
        mov ah,00h
        mov al,13h
        int 10h
        POP AX
ENDM

TMODE MACRO ; Set VGA for 80x25 Text Mode 
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

; -- LIBMP5GR.LIB Routines (Write these) --

extrn LoadBMP     :near ; Comment out to use your own code
extrn StoreBMP    :near ; Comment out to use your own code
extrn DrawBMP     :near ; Comment out to use your own code
extrn DrawBox     :near ; Comment out to use your own code
extrn DrawEmptyBox:near ; Comment out to use your own code

extrn MP5Xit:near

;====== PUBLICs ===========================================================

  PUBLIC bmp        ; Must be available for linkage with LIBMP5gr library
  PUBLIC ImageArray

;====== Stack Segment =====================================================

stkseg  segment stack                   ; *** STACK SEGMENT ***
        db      64 dup ('STACK   ')
stkseg  ends

;====== BMP Segment =======================================================

bmpseg  segment public                  ; *** BMP Segment ***
  bmp bmptype < >
bmpseg ends

;====== Image Segment ====================================================

imageseg segment public                 ; *** IMAGE Segment ***
  ImageArray db 32 dup( 512 dup(4,15), 512 dup(2,15) )
  ; 64 Images * 1024 bytes : red/white , greeen/white Stripe pattern
imageseg ends

;====== Code/Data segment ================================================

cseg    segment public                  ; *** CODE SEGMENT ***
        assume  cs:cseg, ds:cseg, ss:stkseg, es:nothing

crlf    db CR,LF,'$'

;====== Procedures =======================================================


; Your code goes here !

                                                                    
;====== Main =============================================================

MyImage  db 'MyImage.BMP',0 ; Null-terminated Filename
DogImage db 'Dog.BMP',0

Main PROC far
        MOV AX,CS
        MOV DS,AX

        MOV     DX, offset MyImage
        Call LoadBMP

        PUSH    DS
        MOV     AX,Seg BMP
        MOV     DS,AX
        MOV     SI,Offset BMP
        MOV     AX,0
        Call StoreBMP
        POP     DS

        MOV DX,offset DogImage
        Call LoadBMP

        PUSH    DS
        MOV     AX,Seg BMP
        MOV     DS,AX
        MOV     SI,Offset BMP
        MOV     AX,5
        Call StoreBMP
        POP     DS

        GMODE

        MOV     AX,0  ; MyImage
        MOV     DI,0
        Call DrawBMP

        MOV     AX,5  ; Dog
        MOV     DI,50
        Call DrawBMP

        MOV     AX,10 ; Uninitialized Picture
        MOV     DI,100
        Call DrawBMP

        MOV     DI,320*50 + 0
        MOV     AL,1  ; Blue
        Call DrawBOX

        MOV     DI,320*50 + 50
        MOV     AX,5  ; Dog
        Call DrawBMP
        MOV     AL,4  ; Red
        Call DrawEmptyBox

        MOV     DI,320*50 + 100
        MOV     AX,0  ; Dog
        Call DrawBMP
        MOV     AL,2  ; Green
        Call DrawEmptyBox

        MOV AX,0000h
        MOV ES,AX      ; Timer TICK Counter
        MOV SI,046Ch

        MOV DI,320*100 + 320-32
        MOV CX,320-32

Animate:MOV     AX,5
        Call    DrawBMP

Waiting:CMP EDX,ES:[SI]
        JE Waiting
        MOV EDX,ES:[SI]

        MOV     AL,0
        Call    DrawBOX

        DEC DI
        LOOP Animate

        Call Kbdin
        TMODE

        Call MP5Xit

Main ENDP

;====================================================================

cseg    ENDS
        END MAIN
