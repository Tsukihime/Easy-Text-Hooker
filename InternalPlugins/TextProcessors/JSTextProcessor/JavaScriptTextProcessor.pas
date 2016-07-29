unit JavaScriptTextProcessor;

interface

uses
  PluginAPI_TLB,
  JSTextProcessorUI,
  JsCore;

type
  TJavaScriptTextProcessor = class(TInterfacedObject, ITextEvents,
    ITextProcessor)
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
    FReciever: ITextEvents;
    FJSCore: TJavaScriptCore;
    FJSTextProcessorForm: TJSTextProcessorForm;
  public
    constructor Create(const ApplicationCore: IApplicationCore);
    destructor Destroy; override;
  end;

  TJavaScriptInfo = class(TInterfacedObject, ITextProcessorInfo)
    function Get_Name: WideString; safecall;
    function Get_ID: TGUID; safecall;
    function Get_Version: WideString; safecall;
    property Name: WideString read Get_Name;
    property ID: TGUID read Get_ID;
    property Version: WideString read Get_Version;
  end;

  TJavaScriptFactory = class(TInterfacedObject, ITextProcessorFactory)
    function GetNewTextProcessor(const Core: IApplicationCore)
      : ITextProcessor; safecall;
  end;

procedure InitJavaScriptInternalPlugin(const Registry: ITextProcessorRegistry);

implementation

procedure InitJavaScriptInternalPlugin(const Registry: ITextProcessorRegistry);
begin
  Registry.RegisterFactory(TJavaScriptFactory.Create, TJavaScriptInfo.Create);
end;

{ TJavaScriptTextFactory }

function TJavaScriptFactory.GetNewTextProcessor(const Core: IApplicationCore)
  : ITextProcessor;
begin
  Result := TJavaScriptTextProcessor.Create(Core);
end;

{ TJavaScriptTextProcessor }

constructor TJavaScriptTextProcessor.Create(const ApplicationCore
  : IApplicationCore);
begin
  FApplicationCore := ApplicationCore;
  FReciever := nil;
  FJSCore := TJavaScriptCore.Create;
  FJSTextProcessorForm := TJSTextProcessorForm.CreateParented
    (FApplicationCore.ApplicationWindows.HostWnd, FJSCore,
    FApplicationCore.Settings);
end;

destructor TJavaScriptTextProcessor.Destroy;
begin
  FReciever := nil;
  FJSTextProcessorForm.Free;
  FJSCore.Free;
  inherited;
end;

procedure TJavaScriptTextProcessor.OnNewText(const Text: WideString);
var
  Translation: string;
begin
  Translation := FJSCore.ProcessText(Text);
  if Assigned(FReciever) then
    FReciever.OnNewText(Translation);
end;

procedure TJavaScriptTextProcessor.SetTextReceiver(const Reciever: ITextEvents);
begin
  FReciever := Reciever;
end;

procedure TJavaScriptTextProcessor.HideSettingsWindow;
begin
  FJSTextProcessorForm.Hide;
end;

procedure TJavaScriptTextProcessor.ShowSettingsWindow;
begin
  FJSTextProcessorForm.Show;
end;

{ TJavaScriptInfo }

function TJavaScriptInfo.Get_ID: TGUID;
const
  JavaScriptID: TGUID = '{A8D9AB58-2C2E-40AD-B327-D4B5007D4ED2}';
begin
  Result := JavaScriptID;
end;

function TJavaScriptInfo.Get_Name: WideString;
begin
  Result := 'JavaScript processor';
end;

function TJavaScriptInfo.Get_Version: WideString;
begin
  Result := '1.0';
end;

end.
