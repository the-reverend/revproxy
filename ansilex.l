%{
uses revlexlib, crt, math, strings, sysutils;
{$i revlib.inc}
var
  count: integer;
%}
ESC \033
CR \015
LF \012
DIG [0-9]
ANSICM [mJ]
ANSICD ({ESC}\[{DIG}{1,2}(;{DIG}{1,2})*{ANSICM})

%%
{ANSICD} 
     begin
       inc(count);
     end;
{LF}{ANSICD}{LF} writeln;
{LF} writeln;
. write(yyvars.yytext);

%%

//{ANSICD}"Command ["{ANSICD}"TL"{ANSICD}"="{ANSICD}{TIME}{ANSICD}\]{ANSICD}:{ANSICD}\[{ANSICD}{UINT}{ANSICD}"] ("{ANSICD}"?=Help"{ANSICD}")? :" 

var i : Integer;

var
  yyvars : tyyvars;
begin
  assign(yyvars.yyinput, '');
  assign(yyvars.yyoutput, '');
  reset(yyvars.yyinput); rewrite(yyvars.yyoutput);
  yyvars.yylineno := 0;
  yyclear(yyvars);
  if yylex(yyvars)=0 then ;

  writeln(count);
end.
