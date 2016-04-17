const
  PCHAR_TRUE    : pchar = 'TRUE';
  PCHAR_FALSE   : pchar = 'FALSE';
  PCHAR_SUCCESS : pchar = 'success';
  PCHAR_FAILURE : pchar = 'error';
  PCHAR_DENIED  : pchar = 'revproxy:  access denied.';
  LOCAL         : pchar = 'localhost';
  PHONEBOOKINI  : pchar = 'phonebook.ini';
  REVPROXYINI   : pchar = 'revproxy.ini';
  PROXYTIMEOUT = 250000;

  WINDOW_MAX = 7;
  WINDOW_FULL = 0;
  WINDOW_PROXYTITLE = 1;
  WINDOW_PROXYMSGS = 2;
  WINDOW_SETUPTITLE = 3;
  WINDOW_SETUPMSGS = 4;
  WINDOW_USERTITLE = 5;
  WINDOW_USERMSGS = 6;
  WINDOW_MENUBAR=7;

type
  sourcetype = (src_listener,src_host,src_client,src_visitor);
  ca255 = array[0..255] of char;
  tproxy = record
    wsadata : twsadata;
    socket_fds: tfdset;
    max_fd: tsocket;
    timeout: ptimeval;

    listener: phostent;
    listener_name: pchar;
    listener_addr: tsockaddr;
    listener_fd: tsocket;
    listener_port: u_short;
    listener_connected: boolean;

    host: phostent;
    host_name: pchar;
    host_addr: tsockaddr;
    host_fd: tsocket;
    host_port: u_short;
    host_connected: boolean;

    client_fd: tsocket;
    client_addr: tsockaddr;
    client_connected: boolean;

    visitor_block: boolean;
    visitor_lock: boolean;
  end;

  statetype = (st_connect,st_twgsmenu,st_gamemenu,st_star,st_stats,st_login,
               st_command,st_computer,st_corp,st_port,st_stardock,st_terra,
               st_planet,st_citadel,st_cimmode);
  tgamestate = record
    buf: array[0..1024] of char;
    buf_n: integer;
    lin: array[0..7] of ca255;
    lin_i: u_short;
    sta: array[0..255] of statetype;
    sta_i: u_short;
    sta_c: u_long;
  end;

  twindow = record
    left, right,
    top, bottom,
    row, col: byte;
  end;
  tdisplay = record
    windows: array[0..WINDOW_MAX] of twindow;
    current: word;
  end;

  tmenu = record
    key, arg: ansistring;
    vkey, varg: boolean;
  end;


procedure display_window(var d: tdisplay; num: word);
begin
  with d.windows[d.current] do
  begin
    row:=wherex;
    col:=wherey;
  end;
  d.current:=num;
  with d.windows[d.current] do
  begin
    window(left,top,right,bottom);
    gotoxy(row,col);
  end;
end;

procedure display_setup(var d: tdisplay);
var
  i: word;
  value: ansistring;
begin
  for i:=0 to WINDOW_MAX do
    with d.windows[i] do
    begin
      left:=1;
      right:=80;
      top:=1;
      bottom:=25;
      row:=1;
      col:=1;
    end;
  with d.windows[WINDOW_FULL] do
  begin
    if not(iniread(REVPROXYINI,'display','full',value)) then value:='1;1;80;25';
    left:=strtointdef(wordget(value,1,';'),1);
    top:=strtointdef(wordget(value,2,';'),1);
    right:=strtointdef(wordget(value,3,';'),80);
    bottom:=strtointdef(wordget(value,4,';'),25);
    row:=1;
    col:=1;
  end;
  with d.windows[WINDOW_PROXYTITLE] do
  begin
    if not(iniread(REVPROXYINI,'display','proxytitle',value)) then value:='1;1;58;1';
    left:=strtointdef(wordget(value,1,';'),1);
    top:=strtointdef(wordget(value,2,';'),1);
    right:=strtointdef(wordget(value,3,';'),58);
    bottom:=strtointdef(wordget(value,4,';'),1);
    row:=1;
    col:=1;
  end;
  with d.windows[WINDOW_PROXYMSGS] do
  begin
    if not(iniread(REVPROXYINI,'display','proxymsgs',value)) then value:='2;2;58;8';
    left:=strtointdef(wordget(value,1,';'),2);
    top:=strtointdef(wordget(value,2,';'),2);
    right:=strtointdef(wordget(value,3,';'),58);
    bottom:=strtointdef(wordget(value,4,';'),8);
    row:=1;
    col:=1;
  end;
  with d.windows[WINDOW_SETUPTITLE] do
  begin
    if not(iniread(REVPROXYINI,'display','infotitle',value)) then value:='60;1;80;1';
    left:=strtointdef(wordget(value,1,';'),60);
    top:=strtointdef(wordget(value,2,';'),1);
    right:=strtointdef(wordget(value,3,';'),80);
    bottom:=strtointdef(wordget(value,4,';'),1);
    row:=1;
    col:=1;
  end;
  with d.windows[WINDOW_SETUPMSGS] do
  begin
    if not(iniread(REVPROXYINI,'display','infomsgs',value)) then value:='61;2;80;8';
    left:=strtointdef(wordget(value,1,';'),61);
    top:=strtointdef(wordget(value,2,';'),2);
    right:=strtointdef(wordget(value,3,';'),80);
    bottom:=strtointdef(wordget(value,4,';'),8);
    row:=1;
    col:=1;
  end;
  with d.windows[WINDOW_USERTITLE] do
  begin
    if not(iniread(REVPROXYINI,'display','usertitle',value)) then value:='1;9;58;9';
    left:=strtointdef(wordget(value,1,';'),1);
    top:=strtointdef(wordget(value,2,';'),9);
    right:=strtointdef(wordget(value,3,';'),58);
    bottom:=strtointdef(wordget(value,4,';'),9);
    row:=1;
    col:=1;
  end;
  with d.windows[WINDOW_USERMSGS] do
  begin
    if not(iniread(REVPROXYINI,'display','usermsgs',value)) then value:='2;10;58;25';
    left:=strtointdef(wordget(value,1,';'),2);
    top:=strtointdef(wordget(value,2,';'),10);
    right:=strtointdef(wordget(value,3,';'),58);
    bottom:=strtointdef(wordget(value,4,';'),25);
    row:=1;
    col:=1;
  end;

  with d.windows[WINDOW_MENUBAR] do
  begin
    if not(iniread(REVPROXYINI,'display','menubar',value)) then value:='2;10;58;25';
    left:=strtointdef(wordget(value,1,';'),2);
    top:=strtointdef(wordget(value,2,';'),10);
    right:=strtointdef(wordget(value,3,';'),58);
    bottom:=strtointdef(wordget(value,4,';'),25);
    row:=1;
    col:=1;
  end;

  clrscr;
  display_window(d,WINDOW_FULL);
  gotoxy(1,24);
end;

function pchar_to_ulong(s: pchar): u_long;
var
//  i: u_short;
  rslt: u_long;
begin
//  rslt:=0;
//  for i:=0 to min(sizeof(s),4)-1 do
//    rslt+=u_long(s[i]) shl ((3-i)*8);
  move(s^,rslt,min(sizeof(s),4));
  rslt:=htonl(rslt);
  pchar_to_ulong:=rslt;
end;

function buildaddr(family: smallint; port: u_short; addr: u_long): tsockaddr;
var
  a : tsockaddr;
begin
  a.sin_family:=family;
  a.sin_port:=htons(port);
  a.sin_addr.s_addr:=htonl(addr);
  buildaddr:=a;
end;

procedure socket_disconnect(var proxy: tproxy; fd: tsocket; var d: tdisplay);
begin
  if fd_isset(fd, proxy.socket_fds) then
  begin
    display_window(d,WINDOW_PROXYMSGS);
    if fd=proxy.host_fd then write('host ')
    else if fd=proxy.listener_fd then write('listener ')
         else if fd=proxy.client_fd then write('client ')
              else write('visitor ');
    writeln('socket ', fd, ' closed');
    closesocket(fd);
    fd_clr(fd, proxy.socket_fds);
    if proxy.client_connected and (fd=proxy.client_fd) then proxy.client_connected:=false;
    if proxy.host_connected and (fd=proxy.host_fd) then proxy.host_connected:=false;
  end;
end;

procedure proxy_shutdown(var proxy: tproxy; var d: tdisplay);
var
  i: u_long;
begin
  display_window(d,WINDOW_PROXYMSGS);
  if proxy.socket_fds.fd_count>0 then
    for i:=0 to proxy.max_fd do
      socket_disconnect(proxy,i,d);
  if not(proxy.timeout=nil) then freemem(proxy.timeout);
//if not(proxy.host=nil) then freemem(proxy.host);
  if not(proxy.host_name=nil) then strdispose(proxy.host_name);
  writeln('cleaning up winsock... ');
  wsacleanup;
//writeln('memavail ',memavail);
end;

procedure sock_error(var proxy: tproxy; s: string; var d: tdisplay);
begin
  display_window(d,WINDOW_PROXYMSGS);
  writeln(PCHAR_FAILURE,' #', wsagetlasterror - WSABASEERR, ' at ',s);
  proxy_shutdown(proxy,d);
  display_window(d,WINDOW_FULL);
  halt;
end;

procedure general_error(var proxy: tproxy; s: string; var d: tdisplay);
begin
  display_window(d,WINDOW_USERMSGS);
  writeln(PCHAR_FAILURE,' at ',s);
  proxy_shutdown(proxy,d);
  display_window(d,WINDOW_FULL);
  halt;
end;

procedure proxy_startup(var proxy: tproxy; gname: ansistring; var d: tdisplay);
var
  hname, hport, pport: ansistring;
begin
  proxy.socket_fds.fd_count:=0;
  proxy.timeout:=nil;
  proxy.host:=nil;
  proxy.host_name:=nil;
  display_window(d,WINDOW_PROXYMSGS);
  clrscr;
  write('initializing winsock... ');
  if not(wsastartup($2,proxy.wsadata)=0) then sock_error(proxy,'wsastartup()',d)
  else writeln(PCHAR_SUCCESS);
  if not(iniread(PHONEBOOKINI,gname,'hostname',hname)) then general_error(proxy,'iniread()',d);
  if not(iniread(PHONEBOOKINI,gname,'hostport',hport)) then general_error(proxy,'iniread()',d);
  if not(iniread(PHONEBOOKINI,gname,'proxyport',pport)) then general_error(proxy,'iniread()',d);
  proxy.listener_port:=strtoint(pport);
  proxy.host_port:=strtoint(hport);
  getmem(proxy.timeout,sizeof(proxy.timeout));
  proxy.timeout^.tv_sec:=0;
  proxy.timeout^.tv_usec:=PROXYTIMEOUT;
  proxy.host_name:=stralloc(length(hname)+1);
  strpcopy(proxy.host_name,hname);
  proxy.listener_connected:=false;
  proxy.host_connected:=false;
  proxy.client_connected:=false;
  proxy.visitor_block:=false;
  proxy.visitor_lock:=false;
end;

procedure host_setup(var proxy: tproxy; var d: tdisplay);
begin
  display_window(d,WINDOW_PROXYMSGS);
  write('assigning host socket... ');
  proxy.host_fd:=socket(AF_INET, SOCK_STREAM, 0);
  if (proxy.host_fd = tsocket(INVALID_SOCKET)) then sock_error(proxy,'socket()',d)
  else writeln(proxy.host_fd,' ',PCHAR_SUCCESS);

  write('getting host name... ');
  proxy.host:=gethostbyname(proxy.host_name);
  if proxy.host=nil then sock_error(proxy,'gethostbyname()',d)
  else writeln(proxy.host_name,' (',proxy.host^.h_name,') ',PCHAR_SUCCESS);
  proxy.host_addr:=buildaddr(AF_INET, proxy.host_port, pchar_to_ulong(proxy.host^.h_addr^));

  proxy.host_connected:=false;
end;

procedure listener_setup(var proxy: tproxy; var d: tdisplay);
var
  ca: array[0..255] of char;
begin
  display_window(d,WINDOW_PROXYMSGS);

  write('assigning listener socket... ');
  proxy.listener_fd:=socket(AF_INET, SOCK_STREAM, 0);
  if (proxy.listener_fd = tsocket(INVALID_SOCKET)) then sock_error(proxy,'socket()',d)
  else writeln(proxy.listener_fd,' ',PCHAR_SUCCESS);

  write('setting listener socket options... ');
  if not(setsockopt(proxy.listener_fd, $ffff{SOL_SOCKET}, SO_REUSEADDR, PCHAR_TRUE, sizeof(PCHAR_TRUE)) = 0) then sock_error(proxy,'setsockopt()',d)
  else writeln(PCHAR_SUCCESS);

  // this section not required - only for obtaining local ip
  write('getting listener name... ');
  if (gethostname(ca,sizeof(ca))=SOCKET_ERROR) then halt;
  proxy.listener_name:=stralloc(length(ca)+1);
  proxy.listener:=gethostbyname(proxy.listener_name);
  if proxy.listener=nil then sock_error(proxy,'gethostbyname()',d)
  else writeln(proxy.listener_name,' (',proxy.listener^.h_name,') ',PCHAR_SUCCESS);
  proxy.listener_addr:=buildaddr(AF_INET, proxy.listener_port, pchar_to_ulong(proxy.listener^.h_addr^));

  write('binding listener socket... ');
  proxy.listener_addr:=buildaddr(AF_INET,proxy.listener_port,INADDR_ANY);
  if (bind(proxy.listener_fd, @proxy.listener_addr, sizeof(proxy.listener_addr)) <> 0) then sock_error(proxy,'bind()',d)
  else writeln(PCHAR_SUCCESS);

  write('starting listener... ');
  if (listen(proxy.listener_fd, 10) <> 0) then sock_error(proxy,'listen()',d)
  else writeln(PCHAR_SUCCESS);

  fd_zero(proxy.socket_fds);
  fd_set(proxy.listener_fd, proxy.socket_fds);
  proxy.max_fd:=proxy.listener_fd;
  proxy.listener_connected:=true;
end;

procedure host_connect(var proxy: tproxy; var d: tdisplay);
begin
  display_window(d,WINDOW_PROXYMSGS);
  write('connecting to host socket...');
  if (connect(proxy.host_fd,proxy.host_addr,sizeof(proxy.host_addr))<0) then
    sock_error(proxy,'connect()',d)
  else writeln(PCHAR_SUCCESS);
  fd_set(proxy.host_fd, proxy.socket_fds);
  if (proxy.host_fd>proxy.max_fd) then proxy.max_fd:=proxy.host_fd;
  proxy.host_connected:=true;
end;

procedure host_disconnect(var proxy: tproxy; var d: tdisplay);
var
  i: u_long;
begin
  display_window(d,WINDOW_PROXYMSGS);
  socket_disconnect(proxy, proxy.host_fd,d);
  // release all client and visitor sockets
  for i:=1 to proxy.max_fd do
    if not(i=proxy.listener_fd) then
      socket_disconnect(proxy,i,d);
  proxy.max_fd:=proxy.listener_fd;
end;

function client_connect(var proxy: tproxy; var d: tdisplay): tsocket;
var
  addrlen : longint;
  fd: tsocket;
  addr: tsockaddr;
begin
  display_window(d,WINDOW_PROXYMSGS);
  addrlen:=sizeof(addr);
  fd:=accept(proxy.listener_fd, @addr, addrlen);
  if (fd = tsocket(SOCKET_ERROR)) then sock_error(proxy,'accept()',d)
  else
  begin
    fd_set(fd, proxy.socket_fds);
    if (fd>proxy.max_fd) then proxy.max_fd:=fd;
    writeln('new connection from ', inet_ntoa(addr.sin_addr), ' on socket ', fd);
    if not(proxy.client_connected) then
    begin
      proxy.client_connected:=true;
      proxy.client_fd:=fd;
      proxy.client_addr:=addr;
    end;
  end; //else
  client_connect:=fd;
end;

function getgame(fname: ansistring; var d: tdisplay): ansistring;
var
  fhandle: text;
  line, list, menu: ansistring;
  i: u_short;
const
  menubase=64;
begin
  list:='';
  if fileexists(fname) then
  begin
    assign(fhandle,fname);
    reset(fhandle);
    while not(eof(fhandle)) do
    begin
      readln(fhandle,line);
      line:=trim(line);
      if (leftstr(line,1)='[') and (rightstr(line,1)=']') and not(leftstr(line,2)='[*') then
        if list='' then
          list:=leftstr(rightstr(line,length(line)-1),length(line)-2)+';'
        else
          list:=list+';'+leftstr(rightstr(line,length(line)-1),length(line)-2);
    end;
    close(fhandle);
  end;

  display_window(d,WINDOW_USERMSGS);
  clrscr;
  for i:=1 to wordcount(list,';') do
  begin
    writeln(char(i+menubase),' - ',wordget(list,i,';'));
    menu:=menu+upcase(char(i+menubase))+lowercase(char(i+menubase));
  end;
  i:=u_short(upcase(charmenu('choose a game (ESC to quit): ',menu)));
  if i=0 then halt;
  getgame:=wordget(list,i-menubase,';');
end;

procedure menureset(var m: tmenu; var d: tdisplay);
begin
  m.key:='';
  m.arg:='';
  m.vkey:=false;
  m.varg:=false;
  display_window(d,WINDOW_USERMSGS);
  clrscr;
  writeln;
  writeln('MAIN MENU');
  writeln(' V - visitor options');
  writeln(' X - exit');
  writeln;
end;

procedure menuparsearg(var m: tmenu; ch: char);
begin
  if ch=char(13) then m.varg:=true
  else m.arg:=m.arg+ch;
end;

procedure refresh_setup_window(var d: tdisplay; p: tproxy);
var
  pc: pchar;
  i, j, k: u_long;
begin
  display_window(d,WINDOW_SETUPMSGS);
  clrscr;
  if p.listener_connected then
  begin
    i:=0;
    while not(p.listener^.h_addr_list[i]=nil) do
    begin
      pc:=p.listener^.h_addr_list[i];
      write('p ');
      k:=sizeof(pc)-1;
      for j:=0 to k-1 do
        write(word(pc[j]),'.');
      writeln(word(pc[k]),':',p.listener_port);
      inc(i);
    end;
  end;
  if p.host_connected then writeln('h ',inet_ntoa(p.host_addr.sin_addr),':',p.host_port);
  if p.client_connected then writeln('c ',inet_ntoa(p.client_addr.sin_addr));
  write('vblock: ');
  if p.visitor_block then writeln('YES')
                     else writeln('NO');
  write('vlock: ');
  if p.visitor_lock then writeln('YES')
                    else writeln('NO');
end;

procedure menuparsekey(var m: tmenu; ch: char; var d: tdisplay; var p: tproxy);
var
  k: ansistring;
  valid: boolean;
begin
  k:=upcase(m.key+ch);
  display_window(d,WINDOW_USERMSGS);

  valid:=false;
  if not(valid) and (k='V'  ) then begin valid:=true; writeln('VISITOR: [B]lock [L]ock [D]isconnect'); end;
  if not(valid) and (k='VB' ) then begin valid:=true; write('VISITOR BLOCK: [Y]es [N]o');              end;
  if not(valid) and (k='VBY') then begin valid:=true; writeln(' Yes - BLOCKED');                       end;
  if not(valid) and (k='VBN') then begin valid:=true; writeln(' No - NOT BLOCKED');                    end;
  if not(valid) and (k='VD' ) then begin valid:=true; write('VISITOR DISCONNECT:');                    end;
  if not(valid) and (k='VL' ) then begin valid:=true; write('VISITOR LOCK: [Y]es [N]o');               end;
  if not(valid) and (k='VLY') then begin valid:=true; writeln(' Yes - LOCKED');                        end;
  if not(valid) and (k='VLN') then begin valid:=true; writeln(' No - NOT LOCKED');                     end;
  if not(valid) and (k='X'  ) then begin valid:=true; write('EXIT: [Y]es [N]o');                       end;
  if not(valid) and (k='XY' ) then begin valid:=true; writeln(' Yes - EXITING');                       end;
  if not(valid) and (k='XN' ) then begin valid:=true; writeln(' No');                                  end;

  if valid then
  begin
    m.key:=k;
    if k='VBY' then begin
                      p.visitor_block:=true;
                      refresh_setup_window(d,p);
                      menureset(m,d);
                    end;
    if k='VBN' then begin
                      p.visitor_block:=false;
                      refresh_setup_window(d,p);
                      menureset(m,d);
                    end;
    if k='VD'  then begin
                      writeln('feature not ready');
                      refresh_setup_window(d,p);
                      menureset(m,d);
                    end;
    if k='VLY' then begin
                      p.visitor_lock:=true;
                      refresh_setup_window(d,p);
                      menureset(m,d);
                    end;
    if k='VLN' then begin
                      p.visitor_lock:=false;
                      refresh_setup_window(d,p);
                      menureset(m,d);
                    end;
    if k='XY'  then begin
                      display_window(d,WINDOW_PROXYMSGS);
                      proxy_shutdown(p,d);
                      display_window(d,WINDOW_FULL);
                      halt;
                    end;
    if k='XN'  then menureset(m,d);
  end;
end;

procedure menuparse(var m: tmenu; ch: char; var d: tdisplay; var p: tproxy);
begin
  if ch=char(27) then menureset(m,d)
  else
  begin
    if m.vkey then
    begin
      menuparsearg(m,ch);
      if m.varg then menuparsekey(m,ch,d,p);
    end
    else menuparsekey(m,ch,d,p);
  end;
end;

