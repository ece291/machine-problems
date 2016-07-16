        PAGE 75, 132
        TITLE Tank Simulation (Part I) - Your Name - Current Date

.MODEL LARGE  ; Allow multiple segments
.486          ; Enable use of 32-bit registers (EAX, EBX, etc.) 

COMMENT %
        Battletank Simulator
        --------------------
	ECE291: MP4
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
          mov     ax, VidGrSeg  ; Point Extra Segment to Video Screen
          mov     es, ax
          mov     ax, 0013h     ; Set VGA to Mode 13 graphics
          int     10h
ENDM

TMODE MACRO ; Switch to 80x50 Text Mode Video
          mov  ax, VidTextSeg   ; Point Extra Segment to Video Screen
          mov  es, ax
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

; -- LIBMP4 Routines --

; These procedures are written so that they can be invoked from C
; Recall from Lecture 10 how function arguments are passed via the stack.
; Consult MASM Programmers guide or use 'MASM /h' for help on command syntax
;   for the INVOKE and PROTO directives.

_DrawPoly PROTO far C \
  X1:word, Y1:word, Y3:word, X2:word, Y2:word, Y4:word, Color:byte

_LoadPCX  PROTO far C      DestSeg:word, Fname:far ptr byte

_MoveScreen PROTO far C    DestSeg:word, SourceSeg:word

_AnimateScreen PROTO far C DestSeg:word, SourceSeg:word, HorShift:word

_InstKey PROTO far C

_DeInstallKey PROTO far C

_mp4xit PROTO far C

;====== Stack Segment =====================================================
stkseg  segment stack
        db 64 dup ('STACK   ')
stkseg	ends

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
        assume  cs:cseg, ds:cseg, ss:stkseg, es:nothing

;====== Variables ========================================================

ExitFlag    db 0        ; 0=Play, 1=Exit - Set by MyKeyInt

CRLF      db CR, LF, '$'
pbuf      db 7 dup(?)   
                             
OldVector dd ?          ; Pointer to old keyboard routine  ; Set by InstKey

Xoffset   dw 0 ;        ; {-1,0,1} for left, stop, right   ; Set by MyKeyInt
Yoffset   dw 0 ;        ; {-1,0,1} for forward, stop, back ; Set by MyKeyInt

PUBLIC ExitFlag, OldVector, Xoffset, Yoffset
PUBLIC ScreenBuffer, BackGround, ForeGround, ScratchPad

; ======== Your Code ======================================================

; Uncomment these routines as you write your own code!

; _DrawPoly proc far C PRIVATE uses BX CX DX SI DI DS ES,
;            X1:word, Y1:word, Y3:word, X2:word, Y2:word, Y4:word, Color:byte
;        ...
;        RET
; _DrawPoly endp

;_LoadPCX  proc far C PRIVATE     DestSeg:word, Fname:far ptr byte
;        ...
;        RET
;_LoadPCX endp

;_MoveScreen proc far C PRIVATE    DestSeg:word, SourceSeg:word
;        ...
;        RET
;_MoveScreen endp

;_AnimateScreen proc far C PRIVATE DestSeg:word, SourceSeg:word, HorShift:word
;        ...
;        RET
;_AnimateScreen endp

;_InstKey proc far C PRIVATE 
;        ...
;        RET
;_InstKey endp

;_DeInstallKey proc far C PRIVATE 
;        ...
;        RET
;_DeInstallKey endp

; ======== Given Procedures ===============================================

WaitRetrace proc near

       ; Waits for the monitor beam to make one full pass of the screen.
       ; Combats flicker, but also slows down the redraw rate considerably.
       ; (Free code)

	push	dx
	push	ax

        mov     dx, 3DAh ; VGA Refresh Status Register

WRLoop: in      al, dx
        and     al, 08h  ; Vertical Refresh bit
        jnz     WRLoop

	pop	ax
	pop	dx

	ret
WaitRetrace endp

; ======== Given Test Cases  =============================================

PCXHorizon  db 'horizon.PCX', 0
TRBadMsg    db 'Run the program as: MP4 n, where n=test case {1..5}',CR,LF
            db '[Press ESC to exit]',CR,LF,'$'

Xl          dw  100  ; X Left
Xr          dw  220  ; X Right
Yt          dw   20  ; Y Top
Yb          dw  180  ; Y Bottom
Ymt         dw   50  ; Y mid-Top
Ymb         dw  150  ; Y mid-Bottom

_TestRoutine proc far C testcase:word

            ; A robust set of individual test cases.
            ; Be sure that you *understand and study* this free code,
            ;   as it illustrates how your routines will be called.

            cmp testcase,'5'  ; Check Input Range
            ja  TRBad       ; Avoid Jumping on bad input
            cmp testcase,'1'
            jb  TRBad

            mov bx, testcase
            sub bx,'1'   ; Map '1','2','3','4','5' to 0,2,4,6,8 for jump table
            shl bx,1
            JMP TestFunction[BX]

            TestFunction dw offset TestR12 ; 1 = Single Polygon
                         dw offset TestR12 ; 2 = Multiple Polygons
                         dw offset TestR3  ; 3 = PCX File Loading & Animation
                         dw offset TestR4  ; 4 = Keyboard Interrupt Routine
                         dw offset TestR5  ; 5 = All of the above

TRBad:      mov dx, offset TRBadMsg
            call DSPMSG
            call kbdin
            JMP TRDone

TestR12:    ; Debug a single polygon
            GMODE

            MOV CX,64000/4          ; Clear ScreenBuffer
            MOV DI,0
            MOV AX, SEG ScreenBuffer
            MOV ES,AX
            MOV EAX,0
            REP STOSD

            Invoke _DrawPoly,   0, 20, 180, 120, 40, 160, 8+4 ; bright red

            CMP BX,0*2              ; Draw only one Polygon for case 0
            JE TR0Done              ; Draw Three polygons for case 1

            Invoke _DrawPoly, 120,  0, 200, 160, 80, 120, 8+6 ; bright yellow
            Invoke _DrawPoly, 160, 80, 120, 200,  0, 200, 8+2 ; bright green
            Invoke _DrawPoly, 200, 40, 160, 320, 20, 180, 8+1 ; bright blue

   TR0Done: Invoke _MoveScreen, VidGrSeg, SEG ScreenBuffer
            Call Kbdin ; Press any key
            JMP TRDone

TestR3:     ; Load a PCX File and show it on the screen
            GMODE
            Invoke _LoadPCX, Seg Background, ADDR PCXHorizon
            Invoke _MoveScreen, SEG ScreenBuffer, SEG Background
            Invoke _MoveScreen, VidGrSeg, SEG ScreenBuffer
            Call Kbdin
            JMP TRDone                                                    

TestR4:     ; Test keyboard handler
            TMODE
            Invoke _InstKey

            MOV CL,'*'  ; '*'   ; Indicate position with red *
            MOV CH,4    ; red

            MOV DL,' '  ; space ; Erase old position
            MOV DH,4    ; red
            MOV SI,0    ; Previous position 
                      

   KeyLoop: MOV AX, 160 ; Row * {-1,0,1}
            MUL YOffset
            MOV DI,AX

            MOV AX, 2   ; Col * {-1,0,1}
            MUL XOffset

            ADD DI,AX
            MOV ES:[SI+162],DX
            MOV ES:[DI+162],CX
            MOV SI,DI
            
            cmp     ExitFlag, 0
            je      KeyLoop
            Invoke  _DeInstallKey
            JMP TRDone

TestR5:     ; Everything
            GMODE
            Invoke _InstKey
            Invoke _LoadPCX, Seg Background, ADDR PCXHorizon
            mov     si, 0
            
    ReDraw: cmp     ExitFlag, 1
            je      TR4Done

            add     si, 1
            cmp     si, 320
            jbe     BackShift
            mov     si, 0

 BackShift: Invoke _AnimateScreen, SEG ScreenBuffer, SEG Background, SI

            mov     cx, XOffset
            mov     dx, YOffset

            add xl, cx ; horizontal pan
            add xr, cx

            sub xl, dx ; forward/back (zoom in/out)
            add xr, dx
            sub yt, dx
            add yb, dx
            sub ymt,dx
            add ymb,dx

            Invoke _DrawPoly,   0,  yt,  yb,  xl, ymt, ymb,   4 ; red
            Invoke _DrawPoly,  xl, ymt, ymb,  xr, ymt, ymb, 8+4 ; bright red
            Invoke _DrawPoly,  xr, ymt, ymb, 320,  yt,  yb,   4 ;  red

            call    WaitRetrace  ; Avoid flicker
            Invoke  _MoveScreen, VidGrSeg, SEG ScreenBuffer
            jmp     ReDraw

   TR4Done: Invoke  _DeInstallKey

TRDone:     ret

_TestRoutine endp



;====== SECTION 6: Main procedure =========================================

main	proc	far

        ; Run the program as 'MP4 n', where n = test case 1 .. 5 

        mov  si,82h  ; Read one-digit command line argument from PSP 
        mov  dl,[si] ; See Brey p.380 and Figure Appendix-A5 for details

        mov     ax, cseg  ; Initialize DS=CS
        mov     ds, ax

        MOV DH,0
        Invoke _TestRoutine, DX  ; Component test cases 1..5 

        ; Invoke is like CALL, but MASM will automatically generate
        ; the PUSH commands to put the values on the stack.

        Invoke  _mp4xit

main	endp

cseg    ends
	end	main
