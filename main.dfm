object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = #26377#33050#26412
  ClientHeight = 648
  ClientWidth = 908
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  object Splitter1: TSplitter
    Left = 217
    Top = 0
    Width = 6
    Height = 629
    ExplicitLeft = 200
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 629
    Width = 908
    Height = 19
    Panels = <>
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 217
    Height = 629
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    object scriptList: TListBox
      Left = 0
      Top = 0
      Width = 217
      Height = 629
      Align = alClient
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -14
      Font.Name = #23435#20307
      Font.Style = []
      ItemHeight = 14
      ParentFont = False
      PopupMenu = editMenu
      TabOrder = 0
      OnClick = scriptListClick
    end
  end
  object Panel2: TPanel
    Left = 223
    Top = 0
    Width = 685
    Height = 629
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object Splitter2: TSplitter
      Left = 0
      Top = 442
      Width = 685
      Height = 6
      Cursor = crVSplit
      Align = alBottom
      ExplicitLeft = 100
      ExplicitTop = 474
    end
    object Panel4: TPanel
      Left = 0
      Top = 448
      Width = 685
      Height = 181
      Align = alBottom
      BevelInner = bvLowered
      BevelOuter = bvNone
      TabOrder = 0
      object Panel3: TPanel
        Left = 1
        Top = 139
        Width = 683
        Height = 41
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 0
        DesignSize = (
          683
          41)
        object Button1: TButton
          Left = 600
          Top = 8
          Width = 75
          Height = 25
          Anchors = [akRight, akBottom]
          Caption = #25191#34892
          Font.Charset = GB2312_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #23435#20307
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = Button1Click
        end
      end
      object content_output: TMemo
        Left = 1
        Top = 1
        Width = 683
        Height = 138
        Align = alClient
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
    object paramBox: TScrollBox
      Left = 0
      Top = 0
      Width = 685
      Height = 442
      VertScrollBar.Increment = 42
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      DoubleBuffered = True
      Ctl3D = True
      ParentBackground = True
      ParentCtl3D = False
      ParentDoubleBuffered = False
      TabOrder = 1
    end
  end
  object editMenu: TPopupMenu
    Left = 80
    Top = 216
    object N1: TMenuItem
      Caption = #32534#36753
      OnClick = N1Click
    end
  end
end
