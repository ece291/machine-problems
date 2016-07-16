TITLE ECE291:MP3-Calculator GUI - Your Name - Date

COMMENT % A GUI for MP2's RPN Calculator

          ECE291: Machine Problem 3
          Prof. John W. Lockwood
          Guest Author: Josh Scheid
          University of Illinois
          Dept. of Electrical & Computer Engineering
          Spring 1999
          
          Ver. 1.1
        %

;====== Constants =========================================================

;ASCII values for common characters
BEEP    EQU 7
CR      EQU 13
LF      EQU 10
ESCKEY  EQU 27
BSKEY   EQU 8
SEMI    EQU 59
SPACE   EQU 32

;====== Externals =========================================================

; -- LIB291 Routines (Free) ---
extrn dspmsg:near, dspout:near, kbdin:near
extrn rsave:near, rrest:near, binasc:near

; -- LIBMP3 Routines (Your code will replace calls to these functions) ---

extrn LibKbdInstall:near
extrn LibKbdUninstall:near
extrn LibKbdHandler:near

extrn LibMouseInstall:near
extrn LibMouseUninstall:near
extrn LibMouseHandler:near

extrn LibDrawScreen:near
extrn LibWaitForInput:near
extrn LibDisplayResult:near

extrn LibMP3Main:near

extrn MP3XIT:near           ; Exit program with a call to this procedure

; Routines from LIBMP2
extrn LibProcessInput:near
extrn LibCalculate:near
extrn LibFormatOutput:near

;====== Stack ========================================================
stkseg  segment stack                   ; *** STACK SEGMENT ***
        db      64 dup ('STACK   ')     ; 64*8 = 512 Bytes of Stack
stkseg  ends

;====== Begin Code/Data ==============================================
cseg    segment public  'CODE'    ; *** CODE SEGMENT ***
        assume  cs:cseg, ds:cseg, ss:stkseg, es:nothing

;====== Variables ====================================================

inputValid      db  0           ; 0: InputBuffer is not ready
                                ; 1: InputBuffer is ready
                                ;-1: Esc key pressed

oldKbdV         dd  ?           ;far pointer to default keyboard
                                ;  interrupt function

DispMode        dw  10          ; Operate in decimal mode by default


bottomOfStack   dw  0           ; Offset of stack at beginning of program
                                ; Used to calculate current number of 
                                ; operands on the stack
                                
operandsStr     db  'Operands: ','$'                                


OutputBuffer    db 16 dup(?),'$' ; Contains formatted output
                                 ; (Should be terminated with '$')
                                 
MAXBUFLENGTH    EQU 24
InputBuffer     db  MAXBUFLENGTH dup(?),'$' ; Contains one line of user input
BufLength       dw  ?                       ; Actual length of InputBuffer

include calcskin.dat            ; 2000 byte character array to define a
                                ; 40x25 screen

PUBLIC DispMode, InputBuffer, BufLength, OutputBuffer   ; Needed by LIBMP2/3
PUBLIC inputValid, oldKbdV, bottomOfStack, operandsStr  ; Needed by LIBMP3
PUBLIC calcskin                                         ; Needed by LIBMP3

                                   
;====== Procedures ========================================================

KbdInstall PROC NEAR

    ; Your code here
    
KbdInstall ENDP

;------------------------------------------------------------------------

KbdUninstall PROC NEAR

    ; Your code here
    
KbdUninstall ENDP

;------------------------------------------------------------------------

KbdHandler PROC NEAR

    ; Your code here
    
KbdHandler ENDP

;------------------------------------------------------------------------

MouseInstall PROC NEAR

    ; Your code here
    
MouseInstall ENDP

;------------------------------------------------------------------------

MouseUninstall PROC NEAR

    ; Your code here
    
MouseUninstall ENDP

;------------------------------------------------------------------------

MouseHandler PROC NEAR

    ; Your code here

MouseHandler ENDP

;------------------------------------------------------------------------

DrawScreen PROC NEAR

    ; Your code here
   
DrawScreen ENDP

;------------------------------------------------------------------------

WaitForInput PROC NEAR

    ; Your code here
    
WaitForInput ENDP

;------------------------------------------------------------------------

DisplayResult PROC NEAR

    ; Your code here

DisplayResult ENDP

;------------------------------------------------------------------------

MP3Main PROC NEAR

    ; Your code here

MP3Main ENDP

;====== Main Procedure ====================================================

MAIN    PROC    FAR

        MOV     AX, CSEG     ; Use common code and data segment
        MOV     DS, AX

        MOV     AX, 0B800h   ; Use extra segment to access video screen
        MOV     ES, AX

        MOV     AX, 0000h    ; Put display into 40x25 text mode
        INT     10h

        MOV     AH, 01h      ; hide text cursor
        MOV     CX, 2000h
        INT     10h

        CALL    LibMP3Main              ; Replace this call with a call to
                                        ; your MP3Main routine.
                                        ; Add nothing else to MAIN                                       

        ; Start your coding by writing main with all LIB routines
        ;
        ; ---------------- Pseudo-code for main ---------------
        ;
        ; Install Mouse and Keyboard handlers
        ; Draw initial screen
        ; Record initial stack pointer
        ;
        ; Loop {
        ;    Wait for user to finish entering string from keyboard or mouse
        ;     ..
        ;    Process the input text
        ;    Calculate Result
        ;    Format the Output
        ;    Display the result
        ;  }
        ;
        ; Un-install Mouse and Keyboard handlers
        
        CALL    MP3XIT                  ; Exit to DOS

MAIN    ENDP

CSEG    ENDS
        END     MAIN
