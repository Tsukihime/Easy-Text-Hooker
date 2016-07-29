unit PluginManager;

interface

uses
  System.SysUtils,
  Winapi.Windows,
  Classes,
  System.Generics.Collections,
  PluginAPI_TLB;

type
  EPluginsLoadError = class(Exception);

  TETHPluginInitProc = procedure(const Registry
    : ITextProcessorRegistry); stdcall;
  TETHFinalizeProc = procedure; stdcall;

  TPlugin = class
  private
    FETHFinalize: TETHFinalizeProc;
    FETHPluginInit: TETHPluginInitProc;
    FLibraryHandle: THandle;
  public
    constructor Create(const AFilePath: string;
      const Registry: ITextProcessorRegistry);
    destructor Destroy; override;
  end;

  TPluginManager = class
  private
    FPluginList: TObjectList<TPlugin>;
    FPluginDir: string;
    FRecursive: Boolean;
  public
    procedure RegisterAll(const Registry: ITextProcessorRegistry);
    constructor Create(const PluginDir: string; Recursive: Boolean = false);
    destructor Destroy; override;
  end;

implementation

uses
  System.Types,
  System.IOUtils,
  System.SysConst;

const
  PluginExt: string = 'etp';

resourcestring
  rsPluginsLoadError = 'One or more plugins has failed to load:' +
    sLineBreak + '%s';

  { TPlugin }

procedure DllCheck(RetVal: Boolean; FileName: string = '');
var
  Error: EOSError;
  LastError: Integer;
  ErrorMessage: string;
begin
  if RetVal then
    exit;

  LastError := GetLastError;
  if LastError <> 0 then
  begin
    ErrorMessage := SysErrorMessage(LastError) + sLineBreak;
    ErrorMessage := StringReplace(ErrorMessage, '%1', '%s', [rfReplaceAll]);
    Error := EOSError.CreateResFmt(@SOSError,
      [LastError, Format(ErrorMessage, [FileName]), '']);
  end
  else
    Error := EOSError.CreateRes(@SUnkOSError);
  Error.ErrorCode := LastError;
  raise Error;
end;

constructor TPlugin.Create(const AFilePath: string;
  const Registry: ITextProcessorRegistry);
var
  FileName: string;
begin
  FileName := TPath.GetFileName(AFilePath);

  FLibraryHandle := SafeLoadLibrary(AFilePath, GetErrorMode() or
    SEM_NOGPFAULTERRORBOX or SEM_FAILCRITICALERRORS or SEM_NOOPENFILEERRORBOX);
  DllCheck(FLibraryHandle <> 0, FileName);

  @FETHFinalize := GetProcAddress(FLibraryHandle, 'ETHFinalize');
  Win32Check(@FETHFinalize <> nil);

  @FETHPluginInit := GetProcAddress(FLibraryHandle,
    'ETHInitializeTextProcessors');
  Win32Check(@FETHPluginInit <> nil);

  FETHPluginInit(Registry);
end;

destructor TPlugin.Destroy;
begin
  if FLibraryHandle <> 0 then
  begin
    if Assigned(@FETHFinalize) then
      FETHFinalize();

    FreeLibrary(FLibraryHandle);
    FLibraryHandle := 0;
  end;
  inherited;
end;

{ TPluginManager }

constructor TPluginManager.Create(const PluginDir: string;
  Recursive: Boolean = false);
begin
  FPluginDir := TPath.GetFullPath(PluginDir);
  FRecursive := Recursive;
  FPluginList := TObjectList<TPlugin>.Create();
end;

destructor TPluginManager.Destroy;
begin
  FPluginList.Free;
  inherited;
end;

procedure TPluginManager.RegisterAll(const Registry: ITextProcessorRegistry);
var
  PluginPaths: TStringDynArray;
  SearchOption: TSearchOption;
  PluginPath: string;
  Plugin: TPlugin;
  Failures: TStringList;
begin
  if FRecursive then
    SearchOption := TSearchOption.soAllDirectories
  else
    SearchOption := TSearchOption.soTopDirectoryOnly;

  PluginPaths := TDirectory.GetFiles(FPluginDir, '*.' + PluginExt,
    SearchOption);
  Failures := TStringList.Create;
  try
    for PluginPath in PluginPaths do
    begin
      try
        Plugin := TPlugin.Create(PluginPath, Registry);
        FPluginList.Add(Plugin);
      except
        on e: Exception do
        begin
          Failures.Add(e.Message);
          Failures.Add(PluginPath);
          Failures.Add('');
        end;
      end;
    end;

    if Failures.Count > 0 then
      raise EPluginsLoadError.Create(Format(rsPluginsLoadError,
        [Failures.Text]));
  finally
    Failures.Free;
  end;
end;

end.
