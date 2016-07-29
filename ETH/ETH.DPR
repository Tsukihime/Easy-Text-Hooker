program ETH;

{$WARN SYMBOL_PLATFORM OFF}

uses
  Forms,
  Main in 'src\Main.pas' {MainForm},
  TextProcessorProvider in 'src\Core\TextProcessorProvider.pas',
  TextPublisher in 'src\Core\TextPublisher.pas',
  TextProcessorManager in 'src\Core\TextProcessorManager.pas',
  ApplicationCore in 'src\Core\ApplicationCore.pas',
  SettingsNode in 'src\Core\SettingsNode.pas',
  SettingsFile in 'src\Core\SettingsFile.pas',
  TextProcessorNode in 'src\Core\TextProcessorNode.pas' {,
    PluginAPI_TLB in 'src\PluginAPI\Headers\PluginAPI_TLB.pas';

    {$R *.res},
  HostPluginUIPanel in 'src\HostPluginUIPanel.pas',
  PluginAPI_TLB in 'src\PluginAPI\Headers\PluginAPI_TLB.pas',
  PluginManager in 'src\Core\PluginManager.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Easy Text Hooker';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;

end.
