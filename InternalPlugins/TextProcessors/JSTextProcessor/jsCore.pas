unit jsCore;

interface

uses Classes, ComObj, Variants;

type
  TJavaScriptCore = class
  private
    FScript: string;
    FScriptPath: string;
    FJsScriptControl: OleVariant;
    FScriptLoaded: boolean;
    function GetJsScriptControl: OleVariant;
  public
    procedure LoadScript(path: string);
    function ProcessText(text: string): string;
    property ScriptPath: string read FScriptPath;
    property Script: string read FScript;
    destructor Destroy; override;
  end;

implementation

uses
  System.IOUtils,
  System.SysUtils;

{ JavaScriptTextProcessor }

destructor TJavaScriptCore.Destroy;
begin
  FJsScriptControl := UnAssigned;
  inherited;
end;

function TJavaScriptCore.GetJsScriptControl: OleVariant;
begin
  if not FScriptLoaded then
  begin
    Result := UnAssigned;
    exit;
  end;

  if VarIsEmpty(FJsScriptControl) then
  begin
    FJsScriptControl := CreateOleObject('ScriptControl');
    FJsScriptControl.Language := 'JavaScript';
    FJsScriptControl.AddCode(FScript);
  end;

  Result := FJsScriptControl;
end;

procedure TJavaScriptCore.LoadScript(path: string);
var
  Bytes: TBytes;
begin
  FScriptLoaded := false;
  if not TFile.Exists(path) then
    exit;

  FScriptPath := path;

  Bytes := TFile.ReadAllBytes(FScriptPath);
  FScript := TEncoding.UTF8.GetString(Bytes);

  FScriptLoaded := True;
  FJsScriptControl := UnAssigned;
end;

function TJavaScriptCore.ProcessText(text: string): string;
var
  s: Variant;
  JsScriptControl: OleVariant;
begin
  Result := text;

  if not FScriptLoaded then
    exit;

  JsScriptControl := GetJsScriptControl;
  if VarIsEmpty(JsScriptControl) then
    exit;

  try
    s := text;
    Result := JsScriptControl.Run('process_text', s);
  except
    // supress exceptions
    FJsScriptControl := UnAssigned;
  end;
end;

end.
