<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "CheckBlackJack" => [
     [0, 5],
     "Correctly checks for blackjack and deals new hand if needed",
   ],
 "DealCards" => [
     [0,5],
     "Deals two cards to player and two to dealer",
   ],
 "DealPlayer" => [
     [0, 5],
     "Deals card to player",
   ],
 "DealDealer" => [
     [0, 5],
     "Deals card to dealer",
   ],
 "Status" => [
     [0, 15],
     "Outputs status of game to screen",
     "Calculates player and dealer totals",
   ],
 "DisplayCards" => [
     [0, 15],
     "Displays cards and player or dealer message",
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