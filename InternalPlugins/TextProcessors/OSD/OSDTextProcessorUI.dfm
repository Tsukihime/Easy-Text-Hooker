object OSDSettings: TOSDSettings
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'OSDSettingsForm'
  ClientHeight = 259
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    400
    259)
  PixelsPerInch = 96
  TextHeight = 13
  object Font: TGroupBox
    Left = 8
    Top = 147
    Width = 384
    Height = 102
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Font'
    TabOrder = 1
    DesignSize = (
      384
      102)
    object Label14: TLabel
      Left = 11
      Top = 22
      Width = 52
      Height = 13
      Caption = 'Font color:'
    end
    object Label15: TLabel
      Left = 11
      Top = 50
      Width = 64
      Height = 13
      Caption = 'Outline color:'
    end
    object imgTextColor: TImage
      Left = 113
      Top = 17
      Width = 55
      Height = 21
      Cursor = crHandPoint
      OnClick = imgTextColorClick
    end
    object imgOutlineColor: TImage
      Left = 113
      Top = 44
      Width = 55
      Height = 21
      Cursor = crHandPoint
      OnClick = imgOutlineColorClick
    end
    object Label16: TLabel
      Left = 182
      Top = 50
      Width = 67
      Height = 13
      Caption = 'Outline width:'
    end
    object Label1: TLabel
      Left = 11
      Top = 78
      Width = 86
      Height = 13
      Caption = 'Background color:'
    end
    object imgBackgroundColor: TImage
      Left = 113
      Top = 71
      Width = 55
      Height = 21
      Cursor = crHandPoint
      OnClick = imgBackgroundColorClick
    end
    object Label3: TLabel
      Left = 182
      Top = 78
      Width = 70
      Height = 13
      Caption = 'Transparency:'
    end
    object btnOsdFontSelect: TButton
      Left = 182
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Select font'
      TabOrder = 0
      OnClick = btnOsdFontSelectClick
    end
    object tbOutline: TTrackBar
      Left = 263
      Top = 47
      Width = 118
      Height = 16
      Anchors = [akLeft, akTop, akRight]
      Max = 9
      Position = 1
      PositionToolTip = ptTop
      TabOrder = 1
      ThumbLength = 15
      TickMarks = tmBoth
      TickStyle = tsNone
      OnChange = tbOutlineChange
    end
    object tbBackgroundTransparency: TTrackBar
      Left = 263
      Top = 76
      Width = 118
      Height = 16
      Anchors = [akLeft, akTop, akRight]
      Max = 255
      PositionToolTip = ptTop
      TabOrder = 2
      ThumbLength = 15
      TickMarks = tmBoth
      TickStyle = tsNone
      OnChange = tbBackgroundTransparencyChange
    end
  end
  object GroupBox4: TGroupBox
    Left = 8
    Top = 24
    Width = 384
    Height = 124
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Position'
    TabOrder = 2
    DesignSize = (
      384
      124)
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
      Width = 32
      Height = 13
      Caption = 'Width:'
    end
    object Label11: TLabel
      Left = 11
      Top = 78
      Width = 35
      Height = 13
      Caption = 'Height:'
    end
    object tbX: TTrackBar
      Left = 61
      Top = 21
      Width = 320
      Height = 16
      Anchors = [akLeft, akTop, akRight]
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
      Top = 40
      Width = 320
      Height = 16
      Anchors = [akLeft, akTop, akRight]
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
      Top = 59
      Width = 320
      Height = 16
      Anchors = [akLeft, akTop, akRight]
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
      Top = 78
      Width = 320
      Height = 16
      Anchors = [akLeft, akTop, akRight]
      Max = 100
      Position = 10
      PositionToolTip = ptTop
      TabOrder = 3
      ThumbLength = 15
      TickMarks = tmBoth
      TickStyle = tsNone
      OnChange = OSDPosChange
    end
    object cbSticky: TCheckBox
      Left = 11
      Top = 100
      Width = 97
      Height = 17
      Caption = 'Sticky text'
      TabOrder = 4
      OnClick = cbStickyClick
    end
  end
  object cbHideOSD: TCheckBox
    Left = 8
    Top = 1
    Width = 97
    Height = 17
    Caption = 'Hide OSD'
    TabOrder = 0
    OnClick = cbHideOSDClick
  end
  object ColorDialog1: TColorDialog
    Left = 168
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial Unicode MS'
    Font.Style = []
    Options = [fdTrueTypeOnly, fdEffects]
    Left = 104
  end
end
