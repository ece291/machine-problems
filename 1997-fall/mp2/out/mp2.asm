        PAGE 75, 132
        TITLE ECE291:MP2:MP2-Compress - Your Name - Date

COMMENT *
        Data Compression.

        The world contains a great deal of data.  Luckily, a great
        deal of it is redundant (i.e., repeats itself or has repeating
        patterns).  Using compression algorithms, one can encode such
        data using a smaller number of bits.

        For this MP, you will write a program which uses Run-Length
        Encoding (RLE) to compress textual data.  As you will see, RLE
        is most effective on data which as long runs of identical characters.

        ECE291: Machine Problem 2
        Prof. John W. Lockwood
        Unversity of Illinois
        Dept. of Electrical & Computer Engineering
        Fall 1997

        Ver 1.0
        *

;====== Constants =========================================================

BEEP    EQU 7
BS      EQU 8
CR      EQU 13
LF      EQU 10

ESCKEY  EQU 27
SPACE   EQU 32

BufferMaxLength      EQU 64 ; Bytes
BufferMaxLengthBits  EQU BufferMaxLength * 8 ; Bits
TextMsgMaxLength     EQU 56 ; Bytes

;====== Externals =========================================================

; -- LIB291 Routines (Free) ---

extrn kbdine:near, kbdin:near, dspout:near   ; LIB291 Routines
extrn dspmsg:near, binasc:near, ascbin:near  ; (Always Free)
extrn mp2xit:near ; Exit program with a call to this procedure

; -- LIBMP2 Routines (Replace these with your own code) ---

extrn PrintBuffer:near   ; Print contents of Buffer
extrn ReadBuffer:near    ; Read Buffer from keyboard
extrn ReadTextMsg:near   ; Read TextMsg from keyboard
extrn PrintTextMsg:near  ; Print contents of TxtMsg
extrn Encode:near        ; Encode ASCII -> 5-bit
extrn AppendBuffer:near  ; Add a character to Buffer
extrn EncodeRLE:near     ; Run Length Encode TextMsg -> Buffer
extrn DecodeRLE:near     ; Run Length Decode Buffer -> TextMsg

;====== SECTION 3: Define stack segment ===================================
stkseg  segment stack                   ; *** STACK SEGMENT ***
        db      64 dup ('STACK   ')     ; 64*8 = 512 Bytes of Stack
stkseg  ends

;====== SECTION 4: Define code segment ====================================
cseg    segment public  'CODE'    ; *** CODE SEGMENT ***
        assume  cs:cseg, ds:cseg, ss:stkseg, es:nothing

;====== SECTION 5: Variables ==============================================

Buffer  db BufferMaxLength    dup(0)        ; Data Buffer for encoded Message
TextMsg db TextMsgMaxLength   dup('$'), '$' ; Text Message 

BufferLength dw 0 ; Number of bits in buffer

crlf db CR,LF,'$' ; DOS uses carriage return + Linefeed for new line

PUBLIC Buffer, TextMsg, BufferLength 

;====== Procedures ========================================================


; Your Subroutines go here !
; ---- ----------- -- ----

;====== Main procedure ====================================================

MenuMessage db CR,LF, \
  '------------- MP2 Menu --------------',CR,LF,\
  '  Enter   (T)ext     / (B)inary',CR,LF, \
  '  Print   (M)essage  / (R)buffeR',CR,LF, \
  '  RLE     (E)ncode   / (D)ecode',CR,LF, \
  '------ [ESC] or (Q)uit to exit ------',CR,LF,'$'

main    proc    far
        mov     ax, cseg
        mov     ds, ax

          MOV DX, Offset MenuMessage
          CALL DSPMSG                   ; Display Menu

MainLoop: MOV DX, Offset CRLF
          CALL DSPMSG

MainRead: CALL KBDIN                    ; Read Input

          CMP AL,'a'
          JB  MainOpt
          CMP AL,'z'                    ; Convert Lowercase to Uppercase
          JA  MainOpt
          SUB AL,'a'-'A'

MainOpt:  CMP AL,'T'
          JNE MainNotT                   
          Call ReadTextMsg              ; Read in a text message
          JMP MainLoop

MainNotT: CMP AL,'B'
          JNE MainNotB
          Call ReadBuffer               ; Read in a binary message
          JMP MainLoop

MainNotB: CMP AL,'M'
          JNE MainNotM
          Call PrintTextMsg             ; Print TextMsg
          JMP MainLoop

MainNotM: CMP AL,'R'
          JNE MainNotR                  ; Print Buffer
          Call PrintBuffer              ; (show least significants bit first) 
          JMP MainLoop                  

MainNotR: CMP AL,'E'
          JNE MainNotE
          Call EncodeRLE                ; Run Length Encode Message 
          Call PrintBuffer              ; and print result
          JMP MainLoop

MainNotE: CMP AL,'D'
          JNE MainNotD
          Call DecodeRLE                ; Run Length Decode Message
          Call PrintTextMsg             ; and show result
          JMP MainLoop

MainNotD: CMP AL,ESCKEY
          JE  MainDone                  ; Quit program
          CMP AL,'Q'
          JE  MainDone

          JMP MainRead                  ; Ignore any other character 

MainDone: call MP2xit ; Exit to DOS

main    endp
 
cseg    ends
        end     main

                 
                  
