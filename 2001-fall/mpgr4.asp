<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "PointInBox" => [
     [0, 2],
   ],
 "GetPixel" => [
     [0, 2],
   ],
 "DrawPixel" => [
     [0, 2],
   ],
 "DrawLine" => [
     [0, 7],
   ],
 "DrawRect" => [
     [0, 4],
   ],
 "DrawCircle" => [
     [0, 7],
   ],
 "DrawText" => [
     [0, 7],
   ],
 "ClearBuffer" => [
     [0, 3],
   ],
 "CopyBuffer" => [
     [0, 5],
   ],
 "ComposeBuffers" => [
     [0, 7],
   ],
 "BlurBuffer" => [
     [0, 7],
   ],
 "FloodFill" => [
     [0, 7],
   ],
 "InstallKeyboard" => [
     [0, 1],
   ],
 "RemoveKeyboard" => [
     [0, 1],
   ],
 "KeyboardISR" => [
     [0, 3],
   ],
 "InstallMouse" => [
     [0, 3],
   ],
 "RemoveMouse" => [
     [0, 1],
   ],
 "MouseCallback" => [
     [0, 6],
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
     -75 => "After _DEADLINE_: -7pts/weekday up to 5 days, -75 after 5 days",
   ],
);

GradeSheet (\@Functions, \@Code);

%>