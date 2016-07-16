        PAGE 75, 132
        TITLE   MP2     your name       current date

CR      EQU 13
LF      EQU 10
ESCKEY  EQU 27
SPACE   EQU 32
SEMI    EQU 59

extrn dosxit:near, kbdine:near, dspmsg:near, binasc:near
extrn ReadInput:near  ; Remove this line to add your own procedure
extrn Calculate:near  ; Remove this line to add your own procedure
extrn DispOutput:near ; Remove this line to add your own procedure

;====== SECTION 3: Define stack segment ===================================
stkseg  segment stack                   ; *** STACK SEGMENT ***
        db      64 dup ('STACK   ')     ; 64*8 = 512 Bytes of Stack
stkseg  ends

;====== SECTION 4: Define code segment ====================================
cseg    segment public                  ; *** CODE SEGMENT ***
        assume  cs:cseg, ds:cseg, ss:stkseg, es:nothing

;====== SECTION 5: Declare variables ======================================

DispMode DW     10      ; Operate in decimal mode by default
crlf DB CR,LF,'$'       ; New Line

;====== SECTION 6: Main procedure =========================================

main    proc    far
        mov     ax, cseg   ; Initialize DS register
        mov     ds, ax

        MOV     DI, offset DispMode

Calc:   Call    ReadInput      ; Read Input from Keyboard
        MOV     DX,offset crlf
        call    dspmsg         ; New Line
        CMP     BH, ESCKEY     ; Quit When ESC is entered
        JE      Done
        CMP     BH, 'Q'        ; Also quit if Q is entered
        JE      Done
        Call    Calculate      ; Perform Math/Logical Calculation
        Call    DispOutput     ; Display number at top of stack
        JMP     Calc

Done:   call    dosxit                  ; Exit to DOS
main    endp
 
cseg    ends
        end     main

