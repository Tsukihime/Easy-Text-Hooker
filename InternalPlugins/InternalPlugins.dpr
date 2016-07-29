library InternalPlugins;

{$R *.dres}

uses
  Winapi.GDIPAPI,
  Winapi.GDIPOBJ,
  PluginAPI_TLB in '..\ETH\src\PluginAPI\Headers\PluginAPI_TLB.pas',
  AGTHConst in 'TextProcessors\AGTH\AGTHConst.pas',
  AGTHServer in 'TextProcessors\AGTH\AGTHServer.pas',
  AGTHTextProcessor in 'TextProcessors\AGTH\AGTHTextProcessor.pas',
  AGTHUI in 'TextProcessors\AGTH\AGTHUI.pas' {AGTHForm} ,
  Inject in 'TextProcessors\AGTH\Inject.pas',
  PipeServer in 'TextProcessors\AGTH\PipeServer.pas',
  TextStream in 'TextProcessors\AGTH\TextStream.pas',
  GoogleTranslate in 'TextProcessors\GoogleTranslate\GoogleTranslate.pas',
  GoogleTranslateTextProcessor
    in 'TextProcessors\GoogleTranslate\GoogleTranslateTextProcessor.pas',
  GoogleTranslateUI
    in 'TextProcessors\GoogleTranslate\GoogleTranslateUI.pas' {GoogleTranslateSettingsForm} ,
  JavaScriptTextProcessor
    in 'TextProcessors\JSTextProcessor\JavaScriptTextProcessor.pas',
  jsCore in 'TextProcessors\JSTextProcessor\jsCore.pas',
  jsHighlighter in 'TextProcessors\JSTextProcessor\jsHighlighter.pas',
  JSTextProcessorUI
    in 'TextProcessors\JSTextProcessor\JSTextProcessorUI.pas' {JSTextProcessorForm} ,
  OSD in 'TextProcessors\OSD\OSD.pas' {OSDForm} ,
  OSDTextProcessor in 'TextProcessors\OSD\OSDTextProcessor.pas',
  OSDTextProcessorUI
    in 'TextProcessors\OSD\OSDTextProcessorUI.pas' {OSDSettings} ,
  TextArea in 'TextProcessors\TextArea\TextArea.pas',
  TextAreaUI in 'TextProcessors\TextArea\TextAreaUI.pas' {TextAreaForm} ,
  DllTreadSynchronizer in 'TextProcessors\DllTreadSynchronizer.pas',
  CopyToClipboardTextProcessor
    in 'TextProcessors\CopyToClipboard\CopyToClipboardTextProcessor.pas',
  GetFromClipboardTextProcesor
    in 'TextProcessors\GetFromClipboard\GetFromClipboardTextProcesor.pas';

{$R *.res}

procedure InitializeGDIPlus;
begin // Initialize StartupInput structure
  StartupInput.DebugEventCallback := nil;
  StartupInput.SuppressBackgroundThread := False;
  StartupInput.SuppressExternalCodecs := False;
  StartupInput.GdiplusVersion := 1;

  GdiplusStartup(gdiplusToken, @StartupInput, nil);
end;

procedure FinalizeGDIPlus;
begin
  if Assigned(GenericSansSerifFontFamily) then
    GenericSansSerifFontFamily.Free;
  if Assigned(GenericSerifFontFamily) then
    GenericSerifFontFamily.Free;
  if Assigned(GenericMonospaceFontFamily) then
    GenericMonospaceFontFamily.Free;
  if Assigned(GenericTypographicStringFormatBuffer) then
    GenericTypographicStringFormatBuffer.Free;
  if Assigned(GenericDefaultStringFormatBuffer) then
    GenericDefaultStringFormatBuffer.Free;

  GdiplusShutdown(gdiplusToken);
end;

procedure ETHInitializeTextProcessors(const Registry
  : ITextProcessorRegistry); stdcall;
begin
  InitializeDllTreadSynchronizer;
  InitializeGDIPlus;

  Registry.RegisterFactory(TAGTHFactory.Create, TAGTHInfo.Create);
  Registry.RegisterFactory(TGoogleTraranslateFactory.Create,
    TGoogleTranslateInfo.Create);
  Registry.RegisterFactory(TJavaScriptFactory.Create, TJavaScriptInfo.Create);
  Registry.RegisterFactory(TOSDFactory.Create, TOSDInfo.Create);
  Registry.RegisterFactory(TTextAreaFactory.Create, TTextAreaInfo.Create);
  Registry.RegisterFactory(TCopyToClipboardFactory.Create,
    TCopyToClipboardInfo.Create);
  Registry.RegisterFactory(TGetFromClipboardFactory.Create,
    TGetFromClipboardInfo.Create);

end;

procedure ETHFinalize; stdcall;
begin
  FinalizeGDIPlus;
  FinalizeDllTreadSynchronizer;
end;

exports
  ETHInitializeTextProcessors,
  ETHFinalize;

begin

end.
