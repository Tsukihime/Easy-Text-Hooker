program ETH;

{$R *.dres}

uses
  Forms,
  windows,
  Main in 'src\Main.pas' {MainForm},
  OSD in 'src\OSD.pas' {OSDForm},
  GoogleTranslate in 'src\GoogleTranslate.pas',
  AGTHServer in 'src\AGTHServer.pas',
  PipeServer in 'src\PipeServer.pas',
  Inject in 'src\Inject.pas',
  Pipe in 'src\Pipe.pas',
  AGTHConst in 'src\AGTHConst.pas',
  uSettings in 'src\uSettings.pas',
  jsCore in 'src\jsCore.pas',
  jsHighlighter in 'src\jsHighlighter.pas',
  TextStream in 'src\TextStream.pas',
  Translator in 'src\Translator.pas',
  YandexTranslate in 'src\YandexTranslate.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Easy Text Hooker';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;

end.
