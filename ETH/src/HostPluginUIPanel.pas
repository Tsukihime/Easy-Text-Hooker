unit HostPluginUIPanel;

interface

uses
  Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Winapi.Windows,
  Winapi.Messages;

type
  TEnumChildsProc = reference to procedure(ChildHandle: THandle);

  THostPlugunUIPanel = class(TPanel)
  protected
    procedure EnumChilds(Proc: TEnumChildsProc);
  public
    constructor Create(AOwner: TComponent); override;
    function PreProcessMessage(var Msg: TMsg): Boolean; override;
    procedure Resize; override;
  end;

implementation

uses
  Vcl.Forms;

type
  TEnumChildData = record
    ParentHandle: THandle;
    EnumProc: TEnumChildsProc;
  end;

  PEnumChildData = ^TEnumChildData;

function EnumChildProc(hwnd: hwnd; Data: PEnumChildData): BOOL; stdcall;
begin
  if (Data.ParentHandle = GetParent(hwnd)) then
    Data.EnumProc(hwnd);
  Result := true;
end;

{ TPanel }

constructor THostPlugunUIPanel.Create(AOwner: TComponent);
begin
  inherited;
  Align := alClient;
  BorderStyle := bsNone;
  BevelOuter := bvNone;
end;

procedure THostPlugunUIPanel.EnumChilds(Proc: TEnumChildsProc);
var
  Data: TEnumChildData;
begin
  Data.EnumProc := Proc;
  Data.ParentHandle := Handle;
  EnumChildWindows(Handle, @EnumChildProc, IntPtr(@Data));
end;

function THostPlugunUIPanel.PreProcessMessage(var Msg: TMsg): Boolean;
var
  Unicode: Boolean;
begin
  Unicode := (Msg.hwnd = 0) or IsWindowUnicode(Msg.hwnd);
  TranslateMessage(Msg);
  if Unicode then
    DispatchMessageW(Msg)
  else
    DispatchMessageA(Msg);
  Result := true;
end;

procedure THostPlugunUIPanel.Resize;
begin
  inherited;
  EnumChilds(
    procedure(ChildHandle: THandle)
    begin
      SetWindowPos(ChildHandle, 0, 0, 0, Width, Height, SWP_NOACTIVATE or
        SWP_NOOWNERZORDER or SWP_NOZORDER);
    end);
end;

end.
