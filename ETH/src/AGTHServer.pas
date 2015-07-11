unit AGTHServer;

interface

uses
  PipeServer,
  Classes,
  System.Generics.Collections,
  ExtCtrls,
  AGTHConst,
  TextStream;

type
  TNewStreamEvent = procedure(Lines: TStrings) of object;
  TTextEvent = procedure(Text: WideString) of object;

  TAGTHServer = class
    constructor Create;
    destructor Destroy; override;
  private
    FPipeServer: TPipeServer;
    FTextStreams: TObjectList<TTextStream>;
    FTimer: TTimer;
    FEndLineDelay: Integer;
    FCurrentStream: Integer;

    FOnNewStreamEvent: TNewStreamEvent;
    FOnNewText: TTextEvent;

    procedure DoNewText(Text: WideString);
    procedure DoNewStream(Lines: TStrings);

    procedure OnRecieve(hPipe: THandle; data: TAGTHRcPckt);
    procedure SetEndLineDelay(const Value: Integer);
    procedure OnTimer(Sender: TObject);
  public
    procedure SelectStream(index: Integer);
    procedure GetStreams(StreamList: TStrings);
    procedure GetStreamText(Lines: TStrings);
    property EndLineDelay: Integer read FEndLineDelay write SetEndLineDelay;
    property OnNewStream: TNewStreamEvent read FOnNewStreamEvent
      write FOnNewStreamEvent;
    property OnNewText: TTextEvent read FOnNewText write FOnNewText;
  end;

implementation

{ TAGTHServer }

constructor TAGTHServer.Create;
begin
  FTextStreams := TObjectList<TTextStream>.Create(true);
  FTimer := TTimer.Create(nil);
  FTimer.OnTimer := OnTimer;
  EndLineDelay := 150;
  FTimer.Enabled := true;
  FCurrentStream := 0;

  FPipeServer := TPipeServer.Create;
  FPipeServer.OnReceive := OnRecieve;
  FPipeServer.Start;
end;

destructor TAGTHServer.Destroy;
begin
  FTimer.Free;
  FPipeServer.Free;
  FTextStreams.Free;
  inherited;
end;

procedure TAGTHServer.GetStreams(StreamList: TStrings);
var
  i: Integer;
begin
  StreamList.Clear;
  for i := 0 to FTextStreams.Count - 1 do
    StreamList.Add(FTextStreams[i].StreamID);
end;

procedure TAGTHServer.GetStreamText(Lines: TStrings);
begin
  if (FCurrentStream >= 0) and (FCurrentStream < FTextStreams.Count) then
    FTextStreams[FCurrentStream].GetStreamText(Lines);
end;

procedure TAGTHServer.SelectStream(index: Integer);
begin
  FCurrentStream := index;
end;

procedure TAGTHServer.SetEndLineDelay(const Value: Integer);
var
  i: Integer;
begin
  FEndLineDelay := Value;
  for i := 0 to FTextStreams.Count - 1 do
    FTextStreams[i].EndLineDelay := EndLineDelay;
  FTimer.Interval := EndLineDelay;
end;

procedure TAGTHServer.DoNewStream(Lines: TStrings);
begin
  if Assigned(FOnNewStreamEvent) then
    FOnNewStreamEvent(Lines);
end;

procedure TAGTHServer.OnRecieve(hPipe: THandle; data: TAGTHRcPckt);
var
  i: Integer;
  TextStream: TTextStream;
  Streams: TStringList;
begin
  for i := 0 to FTextStreams.Count - 1 do
    if FTextStreams[i].Compare(data) then
    begin
      FTextStreams[i].Add(data);
      exit;
    end;

  TextStream := TTextStream.Create(data);
  TextStream.EndLineDelay := EndLineDelay;
  FTextStreams.Add(TextStream);

  Streams := TStringList.Create;
  GetStreams(Streams);
  DoNewStream(Streams);
  Streams.Free;
end;

procedure TAGTHServer.OnTimer(Sender: TObject);
var
  str: WideString;
begin
  if (FCurrentStream >= 0) and (FCurrentStream < FTextStreams.Count) then
    if FTextStreams[FCurrentStream].GetText(str) then
      DoNewText(str);
end;

procedure TAGTHServer.DoNewText(Text: WideString);
begin
  if Assigned(FOnNewText) then
    FOnNewText(Text);
end;

end.
