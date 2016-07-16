<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "MP4Main" => [
     [0, 10],
     "Correcly runs main game loop",
   ],
 "Initialize" => [
     [0, 3],
     "Correctly initializes game variables",
   ],
 "GetNextPiece" => [
     [0, 7],
     "Correctly generates a new piece",
   ],
 "MovePiece" => [
     [0, 3],
     "Correctly checks to see if the current piece should be moved, and if so, moves the current piece",
   ],
 "RotatePieceCW" => [
     [0, 7],
     "Correctly checks to see if the current piece should be moved, and if so, rotates the current piece",
   ],

 "CheckPieceCollision" => [
     [0, 3],
     "Correctly checks for a collision between the current piece and the game board",
   ],

 "PutPieceOnBoard" => [
     [0, 5],
     "Correctly writes the current piece to the game board",
   ],

 "MarkBlocks" => [
     [0, 7],
     "Correctly marks the blocks in the game board that are to be cleared",
   ],
 "ClearBlocks" => [
     [0, 5],
     "Correctly clears all marked blocks from the game board",
   ],

 "DropBlocks" => [
     [0, 7],
     "Correctly drops any suspended block down as far as possible in the game board",
   ],

 "ClearAllBlocks" => [
     [0, 7],
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
     [0, 8],
     "Correctly draws a block at a location in the specified destination",
   ],

 "DrawGameBoard" => [
     [0, 5],
     "Correctly draws entire game board at a location in the specified destination",
   ],

 "DrawCurrentPiece" => [
     [0, 5],
     "Correctly draws current piece at a location in the specified destination",
   ],

 "DrawText" => [
     [0, 8],
     "Correctly draws an anti-aliased text string at a location in the specified destination",
   ],

 "AlphaCompose" => [
     [0, 8],
     "Correctly performs an alpha composition of the input pixel",
   ],

 "InstallMouse" => [
     [0, 2],
   "Correctly installs the mouse callback",
   ],

 "RemoveMouse" => [
     [0, 2],
    "Correctly removes the mouse callback",
   ],

 "MouseCallback" => [
     [0, 10],
     "Correctly handles mouse input from the user",
   ],

 "SetMousePos" => [
     [0, 3],
     "Correctly sets the position of the mouse on the screen ",
   ],

 "UpdateMouseVisibility" => [
     [0, 3],
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
     6 => "Before _DEADLINE_: +2pt/weekday",
     -75 => "After _DEADLINE_: -7pts/weekday up to 5 days, -75 after 5 days",
   ],
);

GradeSheet (\@Functions, \@Code);

%>