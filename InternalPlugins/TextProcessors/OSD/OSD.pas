unit OSD;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Types, System.UITypes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  //
  Math,
  GdipObj,
  GdipApi;

type
  TOSDForm = class(TForm)
    UpdateTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure UpdateTimerTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    FX, FY, FWidth, FHeight: Integer;
    FText: string;
    FOutlineColor: TColor;
    FTextColor: TColor;
    FOutlineWidth: Integer;
    FDrawWindowOutline: boolean;
    FSticky: boolean;
    FBoundRect: TRect;
    FMainFormHandle: HWND;
    FBackgroundColor: TColor;
    FBackgroundTransparency: Integer;
    procedure UpdateWindow(Surface: TGPBitmap);
    procedure RepaintWindow;
    procedure SetTextColor(const Value: TColor);
    function GetFont: TFont;
    procedure SetFont(Font: TFont);
    procedure SetOutlineColor(const Value: TColor);
    procedure setOutlineWidth(const Value: Integer);
    procedure SetDrawWindowOutline(const Value: boolean);
    function BGR2ARGB(col: TColor; Alpha: UInt8 = 255): Cardinal;
    function FontStyle2GPFontStyle(Style: TFontStyles): Integer;
    procedure SetSticky(const Value: boolean);
    procedure SetBackgroundColor(const Value: TColor);
    procedure SetBackgroundTransparency(const Value: Integer);
  public
    procedure SetText(Text: widestring);
    procedure SetPosition(X, Y, Width, Height: Integer);

    property TextColor: TColor read FTextColor write SetTextColor;
    property OutlineColor: TColor read FOutlineColor write SetOutlineColor;
    property BackgroundColor: TColor read FBackgroundColor
      write SetBackgroundColor;
    property BackgroundTransparency: Integer read FBackgroundTransparency
      write SetBackgroundTransparency;
    property TextFont: TFont read GetFont write SetFont;
    property OutlineWidth: Integer read FOutlineWidth write setOutlineWidth;
    property DrawWindowOutline: boolean read FDrawWindowOutline
      write SetDrawWindowOutline;
    property Sticky: boolean read FSticky write SetSticky;
    property MainFormHandle: HWND read FMainFormHandle write FMainFormHandle;
  end;

implementation

{$R *.dfm}

procedure TOSDForm.UpdateWindow(Surface: TGPBitmap);
var
  picture_size: TSize;
  ptSrc: TPoint;
  blendfunc: BLENDFUNCTION;
  dcSrc: HDC;
  dcDst: HDC;
  BitmapHandle, PrevBitmap: HBITMAP;
begin
  picture_size.cx := Width;
  picture_size.cy := Height;
  ptSrc := Point(0, 0);

  blendfunc.BlendOp := AC_SRC_OVER;
  blendfunc.BlendFlags := 0;
  blendfunc.SourceConstantAlpha := 255;
  blendfunc.AlphaFormat := AC_SRC_ALPHA;

  dcDst := self.Handle;

  dcSrc := CreateCompatibleDC(0);
  Surface.GetHBITMAP(0, BitmapHandle);
  PrevBitmap := SelectObject(dcSrc, BitmapHandle);

  UpdateLayeredWindow(dcDst, 0, nil, @picture_size, dcSrc, @ptSrc, 0,
    @blendfunc, ULW_ALPHA);

  SelectObject(dcSrc, PrevBitmap);
  DeleteObject(BitmapHandle);
  DeleteDC(dcSrc);
end;

function TOSDForm.BGR2ARGB(col: TColor; Alpha: UInt8): Cardinal;
var
  r, g, b: byte;
begin
  r := col and $FF;
  g := col shr 8 and $FF;
  b := col shr 16 and $FF;
  Result := RGB(b, g, r) or (Alpha shl 24);
end;

function TOSDForm.FontStyle2GPFontStyle(Style: TFontStyles): Integer;
begin
  Result := FontStyleRegular;
  if fsBold in TextFont.Style then
    Result := Result or FontStyleBold;
  if fsItalic in TextFont.Style then
    Result := Result or FontStyleItalic;
  if fsUnderline in TextFont.Style then
    Result := Result or FontStyleUnderline;
  if fsStrikeOut in TextFont.Style then
    Result := Result or FontStyleStrikeout;
end;

procedure TOSDForm.RepaintWindow;
var
  Surface: TGPBitmap;
  Graphics: TGPGraphics;
  Pen: TGPPen;
  TextBrush, OutlineBrush, BGBrush: TGPSolidBrush;
  WindowRect, TextRect, OutlineRect: TGPRectF;
  FontFamily: TGPFontFamily;
  GPFont: TGPFont;
  GPStringFormat: TGPStringFormat;
  dx, dy, distance: Integer;
begin
  Surface := TGPBitmap.Create(Width, Height, PixelFormat32bppARGB);
  try
    Graphics := TGPGraphics.Create(Surface);
    try
      Graphics.SetTextRenderingHint(TextRenderingHintAntiAliasGridFit);
      Graphics.Clear(0);

      WindowRect.X := 0;
      WindowRect.Y := 0;
      WindowRect.Width := Width - 1;
      WindowRect.Height := Height - 1;

      BGBrush := TGPSolidBrush.Create(BGR2ARGB(FBackgroundColor,
        FBackgroundTransparency));
      Graphics.FillRectangle(BGBrush, WindowRect);
      BGBrush.Free;

      if FDrawWindowOutline then
      begin
        Pen := TGPPen.Create(BGR2ARGB(FOutlineColor), FOutlineWidth);
        Graphics.DrawRectangle(Pen, WindowRect);
        Pen.Free;
      end;

      TextBrush := TGPSolidBrush.Create(BGR2ARGB(FTextColor));
      FontFamily := TGPFontFamily.Create(TextFont.Name);
      GPFont := TGPFont.Create(FontFamily, TextFont.Size,
        FontStyle2GPFontStyle(TextFont.Style), UnitPoint);

      GPStringFormat := TGPStringFormat.Create;

      // draw outline
      OutlineBrush := TGPSolidBrush.Create(BGR2ARGB(FOutlineColor));
      for dx := -FOutlineWidth to FOutlineWidth do
        for dy := -FOutlineWidth to FOutlineWidth do
        begin
          distance := Round(Hypot(dx, dy));
          if (distance <= FOutlineWidth) and (distance >= 1) then
          begin
            OutlineRect.X := FOutlineWidth + dx;
            OutlineRect.Y := FOutlineWidth + dy;
            OutlineRect.Width := Width - FOutlineWidth * 2;
            OutlineRect.Height := Height - FOutlineWidth * 2;

            Graphics.DrawString(FText, length(FText), GPFont, OutlineRect,
              GPStringFormat, OutlineBrush);
          end;
        end;
      OutlineBrush.Free;

      // draw text
      TextRect.X := FOutlineWidth;
      TextRect.Y := FOutlineWidth;
      TextRect.Width := Width - FOutlineWidth * 2;
      TextRect.Height := Height - FOutlineWidth * 2;

      Graphics.DrawString(FText, length(FText), GPFont, TextRect,
        GPStringFormat, TextBrush);

      UpdateWindow(Surface);

      GPStringFormat.Free;
      GPFont.Free;
      FontFamily.Free;
    finally
      Graphics.Free;
    end;
  finally
    Surface.Free;
  end;
end;

procedure TOSDForm.FormResize(Sender: TObject);
begin
  RepaintWindow;
end;

procedure TOSDForm.FormCreate(Sender: TObject);
var
  WindowStyle: NativeInt;
begin
  WindowStyle := GetWindowLong(Handle, GWL_EXSTYLE);
  WindowStyle := WindowStyle and not WS_EX_APPWINDOW;
  WindowStyle := WindowStyle or WS_EX_TRANSPARENT or WS_EX_LAYERED or
    WS_EX_TOOLWINDOW;

  SetWindowLong(Handle, GWL_EXSTYLE, WindowStyle);
  FBoundRect := Screen.DesktopRect;
end;

procedure TOSDForm.SetBackgroundColor(const Value: TColor);
begin
  FBackgroundColor := Value;
  RepaintWindow;
end;

procedure TOSDForm.SetBackgroundTransparency(const Value: Integer);
begin
  FBackgroundTransparency := Value;
  RepaintWindow;
end;

procedure TOSDForm.SetDrawWindowOutline(const Value: boolean);
begin
  if FDrawWindowOutline <> Value then
  begin
    FDrawWindowOutline := Value;
    RepaintWindow;
  end;
end;

procedure TOSDForm.SetFont(Font: TFont);
begin
  self.Font.Assign(Font);
  RepaintWindow;
end;

procedure TOSDForm.SetOutlineColor(const Value: TColor);
begin
  FOutlineColor := Value;
  RepaintWindow;
end;

procedure TOSDForm.setOutlineWidth(const Value: Integer);
begin
  FOutlineWidth := Value;
  RepaintWindow;
end;

procedure TOSDForm.SetTextColor(const Value: TColor);
begin
  FTextColor := Value;
  RepaintWindow;
end;

function TOSDForm.GetFont: TFont;
begin
  Result := self.Font;
end;

procedure TOSDForm.SetPosition(X, Y, Width, Height: Integer);
begin
  FX := X;
  FY := Y;
  FWidth := Width;
  FHeight := Height;
  UpdateTimerTimer(UpdateTimer);
end;

procedure TOSDForm.SetSticky(const Value: boolean);
begin
  FSticky := Value;
  if not Sticky then
    FBoundRect := Screen.DesktopRect;
end;

procedure TOSDForm.SetText(Text: widestring);
begin
  if FText <> Text then
  begin
    FText := Text;
    RepaintWindow;
  end;
end;

procedure TOSDForm.UpdateTimerTimer(Sender: TObject);
var
  ForegroundHWND: THandle;
  ForegroundPID: Cardinal;
  SelfForeground: boolean;
begin
  if Sticky then
  begin
    ForegroundHWND := GetForegroundWindow();
    GetWindowThreadProcessId(ForegroundHWND, @ForegroundPID);
    SelfForeground := (ForegroundPID = GetCurrentProcessId);

    DrawWindowOutline := SelfForeground;

    if (ForegroundHWND <> 0) and not SelfForeground then
    begin
      GetWindowRect(ForegroundHWND, FBoundRect);
    end;
  end;

  Width := Round(FBoundRect.Width * FWidth / 100);
  Height := Round(FBoundRect.Height * FHeight / 100);
  Left := FBoundRect.Left + Round((FBoundRect.Width - Width) * FX / 100);
  Top := FBoundRect.Top + Round((FBoundRect.Height - Height) * FY / 100);

  SetWindowPos(Handle, HWND_TOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE);
end;

end.
