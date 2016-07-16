<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "Init" => [
  [0, 5],
  "Correctly sets up WordSpace variable",
 ],
 "ProcessCharacter" => [
  [0, 10],
  "Makes sure character is in the range 'a' to 'z'",
  "Checks if character has been used before, and marks it as used if it hasn't",
  "Determines if a character matches and alters WordSpace variable
  accordingly",
  "Updates NumIncorrect variable appropriately",
 ],
 "DisplayWord" => [
  [0, 5],
  "Outputs WordSpace variable to screen, with spaces between each character",
 ],
 "DisplayUsed" => [
  [0, 5],
  "Displays list of used letters",
 ],
 "CheckWinner" => [
  [0, 5],
  "Determines if the user has won or lost",
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
 "Photo (graded later)" => [
     [0, 1],
     "Took a digital photo (should appear in Photos section of website)",
   ],
 );

my @Code = (
 "Penalty/Bonus" => [
  5 => "Before _DEADLINE_: +1pts/weekday",
  -40 => "After _DEADLINE_: -4pts/weekday",
 ],
);

GradeSheet (\@Functions, \@Code);

%>
