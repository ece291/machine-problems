<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "InitVideo" => [
  [0, 10],
  "Initializes the video display correctly",
 ],
 "InstallISR" => [
  [0, 10],
  "Initializes the Timer and Keyboard interrupt vectors correctly",
 ],
 "RestoreISR" => [
  [0, 5],
  "Restores the old Timer and Keyboard interrupt vectors correctly",
 ],
 "Blit" => [
  [0, 10],
  "Copies image of 5x5 character onto screen correctly",
 ],
 "GetStr" => [
  [0, 10],
  "Gets user input and writes it to a buffer correctly",
 ],
 "KbdISR" => [
  [0, 10],
  "Handles key presses and releases correctly",
  "Enqueues ascii code onto keyboard queue when appropriate",
 ],
 "DrawMsg" => [
  [0, 10],
  "Echoes the String in DX and draws onto the first line of the screen",
  
 ],
 "RestoreVideo" => [
  [0, 5],
  "Restores Video Display correctly",
 ],
 "DisplayTime" => [
  [0, 10],
  "Convert and display the time on the video memory correctly",
 ],
 "Main" => [
  [0, 10],
  "Everything else",
  "loops correctly and decrement time correctly",
 ]
 );

my @Code = (
 "Penalty/Bonus" => [
  6 => "Before _DEADLINE_: +2pts/weekday",
  -55 => "After _DEADLINE_: -6pts/weekday",
 ],
 "Score Modifier" => [
     -5 => "Program should follow all specifications of assignment",
 ],
);

GradeSheet (\@Functions, \@Code);

%>
