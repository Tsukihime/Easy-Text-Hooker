unit GoogleTranslate;

interface

uses
  IdHTTP,
  SysUtils,
  JSON,
  HTTPApp,
  IdSSLOpenSSL,
  System.RegularExpressions,
  System.Generics.Collections,
  System.SyncObjs,
  Classes;

type
  TLangsDictionary = TDictionary<string, string>;
  TOnTranslateNotify = reference to procedure(const TranslatedText: string);

  TGoogleTranslate = class
  private
    function ExtractTranslation(const JSON: string): string;
    function URLEncode(const wstr: widestring): string;
    function MatchEvaluator(const Match: TMatch): string;
    function FixGoogleJSON(JSON: string): string;
  private
    FCriticalSection: TCriticalSection;
    FHttp: TidHttp;
    FSrcLang, FDestLang: string;
    FLangs: TLangsDictionary;
    procedure GetAllLanguages(Items: TStrings);
  public
    function Translate(Text: string): string;
    procedure DoTranslate(const Text: string; Callback: TOnTranslateNotify);
    procedure SetTranslationDirection(SourceLang, DestinationLang: string);
    procedure GetFromLanguages(Items: TStrings);
    procedure GetToLanguages(Items: TStrings);
    constructor Create;
    destructor Destroy; override;
  end;

  TTranslateThread = class(TThread)
  private
    FOnTranslate: TOnTranslateNotify;
    FText: string;
    FTranslator: TGoogleTranslate;
  protected
    procedure Execute; override;
  public
    procedure DoTranslate(const Translator: TGoogleTranslate;
      const Text: string; Callback: TOnTranslateNotify);
  end;

implementation

{ TGoogleTranslate }

procedure TGoogleTranslate.SetTranslationDirection(SourceLang,
  DestinationLang: string);
begin
  if FLangs.ContainsKey(SourceLang) then
    FSrcLang := FLangs[SourceLang];
  if FLangs.ContainsKey(DestinationLang) then
    FDestLang := FLangs[DestinationLang];
end;

// secret translate.googleapis.com API that is internally used by the
// Google Translate extension for Chrome and requires no authentication.
function TGoogleTranslate.Translate(Text: string): string;
var
  response, url, srctext: string;
begin
  FCriticalSection.Acquire;
  try
    srctext := URLEncode(Text);

    url := Format
      ('https://translate.googleapis.com/translate_a/single?client=gtx&sl=%s&tl=%s&dt=t&q=%s',
      [FSrcLang, FDestLang, srctext]);

    try
      response := FHttp.Get(url);
    except
      Result := Text;
      exit;
    end;

    Result := ExtractTranslation(FixGoogleJSON(response));
    if Result = '' then
      Result := Text;
  finally
    FCriticalSection.Release;
  end;
end;

function TGoogleTranslate.URLEncode(const wstr: widestring): string;

var
  i: Integer;
  S: RawByteString;
  StringBuilder: TStringBuilder;
begin
  S := UTF8Encode(wstr);
  StringBuilder := TStringBuilder.Create;
  for i := 1 to Length(S) do
    StringBuilder.Append('%').Append(IntToHex(Ord(S[i]), 2));

  Result := StringBuilder.ToString;
  StringBuilder.Free;
end; // URLEncode

function TGoogleTranslate.MatchEvaluator(const Match: TMatch): string;
begin
  if Match.Groups['quoted'].Length > 0 then
    Result := Match.Groups['quoted'].Value
  else if Match.Groups['left'].Length > 0 then
    Result := 'null,'
  else if Match.Groups['right'].Length > 0 then
    Result := ',null'
  else
    Result := Match.Value;
end;

// replace [,,"...",  in json to [null,null,"...",
function TGoogleTranslate.FixGoogleJSON(JSON: string): string;
var
  Evaluator: TMatchEvaluator;
begin
  Evaluator := MatchEvaluator;
  Result := TRegEx.Replace(JSON,
    '(?<quoted>"(?:[^"\\]|\\.)*")|(?<=[,\[])(?<left>,)|(?<right>,)(?=[,\]])',
    Evaluator);
end;

procedure TGoogleTranslate.GetAllLanguages(Items: TStrings);
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

procedure TGoogleTranslate.GetFromLanguages(Items: TStrings);
var
  i: Integer;
begin
  GetAllLanguages(Items);
  i := Items.IndexOf('Auto detect');
  Items.Move(i, 0);
end;

procedure TGoogleTranslate.GetToLanguages(Items: TStrings);

var
  i: Integer;
begin
  GetAllLanguages(Items);
  i := Items.IndexOf('Auto detect');
  Items.Delete(i);
end;

constructor TGoogleTranslate.Create;
begin
  FCriticalSection := TCriticalSection.Create;
  FHttp := TidHttp.Create(nil);
  FHttp.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(FHttp);
  FHttp.HandleRedirects := True;

  FHttp.Request.AcceptCharSet := 'utf-8';
  FHttp.Request.AcceptEncoding := 'utf-8';
  FHttp.Request.Connection := 'keep-alive';
  FHttp.Request.UserAgent :=
    'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.0.3705; .NET CLR 1.1.4322)';

  FLangs := TLangsDictionary.Create;
  FLangs.Add('Auto detect', 'auto');
  FLangs.Add('Afrikaans', 'af');
  FLangs.Add('Albanian', 'sq');
  FLangs.Add('Arabic', 'ar');
  FLangs.Add('Armenian', 'hy');
  FLangs.Add('Azerbaijani', 'az');
  FLangs.Add('Basque', 'eu');
  FLangs.Add('Belarusian', 'be');
  FLangs.Add('Bengali', 'bn');
  FLangs.Add('Bosnian', 'bs');
  FLangs.Add('Bulgarian', 'bg');
  FLangs.Add('Catalan', 'ca');
  FLangs.Add('Cebuano', 'ceb');
  FLangs.Add('Chichewa', 'ny');
  FLangs.Add('Chinese Simplified', 'zh-CN');
  FLangs.Add('Chinese Traditional', 'zh-TW');
  FLangs.Add('Croatian', 'hr');
  FLangs.Add('Czech', 'cs');
  FLangs.Add('Danish', 'da');
  FLangs.Add('Dutch', 'nl');
  FLangs.Add('English', 'en');
  FLangs.Add('Esperanto', 'eo');
  FLangs.Add('Estonian', 'et');
  FLangs.Add('Filipino', 'tl');
  FLangs.Add('Finnish', 'fi');
  FLangs.Add('French', 'fr');
  FLangs.Add('Galician', 'gl');
  FLangs.Add('Georgian', 'ka');
  FLangs.Add('German', 'de');
  FLangs.Add('Greek', 'el');
  FLangs.Add('Gujarati', 'gu');
  FLangs.Add('Haitian Creole', 'ht');
  FLangs.Add('Hausa', 'ha');
  FLangs.Add('Hebrew', 'iw');
  FLangs.Add('Hindi', 'hi');
  FLangs.Add('Hmong', 'hmn');
  FLangs.Add('Hungarian', 'hu');
  FLangs.Add('Icelandic', 'is');
  FLangs.Add('Igbo', 'ig');
  FLangs.Add('Indonesian', 'id');
  FLangs.Add('Irish', 'ga');
  FLangs.Add('Italian', 'it');
  FLangs.Add('Japanese', 'ja');
  FLangs.Add('Javanese', 'jw');
  FLangs.Add('Kannada', 'kn');
  FLangs.Add('Kazakh', 'kk');
  FLangs.Add('Khmer', 'km');
  FLangs.Add('Korean', 'ko');
  FLangs.Add('Lao', 'lo');
  FLangs.Add('Latin', 'la');
  FLangs.Add('Latvian', 'lv');
  FLangs.Add('Lithuanian', 'lt');
  FLangs.Add('Macedonian', 'mk');
  FLangs.Add('Malagasy', 'mg');
  FLangs.Add('Malay', 'ms');
  FLangs.Add('Malayalam', 'ml');
  FLangs.Add('Maltese', 'mt');
  FLangs.Add('Maori', 'mi');
  FLangs.Add('Marathi', 'mr');
  FLangs.Add('Mongolian', 'mn');
  FLangs.Add('Myanmar (Burmese)', 'my');
  FLangs.Add('Nepali', 'ne');
  FLangs.Add('Norwegian', 'no');
  FLangs.Add('Persian', 'fa');
  FLangs.Add('Polish', 'pl');
  FLangs.Add('Portuguese', 'pt');
  FLangs.Add('Punjabi', 'ma');
  FLangs.Add('Romanian', 'ro');
  FLangs.Add('Russian', 'ru');
  FLangs.Add('Serbian', 'sr');
  FLangs.Add('Sesotho', 'st');
  FLangs.Add('Sinhala', 'si');
  FLangs.Add('Slovak', 'sk');
  FLangs.Add('Slovenian', 'sl');
  FLangs.Add('Somali', 'so');
  FLangs.Add('Spanish', 'es');
  FLangs.Add('Sudanese', 'su');
  FLangs.Add('Swahili', 'sw');
  FLangs.Add('Swedish', 'sv');
  FLangs.Add('Tajik', 'tg');
  FLangs.Add('Tamil', 'ta');
  FLangs.Add('Telugu', 'te');
  FLangs.Add('Thai', 'th');
  FLangs.Add('Turkish', 'tr');
  FLangs.Add('Ukrainian', 'uk');
  FLangs.Add('Urdu', 'ur');
  FLangs.Add('Uzbek', 'uz');
  FLangs.Add('Vietnamese', 'vi');
  FLangs.Add('Welsh', 'cy');
  FLangs.Add('Yiddish', 'yi');
  FLangs.Add('Yoruba', 'yo');
  FLangs.Add('Zulu', 'zu');

  FSrcLang := 'auto';
  FDestLang := 'ru';
end;

destructor TGoogleTranslate.Destroy;
begin
  FHttp.Free;
  FLangs.Free;
  FCriticalSection.Free;
  inherited;
end;

procedure TGoogleTranslate.DoTranslate(const Text: string;
  Callback: TOnTranslateNotify);
var
  TranslateThread: TTranslateThread;
begin
  TranslateThread := TTranslateThread.Create(True);
  TranslateThread.FreeOnTerminate := True;
  TranslateThread.DoTranslate(self, Text, Callback);
end;

function TGoogleTranslate.ExtractTranslation(const JSON: string): string;
var
  JSONArray: TJSONArray;
  arr: TJSONArray;
  jValue: TJSONValue;
  textArrays: TJSONArray;
begin
  Result := '';
  JSONArray := TJSONObject.ParseJSONValue(JSON) as TJSONArray;
  if Assigned(JSONArray) then
    try
      try
        // [[["needle", "..."], ["needle2", "..."] ...
        textArrays := JSONArray.Items[0] as TJSONArray;
        for jValue in textArrays do
        begin
          arr := jValue as TJSONArray;
          Result := Result + ' ' + arr.Items[0].Value;
        end;
      except
        Result := '';
        exit;
      end;
    finally
      JSONArray.Free;
    end;
end;

{ TTranslateThread }

procedure TTranslateThread.DoTranslate(const Translator: TGoogleTranslate;
  const Text: string; Callback: TOnTranslateNotify);
begin
  FText := Text;
  FOnTranslate := Callback;
  FTranslator := Translator;
  Execute;
end;

procedure TTranslateThread.Execute;
var
  Translation: string;
begin
  Translation := FTranslator.Translate(FText);
  Synchronize(
    procedure
    begin
      FOnTranslate(Translation);
    end);
end;

end.
