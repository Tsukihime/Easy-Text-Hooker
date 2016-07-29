unit SettingsFile;

interface

uses
  Winapi.ActiveX,
  PluginAPI_TLB,
  JSON;

type
  /// <summary>
  /// Represents config file functionality
  /// </summary>
  TSettingsFile = class
  private
    FFilePath: string;
    FJSONConfig: TJSONObject;
  public
    constructor Create(const Path: string); overload;
    /// <param name="SettingsName">
    /// %APPDATA%/ProductName/SettingsName.json
    /// </param>
    /// <param name="ProductName">
    /// %APPDATA%/ProductName/SettingsName.json
    /// </param>
    /// <param name="CheckProgramDir">
    /// if True checks ProgramDir/SettingsName.json and if exist use it
    /// </param>
    constructor Create(const SettingsName: string; const ProductName: string;
      CheckProgramDir: Boolean = False); overload;
    destructor Destroy; override;

    property ConfigNode: TJSONObject read FJSONConfig;
  end;

implementation

uses
  SysUtils,
  IOUtils;

{ TSettingsFile }

constructor TSettingsFile.Create(const SettingsName: string;
  const ProductName: string; CheckProgramDir: Boolean = False);
var
  Path: string;
begin
  Path := TPath.Combine(ExtractFilePath((paramstr(0))), SettingsName + '.json');

  if CheckProgramDir and FileExists(Path) then
  begin
    Create(Path);
    exit;
  end;

  Path := TPath.Combine(TPath.GetHomePath, ProductName);
  if not DirectoryExists(Path) then
    CreateDir(Path);
  Path := TPath.Combine(Path, SettingsName + '.json');

  Create(Path);
end;

constructor TSettingsFile.Create(const Path: string);
var
  Data: TBytes;
begin
  FFilePath := Path;
  FJSONConfig := TJSONObject.Create;

  if TFile.Exists(FFilePath) then
  begin
    Data := TFile.ReadAllBytes(FFilePath);
    FJSONConfig.Parse(Data, 0);
  end;

  inherited Create;
end;

destructor TSettingsFile.Destroy;
var
  Data: TBytes;
  DataSize: Integer;
begin
  SetLength(Data, FJSONConfig.EstimatedByteSize);
  DataSize := FJSONConfig.ToBytes(Data, 0);
  FJSONConfig.Free;
  SetLength(Data, DataSize);
  TFile.WriteAllBytes(FFilePath, Data);
  inherited;
end;

end.
