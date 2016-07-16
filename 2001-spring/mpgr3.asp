<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "MP3Main" => [
     [0, 3],
     "Program runs correctly",
   ],
 "DrawKeyboard" => [
     [0,3],
     "Draws the attributes and lines of the keyboard",
   ],
 "DrawKeyNames" => [
     [0, 6],
     "Draws the keynames in upper or lower case appropriately",     
   ],
 "NextString" => [
     [0, 4],
     "Switches strings and zeros time and errors counters",
     "Clears all unwanted characters from screen.",
   ],
 "InstallTimer, RemoveTimer" => [
     [0, 2],
     "Correctly installs/removes the timer ISR",
     "Program does not crash on exit",
   ],
 "TimerISR" => [
     [0, 2],
     "Appropriately manages the timer variables",
   ],
 "InstallKeyboard, RemoveKeyboard" => [
     [0, 2],
     "Correctly installs/removes the keyboard ISR",
     "Keyboard works after exit",
   ],
 "KeyboardISR" => [
     [0, 8],
     "Typing and highlighting work",
     "Converts the scancode to the proper ASCII",
     "Shift state is correctly maintained (hold left, and tap right, for example)",
   ],
 "HighlightKey" => [
     [0, 4],
     "Keys on the keyboard are highlighted correctly",
   ],
 "GetKeyPress" => [
     [0, 3],
     "Waits for next key or returns immediately on escape",
   ],
 "TypeKey" => [
     [0, 6],
     "Displays typed characters with correct attributes",
     "Handles backspaces without wrapping",
     "Moves the cursor to the correct location",
   ],
 "CheckKey" => [
     [0, 3],
     "Typing errors are shown as errors",
     
   ],
 "DisplayStats" => [
     [0, 4],
     "Correctly displays the error and time messages",
     "Right justifies the statistics",
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
     -2 => "Lack of function headers (inputs, outputs, purpose)",
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