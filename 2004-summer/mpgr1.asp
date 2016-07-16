<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "CalculateScores" => [
     [0, 20],
   ],
 "CalculateRanges" => [
     [0, 15],
   ],
 "ConstructStarString" => [
     [0, 15],
   ],
 "DisplayHistogram" => [
     [0, 15],
   ],
);

my @Code = (
 "Cover Memo" => [
     0 => "Cover memos are to be submitted along with the code for the MPs",
     -5 => "Did not submit or submitted insufficient cover memo",
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
     -2 => "Excessive sportscaster commenting",
     -2 => "No Function Headers",
     -3 => "Sparse and or unclear comments",
   ],
 "Penalty/Bonus" => [
     6 => "Before _DEADLINE_: +2pt/weekday",
     -65 => "After _DEADLINE_: -13pts/weekday",
   ],
);

GradeSheet (\@Functions, \@Code);

%>
