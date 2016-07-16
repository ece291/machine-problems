<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%



my @Functions = (

 "MP4Main" => [

  [0, 8],

  "Main loop, handles mouse and keyboard input, redraws screen",

 ],

 "drawRect" => [

  [0, 6],

  "Draws rectangle at correct location with correct size",

 ],

 "updateParticles" => [

  [0, 6],

  "Updates the position of the particles, making sure they are within bounds",

 ],

 "drawParticles" => [

  [0, 6],

  "Draws particles to screen at correct locations",

 ],

 "clearParticles" => [

  [0, 6],

  "Clears the entire particle array",

 ],

 "drawString" => [

  [0, 4],

  "Draws a text string to the screen",

 ],
 
  "pointInRect" => [

  [0, 4],

  "Determines if a point is within the bounds of a rectangle",

 ],

 "clearScreen" => [

  [0, 4],

  "Clear the screen using a specific color",

 ],
	
 "loadImages" => [

  [0, 4],

  "Load images into memory",

 ],
 
  "alphaBlit" => [

  [0, 4],

  "Alpha blends part of one image over part of another image",

 ],
 
  "installMouse" => [

  [0, 4],

  "Installs a mouse handler",

 ],
 
  "removeMouse" => [

  [0, 4],

  "Removes the mouse handler",

 ],
 
   "mouseCallback" => [

  [0, 4],

  "Routine to handle mouse events",

 ],
 
   "installKeyboardISR" => [

  [0, 4],

  "Installs a keyboard handler",

 ],
 
  "removeKeyboardISR" => [

  [0, 4],

  "Removes the keyboard handler",

 ],
 
   "keyoboardISR" => [

  [0, 4],

  "Routine to handle keyboard events",

 ],

 
 

"Style (graded later)" => [

     [0, 5],

     "Follows specifications for modularity, including using variable names instead of hardcoded addresses (1 point)",

     "Uses good control structures efficiently: (2 points)",

     " - Avoids use of extraneous variables, extraneous registers, or excessive code",

     "Has satisfactory documentation: (2 points)",

     " - Includes function headers (I/O and purpose) and sufficient body comments",

     " - Avoids \"sportscaster\" comments",

   ]
 );



my @Code = (

 "Penalty/Bonus" => [

  6 => "Before _DEADLINE_: +2pts/weekday",

  -60 => "After _DEADLINE_: -10pts/weekday",

 ],

);



GradeSheet (\@Functions, \@Code);



%>