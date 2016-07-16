
---------- MP2 Menu -----------
  Enter   (T)ext    (B)inary
  Print   (M)essage (R)buffeR
  Huffman (E)ncode  (D)ecode
-------- [ESC] = exit ---------

Enter Binary Data (LSBit .. MSBit): 
101

Text Message=
E

Enter Text Message: 
Z

Compressed Size = 9 bits ~= 1 bytes.  (LSBit .. MSBit)
11000011 0

Enter Text Message: 
HELLO

Compressed Size = 22 bits ~= 2 bytes.  (LSBit .. MSBit)
00101101 00100001 000001



LIBMP2 Calls: 
 -PrintBuffer 
 -ReadBuffer 
 -ReadTextMsg 
 -PrintTextMsg 
 -Encode 
 -AppendBufferN 
 -EncodeHuff 
 -DecodeHuff 

