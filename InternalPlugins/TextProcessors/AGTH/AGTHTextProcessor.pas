unit AGTHTextProcessor;

interface

uses
  PluginAPI_TLB,
  AGTHServer,
  AGTHUI;

type
  TAGTHTextProcessor = class(TInterfacedObject, ITextEvents, ITextProcessor)
  protected
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
    FAGTHForm: TAGTHForm;
  public
    constructor Create(const ApplicationCore: IApplicationCore);
    destructor Destroy; override;
    procedure SendText(const AText: string);
  end;

  TAGTHInfo = class(TInterfacedObject, ITextProcessorInfo)
    function Get_Name: WideString; safecall;
    function Get_ID: TGUID; safecall;
    function Get_Version: WideString; safecall;
    property Name: WideString read Get_Name;
    property ID: TGUID read Get_ID;
    property Version: WideString read Get_Version;
  end;

  TAGTHFactory = class(TInterfacedObject, ITextProcessorFactory)
    function GetNewTextProcessor(const Core: IApplicationCore)
      : ITextProcessor; safecall;
  end;

implementation

{ TAGTHTextFactory }

function TAGTHFactory.GetNewTextProcessor(const Core: IApplicationCore)
  : ITextProcessor;
begin
  Result := TAGTHTextProcessor.Create(Core);
end;

{ TAGTHTextProcessor }

constructor TAGTHTextProcessor.Create(const ApplicationCore: IApplicationCore);
begin
  FApplicationCore := ApplicationCore;
  FReciever := nil;

  FAGTHForm := TAGTHForm.CreateParented
    (FApplicationCore.ApplicationWindows.HostWnd, FApplicationCore.Settings);
  FAGTHForm.OnNewTextReceived := SendText;
end;

destructor TAGTHTextProcessor.Destroy;
begin
  FReciever := nil;
  FAGTHForm.Free;
  inherited;
end;

procedure TAGTHTextProcessor.OnNewText(const Text: WideString);
begin
  // none
end;

procedure TAGTHTextProcessor.SendText(const AText: string);
begin
  if Assigned(FReciever) then
    FReciever.OnNewText(AText);
end;

procedure TAGTHTextProcessor.SetTextReceiver(const Reciever: ITextEvents);
begin
  FReciever := Reciever;
end;

procedure TAGTHTextProcessor.HideSettingsWindow;
begin
  FAGTHForm.Hide;
end;

procedure TAGTHTextProcessor.ShowSettingsWindow;
begin
  FAGTHForm.Show;
end;

{ TAGTHInfo }

function TAGTHInfo.Get_ID: TGUID;
const
  AGTHID: TGUID = '{0A89D863-42D4-4578-9D67-D0DF91974D6B}';
begin
  Result := AGTHID;
end;

function TAGTHInfo.Get_Name: WideString;
begin
  Result := 'AGTH processor';
end;

function TAGTHInfo.Get_Version: WideString;
begin
  Result := '1.0';
end;

end.
