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

function posc(c:char; s:ansistring): integer;
var
  p: pchar;
  i: integer;
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

function validfolder(path:ansistring): boolean;
var
  f: text;
  fname: ansistring;
begin
 fname:=path+'pmap.$$$';
 {$i-}
 assign(f, fname);
 rewrite(f);
 {$i+}
 case ioresult of
   0: begin
        write(f,'this file can be deleted.');
        close(f);
        deletefile(fname);
        validfolder:=(extractfilename(fname)='pmap.$$$');
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

