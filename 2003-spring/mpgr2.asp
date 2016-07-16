<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "GetString" => [
  [0, 4],
  "Inputs an entire line of user input",
  "Ignores LF, clears character on BS unless at beginning of line",
  "Quits when ESC is entered",
 ],
 "ProcessNumbers" => [
  [0, 4],
  "Pushes the input numbers to the stack in correct order",
  "Handles the error correctly",
  "Detects overflow input",
 ],
 "ProcessOperators" => [
  [0, 4],
  "Sets AX properly when the Operators are detected",
  "Executes only word[NumCount]-1 Operations",
  "Handles the error correctly",
 ],
 "Calculate" => [
  [0, 7],
  "Performs correct fractional calculations",
  "Stores in the correct stack location",
  "Detects overflow",
 ],
 "GCD" => [
  [0, 7],
  "Returns correct value of GCD using recursion",
 ],
 "PowerInit" => [
  [0, 3],
  "Initializes properly to call CalPow",
  "Detects errors",  
 ],
 "CalPow" => [
  [0, 7],
  "Calculates the Power using recursion",
 ],
 "DoublePopping" => [
  [0, 3],
  "Returns correct values in tmpList",
  "Updates StackTop correcly",
 ],
 "SinglePushing" => [
  [0, 2],
  "Stores to stack in order",
  "Updates StackTop correcly",
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
  -50 => "After _DEADLINE_: -5pts/weekday",
 ],
);

GradeSheet (\@Functions, \@Code);

%>