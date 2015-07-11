unit PipeServer;

interface

uses Classes, Windows, System.Generics.Collections,
  //
  Pipe, AGTHConst;

type
  TWOHandles = array [0 .. MAXIMUM_WAIT_OBJECTS - 1] of THandle;

  TSyncPckt = packed record
    hPipe: THandle;
    Data: TAGTHRcPckt;
  end;

  TOnConnectEvent = procedure(hPipe: THandle) of object;
  TOnDisconnectEvent = procedure(hPipe: THandle) of object;
  TOnReceiveEvent = procedure(hPipe: THandle; Data: TAGTHRcPckt) of object;

  TPipeServer = class(TThread)
  private
    FOnConnect: TOnConnectEvent;
    FOnReceive: TOnReceiveEvent;
    FOnDisconnect: TOnDisconnectEvent;

    LastUpdateTime: Cardinal;

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
    Pipes: TObjectDictionary<THandle, TPipe>;
    PacketQueue: TQueue<TSyncPckt>;

    function FillWOArray(var WOArr: TWOHandles): Cardinal;
    procedure ClosePipe(Pipe: TPipe);
  end;

const
  QueueUpdateInterval = 30;

implementation

{ TPipeServer }

constructor TPipeServer.Create;
begin
  inherited Create(true);
  Pipes := TObjectDictionary<THandle, TPipe>.Create([doOwnsValues]);
  PacketQueue := TQueue<TSyncPckt>.Create;
  IncomingPipe := nil;
  LastUpdateTime := GetTickCount;

  FOnConnect := nil;
  FOnReceive := nil;
  FOnDisconnect := nil;
end;

destructor TPipeServer.Destroy;
begin
  Terminate;
  WaitFor;

  Pipes.Free;
  if Assigned(IncomingPipe) then
    IncomingPipe.Free;

  PacketQueue.Free;
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
  packet: TSyncPckt;
begin
  packet.hPipe := hPipe;
  packet.Data := Data;
  PacketQueue.Enqueue(packet);
end;

procedure TPipeServer.UpdateQueue;
var
  cnt: Integer;
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
  packet: TSyncPckt;
begin
  while PacketQueue.Count > 0 do
  begin
    // don't worry about PacketQueue, at this point owner thread is paused
    packet := PacketQueue.Dequeue;
    if Assigned(FOnReceive) then
      FOnReceive(packet.hPipe, packet.Data);
  end;
end;

function TPipeServer.FillWOArray(var WOArr: TWOHandles): Cardinal;
var
  i, psz: Integer;
  pair: TPair<THandle, TPipe>;
begin
  psz := Pipes.Count;
  if psz > MAXIMUM_WAIT_OBJECTS - 1 then
    psz := MAXIMUM_WAIT_OBJECTS - 1;

  WOArr[0] := IncomingPipe.WaitEvent;

  for i := 0 to psz - 1 do
    WOArr[i + 1] := Pipes.Keys.ToArray[i];

  Result := psz + 1;
end;

procedure TPipeServer.ClosePipe(Pipe: TPipe);
begin
  DoDisconnect(Pipe.hPipe);
  Pipes.Remove(Pipe.WaitEvent);
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

          Pipes.Add(IncomingPipe.WaitEvent, IncomingPipe);
          IncomingPipe.Read;

          IncomingPipe := TPipe.Create;
          IncomingPipe.OnReceive := DoReceive;
        end;

      WAIT_OBJECT_0 + 1 .. WAIT_OBJECT_0 + MAXIMUM_WAIT_OBJECTS - 1:
        begin
          WOIndex := WaitResult - WAIT_OBJECT_0;
          ev := WaitEvents[WOIndex];

          if Pipes.TryGetValue(ev, Pipe) then
            if not Pipe.Read then
              ClosePipe(Pipe);
        end;

      WAIT_ABANDONED_0 + 1 .. WAIT_ABANDONED_0 + MAXIMUM_WAIT_OBJECTS - 1:
        begin
          WOIndex := WaitResult - WAIT_ABANDONED_0;
          ev := WaitEvents[WOIndex];

          if Pipes.TryGetValue(ev, Pipe) then
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
