
(* lexical analyzer template (TP Lex V3.0), V1.0 3-2-91 AG *)

(* global definitions: *)

uses LexLib, crt, math, strings, sysutils;

{$i revlib.inc}

const NS=20000;
var sects : array [1..NS] of Integer;
tempstr: ansistring;




function yylex : Integer;

procedure yyaction ( yyruleno : Integer );
  (* local definitions: *)

begin
  (* actions: *)
  case yyruleno of
  1:
                                                 
     begin
       tempstr:=rightstr(yytext,length(yytext)-23);
       inc(sects[strtoint(substr(tempstr,0,posc(']',tempstr)-1))]);
     end;

  2,
  3:
   ;

  end;
end(*yyaction*);

(* DFA table: *)

type YYTRec = record
                cc : set of Char;
                s  : Integer;
              end;

const

yynmarks   = 4;
yynmatches = 4;
yyntrans   = 48;
yynstates  = 43;

yyk : array [1..yynmarks] of Integer = (
  { 0: }
  { 1: }
  { 2: }
  2,
  { 3: }
  2,
  { 4: }
  3,
  { 5: }
  { 6: }
  { 7: }
  { 8: }
  { 9: }
  { 10: }
  { 11: }
  { 12: }
  { 13: }
  { 14: }
  { 15: }
  { 16: }
  { 17: }
  { 18: }
  { 19: }
  { 20: }
  { 21: }
  { 22: }
  { 23: }
  { 24: }
  { 25: }
  { 26: }
  { 27: }
  { 28: }
  { 29: }
  { 30: }
  { 31: }
  { 32: }
  { 33: }
  { 34: }
  { 35: }
  { 36: }
  { 37: }
  { 38: }
  { 39: }
  { 40: }
  { 41: }
  { 42: }
  1
);

yym : array [1..yynmatches] of Integer = (
{ 0: }
{ 1: }
{ 2: }
  2,
{ 3: }
  2,
{ 4: }
  3,
{ 5: }
{ 6: }
{ 7: }
{ 8: }
{ 9: }
{ 10: }
{ 11: }
{ 12: }
{ 13: }
{ 14: }
{ 15: }
{ 16: }
{ 17: }
{ 18: }
{ 19: }
{ 20: }
{ 21: }
{ 22: }
{ 23: }
{ 24: }
{ 25: }
{ 26: }
{ 27: }
{ 28: }
{ 29: }
{ 30: }
{ 31: }
{ 32: }
{ 33: }
{ 34: }
{ 35: }
{ 36: }
{ 37: }
{ 38: }
{ 39: }
{ 40: }
{ 41: }
{ 42: }
  1
);

yyt : array [1..yyntrans] of YYTrec = (
{ 0: }
  ( cc: [ #1..#9,#11..'B','D'..#255 ]; s: 3),
  ( cc: [ #10 ]; s: 4),
  ( cc: [ 'C' ]; s: 2),
{ 1: }
  ( cc: [ #1..#9,#11..'B','D'..#255 ]; s: 3),
  ( cc: [ #10 ]; s: 4),
  ( cc: [ 'C' ]; s: 2),
{ 2: }
  ( cc: [ 'o' ]; s: 5),
{ 3: }
{ 4: }
{ 5: }
  ( cc: [ 'm' ]; s: 6),
{ 6: }
  ( cc: [ 'm' ]; s: 7),
{ 7: }
  ( cc: [ 'a' ]; s: 8),
{ 8: }
  ( cc: [ 'n' ]; s: 9),
{ 9: }
  ( cc: [ 'd' ]; s: 10),
{ 10: }
  ( cc: [ ' ' ]; s: 11),
{ 11: }
  ( cc: [ '[' ]; s: 12),
{ 12: }
  ( cc: [ 'T' ]; s: 13),
{ 13: }
  ( cc: [ 'L' ]; s: 14),
{ 14: }
  ( cc: [ '=' ]; s: 15),
{ 15: }
  ( cc: [ '0'..'9' ]; s: 16),
{ 16: }
  ( cc: [ '0'..'9' ]; s: 17),
{ 17: }
  ( cc: [ ':' ]; s: 18),
{ 18: }
  ( cc: [ '0'..'9' ]; s: 19),
{ 19: }
  ( cc: [ '0'..'9' ]; s: 20),
{ 20: }
  ( cc: [ ':' ]; s: 21),
{ 21: }
  ( cc: [ '0'..'9' ]; s: 22),
{ 22: }
  ( cc: [ '0'..'9' ]; s: 23),
{ 23: }
  ( cc: [ ']' ]; s: 24),
{ 24: }
  ( cc: [ ':' ]; s: 25),
{ 25: }
  ( cc: [ '[' ]; s: 26),
{ 26: }
  ( cc: [ '0'..'9' ]; s: 27),
{ 27: }
  ( cc: [ ',' ]; s: 28),
  ( cc: [ '0'..'9' ]; s: 27),
  ( cc: [ ']' ]; s: 29),
{ 28: }
  ( cc: [ '0'..'9' ]; s: 30),
{ 29: }
  ( cc: [ ' ' ]; s: 31),
{ 30: }
  ( cc: [ ',' ]; s: 28),
  ( cc: [ '0'..'9' ]; s: 30),
  ( cc: [ ']' ]; s: 29),
{ 31: }
  ( cc: [ '(' ]; s: 32),
{ 32: }
  ( cc: [ '?' ]; s: 33),
{ 33: }
  ( cc: [ '=' ]; s: 34),
{ 34: }
  ( cc: [ 'H' ]; s: 35),
{ 35: }
  ( cc: [ 'e' ]; s: 36),
{ 36: }
  ( cc: [ 'l' ]; s: 37),
{ 37: }
  ( cc: [ 'p' ]; s: 38),
{ 38: }
  ( cc: [ ')' ]; s: 39),
{ 39: }
  ( cc: [ '?' ]; s: 40),
{ 40: }
  ( cc: [ ' ' ]; s: 41),
{ 41: }
  ( cc: [ ':' ]; s: 42)
{ 42: }
);

yykl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 1,
{ 3: } 2,
{ 4: } 3,
{ 5: } 4,
{ 6: } 4,
{ 7: } 4,
{ 8: } 4,
{ 9: } 4,
{ 10: } 4,
{ 11: } 4,
{ 12: } 4,
{ 13: } 4,
{ 14: } 4,
{ 15: } 4,
{ 16: } 4,
{ 17: } 4,
{ 18: } 4,
{ 19: } 4,
{ 20: } 4,
{ 21: } 4,
{ 22: } 4,
{ 23: } 4,
{ 24: } 4,
{ 25: } 4,
{ 26: } 4,
{ 27: } 4,
{ 28: } 4,
{ 29: } 4,
{ 30: } 4,
{ 31: } 4,
{ 32: } 4,
{ 33: } 4,
{ 34: } 4,
{ 35: } 4,
{ 36: } 4,
{ 37: } 4,
{ 38: } 4,
{ 39: } 4,
{ 40: } 4,
{ 41: } 4,
{ 42: } 4
);

yykh : array [0..yynstates-1] of Integer = (
{ 0: } 0,
{ 1: } 0,
{ 2: } 1,
{ 3: } 2,
{ 4: } 3,
{ 5: } 3,
{ 6: } 3,
{ 7: } 3,
{ 8: } 3,
{ 9: } 3,
{ 10: } 3,
{ 11: } 3,
{ 12: } 3,
{ 13: } 3,
{ 14: } 3,
{ 15: } 3,
{ 16: } 3,
{ 17: } 3,
{ 18: } 3,
{ 19: } 3,
{ 20: } 3,
{ 21: } 3,
{ 22: } 3,
{ 23: } 3,
{ 24: } 3,
{ 25: } 3,
{ 26: } 3,
{ 27: } 3,
{ 28: } 3,
{ 29: } 3,
{ 30: } 3,
{ 31: } 3,
{ 32: } 3,
{ 33: } 3,
{ 34: } 3,
{ 35: } 3,
{ 36: } 3,
{ 37: } 3,
{ 38: } 3,
{ 39: } 3,
{ 40: } 3,
{ 41: } 3,
{ 42: } 4
);

yyml : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 1,
{ 3: } 2,
{ 4: } 3,
{ 5: } 4,
{ 6: } 4,
{ 7: } 4,
{ 8: } 4,
{ 9: } 4,
{ 10: } 4,
{ 11: } 4,
{ 12: } 4,
{ 13: } 4,
{ 14: } 4,
{ 15: } 4,
{ 16: } 4,
{ 17: } 4,
{ 18: } 4,
{ 19: } 4,
{ 20: } 4,
{ 21: } 4,
{ 22: } 4,
{ 23: } 4,
{ 24: } 4,
{ 25: } 4,
{ 26: } 4,
{ 27: } 4,
{ 28: } 4,
{ 29: } 4,
{ 30: } 4,
{ 31: } 4,
{ 32: } 4,
{ 33: } 4,
{ 34: } 4,
{ 35: } 4,
{ 36: } 4,
{ 37: } 4,
{ 38: } 4,
{ 39: } 4,
{ 40: } 4,
{ 41: } 4,
{ 42: } 4
);

yymh : array [0..yynstates-1] of Integer = (
{ 0: } 0,
{ 1: } 0,
{ 2: } 1,
{ 3: } 2,
{ 4: } 3,
{ 5: } 3,
{ 6: } 3,
{ 7: } 3,
{ 8: } 3,
{ 9: } 3,
{ 10: } 3,
{ 11: } 3,
{ 12: } 3,
{ 13: } 3,
{ 14: } 3,
{ 15: } 3,
{ 16: } 3,
{ 17: } 3,
{ 18: } 3,
{ 19: } 3,
{ 20: } 3,
{ 21: } 3,
{ 22: } 3,
{ 23: } 3,
{ 24: } 3,
{ 25: } 3,
{ 26: } 3,
{ 27: } 3,
{ 28: } 3,
{ 29: } 3,
{ 30: } 3,
{ 31: } 3,
{ 32: } 3,
{ 33: } 3,
{ 34: } 3,
{ 35: } 3,
{ 36: } 3,
{ 37: } 3,
{ 38: } 3,
{ 39: } 3,
{ 40: } 3,
{ 41: } 3,
{ 42: } 4
);

yytl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 4,
{ 2: } 7,
{ 3: } 8,
{ 4: } 8,
{ 5: } 8,
{ 6: } 9,
{ 7: } 10,
{ 8: } 11,
{ 9: } 12,
{ 10: } 13,
{ 11: } 14,
{ 12: } 15,
{ 13: } 16,
{ 14: } 17,
{ 15: } 18,
{ 16: } 19,
{ 17: } 20,
{ 18: } 21,
{ 19: } 22,
{ 20: } 23,
{ 21: } 24,
{ 22: } 25,
{ 23: } 26,
{ 24: } 27,
{ 25: } 28,
{ 26: } 29,
{ 27: } 30,
{ 28: } 33,
{ 29: } 34,
{ 30: } 35,
{ 31: } 38,
{ 32: } 39,
{ 33: } 40,
{ 34: } 41,
{ 35: } 42,
{ 36: } 43,
{ 37: } 44,
{ 38: } 45,
{ 39: } 46,
{ 40: } 47,
{ 41: } 48,
{ 42: } 49
);

yyth : array [0..yynstates-1] of Integer = (
{ 0: } 3,
{ 1: } 6,
{ 2: } 7,
{ 3: } 7,
{ 4: } 7,
{ 5: } 8,
{ 6: } 9,
{ 7: } 10,
{ 8: } 11,
{ 9: } 12,
{ 10: } 13,
{ 11: } 14,
{ 12: } 15,
{ 13: } 16,
{ 14: } 17,
{ 15: } 18,
{ 16: } 19,
{ 17: } 20,
{ 18: } 21,
{ 19: } 22,
{ 20: } 23,
{ 21: } 24,
{ 22: } 25,
{ 23: } 26,
{ 24: } 27,
{ 25: } 28,
{ 26: } 29,
{ 27: } 32,
{ 28: } 33,
{ 29: } 34,
{ 30: } 37,
{ 31: } 38,
{ 32: } 39,
{ 33: } 40,
{ 34: } 41,
{ 35: } 42,
{ 36: } 43,
{ 37: } 44,
{ 38: } 45,
{ 39: } 46,
{ 40: } 47,
{ 41: } 48,
{ 42: } 48
);


var yyn : Integer;

label start, scan, action;

begin

start:

  (* initialize: *)

  yynew;

scan:

  (* mark positions and matches: *)

  for yyn := yykl[yystate] to     yykh[yystate] do yymark(yyk[yyn]);
  for yyn := yymh[yystate] downto yyml[yystate] do yymatch(yym[yyn]);

  if yytl[yystate]>yyth[yystate] then goto action; (* dead state *)

  (* get next character: *)

  yyscan;

  (* determine action: *)

  yyn := yytl[yystate];
  while (yyn<=yyth[yystate]) and not (yyactchar in yyt[yyn].cc) do inc(yyn);
  if yyn>yyth[yystate] then goto action;
    (* no transition on yyactchar in this state *)

  (* switch to new state: *)

  yystate := yyt[yyn].s;

  goto scan;

action:

  (* execute action: *)

  if yyfind(yyrule) then
    begin
      yyaction(yyrule);
      if yyreject then goto action;
    end
  else if not yydefault and yywrap then
    begin
      yyclear;
      return(0);
    end;

  if not yydone then goto start;

  yylex := yyretval;

end(*yylex*);



var i : Integer;

begin
  for i := 1 to NS do sects[i]:=0;
  if yylex=0 then ;
  writeln('sector':6, ' ':3, 'No. command prompts':6);
  for i := 1 to NS do if sects[i]>0 then
    writeln(i:6, ' ':3, sects[i]:6);
end.
