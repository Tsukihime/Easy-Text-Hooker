program ETH;

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
  jsHighlighter in 'src\jsHighlighter.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Easy Text Hooker';
  Application.CreateForm(TMainForm, MainForm);
  ShowWindow(Application.Handle, SW_HIDE);
  SetWindowLong(Application.Handle, GWL_EXSTYLE,
    GetWindowLong(Application.Handle, GWL_EXSTYLE) and not WS_EX_APPWINDOW or
    WS_EX_TOOLWINDOW);
  ShowWindow(Application.Handle, SW_SHOW);

  Application.Run;

end.
