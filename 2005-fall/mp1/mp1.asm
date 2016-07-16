; MP1 - Restaurant Guide
; Your name
; Date
;
; This program illustrates the use of a simple loop for data retrieval,
; logic tests with multiple comparisons, and addressing modes.

        BITS    16

;====== SECTION 1: Define constants =======================================

        CR      EQU     0Dh
        LF      EQU     0Ah
        MaxPat  EQU     30              ; Maximum length of pattern string

; You may define additional constants here

;====== SECTION 2: Declare external procedures ============================

EXTERN  kbdine, dspout, dspmsg, dosxit

;====== SECTION 3: Define stack segment ===================================

SEGMENT stkseg STACK                    ; *** STACK SEGMENT ***
        RESB      64*8
stacktop:
        RESB    0                       ; NASM bug workaround

;====== SECTION 4: Define code segment ====================================

SEGMENT code                            ; *** CODE SEGMENT ***

;====== SECTION 5: Declare variables for main procedure ===================

prompt  DB      CR,LF,LF,'Type a pattern: ','$'
nonemsg DB      CR,LF,'No records found','$'
invmsg  DB      CR,LF,'Invalid pattern','$'
pattrn  RESB    MaxPat
reclst  DB      'IM Biaggis     ','$'
        DB      'AI Courier Cafe','$'
        DB      'MI Fiesta Cafe ','$'
        DB      'CI First Wok   ','$'
        DB      'AE Kennedys    ','$'
        DB      'AM Milos       ','$'
        DB      'IM Olive Garden','$'
        DB      'SI Panera      ','$'
        DB      'PM Papa Dels   ','$'
        DB      'MI Qdoba Grill ','$'
        DB      'MM Radio Maria ','$'
        DB      'AM Silvercreek ','$'
        DB      'SI Subway      ','$'
        DB      'CM Tang Dynasty','$'
        DB      'IE Timpones    ','$'
        DB      'PI Zas         ','$'
recend  RESB      0                     ; Name of next byte after all records

;You may declare additional variables here

;====== SECTION 6: Program initialization =================================

..start:
        MOV     AX, CS                  ; Initialize Default Segment register
        MOV     DS, AX
        MOV     AX, stkseg              ; Initialize Stack Segment register
        MOV     SS, AX
        MOV     SP, stacktop            ; Initialize Stack Pointer register

;====== SECTION 7: Main procedure =========================================

main:

; Your program goes here

        CALL    dosxit
