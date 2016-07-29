unit GoogleTranslateUI;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  //
  PluginAPI_TLB,
  GoogleTranslate;

type
  TGoogleTranslateSettingsForm = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    SrcLang: TComboBox;
    DestLang: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure LangChange(Sender: TObject);
  private
    FTranslator: TGoogleTranslate;
    FSettings: ISettings;
  public
    constructor CreateParented(AParentWindow: HWND;
      const ATranslator: TGoogleTranslate; const Settings: ISettings); overload;
    function WantChildKey(Child: TControl; var Message: TMessage)
      : Boolean; override;
  end;

implementation

{$R *.dfm}
{ TGoogleTranslateSettingsForm }

constructor TGoogleTranslateSettingsForm.CreateParented(AParentWindow: HWND;
  const ATranslator: TGoogleTranslate; const Settings: ISettings);
begin
  FTranslator := ATranslator;
  FSettings := Settings;
  CreateParented(AParentWindow);
end;

procedure TGoogleTranslateSettingsForm.FormCreate(Sender: TObject);
var
  str: string;
begin
  FTranslator.GetFromLanguages(SrcLang.Items);
  FTranslator.GetToLanguages(DestLang.Items);

  str := FSettings.ReadString('SrcLang', 'Japanese');
  SrcLang.ItemIndex := SrcLang.Items.IndexOf(str);

  str := FSettings.ReadString('DestLang', 'Russian');
  DestLang.ItemIndex := DestLang.Items.IndexOf(str);

  LangChange(SrcLang);
end;

procedure TGoogleTranslateSettingsForm.LangChange(Sender: TObject);
begin
  FSettings.WriteString('SrcLang', SrcLang.Text);
  FSettings.WriteString('DestLang', DestLang.Text);
  FTranslator.SetTranslationDirection(SrcLang.Text, DestLang.Text);
end;

function TGoogleTranslateSettingsForm.WantChildKey(Child: TControl;
  var Message: TMessage): Boolean;
begin
  Result := ((Message.Msg = WM_CHAR) and (Message.WParam = VK_TAB)) or
    (Child.Perform(CN_BASE + Message.Msg, Message.WParam, Message.LParam) <> 0);
end;

end.
