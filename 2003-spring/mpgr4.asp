<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "MP4Main" => [
  [0, 5],
  "Exits on keypress, and zooms appropriately",
  "If mouse is clicked twice quickly ignore the second click",
 ],
 "MapBuffer" => [
  [0, 4],
  "Fractal is colorful",
 ],
 "CalcPixel" => [
  [0, 12],
  "Fractal looks like the Mandelbrot fractal",
 ],
 "ComplexSquare" => [
  [0, 6],
  "",
 ],
 "IsDiverging" => [
  [0, 6],
  "",
 ],
 "Style (graded later)" => [
     [0, 4],
     "Uses constants, local variables on the stack, and struct correctly",
     "Doesn't flood the fpu stack",
     "Uses good control structures efficiently",
     "Includes function headers (I/O and purpose) and sufficient body comments",
     "Avoids \"sportscaster\" comments",
   ],
 "Cover Memo (graded later)" => [
     [0, 3],
     "Turned in satisfactory Cover Memo",
   ],
 );

my @Code = (
 "Penalty/Bonus" => [
  5 => "Before _DEADLINE_: +1pts/weekday",
  -40 => "After _DEADLINE_: -4pts/weekday",
 ],
);

GradeSheet (\@Functions, \@Code);

%>
