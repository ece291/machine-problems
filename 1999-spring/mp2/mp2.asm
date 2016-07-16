        PAGE 75, 132
        TITLE   MP2     your name       current date

COMMENT % RPN Calculator

          ECE291: Machine Problem 2
          Prof. John W. Lockwood
          University of Illinois
          Dept. of Electrical & Computer Engineering
          Spring 1999
          
          Ver. 2.1
        %

;====== Constants ========================================================
CR      EQU 13
LF      EQU 10
BSKEY   EQU 8
ESCKEY  EQU 27
SPACE   EQU 32
SEMI    EQU 59

;====== External Functions ===============================================
;-- Lib291 Calls --
extrn kbdine:near, dspmsg:near, binasc:near, dspout:near

;-- LibMP2 Calls --
extrn LibProcessInput:near ; Your code will replace the call to this function
extrn LibCalculate:near    ; Your code will replace the call to this function
extrn LibFormatOutput:near ; Your code will replace the call to this function
extrn mp2xit:near

;====== Stack ============================================================
stkseg  segment stack                   ; *** STACK SEGMENT ***
        db      64 dup ('STACK   ')     ; 64*8 = 512 Bytes of Stack
stkseg  ends

;====== Begin Code/Data ===================================================
cseg    segment public 'CODE'           ; *** CODE SEGMENT ***
        assume  cs:cseg, ds:cseg, ss:stkseg, es:nothing

;====== Variables =============

DispMode DW     10      ; Operate in decimal mode by default
crlf DB CR,LF,'$'       ; New Line

HelpMsg  db '============ ECE291 RPN Calculator ============',CR,LF
         db 'Enter Number                               -or-',CR,LF
         db '      Operation (+,-,*,/,%,!,N,&,|,^,~)    -or-',CR,LF
         db '      Mode (MD=Decimal, MH=Hex, MB=Binary) -or-',CR,LF
         db '      Quit (ESC, Q, or q)',CR,LF
         db '============ Lockwood: Spring 1999 ============',CR,LF,CR,LF,'$'

ResultMsg db 'Result: ','$'   ; Message displayed on screen before output

OutputBuffer db 16 dup(?),'$' ; Contains formatted output 
                              ; (Should be terminated with '$')

MAXBUFLENGTH EQU 80           ; Maximum length of an input line
InputBuffer  db MAXBUFLENGTH dup(?),'$' ; Contains one line of user input
BufLength    dw ?                       ; Actual Length of InputBuffer

PUBLIC DispMode, InputBuffer, BufLength, OutputBuffer ; Needed by LIBMP2

;====== Your procedures =======

ProcessKey PROC NEAR
 ; Input:
 ;    Register AL == ASCII code for key that was entered
 ;    (value of register AL must be preserved)
 ; Output:
 ;    Variable InputBuffer == String containing one line of input
 ; Input/Output:
 ;    BufLength == Length of InputBuffer
 ; Purpose:
 ;    Enqueue each character entered from the keyboard
 ;    into a string called 'InputBuffer'.
 ;    
 ; Note:
 ;    This code is given to you for free as an example
 ;    of how to write function headers, label jumps, and comment your code.
 ;

        MOV     DI, BufLength        ; Load existing string length

        CMP     AL,BSKEY             ; Check if user hit 'Back space' key
        JE      ProcessBackSpaceKey

        CMP     DI, MAXBUFLENGTH     ; Avoid Buffer Overflow!
        JAE     ProcessKeyFinished

        MOV     InputBuffer[DI],AL   ; Append input letter to buffer 

        INC     BufLength            ; Proceed to next byte.

  ProcessKeyFinished:
        RET

  ProcessBackSpaceKey:
        CMP DI,0                    ; If string is not already empty .. 
        JE ProcessKeyFinished
        DEC BufLength  
        RET                         ; .. make it 1 byte shorter 

ProcessKey ENDP

; ------------------

ProcessInput PROC Near
        ; Write Your code here !
        RET
ProcessInput ENDP

; ------------------

FormatOutput PROC Near
        ; Write Your code here !
        RET
FormatOutput ENDP

; ------------------

Calculate PROC Near
        ; Write Your code here !
        RET
Calculate ENDP


;====== Main procedure =========


main      proc    far
          mov     ax, cseg   ; Initialize DS register
          mov     ds, ax

          MOV     DX, offset HelpMsg ; Print on-line help
          CALL    DSPMSG

MainLoop:   ; --- Main body of program ---

          MOV    BufLength, 0   

KeyLoop:  Call   KBDINE              ; Read keyboard input

          Call   ProcessKey          ; -- Process Keyboard Input ---
          CMP    AL,ESCKEY
          JE     Done                ; Quit instantly for ESCAPE key
          CMP    AL,13
          JNE KeyLoop                ; Continue reading until end-of-line

          MOV    DX, offset crlf     ; Skip a line
          CALL   DSPMSG 

          Call    LibProcessInput    ; -- Process InputBuffer --
                                     ; (Replace with your 'Call ProcessInput')

          CMP    BH,'Q'
          JE     Done                ; Quit for 'Q' or 'q' command
          CMP    BH,'q'
          JE     Done


          Call    LibCalculate       ; -- Perform Math/Logical Calculation --
                                     ; (Replace with your 'Call Calculate')


          Call    LibFormatOutput    ; -- Format number at top of stack --
                                     ; (Replace with your 'Call FormatOutput')


          MOV     DX, Offset ResultMsg
          Call    DSPMSG             ; Print 'Result: '
          MOV     DX, Offset OutputBuffer
          Call    DSPMSG             ; Print formatted output 
          MOV     dx,offset crlf
          call    DSPMSG             ; Print New line

          JMP     MainLoop

Done:     call    mp2xit             ; Exit program

main    endp
 
cseg    ends
        end     main

