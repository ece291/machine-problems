<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "GetInput" => [
  [0, 6],
  "Takes user input",
  "Handles characters correctly",
 ],
 "ParseInput" => [
  [0,5],
  "Correctly parses input buffer",
 ],
 "DisplayBuffer" => [
  [0, 5],
  "Displays buffer in correct mode",
 ],
 "Random" => [
  [0, 4],
  "Generates a random number in the correct range",
 ],
 "GetBits" => [
  [0, 5],
  "Figures out the bits a number uses",
 ],
 "Solve" => [
  [0, 6],
  "Solves the given equation",
 ],
 "PowMod" => [
  [0, 6],
  "Computes the desired result",
 ],
 "CheckPrime" => [
  [0, 5],
  "Correctly figures out if a number is prime",
 ],
 "GenerateKeyPair" => [
  [0, 4],
  "Generates a valid pair of keys",
 ],
 "Crypt" => [
  [0, 4],
  "Correctly performs transformation on data",
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
  -3 => "Sparse and/or unclear comments",
 ],
 "Penalty/Bonus" => [
  5 => "Before _DEADLINE_: +1pt/weekday",
  -50 => "After _DEADLINE_: -10pts/weekday",
 ],
);

GradeSheet (\@Functions, \@Code);

%>