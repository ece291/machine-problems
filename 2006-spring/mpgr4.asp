<%@LANGUAGE=PerlScript %><!--#include file="ECE390.asp" --><% 
 
my @Functions = ( 
 "_Generate" => [ 
  [0, 12], 
 ], 
 "_IteratePixel" => [ 
  [0, 6], 
 ], 
 "_SetLimit" => [ 
  [0, 6],
 ], 
 "_InstallMouse" => [ 
  [0, 3], 
 ], 
 "_MouseCallback" => [ 
  [0, 6], 
 ], 
 "_RemoveMouse"=> [ 
  [0, 3], 
 ], 
 "_FillColorMap"=> [ 
  [0, 12], 
 ], 
 "_Blend"=> [ 
  [0, 12], 
 ], 

"Style and Documentation (+5 now, with possible deductions during later grading. -0 for clear and precise comments, -2 for excessive \"sportscaster\" commenting, -2 for no function headers, -2 for convoluted code -1 for sparse and/or unclear comments.)" => [
     [0, 6],
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