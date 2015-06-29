unit Pipe;

interface

uses windows, AGTHConst;

type
  TOnReceiveEvent = procedure(hPipe: THandle; const Data: TAGTHRcPckt)
    of object;

  TPipe = class
  private
    FInitialized: boolean;
    FOverLapRd: TOverlapped;
    FOnReceive: TOnReceiveEvent;
    DataBuf: TAGTHRcPckt;
    IOPending: boolean;
    function Init: boolean;
    function GetOverLapRd: POverlapped;
    procedure DoReceive;
    procedure ClearBuffer;
  public
    hPipe: THandle;
    WaitEvent: THandle;
    constructor Create;
    destructor Destroy; override;
    function Read: boolean;
    property OnReceive: TOnReceiveEvent read FOnReceive write FOnReceive;
  end;

implementation

{ TPipe }

procedure TPipe.ClearBuffer;
begin
  FillChar(DataBuf, Sizeof(TAGTHRcPckt), 0);
  IOPending := false;
end;

constructor TPipe.Create;
begin
  FOnReceive := nil;
  FInitialized := Init;
end;

destructor TPipe.Destroy;
begin
  if FInitialized then
  begin
    if WaitEvent <> INVALID_HANDLE_VALUE then
      CloseHandle(WaitEvent);

    if hPipe <> INVALID_HANDLE_VALUE then
      CloseHandle(hPipe);
  end;

  inherited;
end;

procedure TPipe.DoReceive;
begin
  if Assigned(FOnReceive) then
    FOnReceive(hPipe, DataBuf);
end;

function TPipe.GetOverLapRd: POverlapped;
begin
  FillChar(FOverLapRd, Sizeof(TOverlapped), 0);
  FOverLapRd.hEvent := WaitEvent;
  Result := @FOverLapRd;
end;

function TPipe.Init: boolean;
var
  OverLapRd: TOverlapped;
begin
  hPipe := CreateNamedPipeW(AGTH_PIPE_NAME, AGTH_PIPE_OPEN_MODE, AGTH_PIPE_MODE,
    MAXIMUM_WAIT_OBJECTS - 1, 0, AGTH_IN_BUFFER_SIZE, 0, nil);

  if hPipe = INVALID_HANDLE_VALUE then
  begin
    Result := false;
    exit;
  end;

  FillChar(OverLapRd, Sizeof(TOverlapped), 0);
  OverLapRd.hEvent := CreateEventW(nil, true, false, nil);
  ConnectNamedPipe(hPipe, @OverLapRd);
  WaitEvent := OverLapRd.hEvent;

  ClearBuffer;

  Result := true;
end;

function TPipe.Read: boolean;
var
  fSuccess: boolean;
  BytesRead: Cardinal;
begin
  if IOPending then
    DoReceive;

  ClearBuffer;

  fSuccess := ReadFile(hPipe, DataBuf, Sizeof(TAGTHRcPckt), BytesRead,
    GetOverLapRd);

  if ((not fSuccess) or (BytesRead = 0)) then
  begin
    if GetLastError = ERROR_IO_PENDING then
    begin
      IOPending := true;
      Result := true; // ждем завершени€ операции
    end
    else
      Result := false; // Ёкземпл€р канала сломалс€, завершаем обслуживание.
  end
  else
  begin
    DoReceive;
    Result := true;
  end;
end;

end.
