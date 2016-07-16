<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%



my @Functions = (

 "MP4Main" => [

  [0, 6],

  "Main loop, handles mouse and keyboard input, redraws screen",

 ],

 "drawRect" => [

  [0, 6],

  "Draws rectangle at correct location with correct size",

 ],

 "updateParticles" => [

  [0, 7],

  "Updates the position of the particles, making sure they are within bounds",

 ],

 "drawParticles" => [

  [0, 7],

  "Draws particles to screen at correct locations",

 ],

 "clearParticles" => [

  [0, 4],

  "Clears the entire particle array",

 ],
 
 "addParticle" => [

  [0, 6],

  "Add particle to the array",

 ],
 "drawString" => [

  [0, 6],

  "Draws a text string to the screen",

 ],
 
  "pointInRect" => [

  [0, 5],

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

  [0, 12],

  "Alpha blends part of one image over part of another image",

 ],
 
  "installMouse" => [

  [0, 6],

  "Installs a mouse handler",

 ],
 
  "removeMouse" => [

  [0, 6],

  "Removes the mouse handler",

 ],
 
   "mouseCallback" => [

  [0, 6],

  "Routine to handle mouse events",

 ],
 
   "installKeyboardISR" => [

  [0, 6],

  "Installs a keyboard handler",

 ],
 
  "removeKeyboardISR" => [

  [0, 3],

  "Removes the keyboard handler",

 ],
 
   "keyoboardISR" => [

  [0, 6],

  "Routine to handle keyboard events",

 ],
 );



my @Code = (

 "Penalty/Bonus" => [

  6 => "Before _DEADLINE_: +2pts/weekday",

  -60 => "After _DEADLINE_: -10pts/weekday",

 ],
 "Style (graded later)" => [ 
     -5 => "Program should follow all specifications of assignment", 

   ]
);



GradeSheet (\@Functions, \@Code);



%>
