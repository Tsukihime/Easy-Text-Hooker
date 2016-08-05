unit CaptureWindowTextProcessor;

interface

uses
  CaptureWindowTextUI,
  PluginAPI_TLB;

type
  TCaptureWindowTextProcessor = class(TInterfacedObject, ITextEvents,
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
    FReciever: ITextEvents;
    SettingsForm: TCaptureSettingsForm;
  public
    constructor Create(const ACore: IApplicationCore);
    destructor Destroy; override;
    procedure SendText(const AText: string);
  end;

  TCaptureWindowInfo = class(TInterfacedObject, ITextProcessorInfo)
    function Get_Name: WideString; safecall;
    function Get_ID: TGUID; safecall;
    function Get_Version: WideString; safecall;
    property Name: WideString read Get_Name;
    property ID: TGUID read Get_ID;
    property Version: WideString read Get_Version;
  end;

  TCaptureWindowFactory = class(TInterfacedObject, ITextProcessorFactory)
    function GetNewTextProcessor(const ApplicationCore: IApplicationCore)
      : ITextProcessor; safecall;
  end;

implementation

{ TCaptureWindowFactory }

function TCaptureWindowFactory.GetNewTextProcessor(const ApplicationCore
  : IApplicationCore): ITextProcessor;
begin
  Result := TCaptureWindowTextProcessor.Create(ApplicationCore);
end;

{ TCaptureWindowTextProcessor }

constructor TCaptureWindowTextProcessor.Create(const ACore: IApplicationCore);
begin
  FCore := ACore;
  SettingsForm := TCaptureSettingsForm.CreateParented
    (ACore.ApplicationWindows.HostWnd);
  SettingsForm.OnNewText := SendText;
end;

destructor TCaptureWindowTextProcessor.Destroy;
begin
  SettingsForm.Free;
  inherited;
end;

procedure TCaptureWindowTextProcessor.OnNewText(const Text: WideString);
begin
  // none
end;

procedure TCaptureWindowTextProcessor.SendText(const AText: string);
begin
  if Assigned(FReciever) then
    FReciever.OnNewText(AText);
end;

procedure TCaptureWindowTextProcessor.SetTextReceiver(const Reciever
  : ITextEvents);
begin
  FReciever := Reciever;
end;

procedure TCaptureWindowTextProcessor.HideSettingsWindow;
begin
  SettingsForm.Hide;
end;

procedure TCaptureWindowTextProcessor.ShowSettingsWindow;
begin
  SettingsForm.Show;
end;

{ TCaptureWindowInfo }

function TCaptureWindowInfo.Get_ID: TGUID;
const
  CaptureWindowID: TGUID = '{B422DCEC-AA93-451C-B9CB-D34AE1F2D24F}';
begin
  Result := CaptureWindowID;
end;

function TCaptureWindowInfo.Get_Name: WideString;
begin
  Result := 'Capture Window Text';
end;

function TCaptureWindowInfo.Get_Version: WideString;
begin
  Result := '1.0';
end;

end.
