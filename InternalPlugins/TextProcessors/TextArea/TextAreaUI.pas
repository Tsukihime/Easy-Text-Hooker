unit TextAreaUI;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TTextAreaForm = class(TForm)
    Memo: TMemo;
    Panel2: TPanel;
    FontSet: TButton;
    FontDialog: TFontDialog;
    procedure FontSetClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SetText(const AText: string);
    function WantChildKey(Child: TControl; var Message: TMessage)
      : Boolean; override;
  end;

implementation

{$R *.dfm}
{ TTextAreaForm }

procedure TTextAreaForm.FontSetClick(Sender: TObject);
begin
  FontDialog.Font := Memo.Font;
  if FontDialog.Execute(Handle) then
    Memo.Font := FontDialog.Font;
end;

procedure TTextAreaForm.SetText(const AText: string);
begin
  Memo.Text := AText;
end;

function TTextAreaForm.WantChildKey(Child: TControl;
  var Message: TMessage): Boolean;
begin
  Result := ((Message.Msg = WM_CHAR) and (Message.WParam = VK_TAB)) or
    (Child.Perform(CN_BASE + Message.Msg, Message.WParam, Message.LParam) <> 0);
end;

end.
