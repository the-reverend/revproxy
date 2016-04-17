%{

uses LexLib, crt, math, strings, sysutils;

{$i revlib.inc}

const NS=20000;
var sects : array [1..NS] of Integer;
tempstr: ansistring;

%}

DIGIT [0-9]
NUMBER [0-9]+(","[0-9]+)*
TIME ({DIGIT}{DIGIT})":"({DIGIT}{DIGIT})":"({DIGIT}{DIGIT}) 

%%

"Command [TL="{TIME}"]:["{NUMBER}"] (?=Help)? :" 
     begin
       tempstr:=rightstr(yytext,length(yytext)-23);
       inc(sects[strtoint(substr(tempstr,0,posc(']',tempstr)-1))]);
     end;

. |
\n ;

%%

var i : Integer;

begin
  for i := 1 to NS do sects[i]:=0;
  if yylex=0 then ;
  writeln('sector':6, ' ':3, 'No. command prompts':6);
  for i := 1 to NS do if sects[i]>0 then
    writeln(i:6, ' ':3, sects[i]:6);
end.
