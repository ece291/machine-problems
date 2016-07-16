<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><% 
 
my @Functions = ( 
 "GetInput" => [ 
  [0, 15], 
 ], 
 "ParseInput" => [ 
  [0, 15], 
 ], 
 "PrintArray" => [ 
  [0, 10],
 ], 
 "Partition" => [ 
  [0, 20],
 ], 
 "QuickSort" => [ 
  [0, 10],
 ],
 "BubbleSort" => [ 
  [0, 10],
 ],
 ); 

my @Code = ( 
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
     6 => "Before _DEADLINE_: +2pts/weekday", 
     -80 => "After _DEADLINE_: -16pts/weekday", 
   ], 
); 

GradeSheet (\@Functions, \@Code); 
 
%>

