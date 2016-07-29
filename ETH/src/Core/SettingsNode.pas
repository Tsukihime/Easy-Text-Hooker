unit SettingsNode;

interface

uses
  Winapi.ActiveX,
  PluginAPI_TLB,
  JSON;

type
  ISerialisable = interface
    function GetSerialized: TJSONObject;
    property Serialized: TJSONObject read GetSerialized;
  end;

  TSettingsNode = class(TInterfacedObject, ISettings, ISerialisable)
  protected
    // Interface
    procedure WriteString(const Name: WideString;
      const Value: WideString); safecall;
    function ReadString(const Name: WideString; const Default: WideString)
      : WideString; safecall;
    procedure WriteInteger(const Name: WideString; Value: SYSINT); safecall;
    function ReadInteger(const Name: WideString; Default: SYSINT)
      : SYSINT; safecall;
    procedure WriteBoolean(const Name: WideString; Value: WordBool); safecall;
    function ReadBoolean(const Name: WideString; Default: WordBool)
      : WordBool; safecall;
    // end Intf
  private
    FJSONNode: TJSONObject;
    function GetSerialized: TJSONObject;
    procedure WriteJsonValue(const Name: string; Value: TJSONValue);
    function ReadJsonValue(const Name: string): TJSONValue;
  public
    constructor Create(const InitialNode: TJSONObject = nil);
    destructor Destroy; override;
    property Serialized: TJSONObject read GetSerialized;
  end;

implementation

{ TSettingsNode }

constructor TSettingsNode.Create(const InitialNode: TJSONObject);
begin
  if not Assigned(InitialNode) then
    FJSONNode := TJSONObject.Create
  else
    FJSONNode := InitialNode.Clone as TJSONObject;
end;

destructor TSettingsNode.Destroy;
begin
  FJSONNode.Free;
  inherited;
end;

function TSettingsNode.GetSerialized: TJSONObject;
begin
  Result := FJSONNode.Clone as TJSONObject;
end;

function TSettingsNode.ReadBoolean(const Name: WideString; Default: WordBool)
  : WordBool;
var
  jValue: TJSONValue;
begin
  jValue := ReadJsonValue(Name);
  if Assigned(jValue) and ((jValue is TJSONTrue) or (jValue is TJSONFalse)) then
    Result := jValue is TJSONTrue
  else
    Result := Default;
end;

function TSettingsNode.ReadInteger(const Name: WideString;
  Default: SYSINT): SYSINT;
var
  jValue: TJSONValue;
begin
  jValue := ReadJsonValue(Name);
  if Assigned(jValue) and (jValue is TJSONNumber) then
    Result := (jValue as TJSONNumber).AsInt
  else
    Result := Default;
end;

function TSettingsNode.ReadString(const Name, Default: WideString): WideString;
var
  jValue: TJSONValue;
begin
  jValue := ReadJsonValue(Name);
  if Assigned(jValue) and (jValue is TJSONString) then
    Result := (jValue as TJSONString).Value
  else
    Result := Default;
end;

procedure TSettingsNode.WriteBoolean(const Name: WideString; Value: WordBool);
begin
  if Value then
    WriteJsonValue(Name, TJSONTrue.Create)
  else
    WriteJsonValue(Name, TJSONFalse.Create);
end;

procedure TSettingsNode.WriteInteger(const Name: WideString; Value: SYSINT);
begin
  WriteJsonValue(Name, TJSONNumber.Create(Value));
end;

procedure TSettingsNode.WriteString(const Name, Value: WideString);
begin
  WriteJsonValue(Name, TJSONString.Create(Value));
end;

function TSettingsNode.ReadJsonValue(const Name: string): TJSONValue;
begin
  Result := FJSONNode.GetValue(Name);
end;

procedure TSettingsNode.WriteJsonValue(const Name: string; Value: TJSONValue);
var
  jPair: TJSONPair;
begin
  jPair := FJSONNode.Get(Name);
  if Assigned(jPair) then
    FJSONNode.RemovePair(Name);
  FJSONNode.AddPair(Name, Value);
end;

end.
