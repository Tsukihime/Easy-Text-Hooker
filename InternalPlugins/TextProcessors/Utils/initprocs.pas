unit initprocs;

interface

const
  crCustomCrossHair = 1;

procedure Init;
procedure Finalize;

implementation

uses
  Winapi.GDIPAPI,
  Winapi.GDIPOBJ,
  Winapi.Windows,
  Vcl.Forms,
  DllTreadSynchronizer;

procedure InitializeGDIPlus;
begin // Initialize StartupInput structure
  StartupInput.DebugEventCallback := nil;
  StartupInput.SuppressBackgroundThread := False;
  StartupInput.SuppressExternalCodecs := False;
  StartupInput.GdiplusVersion := 1;

  GdiplusStartup(gdiplusToken, @StartupInput, nil);
end;

procedure FinalizeGDIPlus;
begin
  if Assigned(GenericSansSerifFontFamily) then
    GenericSansSerifFontFamily.Free;
  if Assigned(GenericSerifFontFamily) then
    GenericSerifFontFamily.Free;
  if Assigned(GenericMonospaceFontFamily) then
    GenericMonospaceFontFamily.Free;
  if Assigned(GenericTypographicStringFormatBuffer) then
    GenericTypographicStringFormatBuffer.Free;
  if Assigned(GenericDefaultStringFormatBuffer) then
    GenericDefaultStringFormatBuffer.Free;

  GdiplusShutdown(gdiplusToken);
end;

procedure Init;
begin
  InitializeDllTreadSynchronizer;
  InitializeGDIPlus;
  Screen.Cursors[crCustomCrossHair] := LoadCursor(hInstance, 'CrosshairCursor');
end;

procedure Finalize;
begin
  FinalizeGDIPlus;
  FinalizeDllTreadSynchronizer;
end;

end.
