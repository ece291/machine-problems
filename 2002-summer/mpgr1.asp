<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "GetNextHeader" => [
     [0, 12],
     "Program Exits after two CR",
     "Indentation matches expected values in test1.in",
   ],
 "GetIndent" => [
     [0, 12],
     "Proper Indentation is used for test2.in",
     "Invalid characters cause BEL to sound (test3.in)",
   ],
 "DisplayIndent" => [
     [0, 12],
     "2*Indent (BL) spaces displayed at beginning of line",
     "Procedure does not use MUL (checked post-handin)",
   ],
 "DisplayItem" => [
     [0, 12],
     "All characters after the Header character are shown",
     "Line stops at the CR, which is displayed",
     "All lines are shown - none overlap",
   ],
 "CalcTotals" => [
     [0, 15],
     "Totals are correctly calculated",
     "Procedure written with a loop construct rather than five individual calculations",
   ],
 "DispTotals" => [
     [0, 12],
     "Numbers are right-justified",
     "Procedure written with a loop construct rather than five individual displays",
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
     6 => "Before _DEADLINE_: +2pt/weekday",
     -75 => "After _DEADLINE_: -15pts/weekday",
   ],
);

GradeSheet (\@Functions, \@Code);

%>