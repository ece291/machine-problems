<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "GetStr" => [
  [0, 12],
  "Inputs an entire line of user input",
  "Ignores LF, clears character on BS unless at beginning of line",
 ],
 "Prime" => [
  [0, 12],
  "Determines whether given input number is prime",
 ],
 "Keys" => [
  [0, 15],
  "Determines validity of a key pair",
 ],
 "EncDec" => [
  [0, 12],
  "Encrypts or Decrypts a string as requested",
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