object frm_toICE: Tfrm_toICE
  Left = 0
  Top = 0
  Caption = 'frm_toICE'
  ClientHeight = 100
  ClientWidth = 426
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object TreeWindows: TTreeView
    Left = 2
    Top = 0
    Width = 289
    Height = 31
    HideSelection = False
    Indent = 19
    ReadOnly = True
    TabOrder = 0
  end
  object ListParams: TListView
    Left = 2
    Top = 37
    Width = 289
    Height = 54
    Columns = <
      item
        Caption = #1055#1072#1088#1072#1084#1077#1090#1088
        Width = 190
      end
      item
        Caption = #1047#1085#1072#1095#1077#1085#1080#1077
        Width = 400
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
  end
end
