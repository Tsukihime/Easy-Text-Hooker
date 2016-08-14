unit OSDTextProcessorUI;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls,
  //
  OSD;

type
  TOSDSettings = class(TForm)
    Font: TGroupBox;
    Label14: TLabel;
    Label15: TLabel;
    imgTextColor: TImage;
    imgOutlineColor: TImage;
    Label16: TLabel;
    btnOsdFontSelect: TButton;
    tbOutline: TTrackBar;
    GroupBox4: TGroupBox;
    Label2: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    tbX: TTrackBar;
    tbY: TTrackBar;
    tbWidth: TTrackBar;
    tbHeight: TTrackBar;
    cbSticky: TCheckBox;
    cbHideOSD: TCheckBox;
    ColorDialog1: TColorDialog;
    FontDialog: TFontDialog;
    Label1: TLabel;
    imgBackgroundColor: TImage;
    Label3: TLabel;
    tbBackgroundTransparency: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure imgOutlineColorClick(Sender: TObject);
    procedure imgTextColorClick(Sender: TObject);
    procedure btnOsdFontSelectClick(Sender: TObject);
    procedure tbOutlineChange(Sender: TObject);
    procedure OSDPosChange(Sender: TObject);
    procedure cbStickyClick(Sender: TObject);
    procedure cbHideOSDClick(Sender: TObject);
    procedure imgBackgroundColorClick(Sender: TObject);
    procedure tbBackgroundTransparencyChange(Sender: TObject);
  private
    FOSDForm: TOSDForm;
    FMainFormHandle: HWnd;
  public
    property OSDForm: TOSDForm read FOSDForm;
    procedure UpdateColorBoxes;
    constructor CreateParented(ParentWindow: HWnd;
      MainFormHandle: HWnd); overload;
    function WantChildKey(Child: TControl; var Message: TMessage)
      : Boolean; override;
  end;

implementation

{$R *.dfm}

procedure TOSDSettings.btnOsdFontSelectClick(Sender: TObject);
begin
  FontDialog.Font := OSDForm.TextFont;
  if FontDialog.Execute then
    OSDForm.TextFont := FontDialog.Font;
end;

procedure TOSDSettings.cbHideOSDClick(Sender: TObject);
begin
  if cbHideOSD.checked then
    OSDForm.Hide
  else
    OSDForm.Show;
end;

procedure TOSDSettings.cbStickyClick(Sender: TObject);
begin
  OSDForm.Sticky := cbSticky.checked;
end;

constructor TOSDSettings.CreateParented(ParentWindow, MainFormHandle: HWnd);
begin
  FMainFormHandle := MainFormHandle;
  CreateParented(ParentWindow);
end;

procedure TOSDSettings.FormCreate(Sender: TObject);
begin
  FOSDForm := TOSDForm.Create(nil);
  FOSDForm.MainFormHandle := FMainFormHandle;
end;

procedure TOSDSettings.FormDestroy(Sender: TObject);
begin
  FOSDForm.Free;
end;

procedure TOSDSettings.imgBackgroundColorClick(Sender: TObject);
begin
  ColorDialog1.Color := OSDForm.BackgroundColor;
  if ColorDialog1.Execute(Handle) then
    OSDForm.BackgroundColor := ColorDialog1.Color;
  UpdateColorBoxes;
end;

procedure TOSDSettings.imgOutlineColorClick(Sender: TObject);
begin
  ColorDialog1.Color := OSDForm.OutlineColor;
  if ColorDialog1.Execute(Handle) then
    OSDForm.OutlineColor := ColorDialog1.Color;
  UpdateColorBoxes;
end;

procedure TOSDSettings.imgTextColorClick(Sender: TObject);
begin
  ColorDialog1.Color := OSDForm.TextColor;
  if ColorDialog1.Execute(Handle) then
    OSDForm.TextColor := ColorDialog1.Color;
  UpdateColorBoxes;
end;

procedure TOSDSettings.tbOutlineChange(Sender: TObject);
begin
  OSDForm.OutlineWidth := tbOutline.Position;
end;

procedure TOSDSettings.tbBackgroundTransparencyChange(Sender: TObject);
begin
  OSDForm.BackgroundTransparency := tbBackgroundTransparency.Position;
end;

procedure TOSDSettings.UpdateColorBoxes;
begin
  with imgTextColor.Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := OSDForm.TextColor;
    FillRect(ClipRect);

    Pen.Color := clBlack;
    Rectangle(0, 0, imgTextColor.Width, imgTextColor.Height);
  end;

  with imgOutlineColor.Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := OSDForm.OutlineColor;
    FillRect(ClipRect);

    Pen.Color := clBlack;
    Rectangle(0, 0, imgOutlineColor.Width, imgOutlineColor.Height);
  end;

  with imgBackgroundColor.Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := OSDForm.BackgroundColor;
    FillRect(ClipRect);

    Pen.Color := clBlack;
    Rectangle(0, 0, imgBackgroundColor.Width, imgBackgroundColor.Height);
  end;
end;

procedure TOSDSettings.OSDPosChange(Sender: TObject);
begin
  OSDForm.SetPosition(tbX.Position, tbY.Position, tbWidth.Position,
    tbHeight.Position);
end;

function TOSDSettings.WantChildKey(Child: TControl;
  var Message: TMessage): Boolean;
begin
  Result := ((Message.Msg = WM_CHAR) and (Message.WParam = VK_TAB)) or
    (Child.Perform(CN_BASE + Message.Msg, Message.WParam, Message.LParam) <> 0);
end;

end.
