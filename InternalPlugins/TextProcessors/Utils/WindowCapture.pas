unit WindowCapture;

interface

type
  IWindowCapture = interface
    function GetWndClassName: string;
    function GetHandle: THandle;
    function GetWndName: string;

    property WndClassName: string read GetWndClassName;
    property WindowName: string read GetWndName;
    property Handle: THandle read GetHandle;
    function GetText: string;
    procedure SetText(const AText: string);
  end;

  TWindowCapture = class(TInterfacedObject, IWindowCapture)
  private
    FClassName: string;
    FHandle: THandle;
    function GetWndClassName: string;
    function GetHandle: THandle;
    function GetWndName: string;
  public
    property WndClassName: string read GetWndClassName;
    property WindowName: string read GetWndName;
    property Handle: THandle read GetHandle;
    function GetText: string;
    procedure SetText(const AText: string);
    constructor Create(HWnd: THandle);
  end;

implementation

uses
  Winapi.Windows,
  Winapi.Messages;

{ TWindowCapture }

constructor TWindowCapture.Create(HWnd: THandle);
const
  MaxLength = 200;
var
  Text: string;
  Size: Integer;
begin
  FHandle := HWnd;
  SetLength(Text, MaxLength);
  Size := GetClassName(FHandle, PChar(Text), MaxLength);
  SetLength(Text, Size);

  FClassName := Text;
end;

function TWindowCapture.GetWndClassName: string;
begin
  Result := FClassName;
end;

function TWindowCapture.GetWndName: string;
var
  Length: Integer;
  Text: string;
begin
  Result := '';
  Length := GetWindowTextLength(FHandle);
  if Length = 0 then
    exit;

  Length := Length + 1;

  SetLength(Text, Length);
  GetWindowText(FHandle, PChar(Text), Length);
  Result := Text;
end;

procedure TWindowCapture.SetText(const AText: string);
begin
  if FHandle = INVALID_HANDLE_VALUE then
    exit;

  SendMessage(FHandle, WM_SETTEXT, 0, LPARAM(PChar(AText)));
end;

function TWindowCapture.GetHandle: THandle;
begin
  Result := FHandle;
end;

function TWindowCapture.GetText: string;
var
  Text: string;
  Length: Integer;
begin
  Result := '';
  if FHandle = INVALID_HANDLE_VALUE then
    exit;

  Length := SendMessage(FHandle, WM_GETTEXTLENGTH, 0, 0);

  if Length = 0 then
    exit;

  inc(Length); // why?

  SetLength(Text, Length);

  Length := SendMessage(FHandle, WM_GETTEXT, Length, LPARAM(PChar(Text)));

  SetLength(Text, Length);
  Result := Text;
end;

end.
