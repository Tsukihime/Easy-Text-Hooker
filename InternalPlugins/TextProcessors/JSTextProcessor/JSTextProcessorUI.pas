unit JSTextProcessorUI;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls,
  //
  PluginAPI_TLB,
  jsCore;

type
  TJSTextProcessorForm = class(TForm)
    ScriptArea: TRichEdit;
    Panel1: TPanel;
    btnScriptLoad: TButton;
    mScriptPath: TMemo;
    JSOpenDialog: TOpenDialog;
    procedure btnScriptLoadClick(Sender: TObject);
  private
    FJSCore: TJavaScriptCore;
    FSettings: ISettings;
  public
    procedure LoadScript(path: string);
    constructor CreateParented(AParentWindow: HWnd;
      const AJSCore: TJavaScriptCore; const Settings: ISettings); overload;
    function WantChildKey(Child: TControl; var Message: TMessage)
      : Boolean; override;
  end;

implementation

uses
  jsHighlighter;

{$R *.dfm}

constructor TJSTextProcessorForm.CreateParented(AParentWindow: HWnd;
  const AJSCore: TJavaScriptCore; const Settings: ISettings);
var
  ScriptPath: string;
begin
  FJSCore := AJSCore;
  FSettings := Settings;
  CreateParented(AParentWindow);

  ScriptPath := Settings.ReadString('ScriptPath', '');
  if ScriptPath <> '' then
    LoadScript(ScriptPath);
end;

procedure TJSTextProcessorForm.btnScriptLoadClick(Sender: TObject);
begin
  JSOpenDialog.Filter := '*.js|*.js';
  JSOpenDialog.InitialDir := ExtractFilePath(paramstr(0));
  if JSOpenDialog.Execute(Self.Handle) then
    LoadScript(JSOpenDialog.FileName);
end;

procedure TJSTextProcessorForm.LoadScript(path: string);
begin
  mScriptPath.Text := path;
  FJSCore.LoadScript(path);
  ScriptArea.Text := FJSCore.Script;
  TRichEditJsHighlighter.jsHighlight(ScriptArea);
  FSettings.WriteString('ScriptPath', FJSCore.ScriptPath);
end;

function TJSTextProcessorForm.WantChildKey(Child: TControl;
  var Message: TMessage): Boolean;
begin
  Result := ((Message.Msg = WM_CHAR) and (Message.WParam = VK_TAB)) or
    (Child.Perform(CN_BASE + Message.Msg, Message.WParam, Message.LParam) <> 0);
end;

end.
