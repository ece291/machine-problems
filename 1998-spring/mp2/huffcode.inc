; Using Lockwood's PhD thesis as a model for typical English usage
; The frequencies of each letter were determined as:
;
;   e 0.121 t 0.105 i 0.081 o 0.072 a 0.068 n 0.065 s 0.062 r 0.061 c 0.046
;   h 0.044 l 0.043 u 0.033 d 0.033 p 0.030 m 0.028 f 0.024 g 0.019 b 0.017
;   w 0.014 v 0.012 y 0.009 k 0.005 q 0.004 x 0.003 z 0.001 j 0.001
;
; Huffman's algorithm was then used to generate the variable length encoding
; for these symbols.

; Format: ASCII Letter, Pattern (MSB first), Pattern (LSB first), # bits)

HuffCodes HuffCode<' ',     01011b,11010b      ,5> 
          HuffCode<'A',      0000b,0000b       ,4>
          HuffCode<'B',    100100b,001001b     ,6>
          HuffCode<'C',      1101b,1011b       ,4>
          HuffCode<'D',     01100b,00110b      ,5>
          HuffCode<'E',       101b,101b        ,3>
          HuffCode<'F',     11001b,10011b      ,5>
          HuffCode<'G',    100101b,101001b     ,6>
          HuffCode<'H',     00101b,10100b      ,5>
          HuffCode<'I',      0011b,1100b       ,4>
          HuffCode<'J', 110000111b,111000011b  ,9>
          HuffCode<'K',   1001110b,0111001b    ,7>
          HuffCode<'L',     00100b,00100b      ,5>
          HuffCode<'M',     10000b,00001b      ,5>
          HuffCode<'N',      0111b,1110b       ,4>
          HuffCode<'O',      0001b,1000b       ,4>
          HuffCode<'P',     10001b,10001b      ,5>
          HuffCode<'Q',   1100000b,0000011b    ,7>
          HuffCode<'R',      0100b,0010b       ,4>
          HuffCode<'S',     01010b,01010b      ,5>
          HuffCode<'T',       111b,111b        ,3>
          HuffCode<'U',     01101b,10110b      ,5>
          HuffCode<'V',   1100010b,0100011b    ,7>
          HuffCode<'W',    100110b,011001b     ,6>
          HuffCode<'X',  11000010b,01000011b   ,8>
          HuffCode<'Y',   1001111b,1111001b    ,7>
          HuffCode<'Z', 110000110b,011000011b  ,9>
          HuffCode<'*',   1100011b,1100011b    ,7>


; Note: The symbols for space and * were added after calculation
;       of the Huffman encoding by splitting the nodes for S and V.
                                   

