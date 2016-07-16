        PAGE 75, 132
        TITLE  ECE291:MP1:Events - Your Name - Date  

COMMENT *
        This program checks a calendar to remind you of
        events that will occur in the near future.
        The data for this program are read from the file
        events.inc when the program is assembled.
        Dates are specified in a month/day format.       

        ECE291 Machine Problem 1
        Prof. John W. Lockwood
        Unversity of Illinois, Dept. of Electrical & Computer Engineering
        Spring 1997
	*

;====== SECTION 1: Define constants =======================================

        CR        EQU     0Dh
        LF        EQU     0Ah
        
;====== SECTION 2: Declare external procedures ============================

; -- Functions in LIB291.LIB --

        extrn binasc:near, dspmsg:near, dosxit:near, dspout:near;

        ; Please read your lab manual for a full description of the
        ; LIB291 functions.  You will want to use these functions for
        ; displaying output on the screen.

; -- Functions in LIBMP1.LIB --

        ; You may use these procedures freely.

        extrn getdate:near
          ;Purpose: Read current date
          ; Inputs: None
          ;Outputs: DH = month
          ;         DL = day
          ;         CX = year
          ;Registers: All others preserved

        extrn printdate:near
          ;  Purpose: Print a 5-character date string as "MM/DD"
          ;   Inputs: DH=month (MM)
          ;           DL=day   (DD)
          ;   Output: None (Prints to screen)
          ;Registers: All others preserved

        extrn calcdate:near
          ;  Purpose: Calculates a day number from a given month and day.
          ;   Inputs: DH=month
          ;           DL=day
          ;  O utput: AX=Day number (0..365)
          ;Registers: All others preserved
          ;     Note: Always assumes that Feb has 29 days (leap year)


;====== SECTION 3: Define stack segment ===================================

stkseg  segment stack                   ; *** STACK SEGMENT ***
        db      64 dup ('STACK   ')
stkseg  ends

;====== SECTION 4: Define code segment ====================================

cseg    segment public                  ; *** CODE SEGMENT ***
        assume  cs:cseg, ds:cseg, ss:stkseg, es:nothing

;====== SECTION 5: Declare variables for main procedure ===================

Event STRUC                      ; -- Format of Events Database --
  month   BYTE ?                 ; Month Number (1..12)
  day     BYTE ?                 ; Day Number (1..31)
  message BYTE 29 dup(' ')       ; Message to Print
  endmark BYTE '$'
Event ENDS

INCLUDE events.inc
; Read the file called 'events.inc'. 
; 'Events' defined as an array of event structures
; 'numrec'    : 16-bit word which stores the number of records
; 'lookahead' : 16-bit word which indicates how many days to look ahead
                             
todaymsg db 'Today is: ','$'; First Message Printed

hdr db '-Date- ----------Event------------- -Days-',CR,LF,'$' ; Column Header

pbuf db 7 dup(?)   ; Temporary storage used by BINASC lib291 call

crlf db CR,LF,'$'  ; String to generate a new line

today dw ? ; Stores the day number

;====== SECTION 6: Procedures =========================================
                                                
main      proc    far
          mov     ax, cseg                ; Initialize DS register
          mov     ds, ax
 
; --- Free code to get you started ---

          mov dx, offset todaymsg ; Print 'Today is: '
          call dspmsg

          call getdate    ; Read the date
          call printdate  ; Print the date
          call calcdate   ; Calculate the day number
          mov today,ax    ; save the result in the variable 'today'
                                                 
          mov dx,offset crlf ; Print two carriage returns
          call dspmsg
          call dspmsg
          
; ================================================

;            YOUR CODE GOES HERE

; ================================================



; -- End of your code --------------------------------

          call    dosxit
main      endp


cseg      ends
          end     main
