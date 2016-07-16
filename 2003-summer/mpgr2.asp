<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><% 
 
my @Functions = ( 
 "GetStr" => [ 
  [0, 10], 
  "Inputs an entire line of user input", 
  "Ignores LF, clears character on BS unless at beginning of line", 
  "Terminates input with \$ ", 
  "Never writes more characters than buffer can hold", 
  "Returns when CR is press", 
 ], 
 "Prime" => [ 
  [0, 10], 
  "Determines if number is prime", 
 ], 
 "InitSerial" => [ 
  [0, 15], 
  "Sets serial baud rate correctly", 
  "Sets serial line options correctly", 
  "Display serial line interrupts", 
 ], 
 "Recv" => [ 
  [0, 10], 
  "Reads input and stores it to buffer", 
  "Stops when it receives \$ or when input is full", 
  "Terminates buffer with \$ ", 
 ], 
 "Send" => [ 
  [0, 10], 
  "Send string character by character over serial port", 
 ], 
 "Keys" => [ 
  [0, 15], 
  "Reads K1 and K2 from input and determines whether they are valid", 
  "Finds InvK1 and prints its value",   
 ], 
 "EncDec" => [ 
  [0, 10], 
  "Encodes/Decodes uppercase letters of string", 
 ] 
 ); 
my @Code = ( 
 "Modularity" => [ 
     0 => "Program should follow all specifications of assignment", 
     -3 => "Used hardcoded address rather than pointers", 
   ], 
 "Technique and Style" => [ 
     0 => "Program should be comprised of compact and efficient code", 
     -2 => "Awkward use of conditional jumps or loops", 
     -3 => "Extraneous use of registers and/or variables", 
     -3 => "Excessive coding", 
   ], 
 "Comments" => [ 
     0 => "Program should have clear and precise comments", 
     -2 => "Excessive \"sportscaster\" commenting", 
     -2 => "No Function Headers", 
     -3 => "Sparse and/or unclear comments", 
   ], 
 "Penalty/Bonus" => [ 
     6 => "Before _DEADLINE_: +2pt/weekday", 
     -50 => "After _DEADLINE_: -10pts/weekday", 
   ], 
); 

GradeSheet (\@Functions, \@Code); 
 
%>

