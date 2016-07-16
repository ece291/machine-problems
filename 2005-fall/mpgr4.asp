<%@LANGUAGE=PerlScript %><!--#include file="ECE390.asp" --><% 
 
my @Functions = ( 
 "Init" => [ 
  [0, 6], 
 ], 
 "KbdInit" => [ 
  [0, 3], 
 ], 
 "Task1" => [ 
  [0, 9],
 ], 
 "Task2" => [ 
  [0, 12], 
 ], 
 "Task3" => [ 
  [0, 3], 
 ], 
 "NewPosition"=> [ 
  [0, 3], 
 ], 
 "GenBrick"=> [ 
  [0, 6], 
 ], 
 "Enq/Deq"=> [ 
  [0, 6], 
 ], 

"Style and Documentation (+5 now, with possible deductions during later grading. -0 for clear and precise comments, -2 for excessive \"sportscaster\" commenting, -2 for no function headers, -2 for convoluted code -1 for sparse and/or unclear comments.)" => [
     [0, 8],
   ],
 "Cover Memo (+4 now, with possible deductions during later grading. Please see the MP handout. -1 for each missing bullet point.)" => [
     [0, 4],
   ],

 ); 

my @Code = ( 
  "Penalty/Bonus" => [ 
     5 => "Before _DEADLINE_: +1pt/weekday", 
     -60 => "After _DEADLINE_: -6pts/weekday", 
   ], 
); 

GradeSheet (\@Functions, \@Code); 
 
%>