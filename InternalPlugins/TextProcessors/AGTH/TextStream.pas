unit TextStream;

interface

uses
  Classes,
  Windows,
  SysUtils,
  AGTHConst;

type
  TTextStream = class
  private
    FText: TStringList;
    FLastTime: Cardinal;
    FLagTime: Cardinal;

    FContext: Cardinal;
    FSubcontext: Cardinal;
    FProcessID: Cardinal;
    FHookName: ansistring;
    FEndLineDelay: Cardinal;
    FNewText: boolean;
    FBuffer: TStringBuilder;
    procedure NewStr;
  public
    constructor Create(const pckt: TAGTHMessage);
    destructor Destroy; override;
    function Compare(const pckt: TAGTHMessage): boolean;
    procedure Add(const pckt: TAGTHMessage);
    function StreamID: string;
    function GetText(var Text: WideString): boolean;
    procedure GetStreamText(lines: TStrings);
    property EndLineDelay: Cardinal read FEndLineDelay write FEndLineDelay;
  end;

const
  MAX_STR_CAPACITY = 64;

implementation

{ TTextStream }

procedure TTextStream.Add(const pckt: TAGTHMessage);
begin
  FNewText := true;
  if pckt.UpTime - FLastTime > FEndLineDelay then
    NewStr;
  FLastTime := pckt.UpTime;
  FLagTime := GetTickCount - FLastTime;
  FBuffer.Append(copy(pckt.Text, 1, pckt.TextLength));
end;

procedure TTextStream.NewStr;
begin
  if (FBuffer.Length > 0) then
  begin
    FText.Add(FBuffer.ToString);
    FBuffer.Clear;
    if FText.Count > MAX_STR_CAPACITY then
      FText.Delete(0);
  end;
end;

function TTextStream.Compare(const pckt: TAGTHMessage): boolean;
var
  str: ansistring;
begin
  str := pckt.HookName;
  Result := (FContext = pckt.Context) and (FSubcontext = pckt.Subcontext) and
    (FProcessID = pckt.ProcessID) and (FHookName = str);
end;

constructor TTextStream.Create(const pckt: TAGTHMessage);
begin
  FBuffer := TStringBuilder.Create;
  FText := TStringList.Create;
  FText.Add('');
  FContext := pckt.Context;
  FSubcontext := pckt.Subcontext;
  FProcessID := pckt.ProcessID;
  FHookName := pckt.HookName;
  FEndLineDelay := 150;
  Add(pckt);
end;

destructor TTextStream.Destroy;
begin
  FBuffer.Free;
  FText.Free;
  inherited;
end;

procedure TTextStream.GetStreamText(lines: TStrings);
begin
  lines.Assign(FText);
end;

function TTextStream.GetText(var Text: WideString): boolean;
var
  CurrentTime: Cardinal;
begin
  Result := false;
  CurrentTime := GetTickCount;
  if (CurrentTime - FLagTime - FLastTime > FEndLineDelay) and FNewText then
  begin
    NewStr;
    Text := self.FText.Strings[self.FText.Count - 1];
    FNewText := false;
    Result := true;
  end;
end;

function TTextStream.StreamID: string;
begin
  Result := '0x' + IntToHex(FContext, 8) + ':' + IntToHex(FSubcontext, 8) +
    '   ' + string(FHookName);
end;

end.
