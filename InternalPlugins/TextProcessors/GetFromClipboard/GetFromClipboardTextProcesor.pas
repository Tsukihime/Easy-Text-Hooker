unit GetFromClipboardTextProcesor;

interface

uses
  Classes,
  ExtCtrls,
  PluginAPI_TLB;

type
  TGetFromClipboardTextProcessor = class(TInterfacedObject, ITextEvents,
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
    FTimer: TTimer;
    FLastText: string;
    procedure OnTimer(Sender: TObject);
  public
    constructor Create(const ACore: IApplicationCore);
    destructor Destroy; override;
  end;

  TGetFromClipboardInfo = class(TInterfacedObject, ITextProcessorInfo)
    function Get_Name: WideString; safecall;
    function Get_ID: TGUID; safecall;
    function Get_Version: WideString; safecall;
    property Name: WideString read Get_Name;
    property ID: TGUID read Get_ID;
    property Version: WideString read Get_Version;
  end;

  TGetFromClipboardFactory = class(TInterfacedObject, ITextProcessorFactory)
    function GetNewTextProcessor(const ApplicationCore: IApplicationCore)
      : ITextProcessor; safecall;
  end;

implementation

uses
  Clipbrd;

{ TGetFromClipboardFactory }

function TGetFromClipboardFactory.GetNewTextProcessor(const ApplicationCore
  : IApplicationCore): ITextProcessor;
begin
  Result := TGetFromClipboardTextProcessor.Create(ApplicationCore);
end;

{ TGetFromClipboardTextProcessor }

constructor TGetFromClipboardTextProcessor.Create
  (const ACore: IApplicationCore);
begin
  FCore := ACore;
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 100;
  FTimer.OnTimer := OnTimer;
  FTimer.Enabled := true;
end;

destructor TGetFromClipboardTextProcessor.Destroy;
begin
  FTimer.Free;
  inherited;
end;

procedure TGetFromClipboardTextProcessor.OnNewText(const Text: WideString);
begin
  // none
end;

procedure TGetFromClipboardTextProcessor.OnTimer(Sender: TObject);
var
  Text: string;
begin
  if not Assigned(FReciever) then
    exit;

  try
    Text := Clipboard.AsText;
  except
    exit;
  end;

  if Text <> FLastText then
  begin
    FLastText := Text;
    FReciever.OnNewText(Text);
  end;
end;

procedure TGetFromClipboardTextProcessor.SetTextReceiver(const Reciever
  : ITextEvents);
begin
  FReciever := Reciever;
end;

procedure TGetFromClipboardTextProcessor.HideSettingsWindow;
begin
  // none
end;

procedure TGetFromClipboardTextProcessor.ShowSettingsWindow;
begin
  // none
end;

{ TGetFromClipboardInfo }

function TGetFromClipboardInfo.Get_ID: TGUID;
const
  GetFromClipboardID: TGUID = '{D9EFCA84-CF84-462E-9157-2CE104319D24}';
begin
  Result := GetFromClipboardID;
end;

function TGetFromClipboardInfo.Get_Name: WideString;
begin
  Result := 'Get From Clipboard';
end;

function TGetFromClipboardInfo.Get_Version: WideString;
begin
  Result := '1.0';
end;

end.
