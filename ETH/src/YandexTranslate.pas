unit YandexTranslate;

interface

uses
  IdHTTP,
  SysUtils,
  DBXJSON,
  HTTPApp,
  IdSSLOpenSSL,
  System.RegularExpressions,
  Classes,
  Translator;

type
  TYandexTranslate = class(TTranslator)
  private
    function ExtractTranslation(json: string): string;
    function URLEncode(const wstr: widestring): string;
  private
    FHttp: TidHttp;
    FApiKey: string;
  public
    function Translate(Text: string): string; override;
    procedure GetFromLanguages(Items: TStrings); override;
    procedure GetToLanguages(Items: TStrings); override;
    constructor Create(ApiKey: string);
    destructor Destroy; override;
  end;

implementation

{ YandexTranslate }

function TYandexTranslate.Translate(Text: string): string;
var
  response, url, srctext: string;
begin
  srctext := URLEncode(Text);

  url := Format
    ('https://translate.yandex.net/api/v1.5/tr.json/translate?key=%s&text=%s&lang=%s-%s&format=plain',
    [FApiKey, srctext, FSrcLang, FDestLang]);

  try
    response := FHttp.Get(url);
  except
    Result := Text;
    exit;
  end;

  Result := ExtractTranslation(response);
  if Result = '' then
    Result := Text;
end;

function TYandexTranslate.URLEncode(const wstr: widestring): string;
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

constructor TYandexTranslate.Create(ApiKey: string);
begin
  inherited Create;
  FApiKey := ApiKey;
  FHttp := TidHttp.Create(nil);
  FHttp.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(FHttp);
  FHttp.HandleRedirects := True;

  FHttp.Request.AcceptCharSet := 'utf-8';
  FHttp.Request.AcceptEncoding := 'utf-8';
  FHttp.Request.Connection := 'keep-alive';
  FHttp.Request.UserAgent :=
    'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.0.3705; .NET CLR 1.1.4322)';

  FLangs.Add('Afrikaans', 'af');
  FLangs.Add('Arabic', 'ar');
  FLangs.Add('Azerbaijani', 'az');
  FLangs.Add('Bashkir', 'ba');
  FLangs.Add('Belarusian', 'be');
  FLangs.Add('Bulgarian', 'bg');
  FLangs.Add('Bengali', 'bn');
  FLangs.Add('Bosnian', 'bs');
  FLangs.Add('Catalan', 'ca');
  FLangs.Add('Czech', 'cs');
  FLangs.Add('Welsh', 'cy');
  FLangs.Add('Danish', 'da');
  FLangs.Add('German', 'de');
  FLangs.Add('Greek', 'el');
  FLangs.Add('English', 'en');
  FLangs.Add('Spanish', 'es');
  FLangs.Add('Estonian', 'et');
  FLangs.Add('Basque', 'eu');
  FLangs.Add('Persian', 'fa');
  FLangs.Add('Finnish', 'fi');
  FLangs.Add('French', 'fr');
  FLangs.Add('Irish', 'ga');
  FLangs.Add('Galician', 'gl');
  FLangs.Add('Gujarati', 'gu');
  FLangs.Add('Hebrew', 'he');
  FLangs.Add('Hindi', 'hi');
  FLangs.Add('Croatian', 'hr');
  FLangs.Add('Haitian', 'ht');
  FLangs.Add('Hungarian', 'hu');
  FLangs.Add('Armenian', 'hy');
  FLangs.Add('Indonesian', 'id');
  FLangs.Add('Icelandic', 'is');
  FLangs.Add('Italian', 'it');
  FLangs.Add('Japanese', 'ja');
  FLangs.Add('Georgian', 'ka');
  FLangs.Add('Kazakh', 'kk');
  FLangs.Add('Kannada', 'kn');
  FLangs.Add('Korean', 'ko');
  FLangs.Add('Kirghiz', 'ky');
  FLangs.Add('Latin', 'la');
  FLangs.Add('Lithuanian', 'lt');
  FLangs.Add('Latvian', 'lv');
  FLangs.Add('Malagasy', 'mg');
  FLangs.Add('Macedonian', 'mk');
  FLangs.Add('Mongolian', 'mn');
  FLangs.Add('Malay', 'ms');
  FLangs.Add('Maltese', 'mt');
  FLangs.Add('Dutch', 'nl');
  FLangs.Add('Norwegian', 'no');
  FLangs.Add('Punjabi', 'pa');
  FLangs.Add('Polish', 'pl');
  FLangs.Add('Portuguese', 'pt');
  FLangs.Add('Romanian', 'ro');
  FLangs.Add('Russian', 'ru');
  FLangs.Add('Sinhalese', 'si');
  FLangs.Add('Slovak', 'sk');
  FLangs.Add('Slovenian', 'sl');
  FLangs.Add('Albanian', 'sq');
  FLangs.Add('Serbian', 'sr');
  FLangs.Add('Swedish', 'sv');
  FLangs.Add('Swahili', 'sw');
  FLangs.Add('Tamil', 'ta');
  FLangs.Add('Tajik', 'tg');
  FLangs.Add('Thai', 'th');
  FLangs.Add('Tagalog', 'tl');
  FLangs.Add('Turkish', 'tr');
  FLangs.Add('Tatar', 'tt');
  FLangs.Add('Udmurt', 'udm');
  FLangs.Add('Ukrainian', 'uk');
  FLangs.Add('Urdu', 'ur');
  FLangs.Add('Uzbek', 'uz');
  FLangs.Add('Vietnamese', 'vi');
  FLangs.Add('Chinese', 'zh');
end;

destructor TYandexTranslate.Destroy;
begin
  FHttp.Free;
  inherited;
end;

function TYandexTranslate.ExtractTranslation(json: string): string;
var
  JSONObject: TJSONObject;
  JsonArray: TJSONArray;
  i: Integer;
begin
  Result := '';
  JSONObject := TJSONObject.ParseJSONValue(json) as TJSONObject;
  if Assigned(JSONObject) then
    try
      try
        JsonArray := JSONObject.Get('text').JsonValue as TJSONArray;
        Result := JsonArray.Get(0).Value;
      except
        Result := '';
        exit;
      end;

    finally
      JSONObject.Free;
    end;
end;

procedure TYandexTranslate.GetFromLanguages(Items: TStrings);
begin
  GetAllLanguages(Items);
end;

procedure TYandexTranslate.GetToLanguages(Items: TStrings);
begin
  GetAllLanguages(Items);
end;

end.
