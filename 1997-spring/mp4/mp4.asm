        PAGE 75, 132
        TITLE Lunar_Lander - John Lockwood - 3/97

COMMENT %
        LUNAR LANDER
        -------------------
        ECE291: Machine Problem 4
        Prof. John W. Lockwood
        Unversity of Illinois, Dept. of Electrical & Computer Engineering
        Spring 1997
        Documentation: http://www.ece.uiuc.edu/~ece291/mp/mp4/mp4.html
        Revision 1.0
        %

;====== Constants =========================================================
VIDTXTSEG EQU 0B800h  ; VGA Video Segment Adddress (Text Mode)

;====== Externals =========================================================
; -- LIB291 Routines (Free) ---
extrn dspmsg:near, binasc:near, kbdin:near

; -- LIBMP4 Routines (You need to write these)
extern InstTime:near      ; Remove this line to use your own code
extern MyTimeInt:near     ; Remove this line to use your own code
extern DeInstallTime:near ; Remove this line to use your own code
extern InstKey:near       ; Remove this line to use your own code
extern MyKeyInt:near      ; Remove this line to use your own code
extern DeInstallKey:near  ; Remove this line to use your own code
extern DrawScreen:near    ; Remove this line to use your own code
extern ReDrawScreen:near  ; Remove this line to use your own code
extern FinalScreen:near   ; Remove this line to use your own code
extern MainLIB:near       ; Remove this line to use your own code

extern mp4xit:near    

;====== Stack ============================================================
stkseg  segment stack
        db 64 dup ('STACK   ')
stkseg  ends
           
;====== Begin Code/Data segment ==========================================
cseg    segment public  
        assume  cs:cseg, ds:cseg, ss:stkseg, es:nothing

;====== Variables ========================================================

        x   dw 0      ; Horizontal Position     (1/324 m)
        v_x dw 18     ; Horizontal Velocity     (1/18 m/s)
        a_x dw 0      ; Horizontal Acceleration (m/s^2)
                                               
        y   dw 60*324 ; Vertical Position       (1/324 m)
        v_y dw 0      ; Vertical Velocity       (1/18 m/s)
        a_y dw 0      ; Vertical Acceleration   (m/s^s)

        G   dw  3 ; Gravity        (m/s^2)
        T   dw  0 ; Main Thruster  (m/s^2)
        TL  dw  0 ; Left Thruster  (m/s^2)
        TR  dw  0 ; Right Thruster (m/s^2)

        Time dw 0 ; Flight Time (1/18 sec)

        Fuel_Init dw 2000 ; Initial Amount of Fuel (Full Tank)
        fuel dw ?

        ExitFlag db 0  ; 0=Run, 1=Exit - Set by keyboard Interrupt handler

PUBLIC x,v_x,a_x,y,v_y,a_y,G,T,TL,TR   ; Variables available to LIBMP4
PUBLIC Time,Fuel_Init,fuel,ExitFLag

;====== Procedures  =======================================================

        ; --------------------------------------
        ; Your subroutines go here
        ; --------------------------------------

;====== SECTION 6: Main procedure =========================================

main    proc    far
        mov     ax, cseg ; Initialize DS=CS 
        mov     ds, ax

        mov ax,0B800h    ; Load ES with video Segment 
        mov es,ax

        mov AX,2         ; Set 80x25 Text Mode
        int 10h

        MOV AX,Fuel_Init ; Initialize Fuel with full tank
        MOV Fuel,AX

        ; --------------------------------------
        CALL MainLib  ; Your MAIN goes here 
        ; --------------------------------------

        Call mp4xit
main    endp

cseg    ends
        end     main

