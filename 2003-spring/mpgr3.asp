<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "main" => [
  [0, 5],
  "",
 ],
 "InitDisplay" => [
  [0, 4],
  "Initializes the video display correctly",
 ],
 "InitVectors" => [
  [0, 3],
  "Initializes the Timer and Keyboard interrupt vectors correctly",
 ],
 "RestoreVectors" => [
  [0, 3],
  "Restores the old Timer and Keyboard interrupt vectors correctly",
 ],
 "TimerInt" => [
  [0, 1],
  "Increments the Ticks variable",
 ],
 "KbdInt" => [
  [0, 8],
  "Handles key presses and releases correctly",
  "Enqueues ascii code onto keyboard queue when appropriate",
 ],
 "CheckKeyPress" => [
  [0, 4],
  "Dequeues ascii code from keyboard queue",
  "Compares the keyboard input to the string",
 ],
 "DisplayScore" => [
  [0, 4],
  "Displays the correct score to the middle of the screen",
 ],
 "DisplayString" => [
  [0, 4],
  "Displays a string to the screen by accessing the video memory directly",
 ],
 "DisplayFallingStr" => [
  [0, 4],
  "Displays a falling string",
 ],
 "Enq" => [
  [0, 3],
  "Enqueues a byte onto the circular keyboard queue",
 ],
 "Deq" => [
  [0, 3],
  "Dequeues a byte from the circular keyboard queue",
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
  -55 => "After _DEADLINE_: -6pts/weekday",
 ],
);

GradeSheet (\@Functions, \@Code);

%>