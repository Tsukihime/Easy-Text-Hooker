unit DllTreadSynchronizer;

interface

uses
  Classes,
  Windows,
  Messages;

type
  TDllTreadSynchronizer = class
  private
    FHandle: HWND;
    FOldWakeMainThread: TNotifyEvent;
    procedure WakeMainThread(Sender: TObject);
  protected
    procedure WndProc(var Message: TMessage);
  public
    constructor Create;
    destructor Destroy; override;
  end;

const
  WM_SYNCHRONIZE = WM_NULL;

procedure InitializeDllTreadSynchronizer;
procedure FinalizeDllTreadSynchronizer;

implementation

var
  FDllTreadSynchronizer: TDllTreadSynchronizer;

procedure InitializeDllTreadSynchronizer;
begin
  if not Assigned(FDllTreadSynchronizer) then
    FDllTreadSynchronizer := TDllTreadSynchronizer.Create
end;

procedure FinalizeDllTreadSynchronizer;
begin
  if Assigned(FDllTreadSynchronizer) then
    FDllTreadSynchronizer.Free;
end;

{ TDllTreadSynchronizer }

constructor TDllTreadSynchronizer.Create;
begin
  if IsLibrary then
  begin
    FHandle := AllocateHWnd(WndProc);
    FOldWakeMainThread := Classes.WakeMainThread;
    Classes.WakeMainThread := WakeMainThread;
  end;
end;

destructor TDllTreadSynchronizer.Destroy;
begin
  if IsLibrary then
  begin
    Classes.WakeMainThread := FOldWakeMainThread;
    DeallocateHWnd(FHandle);
  end;
  inherited;
end;

procedure TDllTreadSynchronizer.WakeMainThread(Sender: TObject);
begin
  PostMessage(FHandle, WM_SYNCHRONIZE, 0, 0);
end;

procedure TDllTreadSynchronizer.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_SYNCHRONIZE:
      CheckSynchronize;
  else
    Message.Result := DefWindowProc(FHandle, Message.Msg, Message.wParam,
      Message.lParam);
  end;
end;

end.
