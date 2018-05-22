program MiniPing;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  Windows, WinSock2, SysUtils,
  PingU in 'PingU.pas',
  PingAPIU in 'PingAPIU.pas';

var
  argc: Integer;
  Host: String;
  Line: String;
  WSADATA: TWSAData;

procedure ShowUsage();
begin
  Writeln('MiniPing - A minimal ping program');
  Writeln('');
  Writeln('ExitCodes:');
  Writeln('  0: Host is reachable');
  Writeln('  1: Host is not reachable');
  Writeln('  2: An exception occured');
  Writeln('');
end;

begin
  argc := ParamCount();

  if (argc <> 1) then
  begin
    ShowUsage();
    ExitCode := 128;
  end
  else
  begin
    // Get Host
    Host := ParamStr(1);

    // Initialize WSA for use wich ICMP
    WSAStartup(MAKEWORD(2, 2), WSADATA);

    try
      ExitCode := PingU.Ping(Host, Line);
      Write(Line);
    except
      on E: Exception do
      begin
        Writeln('Exception: ' + E.Message + ' (' + E.ClassName + ')');
        ExitCode := 2;
      end;
    end;

    WSACleanup();

  end;

{$IFDEF DEBUG}
  Readln;
{$ENDIF}

end.
