all: mp1.exe

mp1.obj: mp1.asm events.inc 
        masm mp1,,;

mp1.exe: mp1.obj
        link mp1,,,lib291/map+libmp1/map;
