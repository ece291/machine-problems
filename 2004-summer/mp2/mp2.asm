; MP2 - Sorting Algorithm Analysis
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

; Define general constants
        CR      	EQU     0Dh
        LF      	EQU     0Ah
	ESC		EQU	1Bh
	SPACE		EQU	20h
	BACKSPACE	EQU	08h

;====== SECTION 2: Declare external routines ==============================

; Declare external library routines
EXTERN kbdin, kbdine, dspmsg, ascbin, binasc, dosxit, dspout
EXTERN libGetInput, libParseInput, libPrintArray
EXTERN libPartition, libQuickSort, libBubbleSort, mp2xit

; Make program functions and variables global
GLOBAL GetInput, ParseInput, PrintArray
GLOBAL Partition, QuickSort, BubbleSort
GLOBAL EnterString, CompareCount, SwapCount, binascBuf, TestArrayBubble, TestArrayQuick
GLOBAL DataString, Array, ArrayLen
      
;====== SECTION 3: Define stack segment ===================================

SEGMENT stkseg STACK                    ; *** STACK SEGMENT ***
        resb      64*8
stacktop:
        resb      0                     ; work around NASM bug

;====== SECTION 4: Define code segment ====================================

SEGMENT code                            ; *** CODE SEGMENT ***

;====== SECTION 5: Declare variables for main procedure ===================

IntroString	db	CR,LF
		db	0DAh
		times 28 db 0C4h
		db	0BFh, CR, LF
		db	0B3h, '  ', 228, 'C', 228, ' 291 Summer 2004 MP2   ', 0B3h, CR, LF
		db	0B3h, ' Sorting Algorithm Analysis ', 0B3h, CR, LF
		db	0C0h
		times 28 db 0C4h
		db	0D9h, CR, LF, CR, LF, ':', ' ', '$'
	
InputMsgString		db	'Enter a string of numbers, each separated by one space:',CR,LF,'$'
ErrorString		db	'Error encountered in parsing input!',CR,LF,'$'
InitialArrayString	db	'Initial array:',CR,LF,'$'
SortQuickString		db	'Array sorted with QuickSort:',CR,LF,'$'
SortBubbleString	db	'Array sorted with BubbleSort:',CR,LF,'$'
CompareString		db	'Number of comparisons: ','$'
SwapString		db	'Number of swaps: ','$'
EnterString		db	CR,LF,'$'

DataString	times 76 db 0	 
Array		times 25 dw 0
ArrayLen	dw	0

CompareCount	dw	0
SwapCount	dw	0

FunctionTable	dw	BubbleSort, QuickSort
StringTable	dw	SortBubbleString, SortQuickString
			       
binascBuf	times 7 db 0

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

	; Get the input string
	push	word DataString
	call	GetInput
	add	sp, 2
	test	ax, ax
	jnz	near .Done

	mov	dx, EnterString
	call	dspmsg
	call	dspmsg
	mov	di, 0

.SortLoop
	mov	word [CompareCount], 0
	mov	word [SwapCount], 0

	; Parse the input string
	push	word Array
	push	word DataString
	call	ParseInput
	add	sp, 4
	test	ax, ax
	js	near .Error
	mov	[ArrayLen], ax

	; Print out the initial array
	mov	dx, InitialArrayString
	call	dspmsg
	push 	word [ArrayLen]
	push	word Array
	call	PrintArray
	add	sp, 4

	; Sort the array with Bubblesort or QuickSort
	mov	ax, [ArrayLen]
	dec	ax
	push	ax
	test	di, di
	jz	.CallBubble
	
	mov	ax, [ArrayLen]
	dec	ax
	push	ax
	push	word 0
	push	word Array
	call	QuickSort
	add	sp, 6
	jmp	.PrintArray

.CallBubble
	push	word [ArrayLen]
	push	word Array
	call	BubbleSort
	add	sp, 4

.PrintArray
	; Print out the sorted array
	shl	di, 1
	mov	dx, [StringTable+di]
	shr	di, 1
	call	dspmsg
	push	word [ArrayLen]
	push	word Array
	call	PrintArray
	add	sp, 4

	; Print out comparison and swap info
	mov	dx, CompareString
	call	dspmsg
	mov	ax, [CompareCount]
	mov	bx, binascBuf
	call	binasc
	mov	dx, bx
	call	dspmsg
	mov	dx, EnterString
	call	dspmsg	      
	mov	dx, SwapString
	call	dspmsg
	mov	ax, [SwapCount]
	mov	bx, binascBuf
	call	binasc
	mov	dx, bx
	call	dspmsg
	mov	dx, EnterString
	call	dspmsg
	call	dspmsg

	inc	di
	cmp	di, 2
	jl	near .SortLoop
	jmp	.Done

.Error
	mov	dx, ErrorString
	call	dspmsg

.Done
	call	mp2xit	

;====== SECTION 8: Your subroutines =======================================

;--------------------------------------------------------------
;--          Replace library calls with your code!           --
;--          [Save all reg values that you modify]           --
;--          Do not forget to add function headers           --
;--------------------------------------------------------------

;--------------------------------------------------------------
;--                        GetInput()                        --
;--------------------------------------------------------------
GetInput
	push	bp
	mov	bp, sp

	push	word [bp+4]
	call	libGetInput
	add	sp, 2

	pop	bp
	ret

;--------------------------------------------------------------
;--                       ParseInput()                       --
;--------------------------------------------------------------
ParseInput
	push	bp
	mov	bp, sp

	push	word [bp+6]
	push	word [bp+4]
	call	libParseInput
	add	sp, 4

	pop	bp
	ret

;--------------------------------------------------------------
;--                       PrintArray()                       --
;--------------------------------------------------------------
PrintArray
	push	bp
	mov	bp, sp

	push	word [bp+6]
	push	word [bp+4]
	call	libPrintArray
	add	sp, 4

	pop	bp
	ret

;--------------------------------------------------------------
;--                        Partition()                       --
;--------------------------------------------------------------
Partition
	push	bp
	mov	bp, sp

	push	word [bp+8]
	push	word [bp+6]
	push	word [bp+4]
	call	libPartition
	add	sp, 6

	pop	bp
	ret

;--------------------------------------------------------------
;--                        QuickSort()                       --
;--------------------------------------------------------------
QuickSort
	push	bp
	mov	bp, sp

	push	word [bp+8]
	push	word [bp+6]
	push	word [bp+4]
	call	libQuickSort
	add	sp, 6

	pop	bp
	ret

;--------------------------------------------------------------
;--                        BubbleSort()                      --
;--------------------------------------------------------------
BubbleSort
	push	bp
	mov	bp, sp

	push	word [bp+6]
	push	word [bp+4]
	call	libBubbleSort
	add	sp, 4

	pop	bp
	ret
