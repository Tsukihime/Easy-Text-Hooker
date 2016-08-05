unit PutTextToWindowUI;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  //
  WindowCapture;

type
  TPutSettingsForm = class(TForm)
    Label1: TLabel;
    imgSelectWindow: TImage;
    lbClassName: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    lbWndText: TLabel;
    Memo1: TMemo;
    Label4: TLabel;
    procedure imgSelectWindowMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure imgSelectWindowMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    Capture: IWindowCapture;
  public
    procedure SetText(const AText: string);
  end;

implementation

uses
  Initprocs;

{$R *.dfm}

procedure TPutSettingsForm.imgSelectWindowMouseMove(Sender: TObject;
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

procedure TPutSettingsForm.imgSelectWindowMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Screen.Cursor := crDefault;
end;

procedure TPutSettingsForm.SetText(const AText: string);
begin
  if not Assigned(Capture) then
    exit;

  Capture.SetText(AText);
end;

end.
