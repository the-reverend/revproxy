program revproxy;

// stacksize, heapsize \\
{$M 524288, 3145728}

uses
  winsock, crt, strings, math, dos, sysutils;

const
  FULLVERSION = true;

{$include revlib.inc}
{$include revproxy.inc}

procedure process_client_state(var s: tgamestate);
begin
end;

procedure process_host_state(var s: tgamestate);
begin
end;

function insynch(var s1, s2: tgamestate): boolean;
begin
  if (s1.sta_i=s2.sta_i) and (s1.sta_c=s1.sta_c) then insynch:=true
  else insynch:=false;
end;

procedure main;
var
  proxy: tproxy;
  temp_fds: tfdset;
  new_fd, current_fd: tsocket;
  source: sourcetype;
  hs, cs, vs: tgamestate;
  gname: ansistring;

  display: tdisplay;
  menu: tmenu;

  ans: integer;
  i, j: u_int;
  k: longint;
  ch: char;
  synch, done: boolean;
  path_app, path_log, path_database: ansistring;

begin
//writeln('memavail ',memavail);


  hs.sta_i:=0;
  hs.sta_c:=0;
  cs.sta_i:=0;
  cs.sta_c:=0;

  if not(iniread(REVPROXYINI,'folders','program',path_app)) then path_app:='';
  if not(iniread(REVPROXYINI,'folders','logdata',path_log)) then path_log:='';
  if not(iniread(REVPROXYINI,'folders','database',path_database)) then path_database:='';

  display_setup(display);
  display_window(display,WINDOW_PROXYTITLE);
  write('PROXY MESSAGES:');
  display_window(display,WINDOW_SETUPTITLE);
  write('PROXY SETUP:');
  display_window(display,WINDOW_USERTITLE);
  write('USER INPUT:');

  display_window(display,WINDOW_USERMSGS);
  gname:=getgame(PHONEBOOKINI,display);
  k:=strppos('%gamename%',path_database);
  if k>0 then path_database:=leftstr(path_database,k)+gname+'\';

  display_window(display,WINDOW_PROXYMSGS);
  proxy_startup(proxy,gname,display);
  host_setup(proxy,display);
  listener_setup(proxy,display);

  refresh_setup_window(display, proxy);
  menureset(menu,display);

  done:=false;
  synch:=true;
  ch:=' ';
  while not(done) do
  begin
    temp_fds:=proxy.socket_fds;
    ans:=select(proxy.max_fd{+1}, @temp_fds, nil, nil, proxy.timeout);
    if ans=SOCKET_ERROR then sock_error(proxy,'select()',display);
    if ans>0 then
    begin
      for i:=0 to proxy.socket_fds.fd_count-1 do
      begin
        current_fd:=proxy.socket_fds.fd_array[i];
        if fd_isset(current_fd, temp_fds) then
        begin
          if current_fd=proxy.listener_fd then source:=src_listener
          else if current_fd=proxy.host_fd then source:=src_host
               else if current_fd=proxy.client_fd then source:=src_client
                    else source:=src_visitor;
          case source of
            src_listener: // handle new connections
              begin
                if proxy.client_connected and proxy.visitor_block then
                begin
                  new_fd:=client_connect(proxy,display);
                  socket_disconnect(proxy,new_fd,display);
                end
                else
                begin
                  new_fd:=client_connect(proxy,display);
                  if not(proxy.host_connected) then host_connect(proxy,display);
                  refresh_setup_window(display,proxy);
                end;
              end;
            src_host: // handle data from the host
              begin
                hs.buf_n:=recv(proxy.host_fd, hs.buf, sizeof(hs.buf), 0);
                if hs.buf_n<=0 then
                begin
                  host_disconnect(proxy,display);
                  host_setup(proxy,display);
                  refresh_setup_window(display,proxy);
                end //if
                else // got some data from host
                begin
                  synch:=false;
                  for j:=0 to proxy.socket_fds.fd_count-1 do
                  begin
                    current_fd:=proxy.socket_fds.fd_array[j];
                    if (fd_isset(current_fd, proxy.socket_fds)) then
                      if (current_fd <> proxy.listener_fd) and (current_fd <> proxy.host_fd) then
                        if (send(current_fd, hs.buf, hs.buf_n, 0) = SOCKET_ERROR) then sock_error(proxy,'send()',display)
                  end;//for
                  process_host_state(hs);
                  synch:=insynch(cs,hs);
                end;
              end;
            src_client: // handle data from a client
              begin
                cs.buf_n:=recv(current_fd, cs.buf, sizeof(cs.buf), 0);
                if cs.buf_n<=0 then
                begin
                  socket_disconnect(proxy,current_fd,display);
                  refresh_setup_window(display,proxy);
                end
                else // got some data from client
                begin
                  synch:=false;
                  if (fd_isset(proxy.host_fd, proxy.socket_fds)) then
                    if (send(proxy.host_fd, cs.buf, cs.buf_n, 0) = SOCKET_ERROR) then sock_error(proxy,'send()',display);
                  process_client_state(cs);
                end;
              end;
            src_visitor: // handle data from a visitor
              begin
                if proxy.visitor_lock then
                begin
                  vs.buf_n:=recv(current_fd, vs.buf, sizeof(vs.buf), 0);
                  if vs.buf_n<=0 then
                  begin
                    socket_disconnect(proxy,current_fd,display);
                    refresh_setup_window(display,proxy);
                  end
                end
                else
                begin
                  cs.buf_n:=recv(current_fd, cs.buf, sizeof(cs.buf), 0);
                  if cs.buf_n<=0 then
                  begin
                    socket_disconnect(proxy,current_fd,display);
                    refresh_setup_window(display,proxy);
                  end
                  else // got some data from client
                  begin
                    synch:=false;
                    if (fd_isset(proxy.host_fd, proxy.socket_fds)) then
                      if (send(proxy.host_fd, cs.buf, cs.buf_n, 0) = SOCKET_ERROR) then sock_error(proxy,'send()',display);
                    process_client_state(cs);
                  end;
                end;
              end;
          end; //case
        end; //if
      end; //for
    end; //if
    while keypressed do
      menuparse(menu,readkey,display,proxy);
  end; //while

  display_window(display,WINDOW_PROXYMSGS);
  proxy_shutdown(proxy,display);
  display_window(display,WINDOW_FULL);
end;

begin
  main();
end.
