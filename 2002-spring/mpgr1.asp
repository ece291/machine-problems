<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "FodderStat" => [
     [0, 8],
     "Correctly acknowledges that you have a hit",
     "Changes your round score and the actual playerscore",
   ],
 "FodderSet" => [
     [0, 11],
     "Displays the correct messages on to the screen",
     "Comes up with random numbers",
   ],
 "FodderShoot" => [
     [0, 8],
     "Correctly implements algorithm",
   ],
 "ReadLine" => [
     [0, 11],
     "Correctly echoes out numbers",
     "Takes in the correctly inputs and stores it without error into velocity",
   ],
 "NewPlay" => [
     [0, 11],
     "Creates new players and sets activeplayer",
   ],
 "DispChar" => [
     [0, 8],
     "Displays correct player create message",
   ],
 "PlayerStats" => [
     [0, 11],
     "Updates the correct players score",
   ],
 "DisplayPlayerStats" => [
     [0, 7],
     "Displays all your playerstats",
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
     -2 => "No Function Headers",
     -3 => "Sparse and/or unclear comments",
   ],
 "Penalty/Bonus" => [
     5 => "Before _DEADLINE_: +1pt/weekday",
     -75 => "After _DEADLINE_: -7pts/weekday",
   ],
);

GradeSheet (\@Functions, \@Code);

%>