<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "TransmitInput" => [
  [0, 10],
  "Correctly transmits input on COM2 and displays it to the screen",
 ],
 "ReceiveInput" => [
  [0, 10],
  "Correctly receives input on COM1 and displays it to the screen",
 ],
 "ParseInput" => [
  [0, 10],
  "Correctly parses input buffer",
 ],
 "PrintArray" => [
  [0, 10],
  "Correctly displays input array to the screen",
 ],
 "Partition" => [
  [0, 15],
  "Correctly partitions the input array",
 ],
 "QuickSort" => [
  [0, 10],
  "Correctly sorts the input array using the QuickSort algorithm",
 ],
 "BubbleSort" => [
  [0, 10],
  "Correctly sorts the input array using the BubbleSort algorithm",
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
  -2 => "No Function Headers",
  -2 => "Excessive \"sportscaster\" commenting",
  -3 => "Sparse and/or unclear comments",
 ],
 "Penalty/Bonus" => [
  5 => "Before _DEADLINE_: +1pt/weekday",
  -75 => "After _DEADLINE_: -7pts/weekday up to 5 days, -75 after 5 days",
 ],
);

GradeSheet (\@Functions, \@Code);

%>