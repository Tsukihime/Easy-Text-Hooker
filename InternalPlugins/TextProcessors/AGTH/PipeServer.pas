unit PipeServer;

interface

uses Classes, Windows, System.Generics.Collections,
  //
  AGTHConst;

type
  TPipeState = class
  public
    Initialized: boolean;
    Overlapped: TOverlapped;
    DataBuffer: TAGTHMessage;
    IOPending: boolean;
    hPipe: THandle;
    WaitEvent: THandle;
  public
    constructor Create;
  end;

  TOnReceiveEvent = procedure(Data: TAGTHMessage) of object;

  TPipeServer = class(TThread)
  private
    FOnReceiveHandlers: TList<TOnReceiveEvent>;
    LastUpdateTime: Cardinal;

    procedure DoConnect(const Pipe: TPipeState);
    procedure DoDisconnect(const Pipe: TPipeState);
    procedure DoReceive(const Pipe: TPipeState);
    procedure DoConnectionLimitReached;
    procedure SyncQueue;
    procedure UpdateQueue;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure OnReceiveSubscribe(OnReceive: TOnReceiveEvent);
    procedure OnReceiveUnsubscribe(OnReceive: TOnReceiveEvent);
  private
    Pipes: TObjectList<TPipeState>;
    PacketQueue: TQueue<TAGTHMessage>;

    function NewIncomingPipeState: TPipeState;
    procedure FreePipeState(const PipeState: TPipeState);
    function PipeRead(const PipeState: TPipeState): boolean;
    procedure ClosePipe(const Pipe: TPipeState);
  end;

  IPipeServer = interface
    procedure OnReceiveSubscribe(OnReceive: TOnReceiveEvent);
    procedure OnReceiveUnsubscribe(OnReceive: TOnReceiveEvent);
  end;

  TPipeServerSingleton = class(TInterfacedObject, IPipeServer)
  private
    class var FSingleton: TPipeServerSingleton;
  private
    FPipeServer: TPipeServer;
    property PipeServer: TPipeServer read FPipeServer implements IPipeServer;
  public
    class function GetInstatnce: IPipeServer;
    constructor Create;
    destructor Destroy; override;
  end;

const
  QueueUpdateInterval = 30;
  ConnectionLimit = MAXIMUM_WAIT_OBJECTS;
  IncomingPipeIndex = 0;

implementation

uses
  SysUtils;

{ TPipeState }

constructor TPipeState.Create;
begin
  Initialized := false;
  Overlapped := Default (TOverlapped);
  DataBuffer := Default (TAGTHMessage);
  IOPending := false;
  hPipe := INVALID_HANDLE_VALUE;
  WaitEvent := INVALID_HANDLE_VALUE;
end;

{ TPipeServer }

constructor TPipeServer.Create;
begin
  inherited Create(true);
  Pipes := TObjectList<TPipeState>.Create;
  PacketQueue := TQueue<TAGTHMessage>.Create;
  LastUpdateTime := GetTickCount;
  FOnReceiveHandlers := TList<TOnReceiveEvent>.Create;
end;

destructor TPipeServer.Destroy;
var
  Pipe: TPipeState;
begin
  Terminate;
  WaitFor;

  for Pipe in Pipes do
    FreePipeState(Pipe);
  Pipes.Free;

  PacketQueue.Free;
  FOnReceiveHandlers.Free;
  inherited;
end;

procedure TPipeServer.DoConnect(const Pipe: TPipeState);
begin
  //
end;

procedure TPipeServer.DoConnectionLimitReached;
begin
  //
end;

procedure TPipeServer.DoDisconnect(const Pipe: TPipeState);
begin
  //
end;

procedure TPipeServer.DoReceive(const Pipe: TPipeState);
begin
  PacketQueue.Enqueue(Pipe.DataBuffer);
end;

procedure TPipeServer.UpdateQueue;
begin
  if abs(GetTickCount - LastUpdateTime) > QueueUpdateInterval then
  begin
    if PacketQueue.Count > 0 then
      Synchronize(SyncQueue);
    LastUpdateTime := GetTickCount;
  end;
end;

procedure TPipeServer.SyncQueue; // main tread context
var
  OnReceive: TOnReceiveEvent;
  packet: TAGTHMessage;
begin
  while PacketQueue.Count > 0 do
  begin
    // don't worry about PacketQueue, at this point owner thread is paused
    packet := PacketQueue.Dequeue;

    for OnReceive in FOnReceiveHandlers do
      OnReceive(packet);
  end;
end;

procedure TPipeServer.Execute;

  function SearchPipe(Event: THandle): TPipeState;
  var
    Pipe: TPipeState;
  begin
    Result := nil;
    for Pipe in Pipes do
      if Pipe.WaitEvent = Event then
      begin
        Result := Pipe;
        break;
      end;
  end;

var
  WaitResult: Cardinal;
  WaitEvents: TWOHandleArray;
  Pipe: TPipeState;
  IncomingPipe: TPipeState;
  i: Integer;
begin
  IncomingPipe := NewIncomingPipeState;
  Pipes.Insert(IncomingPipeIndex, IncomingPipe);

  while not Terminated do
  begin
    for i := 0 to Pipes.Count - 1 do
      WaitEvents[i] := Pipes[i].WaitEvent;

    WaitResult := WaitForMultipleObjects(Pipes.Count, @WaitEvents, false,
      QueueUpdateInterval);

    case WaitResult of
      WAIT_OBJECT_0: // incoming connection
        begin
          if not(Pipes.Count = ConnectionLimit) then
            DoConnect(IncomingPipe);

          if not PipeRead(IncomingPipe) then
            ClosePipe(IncomingPipe);

          // new incoming pipe
          if not(Pipes.Count = ConnectionLimit) then
          begin
            IncomingPipe := NewIncomingPipeState;
            Pipes.Insert(IncomingPipeIndex, IncomingPipe);
          end;

          if Pipes.Count = ConnectionLimit then
            DoConnectionLimitReached;
        end;

      WAIT_OBJECT_0 + 1 .. WAIT_OBJECT_0 + MAXIMUM_WAIT_OBJECTS - 1:
        // Data received
        begin
          Pipe := SearchPipe(WaitEvents[WaitResult - WAIT_OBJECT_0]);
          if not PipeRead(Pipe) then
            ClosePipe(Pipe);
        end;

      WAIT_ABANDONED_0 + 1 .. WAIT_ABANDONED_0 + MAXIMUM_WAIT_OBJECTS - 1:
        // Pipe break
        begin
          Pipe := SearchPipe(WaitEvents[WaitResult - WAIT_ABANDONED_0]);
          ClosePipe(Pipe);
        end;

      WAIT_TIMEOUT:
        ; // pass down

      WAIT_FAILED:
        // lol wut?
        begin
          Assert(false, 'TPipeServer.Execute: WAIT_FAILED');
        end;
    end;
    UpdateQueue;
  end;
end;

function TPipeServer.NewIncomingPipeState: TPipeState;
begin
  Result := TPipeState.Create;

  Result.hPipe := CreateNamedPipeW(AGTH_PIPE_NAME, AGTH_PIPE_OPEN_MODE,
    AGTH_PIPE_MODE, MAXIMUM_WAIT_OBJECTS - 1, 0, AGTH_IN_BUFFER_SIZE, 0, nil);

  if Result.hPipe = INVALID_HANDLE_VALUE then
  begin
    Result.Initialized := false;
    exit;
  end;

  Result.WaitEvent := CreateEventW(nil, true, false, nil);
  Result.Overlapped.hEvent := Result.WaitEvent;
  ConnectNamedPipe(Result.hPipe, @Result.Overlapped);

  Result.IOPending := false;
  Result.Initialized := true;
end;

procedure TPipeServer.FreePipeState(const PipeState: TPipeState);
begin
  if not PipeState.Initialized then
    exit;

  if PipeState.WaitEvent <> INVALID_HANDLE_VALUE then
    CloseHandle(PipeState.WaitEvent);

  if PipeState.hPipe <> INVALID_HANDLE_VALUE then
    CloseHandle(PipeState.hPipe);
end;

function TPipeServer.PipeRead(const PipeState: TPipeState): boolean;
var
  fSuccess: boolean;
  BytesRead: Cardinal;
begin
  if PipeState.IOPending then
    DoReceive(PipeState);

  PipeState.IOPending := false;
  PipeState.Overlapped := Default (TOverlapped);
  PipeState.Overlapped.hEvent := PipeState.WaitEvent;

  fSuccess := ReadFile(PipeState.hPipe, PipeState.DataBuffer,
    Sizeof(TAGTHMessage), BytesRead, @PipeState.Overlapped);

  if ((not fSuccess) or (BytesRead = 0)) then
  begin
    if GetLastError = ERROR_IO_PENDING then
    begin
      PipeState.IOPending := true;
      Result := true; // ждем завершения операции
    end
    else
      Result := false; // Экземпляр сломался, завершаем обслуживание.
  end
  else
  begin // пришли данные
    DoReceive(PipeState);
    Result := true;
  end;
end;

procedure TPipeServer.ClosePipe(const Pipe: TPipeState);
begin
  DoDisconnect(Pipe);
  FreePipeState(Pipe);
  Pipes.Remove(Pipe);
end;

procedure TPipeServer.OnReceiveSubscribe(OnReceive: TOnReceiveEvent);
begin
  FOnReceiveHandlers.Add(OnReceive);
end;

procedure TPipeServer.OnReceiveUnsubscribe(OnReceive: TOnReceiveEvent);
begin
  FOnReceiveHandlers.Remove(OnReceive);
end;

{ TPipeServerSingleton }

constructor TPipeServerSingleton.Create;
begin
  FPipeServer := TPipeServer.Create;
  FPipeServer.Start;
end;

destructor TPipeServerSingleton.Destroy;
begin
  FreeAndNil(FPipeServer);
  FSingleton := nil;
  inherited;
end;

class function TPipeServerSingleton.GetInstatnce: IPipeServer;
begin
  if not Assigned(FSingleton) then
    FSingleton := TPipeServerSingleton.Create;
  Result := FSingleton;
end;

end.
