unit AGTHConst;

interface

uses Windows;

type
  TAGTHMessage = packed record // SizeOf = 8168 bytes
    Context: Cardinal;
    Subcontext: Cardinal;
    ProcessID: Cardinal;
    UpTime: Cardinal;
    TextLength: Cardinal;
    HookName: array [0 .. 23] of AnsiChar;
    // не уверен насчёт последних 2(3) символов
    Text: array [0 .. 4061] of WideChar;
  end;

  PAGTHRcPckt = ^TAGTHMessage;

const
  AGTH_PIPE_NAME: PWideChar = '\\.\pipe\agth';
  AGTH_PIPE_OPEN_MODE: Cardinal = PIPE_ACCESS_INBOUND or FILE_FLAG_OVERLAPPED;

  AGTH_PIPE_MODE: Cardinal = PIPE_WAIT or PIPE_READMODE_MESSAGE or
    PIPE_TYPE_MESSAGE;

  AGTH_IN_BUFFER_SIZE: Cardinal = $20000;

implementation

end.
