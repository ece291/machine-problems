GLOBAL ShadowMaps

SEGMENT code

ShadowMaps
; no blocker (starting state, blocks edge of circular view)
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,1fh
db 00h,00h,00h,00h,1fh,1fh
db 00h,00h,00h,1fh,1fh,1fh
; blocker at (x,y)=(1,0)
db 00h,1dh,1fh,1fh,1fh,1fh
db 00h,0ch,1fh,1fh,1fh,1fh
db 00h,00h,0ch,1fh,1fh,1fh
db 00h,00h,00h,0ch,1fh,1fh
db 00h,00h,00h,00h,0ch,1fh
db 00h,00h,00h,00h,00h,0ch
; blocker at (x,y)=(2,0)
db 00h,00h,1dh,1fh,1fh,1fh
db 00h,00h,04h,1ch,1fh,1fh
db 00h,00h,00h,00h,04h,0ch
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
; blocker at (x,y)=(3,0)
db 00h,00h,00h,1dh,1fh,1fh
db 00h,00h,00h,04h,0ch,1eh
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
; blocker at (x,y)=(4,0)
db 00h,00h,00h,00h,1dh,1fh
db 00h,00h,00h,00h,04h,04h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
; blocker at (x,y)=(0,1)
db 00h,00h,00h,00h,00h,00h
db 1bh,03h,00h,00h,00h,00h
db 1fh,1fh,03h,00h,00h,00h
db 1fh,1fh,1fh,03h,00h,00h
db 1fh,1fh,1fh,1fh,03h,00h
db 1fh,1fh,1fh,1fh,1fh,03h
; blocker at (x,y)=(1,1)
db 00h,00h,00h,00h,00h,00h
db 00h,19h,1bh,13h,01h,01h
db 00h,1dh,1fh,1fh,1fh,1fh
db 00h,1ch,1fh,1fh,1fh,1fh
db 00h,08h,1fh,1fh,1fh,1fh
db 00h,08h,1fh,1fh,1fh,1fh
; blocker at (x,y)=(2,1)
db 00h,00h,00h,00h,00h,00h
db 00h,00h,19h,1bh,1bh,1bh
db 00h,00h,0ch,1fh,1fh,1fh
db 00h,00h,00h,0ch,1fh,1fh
db 00h,00h,00h,00h,0ch,1fh
db 00h,00h,00h,00h,00h,0ch
; blocker at (x,y)=(3,1)
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,19h,1bh,1bh
db 00h,00h,00h,0ch,1eh,1fh
db 00h,00h,00h,00h,00h,1ch
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
; blocker at (x,y)=(4,1)
db 00h,00h,00h,00h,00h,01h
db 00h,00h,00h,00h,19h,1fh
db 00h,00h,00h,00h,04h,1ch
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
; blocker at (x,y)=(0,2)
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 1bh,02h,00h,00h,00h,00h
db 1fh,13h,00h,00h,00h,00h
db 1fh,1fh,02h,00h,00h,00h
db 1fh,1fh,03h,00h,00h,00h
; blocker at (x,y)=(1,2)
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,19h,03h,00h,00h,00h
db 00h,1dh,1fh,03h,00h,00h
db 00h,1dh,1fh,1fh,03h,00h
db 00h,1dh,1fh,1fh,1fh,03h
; blocker at (x,y)=(2,2)
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,19h,13h,01h,00h
db 00h,00h,1ch,1fh,1fh,13h
db 00h,00h,08h,1fh,1fh,1fh
db 00h,00h,00h,1ch,1fh,1fh
; blocker at (x,y)=(3,2)
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,19h,1bh,03h
db 00h,00h,00h,0ch,1fh,1fh
db 00h,00h,00h,00h,0ch,1fh
db 00h,00h,00h,00h,00h,0ch
; blocker at (x,y)=(4,2)
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,19h,1bh
db 00h,00h,00h,00h,0ch,1fh
db 00h,00h,00h,00h,00h,04h
db 00h,00h,00h,00h,00h,00h
; blocker at (x,y)=(0,3)
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 1bh,02h,00h,00h,00h,00h
db 1fh,03h,00h,00h,00h,00h
db 1fh,17h,00h,00h,00h,00h
; blocker at (x,y)=(1,3)
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,19h,03h,00h,00h,00h
db 00h,1dh,17h,00h,00h,00h
db 00h,1dh,1fh,13h,00h,00h
; blocker at (x,y)=(2,3)
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,19h,03h,00h,00h
db 00h,00h,1dh,1fh,03h,00h
db 00h,00h,0ch,1fh,1fh,03h
; blocker at (x,y)=(3,3)
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,19h,13h,00h
db 00h,00h,00h,1ch,1fh,1bh
db 00h,00h,00h,00h,1dh,1fh
; blocker at (x,y)=(4,3)
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,19h,13h
db 00h,00h,00h,00h,0ch,1fh
db 00h,00h,00h,00h,00h,0ch
; blocker at (x,y)=(0,4)
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 1bh,02h,00h,00h,00h,00h
db 1fh,02h,00h,00h,00h,00h
; blocker at (x,y)=(1,4)
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,19h,02h,00h,00h,00h
db 08h,1fh,13h,00h,00h,00h
; blocker at (x,y)=(2,4)
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,19h,03h,00h,00h
db 00h,00h,1dh,1fh,02h,00h
; blocker at (x,y)=(3,4)
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,19h,03h,00h
db 00h,00h,00h,1ch,1fh,03h
; blocker at (x,y)=(4,4)
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,00h,00h
db 00h,00h,00h,00h,19h,13h
db 00h,00h,00h,00h,1ch,1fh
