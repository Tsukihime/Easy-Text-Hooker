unit PipeServer;

interface

uses Classes, Windows, System.Generics.Collections,
  //
  Pipe, AGTHConst;

type
  TWOHandles = array [0 .. MAXIMUM_WAIT_OBJECTS - 1] of THandle;

  TOnConnectEvent = procedure(hPipe: THandle) of object;
  TOnDisconnectEvent = procedure(hPipe: THandle) of object;
  TOnReceiveEvent = procedure(hPipe: THandle; Data: TAGTHRcPckt) of object;

  TPipeServer = class(TThread)
  private
    FOnConnect: TOnConnectEvent;
    FOnReceive: TOnReceiveEvent;
    FOnDisconnect: TOnDisconnectEvent;

    LastUpdateTime: Cardinal;
    PcktBuffer: TThreadList;

    procedure DoConnect(hPipe: THandle);
    procedure DoDisconnect(hPipe: THandle);
    procedure DoReceive(hPipe: THandle; const Data: TAGTHRcPckt);
    procedure SyncQueue;
    procedure UpdateQueue;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
  public
    property OnConnect: TOnConnectEvent read FOnConnect write FOnConnect;
    property OnDisconnect: TOnDisconnectEvent read FOnDisconnect
      write FOnDisconnect;
    property OnReceive: TOnReceiveEvent read FOnReceive write FOnReceive;
  private
    IncomingPipe: TPipe;
    Pipes: TObjectList<TPipe>;

    function FillWOArray(var WOArr: TWOHandles): Cardinal;
    function FindPipe(ev: THandle; var Pipe: TPipe): boolean;
    procedure ClosePipe(Pipe: TPipe);
  end;

  TSyncPckt = packed record
    hPipe: THandle;
    Data: TAGTHRcPckt;
  end;

  PSyncPckt = ^TSyncPckt;

const
  QueueUpdateInterval = 30;

implementation

{ TPipeServer }

constructor TPipeServer.Create;
begin
  inherited Create(true);
  Pipes := TObjectList<TPipe>.Create(true);
  IncomingPipe := nil;
  LastUpdateTime := GetTickCount;
  PcktBuffer := TThreadList.Create;

  FOnConnect := nil;
  FOnReceive := nil;
  FOnDisconnect := nil;
end;

destructor TPipeServer.Destroy;
begin
  Terminate;
  WaitForSingleObject(Self.Handle, 2000);

  Pipes.Free;
  if Assigned(IncomingPipe) then
    IncomingPipe.Free;

  SyncQueue; // from main tread for clear queue
  PcktBuffer.Free;

  inherited;
end;

procedure TPipeServer.DoConnect(hPipe: THandle);
begin
  Synchronize(
    procedure
    begin
      if Assigned(FOnConnect) then
        FOnConnect(hPipe);
    end);
end;

procedure TPipeServer.DoDisconnect(hPipe: THandle);
begin
  Synchronize(
    procedure
    begin
      if Assigned(FOnDisconnect) then
        FOnDisconnect(hPipe);
    end);
end;

procedure TPipeServer.DoReceive(hPipe: THandle; const Data: TAGTHRcPckt);
var
  pckt: PSyncPckt;
begin
  pckt := GetMemory(SizeOf(TSyncPckt));
  Assert(pckt <> nil, 'TPipeServer.DoReceive: Memory allocation failed!');
  pckt.hPipe := hPipe;
  pckt.Data := Data;
  PcktBuffer.Add(pckt);
end;

procedure TPipeServer.UpdateQueue;
var
  cnt: Integer;
begin
  if GetTickCount - LastUpdateTime > QueueUpdateInterval then
  begin
    cnt := PcktBuffer.LockList.Count;
    PcktBuffer.UnlockList;
    if cnt > 0 then
      Synchronize(SyncQueue);
    LastUpdateTime := GetTickCount;
  end;
end;

procedure TPipeServer.SyncQueue; // main tread context
var
  lst: TList;
  pckt: PSyncPckt;
begin
  lst := PcktBuffer.LockList;
  try
    while lst.Count > 0 do
    begin
      pckt := lst.First;
      lst.Extract(pckt);

      Assert(pckt <> nil, 'TPipeServer.SyncQueue: pckt == nil');
      if Assigned(FOnReceive) then
        FOnReceive(pckt.hPipe, pckt.Data);
      FreeMemory(pckt);
    end;
  finally
    PcktBuffer.UnlockList;
  end;
end;

function TPipeServer.FillWOArray(var WOArr: TWOHandles): Cardinal;
var
  i, psz: Integer;
begin
  psz := Pipes.Count;
  if psz > MAXIMUM_WAIT_OBJECTS - 1 then
    psz := MAXIMUM_WAIT_OBJECTS - 1;

  WOArr[0] := IncomingPipe.WaitEvent;

  for i := 0 to psz - 1 do
    WOArr[i + 1] := Pipes[i].WaitEvent;

  Result := psz + 1;
end;

function TPipeServer.FindPipe(ev: THandle; var Pipe: TPipe): boolean;
var
  i: Integer;
begin
  Result := false;
  for i := 0 to Pipes.Count - 1 do
    if Pipes[i].WaitEvent = ev then
    begin
      Pipe := Pipes[i];
      Result := true;
      break;
    end;
end;

procedure TPipeServer.ClosePipe(Pipe: TPipe);
begin
  Pipes.Extract(Pipe);
  DoDisconnect(Pipe.hPipe);
  Pipe.Free;
end;

procedure TPipeServer.Execute;
var
  WaitResult: Cardinal;
  WaitEvents: TWOHandles;
  nCount: Cardinal;
  WOIndex: Cardinal;
  ev: THandle;
  Pipe: TPipe;
begin
  IncomingPipe := TPipe.Create;
  IncomingPipe.OnReceive := DoReceive;

  while not Terminated do
  begin
    nCount := FillWOArray(WaitEvents);
    WaitResult := WaitForMultipleObjects(nCount, @WaitEvents, false,
      QueueUpdateInterval);

    case WaitResult of
      WAIT_OBJECT_0:
        begin // incoming connection
          DoConnect(IncomingPipe.hPipe);

          Pipes.Add(IncomingPipe);
          IncomingPipe.Read;

          IncomingPipe := TPipe.Create;
          IncomingPipe.OnReceive := DoReceive;
        end;

      WAIT_OBJECT_0 + 1 .. WAIT_OBJECT_0 + MAXIMUM_WAIT_OBJECTS - 1:
        begin
          WOIndex := WaitResult - WAIT_OBJECT_0;
          ev := WaitEvents[WOIndex];

          if FindPipe(ev, Pipe) then
            if not Pipe.Read then
              ClosePipe(Pipe);
        end;

      WAIT_ABANDONED_0 + 1 .. WAIT_ABANDONED_0 + MAXIMUM_WAIT_OBJECTS - 1:
        begin
          WOIndex := WaitResult - WAIT_ABANDONED_0;
          ev := WaitEvents[WOIndex];

          if FindPipe(ev, Pipe) then
            ClosePipe(Pipe);
        end;

      WAIT_TIMEOUT:
        ; // pass down
      WAIT_FAILED:
        begin
          Assert(false, 'TPipeServer.Execute: WAIT_FAILED'); // lol wut?
        end;
    end;
    UpdateQueue;
  end;
end;

end.
