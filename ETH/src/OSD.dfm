object OSDForm: TOSDForm
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'ETH OSD'
  ClientHeight = 64
  ClientWidth = 64
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -19
  Font.Name = 'Arial Unicode MS'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 25
  object UpdateTimer: TTimer
    Interval = 200
    OnTimer = UpdateTimerTimer
    Left = 16
    Top = 16
  end
end
