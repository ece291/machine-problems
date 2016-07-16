; MP1 - Gradebook
;  Your Name
;  Today's Date
;
; Ryan Chmiel, Summer 2004
; University of Illinois, Urbana-Champaign
; Dept. of Electrical and Computer Engineering
;
; Version 1.0

	BITS	16

;====== SECTION 1: Define constants =======================================

        CR      	EQU     0Dh
        LF      	EQU     0Ah
	NUMSTUDENTS	EQU	30
	NUMRANGES	EQU	5

;====== SECTION 2: Declare external routines ==============================

; Declare external library routines
EXTERN dspmsg, mp1xit
EXTERN libCalculateScores, libCalculateRanges, libConstructStarString, libDisplayHistogram

; Declare local routines
GLOBAL CalculateScores, CalculateRanges, ConstructStarString, DisplayHistogram

; Make program variables global
GLOBAL Grades, IntroString, EnterString, StarString, RangeStrings, RangeCount
      
;====== SECTION 3: Define stack segment ===================================

SEGMENT stkseg STACK                    ; *** STACK SEGMENT ***
        resb      64*8
stacktop:
        resb      0                     ; work around NASM bug

;====== SECTION 4: Define code segment ====================================

SEGMENT code                            ; *** CODE SEGMENT ***

;====== SECTION 5: Declare variables for main procedure ===================

; These are the grades obtained by 30 sample students in ECE 291.
; Each row corresponds to one student.  The grades are listed as 
; follows:
;
;  HW0,HW1,HW2,HW3,HW4,HW5,HW6,MP0,MP1,MP2,MP3,MP4,EX1,EX2,FINAL,PROJECT,TOTAL
; 
; Note that the total is initially 0,0 as you need to reserve a word for the
; total (2 bytes), and you will need to calculate the total in your program.

Grades	db	20,20,20,20,20,61,20,30,53,71,84,80, 97,116,122,122,0,0
	db	20,20,20,20,20,61,20,30,60,60,84,90,120, 84,112,112,0,0
	db	20,20,20,20,20,20, 0,30,64,70,85,70, 73,104,134,134,0,0
	db	20,20,20,20,20,20,20,30,64,74,81,90, 91,106,120, 99,0,0
	db	20,20,20,15,20,20, 0,30,65,74,85,90, 85,109,143,154,0,0
	db	20,20,10, 0, 0, 5,20,30,40,35,65,60, 70, 62, 96,100,0,0
	db	20,20,20,20,20,73, 0,30,48,70,80,70, 73, 45,129,123,0,0
	db	20,20,17,20,20,20,20,30,65,80,85,90,110,105,139,128,0,0
	db	14,18,18,16,13,20, 5,30,50,70,80,84,119,103,124,103,0,0
	db	20,20,20,20,20,20,20,30,55,73,85,80, 59, 66,115,120,0,0
	db	20,20,20,17,16,20, 2,30,50,70,80,90, 92, 99,115,130,0,0
	db	20,20,20,20,20,20,20,30,65,80,85,90,101,102,113,134,0,0
	db	20,20,20,20,20,20, 7,30,55,75,85,90, 78, 84,124,145,0,0
	db	20,10,20,20,20,20,20,30,49,72,80,80, 77, 89,134,114,0,0
	db	20,20,20,20,20,20,20,20,62,72,60,90, 90, 97,132,133,0,0
	db	20,20,20,20,19, 0, 0,20,54,74,70,70, 74,101,121, 80,0,0
	db	16,19,18,17,16,15, 0,20,50,71,81,80,104, 75,125,126,0,0
	db	20,20,20,20,20,20,20,30,55,75,84, 0,112,107,136,155,0,0
	db	20,20,20,11,20,12, 0,30,49,44,79,90,106,103,101,119,0,0
	db	20,20,20,20,20,20,20,20,20,40,40,70, 84,117,110,115,0,0
	db	20,20,20,20,20,20,20,20,46,75,82,70,106, 96,122,153,0,0
	db	20,18, 7, 0,20,20,20,20,46,70,78,30,118,108,132,131,0,0
	db	20,20,20, 0,20,20, 0,30,55,75,85,90,101,108,141,151,0,0
	db	20,20,20,20,20,73,20, 0,47,73,81,90, 67, 79,131,128,0,0
	db	20,20,20,20,20,20,20,30,52,72,80,90, 94, 86,146,111,0,0
	db	20,20,20,20,20,20,20,20,55,70,81,90, 46, 99,129,134,0,0
	db	20,20,20,20,20,20,20,20,51,71,81,70,108,104,131,120,0,0
	db	20,20,20,20,63,52,10,30,55,70,80,60,104, 86,114,121,0,0
	db	20, 0, 0,20,20,20, 9,20,48,70,79,55, 81,119,109,107,0,0
	db	20,20,20,20,20,20,20,30,20,40,40,50,120,100,150,160,0,0

IntroString	db	CR,LF,'ECE 291 Summer 2004',CR,LF,'MP1 - Gradebook',CR,LF,CR,LF,'$'

; Mimics hitting the enter key
EnterString	db	CR,LF,'$'
	 
; String used to hold one bar of the histogram.  The string will contain up to 
; 30 stars (*) followed by a dollar sign to terminate the string
StarString	times 31 db 0

; Strings to define the grade ranges
RangeStrings	db	' (A) 900-1000  ','$'
		db	' (B) 800-899   ','$'
		db	' (C) 700-799   ','$'
		db	' (D) 600-699   ','$'
		db	' (F) < 600     ','$'

; Array holding the number of scores that fall into each of the ranges above.
; The number of A grades is stored in the first cell of the array, and so on...
RangeCount	times 5 db 0   

;====== SECTION 6: Program initialization =================================

..start:
        mov     ax, cs                  ; Initialize Default Segment register
        mov     ds, ax  
        mov     ax, stkseg              ; Initialize Stack Segment register
        mov     ss, ax
        mov     sp, stacktop            ; Initialize Stack Pointer register

;====== SECTION 7: Main procedure =========================================

MAIN:
	mov	dx, IntroString
	call	dspmsg
				       
	call	CalculateScores
	call	CalculateRanges
	call	DisplayHistogram

        call    mp1xit

;====== SECTION 8: Your subroutines =======================================

;--------------------------------------------------------------
;--          Replace library calls with your code!           --
;--          [Save all reg values that you modify]           --
;--          Do not forget to add function headers           --
;--------------------------------------------------------------

;--------------------------------------------------------------
;--                    CalculateScores()                     --
;--------------------------------------------------------------
CalculateScores
	call	libCalculateScores
	ret

;--------------------------------------------------------------
;--                    CalculateRanges()                     --
;--------------------------------------------------------------
CalculateRanges
	call	libCalculateRanges
	ret

;--------------------------------------------------------------
;--                  ConstructStarString()                   --
;--------------------------------------------------------------
ConstructStarString
	call	libConstructStarString
	ret

;--------------------------------------------------------------
;--                   DisplayHistogram()                     --
;--------------------------------------------------------------
DisplayHistogram
	call	libDisplayHistogram
	ret















