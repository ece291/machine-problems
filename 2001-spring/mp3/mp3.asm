; MP3 - Typing-Tutor 291
;  Your Name
;  Today's Date
;
; Josh Potts, Spring 2001
; Authors: Ajay Ladsaria, Michael Urman
; University of Illinois, Urbana-Champaign
; Dept. of Electrical and Computer Engineering
;
; Version 1.0

	BITS	16

;====== SECTION 1: Define constants =======================================

        CR      	EQU     0Dh
        LF      	EQU     0Ah
        BEL     	EQU     07h
	ATTR_PRESS	EQU	0Eh	;feel free to change attrs as long
	ATTR_RELEASE	EQU	03h	;as they stay distinct
	ATTR_NORMAL	EQU	0Fh
	ATTR_ERROR	EQU	4Fh
	ATTR_STR	EQU	0Ah
	SCAN_MAX	EQU	83
	KEY_STR		EQU	18
	ERR_OFF		EQU	8*160+20	;offset of things on screen
	TIME_OFF	EQU 	10*160+20
	STR_OFF		EQU	2*160
	IN_ROW		EQU	4
	IN_OFF		EQU	IN_ROW*160
	KBD_OFF		EQU	13*160

;====== SECTION 2: Declare external procedures ============================

EXTERN  kbdin, dspout, dspmsg, mp3xit, binasc

; You will have to write these functions
EXTERN  libMP3Main, libDrawKeyboard, libDrawKeyNames, libNextString
EXTERN  libTimerISR, libInstallTimer, libRemoveTimer
EXTERN  libKeyboardISR, libInstallKeyboard, libRemoveKeyboard
EXTERN	libHighlightKey, libGetKeyPress, libTypeKey, libCheckKey
EXTERN  libDisplayStats

GLOBAL shift, quit, nextKey, ticks, fifths, seconds
GLOBAL KeyboardV, TimerV, currentStr, errors, errorMsg, errorNum
GLOBAL timeMsg, timeNum, StrTable

GLOBAL KeySkin, QwertyNames, QwertyShift, KeyLocations
GLOBAL SpecialAscii, SpecialKeys
GLOBAL  MP3Main, DrawKeyboard, DrawKeyNames, NextString
GLOBAL  TimerISR, InstallTimer, RemoveTimer
GLOBAL  KeyboardISR, InstallKeyboard, RemoveKeyboard
GLOBAL	HighlightKey, GetKeyPress, TypeKey, CheckKey, DisplayStats

;====== SECTION 3: Define stack segment ===================================

SEGMENT stkseg STACK                    ; *** STACK SEGMENT ***
        resb      64*8
stacktop:
        resb      0                     ; work around NASM bug

;====== SECTION 4: Define code segment ====================================

SEGMENT code                            ; *** CODE SEGMENT ***

;====== SECTION 5: Declare variables for main procedure ===================
shift		db 	0	;bit 1=LSHIFT pressed, bit 0=RSHIFT pressed
quit		db 	0	;quit on nonzero
nextKey		db	0	;most recent input
ticks		db	0	;{0..17} gets inc at each timer int
fifths		db	0	;{0..5}
seconds 	dw	0	;elapsed seconds
KeyboardV	resd 	1	;holds address of orig keyboardISR
TimerV		resd 	1	;holds address of orig timerISR
currentStr	dw	-1	;{0..STR_MAX-1}	
errors		dw 	0	;error total thus far
errorMsg	db 'Errors: '
errorNum	times 7 db 0	;errors in ascii
timeMsg		db 'Seconds:'
timeNum		times 7 db 0	;time in ascii

	;lookup table for the template strings
StrTable	dw .String1, .String2, .String3, .String4, .String5,
		dw .String6, .String7, .String8, .String9, .String10, 0
	;feel free to add more strings, but remember to change StrTable
.String1	db	"The quick brown fox.",0
.String2	db	"Another test string-=-",0
.String3 	db	"Poor pillow! Alas, poor pillow.  How I miss your tender embrace!", 0
.String4	db	"You should keep your other CD in a safe place for backup purposes.", 0
.String5	db	"These products typically employ IP telephony, but they don't have to.", 0
.String6	db	"Service providers (SPs) can quickly add applications through open APIs.", 0
.String7	db	"Have multimedia collaboration built into the switch through support of H.323.", 0
.String8	db	"I had been asked to drive in heavy traffic and had done so successfully.", 0
.String9	db	"Eliminate the need for a separate Internet telephony gateway.", 0
.String10	db	"Please make a written declaration of all the goods you've brought with you.", 0

;====== SECTION 6: Program initialization =================================

..start:
        mov     ax, cs                  ; Initialize Default Segment register
        mov     ds, ax  
        mov     ax, stkseg              ; Initialize Stack Segment register
        mov     ss, ax
        mov     sp, stacktop            ; Initialize Stack Pointer register

;====== SECTION 7: Main procedure =========================================

MAIN:
	mov	ax, 3
	int	10h

	call MP3Main			; Use this for the real program
	;call MP3TestMain		; Use this for testing HighlightKey

	mov	ax, 3
	int	10h
        call    mp3xit

	

; MP3Main
MP3Main:
	call	libMP3Main
	ret


; MP3TestMain
; No inputs or outputs
; Useful for testing HighlightKey in a non-ISR situation
MP3TestMain:
	call	DrawKeyboard

	mov	cx, 83
.loopme
	mov	ax, cx
	call	HighlightKey
	or	ax, 80h			; Stick a breakpoint or kbdin here
	call	HighlightKey
	loop	.loopme
	ret
        
	
; DrawKeyboard
DrawKeyboard
	call	libDrawKeyboard
	ret

; DrawKeyNames
DrawKeyNames
	call	libDrawKeyNames
	ret

; NextString
NextString
	call	libNextString
	ret

; InstallTimer
InstallTimer
	call	libInstallTimer
	ret

; RemoveTimer
RemoveTimer
	call	libRemoveTimer
	ret

; TimerISR
TimerISR
	jmp	libTimerISR
	
; InstallKeyboard
InstallKeyboard
	call	libInstallKeyboard
	ret

; RemoveKeyboard
RemoveKeyboard
	call	libRemoveKeyboard
	ret

; KeyboardISR
KeyboardISR
	jmp	libKeyboardISR

; HighlightKey
HighlightKey
	call	libHighlightKey
	ret

; GetKeyPress
GetKeyPress
	call	libGetKeyPress
	ret

; TypeKey
TypeKey
	call	libTypeKey
	ret
	
; CheckKey
CheckKey
	call	libCheckKey
	ret

; DisplayStats
DisplayStats
	call	libDisplayStats
	ret





;====== SECTION 8: Stuff we would have preferred to use %include for ======

; ============================================================   =============
; | ` | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 0 | - | = | BKSP |   |Ins|Hom|PgU|
; ------------------------------------------------------------   -------------
; | Tab | Q | W | E | R | T | Y | U | I | O | P | [ | ] | \  |   |Del|End|PgD|
; ------------------------------------------------------------   =============
; | Caps | A | S | D | F | G | H | J | K | L | ; | ' | Enter |
; ------------------------------------------------------------       =====
; | Shift  | Z | X | C | V | B | N | M | , | . | / |  Shift  |       | ^ |
; ------------------------------------------------------------   -------------
; | Ctrl | Win | Alt |  space-bar  | Alt | Win | Menu | Ctrl |   |<- | V | ->|
; ============================================================   =============

ULD equ 201	;define line drawing character constants
DLS equ 199
HD equ 205
VD equ 186
UDS equ 209
HS equ 196
VS equ 179
HSD equ 194
HSU equ 193
HVS equ 197
RDS equ 182
DDS equ 207
DLD equ 200
DRD equ 188
URD equ 187
HSV equ 197
HDSV equ 206
HDU equ 202


KeySkin	;use them
      db 0,0, ULD
    ;times 13 dd (UDS<<24)+(HD<<16)+(HD<<8)+(HD)
    times 13 db HD,HD,HD,UDS
      db HD,HD,HD,HD,HD,HD, URD
      db 0,0,0, ULD, HD,HD,HD,UDS, HD,HD,HD,UDS, HD, HD, HD, URD, 0,0
      ; numline
      db 0,0, VD,
times 13 dd VS<<24
      db 0,0,0,0,0,0, VD
      db 0,0,0, VD, 0,0,0,VS, 0,0,0,VS, 0,0,0, VD, 0,0
      ; num-tabs
      db 0,0, DLS, HS,HS
times 13 dd (HS)+(HSU<<8)+(HS<<16)+(HSD<<24)
      db  HS,HS,HS,HS, RDS
      db 0,0,0, DLS, HS,HS,HS, HSV, HS,HS,HS, HSV, HS,HS,HS, RDS, 0,0
      ; tabline
      db 0,0, VD, 0,0,
times 13 dd VS<<24
      db 0,0,0,0, VD
      db 0,0,0, VD, 0,0,0,VS, 0,0,0,VS, 0,0,0, VD, 0,0
      ; tab-caps
      db 0,0, DLS,HS,HS,HS,
times 12 dd (HS)+(HS<<8)+(HSU<<16)+(HSD<<24)
      db HS,HS,HSU, HS,HS,HS,HS, RDS
      db 0,0,0, DLD, HD,HD,HD,DDS, HD,HD,HD,DDS, HD, HD, HD, DRD, 0,0
      ; capsline
      db 0,0, VD, 0,0,0,
times 12 dd VS<<24
      db 0,0,0,0,0,0,0, VD
      times 18 db 0
      ; caps-shift
      db 0,0, DLS, HS,HS,HS,HS,HS
times 11 dd (HS)+(HSU<<8)+(HS<<16)+(HSD<<24)
      db HS,HSU, HS,HS,HS,HS,HS,HS,HS, RDS
      db 0,0,0,0,0,0,0, ULD, HD,HD,HD, URD, 0,0,0,0,0,0
      ; shiftline
      db 0,0, VD, 0,0,0,0,0
times 11 dd VS<<24
      db 0,0,0,0,0,0,0,0,0, VD, 0,0,0,0,0,0,0, VD, 0,0,0, VD, 0,0,0,0,0,0
      ; shift-ctrl
      db 0,0, DLS, HS,HS,HS,HS,HS,HS,HSD, HS,HSU,HS,HS,HS,HVS
      db HS,HS,HS,HSU,HS,HSD, HS,HSU,HS,HS,HS,HSU,HS,HS,HS,HSU,HS,HS, HS,HSV
      db HS,HS,HS,HSU,HS,HSD, HS,HSU,HS,HS,HS,HSV
      db HS,HS,HS,HSU,HS,HS,HSD, HS,HS,HS,HS,HS,HS,RDS
      db 0,0,0, ULD,HD,HD,HD,HDSV, HD,HD,HD, HDSV, HD,HD,HD, URD, 0,0
      ; ctrl line
      db 0,0, VD, 0,0,0,0,0,0,VS, 0,0,0,0,0,VS, 0,0,0,0,0,VS,
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,VS
      db 0,0,0,0,0,VS, 0,0,0,0,0,VS, 0,0,0,0,0,0,VS, 0,0,0,0,0,0,VD
      db 0,0,0, VD, 0,0,0, VD, 0,0,0, VD, 0,0,0, VD, 0,0
      ; bottom
      db 0,0, DLD, HD,HD,HD,HD,HD,HD,DDS, HD,HD,HD,HD,HD,DDS, HD,HD,HD,HD,HD,DDS
      times 13 db HD
      db DDS, HD,HD,HD,HD,HD,DDS, HD,HD,HD,HD,HD,DDS, HD,HD,HD,HD,HD,HD,DDS
      db HD,HD,HD,HD,HD,HD,DRD
      db 0,0,0, DLD, HD,HD,HD, HDU, HD,HD,HD, HDU, HD,HD,HD, DRD, 0,0

LCTRL	equ	2
RCTRL	equ	3
LALT	equ	4
RALT	equ	5
LSHIFT	equ	6
RSHIFT	equ	7
CAPS	equ	1
BKSP	equ	8
ENTR	equ	13
ESC	equ	27
TAB	equ 	9
DEL	equ	10
HOME	equ	11
UP	equ	24
PGUP	equ	12
LEFT	equ	27
RIGHT	equ	26
END	equ	14
DOWN	equ	25
PGDN	equ	15
INS	equ	16
SPACE	equ	17

QwertyNames
	db	0	; filler
	db	ESC,'1','2','3','4','5','6','7','8','9','0','-','=',BKSP
	db	TAB, 'q','w','e','r','t','y','u','i','o','p','[',']',ENTR
	db	LCTRL,'a','s','d','f','g','h','j','k','l',';',"'","`"
	db	LSHIFT,'\','z','x','c','v','b','n','m',",",'.','/',RSHIFT,'*'
	db	LALT, SPACE, CAPS, 0,0,0,0,0,0,0,0,0,0 ; F1-F10
	db	0,0	; numlock, scroll lock
	db	HOME, UP, PGUP, '-'
	db	LEFT, 0, RIGHT, '+'
	db	END, DOWN, PGDN, INS
	db	DEL, 0; sysrq

QwertyShift
	db	0	; filler
	db	ESC,'!','@','#','$','%','^','&','*','(',')','_','+',BKSP
	db	TAB, 'Q','W','E','R','T','Y','U','I','O','P','{','}',ENTR
	db	LCTRL,'A','S','D','F','G','H','J','K','L',':','"','~'
	db	LSHIFT,'|','Z','X','C','V','B','N','M',"<",'>','?',RSHIFT,'*'
	db	LALT, SPACE, CAPS, 0,0,0,0,0,0,0,0,0,0 ; F1-F10
	db	0,0	; numlock, scroll lock
	db	HOME, UP, PGUP, '-'
	db	LEFT, 0, RIGHT, '+'
	db	END, DOWN, PGDN, INS
	db	DEL, 0; sysrq

KeyLocations
	dw	0	; filler
	dw	0,176,184,192,200,208,216,224,232,240,248,256,264,272
	dw	488, 500,508,516,524,532,540,548,556,564,572,580,588,910
	dw	1448,822,830,838,846,854,862,870,878,886,894,902,168
	dw	1128,596,1146,1154,1162,1170,1178,1186,1194,1202,1210,1218,1226
	dw	0	; *
	dw	1474, 1486, 808, 0,0,0,0,0,0,0,0,0,0 ; F1-F10
	dw	0,0	; numlock, scroll lock
	dw	300, 1262, 308,0 ;789- = FIXME
	dw	1574,0,1590,0 ;456+ = FIXME

	dw	620,1582,628,292 ;1230 = FIXME

	dw	612, 0; del = FIXME, sysrq

; lookup table for special key's ascii representations
SpecialAscii db 0,0,0,0,0,0,0,0,8,9,0,0,0,13,0,0,0,' '
; lookup table for special key's string representations
SpecialKeys
	dw 0
	dw	.caps
	dw	.ctrl
	dw	.ctrl
	dw	.alt
	dw	.alt
	dw	.shift
	dw	.shift
	dw	.bksp
	dw	.tab
	dw	.del
	dw	.home
	dw	.pgup
	dw	.enter
	dw	.end
	dw	.pgdn
	dw	.ins
	dw	.space

.caps	db	'CAPS$'
.ctrl	db	'CTRL$'
.alt	db	'ALT$'
.shift	db	'SHIFT$'
.bksp	db	'BKSP$'
.tab	db	'TAB$'
.del	db	'DEL$'
.home	db	'HOM$'
.pgup	db	'PG',UP,'$'
.enter	db	'ENTER$'
.end	db	'END$'
.pgdn	db	'PG',DOWN,'$'
.ins	db	'INS$'
.space	db	'SPACEBAR$'
