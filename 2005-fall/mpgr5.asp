<%@LANGUAGE=PerlScript %><!--#include file="ECE390.asp" --><% 
 
my @Functions = ( 
 "Functionality (each function roughly 3 points)" => [ 
  [0, 25], 
 ], 
 "Team charter" => [
  [0,5],
 ],
 "Technique, Style, ... (+3 now, with possible deductions during later grading. -0 for clear and precise comments, -2 for excessive \"sportscaster\" commenting, -2 for no function headers, -1 for sparse and/or unclear comments.) and Documention (+3 now, with possible deductions during later grading. -0 for compact and efficient code, -1 for awkward use of conditional jumps or loops, -1 for extraneous use of registers and/or variables, -1 for excessive coding.)" => [
     [0, 6],
   ],
 "Cover Memo (+4 now, with possible deductions during later grading. Please see the MP handout. -1 for each missing bullet point.)" => [
     [0, 4],
   ],
 "Peer Evaluation" => [
     [0, 20],
   ],
 ); 

my @Code = ( 
  "Penalty/Bonus" => [ 
     5=> "Before _DEADLINE_: +1pt/weekday", 
     -60 => "After _DEADLINE_: -6pts/weekday", 
   ], 
); 

GradeSheet (\@Functions, \@Code); 
 
%>

