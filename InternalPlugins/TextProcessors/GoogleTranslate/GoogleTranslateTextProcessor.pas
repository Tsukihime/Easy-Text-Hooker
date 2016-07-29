unit GoogleTranslateTextProcessor;

interface

uses
  PluginAPI_TLB,
  GoogleTranslate,
  GoogleTranslateUI;

type
  TGoogleTranslateTextProcessor = class(TInterfacedObject, ITextEvents,
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
    FTranslator: TGoogleTranslate;
    FGoogleTranslateSettingsForm: TGoogleTranslateSettingsForm;
  public
    constructor Create(const ACore: IApplicationCore);
    destructor Destroy; override;
  end;

  TGoogleTranslateInfo = class(TInterfacedObject, ITextProcessorInfo)
    function Get_Name: WideString; safecall;
    function Get_ID: TGUID; safecall;
    function Get_Version: WideString; safecall;
    property Name: WideString read Get_Name;
    property ID: TGUID read Get_ID;
    property Version: WideString read Get_Version;
  end;

  TGoogleTraranslateFactory = class(TInterfacedObject, ITextProcessorFactory)
    function GetNewTextProcessor(const ApplicationCore: IApplicationCore)
      : ITextProcessor; safecall;
  end;

implementation

{ TGoogleTraranslateFactory }

function TGoogleTraranslateFactory.GetNewTextProcessor(const ApplicationCore
  : IApplicationCore): ITextProcessor;
begin
  Result := TGoogleTranslateTextProcessor.Create(ApplicationCore);
end;

{ TGoogleTranslateTextProcessor }

constructor TGoogleTranslateTextProcessor.Create(const ACore: IApplicationCore);
begin
  FCore := ACore;
  FReciever := nil;
  FTranslator := TGoogleTranslate.Create;
  FGoogleTranslateSettingsForm := TGoogleTranslateSettingsForm.CreateParented
    (FCore.ApplicationWindows.HostWnd, FTranslator, FCore.Settings);
  FGoogleTranslateSettingsForm.Hide;
end;

destructor TGoogleTranslateTextProcessor.Destroy;
begin
  FReciever := nil;
  FGoogleTranslateSettingsForm.Free;
  FTranslator.Free;
  inherited;
end;

procedure TGoogleTranslateTextProcessor.OnNewText(const Text: WideString);
begin
  FTranslator.DoTranslate(Text,
    procedure(const TranslatedText: string)
    begin
      if Assigned(FReciever) then
        FReciever.OnNewText(TranslatedText);
    end);
end;

procedure TGoogleTranslateTextProcessor.SetTextReceiver(const Reciever
  : ITextEvents);
begin
  FReciever := Reciever;
end;

procedure TGoogleTranslateTextProcessor.HideSettingsWindow;
begin
  FGoogleTranslateSettingsForm.Hide;
end;

procedure TGoogleTranslateTextProcessor.ShowSettingsWindow;
begin
  FGoogleTranslateSettingsForm.Show;
end;

{ TGoogleTranslateInfo }

function TGoogleTranslateInfo.Get_ID: TGUID;
const
  GoogleTranslateID: TGUID = '{5733BF25-4D0F-46B9-8B26-ABA946068864}';
begin
  Result := GoogleTranslateID;
end;

function TGoogleTranslateInfo.Get_Name: WideString;
begin
  Result := 'Google translate';
end;

function TGoogleTranslateInfo.Get_Version: WideString;
begin
  Result := '1.0';
end;

end.
