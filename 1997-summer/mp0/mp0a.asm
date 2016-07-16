	PAGE 75, 132
	TITLE   MP0     your name       current date

COMMENT *
	This program illustrates LIB291 input and output routines plus
	a simple subroutine call for I/O.  Be sure to also put your name
	in the two places where it says 'your name' and also change
	the date where it says 'current date'.
	*

;====== SECTION 1: Define constants =======================================

	CR      EQU     0Dh
	LF      EQU     0Ah
	BEL     EQU     07h
	ESCKEY  EQU     1Bh

;====== SECTION 2: Declare external procedures ============================

	extrn   kbdine:near, dspout:near, dspmsg:near, dosxit:near

;====== SECTION 3: Define stack segment ===================================

stkseg  segment stack                   ; *** STACK SEGMENT ***
	db      64 dup ('STACK   ')
stkseg  ends

;====== SECTION 4: Define code segment ====================================

cseg    segment public                  ; *** CODE SEGMENT ***
	assume  cs:cseg, ds:cseg, ss:stkseg, es:nothing

;====== SECTION 5: Declare variables for main procedure ===================
hdmsg   db      'MPD: Type "N" or the "ESC" key','$'
prompt  db      CR,LF,'MPD:','$'
xitmsg  db      CR,LF,'MPD: Exit to DOS','$'
usrname db      CR,LF,'your name','$'

;====== SECTION 6: Main procedure =========================================

main    proc    far
	mov     ax, cseg                ; Initialize DS register
	mov     ds, ax
	mov     dx, offset hdmsg        ; DX = "Address" of hdmsg text
	call    dspmsg                  ; Display message
toplp:  mov     dx, offset prompt       ; Prompt for letter command
	call    dspmsg
	call    kbdine                  ; Get keyboard character in AL
	cmp     al, ESCKEY              ; Exit on ESC character
	je      mpdxit
	cmp     al, 'N'                 ; Print user name on 'N' character
	je      prname
	mov     dl, BEL                 ; Ring the bell if other character
	call    dspout
	jmp     toplp

prname: mov     dx, offset usrname      ; Type out user name
	call    dspmsg
	jmp     toplp

mpdxit: mov     dx, offset xitmsg       ; Type out exit message
	call    dspmsg
	call    dosxit                  ; Exit to DOS
main    endp

cseg    ends
	end     main
