object JSTextProcessorForm: TJSTextProcessorForm
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'JSTextProcessorForm'
  ClientHeight = 259
  ClientWidth = 397
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ScriptArea: TRichEdit
    Left = 0
    Top = 29
    Width = 397
    Height = 230
    Align = alClient
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    Zoom = 100
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 397
    Height = 29
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      397
      29)
    object btnScriptLoad: TButton
      Left = 317
      Top = 2
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Load'
      TabOrder = 0
      OnClick = btnScriptLoadClick
    end
    object mScriptPath: TMemo
      Left = 5
      Top = 5
      Width = 306
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Color = clBtnFace
      Ctl3D = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      Lines.Strings = (
        'mScriptPath')
      ParentCtl3D = False
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
    end
  end
  object JSOpenDialog: TOpenDialog
    Left = 224
    Top = 96
  end
end
