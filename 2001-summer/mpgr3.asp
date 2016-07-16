<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "DrawGameboard" => [
     [0, 10],
     "",
   ],
 "DrawPalette" => [
     [0, 6],
     "",
   ],
 "DrawArrow" => [
     [0, 4],
     "",     
   ],
 "DrawPaletteArrow" => [
     [0, 4],
     "",
     "",
   ],
 "InstallTimer, RemoveTimer" => [
     [0, 3],
     "Correctly installs/removes the timer ISR",
     "Program does not crash on exit",
   ],
 "TimerISR" => [
     [0, 4],
     "Appropriately manages the timer variable",
   ],
 "Delay" => [
     [0, 5],
     "",
   ],
 "InstallKeyboard, RemoveKeyboard" => [
     [0, 3],
     "Correctly installs/removes the keyboard ISR",
     "Keyboard works after exit",
   ],
 "KeyboardISR" => [
     [0, 12],
     "",
     "",
     "",
   ],
 
 "PercolateUp" => [
     [0, 12],
     "",
   ],
 "CheckShot" => [
     [0, 4],
     "",
     "",
     "",
   ],
 "ChangeColor" => [
     [0, 4],
     "",
     
   ],
 "MoveArrow" => [
     [0, 4],
     "",
     "",
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
     -2 => "Lack of function headers (inputs, outputs, purpose)",
     -2 => "Excessive \"sportscaster\" commenting",
     -3 => "Sparse and/or unclear comments",
   ],
 "Penalty/Bonus" => [
     5 => "Before _DEADLINE_: +1pt/weekday",
     -50 => "After _DEADLINE_: -10pts/weekday",
   ],
);

GradeSheet (\@Functions, \@Code);

%>