unit Translator;

interface

uses
  System.Generics.Collections, Classes;

type
  TLangsDictionary = TDictionary<string, string>;

  TTranslator = class
  protected
    FSrcLang, FDestLang: string;
    FLangs: TLangsDictionary;
  protected
    procedure GetAllLanguages(Items: TStrings);
  public
    function Translate(text: string): string; virtual; abstract;
    procedure SetTranslationDirection(SourceLang, DestinationLang: string);
    procedure GetFromLanguages(Items: TStrings); virtual; abstract;
    procedure GetToLanguages(Items: TStrings); virtual; abstract;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TTramslator }

constructor TTranslator.Create;
begin
  FLangs := TLangsDictionary.Create;
  FSrcLang := 'jp';
  FDestLang := 'ru';
end;

destructor TTranslator.Destroy;
begin
  FLangs.Free;
  inherited;
end;

procedure TTranslator.GetAllLanguages(Items: TStrings);
var
  Key: string;
  tmpsl: TStringList;
begin
  tmpsl := TStringList.Create;
  try
    for Key in FLangs.Keys do
      tmpsl.Add(Key);

    tmpsl.Sort;
    Items.Clear;
    Items.Assign(tmpsl);
  finally
    tmpsl.Free;
  end;
end;

procedure TTranslator.SetTranslationDirection(SourceLang,
  DestinationLang: string);
begin
  if FLangs.ContainsKey(SourceLang) then
    FSrcLang := FLangs[SourceLang];
  if FLangs.ContainsKey(DestinationLang) then
    FDestLang := FLangs[DestinationLang];
end;

end.
