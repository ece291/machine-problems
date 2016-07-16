<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "MP3Main" => [
     [0, 7],
     "Worms move properly",
     "Game exits when it should",
   ],
 "MoveWorm" => [
     [0, 5],
     "Worms move forward.",
   ],
 "RedrawWorm" => [
     [0, 7],
     "Worms grow after eating food",     
   ],
 "AddHeadSeg" => [
     [0, 7],
     "Crashes occur properly at the front of the worm",
   ],
 "DelTailSeg" => [
     [0, 7],
     "Crashes do not occur behind the worm",
   ],
 "GetWormHead" => [
     [0, 5],
     "libAI functions properly",
   ],
 "HandleCollisions" => [
     [0, 7],
     "A worm colliding with a number causes that worm to grow",
     "A worm colliding with another worm or the wall causes the game to end",
   ],
 "CreateNumber" => [
     [0, 7],
     "Numbers appear randomly and are drawn to both the screen and the Map",
   ],
 "KeyboardISR" => [
     [0, 4],
     "Handles key presses properly, including escape",
   ],
 
 "TimerISR" => [
     [0, 4],
     "Worm moves forward every DELAYTICKS ticks.",
     "Chains to original interrupt"
   ],
 "InstallInt" => [
     [0, 6],
     "ISR handlers are properly installed and removed",
   ],
 "RemoveInt" => [
     [0, 4],
     "ISR handlers are properly removed",
   ],
"AIWorm" => [
     [0, 5],
     "Opponent worm is controlled by the computer",
     "2 pts for going after the food efficiently",
     "2 pts for not crashing when it could turn to avoid crashing (lib does not do this)",
     "1 pt for winning the AI tournament (4 pts prerequisite to enter)",
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
     -75 => "After _DEADLINE_: -7pts/weekday",
   ],
);

GradeSheet (\@Functions, \@Code);

%>
