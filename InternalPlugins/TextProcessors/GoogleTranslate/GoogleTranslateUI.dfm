object GoogleTranslateSettingsForm: TGoogleTranslateSettingsForm
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'GoogleTranslateSettingsForm'
  ClientHeight = 98
  ClientWidth = 218
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 201
    Height = 81
    DoubleBuffered = False
    ParentDoubleBuffered = False
    TabOrder = 0
    object Label1: TLabel
      Left = 7
      Top = 3
      Width = 93
      Height = 13
      Caption = 'Translate direction:'
    end
    object Label3: TLabel
      Left = 10
      Top = 26
      Width = 28
      Height = 13
      Caption = 'From:'
    end
    object Label4: TLabel
      Left = 10
      Top = 53
      Width = 16
      Height = 13
      Caption = 'To:'
    end
    object SrcLang: TComboBox
      Left = 45
      Top = 23
      Width = 145
      Height = 21
      Hint = 'Source language'
      HelpType = htKeyword
      Style = csDropDownList
      TabOrder = 0
      OnChange = LangChange
    end
    object DestLang: TComboBox
      Left = 45
      Top = 50
      Width = 145
      Height = 21
      Hint = 'Destination language'
      Style = csDropDownList
      TabOrder = 1
      OnChange = LangChange
    end
  end
end
