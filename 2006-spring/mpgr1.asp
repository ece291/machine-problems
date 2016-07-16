<%@LANGUAGE=PerlScript %><!--#include file="ECE390.asp" --><%

my @Functions = (
 "Init" => [
     [0, 4],
   ],
 "ProcessChar" => [
     [0, 20],
   ],
 "DisplayWord" => [
     [0, 8],
   ],
 "DisplayUsed" => [
     [0, 8],
   ],
 "CheckWinner" => [
     [0, 10],
   ],
 "Documentation and control structures (+6 now, with possible deductions during later grading. -0 for clear and precise comments, -2 for excessive \"sportscaster\" commenting, -2 for no function headers, -2 for convoluted code -1 for sparse and/or unclear comments.)" => [
     [0, 6],
   ],
 "Cover Memo (+4 now, with possible deductions during later grading. Please see the MP handout. -1 for each missing bullet point.)" => [
     [0, 4],
   ],
 );

my @Code = (
 "Penalty/Bonus" => [
     5 => "Before _DEADLINE_: +1pt/weekday",
     -25 => "After _DEADLINE_: -6pts/weekday",
   ],
);

GradeSheet (\@Functions, \@Code);

%>
