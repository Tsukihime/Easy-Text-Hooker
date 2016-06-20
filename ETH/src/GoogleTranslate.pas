unit GoogleTranslate;

interface

uses
  IdHTTP,
  SysUtils,
  DBXJSON,
  HTTPApp,
  IdSSLOpenSSL,
  System.RegularExpressions,
  Translator;

type
  TGoogleTranslate = class(TTranslator)
  private
    function ExtractTranslation(json: string): string;
    function URLEncode(const wstr: widestring): string;
    function MatchEvaluator(const Match: TMatch): string;
    function FixGoogleJSON(json: string): string;
  private
    FHttp: TidHttp;
  public
    function Translate(Text: string): string; override;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TGoogleTranslate }

function TGoogleTranslate.Translate(Text: string): string;
var
  response, url, srctext: string;
begin
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
function TGoogleTranslate.FixGoogleJSON(json: string): string;
begin
  Result := TRegEx.Replace(json, '(?<quoted>"(?:[^"\\]|\\.)*")|' +
    '(?<=[,\[])(?<left>,)|' + '(?<right>,)(?=[,\]])', MatchEvaluator);
end;

constructor TGoogleTranslate.Create;
begin
  inherited;
  FHttp := TidHttp.Create(nil);
  FHttp.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(FHttp);
  FHttp.HandleRedirects := True;

  FHttp.Request.AcceptCharSet := 'utf-8';
  FHttp.Request.AcceptEncoding := 'utf-8';
  FHttp.Request.Connection := 'keep-alive';
  FHttp.Request.UserAgent :=
    'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.0.3705; .NET CLR 1.1.4322)';

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
end;

destructor TGoogleTranslate.Destroy;
begin
  FHttp.Free;
  inherited;
end;

function TGoogleTranslate.ExtractTranslation(json: string): string;
var
  JSONArray: TJSONArray;
  arr: TJSONArray;
  i: Integer;
begin
  Result := '';
  JSONArray := TJSONObject.ParseJSONValue(json) as TJSONArray;
  if Assigned(JSONArray) then
    try
      try
        // [[["needle", "..."] ...
        arr := JSONArray.Get(0) as TJSONArray;
        arr := arr.Get(0) as TJSONArray;
        Result := arr.Get(0).Value
      except
        Result := '';
        exit;
      end;
    finally
      JSONArray.Free;
    end;
end;

end.
