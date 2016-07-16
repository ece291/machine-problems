        TITLE ECE291: Big Calculator - Your Name - Date

COMMENT *
        Big Calculator

        For this MP, you will write an interactive program which
        performs simple mathematical calculations on large numbers.

        ECE291: Machine Problem 2
        Jay R. Moorman
        University of Illinois
        Dept. of Electrical & Computer Engineering
        Summer 1999

        Ver 1.0
        *

;====== Constants =========================================================

NULL    EQU 0
BEEP    EQU 7
BS      EQU 8
CR      EQU 13
LF      EQU 10
EOS     EQU 24

ESCKEY  EQU 27
SPACE   EQU 32

MaxLength     EQU 40 ; Limit input numbers 
PUBLIC MaxLength     ; Declare public for library use

;====== Externals =========================================================

; -- LIB291 Routines (Free) ---

extrn kbdine:near, kbdin:near, dspout:near   ; LIB291 Routines
extrn dspmsg:near, binasc:near, ascbin:near  ; (Always Free)

extrn mp2xit:near ; Exit program with a call to this procedure

; -- LIBMP2 Routines (Replace these with your own code) ---

extrn LibGetOperand:near        ; Get operand via user input
extrn LibShowString:near        ; Output a string number to screen
extrn LibShowOperands:near      ; Output operands to screen
extrn LibCompare:near           ; Compare two operands
extrn LibLogicOperations:near   ; Perform Logic comparisons
extrn LibAddCore:near           ; Core math of add procedure
extrn LibAddOperation:near      ; Procedure to add two operands
extrn LibSubtractOperation:near ; Procedure to subtract two operands


;====== SECTION 3: Define stack segment ===================================
stkseg  segment stack                   ; *** STACK SEGMENT ***
        db      64 dup ('STACK   ')     ; 64*8 = 512 Bytes of Stack
stkseg  ends

;====== SECTION 4: Define code segment ====================================
cseg    segment public  'CODE'          ; *** CODE SEGMENT ***
        assume  cs:cseg, ds:cseg, ss:stkseg, es:nothing

;====== SECTION 5: Variables ==============================================

; First byte is reserved for the sign
Op1    db   0,MaxLength-1 dup(?),EOS     ; String for operand 1
Op2    db   0,MaxLength-1 dup(?),EOS     ; String for operand 2
Result db   0,(2*MaxLength)-1 dup(?),EOS ; String for resulting calculation

crlf    db CR,LF,'$' ; Carriage return + Linefeed for new line
PBuf    db 7 dup(?)

MenuMessage db CR,LF
        db  '------------- MP2 Menu -------------',CR,LF
        db  '  Enter:  Operand(1)    Operand(2)'  ,CR,LF
        db  '          (S)how Operands'           ,CR,LF,CR,LF
        db  '  Logical Operations:'               ,CR,LF
        db  '          (>) Greater Than'          ,CR,LF
        db  '          (=) Is Equal'              ,CR,LF,CR,LF
        db  '  Mathematical Operations:'          ,CR,LF
        db  '          (+) Addition'              ,CR,LF
        db  '          (-) Subtraction'           ,CR,LF,CR,LF
        db  '  Redisplay (M)enu'                  ,CR,LF,CR,LF
        db  '------ [ESC] or (Q)uit = exit ------',CR,LF,'$'
Prompt      db '>','$'

OpMsg     db CR,LF,'Operand: ','$'
Op1Msg    db CR,LF,'Operand 1: ','$'
Op2Msg    db CR,LF,'Operand 2: ','$'
LogicMsg1 db CR,LF,'The operands are equal ','$'
LogicMsg2 db CR,LF,'The operands are not equal ','$'
LogicMsg3 db CR,LF,'Operand1 is greater than Operand2 ','$'
LogicMsg4 db CR,LF,'Operand1 is not greater than Operand2 ','$'
AddMsg    db CR,LF,'Addition Result: ','$'
SubMsg    db CR,LF,'Subtraction Result: ','$'


PUBLIC Result

; Tables
InputTable db ESCKEY,'Q','q','M','m'
           db '1','2','S','s'
           db '>','=','+','-'
           db Null

JmpTable   dw offset MainDone
           dw offset MainDone
           dw offset MainDone
           dw offset DisplayMenu
           dw offset DisplayMenu
           dw offset GetOp1
           dw offset GetOp2
           dw offset ShowOp
           dw offset ShowOp
           dw offset LogicOp
           dw offset LogicOp
           dw offset AddOp
           dw offset SubOp

;====== Procedures ========================================================


; Your Subroutines go here !
; ---- ----------- -- ----

;--------------------------------------------------------
; Procedure to get a new operand from the user
;       Only allow valid input numbers
;       Must accept negative numbers
;       Allow backspace, but not past beginning of string
;       Don't allow greater than MaxLength characters
;       All input characters should be converted
;               to decimal numbers
; Input:  SI = offset of string to input number
; Output: 
;         
; Destroys: 
; Calls:
;--------------------------------------------------------

GetOperand Proc NEAR

        call LibGetOperand      ; Comment out and replace with your own code

        ret
GetOperand ENDP


;--------------------------------------------------------
; Procedure to show a string
; Input:  SI = offset of string
; Output: String to display
;         
; Destroys:
; Calls:
;--------------------------------------------------------

ShowString Proc NEAR

        call LibShowString      ; Comment out and replace with your own code

        ret
ShowString ENDP


;--------------------------------------------------------
; Procedure to show operands
; Input:  SI = offset of operand 1
;         DI = offset of operand 2
; Output: 
;         
; Destroys: 
; Calls: ShowString
;--------------------------------------------------------

ShowOperands Proc NEAR

        call LibShowOperands    ; Comment out and replace with your own code

        ret
ShowOperands ENDP


;--------------------------------------------------------
; Procedure to compare two operands
; Input:  SI = offset of operand 1
;         DI = offset of operand 2
; Output: DL = 1  if Op1 > Op2
;            = 0  if Op1 = Op2
;            = -1 if Op1 < Op2
;
; Destroys: DX
; Calls:
;--------------------------------------------------------

Compare Proc NEAR

        call LibCompare         ; Comment out and replace with your own code

        ret
Compare ENDP


;--------------------------------------------------------
; Procedure to see if two operands are equal or greater than
;    each other.
; Input:  SI = offset of operand 1
;         DI = offset of operand 2
;         AL = '=' for IsEqual
;         AL = '>' for GreaterThan
; Output: Correct message output to screen
;         
; Destroys: 
; Calls: Compare
;--------------------------------------------------------

LogicOperations Proc NEAR

        call LibLogicOperations ; Comment out and replace with your own code

        ret
LogicOperations ENDP


;--------------------------------------------------------
; Core add procedure
; Input:  SI = offset of operand 1
;         DI = offset of operand 2
; Output: Correct result put in Result variable
;         
; Destroys: 
; Calls: Compare
;--------------------------------------------------------

AddCore Proc NEAR

        call LibAddCore         ; Comment out and replace with your own code

        ret
AddCore ENDP


;--------------------------------------------------------
; Procedure to add two operands
; Input:  SI = offset of operand 1
;         DI = offset of operand 2
; Output: Correct result output to screen
;         
; Destroys: 
; Calls: AddCore, ShowString
;--------------------------------------------------------

AddOperation Proc NEAR

        call LibAddOperation    ; Comment out and replace with your own code

        ret
AddOperation ENDP


;--------------------------------------------------------
; Procedure to subtract two operands
; Input:  SI = offset of operand 1
;         DI = offset of operand 2
; Output: Correct result output to screen
;         
; Destroys: 
; Calls: AddCore, ShowString
;--------------------------------------------------------

SubtractOperation Proc NEAR

        call LibSubtractOperation ; Comment out and replace with your own code

        ret
SubtractOperation ENDP


;====== Main procedure ====================================================

main    Proc FAR
        mov  ax, cseg
        mov  ds, ax

DisplayMenu:
        mov  dx, offset MenuMessage
        call dspmsg                     ; Display Menu

MainLoop:
        mov  dx, offset crlf
        call dspmsg
        mov  dx, offset Prompt
        call dspmsg

MainRead:
        mov  bx,0                       ; Initialize to check input
        mov  si, offset Op1             ; Assume Op1 operation Op2
        mov  di, offset Op2
        call kbdin                      ; Read Input

LpRead: cmp  InputTable[bx],Null        ; Check if end of table
        je   MainRead                   
        cmp  al,InputTable[bx]          ; Check for key match
        je   MatchGood
        inc  bx                         ; Check next
        jmp  LpRead

MatchGood:
        mov  dl,al                      ; Output character
        call dspout
        shl  bx,1                       ; Multiply by 2
        jmp  JmpTable[bx]               ; Jump to proper address


GetOp1: call GetOperand
        jmp  MainLoop

GetOp2: mov  si, offset Op2
        call GetOperand
        jmp  MainLoop

ShowOp: call ShowOperands
        jmp  MainLoop

LogicOp:
        call LogicOperations
        jmp  MainLoop

AddOp:  call AddOperation
        jmp  MainLoop
SubOp:  call SubtractOperation
        jmp  MainLoop


MainDone:
        call mp2xit                     ; Exit to DOS

main    endp

cseg    ends
        end     main

                 
                  
