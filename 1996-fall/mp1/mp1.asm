        PAGE 75, 132
        TITLE   MP1    your name       current date

COMMENT *
        This program computes class standings (grades) based on
        the raw scores for homeworks, machine problems, exams,
        and the final.  
	*

;====== SECTION 1: Define constants =======================================

	CR	EQU	0Dh
	LF	EQU	0Ah

;====== SECTION 2: Declare external procedures ============================

        extrn   binasc:near, dspmsg:near, dosxit:near  ; From lib291.lib
        extrn   printrec:near                          ; From libmp1.lib

;====== SECTION 3: Define stack segment ===================================

stkseg  segment stack                   ; *** STACK SEGMENT ***
        db      64 dup ('STACK   ')
stkseg  ends

;====== SECTION 4: Define code segment ====================================

cseg    segment public                  ; *** CODE SEGMENT ***
        assume  cs:cseg, ds:cseg, ss:stkseg, es:nothing

;====== SECTION 5: Declare variables for main procedure ===================
; Format of the gradebook database:
;   [Note that each record is 24 bytes long]
;
;            ID: 5 ASCII letters or numbers
;    hw0..final: 1-byte unsigned integers (array of 16 elements)
;           tot: 2-byte unsigned integer (calculated as per instructions)
;
;   ID,'$',hw0,hw1,hw2,hw3,hw4,hw5,mp0,mp1,mp2,mp4,mp5,mp6,e1,e1,final,tot

INCLUDE gbk.dta

; This directive inserts the contents of the file gbk.dta here.
; In this file, two variables are defined: gbk and numrec
;
; gbk is an array of 24-byte records holding raw scores
; numrec is defined as a 16-bit integer which stores the number of records

; This header should be the first line printed 
hdr db '-ID-- '
    db 'hw0 hw1 hw2 hw3 hw4 hw5 '
    db 'mp0 mp1 mp2 mp3 mp4 mp5 mp6 '
    db 'Ex1 Ex2 Fin Total',CR,LF,'$'

;====== SECTION 6: Main procedure =========================================

main    proc    far
        mov     ax, cseg                ; Initialize DS register
        mov     ds, ax

        ; Your code

        call    dosxit
main    endp


cseg    ends
        end     main
