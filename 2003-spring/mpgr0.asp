
<%@LANGUAGE=PerlScript %><!--#include file="ECE291.asp" --><%

my @Functions = (
 "MP0 Modification" => [
     [0,4], # was 10
     "Handles all grades, including a 'C'",
  ],
 "MP0 Questions" => [
     [0,4], # was 10
     "AL = <tt><input type=text style=\"font-family:monospace\" size=4 maxlength=2></tt> (1 pt)",
     "Explanation of program operation when <tt>44h</tt> is entered into memory offset 0 (1 pt)",
     "Segment:Offset of Mystery Variable: <tt><input type=text style=\"font-family:monospace\" size=8 maxlength=4>:<input input type=text style=\"font-family:monospace\" size=8 maxlength=4></tt> (1 pt)",
     "Explanation of how and why program operates differently with <tt>mystery</tt> variable in place (1 pt)",
  ],
 "TA Question", => [
     [0,2], # was 5
     "Can answer all of TA's questions about editing, assembling, and/or debugging code",
   ],
);

my @Code = (
 "Penalty/Bonus" => [
     -10 => "After _DEADLINE_: -1pt/weekday",
   ],
);

GradeSheet (\@Functions, \@Code);

%>