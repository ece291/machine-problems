; MP0 - Your Name - Today's Date
;
;       This program illustrates a (very) basic assembly program and
;       the use of LIB291 input and output routines.
;       By working on this code, you will have the opportunity to 
;       exercise the tools for this class, namely the editor, 
;       the Assembler (NASM), and the debugger (TD).
;       Be sure to put your name in the places where it says 'Your Name' 
;       and also  change the date where it says 'Today's Date'.  
;       The changes that you need to make to this program are 
;       described in the MP0 assignment page.

	BITS	16

;====== SECTION 1: Define constants =======================================

        CR      EQU     0Dh
        LF      EQU     0Ah
        BEL     EQU     07h

;====== SECTION 2: Declare external procedures ============================

EXTERN  kbdine, dspout, dspmsg, dosxit

;====== SECTION 3: Define stack segment ===================================

SEGMENT stkseg STACK                    ; *** STACK SEGMENT ***
        resb      64*8
stacktop:

;====== SECTION 4: Define code segment ====================================

SEGMENT code                            ; *** CODE SEGMENT ***

;====== SECTION 5: Declare variables for main procedure ===================
mygrade  db      0 
question db      'What grade would you like in ECE291? ','$'
Exitmsg  db      CR,LF,'Good Luck!',CR,LF,'$'
invalid  db      CR,LF,'Not a valid choice! ',CR,LF,'$' 
Amsg     db      CR,LF,'Learn all material and Submit MPs early.',CR,LF,'$'
Bmsg     db      CR,LF,'Keep up in class and submit MPs on time.',CR,LF,'$'
Dmsg     db      CR,LF,'Skip a few machine problems.',CR,LF,'$'
Fmsg     db      CR,LF,'Sleep through exams.',CR,LF,'$'


;====== SECTION 6: Program initialization =================================

..start:
        mov     ax, cs                  ; Initialize Default Segment register
        mov     ds, ax  
        mov     ax, stkseg              ; Initialize Stack Segment register
        mov     ss, ax
        mov     sp, stacktop            ; Initialize Stack Pointer register

;====== SECTION 7: Main procedure =========================================

MAIN:
        mov     dx, question            ; Prompt user with the grade question
        call    dspmsg                   
        call    kbdine   
        mov     [mygrade], al           ; Save result
            
.CheckGrade:
        cmp     byte [mygrade], 'A'     ; Check if A student
        jne     .NotGradeA
        mov     dx, Amsg                ; Print message for A students
        call    dspmsg
        jmp     .mpExit

.NotGradeA:
        cmp     byte [mygrade], 'B'     ; Check if B student
        jne     .NotGradeB
        mov     dx, Bmsg                ; Print message for B students
        call    dspmsg
        jmp     .mpExit

.NotGradeB:
        cmp     byte [mygrade], 'D'     ; Check if D student
        jne     .NotGradeD
        mov     dx, Dmsg                ; Print message for D students
        call    dspmsg
        jmp     .mpExit

.NotGradeD:
        cmp     byte [mygrade], 'F'     ; Check if F student
        jne     .NotGradeF
        mov     dx, Fmsg                ; Print message for F students
        call    dspmsg
        jmp     .mpExit

.NotGradeF:
        mov     dl, BEL                 ; Ring the bell if other character
        call    dspout
        mov     dx, invalid             ; Print invalid message
        call    dspmsg
        jmp     .FinalExit

.mpExit:
        mov     dx, Exitmsg             ; Type out exit message
        call    dspmsg

.FinalExit:
        call    dosxit                  ; Exit to DOS


