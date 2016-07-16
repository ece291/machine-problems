PAGE    70, 140
TITLE   MP2 - [Sorting Efficiency]  Your Name   Today's Date

COMMENT *
        In this MP, you will write a program which 
        will take input from the keyboard and sort
        it using two different algorithms
        
        ECE291 - Machine Problem 2
        Professor Polychronopoulos
        Guest Authors - Karan Mehra, Michael Urman
        Univeristy of Illinois Urbana Champaign
        Dept. of Electrical & Computer Engineering
        Spring 2000
        
        Ver 1.0
        *

;--------------------------------------------------------------
;--                   Defining  Constants                    --
;--------------------------------------------------------------

        BELL        EQU     007h
        BS          EQU     008h
        TAB         EQU     009h
        LF          EQU     00Ah
        CR          EQU     00Dh
        SPACE       EQU     020h
        ESCKEY      EQU     01Bh
        INPUT_SIZE  EQU     0078

        public  BELL, BS, TAB, LF, CR
        public  SPACE, ESCKEY, INPUT_SIZE

;--------------------------------------------------------------
;--               Declaring External Procedures              --
;--------------------------------------------------------------

;       Functions in LIB291.LIB These functions are free to 
;       be used by you. Complete descriptions of the LIB291
;       functions can be found in your lab manuals. Use these
;       functions for displaying output on the screen.

        extrn dspmsg:near, dspout:near, kbdin:near
        extrn rrest:near, rsave:near, binasc:near

;       Functions in LIBMP2.LIB
;       You will need to write these functions for this program.

        extrn libSortHeap:near, libPercolate:near, libQuickSort:near
        extrn libTakeInput:near, libGetArray:near, libPrintList:near

;       This function terminates the program.
        extrn mp2xit:near

;--------------------------------------------------------------
;--                Defining the Stack Segment                --
;--------------------------------------------------------------

stkseg SEGMENT stack
        db  64 dup ('STACK  ')
stkseg ENDS

;--------------------------------------------------------------
;--                 Defining the Code Segment                --
;--------------------------------------------------------------

cseg SEGMENT PUBLIC 'CODE'
        assume cs:cseg, ds:cseg, ss:stkseg, es:nothing

;--------------------------------------------------------------
;--           Declaring variables for Lib Procedures         --
;--------------------------------------------------------------

enterK      db  CR,LF,'$'                   ; Helps in formating the output
input       db  80 dup(0)                   ; Our Input Buffer
list        db  80 dup(0)                   ; Unsorted Array of characters
list_size   db  0                           ; Number of characters in the list
dbug        dw  0                           ; Debug Level -     
                                            ;             0 is result ONLY
                                            ;             1 is debug without step
                                            ;             2 is debug with step
swapMsg     db  '   Swapping ','$'
cmpMsg      db  '  Comparing ','$'
cmpCtr      dw  0                           ; Counter for number of comparisions
swpCtr      dw  0                           ; Counter for number of swaps

public  input, list, list_size, dbug, enterK
public  swapMsg, cmpMsg, cmpCtr, swpCtr
public  Percolate, QuickSort, PrintList

;--------------------------------------------------------------
;--           Declaring variables for Main Procedure         --
;--------------------------------------------------------------

menu        db  CR,LF,0C9h,28 dup (0CDh), 0B5h,'SORTING  EFFICIENCY',0C6h,28 dup (0CDh),0BBh,CR,LF
            db  0BAh,'                                                                             ',0BAh,CR,LF 
            db  0BAh,'                               H E A P S O R T                               ',0BAh,CR,LF
            db  0BAh,'                                                                             ',0BAh,CR,LF
            db  0BAh,'                       HR : Displays final result only                       ',0BAh,CR,LF
            db  0BAh,'                       HD : Shows debugging information                      ',0BAh,CR,LF
            db  0BAh,'                       HS : Steps through the action                         ',0BAh,CR,LF
            db  0BAh,'                                                                             ',0BAh,CR,LF
            db  0BAh,'                              Q U I C K S O R T                              ',0BAh,CR,LF 
            db  0BAh,'                                                                             ',0BAh,CR,LF
            db  0BAh,'                       QR : Displays final result only                       ',0BAh,CR,LF
            db  0BAh,'                       QD : Shows debugging information                      ',0BAh,CR,LF
            db  0BAh,'                       QS : Steps through the action                         ',0BAh,CR,LF
            db  0BAh,'                                                                             ',0BAh,CR,LF
            db  0BAh,'                                M  : MP2 MENU                                ',0BAh,CR,LF
            db  0BAh,'                               ESC : EXIT MP2                                ',0BAh,CR,LF 
            db  0BAh,'                                                                             ',0BAh,CR,LF
            db  0C8h, 68 dup(0CDh),0B5h,0E4h,9Bh,0EEh,' 291',0C6h,0BCh,CR,LF
            db  CR,LF,'$'
prompt      db  ':','$'

buf         db  7 dup(0)                            ; Needed to convert Binary to Ascii [binasc]
sortM       db  'HhQqMm'                            
sortT       db  'RrDdSs'                            
qMsg        db  'Initiating QuickSort',CR,LF,'$'
hMsg        db  'Initiating HeapSort',CR,LF,'$' 
cMsg        db  'Number of comparisions: ','$' 
sMsg        db  'Number of swaps: ','$'        
doneMsg     db  'Sorted Array is ','$'              
errMsg      db  CR,LF,'Invalid Option!',CR,LF,'$'   

;--------------------------------------------------------------
;--                       Main Procedure                     --
;--------------------------------------------------------------

MAIN PROC FAR
        mov     ax, cseg                 
        mov     ds, ax                      ; Initialize ds => cs

drawMain:
        mov     dx, offset menu             ; display our menu
        call    dspmsg
        
getInput:
        mov     dx, offset prompt
        call    dspmsg

        call    TakeInput                   ; obtain one line of input
        jc      exitMain

        xor     si, si
        mov     cx, 6

validate1:                                  ; parce the sorting technique
        mov     dl, sortM[si]
        inc     si
        cmp     input[0], dl
        je      checkType
        loop    validate1

invalidChoice:                              ; trap for invalid options
        mov     dx, offset errMsg
        call    dspmsg
        jmp     getInput

checkType:                                  
        dec     si
        shr     si, 1
        mov     ax, si                      ; save the sorting technique in AX
        cmp     ax, 2
        je      drawMain
        mov     si, 0
        mov     cx, 6

validate2:                                  ; parce the level of debug required
        mov     dl, sortT[si]
        inc     si
        cmp     input[1], dl
        je      validated
        loop    validate2

        jmp     invalidChoice

validated:                                  
        dec     si
        shr     si, 1
        mov     dbug, si
        mov     bx, 2
        cmp     input[bx], SPACE            ; third character should be a SPACE
        jne     invalidChoice

ignoreSpaces:                               ; move BX to the first valid character
        inc     bx
        cmp     input[bx], SPACE
        je      ignoreSpaces
        
        cmp     input[bx], '$'
        je      invalidChoice

        mov     dx, offset enterK
        call    dspmsg

        call    GetArray                    ; fill in the list array with our characters
        
        cmp     ax, 0                       ; is it heap?
        je      doHeap

doQuick:
        mov     dx, offset qMsg
        call    dspmsg
        mov     cl, list_size               ; right
        push    cx
        mov     cx, 1                       ; left
        push    cx
        call    Quicksort
        pop     cx
        pop     cx
        jmp     doneSort

doHeap:
        mov     dx, offset hMsg
        call    dspmsg
        call    SortHeap

doneSort:
        mov     dx, offset doneMsg
        call    dspmsg
        mov     dbug, 1                     ; set debug level so that we 
        call    PrintList                   ; can display the final result
        
        mov     dx, offset cMsg
        call    dspmsg
        
        mov     bx, offset buf
        mov     ax, cmpCtr
        call    binasc
        
        mov     dx, bx
        call    dspmsg

        mov     dx, offset enterK
        call    dspmsg

        mov     dx, offset sMsg
        call    dspmsg
        
        mov     bx, offset buf
        mov     ax, swpCtr
        call    binasc
        
        mov     dx, bx
        call    dspmsg

        mov     dx, offset enterK
        call    dspmsg

        jmp     getInput

exitMain:
        call    mp2xit

MAIN ENDP

;--------------------------------------------------------------
;--             Replace Library Calls with your Code!        --
;--             [Save all reg values that you modify]        -- 
;--             Do not forget to add Function Headers        --
;--------------------------------------------------------------

;--------------------------------------------------------------
;--                        SortHeap()                        --
;--------------------------------------------------------------

SortHeap PROC NEAR

        call    libSortHeap
        ret

SortHeap ENDP

;--------------------------------------------------------------
;--                        Percolate()                       --
;--------------------------------------------------------------

Percolate PROC NEAR

        call    libPercolate
        ret

Percolate ENDP

;--------------------------------------------------------------
;--                        QuickSort()                       --
;--------------------------------------------------------------

QuickSort PROC NEAR

        call    libQuickSort
        ret

QuickSort ENDP

;--------------------------------------------------------------
;--                        TakeInput()                       --
;--------------------------------------------------------------

TakeInput PROC NEAR

        call    libTakeInput
        ret

TakeInput ENDP

;--------------------------------------------------------------
;--                         GetArray()                       --
;--------------------------------------------------------------

GetArray PROC NEAR

        call    libGetArray
        ret

GetArray ENDP

;--------------------------------------------------------------
;--                        PrintList()                       --
;--------------------------------------------------------------

PrintList PROC NEAR

        call    libPrintList
        ret

PrintList ENDP

CSEG ENDS
     END    MAIN
