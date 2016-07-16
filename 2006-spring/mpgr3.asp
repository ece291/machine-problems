<%@LANGUAGE=PerlScript %><!--#include file="ECE390.asp" --><% 
 
my @Functions = ( 
 "Init" => [ 
  [0, 11], 
 ], 
 "KbdInt" => [ 
  [0, 2], 
 ], 
 "ReadKeyboard" => [ 
  [0, 9],
 ], 
 "UpdateMoves" => [ 
  [0, 10], 
 ], 
 "ScrollMap" => [ 
  [0, 10], 
 ], 
 "CollisionDetect"=> [ 
  [0, 8], 
 ], 
 "DrawStatus"=> [ 
  [0, 4], 
 ], 
 "FindRespawn"=> [ 
  [0, 3], 
 ], 
 "Enq"=> [ 
  [0, 3], 
 ], 
 "Deq"=> [ 
  [0, 3], 
 ], 
"Style and Documentation (+3 now, with possible deductions during later grading. -0 for clear and precise comments, -2 for excessive \"sportscaster\" commenting, -2 for no function headers, -2 for convoluted code -1 for sparse and/or unclear comments.)" => [
     [0, 3],
   ],
 "Cover Memo (+4 now, with possible deductions during later grading. Please see the MP handout. -1 for each missing bullet point.)" => [
     [0, 4],
   ],

 ); 

my @Code = ( 
  "Penalty/Bonus" => [ 
     5 => "Before _DEADLINE_: +1pt/weekday", 
     -70 => "After _DEADLINE_: -7pts/weekday", 
   ], 
); 

GradeSheet (\@Functions, \@Code); 
 
%>