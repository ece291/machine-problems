        PAGE 75, 132
        TITLE   MP5.ASM   your name

Comment *
        NETWORK TAG - Network Routines
        ------------------------------
        ECE291: Machine Problem 5-2
        Prof. John W. Lockwood
        University of Illinois, Dept. of Electrical & Computer Engineering
        Spring 1997
        Documentation: http://www.ece.uiuc.edu/~ece291/mp/mp5/mp5.html
        Revision 1.0
        *

.MODEL COMPACT  ; Allow Multiple Segments
.486            ; Enable use of 32-bit registers and 286/386/486 Registers

OPTION NOOLDMACROS 

; ===== Handy General-Purpose MACROS ======================================

INCLUDE MACROS.INC

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

;====== Network Info =====================================================

; ---- Network Player Information ---

INACTIVE     EQU 0
ACTIVE       EQU 1
DEPARTING    EQU 2

PlayerType STRUC
  OldPosition  DW 320*100+160-16  ; Location specified as VGA MODE-13 Offset
  CurPosition  DW 320*100+160-16  ;   (Start at center of the screen)
  Status       DB INACTIVE        ; All Players Initially Inactive
PlayerType ENDS

; ---- Network Message Types & Formats ---

HELLO   EQU 33
UPDATE  EQU 21
GOODBYE EQU 22

GenericMsg STRUC          ; Generic Message Structure
  MsgType   db ?          ; 1-byte packet type identifier (See types below)
  PlayerNum db 63         ; Player that transmitted the message
GenericMSG ENDS

HelloMsg STRUC            ; Hello Message 
  MsgType   db HELLO
  PlayerNum db 63
  Image     db 630 dup(?) ; 118+32*32/2 bytes
HelloMsg ENDS

UpdateMsg STRUC           ; Update Message
  MsgType   db UPDATE
  PlayerNum db 63
  Position  dw ?          ; My Current Position
  It_Flag   db 0          ; 1 if It, 0 otherwise
  Tagged_by db ?          ; Player number that tagged me
UpdateMsg ENDS

GoodByeMsg STRUC          ; GoodBye Message
  MsgType db GOODBYE
  PlayerNum db 63
GoodByeMsg ENDS

;====== Stack Segment =====================================================

stkseg  segment stack                   ; *** STACK SEGMENT ***
        db      64 dup ('STACK   ')
stkseg  ends

;====== BMP Segment =======================================================

bmpseg  segment public                  ; *** BMP Segment ***
  bmp bmptype < >
bmpseg ends

PUBLIC bmp

;====== Image Segment ====================================================

imageseg segment public                 ; *** IMAGE Segment ***
  ImageArray db 32 dup( 512 dup(4,15), 512 dup(2,15) )
  ; 64 Images * 1024 bytes : red/white , greeen/white Stripe pattern
imageseg ends

PUBLIC imagearray

;====== Define code segment ===============================================

cseg    segment public                  ; *** CODE SEGMENT ***
        assume  cs:cseg, ds:cseg, ss:stkseg, es:nothing

;====== External procedures ===============================================

; -- Lib291 (Free) --
extrn   kbdin:near, binasc:near, dspmsg:near, dosxit:near

; -- LibNet (Free) --
extrn   NetInit:near, SendPacket:near, NetRelease:near, NetTest:Near
extrn   TXBuffer:byte, RXBuffer:byte 

; -- LibMP5gr --
extrn LoadBMP      :near ; Comment out to use your own code
extrn StoreBMP     :near ; Comment out to use your own code
extrn DrawBMP      :near ; Comment out to use your own code
extrn DrawBox      :near ; Comment out to use your own code
extrn DrawEmptyBox :near ; Comment out to use your own code

; -- LibMP5nt --
extrn NetPostLib   :near ; Comment out to use your own code
extrn JoyCalibrate :near ; Comment out to use your own code
extrn JoyStickMove :near ; Comment out to use your own code
extrn ReDrawScreen :near ; Comment out to use your own code

extrn MP5Xit:near

;====== Variables ========================================================

MyNum  db 63  ; My Player Number
PUBLIC MyNum

ItNum  db 63  ; Who is it
PUBLIC ItNum

TagNum db 63  ; Who tagged me
PUBLIC TagNum

player PlayerType 64 dup(< >) ; Player Array
PUBLIC player

MyPosition dw 320*100+160-16  ; Start at middle of screen
PUBLIC MyPosition

ExitFLag db 0 ; 0=Play, 1=exit
PUBLIC ExitFlag

MyImage  db 'myimage.bmp',0  ; Null-terminated filename
PUBLIC MyImage


pbuf           db 7 dup(?)
crlf           db CR,LF,'$'
Num320         dw 320
SizePlayerType db Sizeof Playertype

;======= Graphic Routines (Part I - Cut & Paste mp5gr routines) ==========

; Your code goes Here !

;======= Network Routines (Part II ) =====================================

; Your code also goes Here!

; -- Callback function for incoming messages --

netpost proc near
        Call NetPostLib  ; Remove this line & replace with your own code

        ; And the rest of your code goes here !

        RET
netpost endp

public netpost

; ====== MAIN Routine ====================================================

HelloTime      dw 0
UpdateTime     dw 0

main proc far
        mov     ax, cseg      ; Initialize DS register
        mov     ds, ax

        Call JoyCalibrate     ; Calibrate Joystick

        GetTime
        SUB AX,18*2           ; Retransmit timers for HelloMsg and UpdateMsg
        MOV HelloTime, AX
        MOV UpdateTime,AX

        Call NetINIT          ; Initialize Network
        Mov MyNum , AL

        Mov DX,offset MyImage ; Load MyImage into BMP
        Call LoadBMP

        GMODE ; Begin graphics mode

MainLoop:

        GetTime
        SUB AX,cs:HelloTime   ; Send Hello Message once per 2 seconds
        CMP AX,18*2
        JB NoHelloMessage

        MOV    (HelloMsg PTR TXBuffer).MsgType ,   HELLO
        MOVMB  (HelloMsg PTR TXBuffer).PlayerNum , MyNum
        STRCPY (HelloMsg PTR TXBuffer).Image , BMP , 630

        MOV AX,SizeOf HelloMsg
        Call SendPacket

        GetTime
        Mov HelloTime,AX

NoHelloMessage:

        GetTime
        SUB AX,UpdateTime
        CMP AX,3              ; Send Update Message 6 times per second
        JB NoUpdateMessage

        Call JoyStickMove     ; Update MyPosition with Joystick position

        MOV    (UpdateMsg PTR TXBuffer).MsgType,  UPDATE
        MOVMB  (UpdateMsg PTR TXBuffer).PlayerNum, MyNum
        MOVMW  (UpdateMsg PTR TXBuffer).Position, MyPosition
        MOV AL,ItNum
        .if MyNum==AL
          MOV    (UpdateMsg PTR TXBuffer).It_Flag,   1
        .else
          MOV    (UpdateMsg PTR TXBuffer).It_Flag,   0
        .endif
        MOVMB (UpdateMsg PTR TXBuffer).Tagged_By, TagNum

        MOV AX,SizeOf UpdateMsg
        Call SendPacket

        GetTime
        Mov UpdateTime,AX

NoUpdateMessage:

        Call ReDrawScreen     ; Redraw the screen

        CMP ExitFlag,0
        JE  MainLoop



        TMODE ; Return to text mode

        PRINTMSG 'Sending Goodbye Message ...'
        MOV    (GoodbyeMsg PTR TXBuffer).MsgType,  GOODBYE
        MOVMB  (GoodbyeMsg PTR TXBuffer).PlayerNum, MyNum

        MOV AX,SizeOf GoodbyeMsg
        Call SendPacket

MainDoneNet:

        Call NetRelease
        call mp5xit

main endp

cseg    ends
        end main     

