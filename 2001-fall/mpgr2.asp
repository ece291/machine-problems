<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "DoCommand" => [
  [0, 6],
  "Program loops until <tt>'q'</tt> is entered",
  "For every non-blank line either a result or an error message is shown",
 ],
 "ReadLine" => [
  [0, 9],
  "User input is taken properly: backspace deletes characters",
  "Buffer experiences neither overflow nor underflow, and beeps on attempts to do so",
 ],
 "GetLetter" => [
  [0, 4],
  "Returns a letter if available, else error status",
 ],
 "GetNumber" => [
  [0, 4],
  "Returns a FDNumber if available, else error status",
 ],
 "CalculateInterest" => [
  [0, 5],
  "Correctly applies formula <em>P * (1+i)<sup>n</sup></em>",
  "<tt>i 100 0.03 12</tt> evaluates to <tt>142.00</tt> (due to rounding)",
 ],
 "ConvertCurrency" => [
  [0, 6],
  "Correctly applies formula <em>P * f * t</em>",
  "<tt>c</tt> evaluates to <tt>...</tt>"
 ],
 "FDRead" => [
  [0, 9],
  "Reads in a FDNumber, saving to <tt>[di]</tt>, else returns error status",
  "100.3 is processed correctly (test with <tt>c d d 100.3</tt>)",
 ],
 "FDWrite" => [
  [0, 9],
  "Writes out a FDNumber to the buffer at offset <tt>bx</tt>",
  "10.03 is output correctly (test with <tt>c d d 10.03</tt>)",
 ],
 "FDAdd" => [
  [0, 4],
  "Adds two FDNumbers together",
  "10.90 + 10.90 = 21.80, not 20.180 (cannot be tested in current framework)",
 ],
 "FDMul" => [
  [0, 9],
  "Multiplies two FDNumbers together",
  "<tt>c d d <em>n</em></tt> returns <em>n</em>",
 ],
 "FDPow" => [
  [0, 10],
  "Properly exponentiates FDNumbers, ignoring non-integer exponent parts",
  "<tt>i 100 0.03 12</tt> evaluates to <tt>142.00</tt> (due to rounding)",
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
  6 => "Before _DEADLINE_: +2pts/weekday",
  -75 => "After _DEADLINE_: -7pts/weekday up to 5 days, -75 after 5 days",
 ],
);

GradeSheet (\@Functions, \@Code);

%>