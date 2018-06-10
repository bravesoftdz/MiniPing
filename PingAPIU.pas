unit PingAPIU;

interface

uses
  Windows, WinSock2, SysUtils;

{$REGION 'GetAddrInfo'}
type
  ULONG_PTR = NativeUInt;
  SIZE_T = ULONG_PTR;

  TIN6_ADDR = record
    s6_bytes: array[0..15] of u_char;
    {
    case Integer of
      0: (s6_bytes: array[0..15] of u_char);
      1: (s6_words: array[0..7] of u_short);   }
  end;

  sockaddr_in6 = record
    sin6_family: Smallint;
    sin6_port: u_short;
    sin6_flowinfo: u_long;
    sin6_addr : TIN6_ADDR;
    sin6_scope_id: u_long;
  end;
  TSockAddrIn6 = sockaddr_in6;
  PSockAddrIn6 = ^sockaddr_in6;

  PAddrInfoW = ^ADDRINFOW;
  ADDRINFOW = record
    ai_flags        : Integer;      // AI_PASSIVE, AI_CANONNAME, AI_NUMERICHOST
    ai_family       : Integer;      // PF_xxx
    ai_socktype     : Integer;      // SOCK_xxx
    ai_protocol     : Integer;      // 0 or IPPROTO_xxx for IPv4 and IPv6
    ai_addrlen      : size_t;        // Length of ai_addr
    ai_canonname    : PWideChar;    // Canonical name for nodename
    ai_addr         : PSockAddrIn;    // Binary address
    ai_next         : PAddrInfoW;   // Next structure in linked list
  end;
  TAddrInfoW = ADDRINFOW;
  LPADDRINFOW = PAddrInfoW;



function GetAddrInfoW(const nodename: PWideChar; const servname : PWideChar; const hints: PAddrInfoW; var res: PaddrinfoW): Integer; stdcall; external 'ws2_32.dll';
procedure FreeAddrInfoW(ai: PAddrInfoW); stdcall; external 'ws2_32.dll';

{§ENDREGION}

{$REGION 'ICMP related functions and types'}

type
  PIPOptionInformation = ^TIPOptionInformation;

  TIPOptionInformation = record
    Ttl: Byte; // time to live
    Tos: Byte; // type of service
    Flags: Byte; // ip header flags
    OptionsSize: Byte; // size in bytes of options data
    OptionsData: ^Byte; // pointer to options data
  end;

  ICMP_ECHO_REPLY = record
    Address: in_addr; // replying address
    Status: ULONG; // reply ip_status
    RoundTripTime: ULONG; // rtt in milliseconds
    DataSize: ULONG; // reply data size in bytes
    Reserved: ULONG; // reserved for system use
    Data: Pointer; // pointer to the reply data
    Options: PIPOptionInformation; // reply options
  end;

  PICMP_ECHO_REPLY = ^ICMP_ECHO_REPLY;

function IcmpCreateFile: THandle; stdcall; external 'icmp.dll';
function IcmpCloseHandle(icmpHandle: THandle): Boolean; stdcall; external 'icmp.dll';
function IcmpSendEcho(icmpHandle: THandle; DestinationAddress: in_addr; RequestData: Pointer; RequestSize: Word; RequestOptions: PIPOptionInformation; ReplyBuffer: Pointer; ReplySize: DWORD; Timeout: DWORD): DWORD; stdcall; external 'icmp.dll';

{$ENDREGION}

{$REGION 'ICMP6 related constants, functions and types'}

const
  ICMP_ECHO = 8;
  ICMP_ECHOREPLY = 0;
  ICMP_UNREACH = 3;
  ICMP_TIME_EXCEEDED = 11;
  // rfc-2292
  ICMP6_ECHO = 128;
  ICMP6_ECHOREPLY = 129;
  ICMP6_UNREACH = 1;
  ICMP6_TIME_EXCEEDED = 3;

  AI_CANONNAME = 2;
  AI_NUMERICHOST = 4;

type
  TIP_OPTION_INFORMATION = record
    Ttl: Byte;
    Tos: Byte;
    Flags: Byte;
    OptionsSize: Byte;
    OptionsData: PAnsiChar;
  end;

  PIP_OPTION_INFORMATION = ^TIP_OPTION_INFORMATION;

  TICMPV6_ECHO_REPLY = record
    Address: TSockAddrIn6;
    Status: Integer;
    RoundTripTime: Integer;
  end;

  PICMPV6_ECHO_REPLY = ^TICMPV6_ECHO_REPLY;

function Icmp6CreateFile: Integer; stdcall; external 'iphlpapi.dll';
function Icmp6SendEcho2(handle: Integer; Event: Pointer; ApcRoutine: Pointer; ApcContext: Pointer; SourceAddress: PSockAddrIn6; DestinationAddress: PSockAddrIn6; RequestData: Pointer; RequestSize: Integer; RequestOptions: PIP_OPTION_INFORMATION; ReplyBuffer: Pointer; ReplySize: Integer; Timeout: Integer): Integer; stdcall; external 'iphlpapi.dll';

{$ENDREGION}

function GetHumanAddress(addr: PSockAddr; const addrlen: NativeUInt): String;

implementation

const
  NI_MAXHOST  = 1025;      // Max size of a fully-qualified domain name.
  NI_NUMERICHOST  =   $2  ;  // Return numeric form of the host's address.

function GetNameInfoW(pSockaddr: PSockAddr; SockaddrLength: Integer; host: PWideChar; hostlen: u_int; serv: PWideChar; servlen: u_int; flags: Integer): Integer; stdcall; external 'Ws2_32.dll';


function GetHumanAddress(addr: PSockAddr; const addrlen: NativeUInt): String;
var
  ClientHost: array[0..NI_MAXHOST-1] of Char;
begin
  GetNameInfoW(addr, addrlen, ClientHost, NI_MAXHOST, nil, 0, NI_NUMERICHOST);
  Result := ClientHost;
end;

end.
