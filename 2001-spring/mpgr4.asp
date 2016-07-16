<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "MP4Main" => [
     [0, 8],
     "Correcly runs main game loop",
   ],
 "Initialize" => [
     [0,2],
     "Correctly initializes game variables",
   ],
 "GetNextPiece" => [
     [0, 5],
     "Correctly generates a new piece",
   ],
 "MovePiece" => [
     [0, 3],
     "Correctly checks to see if the current piece should be moved, and if so, moves the current piece",
   ],
 "RotatePieceCW" => [
     [0, 4],
     "Correctly checks to see if the current piece should be moved, and if so, rotates the current piece",
   ],

 "CheckPieceCollision" => [
     [0, 4],
     "Correctly checks for a collision between the current piece and the game board",
   ],

 "PutPieceOnBoard" => [
     [0, 3],
     "Correctly writes the current piece to the game board",
   ],

 "MarkBlocks" => [
     [0, 6],
     "Correctly marks the blocks in the game board that are to be cleared",
   ],
 "ClearBlocks" => [
     [0, 3],
     "Correctly clears all marked blocks from the game board",
   ],

 "DropBlocks" => [
     [0, 7],
     "Correctly drops any suspended block down as far as possible in the game board",
   ],

 "ClearAllBlocks" => [
     [0, 5],
     "Correctly writes current piece to game board and then continuously clears and drops blocks until no more need to be cleared",
   ],
 "Delay" => [
     [0, 3],
     "Correctly delays program execution for the specified number of timer ticks",
   ],

 "UpdateStats" => [
     [0, 3],
     "Correctly updates the user's game stats",
   ],

 "ClearScreen" => [
     [0, 2],
     "Correctly clears destination image to black",
   ],

 "DrawBlock" => [
     [0, 5],
     "Correctly draws a block at a location in the specified destination",
   ],

 "DrawGameBoard" => [
     [0, 3],
     "Correctly draws entire game board at a location in the specified destination",
   ],

 "DrawCurrentPiece" => [
     [0, 3],
     "Correctly draws current piece at a location in the specified destination",
   ],

 "DrawText" => [
     [0, 6],
     "Correctly draws an anti-aliased text string at a location in the specified destination",
   ],

 "AlphaCompose" => [
     [0, 6],
     "Correctly performs an alpha composition of the input pixel",
   ],

 "InstallKeyboard" => [
     [0, 1],
     "Correctly installs the keyboard ISR",
   ],

 "RemoveKeyboard" => [
     [0, 1],
     "Correctly removes the keyboard ISR",
   ],

 "KeyboardISR" => [
     [0, 3],
     "Correctly handles keyboard input from the user",
   ],

 "InstallTimer" => [
     [0, 1],
     "Correctly installs the timer ISR",
   ],

 "RemoveTimer" => [
     [0, 1],
     "Correctly removes the timer ISR",
   ],

 "TimerISR" => [
     [0, 1],
     "Correctly handles timer ticks from the system timer",
   ],

 "InstallMouse" => [
     [0, 2],
   "Correctly installs the mouse callback",
   ],

 "RemoveMouse" => [
     [0, 1],
    "Correctly removes the mouse callback",
   ],

 "MouseCallback" => [
     [0, 5],
     "Correctly handles mouse input from the user",
   ],

 "SetMousePos" => [
     [0, 2],
     "Correctly sets the position of the mouse on the screen ",
   ],

 "UpdateMouseVisibility" => [
     [0, 2],
     "Correctly updates status of mouse visibility ",
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
     10 => "Before _DEADLINE_: +1pt/weekday",
     -100 => "After _DEADLINE_: -20pts/weekday",
   ],
);

GradeSheet (\@Functions, \@Code);

%>