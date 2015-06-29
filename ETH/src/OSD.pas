unit OSD;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  //
  TextRender;

type
  TOSDForm = class(TForm)
    UpdateTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure UpdateTimerTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FX, FY, FWidth, FHeight: Integer;
    FText: string;
    FRender: TTextRender;
    FDrawWindowOutline: boolean;
    procedure UpdateWindow(surface: TBitmap);
    procedure RepaintWindow;
    procedure SetTextColor(const Value: TColor);
    function GetFont: TFont;
    procedure SetFont(Font: TFont);
    procedure SetOutlineColor(const Value: TColor);
    procedure setOutlineWidth(const Value: Integer);
    function GetOutlineColor: TColor;
    function GetOutlineWidth: Integer;
    function GetTextColor: TColor;
    procedure SetDrawWindowOutline(const Value: boolean);
  public
    procedure SetText(Text: widestring);
    procedure SetPosition(X, Y, Width, Height: Integer);

    property TextColor: TColor read GetTextColor write SetTextColor;
    property OutlineColor: TColor read GetOutlineColor write SetOutlineColor;
    property TextFont: TFont read GetFont write SetFont;
    property OutlineWidth: Integer read GetOutlineWidth write setOutlineWidth;
    property DrawWindowOutline: boolean read FDrawWindowOutline
      write SetDrawWindowOutline;
  end;

var
  OSDForm: TOSDForm;

implementation

{$R *.dfm}

procedure TOSDForm.UpdateWindow(surface: TBitmap);
var
  picture_size: TSize;
  ptSrc: TPoint;
  blendfunc: BLENDFUNCTION;
  dcSrc: HDC;
  dcDst: HDC;
begin
  picture_size.cx := Width;
  picture_size.cy := Height;
  ptSrc := Point(0, 0);

  blendfunc.BlendOp := AC_SRC_OVER;
  blendfunc.BlendFlags := 0;
  blendfunc.SourceConstantAlpha := 255;
  blendfunc.AlphaFormat := AC_SRC_ALPHA;

  dcSrc := surface.Canvas.Handle;
  dcDst := self.Handle;

  UpdateLayeredWindow(dcDst, 0, nil, @picture_size, dcSrc, @ptSrc, 0,
    @blendfunc, ULW_ALPHA);
end;

procedure TOSDForm.RepaintWindow;
var
  surface: TBitmap;
begin
  surface := TBitmap.create;
  FRender.Width := Width;
  FRender.Height := Height;
  FRender.RenderText(surface);
  UpdateWindow(surface);
  surface.Free;
end;

procedure TOSDForm.FormResize(Sender: TObject);
begin
  RepaintWindow;
end;

procedure TOSDForm.FormCreate(Sender: TObject);
begin
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or
    WS_EX_TRANSPARENT or WS_EX_LAYERED);

  FRender := TTextRender.create;
end;

procedure TOSDForm.FormDestroy(Sender: TObject);
begin
  FRender.Free;
end;

procedure TOSDForm.SetDrawWindowOutline(const Value: boolean);
begin
  FDrawWindowOutline := Value;
  FRender.DrawWindowOutline := Value;
  RepaintWindow;
end;

procedure TOSDForm.SetFont(Font: TFont);
begin
  FRender.Font := Font;
  RepaintWindow;
end;

procedure TOSDForm.SetOutlineColor(const Value: TColor);
begin
  FRender.OutlineColor := Value;
  RepaintWindow;
end;

procedure TOSDForm.setOutlineWidth(const Value: Integer);
begin
  FRender.OutlineWidth := Value;
  RepaintWindow;
end;

procedure TOSDForm.SetTextColor(const Value: TColor);
begin
  FRender.TextColor := Value;
  RepaintWindow;
end;

function TOSDForm.GetFont: TFont;
begin
  Result := FRender.Font;
end;

function TOSDForm.GetOutlineColor: TColor;
begin
  Result := FRender.OutlineColor;
end;

function TOSDForm.GetOutlineWidth: Integer;
begin
  Result := FRender.OutlineWidth;
end;

function TOSDForm.GetTextColor: TColor;
begin
  Result := FRender.TextColor;
end;

procedure TOSDForm.SetPosition(X, Y, Width, Height: Integer);
begin
  FX := X;
  FY := Y;
  FWidth := Width;
  FHeight := Height;
  UpdateTimerTimer(UpdateTimer);
end;

procedure TOSDForm.SetText(Text: widestring);
begin
  if FText <> Text then
  begin
    FText := Text;
    FRender.Text := Text;
    RepaintWindow;
  end;
end;

procedure TOSDForm.UpdateTimerTimer(Sender: TObject);
begin
  Width := round(Screen.Width * FWidth / 100);
  Height := round(Screen.Height * FHeight / 100);
  Left := round((Screen.Width - Width) * FX / 100);
  Top := round((Screen.Height - Height) * FY / 100);

  SetWindowPos(Handle, HWND_TOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE or
    SWP_NOMOVE or SWP_NOSIZE);
end;

end.
