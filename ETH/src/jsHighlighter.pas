// my second bike
unit jsHighlighter;

interface

uses ComCtrls, classes, graphics, sysutils;

type
  TRichEditJsHighlighter = class
    class procedure jsHighlight(richedit: TRichEdit); static;
  private
    class function isReserved(_word: string): boolean; static;
    class function isDelimiter(ch: char): boolean; static;
  end;

const
  delimiters: string = ' ,(){}[]-+*%/="''~!&|<>?:;.' + #$9 + #$D + #$A;

  Reswords: array [0 .. 54] of string = ('abstract', 'boolean', 'break', 'byte',
    'case', 'catch', 'char', 'class', 'const', 'continue', 'default', 'delete',
    'do', 'double', 'else', 'extends', 'false', 'final', 'finally', 'float',
    'for', 'function', 'goto', 'if', 'implements', 'import', 'in', 'instanceof',
    'int', 'interface', 'long', 'native', 'new', 'null', 'package', 'private',
    'protected', 'public', 'return', 'short', 'static', 'super', 'switch',
    'synchronized', 'this', 'throw', 'throws', 'transient', 'true', 'try',
    'typeof', 'var', 'void', 'while', 'with');

implementation

{ TRichEditJsHighlighter }

class function TRichEditJsHighlighter.isReserved(_word: string): boolean;
var
  i: integer;
begin
  Result := false;
  _word := LowerCase(_word);
  for i := 0 to Length(Reswords) - 1 do
    if _word = Reswords[i] then
    begin
      Result := true;
      break;
    end;
end;

class function TRichEditJsHighlighter.isDelimiter(ch: char): boolean;
var
  i: integer;
begin
  Result := false;
  for i := 1 to Length(delimiters) do
    if ch = delimiters[i] then
    begin
      Result := true;
      break;
    end;
end;

class procedure TRichEditJsHighlighter.jsHighlight(richedit: TRichEdit);
var
  current_line: integer;

  procedure highlight_block(start, _end: integer; Color: TColor;
    isBold: boolean = false);
  var
    len: integer;
  begin
    len := _end - start + 1;
    start := start - 1 - current_line;
    richedit.SelStart := start;
    richedit.SelLength := len;
    richedit.SelAttributes.Color := Color;
    if isBold then
      richedit.SelAttributes.Style := [fsBold];
  end;

var
  text, tmp: string;
  i: integer;
  state: integer;
  lastpos: integer;
  len: integer;
  tmp2: Double;

begin
  richedit.PlainText := true;
  text := richedit.text;
  richedit.PlainText := false;

  state := 0;
  current_line := 0;
  lastpos := 0;
  i := 1;
  len := Length(text);
  while i <= len do
  begin
    if (text[i] = #$0D) then
      inc(current_line);

    case (state) of
      0:
        case (text[i]) of
          '/':
            if (i + 1 < len - 1) then
              case (text[i + 1]) of
                '/':
                  begin
                    lastpos := i;
                    state := 1;
                    i := i + 1;
                  end;
                '*':
                  begin
                    lastpos := i;
                    state := 2;
                    i := i + 1;
                  end
              end;

          '"':
            begin
              lastpos := i;
              state := 3;
            end;

          '''':
            begin
              lastpos := i;
              state := 4;
            end;

        else
          if isDelimiter(text[i]) then
          begin
            tmp := copy(text, lastpos, i - lastpos);
            if isReserved(tmp) then
              highlight_block(lastpos, i - 1, clNavy, true);

            if TryStrToFloat(tmp, tmp2) then
              highlight_block(lastpos, i - 1, clBlue);

            lastpos := i + 1;
          end;

        end;

      1: // single line comment
        if (text[i] = #$0D) or (text[i] = #$0A) then
        begin
          highlight_block(lastpos, i, clGreen);
          state := 0;
        end;

      2: // multi line comment
        if (text[i] = '*') then
          if (i + 1 < len - 1) then
            if (text[i + 1] = '/') then
            begin
              i := i + 1;
              highlight_block(lastpos, i, clGreen);
              state := 0;
            end;

      3:
        if (text[i] = '"') then
        begin
          highlight_block(lastpos, i, clBlue);
          state := 0;
        end;

      4:
        if (text[i] = '''') then
        begin
          highlight_block(lastpos, i, clBlue);
          state := 0;
        end;
    end;

    i := i + 1;
  end;
end;

end.
