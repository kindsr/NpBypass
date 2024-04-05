unit uConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.IniFiles, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TConfigRec = packed record
    LPR_HostIP: string;
    LPR_HostPort: Integer;
    TCPServerPort: Integer;
    RetryPeriod: Integer;
    HeartbeatPeriod: Integer;
    SalesCarNumber: string;
    EmergencyNumber: string;
  end;

type
  TConfig = class(TForm)
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    btnClose: TButton;
    btnSave: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    edtLPRHostIP: TEdit;
    edtLPRHostPort: TEdit;
    edtTCPServerPort: TEdit;
    edtRetryPeriod: TEdit;
    edtHeartbeatPeriod: TEdit;
    GroupBox2: TGroupBox;
    Label6: TLabel;
    edtSalesCarNumber: TEdit;
    Label7: TLabel;
    edtEmergencyNumber: TEdit;
    procedure FormShow(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure LoadConfig(AFileName: string);
    procedure SaveConfig(AFileName: string);
    { Public declarations }
  end;

var
  Config: TConfig;
  ConfigInfo: TConfigRec;

implementation

{$R *.dfm}

{ TMain }

procedure TConfig.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TConfig.btnSaveClick(Sender: TObject);
begin

  with ConfigInfo do
  begin
    LPR_HostIP       := edtLPRHostIP.Text;
    LPR_HostPort     := StrToInt(edtLPRHostPort.Text);
    TCPServerPort    := StrToInt(edtTCPServerPort.Text);
    RetryPeriod      := StrToInt(edtRetryPeriod.Text);
    HeartbeatPeriod  := StrToInt(edtHeartbeatPeriod.Text);
    SalesCarNumber   := edtSalesCarNumber.Text;
    EmergencyNumber  := edtEmergencyNumber.Text;
  end;

  SaveConfig(ExtractFilePath(Application.ExeName) + ChangeFileExt(ExtractFileName(Application.ExeName), '.ini'));
end;

procedure TConfig.FormShow(Sender: TObject);
begin
  LoadConfig(ExtractFilePath(Application.ExeName) + ChangeFileExt(ExtractFileName(Application.ExeName), '.ini'));

  with ConfigInfo do
  begin
    edtLPRHostIP.Text := LPR_HostIP;
    edtLPRHostPort.Text := IntToStr(LPR_HostPort);
    edtTCPServerPort.Text := IntToStr(TCPServerPort);
    edtRetryPeriod.Text := IntToStr(RetryPeriod);
    edtHeartbeatPeriod.Text := IntToStr(HeartbeatPeriod);
    edtSalesCarNumber.Text := SalesCarNumber;
    edtEmergencyNumber.Text := EmergencyNumber;
  end;
end;

procedure TConfig.LoadConfig(AFileName: string);
var
  iniFile: TIniFile;
begin
  if not FileExists(AFileName) then Exit;

  iniFile := TIniFile.Create(AFileName);

  try
    ConfigInfo.LPR_HostIP       := iniFile.ReadString('GW', 'LPR_HOSTIP', '127.0.0.1');
    ConfigInfo.LPR_HostPort     := iniFile.ReadInteger('GW', 'LPR_HOSTPORT', 2000);
    ConfigInfo.TCPServerPort    := iniFile.ReadInteger('GW', 'TCPSERVERPORT', 2200);
    ConfigInfo.RetryPeriod      := iniFile.ReadInteger('GW', 'RETRY', 5000);
    ConfigInfo.HeartbeatPeriod  := iniFile.ReadInteger('GW', 'HBEAT', 10000);
    ConfigInfo.SalesCarNumber   := iniFile.ReadString('GW', 'SALESCARNUMBER', '아,바,사,자,배');
    ConfigInfo.EmergencyNumber  := iniFile.ReadString('GW', 'EMERGENCYNUMBER', '998,999');
  finally
    iniFile.Free;
  end;
end;

procedure TConfig.SaveConfig(AFileName: string);
var
  iniFile: TIniFile;
begin
  if not FileExists(AFileName) then Exit;

  iniFile := TIniFile.Create(AFileName);

  try
    iniFile.WriteString('GW', 'LPR_HOSTIP', ConfigInfo.LPR_HostIP);
    iniFile.WriteInteger('GW', 'LPR_HOSTPORT', ConfigInfo.LPR_HostPort);
    iniFile.WriteInteger('GW', 'TCPSERVERPORT', ConfigInfo.TCPServerPort);
    iniFile.WriteInteger('GW', 'RETRY', ConfigInfo.RetryPeriod);
    iniFile.WriteInteger('GW', 'HBEAT', ConfigInfo.HeartbeatPeriod);
    iniFile.WriteString('GW', 'SALESCARNUMBER', ConfigInfo.SalesCarNumber);
    iniFile.WriteString('GW', 'EMERGENCYNUMBER', ConfigInfo.EmergencyNumber);
  finally
    iniFile.Free;
  end;
end;

end.
