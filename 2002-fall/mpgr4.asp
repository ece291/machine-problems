<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "Init" => [
  [0, 6],
  "Correctly sets up the interrupt handlers, video, and worm",
 ],
 "KbdInt" => [
  [0, 4],
  "Puts a key onto the keyboard queue",
 ],
 "Task1" => [
  [0, 6],
  "Handles key presses; quits on ESC",
 ],
 "Task2" => [
  [0, 13],
  "Updates the worm position and gives feedback",
 ],
 "CheckLegal" => [
  [0, 6],
  "Verifies a location is available for movement",
 ],
 "GenFood" => [
  [0, 4],
  "Places a new food pellet in a free location",
 ],
 "Enq" => [
  [0, 6],
  "Enqueues a byte onto a circular queue",
 ],
 "Deq" => [
  [0, 6],
  "Dequeues a byte from a circular queue",
 ],
 "Style (graded later)" => [
     [0, 5],
     "Follows specifications for modularity, including using variable names instead of hardcoded addresses (1 point)",
     "Uses good control structures efficiently: (2 points)",
     " - Avoids use of extraneous variables, extraneous registers, or excessive code",
     "Has satisfactory documentation: (2 points)",
     " - Includes function headers (I/O and purpose) and sufficient body comments",
     " - Avoids \"sportscaster\" comments",
   ],
 "Cover Memo (graded later)" => [
     [0, 4],
     "Turned in satisfactory Cover Memo",
   ],
 );

my @Code = (
 "Penalty/Bonus" => [
  5 => "Before _DEADLINE_: +1pts/weekday",
  -60 => "After _DEADLINE_: -6pts/weekday",
 ],
);

GradeSheet (\@Functions, \@Code);

%>
