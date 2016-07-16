OBJS=_mp4.o 
LIBS = v:/ece291/pmodelib/lib291.a
#LIBS += libmp4.a

all: _mp4.exe

clean: 
	-del $(MPNAME).exe

remake: clean all

%.exe: $(OBJS)
	gcc -o _mp4 $(OBJS) $(LIBS)

%.o: %.asm
	nasm -f coff -iv:/ece291/pmodelib/include/ -o $*.o $< -l $*.lst
