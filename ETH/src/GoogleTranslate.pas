unit GoogleTranslate;

interface

uses
  IdHTTP, SysUtils;

type
  Langrec = record
    langid: string;
    name: string;
  end;

  TGTranslateSettings = record
    useproxy: boolean;
    port: Integer;
    host: string;
    Autentification: boolean;
    ProxyUsername: string;
    ProxyPassword: string;
    srclang, destlang: Integer;
  end;

function GTranslate(Text: widestring;
  const settings: TGTranslateSettings): string;

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

function URLEncode(const wstr: widestring): string;
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

function HTTPGet(url: string; const settings: TGTranslateSettings): string;
var
  http: TidHttp;
begin
  http := TidHttp.Create(nil);
  try
    if settings.useproxy then
    begin
      http.ProxyParams.ProxyPort := settings.port;
      http.ProxyParams.ProxyServer := settings.host;
      if settings.Autentification then
      begin
        http.ProxyParams.ProxyUsername := settings.ProxyUsername;
        http.ProxyParams.ProxyPassword := settings.ProxyPassword;
      end;
    end;

    http.Request.AcceptCharSet := 'utf-8';
    http.Request.AcceptEncoding := 'utf-8';
    http.Request.Referer := 'http://google.com';
    http.Request.UserAgent :=
      'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.0.3705; .NET CLR 1.1.4322)';
    // без рефера выдает кодировки отличные от utf-8
    Result := http.Get(url);
  finally
    http.Free;
  end;
end;

function GTranslate(Text: widestring;
  const settings: TGTranslateSettings): string;
var
  response: UTF8String;
  url, srctext: string;

  procedure UnescappeStr(var str: string);
  begin
    str := StringReplace(str, '\u0026quot;', '"', [rfReplaceAll]);
    str := StringReplace(str, '\u0026#39;', #39, [rfReplaceAll]);
    str := StringReplace(str, '\u0026gt;', '>', [rfReplaceAll]);
    str := StringReplace(str, '\u0026lt;', '<', [rfReplaceAll]);
    str := StringReplace(str, '\u0026amp;', '', [rfReplaceAll]);
    str := StringReplace(str, '\u200b', '', [rfReplaceAll]);
  end;

  function ParseJSON_lol(response: string): string;
  var
    S: string;
    i: Integer;
  begin
    response := Copy(response, pos('[[["', response) + 4, Length(response));

    i := 1;
    while (i <= Length(response)) do
    begin
      if (response[i] = '\') then
        inc(i)
      else if (response[i] = '"') then
        break;
      S := S + response[i];
      inc(i); // i++;
    end;
    UnescappeStr(S);
    Result := S;
  end;

begin
  srctext := URLEncode(Text);

  url := 'http://www.google.com/translate_a/t?client=t&sl=' +
    LangArr[settings.srclang].langid + '&tl=' + LangArr[settings.destlang]
    .langid + '&text=' + srctext;
  try
    response := UTF8String(HTTPGet(url, settings));
    // если нет инета возвращаем исходный текст
  except
    Result := Text;
    exit;
  end;

  Result := ParseJSON_lol(string(response));
end;

end.
