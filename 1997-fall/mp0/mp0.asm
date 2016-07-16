	PAGE 75, 132
        TITLE   MP0     Your Name       current date

COMMENT *
        This program illustrates a (very) basic assembly program and
        the use of LIB291 input and output routines.
        Put your name in the places where it says 'your name' and also
        change the date where it says 'current date'.
        *

;====== SECTION 1: Define constants =======================================

	CR      EQU     0Dh
	LF      EQU     0Ah
	BEL     EQU     07h

;====== SECTION 2: Declare external procedures ============================

EXTRN   kbdine:near, dspout:near, dspmsg:near, dosxit:near

;====== SECTION 3: Define stack segment ===================================

STKSEG SEGMENT STACK                    ; *** STACK SEGMENT ***
	db      64 dup ('STACK   ')
STKSEG ENDS

;====== SECTION 4: Define code segment ====================================

CSEG SEGMENT PUBLIC                     ; *** CODE SEGMENT ***
ASSUME  cs:cseg, ds:cseg, ss:stkseg, es:nothing

;====== SECTION 5: Declare variables for main procedure ===================
var      db      0
question db      CR,LF,'What grade would you like in ECE291? ','$'
Exitmsg  db      CR,LF,'Good Luck!',CR,LF,'$'
invalid  db      CR,LF,'Not a valid choice! ',CR,LF,'$' 
Amsg     db      CR,LF,'Great! Comment code and turn work in early.',CR,LF,'$'
Bmsg     db      CR,LF,'Keep up in class and turn things in on time.',CR,LF,'$'
Dmsg     db      CR,LF,'Skip machine problems.',CR,LF,'$'
Fmsg     db      CR,LF,'Sleep through exams.',CR,LF,'$'


;====== SECTION 6: Main procedure =========================================

MAIN PROC FAR
     mov     ax, cs                  ; Initialize Default Segment register
     mov     ds, ax  
     mov     dx, offset question     ; Prompt user with question
     call    dspmsg                  
     call    kbdine                  ; Get keyboard character in AL
     mov     var,al                  ; Save result in a variable

CheckGrade:
     cmp     var, 'A'                ; Check if A student
     jne     NotGradeA
     mov     dx, offset Amsg         ; Print message for A students
     call    dspmsg
     jmp     mpExit

NotGradeA:
     cmp     var, 'B'                ; Check if B student
     jne     NotGradeB
     mov     dx, offset Bmsg         ; Print message for B students
     call    dspmsg
     jmp     mpExit

NotGradeB:
     cmp     var, 'D'                ; Check if D student
     jne     NotGradeD
     mov     dx, offset Dmsg         ; Print message for D students
     call    dspmsg
     jmp     mpExit

NotGradeD:
     cmp     var, 'F'                ; Check if F student
     jne     NotGradeF
     mov     dx, offset Fmsg         ; Print message for F students
     call    dspmsg
     jmp     mpExit

NotGradeF:
     mov     dl, BEL                 ; Ring the bell if other character
     call    dspout
     mov     dx, offset invalid      ; Print invalid message
     call    dspmsg
     jmp     FinalExit

mpExit:
     mov     dx, offset Exitmsg      ; Type out exit message
     call    dspmsg

FinalExit:
     call    dosxit                  ; Exit to DOS

MAIN ENDP

CSEG ENDS
END MAIN




