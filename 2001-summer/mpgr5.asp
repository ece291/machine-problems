<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "Initialize" => [
     [0, 10],
     "Correcly initialized card and score arrays",
   ],
 "DisplayCard" => [
     [0,10],
     "Correctly displays the selected card",
   ],
 "DealCards" => [
     [0, 15],
     "Selects two cards randomly out of the deck",
     "No cards are repeated",
   ],
 "PlayOneRound" => [
     [0, 15],
     "Correctly compares the two selected cards",
     "Displays correct winner of round",
     "Plays through entire deck",
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