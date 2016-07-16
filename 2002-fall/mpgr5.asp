<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "Init" => [
  [0, 6],
  "Correctly sets up the interrupt handlers, and video",
 ],
 "ReceiveSrv" => [
  [-3, 3],
  "Receives Bytes via the Serial Port",
 ],
 "TransmitSrv" => [
  [-3, 3],
  "Sends Bytes via the Serial Port",
 ],
 "Task1" => [
  [-3, 3],
  "Handles key presses; quits on ESC",
 ],
 "Task2" => [
  [-3, 3],
  "Updates the local paddle position",
 ],
 "Task3" => [
  [-3, 3],
  "Updates the remote paddle position",
 ],
 "MoveBall" => [
  [-3, 3],
  "Moves the ball up and down",
 ],
 "MovePaddle" => [
  [-3, 3],
  "Moves the paddles up and down",
 ],
 "Circle" => [
  [-3, 3],
  "Draws a circle for the ball; uses Bresenham's algorithm",
 ],
 "Style (graded later)" => [
     [0, 6],
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
 "Peer Evaluation (graded later)" => [
     [0, 20],
     "Worked Satisfactorily with your group",
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
