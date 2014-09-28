// my personal bike
unit uSettings;

interface

uses IniFiles;

type
  TSettingsFile = class
  private
    FFilePath: string;
    FIni: TMemIniFile;
    FCurrentSection: string;
  public
    constructor Create(filePath: string); overload;
    constructor Create(SettingsName, ProductName: string;
      CheckProgramDir: boolean = false); overload;
    destructor Destroy; override;
  public
    procedure BeginSection(SectionName: string);
    procedure EndSection;
  public
    // write
    procedure WriteBool(Ident: string; Value: boolean); overload;
    procedure WriteBool(Section, Ident: string; Value: boolean); overload;

    procedure WriteInteger(Ident: string; Value: Integer); overload;
    procedure WriteInteger(Section, Ident: string; Value: Integer); overload;

    procedure WriteString(Ident: string; Value: string); overload;
    procedure WriteString(Section, Ident: string; Value: string); overload;

    // read
    function ReadBool(Ident: string; DefaultValue: boolean): boolean; overload;
    function ReadBool(Section, Ident: string; DefaultValue: boolean)
      : boolean; overload;

    function ReadInteger(Ident: string; DefaultValue: Integer)
      : Integer; overload;
    function ReadInteger(Section, Ident: string; DefaultValue: Integer)
      : Integer; overload;

    function ReadString(Ident: string; DefaultValue: string): string; overload;
    function ReadString(Section, Ident: string; DefaultValue: string)
      : string; overload;
  end;

implementation

uses windows, SysUtils, ShlObj;

{ TSettingsFile }

// use default file path in appdata/ProductName/SettingsName.ini
// CheckProgramDir checks ProgramDir/SettingsName.ini and if exist use it
constructor TSettingsFile.Create(SettingsName, ProductName: string;
  CheckProgramDir: boolean = false);
var
  Path, appdata: string;
  Buf: array [0 .. MAX_PATH] of Char;
begin
  Path := ExtractFilePath((paramstr(0))) + SettingsName + '.ini';

  if CheckProgramDir and FileExists(Path) then
  begin
    Create(Path);
    exit;
  end;

  if SHGetSpecialFolderPath(0, @Buf[0], CSIDL_APPDATA, true) then
  begin
    appdata := PChar(@Buf[0]);
    Path := appdata + '\' + ProductName + '\';
    if not DirectoryExists(Path) then
      CreateDir(Path);
    Path := Path + SettingsName + '.ini';
  end;

  Create(Path);
end;

constructor TSettingsFile.Create(filePath: string);
begin
  FFilePath := filePath;
  FIni := TMemIniFile.Create(FFilePath);
  FCurrentSection := 'main';
end;

destructor TSettingsFile.Destroy;
begin
  FIni.UpdateFile;
  FIni.Free;
  inherited;
end;

procedure TSettingsFile.BeginSection(SectionName: string);
begin
  FCurrentSection := SectionName;
end;

procedure TSettingsFile.EndSection;
begin
  FCurrentSection := 'main';
end;

function TSettingsFile.ReadBool(Section, Ident: string;
  DefaultValue: boolean): boolean;
begin
  Result := FIni.ReadBool(Section, Ident, DefaultValue);
end;

function TSettingsFile.ReadBool(Ident: string; DefaultValue: boolean): boolean;
begin
  Result := ReadBool(FCurrentSection, Ident, DefaultValue);
end;

function TSettingsFile.ReadInteger(Section, Ident: string;
  DefaultValue: Integer): Integer;
begin
  Result := FIni.ReadInteger(Section, Ident, DefaultValue);
end;

function TSettingsFile.ReadInteger(Ident: string;
  DefaultValue: Integer): Integer;
begin
  Result := ReadInteger(FCurrentSection, Ident, DefaultValue);
end;

function TSettingsFile.ReadString(Section, Ident, DefaultValue: string): string;
begin
  Result := FIni.ReadString(Section, Ident, DefaultValue);
end;

function TSettingsFile.ReadString(Ident, DefaultValue: string): string;
begin
  Result := ReadString(FCurrentSection, Ident, DefaultValue);
end;

procedure TSettingsFile.WriteBool(Section, Ident: string; Value: boolean);
begin
  FIni.WriteBool(Section, Ident, Value);
end;

procedure TSettingsFile.WriteBool(Ident: string; Value: boolean);
begin
  WriteBool(FCurrentSection, Ident, Value);
end;

procedure TSettingsFile.WriteInteger(Section, Ident: string; Value: Integer);
begin
  FIni.WriteInteger(Section, Ident, Value);
end;

procedure TSettingsFile.WriteInteger(Ident: string; Value: Integer);
begin
  WriteInteger(FCurrentSection, Ident, Value);
end;

procedure TSettingsFile.WriteString(Ident, Value: string);
begin
  WriteString(FCurrentSection, Ident, Value);
end;

procedure TSettingsFile.WriteString(Section, Ident, Value: string);
begin
  FIni.WriteString(Section, Ident, Value);
end;

end.
