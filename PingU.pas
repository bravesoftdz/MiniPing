unit PingU;

interface

uses
  Windows, WinSock2, SysUtils, PingAPIU;

function Ping(const Host: string; out ResultLine: String): Integer;

implementation

{$REGION 'Host + IP to Internal representation'}

type
  TIPFormat = (UNSPEC, IPv4, IPv6);

  TLookupResult = record
    Format: TIPFormat;
    HumanReadable: string;
    case Integer of
      0:
        (addr: sockaddr);
      1:
        (addr4: sockaddr_in);
      2:
        (addr6: sockaddr_in6);
  end;

function LookupIP(const Hostname: string): TLookupResult;
var
  Hints: ADDRINFOW;
  addrinfo: PAddrInfoW;
begin
  // Lowest amount of hints possible...
  ZeroMemory(@Hints, sizeof(Hints));
  // Since there is no IPv6 support downstream, force IPv4
  Hints.ai_family := AF_INET;
  Hints.ai_socktype := SOCK_STREAM;
  Hints.ai_protocol := IPPROTO_ICMP;

  if (GetAddrInfoW(PChar(Hostname), nil, @Hints, addrinfo) <> 0) then
  begin
    RaiseLastOSError();
    Exit;
  end;

  // Only take the first one
  case addrinfo.ai_family of
    AF_UNSPEC:
      begin
        Result.Format := UNSPEC;
      end;
    AF_INET:
      begin
        Result.Format := IPv4;
        Result.HumanReadable := GetHumanAddress(sockaddr(addrinfo.ai_addr^), addrinfo.ai_addrlen);
        Result.addr4 := addrinfo.ai_addr^;
      end;
    AF_INET6:
      begin
        Result.Format := IPv6;
        Result.HumanReadable := GetHumanAddress(sockaddr(addrinfo.ai_addr^), addrinfo.ai_addrlen);
        Result.addr4 := addrinfo.ai_addr^;
      end;
  end;

  // Clean up
  FreeAddrInfoW(addrinfo);
end;

{$ENDREGION}
{$REGION 'Error Messages' }

const
  IP_STATUS_BASE = 11000;
  IP_SUCCESS = 0;
  IP_BUF_TOO_SMALL = IP_STATUS_BASE + 1;
  IP_DEST_NET_UNREACHABLE = IP_STATUS_BASE + 2;
  IP_DEST_HOST_UNREACHABLE = IP_STATUS_BASE + 3;
  IP_DEST_PROT_UNREACHABLE = IP_STATUS_BASE + 4;
  IP_DEST_PORT_UNREACHABLE = IP_STATUS_BASE + 5;
  IP_NO_RESOURCES = IP_STATUS_BASE + 6;
  IP_BAD_OPTION = IP_STATUS_BASE + 7;
  IP_HW_ERROR = IP_STATUS_BASE + 8;
  IP_PACKET_TOO_BIG = IP_STATUS_BASE + 9;
  IP_REQ_TIMED_OUT = IP_STATUS_BASE + 10;
  IP_BAD_REQ = IP_STATUS_BASE + 11;
  IP_BAD_ROUTE = IP_STATUS_BASE + 12;
  IP_TTL_EXPIRED_TRANSIT = IP_STATUS_BASE + 13;
  IP_TTL_EXPIRED_REASSEM = IP_STATUS_BASE + 14;
  IP_PARAM_PROBLEM = IP_STATUS_BASE + 15;
  IP_SOURCE_QUENCH = IP_STATUS_BASE + 16;
  IP_OPTION_TOO_BIG = IP_STATUS_BASE + 17;
  IP_BAD_DESTINATION = IP_STATUS_BASE + 18;
  IP_GENERAL_FAILURE = IP_STATUS_BASE + 50;

function ErrorToText(const ErrorCode: Integer): String;
begin
  case ErrorCode of
    IP_BUF_TOO_SMALL:
      Result := 'IP_BUF_TOO_SMALL';
    IP_DEST_NET_UNREACHABLE:
      Result := 'IP_DEST_NET_UNREACHABLE';
    IP_DEST_HOST_UNREACHABLE:
      Result := 'IP_DEST_HOST_UNREACHABLE';
    IP_DEST_PROT_UNREACHABLE:
      Result := 'IP_DEST_PROT_UNREACHABLE';
    IP_DEST_PORT_UNREACHABLE:
      Result := 'IP_DEST_PORT_UNREACHABLE';
    IP_NO_RESOURCES:
      Result := 'IP_NO_RESOURCES';
    IP_BAD_OPTION:
      Result := 'IP_BAD_OPTION';
    IP_HW_ERROR:
      Result := 'IP_HW_ERROR';
    IP_PACKET_TOO_BIG:
      Result := 'IP_PACKET_TOO_BIG';
    IP_REQ_TIMED_OUT:
      Result := 'IP_REQ_TIMED_OUT';
    IP_BAD_REQ:
      Result := 'IP_BAD_REQ';
    IP_BAD_ROUTE:
      Result := 'IP_BAD_ROUTE';
    IP_TTL_EXPIRED_TRANSIT:
      Result := 'IP_TTL_EXPIRED_TRANSIT';
    IP_TTL_EXPIRED_REASSEM:
      Result := 'IP_TTL_EXPIRED_REASSEM';
    IP_PARAM_PROBLEM:
      Result := 'IP_PARAM_PROBLEM';
    IP_SOURCE_QUENCH:
      Result := 'IP_SOURCE_QUENCH';
    IP_OPTION_TOO_BIG:
      Result := 'IP_OPTION_TOO_BIG';
    IP_BAD_DESTINATION:
      Result := 'IP_BAD_DESTINATION';
    IP_GENERAL_FAILURE:
      Result := 'IP_GENERAL_FAILURE';

  else
    Result := 'Unknown Error';
  end;
end;

{$ENDREGION}

function Ping(const Host: string; out ResultLine: String): Integer;
var
  ICMPFile: THandle;
  SendData: array [0 .. 31] of AnsiChar;
  ReplyBuffer: PICMP_ECHO_REPLY;
  ReplySize: DWORD;
  NumResponses: DWORD;
  Lookup: TLookupResult;
begin
  Result := 3;
  SendData := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  Lookup := LookupIP(Host);

  if Lookup.Format = IPv4 then
  begin
    ICMPFile := IcmpCreateFile;
    if ICMPFile <> INVALID_HANDLE_VALUE then
      try
        ReplySize := sizeof(ICMP_ECHO_REPLY) + sizeof(SendData);
        GetMem(ReplyBuffer, ReplySize);
        try
          NumResponses := IcmpSendEcho(ICMPFile, Lookup.addr4.sin_addr, @SendData, sizeof(SendData), nil, ReplyBuffer, ReplySize, 1000);
          if (NumResponses <> 0) then
          begin
            ResultLine := 'Received Response in ' + IntToStr(ReplyBuffer.RoundTripTime) + ' ms';
            Result := 0;
          end
          else
          begin
            ResultLine := 'Error: ' + ErrorToText(GetLastError());
            Result := 1;
          end;
        finally
          FreeMem(ReplyBuffer);
        end;
      finally
        IcmpCloseHandle(ICMPFile);
      end
    else
    begin
      RaiseLastOSError();
    end;
  end;
end;

end.
