<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "CrossProduct" => [
     [0, 8],
   ],
 "MulVectorMatrix" => [
     [0, 6],
   ],
 "CreateCamera" => [
     [0, 6],
   ],
 "MoveCamera" => [
     [0, 10],
   ],
 "ConvertPoint" => [
     [0, 10],
   ],
 "CalcNextPoint" => [
     [0, 3],
   ],
 "DrawPixel" => [
     [0, 5],
   ],
 "DrawLine" => [
     [0, 3],
   ],
 "DrawTriangle" => [
     [0, 3],
   ],
 "AlphaCompose" => [
     [0, 3],
   ],
 "DrawText" => [
     [0, 8],
   ],
 "InstallKeyboard" => [
     [0, 1],
   ],
 "RemoveKeyboard" => [
     [0, 1],
   ],
 "KeyboardISR" => [
     [0, 2],
   ],
 "InstallMouse" => [
     [0, 2],
   ],
 "RemoveMouse" => [
     [0, 2],
   ],
 "MouseCallback" => [
     [0, 2],
   ],
);

my @Code = (
 "Modularity" => [
     0 => "Program should follow all specifications of assignment",
     -3 => "Used hardcoded address rather than pointers",
   ],
 "Technique and Style" => [
     0 => "Program should be comprised of compact and efficient code",
     -2 => "Awkward use of conditional jumps or loops",
     -2 => "C-style functions push and pop registers other than esi/edi",
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
     5 => "Before _DEADLINE_: +1pt/weekday",
     -75 => "After _DEADLINE_: -7pts/weekday up to 5 days, -75 after 5 days",
   ],
);

GradeSheet (\@Functions, \@Code);

%>