all: mp0.exe

mp0.exe: mp0.obj
   link /co mp0,,,lib291/map;

mp0.obj: mp0.asm
   masm /Zi mp0,,;

clean:
   del mp0.exe
   del *.obj
   del *.map
   del *.lst
 

