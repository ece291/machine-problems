        PAGE 75, 132
        TITLE NETLIB:NetBIOS Library Functions John Lockwood

.MODEL COMPACT  ; Allow Multiple Segments
.486            ; Enable use of 32-bit registers and 286/386/486 Registers

; ===== NetLIB Functions ==================================================

; NETBIOS Network Library Functions
; Multicast Datagram Transmit and Reception Funtions
; Copyright 1997, John Lockwood, All rights reserved
; Department of Electrical and Computer Engineering
; University of Illinois at Urbana/Champaign
; lockwood@ipoint.vlsi.uiuc.edu
; Version 1.0, April, 1997

PUBLIC NetInit    ; Initializes Network and allocates names
                  ; Output: AL = Player number (0..63)

PUBLIC SendPacket ; Sends a Packet
                  ; Inputs: TXBuffer = Data , length=AX

extrn  NetPost:near ; Callback function
                  ; Called with bx=offset RXBuffer, length=AX

PUBLIC NetRelease ; Release NetBIOS Names and Resources

PUBLIC TXBuffer   ; Transmit Buffer (1KByte)

PUBLIC RXBuffer   ; Receive Data Buffer (1KByte)

PUBLIC NetTest    ; Stand-alone Test routine

EXTRN  binasc:near, dspmsg:near, kbdin:near ; ECE291 Library Functions

; ===== Handy General-Purpose MACROS ======================================

INCLUDE MACROS.INC 

; ===== NetBIOS Network Control Block structure ===========================

NCB struc
        ncb_command     db ?    ; command code
        ncb_retcode     db ?    ; error return code
        ncb_lsn         db ?    ; session number
        ncb_num         db ?    ; name number
        ncb_buf_off     dw ?    ; ptr to send/receive data offset
        ncb_buf_seg     dw ?    ; ptr to send/receive data segment
        ncb_buflen      dw ?    ; length of data
        ncb_callname    db 16 dup (?) ; remote name
        ncb_name        db 16 dup (?) ; local name
        ncb_rto         db 0    ; receive timeout
        ncb_sto         db 0    ; send timeout
        ncb_post_off    dw ?    ; async command complete post offset
        ncb_post_seg    dw ?    ; async command complete post segment
        ncb_lana_num    db ?    ; adapter number
        ncb_cmd_done    db ?    ; 0FFh until command completed
        ncb_res         db 14 dup (?) ; reserved
NCB ends

; ===== NetBIOS command constants =========================================

        RESET                 equ 032h
        CANCEL                equ 035h
        STATUS                equ 0B3h
        STATUS_WAIT           equ 034h
        TRACE                 equ 0F9h
        UNLINK                equ 070h
        ADD_NAME              equ 0B0h
        ADD_NAME_WAIT         equ 030h
        ADD_GROUP_NAME        equ 0B6h
        ADD_GROUP_NAME_WAIT   equ 036h
        DELETE_NAME           equ 0B1h
        DELETE_NAME_WAIT      equ 031h
        CALL_                 equ 090h
        LISTEN                equ 091h
        HANG_UP               equ 092h
        SEND                  equ 094h
        CHAIN_SEND            equ 097h
        RECEIVE               equ 095h
        RECEIVE_ANY           equ 096h
        SESSION_STATUS        equ 0B4h
        SEND_DATAGRAM         equ 0A0h
        SEND_BCST             equ 0A2h
        RECEIVE_DATA          equ 0A1h
        RECEIVE_BCST_DATA     equ 0A3h

; ===== Handy NetBios MACROs ==============================================

INT5C MACRO buffer ; Call NetBIOS Interrupt 
        push    es                 ; save registers
        push    bx
        push    ax

        mov     ax, seg buffer
        mov     es, ax
        mov     bx, offset buffer
        int     05Ch               ; NetBIOS interrupt

        pop     ax
        pop     bx                 ; restore registers
        pop     es
ENDM

;====== Define code segment ====================================

cseg    segment public                  ; *** CODE SEGMENT ***
        assume  cs:cseg, ds:cseg, es:nothing

;====== Declare variables procedure ============================

grpsnd  NCB     <> ; Send Network Control Block
grprcv  NCB     <> ; Receive Network Control Block

RXBuffer db 1024 dup('?') ; Receive Data Buffer
TXBuffer db 1024 dup('?') ; Transmit Data Buffer

;-- 16 Byte NCB Group and Player names and numbers --
grp_name db     'ECE291LibTest$$$' ; Change this name for your own use!
grp_num  db     ? ; Determined by NetBIOS at runtime
my_name  db     'ECE291Tester00$$' ; No not move '00' 
my_num   db     ? ; Determined by NetBIOS at runtime

; Packet counters
rcvcnt     dw   0
sndcnt     dw   0
rcvbadpost dw   0

; Misc Variables
pbuf    db      7 dup(?)
crlf    db      CR,LF,'$'

;====== Send Packet Function =============================================

SendPacket PROC Near ; Send Packet
        ; Inputs: TXBuffer: Data Buffer to Transmit
        ;         AX: Data Length
        mov      grpsnd.ncb_command,  SEND_DATAGRAM
        mov      grpsnd.ncb_lana_num, 0               ; LAN Adapter 0
        MOVMB    grpsnd.ncb_num,      grp_num         ; Group Number
        STRCPY16 grpsnd.ncb_callname, grp_name
        mov      grpsnd.ncb_buf_off,  offset txbuffer ; What to Send
        mov      grpsnd.ncb_buf_seg,  cs
        mov      grpsnd.ncb_buflen,   ax 
        mov      grpsnd.ncb_post_off, 0 ; No post after sending
        mov      grpsnd.ncb_post_seg, 0
        INT5C    grpsnd
        inc      sndcnt
        RET
SendPacket ENDP

;====== Receive Interrupt (Post Function) ================================

Post PROC FAR uses ds es ax bx cx dx si di

        mov      ax, cs                  ; make sure ds=cs !!
        mov      ds, ax

        inc      rcvcnt                  ; Count Number of received packets
        cmp      grprcv.ncb_retcode,0
        je       postnoerror

        inc      rcvbadpost
        jmp      postdone

postnoerror:

        mov      bx, offset RXBuffer     ; Set BX = Buffer address
        mov      ax, grprcv.ncb_buflen   ; Set AX = Packet Length

        call     NetPost                 ; User Function

postdone:

        mov      grprcv.ncb_command,  RECEIVE_DATA    ; Command
        mov      grprcv.ncb_buflen,   SizeOf rxbuffer ; Max Message Length
        INT5C    grprcv

        IRET       
                                ; return from interrupt
post EndP

;====== Network INIT ====================================================

NetINIT Proc NEAR

        PRINTMSG 'NetINIT: Initializing NetBIOS'
        PRINTSTR 'Adding NCB Group Name: ',grp_name

        mov      grpsnd.ncb_command, ADD_GROUP_NAME_WAIT
        STRCPY16 grpsnd.ncb_name, grp_name
        INT5C    grpsnd
        cmp      grpsnd.ncb_retcode,0
        je       NIok1 

        PRINTMSG 'Group name already in use on this machine'
        JMP error

NIok1:  MOVMB    grp_num,             grpsnd.ncb_num

NInext: mov      grpsnd.ncb_command,  ADD_NAME_WAIT
        STRCPY16 grpsnd.ncb_name, my_name
        PRINTSTR 'Adding my NCB name: ',grpsnd.ncb_name
        INT5C    grpsnd
        cmp      grpsnd.ncb_retcode, 0
        jne      NIplus

        PRINTMSG 'Registering Post Function to receive datagrams: '
        mov      grprcv.ncb_command,  RECEIVE_DATA    ; Command
        mov      grprcv.ncb_lana_num, 0               ; LAN Adapter
        mov      grprcv.ncb_buf_off,  offset rxbuffer ; Buffer
        mov      grprcv.ncb_buf_seg,  cs              ;
        mov      grprcv.ncb_buflen,   SizeOf rxbuffer ; Max Message Length
        MOVMB    grprcv.ncb_num,      grp_num         ; Group Number
        mov      grprcv.ncb_post_off, offset Post     ; POST Routine called
        mov      grprcv.ncb_post_seg, cs              ;  on Packet arrival
        INT5C    grprcv

        ; Return with AL = My Player Number 
        MOV AH,10
        MOV AL,my_name[12]
        SUB AL,'0'     
        MUL AH
        ADD AL,my_name[13]
        SUB AL,'0'

        PRINTMSG 'Network Ready!'
        Jmp NetFinished


; Generates 'ECE291Player00$$'..'ECE291Player63$$' string

NIplus: CMP my_name[12],'6'
        JB NIok2
        CMP my_name[13],'4'
        JB NIok2
        PRINTMSG 'All Player Names in use'
        jmp Error

NIok2:  INC my_name[13]
        CMP my_name[13],'9'+1 ; invalid digit
        JNE NInext

        INC my_name[12]
        MOV my_name[13],'0'
        JMP NInext

NetFinished:
        RET
NetINIT EndP

;====== Network Release =================================================

NetRelease Proc NEAR

        PRINTMSG  'NetRelease: Free NetBIOS Names & Resources'

        PRINTMSG  'Releasing Name..'
        mov       grpsnd.ncb_command, DELETE_NAME_WAIT
        STRCPY16  grpsnd.ncb_name, my_name
        INT5C     grpsnd

        PRINTMSG  'Releasing Group ..'
        mov       grpsnd.ncb_command, DELETE_NAME_WAIT
        STRCPY16  grpsnd.ncb_name, grp_name
        INT5C     grpsnd

        PRINTNUM 'Total Packets Sent: ' ,     sndcnt
        PRINTNUM 'Total Packets Received: ' , rcvcnt
        PRINTNUM 'Errored Packets Received: ' , rcvbadpost


        RET
NetRelease EndP

;====== Fatal Network Error ============================================

Error:  PRINTNUMB 'NetBIOS Error ', grpsnd.ncb_retcode
        DOSEXIT grpsnd.ncb_retcode

;====== Test Routine ===================================================

NetTest proc near

        Call NetInit
        MOV AH,0                
        PRINTNUM 'My ID = ', AX

MLoop:  PRINTMSG 'Sending Packet'
        MOV AX,700 ; Length
        Call SendPacket

        Delay 500

        PRINTNUM 'Packets Sent: ' ,     sndcnt
        PRINTNUM 'Packets Received: ' , rcvcnt
        PRINTNUM 'Errored Packets Received: ' , rcvbadpost

        mov     ah, 1                   ; loop until a key is pressed
        int     016h
        jz      MLoop

        Call NetRelease
        RET

NetTest EndP

; =========== Section 6: main procedure =================================


cseg    ends
        end
