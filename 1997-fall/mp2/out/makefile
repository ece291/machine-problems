ALL: MP2.EXE

MP2.EXE: MP2.OBJ LIBMP2.LIB
        Link /CO MP2,,,LIBMP2/MAP+LIB291/map;

MP2.OBJ: MP2.ASM 
        Masm /Zi MP2,,;

CLEAN:
        DEL MP2.OBJ
        DEL MP2.LST
        DEL MP2.EXE
        DEL MP2.MAP
