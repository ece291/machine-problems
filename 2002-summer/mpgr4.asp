<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "FreePoints" => [
     [0, 25],
     "Did you turn in this MP?"
   ],
 "DrawMap" => [
     [0, 25],
     "Draws all visible, seen, and invisible tiles at full, half, and zero intensity respectively",
     "Draws all items using alpha-composition, such that the top item is the first picked up",
     "Draws the player with alpha-composition on top of everything",
     "No invalid tiles, or tiles from the other side of the map are drawn",
   ],
 "DrawString" => [
     [0, 20],
     "Letters are properly spaced for the variable width font",
     "String pieces appear in the proper subsequent locations",
   ],
 "InstallKeyboard, RemoveKeyboard, KeyboardISR" => [
     [0, 5],
     "The keyboard works properly with EX291 in protected mode",
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
     -2 => "C-style functions push and pop registers other than esi/edi",
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
     6 => "Before _DEADLINE_: +2pts/weekday",
     -75 => "After _DEADLINE_: -15pts/weekday up to 5 days, -75 after 5 days",
   ],
);

GradeSheet (\@Functions, \@Code);

%>