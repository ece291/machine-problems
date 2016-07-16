<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "GetInput" => [
  [0, 12],
  "Inputs an entire line of user input",
  "Ignores LF, clears character on BS unless at beginning of line",
 ],
 "ProcessInput" => [
  [0, 14],
  "Ignores whitespace at the beginning of the command buffer",
  "PUSHes a number, returns a valid op, or returns 0",
 ],
 "Calculate" => [
  [0, 20],
  "Math operations yield correct answers (for non-negative numbers)",
 ],
 "int GCD(m,n)" => [
  [0, 15],
  "<strong>Recursively</strong> calculates the GCD of two 16-bit numbers",
  "Properly handles m or n being 0 (should return 1).",
 ],
 "PrintRational" => [
  [0, 14],
  "Prints out simplified or improper fraction results",
  "Only prints necessary components, never something like &quot;3 0/1&quot;",
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