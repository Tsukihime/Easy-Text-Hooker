unit ApplicationCore;

interface

uses
  PluginAPI_TLB;

type
  TApplicationCore = class(TInterfacedObject, IApplicationCore)
  private
    FAppWindows: IApplicationWindows;
    FSettings: ISettings;
    function Get_ApplicationWindows: IApplicationWindows; safecall;
    function Get_Settings: ISettings; safecall;
  public
    constructor Create(const AppWindows: IApplicationWindows;
      const Settings: ISettings);
    property ApplicationWindows: IApplicationWindows
      read Get_ApplicationWindows;
    property Settings: ISettings read Get_Settings;
  end;

  TApplicationWindows = class(TInterfacedObject, IApplicationWindows)
  private
    FApplicationWnd: THandle;
    FMainWnd: THandle;
    FHostWnd: THandle;
    function Get_ApplicationWnd: Integer; safecall;
    function Get_MainWnd: Integer; safecall;
    function Get_HostWnd: Integer; safecall;
  public
    property ApplicationWnd: Integer read Get_ApplicationWnd;
    property MainWnd: Integer read Get_MainWnd;
    property HostWnd: Integer read Get_HostWnd;

    constructor Create(ApplicationWnd, MainWnd, HostWnd: THandle);
  end;

implementation

{ TTextProcessorCore }

constructor TApplicationCore.Create(const AppWindows: IApplicationWindows;
  const Settings: ISettings);
begin
  FAppWindows := AppWindows;
  FSettings := Settings;
end;

function TApplicationCore.Get_ApplicationWindows: IApplicationWindows;
begin
  Result := FAppWindows;
end;

function TApplicationCore.Get_Settings: ISettings;
begin
  Result := FSettings;
end;

{ TApplicationWindows }

constructor TApplicationWindows.Create(ApplicationWnd, MainWnd,
  HostWnd: THandle);
begin
  FApplicationWnd := ApplicationWnd;
  FHostWnd := HostWnd;
  FMainWnd := MainWnd;
end;

function TApplicationWindows.Get_ApplicationWnd: Integer;
begin
  Result := FApplicationWnd;
end;

function TApplicationWindows.Get_HostWnd: Integer;
begin
  Result := FHostWnd;
end;

function TApplicationWindows.Get_MainWnd: Integer;
begin
  Result := FMainWnd;
end;

end.
