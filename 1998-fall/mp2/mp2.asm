TITLE ECE291:MP2-RSA - Your Name - Date

COMMENT % RSA Data Encryption.

          For this MP, you will write an interactive program which uses
          RSA encryption to encrypt and decrypt textual data.

          ECE291: Machine Problem 2
          Prof. John W. Lockwood
          Guest Author: Brandon Tipp
          Unversity of Illinois
          Dept. of Electrical & Computer Engineering
          Fall 1998

          Ver 1.1
        %

;====== Constants =========================================================

BEEP    EQU 7
BS      EQU 8
CR      EQU 13
LF      EQU 10

ESCKEY  EQU 27
SPACE   EQU 32

BufferMaxLength     EQU 20 ; Bytes ; Limit text messages to one line 
                                   ; when displaying message in HEX

ASCII   EQU 0
HEX     EQU 1
DECIMAL EQU 2

PUBLIC BEEP, BS, CR, LF, ESCKEY, SPACE, ASCII, HEX, DECIMAL, BufferMaxLength
;====== Externals =========================================================

; -- LIB291 Routines (Free) ---

extrn kbdine:near, kbdin:near, dspout:near   ; LIB291 Routines
extrn dspmsg:near, binasc:near, ascbin:near  ; (Always Free)

extrn mp2xit:near ; Exit program with a call to this procedure

; -- LIBMP2 Routines (Replace these with your own code) ---

extrn PrintBuffer:near     ; Print contents of Buffer
extrn ReadBuffer:near      ; Read Buffer from keyboard
extrn CodeBuffer:near      ; Encode or decode the buffer
extrn ExpModN:near         ; Calculate X^Y mod Z
extrn CheckPrime:near      ; Determine if a number is prime
extrn ReadKeys:near        ; Read and verify valid values for p, q, e, d   
extrn ReadPublicKeys:near  ; Read in d, n

;====== SECTION 3: Define stack segment ===================================
stkseg  segment stack                   ; *** STACK SEGMENT ***
        db      64 dup ('STACK   ')     ; 64*8 = 512 Bytes of Stack
stkseg  ends

;====== SECTION 4: Define code segment ====================================
cseg    segment public  'CODE'    ; *** CODE SEGMENT ***
        assume  cs:cseg, ds:cseg, ss:stkseg, es:nothing

;====== SECTION 5: Variables ==============================================

Buffer  db BufferMaxLength    dup(0)   ; Data Buffer for message

BufferLength db 0 ; Number of bytes in buffer

crlf    db CR,LF,'$' ; DOS uses carriage return + Linefeed for new line
PBuf    db 7 dup(?)

Pmsg    db 'Plese enter a prime number (p): p <= 127: ','$'
Perr1   db BEEP,'One is not prime!',CR,LF,'$'
Perr2   db BEEP,'P must be less than or equal to 127!',CR,LF,'$' 
Perr3   db BEEP,'P must be a prime number!',CR,LF,'$'
Qmsg1   db 'Plese enter a prime number (q): ','$'
Qmsg2   db ' < q <= ','$'
Qerr1   db BEEP,'Q must be greater than ','$'
Qerr2   db BEEP,'Q must be less than or equal to ','$'
Qerr3   db BEEP,'Q must be a prime number!',CR,LF,'$'
PUBmsg  db 'Please enter a public key (e): ',CR,LF,'$'
Nmsg    db 'Please enter the modulus (n = p * q : n>128, n<255): ',CR,LF,'$'
Emsg    db 'Please enter a key (e) that is less than and relatively prime to ','$'
Eerr1   db BEEP,'E must be less than ','$'
Eerr2   db BEEP,'E must be relatively prime to ','$'
Derr    db BEEP,'It is insecure for D and E to be the same!',CR,LF,'$'
PubKeyMsg db 'The public key (e, n) is (','$'
PriKeyMsg db 'The private key (d, n) is (','$'
Prompt  db ': ','$'

TextMsg db 'Enter text for the buffer',CR,LF,'$'
HexMsg  db 'Enter hex for the buffer',CR,LF,'$'
KeyMsg  db 'Generating new public keys...',CR,LF,'$'
PKeyMsg db 'Reading private key information...',CR,LF,'$'
DAscMsg db 'Here is the buffer in ASCII',CR,LF,'$'
DHexMsg db 'Here is the buffer in HEX',CR,LF,'$'
EncMsg  db 'Encrypting the buffer...',CR,LF,'$'
DecMsg  db 'Decrypting the buffer...',CR,LF,'$'

PUBLIC Pmsg, Perr1, Perr2, Perr3, Qmsg1, Qmsg2, Qerr1, Qerr2, Qerr3
PUBLIC Emsg, Eerr1, Eerr2, Derr, PubKeyMsg, PriKeyMsg, Prompt, crlf, PBuf
PUBLIC PUBmsg, Nmsg


p       db 5    ; a prime number
q       db 29   ; another prime number
n       db 145  ; modulus (p * q)
e       db 3    ; default encryption key [relatively prime to (p-1)*(q-1)]
d       db 75   ; default decryption key [relatively prime to (p-1)*(q-1)]

   ; Note that keys are initialized with a valid encoding/decoding values.
   ; They can be changed while running the program

PUBLIC Buffer, BufferLength, e, d, p, q, n

                                   
;====== Procedures ========================================================


; Your Subroutines go here !
; ---- ----------- -- ----


;====== Main procedure ====================================================

MenuMessage db CR,LF
  db '----------------------- MP2 Menu ---------------------',CR,LF
  db ' enter:    (T)ext message   (C)oded hex message',CR,LF
  db ' display:  (A)SCII message  (H)ex encoding',CR,LF
  db ' generate: (K)eys           (P)ublic key',CR,LF
  db ' coding:   (E)ncrypt        (D)ecrypt',CR,LF
  db '--------- [ESC] = (Q)uit -- redisplay (M)enu ---------',CR,LF,'$'

MPrompt db '>$'

main    proc    far
        mov     ax, cseg
        mov     ds, ax

          MOV DX, Offset MenuMessage
          CALL DSPMSG                   ; Display Menu

MainLoop: MOV DX, Offset CRLF
          CALL DSPMSG

          MOV DX, Offset MPrompt
          CALL DSPMSG

MainRead: CALL KBDIN                    ; Read Input

          CMP AL,'a'
          JB  MainOpt
          CMP AL,'z'                    ; Convert Lowercase to Uppercase
          JA  MainOpt
          SUB AL,'a'-'A'

MainOpt:  CMP AL,'K'
          JNE MainNotK                   
          MOV DX, offset KeyMsg
          CALL DSPMSG          
          CALL ReadKeys                 ; Generate a new key
          JMP MainLoop

MainNotK: CMP AL,'P'
          JNE MainNotP                   
          MOV DX, offset PKeyMsg
          CALL DSPMSG          
          CALL ReadPublicKeys           ; Read in a public key
          JMP MainLoop

MainNotP: CMP AL,'T'
          JNE MainNotT
          MOV DX, offset TextMsg
          CALL DSPMSG
          MOV AL, BufferMaxLength       ; Read in a text message
          MOV AH, ASCII
          MOV BX, Offset Buffer
          CALL ReadBuffer               
          MOV DX, Offset crlf
          CALL DSPMSG
          JMP MainLoop

MainNotT: CMP AL,'C'
          JNE MainNotC
          MOV DX, offset HexMsg
          CALL DSPMSG
          MOV AL, BufferMaxLength       ; Read in a hex message
          MOV AH, HEX
          MOV BX, Offset Buffer
          CALL ReadBuffer
          JMP MainLoop

MainNotC: CMP AL,'E'
          JNE MainNotE
          MOV DX, offset EncMsg
          CALL DSPMSG
          MOV DH, byte ptr e            ; Encode the message
          MOV CL, BufferLength
          MOV BX, offset Buffer
          CALL CodeBuffer 
          JMP MainLoop                  

MainNotE: CMP AL,'D'
          JNE MainNotD
          MOV DX, offset DecMsg
          CALL DSPMSG
          MOV DH, byte ptr d            ; Decode the message
          MOV CL, BufferLength
          MOV BX, offset Buffer
          CALL CodeBuffer             
          JMP MainLoop

MainNotD: CMP AL,'A'
          JNE MainNotA
          MOV DX, offset DAscMsg
          CALL DSPMSG
          MOV AL, BufferLength          ; Display the message in ASCII
          MOV AH, ASCII
          MOV BX, offset Buffer
          CALL PrintBuffer
          JMP MainLoop

MainNotA: CMP AL,'H'
          JNE MainNotH
          MOV DX, offset DHexMsg
          CALL DSPMSG
          MOV AL, BufferLength          ; Display the message in Hex
          MOV AH, HEX
          MOV BX, Offset Buffer
          CALL PrintBuffer
          JMP MainLoop

MainNotH: CMP AL,'M'
          JNE MainNotM
          MOV DX, offset MenuMessage
          CALL DSPMSG
          JMP MainLoop

MainNotM: CMP AL,ESCKEY
          JE  MainDone                  ; Quit program
          CMP AL,'Q'
          JE  MainDone

          JMP MainRead                  ; Ignore any other character 

MainDone: call MP2XIT ; Exit to DOS

main    endp

cseg    ends
        end     main
