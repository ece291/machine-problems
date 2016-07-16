; MP3 - 291hack
;  The game map
;
; Ryan Chmiel, Summer 2002
; Author: Peter Johnson, Michael Urman
; University of Illinois, Urbana-Champaign
; Dept. of Electrical and Computer Engineering
;
; Version 1.0

	TILE_VISIBLE	EQU 80h
	TILE_SEEN	EQU 40h
	TILE_SOLID	EQU 20h	; sight AND walking

GLOBAL Map

SEGMENT code

; macros xrolmpqbd
%define x 0|TILE_SOLID	; black black emptiness
%define r 1		; room tile
%define o 2		; path tile
%define l 3|TILE_SOLID	; solid vertical wall
%define m 4|TILE_SOLID	; solid horizontal wall
%define p 5|TILE_SOLID	; solid corner walls
%define q 6|TILE_SOLID	;
%define b 7|TILE_SOLID	;
%define d 8|TILE_SOLID	;
%define e 9		; door tile

%macro break 2-*
%rep %0/2
times %1 db %2
%rotate 2
%endrep
%endmacro

Map
	times 80 db x
	times 80 db x
	times 80 db x
	break 20,x, 1,p, 8,m, 1,q,        20,x,		1,p, 8,m, 1,q, 20,x
	break 20,x, 1,l, 8,m, 1,l,        20,x,		1,l, 8,m, 1,l, 20,x
	break 20,x, 1,l, 8,r, 1,e, 3,o,     17,x,	1,l, 8,r, 1,l, 20,x
	break 20,x, 1,l, 8,r, 1,l, 2,x, 3,o, 15,x,	1,l, 8,r, 1,l, 20,x
	break 20,x, 1,l, 8,r, 1,l,  4,x, 3,o, 13,x,	1,l, 8,r, 1,l, 20,x
	break 20,x, 1,l, 8,r, 1,l,   6,x, 3,o, 11,x,	1,l, 8,r, 1,l, 20,x
	break 20,x, 1,l, 8,r, 1,l,    8,x, 4,o, 8,x,	1,l, 8,r, 1,l, 20,x
	break 20,x, 1,l, 8,r, 1,l,    11,x, 3,o, 6,x,	1,l, 8,r, 1,l, 20,x
	break 20,x, 1,l, 8,r, 1,l,     13,x, 3,o, 4,x,	1,l, 8,r, 1,l, 20,x
	break 20,x, 1,l, 8,r, 1,l,      15,x, 3,o, 2,x,	1,l, 8,r, 1,l, 20,x
	break 20,x, 1,l, 8,r, 1,l,           17,x, 3,o,	1,e, 8,r, 1,l, 20,x
	break 20,x, 1,l, 8,m, 1,l,        20,x,		1,l, 8,m, 1,l, 20,x
	break 20,x, 1,b, 8,m, 1,d,        20,x,		1,b, 8,m, 1,d, 20,x
	times 80 db x
	times 80 db x
	times 80 db x
	times 80 db x

