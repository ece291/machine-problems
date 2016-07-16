TITLE     ECE291        Your Name       Today's Date

COMMENT % Text Mode BlackJack
          ECE291 - Machine Problem 3
          Prof. Constantine Polychronopoulos
          Guest Author: Alex Jurcik
          University of Illinois at Urbana Champaign
          Dept. of Electrical & Computer Engineering
          Spring 2000

          Ver. 1.0
        %

;--------------------------------------------------------------
;--                   Defining  Constants                    --
;--------------------------------------------------------------

        ESCKEY  EQU     01
        HKEY    EQU     35
        SKEY    EQU     31
        ENTER   EQU     28
        SPACE   EQU     39h

        public ESCKEY, HKEY, SKEY, ENTER, SPACE

;--------------------------------------------------------------
;--               Declaring External Procedures              --
;--------------------------------------------------------------

;       Functions in LIB291.LIB These functions are free to 
;       be used by you. Complete descriptions of the LIB291
;       functions can be found in your lab manuals. Use these
;       functions for displaying output on the screen.

        extrn rsave:near, rrest:near, binasc:near, dspout:near, dspmsg:near

;       Functions in LIBMP3.LIB
;       You will need to write these functions for this program.

        extrn libKbdInstall:near, libKbdUninstall:near, libKbdHandler:near
        extrn libDrawBackground:near, libStartGame:near, libDisplayCard:near
        extrn libDrawCardFromDeck:near, libCalculateScore:near, libDisplayScore:near
        extrn libPlayerTurn:near, libDealerTurn:near, libMP3Main:near

;       This function terminates the program.
        extrn mp3xit:near

;--------------------------------------------------------------
;--                Defining the Stack Segment                --
;--------------------------------------------------------------

stkseg SEGMENT stack
        db  64 dup ('STACK  ')
stkseg ENDS

;--------------------------------------------------------------
;--                 Defining the Code Segment                --
;--------------------------------------------------------------

cseg SEGMENT PUBLIC 'CODE'
        assume cs:cseg, ds:cseg, ss:stkseg, es:nothing

;--------------------------------------------------------------
;--           Declaring variables for Lib Procedures         --
;--------------------------------------------------------------

oldKbdV         dd      ?               ; Address of old Kbd Handler

exitFlag        db      0               ; Flag to signify if ESC pressed

randomCard      dw      ?               ; Random card position in array
                                        ;    (0-51)

cardArray       db      52 dup(0)       ; Array of cards(1=chosen, 0=not)
playerHand      db      5  dup(?)       ; Array of cards in the players hand
                                        ;   indexed 0 - 51
playerCards     db      0               ; Number of cards in the player's hand
dealerHand      db      5  dup(?)       ; Array of cards in the dealers hand
                                        ;   indexed 0 - 51
dealerCards     db      0               ; Number of cards in the dealer's hand

drawCard        db      0               ; Flag for if the player wants to "hit"
stayPlayer      db      0               ; Flag for if the player wants to "stay"
spaceFlag       db      0               ; Flag for a waiting loop

playerScore1    dw      0               ; First player's score
playerScore2    dw      0               ; Second player's score
dealerScore     dw      0               ; Dealer's score
scoreBuffer     db      7 dup(' '),'$'  ; Buffer for BINASC

blackjackString db      'Blackjack','$' ; Various strings to show a game's
winString       db      'Win','$'       ;    outcome
drawString      db      'Draw','$'
loseString      db      'Lose','$'
blackjackFlag   db      0               ; Flag to signify if the player has
                                        ;    blackjack

include         bground.dat             ; 2000 byte character array to define our
                                        ;    wallpaper
                                        
public oldKbdV, exitFlag, randomCard, cardArray, playerHand, playerCards
public dealerHand, dealerCards, drawCard, stayPlayer, spaceFlag
public playerScore1, playerScore2, dealerScore, scoreBuffer, blackjackString
public winString, loseString, drawString, blackjackFlag, wallpaper

public KbdInstall, KbdUninstall, DrawBackground
public StartGame, DisplayCard, DrawCardFromDeck
public CalculateScore, DisplayScore, PlayerTurn
public DealerTurn

;--------------------------------------------------------------
;--                       Main Procedure                     --
;--------------------------------------------------------------

MAIN PROC FAR

        mov     ax, cseg    ; Use common code and data segment
        mov     ds, ax
        
        mov     ax, 0B800h  ; Use extra segment to access video screen
        mov     es, ax      ;
        
        mov     ah, 1       ; Set up the video screen
        mov     cx, 2000h   ;
        int     10h         ;
        
        call    MP3Main     ; This is where everything begins
        
        mov     ax, 0700h   ;
        mov     cx, 160*25  ; clearing
        mov     di, 0       ; the
                            ; screen
        rep     stosw   

        call    mp3xit

MAIN ENDP

;--------------------------------------------------------------
;--             Replace Library Calls with your Code!        --
;--             [Save all reg values that you modify]        -- 
;--             Do not forget to add Function Headers        --
;--------------------------------------------------------------

;--------------------------------------------------------------
;--                        KbdInstall()                      --
;--------------------------------------------------------------

KbdInstall PROC NEAR
        
        call    libKbdInstall
        ret
        
KbdInstall ENDP

;--------------------------------------------------------------
;--                       KbdUnInstall()                     --
;--------------------------------------------------------------

KbdUninstall PROC NEAR

        call    libKbdUninstall
        ret
        
KbdUninstall ENDP

;--------------------------------------------------------------
;--                        KbdHandler()                      --
;--------------------------------------------------------------

KbdHandler PROC NEAR

        
KbdHandler ENDP

;--------------------------------------------------------------
;--                       DrawBackground()                   --
;--------------------------------------------------------------

DrawBackground PROC NEAR

        call    libDrawBackground
        ret

DrawBackground ENDP

;--------------------------------------------------------------
;--                        StartGame()                       --
;--------------------------------------------------------------

StartGame PROC NEAR

        call    libStartGame
        ret

StartGame ENDP

;--------------------------------------------------------------
;--                       DisplayCard()                      --
;--------------------------------------------------------------

DisplayCard PROC NEAR

        call    libDisplayCard
        ret

DisplayCard ENDP

;--------------------------------------------------------------
;--                   DrawCardFromDeck()                     --
;--------------------------------------------------------------

DrawCardFromDeck PROC NEAR

        call    libDrawCardFromDeck
        ret
        
DrawCardFromDeck ENDP

;--------------------------------------------------------------
;--                    CalculateScore()                      --
;--------------------------------------------------------------

CalculateScore PROC NEAR

        call    libCalculateScore
        ret
        
CalculateScore ENDP

;--------------------------------------------------------------
;--                     DisplayScore()                       --
;--------------------------------------------------------------

DisplayScore PROC NEAR

        call    libDisplayScore
        ret
        
DisplayScore ENDP

;--------------------------------------------------------------
;--                      PlayerTurn()                        --
;--------------------------------------------------------------

PlayerTurn PROC NEAR

        call    libPlayerTurn
        ret

PlayerTurn ENDP

;--------------------------------------------------------------
;--                      DealerTurn()                        --
;--------------------------------------------------------------

DealerTurn PROC NEAR

        call    libDealerTurn
        ret

DealerTurn ENDP

;--------------------------------------------------------------
;--                        MP3Main()                         --
;--------------------------------------------------------------

MP3Main PROC NEAR

        call    libMP3Main
        ret

MP3Main ENDP

CSEG ENDS
        END MAIN

