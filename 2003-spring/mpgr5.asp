<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "copyBuffer2BufferWithAlpha" => [
  [0, 8],
  "Correctly blit images with alpha blending, do 2 pixels at a time",
 ],
 "markAttached" => [
  [0, 6],
  "Bubbles fall off screen when not attached to top",
 ],
 "countMatched" => [
  [0, 6],
  "Matched bubble are removed from the screen",
 ],
 "updateMovingBubbles" => [
  [0, 6],
  "Bubbles move around and fall",
 ],
 "shootBubble" => [
  [0, 6],
  "Can shoot bubble in range of directions, won't shoot bubble when there already is a bubble shooting",
 ],
 "clearBubbleMarkerFlag" => [
  [0, 4],
  "It should be obvious if this doesn't work",
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
