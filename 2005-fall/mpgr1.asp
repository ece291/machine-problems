<%@LANGUAGE=PerlScript %><!--#include file="ECE390.asp" --><%

my @Functions = (
 "Handles letters and asterisk; correctly prints messages \"No records found\" and  \"Invalid pattern\" " => [
     [0, 15],
   ],
 "Documentation and control structures (+5 now, with possible deductions during later grading. -0 for clear and precise comments, -2 for excessive \"sportscaster\" commenting, -2 for no function headers, -2 for convoluted code -1 for sparse and/or unclear comments.)" => [
     [0, 5],
   ],
 "Cover Memo (+4 now, with possible deductions during later grading. Please see the MP handout. -1 for each missing bullet point.)" => [
     [0, 4],
   ],
 "Photo" => [ [0,1] ]
 );

my @Code = (
 "Penalty/Bonus" => [
     5 => "Before _DEADLINE_: +1pt/weekday",
     -25 => "After _DEADLINE_: -6pts/weekday",
   ],
);

GradeSheet (\@Functions, \@Code);

%>
