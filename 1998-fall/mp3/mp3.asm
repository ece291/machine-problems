TITLE ECE291:MP3-LiteCycles - Your Name - Date

COMMENT % TRON LiteCycle Game with AI players.

          ECE291: Machine Problem 3
          Prof. John W. Lockwood
          Guest Author: Josh Scheid
          University of Illinois
          Dept. of Electrical & Computer Engineering
          Fall 1998
          
          Ver. 1.0
        %

;====== Constants =========================================================

INCLUDE mp3const.asm    ; MP3 constants file

;====== Externals =========================================================

; -- LIB291 Routines (Free) ---
extrn binasc:near, dspmsg:near
extrn rsave:near, rrest:near
extrn mp3xit:near               ; Exit program with a call to this procedure

; -- LIBMP3 Routines (Replace these with your own code) ---

extrn DrawScreen:near           ; display initial game grid on screen
extrn ResetGrid:near            ; initialize game grid
extrn DrawCycles:near           ; place cycles at new position and
                                ; check for collisions
extrn SetPlayerPos:near         ; determine player starting positions
extrn SetGameSpeed:near         ; determine new game speed
extrn InstTimer:near            ; install 'MyTimerHandler in place of default
                                ; handler and speed up timer rate
extrn DeInstTimer:near          ; deinstall 'MyTimerHandler'; reinstall
                                ; default handler and restore normal timer rate
extrn MyTimerHandler:near       ; handle timer interrupt
extrn InstKey:near              ; install 'MyKeyHandler' in place of default
extrn DeInstKey:near            ; deinstall 'MyKeyHandler'; reinstall default
extrn MyKeyHandler:near         ; handle keyboard interrupt

extrn GameMain:near             ; executes game loop and inner round loop

extrn P1Control:near            ; get next direction that player one will go
extrn P2Control:near            ; get next direction that player two will go

;====== SECTION 3: Define stack segment ===================================
stkseg  segment stack                   ; *** STACK SEGMENT ***
        db      64 dup ('STACK   ')     ; 64*8 = 512 Bytes of Stack
stkseg  ends

;====== SECTION 4: Define code segment ====================================
cseg    segment public  'CODE'    ; *** CODE SEGMENT ***
        assume  cs:cseg, ds:cseg, ss:stkseg, es:nothing

;====== SECTION 5: Variables ==============================================
PUBLIC StartMsg, CrashedMsg, WonRoundMsg, CrashedMsg, WonRoundMsg, AndMsg
PUBLIC BothCrashedMsg, CollidedMsg, SpaceMsg, Blank8Msg, RoundInfoMsg
PUBLIC grid, p1X, p1Y, p2X, p2Y 
PUBLIC playerPosState, p1Score, p2Score, p1Name, p2Name, escPressed, spcPressed      
PUBLIC p1KeyDir, p2KeyDir, p1Dir, p2Dir, round, pbuf 
PUBLIC oldTimerV, oldKeyV, timerCount, gameSpeed      

StartMsg        db CR,LF
  db '----------------------- MP3: LiteCycles ----------------------',CR,LF
  db CR,LF
  db 'Controls:  Player 1 (blue)    Player 2 (red)                 ',CR,LF
  db CR,LF
  db '   UP         W               8 (numpad)                  ',CR,LF
  db '   DOWN       S               2 (numpad)                  ',CR,LF
  db '   LEFT       A               4 (numpad)                  ',CR,LF
  db '   RIGHT      D               6 (numpad)                  ',CR,LF
  db CR,LF
  db 'Press the escape key <esc> at any time to end the game.      ',CR,LF
  db CR,LF
  db 'Press the space bar now to begin!!!                          ',CR,LF,'$'

CrashedMsg      db ' crashed!','$'
WonRoundMsg     db ' won round ','$'
AndMsg          db ' and ','$'
BothCrashedMsg  db ' both crashed!','$'
CollidedMsg     db ' collided!','$'
SpaceMsg        db '(press the space bar to start next round)','$'
Blank8Msg       db '        ','$'

RoundInfoMsg    db      '    Round:','$'

grid            db      (GRIDSIZE_X * GRIDSIZE_Y) dup(?)
                        ;allocates memory for game grid

p1X             db      ?      ;player 1 X coord
p1Y             db      ?      ;         Y coord
p2X             db      ?      ;player 2 X coord
p2Y             db      ?      ;         Y coord

playerPosState  db      0       ;player position state

p1Score         dw      0       ;number of rounds that player 1 has won
p2Score         dw      0       ;number of rounds that player 2 has won

; Eight-character strings for player names
p1Name     db      'Player1 ','$'
p2Name     db      'Player2 ','$'

escPressed      db      0       ;flag set if ESC key pressed
spcPressed      db      0       ;flag set if SPC key pressed

; for controlling players through kbd
p1KeyDir        db      UP      ;set by MyKeyHandler
p2KeyDir        db      UP

p1Dir           db      UP      ;direction specified by P1Control
p2Dir           db      UP      ;direction specified by P2Control

round           dw      1       ;current round of game play

pbuf            db      7 dup (?) ;buffer for BINASC

oldTimerV       dd      ?       ;far pointer to default 08h
                                ;  interrupt function
oldKeyV         dd      ?       ;far pointer to default key
                                ;  interrupt function                                
timerCount      db      0       ;counter (to be incremented every 1/72 sec) 

gameSpeed       db      24      ;value that TimerCount should reach before
                                ;advancing game state
                                ;initial speed should be 1/3 sec. (24/72)                                
                                   
;====== Procedures ========================================================


; Your Subroutines go here !
; ---- ----------- -- ----


;====== Main procedure ====================================================

MAIN    PROC    FAR

        MOV     AX, CSEG
        MOV     DS, AX

        ; Put display into 80x50 text mode
        MOV     AX, 1202h               ; Sets to 400 line scan mode
        MOV     BL, 30h
        int     10h
        MOV     AX, 3                   ; Sets to 8x8 font
        INT     10h
        MOV     AX, 1112h               ; Enter text mode
        MOV     BL, 0
        INT     10h
        
        CALL    GameMain                ; Where all the action happens!
        
        CALL    MP3XIT                  ; Exit to DOS

MAIN    ENDP

CSEG    ENDS
        END     MAIN
