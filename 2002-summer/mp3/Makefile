OBJS=mp3.obj map.obj shadows.obj

all: mp3.exe

clean: 
	rm -f mp3.exe $(OBJS) mp3.map

mp3.exe: $(OBJS)
	tlink /c /v $(OBJS), $@, mp3.map, lib291.lib

%.obj: %.asm
	nasm -g -f obj -o $@ $<

