unit AGTHUI;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ImgList, Vcl.ExtCtrls,
  Vcl.Samples.Spin,
  //
  AGTHServer,
  PluginAPI_TLB;

type
  TAGTHSendText = procedure(const AText: string) of object;

  TAGTHForm = class(TForm)
    GroupBox2: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    cbProcess: TComboBox;
    btnHook: TButton;
    seDelay: TSpinEdit;
    GroupBox1: TGroupBox;
    cbStreams: TComboBox;
    AGTHMemo: TMemo;
    ProcIcon: TImageList;
    Images: TImageList;
    imgSelectWindow: TImage;
    cbHCode: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure seDelayChange(Sender: TObject);
    procedure cbProcessDropDown(Sender: TObject);
    procedure cbProcessDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cbProcessChange(Sender: TObject);
    procedure btnHookClick(Sender: TObject);
    procedure cbStreamsChange(Sender: TObject);
    procedure imgSelectWindowMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure imgSelectWindowMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FOnNewTextReceived: TAGTHSendText;
    FSettings: ISettings;
    agserv: TAGTHServer;
    procedure OnNewStream(lines: TStrings);
    procedure OnNewText(Text: widestring);
  public
    constructor CreateParented(AParentWindow: HWnd;
      const Settings: ISettings); overload;
    property OnNewTextReceived: TAGTHSendText read FOnNewTextReceived
      write FOnNewTextReceived;

    function WantChildKey(Child: TControl; var Message: TMessage)
      : Boolean; override;
  end;

implementation

uses
  initprocs,
  Inject,
  psapi,
  shellapi;

{$R *.dfm}
{ TAGTHForm }

procedure TAGTHForm.btnHookClick(Sender: TObject);
var
  pid: Cardinal;
  idx: Integer;
begin
  idx := cbProcess.ItemIndex;
  if (idx >= 0) and (idx < cbProcess.Items.Count) then
  begin
    pid := Cardinal(cbProcess.Items.Objects[cbProcess.ItemIndex]);
    THooker.HookProcess(pid, cbHCode.Text);
  end;
  cbProcessChange(cbProcess);

  idx := cbHCode.Items.IndexOf(cbHCode.Text);
  if idx < 0 then
  begin
    cbHCode.Items.Insert(0, cbHCode.Text);
    while cbHCode.Items.Count > 7 do
      cbHCode.Items.Delete(cbHCode.Items.Count - 1);
  end;
end;

procedure TAGTHForm.cbProcessChange(Sender: TObject);
var
  itindex: Integer;
  pid: Cardinal;
begin
  itindex := cbProcess.ItemIndex;
  pid := Cardinal(cbProcess.Items.Objects[itindex]);
  btnHook.Enabled := not THooker.IsHooked(pid);
end;

procedure TAGTHForm.cbProcessDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  ComboBox: TComboBox;
  Bitmap: TBitmap;
begin
  ComboBox := (Control as TComboBox);
  Bitmap := TBitmap.Create;
  try
    ProcIcon.GetBitmap(index, Bitmap);
    with ComboBox.Canvas do
    begin
      FillRect(Rect);
      if Bitmap.Handle <> 0 then
        Draw(Rect.Left + 2, Rect.Top, Bitmap);
      Rect := Bounds(Rect.Left + ComboBox.ItemHeight + 2 + 5, Rect.Top,
        Rect.Right - Rect.Left, Rect.Bottom - Rect.Top);
      DrawText(Handle, PChar(ComboBox.Items[index]),
        length(ComboBox.Items[index]), Rect, DT_VCENTER + DT_SINGLELINE);
    end;
  finally
    Bitmap.Free;
  end;
end;

procedure TAGTHForm.cbProcessDropDown(Sender: TObject);
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

procedure TAGTHForm.cbStreamsChange(Sender: TObject);
begin
  agserv.SelectStream(cbStreams.ItemIndex);
  agserv.GetStreamText(AGTHMemo.lines);
  AGTHMemo.SelStart := AGTHMemo.Perform(EM_LINEINDEX, AGTHMemo.lines.Count, 0);
  AGTHMemo.Perform(EM_SCROLLCARET, 0, 0);
end;

function TAGTHForm.WantChildKey(Child: TControl; var Message: TMessage)
  : Boolean;
begin
  Result := ((Message.Msg = WM_CHAR) and (Message.WParam = VK_TAB)) or
    (Child.Perform(CN_BASE + Message.Msg, Message.WParam, Message.LParam) <> 0);
end;

constructor TAGTHForm.CreateParented(AParentWindow: HWnd;
  const Settings: ISettings);
begin
  FSettings := Settings;
  CreateParented(AParentWindow);
end;

procedure TAGTHForm.FormCreate(Sender: TObject);
var
  Index: Integer;
begin
  agserv := TAGTHServer.Create;
  agserv.OnNewStream := OnNewStream;
  agserv.OnNewText := OnNewText;

  cbHCode.Items.DelimitedText := FSettings.ReadString('HCodeHistory', '');
  cbHCode.Text := FSettings.ReadString('HCode', '');

  seDelay.Value := FSettings.ReadInteger('CopyDelay', 150);
  seDelayChange(seDelay);

  cbProcessDropDown(cbProcess);
  Index := cbProcess.Items.IndexOf(FSettings.ReadString('LastProcess', ''));
  if Index >= 0 then
  begin
    cbProcess.ItemIndex := Index;
    cbProcessChange(cbProcess);
  end;
end;

procedure TAGTHForm.FormDestroy(Sender: TObject);
begin
  agserv.Free;
  FSettings.WriteString('HCode', cbHCode.Text);
  FSettings.WriteString('HCodeHistory', cbHCode.Items.DelimitedText);
  FSettings.WriteInteger('CopyDelay', seDelay.Value);
  FSettings.WriteString('LastProcess', cbProcess.Text);
end;

procedure TAGTHForm.imgSelectWindowMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if ssLeft in Shift then
    Screen.Cursor := crCustomCrossHair
  else
    Screen.Cursor := crDefault;
end;

procedure TAGTHForm.imgSelectWindowMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  CustomHwnd: THandle;
  pid, cbPID: Cardinal;
  i: Integer;
begin
  Screen.Cursor := crDefault;
  CustomHwnd := windowFromPoint(Mouse.CursorPos);
  GetWindowThreadProcessId(CustomHwnd, @pid);

  cbProcessDropDown(cbProcess); // update process list
  for i := 0 to cbProcess.Items.Count - 1 do
  begin
    cbPID := Cardinal(cbProcess.Items.Objects[i]);
    if cbPID = pid then
    begin
      cbProcess.ItemIndex := i;
      cbProcessChange(cbProcess);
      break;
    end;
  end;
end;

procedure TAGTHForm.seDelayChange(Sender: TObject);
begin
  agserv.EndLineDelay := seDelay.Value;
end;

procedure TAGTHForm.OnNewStream(lines: TStrings);
var
  i: Integer;
begin
  i := cbStreams.ItemIndex;
  cbStreams.Items.Assign(lines);
  cbStreams.ItemIndex := i;
end;

procedure TAGTHForm.OnNewText(Text: widestring);
begin
  agserv.GetStreamText(AGTHMemo.lines);
  AGTHMemo.SelStart := AGTHMemo.Perform(EM_LINEINDEX, AGTHMemo.lines.Count, 0);
  AGTHMemo.Perform(EM_SCROLLCARET, 0, 0);

  if Assigned(FOnNewTextReceived) then
    FOnNewTextReceived(Text);
end;

end.
