unit TextArea;

interface

uses
  PluginAPI_TLB,
  TextAreaUI;

type
  TTextAreaTextProcessor = class(TInterfacedObject, ITextEvents, ITextProcessor)
  public
    // ITextProcessor
    procedure ShowSettingsWindow; safecall;
    procedure HideSettingsWindow; safecall;
    procedure SetTextReceiver(const Reciever: ITextEvents); safecall;
    // ITextEvents
    procedure OnNewText(const Text: WideString); safecall;
    // interface end
  private
    FCore: IApplicationCore;
    FTextAreaForm: TTextAreaForm;
  public
    constructor Create(const ACore: IApplicationCore);
    destructor Destroy; override;
  end;

  TTextAreaInfo = class(TInterfacedObject, ITextProcessorInfo)
    function Get_Name: WideString; safecall;
    function Get_ID: TGUID; safecall;
    function Get_Version: WideString; safecall;
    property Name: WideString read Get_Name;
    property ID: TGUID read Get_ID;
    property Version: WideString read Get_Version;
  end;

  TTextAreaFactory = class(TInterfacedObject, ITextProcessorFactory)
    function GetNewTextProcessor(const ApplicationCore: IApplicationCore)
      : ITextProcessor; safecall;
  end;

implementation

uses
  UITypes,
  SysUtils,
  Graphics;

{ TTextAreaFactory }

function TTextAreaFactory.GetNewTextProcessor(const ApplicationCore
  : IApplicationCore): ITextProcessor;
begin
  Result := TTextAreaTextProcessor.Create(ApplicationCore);
end;

{ TTextAreaTextProcessor }

constructor TTextAreaTextProcessor.Create(const ACore: IApplicationCore);
var
  Settings: ISettings;
begin
  FCore := ACore;
  FTextAreaForm := TTextAreaForm.CreateParented
    (FCore.ApplicationWindows.HostWnd);

  Settings := FCore.Settings;
  with FTextAreaForm.Memo do
  begin
    Font.Name := Settings.ReadString('Name', Font.Name);
    Font.CharSet := Byte(Settings.ReadInteger('CharSet', Font.CharSet));
    Font.Color := StrToInt('$' + Settings.ReadString('Color',
      inttohex(Font.Color, 8)));
    Font.Size := Settings.ReadInteger('Size', Font.Size);
    Font.Style := TFontStyles(Byte(Settings.ReadInteger('Style',
      Byte(Font.Style))));
  end;
end;

destructor TTextAreaTextProcessor.Destroy;
var
  Settings: ISettings;
begin
  Settings := FCore.Settings;
  with FTextAreaForm.Memo do
  begin
    Settings.WriteString('Name', Font.Name);
    Settings.WriteInteger('CharSet', Font.CharSet);
    Settings.WriteString('Color', inttohex(Font.Color, 8));
    Settings.WriteInteger('Size', Font.Size);
    Settings.WriteInteger('Style', Byte(Font.Style));
  end;

  FTextAreaForm.Free;
  inherited;
end;

procedure TTextAreaTextProcessor.OnNewText(const Text: WideString);
begin
  FTextAreaForm.SetText(Text);
end;

procedure TTextAreaTextProcessor.SetTextReceiver(const Reciever: ITextEvents);
begin
  // none
end;

procedure TTextAreaTextProcessor.HideSettingsWindow;
begin
  FTextAreaForm.Hide;
end;

procedure TTextAreaTextProcessor.ShowSettingsWindow;
begin
  FTextAreaForm.Show;
end;

{ TTextAreaInfo }

function TTextAreaInfo.Get_ID: TGUID;
const
  TextAreaID: TGUID = '{AF198686-6672-4518-9A6E-BE1D07C61088}';
begin
  Result := TextAreaID;
end;

function TTextAreaInfo.Get_Name: WideString;
begin
  Result := 'Text Area';
end;

function TTextAreaInfo.Get_Version: WideString;
begin
  Result := '1.0';
end;

end.
