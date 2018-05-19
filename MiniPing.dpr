program MiniPing;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  Windows,
  PingU in 'PingU.pas';

var
  argc: Integer;
  Host: String;
  Line: String;

procedure ShowUsage();
begin
  Writeln('MiniPing - A minimal ping program');
  Writeln('');
  Writeln('ExitCodes:');
  Writeln('  0: Host is reachable');
  Writeln('  1: Host is not reachable');
  Writeln('  2: Could not send ping probe');
  Writeln('  3: Could not resolve address');
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

    ExitCode := PingU.Ping(Host, Line);
    Write(Line);
  end;

{$IFDEF DEBUG}
  Readln;
{$ENDIF}

end.
