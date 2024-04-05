object Config: TConfig
  Left = 0
  Top = 0
  Caption = 'Nexpa Bypass Config'
  ClientHeight = 312
  ClientWidth = 321
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  Font.Quality = fqDraft
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object GroupBox1: TGroupBox
    Left = 0
    Top = 80
    Width = 321
    Height = 129
    Align = alTop
    Caption = #49436#48260#49464#54021
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 29
      Width = 113
      Height = 25
      AutoSize = False
      Caption = 'LPR Host IP'
    end
    object Label2: TLabel
      Left = 16
      Top = 60
      Width = 113
      Height = 25
      AutoSize = False
      Caption = 'LPR Host Port'
    end
    object Label3: TLabel
      Left = 16
      Top = 91
      Width = 113
      Height = 25
      AutoSize = False
      Caption = 'TCP Server Port'
    end
    object Label4: TLabel
      Left = 16
      Top = 122
      Width = 113
      Height = 25
      AutoSize = False
      Caption = 'Retry Period'
      Visible = False
    end
    object Label5: TLabel
      Left = 16
      Top = 153
      Width = 113
      Height = 25
      AutoSize = False
      Caption = 'Heartbeat Period'
      Visible = False
    end
    object edtLPRHostIP: TEdit
      Left = 160
      Top = 29
      Width = 141
      Height = 25
      TabOrder = 0
    end
    object edtLPRHostPort: TEdit
      Left = 160
      Top = 60
      Width = 141
      Height = 25
      TabOrder = 1
    end
    object edtTCPServerPort: TEdit
      Left = 160
      Top = 91
      Width = 141
      Height = 25
      TabOrder = 2
    end
    object edtRetryPeriod: TEdit
      Left = 160
      Top = 122
      Width = 141
      Height = 25
      TabOrder = 3
      Visible = False
    end
    object edtHeartbeatPeriod: TEdit
      Left = 160
      Top = 153
      Width = 141
      Height = 25
      TabOrder = 4
      Visible = False
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 321
    Height = 80
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    object btnClose: TButton
      Left = 246
      Top = 0
      Width = 75
      Height = 80
      Align = alRight
      Caption = 'Close'
      TabOrder = 0
      OnClick = btnCloseClick
    end
    object btnSave: TButton
      Left = 171
      Top = 0
      Width = 75
      Height = 80
      Align = alRight
      Caption = 'Save'
      TabOrder = 1
      OnClick = btnSaveClick
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 209
    Width = 321
    Height = 103
    Align = alClient
    Caption = #50868#50689#49464#54021
    TabOrder = 2
    ExplicitTop = 273
    ExplicitHeight = 80
    object Label6: TLabel
      Left = 16
      Top = 29
      Width = 113
      Height = 25
      AutoSize = False
      Caption = #50689#50629#52264#47049#44277#53685#48264#54840
    end
    object Label7: TLabel
      Left = 16
      Top = 60
      Width = 113
      Height = 25
      AutoSize = False
      Caption = #44596#44553#52264#47049#48264#54840
    end
    object edtSalesCarNumber: TEdit
      Left = 160
      Top = 29
      Width = 141
      Height = 25
      TabOrder = 0
    end
    object edtEmergencyNumber: TEdit
      Left = 160
      Top = 60
      Width = 141
      Height = 25
      TabOrder = 1
    end
  end
end
