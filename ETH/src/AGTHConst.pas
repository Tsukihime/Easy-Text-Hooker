unit AGTHConst;

interface

uses Windows;

type
  TAGTHRcPckt = packed record // SizeOf = 8168 bytes
    Context: Cardinal;
    Subcontext: Cardinal;
    ProcessID: Cardinal;
    UpTime: Cardinal;
    TextLength: Cardinal;
    HookName: array [0 .. 23] of ansichar;
    // Ñ~Ñu ÑÖÑrÑuÑÇÑuÑ~ Ñ~ÑpÑÉÑâÑuÑÑ ÑÅÑÄÑÉÑ|ÑuÑtÑ~ÑyÑá 2(3) ÑÉÑyÑ}ÑrÑÄÑ|ÑÄÑr
    Text: array [0 .. 4061] of widechar;
  end;

  PAGTHRcPckt = ^TAGTHRcPckt;

const
  AGTH_PIPE_NAME: PWideChar = '\\.\pipe\agth';
  AGTH_PIPE_OPEN_MODE: Cardinal = PIPE_ACCESS_INBOUND or FILE_FLAG_OVERLAPPED;

  AGTH_PIPE_MODE: Cardinal = PIPE_WAIT or PIPE_READMODE_MESSAGE or
    PIPE_TYPE_MESSAGE;

  AGTH_IN_BUFFER_SIZE: Cardinal = $20000;

implementation

end.
