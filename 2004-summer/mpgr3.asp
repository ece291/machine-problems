<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><% 
 
my @Functions = ( 
 "MP3Main" => [ 
  [0, 10], 
 ], 
 "MoveBalls" => [ 
  [0, 13], 
 ], 
 "MovePlayer" => [ 
  [0, 6],
 ], 
 "MoveComputer" => [ 
  [0, 8], 
 ], 
 "DrawBackground" => [ 
  [0, 4], 
 ], 
 "DrawPaddles" => [ 
  [0, 6], 
 ], 
 "DrawBalls" => [ 
  [0, 6],
 ],   
 "DrawStats" => [ 
  [0, 8], 
 ], 
 "RefreshScreen" => [ 
  [0, 4], 
 ],
 "InstallKeyboard" => [ 
  [0, 2], 
 ], 
 "RemoveKeyboard" => [ 
  [0, 2], 
 ], 
 "KeyboardISR" => [ 
  [0, 6], 
 ], 
 "InstallTimer" => [ 
  [0, 2], 
 ], 
 "RemoveTimer" => [ 
  [0, 2], 
 ], 
 "TimerISR" => [ 
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
     -85 => "After _DEADLINE_: -17pts/weekday", 
   ], 
); 

GradeSheet (\@Functions, \@Code); 
 
%>

