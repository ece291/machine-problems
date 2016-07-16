<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "MP0 Modification" => [
     [0,10], 
     "Handles all grades, including a 'C'",
  ],
 "MP0 Questions" => [
     [0,10],
     "AL = <tt><input type=text style=\"font-family:monospace\" size=4 maxlength=2></tt> (2 pt)",
     "Explanation of program operation when <tt>44h</tt> is entered into memory offset 0 (3 pt)",
     "Segment:Offset of Mystery Variable: <tt><input type=text style=\"font-family:monospace\" size=8 maxlength=4>:<input input type=text style=\"font-family:monospace\" size=8 maxlength=4></tt> (2 pt)",
     "Explanation of how and why program operates differently with <tt>mystery</tt> variable in place (3 pt)",
  ],
 "TA Question", => [
     [0,10],
     "Can answer all of TA's questions about editing, assembling, and/or debugging code",
   ],
);

my @Code = (
 "Penalty/Bonus" => [
     -6 => "After _DEADLINE_: -1pt/weekday",
   ],
);

GradeSheet (\@Functions, \@Code);

%>
