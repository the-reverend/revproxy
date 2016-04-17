unit revlib;

interface

uses sysutils, math, crt;

type
  charset = set of char;

// ansistring functions \\
function countchar(s: ansistring; c: char): word;
function posc(c:char; s:ansistring): longint;
function posc(c:char; s:ansistring; start:longint): longint;
function stripansi(s: ansistring): ansistring;
function stripchar(s: ansistring; c: char): ansistring;
function stripset(s: ansistring; l: charset): ansistring;
function strppos(s2, s1: ansistring): longint;
function substr(s: ansistring; i, l: longint): ansistring;
function translate(s, tfr, tto: ansistring): ansistring;
function wordcount(s: ansistring; d: char): word;
function wordget(s: ansistring; num: word; d: char): ansistring;
function wordloc(s: ansistring; start, num: word; d: char): word;
function center(s: ansistring; w: longint; c: char): ansistring;

// ini file management \\
function inisection(line,section: ansistring): boolean;
function inikey(line,key:ansistring): boolean;
function inivalue(line:ansistring): ansistring;
function iniwrite(fname,section,key,value:ansistring): boolean;
function iniread(fname,section,key:ansistring; var value:ansistring): boolean;

// misc functions \\
function spinner(count, width: word): word;
function paramcheck(p: ansistring): integer;
function charmenu(prompt, menu: ansistring): char;
function validfolder(path: ansistring): boolean;

implementation

function center(s: ansistring; w: longint; c: char): ansistring;
var
  pad1, pad2: longint;
begin
  pad2:=w-length(s);
  pad1:=pad2 div 2;
  pad2:=pad1 + (pad2 mod 2);
  if length(s)>w then center:=leftstr(s,w)
  else center:=stringofchar(c,pad1)+s+stringofchar(c,pad2);
end;

function substr(s: ansistring; i, l: longint): ansistring;
begin
  substr:=leftstr(rightstr(s,length(s)-i),l);
end;

function spinner(count, width: word): word;
var
  x, y: byte;
  ch: char;
begin
  ch:=' ';
  if count=0 then ch:='-';
  if count=width then ch:='\';
  if count=width*2 then ch:='|';
  if count=width*3 then ch:='/';
  if count>=width*4 then
  begin
    ch:='-';
    count:=0;
  end;
  if not(ch=' ') then
  begin
    x:=wherex;
    y:=wherey;
    write(ch);
    gotoxy(x,y);
  end;
  spinner:=count+1;
end;

function strppos(s2, s1: ansistring): longint;
var
  p1, p2, i: pchar;
  fail: boolean;
  rslt: longint;
begin
  fail:=false;
  p1:=stralloc(length(s1)+1);
  p2:=stralloc(length(s2)+1);
  if strpcopy(p1,s1)<>p1 then fail:=true;
  if strpcopy(p2,s2)<>p2 then fail:=true;
  if not(fail) then
  begin
    i:=strpos(p1, p2);
    if i=nil then rslt:=0
    else rslt:=longint(i)-longint(p1);
  end;
  strdispose(p1);
  strdispose(p2);
  strppos:=rslt;
end;

function posc(c:char; s:ansistring): longint;
var
  p: pchar;
  i: longint;
begin
  p:=stralloc(length(s)+1);
  if strpcopy(p,s)<>p then posc:=0
  else
  begin
    i:=strlen(strscan(p,c));
    if i=0 then posc:=0
    else posc:=length(s)-i+1
  end;
  strdispose(p);
end;

function posc(c:char; s:ansistring; start: longint): longint;
var
  p: pchar;
  i: longint;
begin
  p:=stralloc(length(rightstr(s,max(length(s)-start,0)))+1);
  if (strpcopy(p,rightstr(s,max(length(s)-start,0)))<>p) then posc:=0
  else
  begin
    i:=strlen(strscan(p,c));
    if i=0 then posc:=0
    else posc:=length(s)-i+1
  end;
  strdispose(p);
end;

function validfolder(path:ansistring): boolean;
const
  name: string='tmp.$$$';
var
  f: text;
  fname: ansistring;
begin
 fname:=path+name;
 {$i-}
 assign(f, fname);
 rewrite(f);
 {$i+}
 case ioresult of
   0: begin
        write(f,'this file can be deleted.');
        close(f);
        deletefile(fname);
        validfolder:=(extractfilename(fname)=name);
      end;
   otherwise validfolder:=false;
 end;
end;

function paramcheck(p : ansistring) : integer;
var j, k1, k2, k3, l: integer;
begin
  if posc('/',p)=0 then paramcheck:=0
  else
  begin
    k1:=posc('+',p);
    k2:=posc('-',p);
    k3:=posc(':',p);
    if min(min(k1,k2),k3)=0 then
    begin
      j:=max(max(k1,k2),k3);
      l:=length(p);
      if (j<2) then
      begin
        if (l>1) then paramcheck:=l+1
        else paramcheck:=0;
      end
      else
      begin
        if l>1 then paramcheck:=j
        else paramcheck:=0;
      end;
    end
    else paramcheck:=min(min(k1,k2),k3);
  end;
end;

function wordloc(s: ansistring; start, num: word; d: char): word;
var
  w, l: integer;
  db: boolean;
begin
  l:=length(s);
  if (s='') or (num<1) or (start>l) then
  begin
    wordloc:=0;
    exit;
  end;
  db:=true;
  w:=0;
  start:=pred(start);
  while (w<num) and (start<l) do
  begin
    start:=succ(start);
    if db and not(s[start]=d) then
    begin
      w:=succ(w);
      db:=false;
    end
    else
      if not(db) and (s[start]=d) then db:=true;
  end;
  if w=num then wordloc:=start
  else wordloc:=0;
end;

function wordcount(s: ansistring; d: char): word;
var
  w, i: integer;
  db: boolean;
begin
  if s='' then
  begin
    wordcount:=0;
    exit;
  end;
  db:=true;
  w:=0;
  For  i:=1 to length(s) do
  begin
    if db and not(s[i]=d) then
    begin
      w:=succ(w);
      db:=false;
    end
    else
      if not(db) and (s[i]=d) then db:=true;
  end;
  wordcount:=w;
end;

function wordget(s: ansistring; num: word; d: char): ansistring;
var start, finish : integer;
begin
  if s='' then
  begin
    wordget:='';
    exit;
  end;
  start:=wordloc(s,1,num,d);
  if start=0 then
  begin
    wordget:='';
    exit;
  end
  else finish:=wordloc(s,start,2,d);
  if finish=0 then finish:=succ(length(s));
  repeat
    finish:=pred(finish);
  until s[finish]<>d;
  wordget:=copy(s,start,succ(finish-start));
end;

function inisection(line,section:ansistring): boolean;
begin
  if line='['+section+']' then inisection:=true
  else inisection:=false;
end;

function inikey(line,key:ansistring): boolean;
begin
  if wordcount(line,'=')=2 then
    if wordget(line,1,'=')=key then inikey:=true
    else inikey:=false
  else inikey:=false;
end;

function inivalue(line:ansistring): ansistring;
begin
  inivalue:=wordget(line,2,'=');
end;

function iniwrite(fname,section,key,value:ansistring): boolean;
var
  fhandle, tmphandle: text;
  tmpname, line: ansistring;
  insection, written: boolean;
begin
  insection:=false;
  written:=false;
  tmpname:=fname+'.tmp';
  if fileexists(tmpname) then deletefile(tmpname);
  if fileexists(fname) then
  begin
    assign(tmphandle,tmpname);
    rewrite(tmphandle);
    assign(fhandle,fname);
    reset(fhandle);
    while not(eof(fhandle)) do
    begin
      readln(fhandle,line);
      line:=trim(line);
      if insection and (leftstr(line,1)='[') and (rightstr(line,1)=']') then insection:=false;
      if not(insection) then insection:=inisection(line,section);
      if not(insection) then writeln(tmphandle,line);
      if insection and not(inikey(line,key)) then writeln(tmphandle,line);
      if insection and not(written) then
      begin
        writeln(tmphandle,key,'=',value);
        written:=true;
      end;
    end;
    close(fhandle);
    if not(written) then
    begin
      writeln(tmphandle);
      writeln(tmphandle,'[',section,']');
      writeln(tmphandle,key,'=',value);
    end;
    close(tmphandle);
    if fileexists(fname) then deletefile(fname);
    renamefile(tmpname,fname);
    iniwrite:=true;
  end
  else iniwrite:=false;
end;

function iniread(fname,section,key:ansistring; var value:ansistring): boolean;
var
  fhandle: text;
  line: ansistring;
  insection: boolean;
begin
  value:='';
  insection:=false;
  if fileexists(fname) and (value='') then
  begin
    assign(fhandle,fname);
    reset(fhandle);
    while not(eof(fhandle)) do
    begin
      readln(fhandle,line);
      line:=trim(line);
      if insection and (leftstr(line,1)='[') and (rightstr(line,1)=']') then insection:=false;
      if insection and inikey(line,key) then value:=inivalue(line);
      if not(insection) and inisection(line,section) then insection:=true;
    end;
    close(fhandle);
    if value='' then iniread:=false
    else iniread:=true;
  end
  else iniread:=false;
end;

function charmenu(prompt,menu: ansistring): char;
var
  ch, high: char;
begin
  write(prompt);
  ch:=readkey;
  if ch=char(0) then high:=readkey;
  if ch=char(0) then write(' ',word(high));
  while (posc(ch,menu)=0) and not(ch=char(27)) do
  begin
    ch:=readkey;
    if ch=char(0) then high:=readkey;
    if ch=char(0) then write(' ',word(high));
  end;
  if ch=char(27) then ch:=char(0);
  writeln(ch);
  charmenu:=ch;
end;

function stripansi(s: ansistring): ansistring;
var
  s2: ansistring;
  i: word;
  ain: boolean;
begin
  ain:=false;
  for i:=1 to length(s) do
  begin
    if s[i]=#27 then ain:=true;
    if not(ain) then s2:=s2+s[i];
    if ain and not(s[i]=#27) and not(s[i] in ['[',';','1','2','3','4','5','6','7','8','9','0']) then ain:=false;
  end;
  stripansi:=s2;
end;

function stripchar(s: ansistring; c: char): ansistring;
var
  s2: ansistring;
  i: word;
begin
  for i:=1 to length(s) do
    if not(s[i]=c) then s2:=s2+s[i];
  stripchar:=s2;
end;

function stripset(s: ansistring; l: charset): ansistring;
var
  s2: ansistring;
  i: word;
begin
  for i:=1 to length(s) do
    if not(s[i] in l) then s2:=s2+s[i];
  stripset:=s2;
end;

function translate(s, tfr, tto: ansistring): ansistring;
var
  s2: ansistring;
  i, j, k: word;
  f: boolean;
begin
  k:=min(length(tfr),length(tto));
  for i:=1 to length(s) do
  begin
    f:=false;
    for j:=1 to k do
      if s[i]=tfr[j] then
      begin
        f:=true;
        break;
      end;
    if f then s2:=s2+tto[j]
    else s2:=s2+s[i];
  end;
  translate:=s2;
end;

function countchar(s: ansistring; c: char): word;
var
  i, count: word;
begin
  count:=0;
  for i:=1 to length(s) do
    if s[i]=c then inc(count);
  countchar:=count;
end;

begin
end.
