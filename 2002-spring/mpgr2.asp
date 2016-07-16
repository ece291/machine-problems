<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "MP2Main" => [
  [0, 12],
  "",
  "",
 ],
 "DisplayMatrix" => [
  [0, 4],
  "",
  "",
 ],
 "Dispatch" => [
  [0, 13],
  "",
 ],
 "ReadWord" => [
  [0, 7],
  "",
 ],
 "UpdateCopy" => [
  [0, 5],
  "<em></em>",
  " ",
 ],
 "Naive" => [
  [0, 12],
  "Finds all instances (forwards and reverse) of each of the following words in the default matrix:",
  "<tt>a hello wer ree hat sa bed</tt>"
 ],
 "KMP" => [
  [0, 12],
  "Finds all instances (forwards and reverse) of each of the following words in the default matrix:",
  "<tt>a hello wer ree hat sa bed</tt>",
 ],
 "ComputeFail" => [
  [0, 10],
  "",
  "",
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
  -2 => "No Function Headers",
  -2 => "Excessive \"sportscaster\" commenting",
  -3 => "Sparse and/or unclear comments",
 ],
 "Penalty/Bonus" => [
  5 => "Before _DEADLINE_: +1pts/weekday",
  -75 => "After _DEADLINE_: -7pts/weekday up to 5 days, -75 after 5 days",
 ],
);

GradeSheet (\@Functions, \@Code);

%>