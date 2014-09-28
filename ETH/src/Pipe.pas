unit Pipe;

interface

uses windows, AGTHConst;

type

  TPipe = class
  private
    FInitialized: boolean;
    FOverLapRd: TOverlapped;
    function Init: boolean;
    function GetOverLapRd: POverlapped;
  public
    Pipe: THandle;
    Data: TAGTHRcPckt;
    IOPending: boolean;
    WaitEvent: THandle;
    property OverLapRd: POverlapped read GetOverLapRd;
  public
    procedure ClearBuffer;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TPipe }

procedure TPipe.ClearBuffer;
begin
  FillChar(Data, Sizeof(TAGTHRcPckt), 0);
  IOPending := false;
end;

constructor TPipe.Create;
begin
  FInitialized := Init();
end;

destructor TPipe.Destroy;
begin
  if FInitialized then
  begin
    if WaitEvent <> INVALID_HANDLE_VALUE then
      CloseHandle(WaitEvent);

    if Pipe <> INVALID_HANDLE_VALUE then
      CloseHandle(Pipe);
  end;

  inherited;
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
  if FInitialized then
  begin
    Result := true;
    exit;
  end;

  Pipe := CreateNamedPipeW(AGTH_PIPE_NAME, AGTH_PIPE_OPEN_MODE, AGTH_PIPE_MODE,
    MAXIMUM_WAIT_OBJECTS - 1, 0, AGTH_IN_BUFFER_SIZE, 0, nil);

  if Pipe = INVALID_HANDLE_VALUE then
  begin
    Result := false;
    exit;
  end;

  FillChar(OverLapRd, Sizeof(TOverlapped), 0);
  OverLapRd.hEvent := CreateEventW(nil, true, false, nil);
  ConnectNamedPipe(Pipe, @OverLapRd);
  WaitEvent := OverLapRd.hEvent;

  ClearBuffer();

  Result := true;
end;

end.
