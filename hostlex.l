%{
//uses revlexlib, crt, math, strings, sysutils;
//{$i revlib.inc}
//const NS=20000;
//var sects : array [1..NS] of Integer;
var tempstr: string;
%}
ESC \033
CR \015
LF \012
SP \040
DIG [0-9]
UPPLET [A-Z]
LOWLET [a-z]
ANYLET [0-9A-Za-z]
ANSICM [mJ]
ANSICD ({ESC}\[{DIG}{1,2}(;{DIG}{1,2})*{ANSICM})
UINT {DIG}+
INT -?{UINT}
WORD (ANYLET)+
STR {WORD}({SP}{WORD})*
TIME {DIG}{2}:{DIG}{2}:{DIG}{2}

%s COMMAND1
%s COMMAND2
%s COMMAND3
%s COMMAND4
%s COMMAND5
%s CIMMODE
%s SECTOR
%s SECTORPLANETS
%s SECTORTRADERS
%s SECTORSHIPS
%s SECTORMINES
%%

^{ANSICD}?"Comma" start(COMMAND1,yyvars);
<COMMAND1>:{ANSICD}?\[{ANSICD}? 
                  start(COMMAND2,yyvars);
<COMMAND2>{UINT}  // get sector from command prompt
                  begin
                    display_window(display,WINDOW_USERMSGS);
                    writeln('sector=',yyvars.yytext);
                    start(COMMAND3,yyvars);
                  end;

^": "{CR}{LF}     // start cim mode
                  begin
                    display_window(display,WINDOW_USERMSGS);
                    writeln('cim mode');
                    start(CIMMODE,yyvars);
                    inc(yyvars.yylineno);
                    yyvars.yycolno:=0;
                  end;
<CIMMODE>{UINT}(" >"({CR}{LF})?{SP}\(?{UINT}\)?)+ 
                  // get from-to data from cim mode
                  begin
                    yyvars.yylineno+=max(countchar(yyvars.yytext,#10),countchar(yyvars.yytext,#13));
                    display_window(display,WINDOW_USERMSGS);
                    writeln('path: ',stripset(yyvars.yytext,[#32,#13,#10]));
                  end;
<CIMMODE>^{SP}*{UINT}{SP}+{UINT}({SP}+{UINT})* 
                  // get sector warp data from cim mode
                  begin
                    display_window(display,WINDOW_USERMSGS);
                    writeln('warps: ',yyvars.yytext);
                  end;
<CIMMODE>^{SP}*{UINT}({SP}"-"?{SP}+{UINT}{SP}+{UINT}%){3} 
                  // get port data from cim mode
                  begin
                    display_window(display,WINDOW_USERMSGS);
                    writeln('port: ',yyvars.yytext);
                  end;

^{ANSICD}?"Sector  "{ANSICD}?":".+\. 
                  // enter sector display
                  begin
                    // sector, beacon, port, planets, observer, aliens, traders, ships, figs, navhaz, mines, warps
                    start(SECTOR,yyvars);
                    display_window(display,WINDOW_USERMSGS);
                    writeln(' ',stripansi(yyvars.yytext));
                  end;
<SECTOR>^{ANSICD}?"Beacon".+ 
                  // beacon
                  begin
                    display_window(display,WINDOW_USERMSGS);
                    writeln(' ',stripansi(yyvars.yytext));
                  end;
<SECTOR>^{ANSICD}?"Port".+ 
                  // port
                  begin
                    display_window(display,WINDOW_USERMSGS);
                    writeln(' ',stripansi(yyvars.yytext));
                  end;
<SECTOR>^{ANSICD}?{SP}{11}"(Un".+{UINT} 
                  // port under construction
                  begin
                    display_window(display,WINDOW_USERMSGS);
                    writeln(' ',stripansi(yyvars.yytext));
                  end;
<SECTOR>^{ANSICD}?"Planets".+ 
                  // planets
                  begin
                    start(SECTORPLANETS,yyvars);
                    display_window(display,WINDOW_USERMSGS);
                    writeln(' ',stripansi(yyvars.yytext));
                  end;
<SECTOR,SECTORPLANETS>^{ANSICD}?"Traders".+ 
                  // traders
                  begin
                    start(SECTORTRADERS,yyvars);
                    display_window(display,WINDOW_USERMSGS);
                    writeln(' ',stripansi(yyvars.yytext));
                  end;
<SECTOR,SECTORPLANETS,SECTORTRADERS>^{ANSICD}?"Ships".+ 
                  // ships
                  begin
                    start(SECTORSHIPS,yyvars);
                    display_window(display,WINDOW_USERMSGS);
                    writeln(' ',stripansi(yyvars.yytext));
                  end;
<SECTOR,SECTORPLANETS,SECTORTRADERS,SECTORSHIPS>^{ANSICD}?"Fighters".+ 
                  // figs
                  begin
                    display_window(display,WINDOW_USERMSGS);
                    writeln(' ',stripansi(yyvars.yytext));
                  end;
<SECTOR,SECTORPLANETS,SECTORTRADERS,SECTORSHIPS>^{ANSICD}?"NavHaz".+ 
                  // navhaz
                  begin
                    display_window(display,WINDOW_USERMSGS);
                    writeln(' ',stripansi(yyvars.yytext));
                  end;
<SECTOR,SECTORPLANETS,SECTORTRADERS,SECTORSHIPS>^{ANSICD}?"Mines".+ 
                  // mines
                  begin
                    start(SECTORMINES,yyvars);
                    display_window(display,WINDOW_USERMSGS);
                    writeln(' ',stripansi(yyvars.yytext));
                  end;
<SECTORPLANETS,SECTORTRADERS,SECTORSHIPS,SECTORMINES>^{ANSICD}?{SP}.+ 
                  // list extensions under planets, traders, ships, mines
                  begin
                    display_window(display,WINDOW_USERMSGS);
                    tempstr:=stripansi(yyvars.yytext);
                    if yyvars.yysstate=SECTORPLANETS then
                    begin
                      if leftstr(tempstr,11)='          (' then writeln(' ',tempstr);
                    end
                    else writeln(' ',tempstr);
                  end;
<SECTOR,SECTORPLANETS,SECTORTRADERS,SECTORSHIPS,SECTORMINES>^{ANSICD}?"Warps".+ 
                  // warps
                  begin
                    display_window(display,WINDOW_USERMSGS);
                    writeln(' ',stripansi(yyvars.yytext));
                  end;

^": ENDINT"       |
. ;

{CR}{ANSICD}{LF}  |
{CR}{LF}          |
{CR}              |
{LF}              
                  begin
                    inc(yyvars.yylineno);
                    yyvars.yycolno:=0;
                  end;

%%

{
var i : Integer;

var
  yyvars : tyyvars;
  count : integer;
  fname : ansistring;
  fhandle : file;
begin
  clrscr;
  for i := 1 to NS do sects[i]:=0;

  yyvars.yylineno:=0;
  yyclear(yyvars);
  yyvars.yyiter:=0;

  fname:='long.txt';
  if fileexists(fname) then
  begin
    assign(fhandle,fname);
    reset(fhandle, sizeof(char));
    blockread(fhandle,yyvars.buf,100,yyvars.buflen);
    yyvars.bufptr:=1;
    while yyvars.buflen>0 do
    begin
      if yylex(yyvars)=0 then ;//write('*');
      blockread(fhandle,yyvars.buf,100,yyvars.buflen);
      yyvars.bufptr:=1;
    end;
    close(fhandle);
  end;

  writeln;
  writeln;
  write('|');
  write('sect':5, ' ', 'num':3,' |');
  write('sect':5, ' ', 'num':3,' |');
  write('sect':5, ' ', 'num':3,' |');
  write('sect':5, ' ', 'num':3,' |');
  write('sect':5, ' ', 'num':3,' |');
  write('sect':5, ' ', 'num':3,' |');
  write('sect':5, ' ', 'num':3,' |');
  writeln;
  count:=0;
  for i := 1 to NS do
    if sects[i]>0 then
    begin
      if (count mod 7)=0 then write('|');
      inc(count);
      write(i:5, ' ', sects[i]:3,' |');
      if (count mod 7)=0 then writeln;
    end;
end.
}