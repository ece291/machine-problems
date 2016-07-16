        PAGE 75, 132
        TITLE Tank Simulation (Part II) - Your Name - Current Date

.MODEL LARGE  ; Allow multiple segments
.486          ; Enable use of 32-bit registers (EAX, EBX, etc.) 

COMMENT %
        Battletank Simulator : Part II
        ------------------------------
        ECE291: MP5
        Prof. John W. Lockwood
        Unversity of Illinois, Dept. of Electrical & Computer Engineering
        ; Assistant Guest Authors: Mike Carter, Johanna Canniff
        Fall 1997
        Revision 1.0
        %

;====== Constants =========================================================

VIDGRSEG   EQU 0A000h    ; VGA Video Graphics Segment Adddress
VIDTEXTSEG EQU 0B800h    ; VGA Video Text Segment Adddress

CR         EQU 13
LF         EQU 10


GMODE MACRO ; Switch to 320x200 - 256 colors graphics (Mode 13h)
          mov     ax, 0013h     ; Set VGA to Mode 13 graphics
          int     10h
ENDM

TMODE MACRO ; Switch to 80x50 Text Mode Video
          MOV  AX, 1202h
          MOV  BL, 30h
          int  10h
          MOV  AX, 3
          INT  10h
          MOV  AX, 1112h
          MOV  BL, 0
          INT  10h
ENDM

;====== Externals =========================================================

; -- LIB291 Routines (Free) ---
extrn rsave:near, rrest:near, dspout:near, dspmsg:near, binasc:near, kbdin:near

; extrn __DrawPoly
;extrn __LoadPCX
;extrn __MoveScreen
;extrn __AnimateScreen
;extrn __InstKey
;extrn __DeInstallKey
;
; -- LIBMP4 Routines (From Part I of assignment) --

; Consult MASM Programmers guide or use 'MASM /h' for help on command syntax
;   for the INVOKE and PROTO directives.

_DrawPoly PROTO far C \
  X1:word, Y1:word, Y3:word, X2:word, Y2:word, Y4:word, Color:byte

_LoadPCX  PROTO far C      DestSeg:word, Fname:far ptr byte

_MoveScreen PROTO far C    DestSeg:word, SourceSeg:word

_AnimateScreen PROTO far C DestSeg:word, SourceSeg:word, HorShift:word

_InstKey PROTO far C

_DeInstallKey PROTO far C

; -- New LIBMP5 Routine ---

_ScaleTank PROTO far C \
  XPos:word, YPos:word, Scalef:word, Rotation:byte, PlayerNum:byte

_HallDemo PROTO far C Delay:word

_mp5xit PROTO far C

;====== Additional Data Segments ==========================================


SBSeg segment PUBLIC 'DATA1'
    ScreenBuffer DB 65535 dup(?)  ; Buffered Screen Segment
SBSeg ENDS

BGSeg segment PUBLIC 'DATA2'
    Background   DB 65535 dup(?)  ; Background Graphics Buffer
BGSeg ENDS

FGSeg segment PUBLIC 'DATA3'
    ForeGround   DB 65535 dup(?)  ; Foreground Graphics Buffer
FGSeg ENDS

ScrSeg segment PUBLIC 'DATA4'
    ScratchPad   DB 65535 dup(?)  ; Scratch (temporary) buffer
ScrSeg ENDS

;====== Code/Data segment ================================================
cseg    segment public 'CODE' 
        assume  cs:cseg, ds:cseg, es:nothing

;====== Variables ========================================================

CRLF      db CR, LF, '$'
pbuf      db 7 dup(?)   
                             
OldVector dd ?          ; Pointer to old keyboard routine  ; Set by InstKey

; Variables Set by MyKeyInt (Note that _ added for C compatibilty)
_ExitFlag    db 0   ; 0=Play, 1=Exit - Set by MyKeyInt ; Set by MyKeyInt
_Xoffset     dw 0   ; {-1,0,1} for left, stop, right   ; Set by MyKeyInt
_Yoffset     dw 0   ; {-1,0,1} for forward, stop, back ; Set by MyKeyInt
_Zoom        dw 0   ; {-1,0,1} for '-', stop, '+'      ; Set by MyKeyInt

PUBLIC _ExitFlag, _Xoffset, _Yoffset, _Zoom

PUBLIC OldVector
PUBLIC ScreenBuffer, BackGround, ForeGround, ScratchPad

; ======== Your Code ======================================================

ScaleTank proc far C PUBLIC uses DI SI ES DS ,
        XPos:word, YPos:word, Scalef:word, Rotation:byte, PlayerNum:byte

        ; Write 'PlayerNum' tank image from ForeGround to ScreenBuffer.
        ; Image should be *centered* at XPos, YPos,
        ; Scaled by Scalef % (any possible value between 0 and 2^16-1)
        ; and viewed at 'Rotation' (0..5)


        ; Insert your new code here then comment line below !

        Invoke _ScaleTank, XPos, YPos, Scalef, Rotation, PlayerNum ; lib call

        ; (Note: Efficiency matters!  It is worth an extra 10 points!)

        RET
ScaleTank ENDP

; ------------------------------------------------------------------------

HallDemo proc far C PUBLIC uses DI SI ES DS , Delay:word

        ; Draws one scaled tank moving down a hallway,
        ;       one scaled tank moving  up  a hallway,
        ;       and a little tank moving across a hallway
        ;
        ; Calls 'Delay' between video frames to slow animation for humans
        ;
        ; Test Case: 'MAIN 4'

        ; Insert your new code here then comment line below !

        Invoke _HallDemo, Delay ; lib call

        RET
HallDemo ENDP

; ------------------------------------------------------------------------

MyDemo proc far C PUBLIC uses DI SI ES DS , Delay:word

        ; Use your imagination to create an interesting tank battle.
        ; Try including walls, multiple tanks, and movement.
        ;
        ; Test Case: 'MAIN 5'

        ; Insert your new code here then comment line below !


        RET
MyDemo ENDP


; ======== Calls to LIBMP4 Routines =======================================

; For MP5, you may use MP4 library routines or insert your own code
;             (there is no penalty for using libmp4 routines)

DrawPoly proc far C PUBLIC uses BX CX DX SI DI DS ES,
        X1:word, Y1:word, Y3:word, X2:word, Y2:word, Y4:word, Color:byte
        ; Insert your Part I code here, if you wish, and comment line below.
        Invoke _DrawPoly, X1, Y1, Y3, X2, Y2, Y4, Color ; ; Library Call
        RET
DrawPoly endp

LoadBackgroundPCX  proc far C PUBLIC   , Fname:far ptr byte
        ; Insert your Part I code here, if you wish, and comment line below.
        ; Call with DestSeg = Seg Background.
        Invoke _LoadPCX, Seg BackGround , FName
        RET
LoadBackgroundPCX endp

LoadForegroundPCX  proc far C PUBLIC   , Fname:far ptr byte
        ; Insert your Part I code here, if you wish, and comment line below.
        ; Call with DestSeg = Seg ForeGround.
        Invoke _LoadPCX, Seg ForeGround , FName
        RET
LoadForegroundPCX endp

DrawBufferToScreen proc far C PUBLIC    DestSeg:word, SourceSeg:word
        ; Insert your Part I code here, if you wish, and comment line below.
        ; Call with DestSeg = VidGrSeg, SourceSeg = Seg ScreenBufer
        Invoke _MoveScreen, VidGrSeg , Seg ScreenBuffer
        RET
DrawBufferToScreen endp

AnimateBackgroundToBuffer proc far C PUBLIC, HorShift:word
        ; Insert your Part I code here, if you wish, and comment line below.
        ; Call with DestSeg = Seg ScreenBuffer, SourceSeg = Seg Background
        Invoke _AnimateScreen, SEG ScreenBuffer, SEG Background, HorShift
        RET
AnimateBackgroundToBuffer endp

InstKey proc far C PUBLIC 
        ; Insert your Part I code here, if you wish, and comment line below.
        ; Add code to set Zoom = {-1,0,1} for '-' or '+'
        ; Prefix _XOffset, _YOffset, _ExitFlag, and _Zoom with _Underscore
        Invoke _InstKey
        RET
InstKey endp

DeInstallKey proc far C PUBLIC
        ; Insert your Part I code here, if you wish, and comment line below.
        Invoke _DeInstallKey
        RET
DeInstallKey endp

; ======== Given Procedures ===============================================

WaitRetrace proc near
       ; Waits for the monitor beam to make one full pass of the screen.
       ; Combats flicker, but also slows down the redraw rate considerably.
       ; (Free code)

        push    dx
        push    ax

        mov     dx, 3DAh ; VGA Refresh Status Register

WRLoop: in      al, dx
        and     al, 08h  ; Vertical Refresh bit
        jnz     WRLoop

        pop     ax
        pop     dx

        ret
WaitRetrace endp


DelayTick proc far C PUBLIC uses ES , Clocks:word
        ; Delays Clocks/18 seconds, clock cycles.

        MOV CX,Clocks
        CMP CX,0
        JE DTDone

        MOV AX,0000h
        MOV ES,AX

        DTMain:             ; Read Timer Tick at 0000:046Ch (See Brey, p 399)
          MOV AX,ES:[046Ch]

        DTAgain:
          CMP AX,ES:[046Ch] ; Look until it changes
          JE DTAgain

        LOOP DTMain
  DTDone:
        RET
DelayTick ENDP

ModeGraph proc far C PUBLIC ; Switch to Graphics Mode
        GMODE
        ret
ModeGraph endp

ModeText proc far C PUBLIC  ; Switch to Text Mode
        TMODE
        ret
ModeText endp

; ======== Test Cases =====================================================

TestMsg  db 'TestRoutine is handy for debugging',CR,LF,'$'
TestMsg2 db '[Press any key to continue]',CR,LF,'$'

TestRoutine proc far C PUBLIC uses ES DS SI DI

        mov ax,cs  ; Be sure to set DS for our segment
        mov ds,ax

        ; This routine is called when you type 'MAIN 6'

        TMODE

        MOV dx, offset TestMsg
        CALL DSPMSG

        MOV dx, offset TestMsg2
        CALL DSPMSG

        CALL KBDIN ; Wait for keypress ...

        RET
TestRoutine endp

; ======== END of Program =================================================

; Note that there is no MAIN routine in this ASM file.
; All procedures were called from main.c

cseg    ends
        end
