        PAGE 75, 132
        TITLE Deep291 - Your Name - Current Date

COMMENT %
        WordFind
        --------------------
        ECE291: MP1 - Deep 291
        Prof. John W. Lockwood
        Unversity of Illinois, Dept. of Electrical & Computer Engineering
        Assistant Guest Authors: Pat Spizzo, Neil Kumar
        Fall 1998
        Revision 1.0
        %

;====== Constants =========================================================

CR      EQU 13
LF      EQU 10

;====== Externals =========================================================

; -- LIB291 Routines (free) --

  extrn dspout:near  ; See your lab manual for a full description
  extrn dspmsg:near  ; of the ECE291 lib291 functions
  extrn dosxit:near  ; Quit to DOS

; -- LIB291 Routines (free) --
  extrn mp1xit:near  ; Terminate MP1

;====== Stack Segment =====================================================
stkseg  segment stack
        db 64 dup ('STACK   ')
stkseg  ends

;====== Code/Data segment =================================================
cseg    segment public 'CODE' 
        assume  cs:cseg, ds:cseg, ss:stkseg, es:nothing

;====== Variables =========================================================

INCLUDE wordfile.asm   ; Define NumRows & NumCols; Create OrigMatrix

EndMatrix db NumRows*NumCols dup ('.')
RowSize   dw NumRows
ColSize   dw NumCols

CommandErrorMessage db 'Usage: mp1 WordToFind',CR,LF,'$' 
StartMessage db '------------- Original matrix ------------',CR,LF,'$'
EndMessage   db '-------------- Final matrix --------------',CR,LF,'$'
crlf db CR,LF,'$'  ; Carriage Return / Line Feed String

WordLength dw ?        ; Length of search word
RowPos dw ?
ColPos dw ?
offsetPos dw ?

PUBLIC OrigMatrix,RowSize,ColSize,EndMatrix ; Variables visible to LIBMP1
PUBLIC WordLength,RowPos,ColPos,offsetPos   ;

; ======== Your Code ======================================================

; -- Write the code for your subroutines below --
; To use your own code,
; comment out the 'extrn' routine from above and
; uncomment your procedure declaration

extrn PrintMatrix:near
; Inputs:
;    si = index to matrix to print

; PrintMatrix proc NEAR
;  For all letters in origMatrix {
;      ..
;    MOV DL,[si]
;      ..
;    Print character to screen 
;      ..
;  }
; PrintMatrix ENDP

extrn CheckLetter:near
; Inputs:
;    offsetPos = position of letter in OrigMatrix to check
; Outputs:
;    zf = zero if letter matches
;    zf = one  if letter does not match 

extrn CheckRight:near
; Inputs:
;    offsetPos = RowPos*NumCols + ColPos
;    RowPos = current row position
;    ColPos = current column position
;    WordLength = length of word to find
; Outputs
;    zf = zero if word matches
;    zf = one  if any letter mismatches 

extrn ReplaceRight:near
; Inputs:
;    offsetPos = RowPos*NumCols + ColPos
;    RowPos = current row position
;    ColPos = current column position
;    WordLength = length of word to find
; Output
;    EndMatrix 

extrn CheckDown:near
; Inputs/Ouputs: Same as CheckRight

extrn ReplaceDown:near
; Inputs/Ouputs: Same as ReplaceRight

; Remaining Directions..
extrn CheckLeft:near
extrn ReplaceLeft:near
extrn CheckUp:near
extrn ReplaceUp:near


;====== Main procedure ====================================================

main    proc    far

        ; The Main body of the program parses the command
        ; line and invokes each subroutine.  You are given this code.

        ; Command line arguments can be set in Codeview
        ; by selecting the (R)un menu, then (S)et args.

        mov  ax, ds  ; DOS reads command line arguments from the PSP
        mov  es, ax  ; (See: Hyde, Section 13.3.11 for details)

        mov  ax, cseg
        mov  ds, ax  ; set DS=CS 

        mov  cl, byte ptr es:[80h]     ; Read Length of Command Line
        cmp  cl, 1                    
        jbe  CommandLineError          ; Terminate program for no input

        mov  ch,0
        dec  CX
        mov  SI,0

CheckNextArgumentLetter:
        CMP BYTE PTR ES:[82h+SI],' '
        JE  CommandLineDone            ; Determine length of first argument
        INC SI                         ; by scanning for a space
        LOOP CheckNextArgumentLetter

CommandLineDone:                       ; Start MP0
        mov  WordLength,SI

        mov  dx, offset StartMessage   
        call dspmsg        
        mov  si, offset OrigMatrix
        call PrintMatrix        
        
        mov  offsetPos, 0              ; Start scanning at top-left 
        mov  RowPos, 0                 ; corner of OrigMatrix.
        mov  ColPos, 0

LetterScanLoop:
        call CheckLetter               
        jne  ProcessNextLetter
        
; First Letter matches, now check for word match in all four directions

        call CheckRight   ; Scan for words going right
        jne  RightChecked    
        call ReplaceRight ; Copy word to EndMatrix if it matches
RightChecked:

        call CheckDown    ; Scan for words going down
        jne  DownChecked  
        call ReplaceDown  
DownChecked:

        call CheckLeft    ; Scan for words going right
        jne  LeftChecked     
        call ReplaceLeft  
LeftChecked:

        call CheckUp
        jne  UpChecked    ; Scan for words going up
        call ReplaceUp
UpChecked:

ProcessNextLetter:
        inc  offsetPos          ; advance to next position
        
        inc  ColPos             ; advance to next column
        cmp  ColPos, NumCols
        jb   LetterScanLoop

ProcessNextRow:
        mov  ColPos,0
        inc  RowPos             ; advance to next row 
        cmp  RowPos, NumRows   
        jb   LetterScanLoop 

; Search has completed
        mov  dx, offset CRLF
        call dspmsg
        mov  dx, offset EndMessage
        call dspmsg        

        mov  si, offset EndMatrix        
        call PrintMatrix
        
        call mp1xit

CommandLineError:
        mov   dx, offset CommandErrorMessage
        call  dspmsg                   
          ; Print Error message and quit if program isn't
          ; called with command line argument
        call dosxit

main    endp

cseg    ends
        end     main
