object MainForm: TMainForm
  Left = 271
  Top = 298
  Caption = 'Easy Text Hooker'
  ClientHeight = 152
  ClientWidth = 683
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 683
    Height = 152
    ActivePage = TabSheet3
    Align = alClient
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object TabSheet3: TTabSheet
      Caption = 'AGTH >'
      ImageIndex = 2
      DesignSize = (
        675
        124)
      object Memo1: TMemo
        Left = 199
        Top = 30
        Width = 473
        Height = 91
        Anchors = [akLeft, akTop, akRight, akBottom]
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object cbStreams: TComboBox
        Left = 199
        Top = 3
        Width = 473
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
        OnChange = cbStreamsChange
      end
      object GroupBox2: TGroupBox
        Left = 0
        Top = 0
        Width = 193
        Height = 121
        TabOrder = 2
        object Label7: TLabel
          Left = 3
          Top = 6
          Width = 45
          Height = 13
          Hint = 'Process:'
          Caption = #1055#1088#1086#1094#1077#1089#1089':'
        end
        object Label8: TLabel
          Left = 3
          Top = 33
          Width = 36
          Height = 13
          Caption = 'HCode:'
        end
        object Label12: TLabel
          Left = 3
          Top = 59
          Width = 111
          Height = 13
          Hint = 'Copy to clipboard after'
          Caption = 'Copy to clipboard after'
        end
        object Label13: TLabel
          Left = 172
          Top = 59
          Width = 13
          Height = 13
          Caption = 'ms'
        end
        object cbProcess: TComboBox
          Left = 54
          Top = 3
          Width = 136
          Height = 22
          Style = csOwnerDrawFixed
          Sorted = True
          TabOrder = 0
          OnDrawItem = cbProcessDrawItem
          OnDropDown = cbProcessDropDown
        end
        object edHCode: TEdit
          Left = 54
          Top = 30
          Width = 136
          Height = 21
          TabOrder = 1
        end
        object btnHook: TButton
          Left = 3
          Top = 92
          Width = 187
          Height = 25
          Caption = 'Hook'
          TabOrder = 2
          OnClick = btnHookClick
        end
        object seDelay: TSpinEdit
          Left = 120
          Top = 56
          Width = 46
          Height = 22
          MaxValue = 0
          MinValue = 0
          TabOrder = 3
          Value = 150
          OnChange = seDelayChange
        end
      end
    end
    object js_preProcess: TTabSheet
      Caption = 'Text processor >'
      ImageIndex = 5
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 153
        Height = 124
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
        object btnScriptLoad: TButton
          Left = 3
          Top = 94
          Width = 75
          Height = 25
          Caption = 'Load'
          TabOrder = 0
          OnClick = btnScriptLoadClick
        end
        object chbTextProcessor: TCheckBox
          Left = 3
          Top = 3
          Width = 62
          Height = 17
          Caption = 'Enable'
          TabOrder = 1
        end
        object mScriptPath: TMemo
          Left = 3
          Top = 26
          Width = 144
          Height = 62
          BevelInner = bvNone
          BevelOuter = bvNone
          BorderStyle = bsNone
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Consolas'
          Font.Style = []
          Lines.Strings = (
            'mScriptPath')
          ParentFont = False
          ReadOnly = True
          TabOrder = 2
        end
      end
      object ScriptArea: TRichEdit
        Left = 153
        Top = 0
        Width = 522
        Height = 124
        Align = alClient
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Consolas'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
    object TabSheet5: TTabSheet
      Caption = 'GoogleTranslate >'
      ImageIndex = 4
      object GroupBox1: TGroupBox
        Left = 0
        Top = 0
        Width = 193
        Height = 123
        DoubleBuffered = False
        ParentDoubleBuffered = False
        TabOrder = 0
        object Label1: TLabel
          Left = 7
          Top = 26
          Width = 123
          Height = 13
          Hint = 'Translate into'
          Caption = #1053#1072#1087#1088#1072#1074#1083#1077#1085#1080#1077' '#1087#1077#1088#1077#1074#1086#1076#1072':'
        end
        object Label3: TLabel
          Left = 3
          Top = 50
          Width = 28
          Height = 13
          Caption = 'From:'
        end
        object Label4: TLabel
          Left = 3
          Top = 77
          Width = 16
          Height = 13
          Caption = 'To:'
        end
        object DoTranslate: TCheckBox
          Left = 7
          Top = 3
          Width = 105
          Height = 17
          Hint = 'Enable Online Translate'
          ParentCustomHint = False
          Caption = #1054#1085#1083#1072#1081#1085' '#1087#1077#1088#1077#1074#1086#1076
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
        object srclen: TComboBox
          Left = 35
          Top = 47
          Width = 145
          Height = 21
          Hint = 'Source language'
          HelpType = htKeyword
          Style = csDropDownList
          TabOrder = 1
        end
        object destlen: TComboBox
          Left = 35
          Top = 74
          Width = 145
          Height = 21
          Hint = 'Destination language'
          Style = csDropDownList
          TabOrder = 2
        end
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'OSD'
      ImageIndex = 3
      object GroupBox3: TGroupBox
        Left = 3
        Top = 3
        Width = 142
        Height = 118
        TabOrder = 0
        object rbClipboard: TRadioButton
          Left = 8
          Top = 51
          Width = 113
          Height = 17
          Hint = 'from clipboard'
          Caption = #1048#1079' '#1073#1091#1092#1077#1088#1072' '#1086#1073#1084#1077#1085#1072
          TabOrder = 0
        end
        object rbText: TRadioButton
          Left = 8
          Top = 28
          Width = 129
          Height = 17
          Hint = 'from textarea'
          Caption = #1048#1079' '#1090#1077#1082#1089#1090#1086#1074#1086#1075#1086' '#1087#1086#1083#1103
          Checked = True
          TabOrder = 1
          TabStop = True
        end
        object cbEnableOSD: TCheckBox
          Left = 8
          Top = 5
          Width = 97
          Height = 17
          Hint = 'Enable'
          Caption = #1042#1082#1083#1102#1095#1080#1090#1100
          TabOrder = 2
          OnClick = cbEnableOSDClick
        end
      end
      object GroupBox4: TGroupBox
        Left = 151
        Top = -3
        Width = 242
        Height = 124
        Hint = 'Position'
        Caption = #1055#1086#1079#1080#1094#1080#1103
        TabOrder = 1
        object Label2: TLabel
          Left = 11
          Top = 21
          Width = 10
          Height = 13
          Caption = 'X:'
        end
        object Label9: TLabel
          Left = 11
          Top = 40
          Width = 10
          Height = 13
          Caption = 'Y:'
        end
        object Label10: TLabel
          Left = 11
          Top = 59
          Width = 44
          Height = 13
          Hint = 'Width:'
          Caption = #1064#1080#1088#1080#1085#1072':'
        end
        object Label11: TLabel
          Left = 11
          Top = 78
          Width = 41
          Height = 13
          Hint = 'Height:'
          Caption = #1042#1099#1089#1086#1090#1072':'
        end
        object tbX: TTrackBar
          Left = 61
          Top = 18
          Width = 177
          Height = 16
          Max = 100
          Position = 50
          PositionToolTip = ptTop
          TabOrder = 0
          ThumbLength = 15
          TickMarks = tmBoth
          TickStyle = tsNone
          OnChange = OSDPosChange
        end
        object tbY: TTrackBar
          Left = 61
          Top = 37
          Width = 177
          Height = 16
          Max = 100
          Position = 100
          PositionToolTip = ptTop
          TabOrder = 1
          ThumbLength = 15
          TickMarks = tmBoth
          TickStyle = tsNone
          OnChange = OSDPosChange
        end
        object tbWidth: TTrackBar
          Left = 61
          Top = 56
          Width = 177
          Height = 16
          Max = 100
          Position = 100
          PositionToolTip = ptTop
          TabOrder = 2
          ThumbLength = 15
          TickMarks = tmBoth
          TickStyle = tsNone
          OnChange = OSDPosChange
        end
        object tbHeight: TTrackBar
          Left = 61
          Top = 75
          Width = 177
          Height = 16
          Max = 100
          Position = 10
          PositionToolTip = ptTop
          TabOrder = 3
          ThumbLength = 15
          TickMarks = tmBoth
          TickStyle = tsNone
          OnChange = OSDPosChange
        end
      end
      object Шрифт: TGroupBox
        Left = 399
        Top = -3
        Width = 170
        Height = 124
        Hint = 'Font'
        Caption = #1064#1088#1080#1092#1090
        TabOrder = 2
        object Label14: TLabel
          Left = 11
          Top = 49
          Width = 68
          Height = 13
          Hint = 'Font color:'
          Caption = #1062#1074#1077#1090' '#1090#1077#1082#1089#1090#1072':'
        end
        object Label15: TLabel
          Left = 11
          Top = 77
          Width = 76
          Height = 13
          Hint = 'Outline color:'
          Caption = #1062#1074#1077#1090' '#1086#1073#1074#1086#1076#1082#1080':'
        end
        object imgTextColor: TImage
          Left = 105
          Top = 44
          Width = 55
          Height = 21
          Cursor = crHandPoint
          OnClick = imgTextColorClick
        end
        object imgOutlineColor: TImage
          Left = 105
          Top = 72
          Width = 55
          Height = 21
          Cursor = crHandPoint
          OnClick = imgOutlineColorClick
        end
        object Label16: TLabel
          Left = 11
          Top = 105
          Width = 90
          Height = 13
          Hint = 'Outline width:'
          Caption = #1064#1080#1088#1080#1085#1072' '#1086#1073#1074#1086#1076#1082#1080':'
        end
        object btnOsdFontSelect: TButton
          Left = 8
          Top = 16
          Width = 75
          Height = 25
          Hint = 'Select font'
          Caption = #1064#1088#1080#1092#1090
          TabOrder = 0
          OnClick = btnOsdFontSelectClick
        end
        object tbOutline: TTrackBar
          Left = 99
          Top = 103
          Width = 68
          Height = 16
          Max = 6
          Min = 1
          Position = 1
          PositionToolTip = ptTop
          TabOrder = 1
          ThumbLength = 15
          TickMarks = tmBoth
          TickStyle = tsNone
          OnChange = tbOutlineChange
        end
      end
    end
    object TabSheet2: TTabSheet
      Hint = 'Text'
      Caption = #1058#1077#1082#1089#1090
      ImageIndex = 1
      ParentShowHint = False
      ShowHint = True
      object Memo: TMemo
        Left = 0
        Top = 28
        Width = 675
        Height = 96
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
        ExplicitTop = 33
        ExplicitHeight = 91
      end
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 675
        Height = 28
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        DesignSize = (
          675
          28)
        object FontSet: TButton
          Left = 603
          Top = 0
          Width = 69
          Height = 25
          Hint = 'Set Font'
          Anchors = [akTop, akRight]
          Caption = #1064#1088#1080#1092#1090
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnClick = FontSetClick
        end
        object ClipboardCopy: TCheckBox
          Left = 8
          Top = 4
          Width = 198
          Height = 17
          Hint = 'Copy text to clipboard'
          Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1090#1077#1082#1089#1090' '#1074' '#1073#1091#1092#1077#1088' '#1086#1073#1084#1077#1085#1072
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
        end
      end
    end
  end
  object Timer: TTimer
    Interval = 100
    OnTimer = TimerTimer
    Left = 112
    Top = 112
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Mincho'
    Font.Style = []
    Options = [fdEffects, fdNoVectorFonts]
    Left = 80
    Top = 112
  end
  object ProcIcon: TImageList
    BkColor = clWindow
    Masked = False
    Left = 48
    Top = 112
  end
  object Images: TImageList
    Left = 16
    Top = 112
    Bitmap = {
      494C010101000800A00010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000B05E3A00AA573200A250
      2C009C4C2A009A4B29009A4B29009A4B29009A4B29009A4B29009A4B29009A4B
      29009A4B29008B44250086412400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000B7654200F3E9E000F3E9E000F3E9
      E000F3E9E000F3E9E000F3E9E000F3E9E000F3E9E000F3E9E000F3E9E000F3E9
      E000F3E9E000F3E9E000F3E9E000823F23000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000B96A4700EFDFD300FBF7F400FBF7
      F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7
      F400FBF7F400FBF7F400F3E9E000834023000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000BB6D4B00EFDFD300FBF7F400FBF7
      F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7
      F400FBF7F400FBF7F400F3E9E0008C4425000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000BC704F00EFDFD300FBF7F400FBF7
      F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7
      F400FBF7F400FBF7F400F3E9E0008F4626000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000BD715000EFDFD300FBF7F400FBF7
      F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7
      F400FBF7F400FBF7F400F3E9E000904626000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000BD715000EFDFD300FBF7F400FBF7
      F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7
      F400FBF7F400FBF7F400F3E9E000904626000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000BD715000EFDFD300FBF7F400FBF7
      F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7
      F400FBF7F400FBF7F400F3E9E000904626000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000BD715000EFDFD300FBF7F400FBF7
      F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7
      F400FBF7F400FBF7F400F3E9E000904626000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000BE735300EFDFD300FBF7F400FBF7
      F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7F400FBF7
      F400FBF7F400FBF7F400F3E9E000924727000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C17A5B00EFDFD300EFDFD300EFDF
      D300EFDFD300EFDFD300EFDFD300EFDFD300EFDFD300EFDFD300EFDFD300EFDF
      D300EFDFD300EFDFD300F3E9E000964A28000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C4826500B0562F00B0562F00B056
      2F00B0562F00B0562F00B0562F00B0562F00B0562F00B0562F00B0562F00B056
      2F00B0562F00B0562F00B0562F009A4B29000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C4806300F3E9E000B0562F00B056
      2F00B0562F00B0562F00B0562F00B0562F00B0562F00B0562F00F3E9E000B056
      2F00F3E9E000B0562F00F3E9E0009D4D2A000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C17B5D00BF765700BB6D
      4B00B7664300B5633F00B5633F00B5633F00B5633F00B5633F00B5633F00B563
      3F00B15D3900A9563100A3502C00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFF0000000000008001000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      8001000000000000FFFF00000000000000000000000000000000000000000000
      000000000000}
  end
  object ColorDialog1: TColorDialog
    Left = 144
    Top = 112
  end
  object OpenDialog1: TOpenDialog
    Left = 176
    Top = 112
  end
end
