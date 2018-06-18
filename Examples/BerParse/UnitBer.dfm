object FormParseBer: TFormParseBer
  Left = 116
  Top = 153
  Width = 652
  Height = 463
  Caption = 'BER Format Reader & Writer'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lblBin: TLabel
    Left = 8
    Top = 24
    Width = 77
    Height = 13
    Caption = 'Binary PEM File:'
  end
  object mmoResult: TMemo
    Left = 8
    Top = 64
    Width = 249
    Height = 313
    ReadOnly = True
    TabOrder = 0
  end
  object btnParse: TButton
    Left = 552
    Top = 20
    Width = 75
    Height = 21
    Caption = 'Parse'
    TabOrder = 1
    OnClick = btnParseClick
  end
  object tv1: TTreeView
    Left = 264
    Top = 64
    Width = 361
    Height = 313
    Indent = 19
    TabOrder = 2
    OnDblClick = tv1DblClick
  end
  object edtFile: TEdit
    Left = 96
    Top = 20
    Width = 305
    Height = 21
    TabOrder = 3
  end
  object btnBrowse: TButton
    Left = 424
    Top = 20
    Width = 75
    Height = 21
    Caption = 'Browse'
    TabOrder = 4
    OnClick = btnBrowseClick
  end
  object btnWrite: TButton
    Left = 264
    Top = 392
    Width = 75
    Height = 25
    Caption = 'Write'
    TabOrder = 5
    OnClick = btnWriteClick
  end
  object dlgOpen: TOpenDialog
    Left = 336
    Top = 16
  end
  object dlgSave: TSaveDialog
    Left = 360
    Top = 392
  end
end