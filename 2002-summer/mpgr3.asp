<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "MP3Main" => [
     [0, 12],
     "Game functions properly and exits when it should",
   ],
 "DrawMap" => [
     [0, 14],
     "Visible and Seen tiles are drawn as expected.",
     "Items cover tiles, and character covers all.",
   ],
 "MoveChar" => [
     [0, 16],
     "The correct tiles are Visible",
     "No orphan visible tiles after moving."
   ],
 "PickUp" => [
     [0, 10],
     "Only the first available item is picked up.",
     "Proper messages are displayed.",
   ],
 "DropItem" => [
     [0, 8],
     "Only held items are dropped.",
     "Proper messages are displayed.",
   ],
 "DrawString" => [
     [0, 8],
     "Messages appear correctly.",
   ],
 "InstallKeyboard<br>RemoveKeyboard<br>KeyboardISR" => [
     [0, 7],
     "Character moves, picks up, and drops items when commanded.",
     "Keyboard works properly after exiting program.",
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
     6 => "Before _DEADLINE_: +2pt/weekday",
     -75 => "After _DEADLINE_: -15pts/weekday",
   ],
);

GradeSheet (\@Functions, \@Code);

%>
