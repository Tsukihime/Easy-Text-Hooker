unit PutTextToWindowTextProcessor;

interface

uses
  PutTextToWindowUI,
  PluginAPI_TLB;

type
  TPutTextToWindowTextProcessor = class(TInterfacedObject, ITextEvents,
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
    FCore: IApplicationCore;
    SettingsForm: TPutSettingsForm;
  public
    constructor Create(const ACore: IApplicationCore);
    destructor Destroy; override;
  end;

  TPutTextToWindowInfo = class(TInterfacedObject, ITextProcessorInfo)
    function Get_Name: WideString; safecall;
    function Get_ID: TGUID; safecall;
    function Get_Version: WideString; safecall;
    property Name: WideString read Get_Name;
    property ID: TGUID read Get_ID;
    property Version: WideString read Get_Version;
  end;

  TPutTextToWindowFactory = class(TInterfacedObject, ITextProcessorFactory)
    function GetNewTextProcessor(const ApplicationCore: IApplicationCore)
      : ITextProcessor; safecall;
  end;

implementation

{ TPutTextToWindowFactory }

function TPutTextToWindowFactory.GetNewTextProcessor(const ApplicationCore
  : IApplicationCore): ITextProcessor;
begin
  Result := TPutTextToWindowTextProcessor.Create(ApplicationCore);
end;

{ TPutTextToWindowTextProcessor }

constructor TPutTextToWindowTextProcessor.Create(const ACore: IApplicationCore);
begin
  FCore := ACore;
  SettingsForm := TPutSettingsForm.CreateParented
    (ACore.ApplicationWindows.HostWnd);
end;

destructor TPutTextToWindowTextProcessor.Destroy;
begin
  SettingsForm.Free;
  inherited;
end;

procedure TPutTextToWindowTextProcessor.OnNewText(const Text: WideString);
begin
  SettingsForm.SetText(Text);
end;

procedure TPutTextToWindowTextProcessor.SetTextReceiver(const Reciever
  : ITextEvents);
begin
  // none
end;

procedure TPutTextToWindowTextProcessor.HideSettingsWindow;
begin
  SettingsForm.Hide;
end;

procedure TPutTextToWindowTextProcessor.ShowSettingsWindow;
begin
  SettingsForm.Show;
end;

{ TPutTextToWindowInfo }

function TPutTextToWindowInfo.Get_ID: TGUID;
const
  PutTextToWindowID: TGUID = '{F45E8122-1F02-41D4-8147-539FC5D4E964}';
begin
  Result := PutTextToWindowID;
end;

function TPutTextToWindowInfo.Get_Name: WideString;
begin
  Result := 'Put Text to Window';
end;

function TPutTextToWindowInfo.Get_Version: WideString;
begin
  Result := '1.0';
end;

end.
