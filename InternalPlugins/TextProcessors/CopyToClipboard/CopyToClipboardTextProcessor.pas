unit CopyToClipboardTextProcessor;

interface

uses
  PluginAPI_TLB;

type
  TCopyToClipboardTextProcessor = class(TInterfacedObject, ITextEvents,
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
  public
    constructor Create(const ACore: IApplicationCore);
    destructor Destroy; override;
  end;

  TCopyToClipboardInfo = class(TInterfacedObject, ITextProcessorInfo)
    function Get_Name: WideString; safecall;
    function Get_ID: TGUID; safecall;
    function Get_Version: WideString; safecall;
    property Name: WideString read Get_Name;
    property ID: TGUID read Get_ID;
    property Version: WideString read Get_Version;
  end;

  TCopyToClipboardFactory = class(TInterfacedObject, ITextProcessorFactory)
    function GetNewTextProcessor(const ApplicationCore: IApplicationCore)
      : ITextProcessor; safecall;
  end;

implementation

uses
  Clipbrd;

{ TCopyToClipboardFactory }

function TCopyToClipboardFactory.GetNewTextProcessor(const ApplicationCore
  : IApplicationCore): ITextProcessor;
begin
  Result := TCopyToClipboardTextProcessor.Create(ApplicationCore);
end;

{ TCopyToClipboardTextProcessor }

constructor TCopyToClipboardTextProcessor.Create(const ACore: IApplicationCore);
begin
  FCore := ACore;
end;

destructor TCopyToClipboardTextProcessor.Destroy;
begin
  inherited;
end;

procedure TCopyToClipboardTextProcessor.OnNewText(const Text: WideString);
begin
  try
    Clipboard.AsText := Text;
  except
    // ignore
  end;
end;

procedure TCopyToClipboardTextProcessor.SetTextReceiver(const Reciever
  : ITextEvents);
begin
  // none
end;

procedure TCopyToClipboardTextProcessor.HideSettingsWindow;
begin
  // none
end;

procedure TCopyToClipboardTextProcessor.ShowSettingsWindow;
begin
  // none
end;

{ TCopyToClipboardInfo }

function TCopyToClipboardInfo.Get_ID: TGUID;
const
  CopyToClipboardID: TGUID = '{52992E96-0265-4F88-9726-A2E73F13018C}';
begin
  Result := CopyToClipboardID;
end;

function TCopyToClipboardInfo.Get_Name: WideString;
begin
  Result := 'Copy To Clipboard';
end;

function TCopyToClipboardInfo.Get_Version: WideString;
begin
  Result := '1.0';
end;

end.
