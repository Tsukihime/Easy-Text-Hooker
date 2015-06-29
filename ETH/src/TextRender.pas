// some incapsulated shit
unit TextRender;

interface

uses Windows, Graphics, Types;

type
  TTextRender = class
  private
    FText: string;
    FFont: TFont;
    FOutlineWidth: Integer;
    FOutlineColor: TColor;
    FTextColor: TColor;
    FWidth: Integer;
    FHeight: Integer;
    FDrawWindowOutline: boolean;
    procedure SetFont(Font: TFont);
    procedure Normalize(surface: TBitmap);
    procedure FillPlaneAndDrawText(surface: TBitmap);
    procedure InitAlphaOutline(outline: TBitmap);
    procedure MergeBitmapAlpha(surface: TBitmap; outline: TBitmap);
  public
    constructor Create;
    destructor Destroy; override;
    property Text: string read FText write FText;
    property Font: TFont read FFont write SetFont;
    property TextColor: TColor read FTextColor write FTextColor;
    property OutlineColor: TColor read FOutlineColor write FOutlineColor;
    property OutlineWidth: Integer read FOutlineWidth write FOutlineWidth;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property DrawWindowOutline: boolean read FDrawWindowOutline
      write FDrawWindowOutline;
  public
    procedure RenderText(surface: TBitmap);
  end;

implementation

{ TTextRender }

constructor TTextRender.Create;
begin
  FFont := TFont.Create;
  FOutlineWidth := 1;
  FOutlineColor := clWhite;
  FTextColor := clBlack;
  FDrawWindowOutline := false;
end;

destructor TTextRender.Destroy;
begin
  FFont.Free;
  inherited;
end;

procedure TTextRender.SetFont(Font: TFont);
begin
  FFont.Assign(Font);
end;

procedure TTextRender.FillPlaneAndDrawText(surface: TBitmap);
var
  nCount: Integer;
  lpRect: TRect;
begin
  surface.SetSize(FWidth, FHeight);
  surface.PixelFormat := pf32bit;
  surface.Canvas.Font.Assign(FFont);

  lpRect.TopLeft := Point(FOutlineWidth, FOutlineWidth);
  lpRect.Width := FWidth - FOutlineWidth * 2;
  lpRect.Height := FHeight - FOutlineWidth * 2;

  surface.Canvas.Brush.Style := bsSolid;
  surface.Canvas.Brush.Color := FOutlineColor;
  surface.Canvas.Font.Color := FTextColor;
  surface.Canvas.FillRect(surface.Canvas.ClipRect);

  nCount := length(FText);

  DrawText(surface.Canvas.Handle, PChar(FText), nCount, lpRect, DT_WORDBREAK or
    DT_NOPREFIX);
end;

procedure TTextRender.InitAlphaOutline(outline: TBitmap);
var
  nCount: Integer;
  lpRect: TRect;
  dx, dy: Integer;
  distance: Integer;
  i, k: Integer;
  Pixel: PRGBQuad;
begin
  outline.PixelFormat := pf32bit;
  outline.SetSize(FWidth, FHeight);
  outline.Canvas.Font.Assign(FFont);

  outline.Canvas.Brush.Style := bsSolid;
  outline.Canvas.Brush.Color := clBlack;
  outline.Canvas.FillRect(outline.Canvas.ClipRect);
  outline.Canvas.Font.Color := clWhite;
  outline.Canvas.Brush.Style := bsClear;

  nCount := length(FText);

  for dx := -FOutlineWidth to FOutlineWidth do
    for dy := -FOutlineWidth to FOutlineWidth do
    begin
      distance := round(sqrt(sqr(dx) + sqr(dy)));
      if (distance <= FOutlineWidth) then
      begin
        lpRect.TopLeft := Point(FOutlineWidth + dx, FOutlineWidth + dy);
        lpRect.Width := FWidth - FOutlineWidth * 2;
        lpRect.Height := FHeight - FOutlineWidth * 2;

        DrawText(outline.Canvas.Handle, PChar(FText), nCount, lpRect,
          DT_WORDBREAK or DT_NOPREFIX);
      end;
    end;

  if DrawWindowOutline then
  begin
    outline.Canvas.Pen.Color := $505050;
    outline.Canvas.Rectangle(0, 0, Width - 1, Height - 1);
  end;

  for k := 0 to outline.Height - 1 do
  begin
    Pixel := outline.ScanLine[k];
    for i := 0 to outline.Width - 1 do
    begin
      Pixel.rgbReserved := trunc(Pixel.rgbRed * 0.299 + Pixel.rgbGreen * 0.587 +
        Pixel.rgbBlue * 0.114);
      inc(Pixel, 1);
    end;
  end;
end;

procedure TTextRender.MergeBitmapAlpha(surface, outline: TBitmap);
var
  i, k: Integer;
  src, dst: PRGBQuad;
begin
  for k := 0 to surface.Height - 1 do
  begin
    src := outline.ScanLine[k];
    dst := surface.ScanLine[k];
    for i := 0 to surface.Width - 1 do
    begin
      dst.rgbReserved := src.rgbReserved;
      inc(src, 1);
      inc(dst, 1);
    end;
  end;
end;

procedure TTextRender.Normalize(surface: TBitmap);
var
  i, k: Integer;
  Px: PRGBQuad;
  Alpha: Byte;
begin
  for k := 0 to surface.Height - 1 do
  begin
    Px := surface.ScanLine[k];
    for i := 0 to surface.Width - 1 do
    begin
      Alpha := Px.rgbReserved;
      Px.rgbBlue := Px.rgbBlue * Alpha div 255;
      Px.rgbGreen := Px.rgbGreen * Alpha div 255;
      Px.rgbRed := Px.rgbRed * Alpha div 255;
      inc(Px, 1);
    end;
  end;
end;

procedure TTextRender.RenderText(surface: TBitmap);
var
  AlphaOutline: TBitmap;
begin
  FillPlaneAndDrawText(surface);

  AlphaOutline := TBitmap.Create;
  try
    InitAlphaOutline(AlphaOutline);
    MergeBitmapAlpha(surface, AlphaOutline);
  finally
    AlphaOutline.Free;
  end;

  Normalize(surface);
end;

end.
