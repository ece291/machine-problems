<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "SortFew" => [
  [0, 9],
  "Generates the list of numbers to be sorted",
 ],
 "Timing" => [
  [0, 12],
  "Reports correct timing results",
 ],
 "SelectSort" => [
  [0, 9],
  "Applies the Select Sort algorithm correctly",
 ],
 "Partition" => [
  [0, 12],
  "Partitions an array for QSorts recursive step",
 ],
 "QSort" => [
  [0, 9],
  "Applies the QSort algorithm correctly",
 ],
 "Style (graded later)" => [
     [0, 5],
     "Follows specifications for modularity, including using variable names instead of hardcoded addresses (1 point)",
     "Uses good control structures efficiently: (2 points)",
     " - Avoids use of extraneous variables, extraneous registers, or excessive code",
     "Has satisfactory documentation: (2 points)",
     " - Includes function headers (I/O and purpose) and sufficient body comments",
     " - Avoids \"sportscaster\" comments",
   ],
 "Cover Memo (graded later)" => [
     [0, 4],
     "Turned in satisfactory Cover Memo",
   ],
 );

my @Code = (
 "Penalty/Bonus" => [
  5 => "Before _DEADLINE_: +1pts/weekday",
  -60 => "After _DEADLINE_: -6pts/weekday",
 ],
);

GradeSheet (\@Functions, \@Code);

%>