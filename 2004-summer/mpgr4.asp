<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (

 "MP4" => [
  [0, 90],
 ],

 );

my @Code = ( 
 "Individual Contribution" => [ 
     0 => "", 
     -90 => "", 
   ], 
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
     -2 => "Excessive \"sportscaster\" commenting", 
     -2 => "No Function Headers", 
     -3 => "Sparse and/or unclear comments", 
   ], 
 "Penalty/Bonus" => [ 
     6 => "Before _DEADLINE_: +2pt/weekday", 
     -90 => "After _DEADLINE_: -18pts/weekday", 
   ], 
); 



GradeSheet (\@Functions, \@Code);



%>
