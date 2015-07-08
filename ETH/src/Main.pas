unit Main;

interface

uses Vcl.Samples.Spin, Vcl.ImgList, Vcl.Controls, Vcl.StdCtrls, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.ComCtrls, System.Classes, Forms, Types, Winapi.Messages,
  //
  AGTHServer,
  jsCore,
  jsHighlighter;

type
  TMainForm = class(TForm)
    OSDTimer: TTimer;
    FontDialog: TFontDialog;
    PageControl: TPageControl;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Memo: TMemo;
    TabSheet4: TTabSheet;
    Memo1: TMemo;
    cbStreams: TComboBox;
    GroupBox2: TGroupBox;
    cbProcess: TComboBox;
    Label7: TLabel;
    edHCode: TEdit;
    Label8: TLabel;
    btnHook: TButton;
    ProcIcon: TImageList;
    Images: TImageList;
    TabSheet5: TTabSheet;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    DoTranslate: TCheckBox;
    srclen: TComboBox;
    destlen: TComboBox;
    GroupBox3: TGroupBox;
    rbClipboard: TRadioButton;
    rbText: TRadioButton;
    cbEnableOSD: TCheckBox;
    GroupBox4: TGroupBox;
    tbX: TTrackBar;
    Label2: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    tbY: TTrackBar;
    tbWidth: TTrackBar;
    tbHeight: TTrackBar;
    seDelay: TSpinEdit;
    Label12: TLabel;
    Label13: TLabel;
    Шрифт: TGroupBox;
    btnOsdFontSelect: TButton;
    Label14: TLabel;
    Label15: TLabel;
    imgTextColor: TImage;
    imgOutlineColor: TImage;
    ColorDialog1: TColorDialog;
    tbOutline: TTrackBar;
    Label16: TLabel;
    js_preProcess: TTabSheet;
    Panel1: TPanel;
    btnScriptLoad: TButton;
    OpenDialog: TOpenDialog;
    chbTextProcessor: TCheckBox;
    ScriptArea: TRichEdit;
    mScriptPath: TMemo;
    Panel2: TPanel;
    FontSet: TButton;
    ClipboardCopy: TCheckBox;
    Label3: TLabel;
    Label4: TLabel;
    cbSticky: TCheckBox;
    procedure OSDTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FontSetClick(Sender: TObject);
    procedure cbStreamsChange(Sender: TObject);
    procedure cbEnableOSDClick(Sender: TObject);
    procedure cbProcessDropDown(Sender: TObject);
    procedure cbProcessDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure btnHookClick(Sender: TObject);
    procedure OSDPosChange(Sender: TObject);
    procedure seDelayChange(Sender: TObject);
    procedure btnOsdFontSelectClick(Sender: TObject);
    procedure imgTextColorClick(Sender: TObject);
    procedure imgOutlineColorClick(Sender: TObject);
    procedure tbOutlineChange(Sender: TObject);
    procedure btnScriptLoadClick(Sender: TObject);
    procedure cbStickyClick(Sender: TObject);
    procedure cbProcessChange(Sender: TObject);
  private
    procedure OnNewStream(lines: TStrings);
    procedure OnNewText(Text: widestring);

    procedure SaveSettings;
    procedure LoadSettings;

    function Translate(Text: widestring): widestring;
    procedure UpdateColorBoxes;

    procedure LoadScript(path: string);
  private
    agserv: TAGTHServer;
    jstp: JavaScriptTextProcessor;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMSyscommand(var Message: TWmSysCommand); message WM_SYSCOMMAND;
    procedure WMActivate(var Message: TWMActivate); message WM_ACTIVATE;
    procedure ApplicationFocusChanged(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

uses psapi, shellapi, CLIPBRD, SysUtils, Windows,
  System.UITypes, Graphics,
  //
  OSD, Inject, GoogleTranslate, uSettings;

{$R *.dfm}

// http://www.transl-gunsmoker.ru/2009/03/windows-vista-delphi-1.html?m=1
// http://www.transl-gunsmoker.ru/2009/03/windows-vista-delphi-2.html?m=1
procedure TMainForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle and not WS_EX_TOOLWINDOW or WS_EX_APPWINDOW;
end;

procedure TMainForm.WMActivate(var Message: TWMActivate);
begin
  if (message.Active = WA_ACTIVE) and not IsWindowEnabled(Handle) then
  begin
    SetActiveWindow(Application.Handle);
    message.Result := 0;
  end
  else
    inherited;
end;

procedure TMainForm.WMSyscommand(var Message: TWmSysCommand);
begin
  case (message.CmdType and $FFF0) of
    SC_MINIMIZE:
      begin
        ShowWindow(Handle, SW_MINIMIZE);
        message.Result := 0;
      end;
    SC_RESTORE:
      begin
        ShowWindow(Handle, SW_RESTORE);
        message.Result := 0;
      end;
  else
    inherited;
  end;
end;
// ^^

procedure TMainForm.SaveSettings;
var
  Settings: TSettingsFile;
begin
  Settings := TSettingsFile.Create('Config', 'Easy Text Hooker', True);
  try
    Settings.WriteBool('Main', 'ClipboardCopy', ClipboardCopy.checked);
    Settings.WriteInteger('Main', 'CurrentTab', PageControl.TabIndex);

    Settings.BeginSection('Font');
    Settings.WriteString('Name', Memo.Font.Name);
    Settings.WriteInteger('CharSet', Memo.Font.CharSet);
    Settings.WriteString('Color', inttohex(Memo.Font.Color, 8));
    Settings.WriteInteger('Size', Memo.Font.Size);
    Settings.WriteInteger('Style', Byte(Memo.Font.Style));
    Settings.EndSection;

    Settings.BeginSection('GoogleTranslate');
    Settings.WriteBool('DoTranslate', DoTranslate.checked);
    Settings.WriteInteger('SrcLang', srclen.ItemIndex);
    Settings.WriteInteger('DestLang', destlen.ItemIndex);
    Settings.EndSection;

    Settings.BeginSection('OSD');
    Settings.WriteBool('EnableOSD', cbEnableOSD.checked);
    Settings.WriteBool('FromClipboard', rbClipboard.checked);
    Settings.WriteBool('FromTextarea', rbText.checked);
    Settings.WriteInteger('PositionX', tbX.Position);
    Settings.WriteInteger('PositionY', tbY.Position);
    Settings.WriteInteger('PositionWidth', tbWidth.Position);
    Settings.WriteInteger('PositionHeight', tbHeight.Position);
    Settings.WriteString('FontName', OSDForm.TextFont.Name);
    Settings.WriteInteger('FontCharSet', OSDForm.TextFont.CharSet);
    Settings.WriteInteger('FontSize', OSDForm.TextFont.Size);
    Settings.WriteInteger('FontStyle', Byte(OSDForm.TextFont.Style));
    Settings.WriteString('FontColor', inttohex(OSDForm.TextColor, 8));
    Settings.WriteString('OutlineColor', inttohex(OSDForm.OutlineColor, 8));
    Settings.WriteInteger('OutlineWidth', OSDForm.OutlineWidth);
    Settings.WriteBool('Sticky', cbSticky.checked);
    Settings.EndSection;

    Settings.BeginSection('AGTH');
    Settings.WriteString('HCode', edHCode.Text);
    Settings.WriteInteger('CopyDelay', seDelay.Value);
    Settings.EndSection;

    Settings.BeginSection('jstp');
    Settings.WriteString('ScriptPath', jstp.ScriptPath);
    Settings.WriteBool('EnablePreProcess', chbTextProcessor.checked);
    Settings.EndSection;
  finally
    Settings.Free;
  end;
end;

procedure TMainForm.LoadSettings;
var
  Settings: TSettingsFile;
begin
  Settings := TSettingsFile.Create('Config', 'Easy Text Hooker', True);
  try
    ClipboardCopy.checked := Settings.ReadBool('Main', 'ClipboardCopy', False);
    PageControl.TabIndex := Settings.ReadInteger('Main', 'CurrentTab', 0);

    Memo.Font.Name := Settings.ReadString('Font', 'Name', Memo.Font.Name);
    Memo.Font.CharSet := Byte(Settings.ReadInteger('Font', 'CharSet',
      Memo.Font.CharSet));
    Memo.Font.Color := StrToInt('$' + Settings.ReadString('Font', 'Color',
      inttohex(Memo.Font.Color, 8)));
    Memo.Font.Size := Settings.ReadInteger('Font', 'Size', Memo.Font.Size);
    Memo.Font.Style := TFontStyles(Byte(Settings.ReadInteger('Font', 'Style',
      Byte(Memo.Font.Style))));

    Settings.BeginSection('GoogleTranslate');
    DoTranslate.checked := Settings.ReadBool('DoTranslate', False);

    srclen.ItemIndex := Settings.ReadInteger('SrcLang', 32);
    destlen.ItemIndex := Settings.ReadInteger('DestLang', 45);
    Settings.EndSection;

    Settings.BeginSection('OSD');
    cbEnableOSD.checked := Settings.ReadBool('EnableOSD', False);
    rbClipboard.checked := Settings.ReadBool('FromClipboard', False);
    rbText.checked := Settings.ReadBool('FromTextarea', True);

    tbX.Position := Settings.ReadInteger('PositionX', 50);
    tbY.Position := Settings.ReadInteger('PositionY', 100);
    tbWidth.Position := Settings.ReadInteger('PositionWidth', 100);
    tbHeight.Position := Settings.ReadInteger('PositionHeight', 20);

    OSDForm.TextFont.Name := Settings.ReadString('FontName',
      'Arial Unicode MS');
    OSDForm.TextFont.CharSet := Byte(Settings.ReadInteger('FontCharSet', 0));
    OSDForm.TextFont.Size := Settings.ReadInteger('FontSize', 15);
    OSDForm.TextFont.Style :=
      TFontStyles(Byte(Settings.ReadInteger('FontStyle', 0)));

    OSDForm.TextColor := StrToInt('$' + Settings.ReadString('FontColor',
      inttohex(clWhite, 8)));
    OSDForm.OutlineColor := StrToInt('$' + Settings.ReadString('OutlineColor',
      inttohex(clBlack, 8)));

    OSDForm.OutlineWidth := Settings.ReadInteger('OutlineWidth', 1);
    cbSticky.checked := Settings.ReadBool('Sticky', False);
    Settings.EndSection;

    tbOutline.Position := OSDForm.OutlineWidth;

    Settings.BeginSection('AGTH');
    edHCode.Text := Settings.ReadString('HCode', '');
    seDelay.Value := Settings.ReadInteger('CopyDelay', 150);
    Settings.EndSection;

    Settings.BeginSection('jstp');
    LoadScript(Settings.ReadString('ScriptPath', ''));
    chbTextProcessor.checked := Settings.ReadBool('EnablePreProcess', False);
    Settings.EndSection;
  finally
    Settings.Free;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.OnDeactivate := nil;
  Application.OnActivate := nil;
  agserv.Free;
  SaveSettings;
  jstp.Free;
  OSDForm.Free;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  jstp := JavaScriptTextProcessor.Create;
  OSDForm := TOSDForm.Create(nil);
  agserv := TAGTHServer.Create;
  agserv.OnStream := OnNewStream;
  agserv.OnText := OnNewText;
  agserv.CopyDelay := 200;

  srclen.Clear;
  destlen.Clear;
  for i := 0 to length(LangArr) - 1 do
  begin
    srclen.Items.Add(LangArr[i].Name);
    destlen.Items.Add(LangArr[i].Name);
  end;

  LoadSettings;
  UpdateColorBoxes;
  Application.OnDeactivate := ApplicationFocusChanged;
  Application.OnActivate := ApplicationFocusChanged;
end;

procedure TMainForm.OSDTimerTimer(Sender: TObject);
begin
  try
    if rbClipboard.checked then
      OSDForm.SetText(Clipboard.AsText);
  except
    // who cares?
  end;
end;

procedure TMainForm.OSDPosChange(Sender: TObject);
begin
  OSDForm.SetPosition(tbX.Position, tbY.Position, tbWidth.Position,
    tbHeight.Position);
end;

procedure TMainForm.UpdateColorBoxes;
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
end;

procedure TMainForm.imgOutlineColorClick(Sender: TObject);
begin
  ColorDialog1.Color := OSDForm.OutlineColor;
  if ColorDialog1.Execute(Handle) then
    OSDForm.OutlineColor := ColorDialog1.Color;
  UpdateColorBoxes;
end;

procedure TMainForm.imgTextColorClick(Sender: TObject);
begin
  ColorDialog1.Color := OSDForm.TextColor;
  if ColorDialog1.Execute(Handle) then
    OSDForm.TextColor := ColorDialog1.Color;
  UpdateColorBoxes;
end;

procedure TMainForm.seDelayChange(Sender: TObject);
begin
  agserv.CopyDelay := seDelay.Value;
end;

procedure TMainForm.tbOutlineChange(Sender: TObject);
begin
  OSDForm.OutlineWidth := tbOutline.Position;
end;

procedure TMainForm.FontSetClick(Sender: TObject);
begin
  FontDialog.Font := Memo.Font;
  if FontDialog.Execute then
    Memo.Font := FontDialog.Font;
end;

function TMainForm.Translate(Text: widestring): widestring;
begin
  Result := TGoogleTranslate.Translate(Text, srclen.ItemIndex,
    destlen.ItemIndex);
end;

procedure TMainForm.ApplicationFocusChanged(Sender: TObject);
begin
  OSDForm.DrawWindowOutline := Application.Active;
end;

procedure TMainForm.btnHookClick(Sender: TObject);
var
  pid: Cardinal;
  idx: Integer;
begin
  idx := cbProcess.ItemIndex;
  if (idx >= 0) and (idx < cbProcess.Items.Count) then
  begin
    pid := Cardinal(cbProcess.Items.Objects[cbProcess.ItemIndex]);
    THooker.HookProcess(pid, edHCode.Text);
  end;
  cbProcessChange(cbProcess);
end;

procedure TMainForm.btnOsdFontSelectClick(Sender: TObject);
begin
  FontDialog.Font := OSDForm.TextFont;
  if FontDialog.Execute then
    OSDForm.TextFont := FontDialog.Font;
end;

procedure TMainForm.btnScriptLoadClick(Sender: TObject);
begin
  OpenDialog.Filter := '*.js|*.js';
  OpenDialog.InitialDir := ExtractFilePath(paramstr(0));
  if OpenDialog.Execute(Self.Handle) then
    LoadScript(OpenDialog.FileName);
end;

procedure TMainForm.LoadScript(path: string);
begin
  mScriptPath.Text := path;
  jstp.LoadScript(path);
  ScriptArea.Text := jstp.Script;
  TRichEditJsHighlighter.jsHighlight(ScriptArea);
end;

procedure TMainForm.cbEnableOSDClick(Sender: TObject);
begin
  if cbEnableOSD.checked then
    OSDForm.Show
  else
    OSDForm.Hide;
end;

procedure TMainForm.cbStickyClick(Sender: TObject);
begin
  OSDForm.Sticky := cbSticky.checked;
end;

procedure TMainForm.cbProcessChange(Sender: TObject);
var
  itindex: Integer;
  pid: Cardinal;
begin
  itindex := cbProcess.ItemIndex;
  pid := Cardinal(cbProcess.Items.Objects[itindex]);
  btnHook.Enabled := not THooker.IsHooked(pid);
end;

procedure TMainForm.cbProcessDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  ComboBox: TComboBox;
  bitmap: TBitmap;
begin
  ComboBox := (Control as TComboBox);
  bitmap := TBitmap.Create;
  try
    ProcIcon.GetBitmap(index, bitmap);
    with ComboBox.Canvas do
    begin
      FillRect(Rect);
      if bitmap.Handle <> 0 then
        Draw(Rect.Left + 2, Rect.Top, bitmap);
      Rect := Bounds(Rect.Left + ComboBox.ItemHeight + 2 + 5, Rect.Top,
        Rect.Right - Rect.Left, Rect.Bottom - Rect.Top);
      DrawText(Handle, PChar(ComboBox.Items[index]),
        length(ComboBox.Items[index]), Rect, DT_VCENTER + DT_SINGLELINE);
    end;
  finally
    bitmap.Free;
  end;
end;

procedure TMainForm.cbProcessDropDown(Sender: TObject);
var
  itindex: Integer;
  i: Integer;
  pid: Cardinal;
  proc: THandle;
  buffer: array [0 .. MAX_PATH] of WideChar;
  res: Integer;
  ico: TIcon;
  hico: THandle;
begin
  itindex := cbProcess.ItemIndex;
  THooker.GetProcessList(cbProcess.Items);
  ProcIcon.Clear;
  for i := 0 to cbProcess.Items.Count - 1 do
  begin
    FillChar(buffer, MAX_PATH, 0);

    pid := Cardinal(cbProcess.Items.Objects[i]);
    proc := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,
      False, pid);

    res := 0;
    if proc <> 0 then
    begin
      res := GetModuleFileNameEx(proc, 0, buffer, MAX_PATH);
      CloseHandle(proc);
    end;

    if res > 0 then
    begin
      hico := ExtractIcon(hInstance, buffer, 0);
      if hico <> 0 then
      begin
        ico := TIcon.Create;
        ico.Handle := hico;
        ProcIcon.AddIcon(ico);
        ico.Free;
        DestroyIcon(hico);
      end
      else
        ProcIcon.AddImage(Images, 0);
    end
    else
      ProcIcon.AddImage(Images, 0);
  end;

  cbProcess.ItemIndex := itindex;
end;

procedure TMainForm.cbStreamsChange(Sender: TObject);
begin
  agserv.SelectStream(cbStreams.ItemIndex);
  agserv.GetStreamText(Memo1.lines);
  Memo1.SelStart := Memo1.Perform(EM_LINEINDEX, Memo1.lines.Count, 0);
  Memo1.Perform(EM_SCROLLCARET, 0, 0);
end;

procedure TMainForm.OnNewStream(lines: TStrings);
var
  i: Integer;
begin
  i := cbStreams.ItemIndex;
  cbStreams.Items.Assign(lines);
  cbStreams.ItemIndex := i;
end;

procedure TMainForm.OnNewText(Text: widestring);
var
  s: string;
begin
  agserv.GetStreamText(Memo1.lines);

  if chbTextProcessor.checked then
    s := jstp.ProcessText(Text)
  else
    s := Text;

  if DoTranslate.checked then
    s := Translate(s);

  if (cbEnableOSD.checked) and (rbText.checked) then
    OSDForm.SetText(s);

  if ClipboardCopy.checked then
    Clipboard.AsText := s;

  Memo.Text := s;

  // ----------------------------
  agserv.GetStreamText(Memo1.lines);
  Memo1.SelStart := Memo1.Perform(EM_LINEINDEX, Memo1.lines.Count, 0);
  Memo1.Perform(EM_SCROLLCARET, 0, 0);
end;

end.
