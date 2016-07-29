unit OSDTextProcessor;

interface

uses
  OSD,
  OSDTextProcessorUI,
  PluginAPI_TLB;

type
  TOSDTextProcessor = class(TInterfacedObject, ITextEvents, ITextProcessor)
  public
    // ITextProcessor
    procedure ShowSettingsWindow; safecall;
    procedure HideSettingsWindow; safecall;
    procedure SetTextReceiver(const Reciever: ITextEvents); safecall;
    // ITextEvents
    procedure OnNewText(const Text: WideString); safecall;
    // interface end
  private
    FApplicationCore: IApplicationCore;
    FOSDSettings: TOSDSettings;
  public
    constructor Create(const ApplicationCore: IApplicationCore);
    destructor Destroy; override;
  end;

  TOSDInfo = class(TInterfacedObject, ITextProcessorInfo)
    function Get_Name: WideString; safecall;
    function Get_ID: TGUID; safecall;
    function Get_Version: WideString; safecall;
    property Name: WideString read Get_Name;
    property ID: TGUID read Get_ID;
    property Version: WideString read Get_Version;
  end;

  TOSDFactory = class(TInterfacedObject, ITextProcessorFactory)
    function GetNewTextProcessor(const Core: IApplicationCore)
      : ITextProcessor; safecall;
  end;

implementation

uses
  UITypes,
  Graphics,
  SysUtils;

{ TOSDTextFactory }

function TOSDFactory.GetNewTextProcessor(const Core: IApplicationCore)
  : ITextProcessor;
begin
  Result := TOSDTextProcessor.Create(Core);
end;

{ TGoogleTranslateTextProcessor }

constructor TOSDTextProcessor.Create(const ApplicationCore: IApplicationCore);
var
  Settings: ISettings;
  OutlineWidth: integer;
begin
  FApplicationCore := ApplicationCore;
  FOSDSettings := TOSDSettings.CreateParented
    (FApplicationCore.ApplicationWindows.HostWnd,
    FApplicationCore.ApplicationWindows.MainWnd);

  Settings := FApplicationCore.Settings;
  with FOSDSettings do
  begin
    cbHideOSD.checked := Settings.ReadBoolean('EnableOSD', False);

    tbX.Position := Settings.ReadInteger('PositionX', 50);
    tbY.Position := Settings.ReadInteger('PositionY', 100);
    tbWidth.Position := Settings.ReadInteger('PositionWidth', 100);
    tbHeight.Position := Settings.ReadInteger('PositionHeight', 20);

    OSDForm.TextFont.Name := Settings.ReadString('FontName',
      'Arial Unicode MS');
    OSDForm.TextFont.CharSet := Byte(Settings.ReadInteger('FontCharSet', 0));
    OSDForm.TextFont.Size := Settings.ReadInteger('FontSize', 15);
    OSDForm.TextFont.Style :=
      TFontStyles(Byte(Settings.ReadInteger('FontStyle', 0)));

    OSDForm.TextColor := StrToInt('$' + Settings.ReadString('FontColor',
      inttohex(clWhite, 8)));
    OSDForm.OutlineColor := StrToInt('$' + Settings.ReadString('OutlineColor',
      inttohex(clBlack, 8)));

    OutlineWidth := Settings.ReadInteger('OutlineWidth', 1);
    OSDForm.OutlineWidth := OutlineWidth;
    tbOutline.Position := OutlineWidth;;

    FOSDSettings.cbSticky.checked := Settings.ReadBoolean('Sticky', True);
    UpdateColorBoxes;
    cbHideOSDClick(cbHideOSD);
  end;
end;

destructor TOSDTextProcessor.Destroy;
var
  Settings: ISettings;
begin
  Settings := FApplicationCore.Settings;
  with FOSDSettings do
  begin
    Settings.ReadBoolean('HideOSD', cbHideOSD.checked);
    Settings.WriteInteger('PositionX', tbX.Position);
    Settings.WriteInteger('PositionY', tbY.Position);
    Settings.WriteInteger('PositionWidth', tbWidth.Position);
    Settings.WriteInteger('PositionHeight', tbHeight.Position);
    Settings.WriteString('FontName', OSDForm.TextFont.Name);
    Settings.WriteInteger('FontCharSet', OSDForm.TextFont.CharSet);
    Settings.WriteInteger('FontSize', OSDForm.TextFont.Size);
    Settings.WriteInteger('FontStyle', Byte(OSDForm.TextFont.Style));
    Settings.WriteString('FontColor', inttohex(OSDForm.TextColor, 8));
    Settings.WriteString('OutlineColor', inttohex(OSDForm.OutlineColor, 8));
    Settings.WriteInteger('OutlineWidth', OSDForm.OutlineWidth);
    Settings.ReadBoolean('Sticky', cbSticky.checked);
  end;

  FOSDSettings.Free;
  inherited;
end;

procedure TOSDTextProcessor.OnNewText(const Text: WideString);
begin
  FOSDSettings.OSDForm.SetText(Text);
end;

procedure TOSDTextProcessor.SetTextReceiver(const Reciever: ITextEvents);
begin
  // nope
end;

procedure TOSDTextProcessor.HideSettingsWindow;
begin
  FOSDSettings.Hide;
end;

procedure TOSDTextProcessor.ShowSettingsWindow;
begin
  FOSDSettings.Show;
end;

{ TOSDInfo }

function TOSDInfo.Get_ID: TGUID;
const
  OSDID: TGUID = '{F790E02A-1954-4D76-8C4E-C920633D1234}';
begin
  Result := OSDID;
end;

function TOSDInfo.Get_Name: WideString;
begin
  Result := 'On Screen Display';
end;

function TOSDInfo.Get_Version: WideString;
begin
  Result := '1.0';
end;

end.
