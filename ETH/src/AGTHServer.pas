unit AGTHServer;

interface

uses PipeServer, Classes, Windows, SysUtils,
  System.Generics.Collections, ExtCtrls, AGTHConst;

type
  TTextStream = class
  private
    Text: TStringList;
    LastTime: Cardinal;
    LagTime: Cardinal;

    Context: Cardinal;
    Subcontext: Cardinal;
    ProcessID: Cardinal;
    HookName: ansistring;
    FTmrInterval: Cardinal;
    newText: boolean;
    Buffer: TStringBuilder;
    procedure NewStr;
  public
    constructor Create(const pckt: TAGTHRcPckt);
    destructor Destroy; override;
    function Compare(const pckt: TAGTHRcPckt): boolean;
    procedure Add(const pckt: TAGTHRcPckt);
    function StreamID: string;
    function GetText(var Text: WideString): boolean;
    procedure GetStreamText(lines: TStrings);
    property TmrInterval: Cardinal read FTmrInterval write FTmrInterval;
  end;

  TStreamEvent = procedure(lines: TStrings) of object;
  TTextEvent = procedure(Text: WideString) of object;

  TAGTHServer = class
    constructor Create;
    destructor Destroy; override;
  private
    pps: TPipeServer;
    TextStreams: TObjectList<TTextStream>;
    Tmr: TTimer;
    TmrInterval: Integer;
    CurrentStream: Integer;

    FStreamEvent: TStreamEvent;
    FOnText: TTextEvent;

    procedure TextEvent(Text: WideString);
    procedure StreamEvent(lines: TStrings);

    procedure OnRecieve(hPipe: THandle; data: TAGTHRcPckt);
    function GetDelay: Integer;
    procedure SetDelay(const Value: Integer);
    procedure OnTimer(Sender: TObject);
  public
    procedure SelectStream(index: Integer);
    procedure GetStreams(StreamList: TStrings);
    procedure GetStreamText(lines: TStrings);
    property CopyDelay: Integer read GetDelay write SetDelay;
    property OnStream: TStreamEvent read FStreamEvent write FStreamEvent;
    property OnText: TTextEvent read FOnText write FOnText;
  end;

const
  MAX_STR_CAPACITY = 64;

implementation

uses main;
{ TAGTHServer }

constructor TAGTHServer.Create;
begin
  TextStreams := TObjectList<TTextStream>.Create(true);
  Tmr := TTimer.Create(nil);
  Tmr.OnTimer := OnTimer;
  TmrInterval := 150;
  Tmr.Interval := TmrInterval;
  Tmr.Enabled := true;
  CurrentStream := 0;

  pps := TPipeServer.Create;
  pps.OnReceive := OnRecieve;
  pps.Start;
end;

destructor TAGTHServer.Destroy;
begin
  Tmr.Free;
  pps.Free;
  TextStreams.Free;
  inherited;
end;

function TAGTHServer.GetDelay: Integer;
begin
  Result := TmrInterval;
end;

procedure TAGTHServer.GetStreams(StreamList: TStrings);
var
  i: Integer;
begin
  StreamList.Clear;
  for i := 0 to TextStreams.Count - 1 do
    StreamList.Add(TextStreams[i].StreamID);
end;

procedure TAGTHServer.GetStreamText(lines: TStrings);
begin
  if (CurrentStream >= 0) and (CurrentStream < TextStreams.Count) then
    TextStreams[CurrentStream].GetStreamText(lines);
end;

procedure TAGTHServer.SelectStream(index: Integer);
begin
  CurrentStream := index;
end;

procedure TAGTHServer.SetDelay(const Value: Integer);
var
  i: Integer;
begin
  TmrInterval := Value;
  for i := 0 to TextStreams.Count - 1 do
    TextStreams[i].TmrInterval := TmrInterval;
  Tmr.Interval := TmrInterval;
end;

procedure TAGTHServer.StreamEvent(lines: TStrings);
begin
  TThread.Synchronize(TThread.CurrentThread,
    procedure
    begin
      if Assigned(FStreamEvent) then
        FStreamEvent(lines);
    end);
end;

procedure TAGTHServer.OnRecieve(hPipe: THandle; data: TAGTHRcPckt);
var
  i: Integer;
  ts: TTextStream;
  ln: TStringList;
begin
  for i := 0 to TextStreams.Count - 1 do
    if TextStreams[i].Compare(data) then
    begin
      TextStreams[i].Add(data);
      exit;
    end;

  ts := TTextStream.Create(data);
  ts.TmrInterval := TmrInterval;
  TextStreams.Add(ts);

  ln := TStringList.Create;
  GetStreams(ln);
  StreamEvent(ln);
  ln.Free;
end;

procedure TAGTHServer.OnTimer(Sender: TObject);
var
  str: WideString;
begin
  if (CurrentStream >= 0) and (CurrentStream < TextStreams.Count) then
    if TextStreams[CurrentStream].GetText(str) then
      TextEvent(str);
end;

procedure TAGTHServer.TextEvent(Text: WideString);
begin
  if Assigned(FOnText) then
    FOnText(Text);
end;

{ TTextStream }

procedure TTextStream.Add(const pckt: TAGTHRcPckt);
begin
  newText := true;
  if pckt.UpTime - LastTime > FTmrInterval then
    NewStr;
  LastTime := pckt.UpTime;
  LagTime := GetTickCount - LastTime;
  Buffer.Append(copy(pckt.Text, 1, pckt.TextLength));
end;

procedure TTextStream.NewStr;
begin
  Text.Add(Buffer.ToString);
  Buffer.Clear;
  if Text.Count > MAX_STR_CAPACITY then
    Text.Delete(0);
end;

function TTextStream.Compare(const pckt: TAGTHRcPckt): boolean;
var
  str: ansistring;
begin
  str := pckt.HookName;
  Result := (Context = pckt.Context) and (Subcontext = pckt.Subcontext) and
    (ProcessID = pckt.ProcessID) and (HookName = str);
end;

constructor TTextStream.Create(const pckt: TAGTHRcPckt);
begin
  Buffer := TStringBuilder.Create;
  Text := TStringList.Create;
  Text.Add('');
  Context := pckt.Context;
  Subcontext := pckt.Subcontext;
  ProcessID := pckt.ProcessID;
  HookName := pckt.HookName;
  FTmrInterval := 150;
  Add(pckt);
end;

destructor TTextStream.Destroy;
begin
  Buffer.Free;
  Text.Free;
  inherited;
end;

procedure TTextStream.GetStreamText(lines: TStrings);
begin
  lines.Clear;
  lines.Assign(Text);
end;

function TTextStream.GetText(var Text: WideString): boolean;
var
  CurTime: Cardinal;
begin
  Result := false;
  CurTime := GetTickCount;
  if (CurTime - LagTime - LastTime > FTmrInterval) and newText then
  begin
    NewStr;
    Text := self.Text.Strings[self.Text.Count - 1];
    newText := false;
    Result := true;
  end;
end;

function TTextStream.StreamID: string;
begin
  Result := '0x' + IntToHex(Context, 8) + ':' + IntToHex(Subcontext, 8) + '   '
    + string(HookName);
end;

end.
