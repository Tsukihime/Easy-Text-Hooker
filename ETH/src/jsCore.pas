unit jsCore;

interface

uses Classes, ComObj, Variants, sysutils;

type
  JavaScriptTextProcessor = class
  private
    FScript: string;
    FScriptPath: string;
  public
    procedure LoadScript(path: string);
    function ProcessText(text: string): string;
    property ScriptPath: string read FScriptPath;
    property Script: string read FScript;
  end;

implementation

{ JavaScriptTextProcessor }

procedure JavaScriptTextProcessor.LoadScript(path: string);
var
  ts: TStringList;
begin
  if not FileExists(path) then
    exit;

  FScriptPath := path;

  ts := TStringList.Create;
  try
    ts.LoadFromFile(FScriptPath, TEncoding.UTF8);
    FScript := ts.text;
  finally
    ts.Free;
  end;
end;

function JavaScriptTextProcessor.ProcessText(text: string): string;
var
  js: OleVariant;
  s: Variant;
begin
  js := CreateOleObject('ScriptControl');
  js.Language := 'JavaScript';
  js.AddCode(FScript);

  s := text;
  Result := js.Run('process_text', s);
  js := Unassigned;
end;

end.
