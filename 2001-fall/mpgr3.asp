<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "MP3Main" => [
     [0, 10],
     "Sets up the initial position of the cursor",
     "Sets up the main game loop",
     "Handles color changes",
   ],
 "DrawBorder" => [
     [0, 6],
     "The text boxes should be correctly drawn at the beginning.",
   ],
 "InstallPort" => [
     [0, 10],
     "",     
   ],
 "RemovePort" => [
     [0, 3],
     "",
   ],
 "PortISR" => [
     [0, 5],
     "Receives input from the serial port.",
   ],
 "InstallKeyboard, RemoveKeyboard" => [
     [0, 3],
     "Correctly installs/removes the keyboard ISR",
     "Keyboard works after exit",
   ],
 "KeyboardISR" => [
     [0, 10],
     "Handles key presses properly",
     "Handles shift presses and releases correctly",
   ],
 
 "GetNextKey" => [
     [0, 10],
     "Correctly chooses in which text window to display.",
     "Get inputs from both the keyboard and the serial port.",
   ],
 "TransmitKey" => [
     [0, 2],
     "Characters are transmitted over the serial port",
   ],
 "DrawNewLine" => [
     [0, 4],
     "Clears the next line when enter is pressed",
     "Clears the next line when text wraps over from the current line",
   ],
 "DrawBackspace" => [
     [0, 4],
     "Correctly backspaces and sets the cursor in the right position",
   ],
"TypeKey" => [
     [0, 8],
     "Displays typed characters and cursor in the appropriate text box",
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
     6 => "Before _DEADLINE_: +2pt/weekday",
     -75 => "After _DEADLINE_: -7pts/weekday",
   ],
);

GradeSheet (\@Functions, \@Code);

%>