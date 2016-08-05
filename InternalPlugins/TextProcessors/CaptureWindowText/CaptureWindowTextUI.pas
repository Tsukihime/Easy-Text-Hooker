unit CaptureWindowTextUI;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  //
  WindowCapture;

type
  TNewTextNotify = procedure(const AText: string) of object;

  TCaptureSettingsForm = class(TForm)
    Label1: TLabel;
    imgSelectWindow: TImage;
    lbClassName: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    lbWndText: TLabel;
    Memo1: TMemo;
    Label4: TLabel;
    Timer1: TTimer;
    procedure imgSelectWindowMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure imgSelectWindowMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
  private
    Capture: IWindowCapture;
    FOldText: string;
    FOnNewText: TNewTextNotify;
  public
    property OnNewText: TNewTextNotify read FOnNewText write FOnNewText;
  end;

implementation

uses
  Initprocs;

{$R *.dfm}

procedure TCaptureSettingsForm.imgSelectWindowMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  CustomHwnd: THandle;
begin
  if ssLeft in Shift then
  begin
    Screen.Cursor := crCustomCrossHair;
    CustomHwnd := windowFromPoint(Mouse.CursorPos);
    Capture := TWindowCapture.Create(CustomHwnd);
    lbClassName.Caption := Capture.WndClassName;
    lbWndText.Caption := Capture.WindowName;
    Memo1.Text := Capture.GetText;
  end
  else
    Screen.Cursor := crDefault;
end;

procedure TCaptureSettingsForm.imgSelectWindowMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Screen.Cursor := crDefault;
end;

procedure TCaptureSettingsForm.Timer1Timer(Sender: TObject);
var
  Text: string;
begin
  if not Assigned(Capture) then
    exit;

  Text := Capture.GetText;
  if FOldText = Text then
    exit;

  FOldText := Text;

  if Assigned(FOnNewText) then
    FOnNewText(Text);
end;

end.
