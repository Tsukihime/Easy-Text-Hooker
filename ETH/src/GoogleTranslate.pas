unit GoogleTranslate;

interface

uses
  IdHTTP,
  SysUtils,
  DBXJSON,
  HTTPApp,
  IdSSLOpenSSL,
  System.RegularExpressions;

type
  Langrec = record
    langid: string;
    name: string;
  end;

  TGoogleTranslate = class
  private
    function GTranslate(Text: widestring; srclang, destlang: Integer): string;
    function ExtractTranslation(json: string): string;
    function HTTPGet(url: string): string;
    function URLEncode(const wstr: widestring): string;
    function MatchEvaluator(const Match: TMatch): string;
    function FixGoogleJSON(json: string): string;
  public
    class function Translate(Text: widestring;
      srclang, destlang: Integer): string;
  end;

var
  LangArr: array [0 .. 58] of Langrec = ((langid: 'af'; name: 'Afrikaans'),
    (langid: 'sq'; name: 'Albanian'), (langid: 'ar'; name: 'Arabic'),
    (langid: 'hy'; name: 'Armenian'), (langid: 'az'; name: 'Azerbaijani'),
    (langid: 'eu'; name: 'Basque'), (langid: 'be'; name: 'Belarusian'),
    (langid: 'bg'; name: 'Bulgarian'), (langid: 'ca'; name: 'Catalan'),
    (langid: 'zh-CN'; name: 'Chinese (Simplified)'), (langid: 'zh-TW';
    name: 'Chinese (Traditional)'), (langid: 'hr'; name: 'Croatian'),
    (langid: 'cs'; name: 'Czech'), (langid: 'da'; name: 'Danish'),
    (langid: 'nl'; name: 'Dutch'), (langid: 'en'; name: 'English'),
    (langid: 'et'; name: 'Estonian'), (langid: 'tl'; name: 'Filipino'),
    (langid: 'fi'; name: 'Finnish'), (langid: 'fr'; name: 'French'),
    (langid: 'gl'; name: 'Galician'), (langid: 'ka'; name: 'Georgian'),
    (langid: 'de'; name: 'German'), (langid: 'el'; name: 'Greek'),
    (langid: 'ht'; name: 'Haitian Creole'), (langid: 'iw'; name: 'Hebrew'),
    (langid: 'hi'; name: 'Hindi'), (langid: 'hu'; name: 'Hungarian'),
    (langid: 'is'; name: 'Icelandic'), (langid: 'id'; name: 'Indonesian'),
    (langid: 'ga'; name: 'Irish'), (langid: 'it'; name: 'Italian'),
    (langid: 'ja'; name: 'Japanese'), (langid: 'ko'; name: 'Korean'),
    (langid: 'la'; name: 'Latin'), (langid: 'lv'; name: 'Latvian'),
    (langid: 'lt'; name: 'Lithuanian'), (langid: 'mk'; name: 'Macedonian'),
    (langid: 'ms'; name: 'Malay'), (langid: 'mt'; name: 'Maltese'),
    (langid: 'no'; name: 'Norwegian'), (langid: 'fa'; name: 'Persian'),
    (langid: 'pl'; name: 'Polish'), (langid: 'pt'; name: 'Portuguese'),
    (langid: 'ro'; name: 'Romanian'), (langid: 'ru'; name: 'Russian'),
    (langid: 'sr'; name: 'Serbian'), (langid: 'sk'; name: 'Slovak'),
    (langid: 'sl'; name: 'Slovenian'), (langid: 'es'; name: 'Spanish'),
    (langid: 'sw'; name: 'Swahili'), (langid: 'sv'; name: 'Swedish'),
    (langid: 'th'; name: 'Thai'), (langid: 'tr'; name: 'Turkish'),
    (langid: 'uk'; name: 'Ukrainian'), (langid: 'ur'; name: 'Urdu'),
    (langid: 'vi'; name: 'Vietnamese'), (langid: 'cy'; name: 'Welsh'),
    (langid: 'yi'; name: 'Yiddish'));

implementation

{ TGoogleTranslate }

class function TGoogleTranslate.Translate(Text: widestring;
  srclang, destlang: Integer): string;
var
  gt: TGoogleTranslate;
begin
  gt := TGoogleTranslate.Create;
  try
    Result := gt.GTranslate(Text, srclang, destlang);
  finally
    gt.Free;
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

function TGoogleTranslate.HTTPGet(url: string): string;
var
  http: TidHttp;
begin
  http := TidHttp.Create(nil);
  try
    http.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(http);
    http.HandleRedirects := True;

    http.Request.AcceptCharSet := 'utf-8';
    http.Request.AcceptEncoding := 'utf-8';
    http.Request.Referer := 'https://translate.google.com/';
    http.Request.UserAgent :=
      'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.0.3705; .NET CLR 1.1.4322)';
    // без рефера выдает кодировки отличные от utf-8
    Result := http.Get(url);
  finally
    http.Free;
  end;
end;

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

function TGoogleTranslate.ExtractTranslation(json: string): string;
var
  JSONValue: TJSONValue;
  arr, sentence_arr: TJSONArray;
  i: Integer;
begin
  Result := '';
  JSONValue := TJSONObject.ParseJSONValue(json) as TJSONValue;
  if Assigned(JSONValue) then
    try
      try
        // [[["needle", "..."],["needle2", "..."]  ...
        arr := JSONValue as TJSONArray;
        arr := arr.Get(0) as TJSONArray;
        for i := 0 to arr.Size - 2 do // skip last
        begin
          sentence_arr := arr.Get(i) as TJSONArray;
          Result := Result + (sentence_arr.Get(0) as TJSONString).Value;
        end;
      except
        Result := '';
        exit;
      end;

      Result := HTMLDecode(Result);
    finally
      JSONValue.Free;
    end;
end;

function TGoogleTranslate.GTranslate(Text: widestring;
  srclang, destlang: Integer): string;
var
  response, url, srctext, sl, tl: string;
begin
  srctext := URLEncode(Text);
  sl := LangArr[srclang].langid;
  tl := LangArr[destlang].langid;

  url := Format
    ('https://translate.google.com/translate_a/single?client=t&sl=%s&tl=%s&hl=en&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&dt=at&ie=UTF-8&oe=UTF-8&otf=1&ssel=0&tsel=0&kc=0&q=%s',
    [sl, tl, srctext]);

  try
    response := HTTPGet(url);
  except
    Result := Text;
    exit;
  end;

  Result := ExtractTranslation(FixGoogleJSON(response));
  if Result = '' then
    Result := Text;

end;

end.
