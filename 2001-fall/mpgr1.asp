<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "InterpretAmount" => [
     [0, 11],
     "Verifies validity of the input",
     "Proper amounts are shown for each entry (<tt>dx</tt> was set correctly)",
   ],
 "InterpretTag" => [
     [0, 11],
     "Verified validity of the input",
     "Proper tags are shown for each entry (<tt>cl</tt> was set correctly)",
   ],
 "AddDeposit" => [
     [0, 8],
     "Displays appropriate menus",
     "Adds entry when completed correctly or aborts cleanly",
   ],
 "AddWithdraw" => [
     [0, 8],
     "Displays appropriate menus",
     "Adds entry when completed correctly or aborts cleanly",
   ],
 "DisplayEntry" => [
     [0, 11],
     "Displays proper withdrawal/deposit messages, amount, and tag",
   ],
 "DisplayAllEntries" => [
     [0, 7],
     "Displays all, and only all, entries",
   ],
 "DisplayAcademicEntries" => [
     [0, 8],
     "Displays all entries only with academic related tags set",
     "Displays msg_NoEntries if no matching entries",
   ],
 "DisplayTotal" => [
     [0, 11],
     "Displays correct total and appropriate message",
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
     6 => "Before _DEADLINE_: +2pt/weekday",
     -50 => "After _DEADLINE_: -10pts/weekday",
   ],
);

GradeSheet (\@Functions, \@Code);

%>