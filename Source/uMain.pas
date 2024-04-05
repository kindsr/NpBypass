unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, System.SyncObjs, uGlobal,
  ScktComp, System.Generics.Collections, StrUtils, Vcl.AppEvnts, Vcl.Menus;


type
  TMain = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnLPRServer: TButton;
    btnSetting: TButton;
    btnTCPServer: TButton;
    mLogLPRServer: TMemo;
    mLogTCPServer: TMemo;
    pnlStatus: TPanel;
    Label1: TLabel;
    lblConnected: TLabel;
    btnClear: TButton;
    TrayIcon1: TTrayIcon;
    ApplicationEvents1: TApplicationEvents;
    PopupMenu1: TPopupMenu;
    pmExit: TMenuItem;
    Timer1: TTimer;
    procedure btnSettingClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnLPRServerClick(Sender: TObject);
    procedure btnTCPServerClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ApplicationEvents1Minimize(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure pmExitClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    procedure csLprServer_Connect(Sender: TObject; Socket: TCustomWinSocket);
    procedure csLprServer_Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure csLprServer_Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure ssTcpServer_ClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ssTcpServer_ClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ssTcpServer_ClientError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure ssTcpServer_ClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    function CheckSalesCar(aCarNumber: string): Boolean;
    function CheckEmergencyCar(aCarNumbar: string): Boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Main: TMain;
  LPRServerQueue: TQueue<string>;
  csLprServer: TClientSocket;
  ssTcpServer: TServerSocket;
  iConnectedClients: Integer;
  sNowCarNo: aString;
  bStartFlag: Boolean = False;

implementation

uses uConfig;

{$R *.dfm}

procedure TMain.btnSettingClick(Sender: TObject);
begin
  NextModalDialog(TConfig.Create(Self));
end;

procedure TMain.btnTCPServerClick(Sender: TObject);
begin
  if TButton(Sender).Tag = 0 then
  begin
    try
      ssTcpServer.Open;
      TButton(Sender).Tag := 1;
      TButton(Sender).Caption := 'TCP Server Close';
    except
      on E: Exception do
      begin
        lblConnected.Caption := '0';
        TButton(Sender).Tag := 0;
        TButton(Sender).Caption := 'TCP Server Open';
      end;
    end;
  end
  else
  begin
    if ssTcpServer.Active then
    begin
      ssTcpServer.Close;
      lblConnected.Caption := '0';
      TButton(Sender).Tag := 0;
      TButton(Sender).Caption := 'TCP Server Open';
    end;
  end;
end;

procedure TMain.ApplicationEvents1Minimize(Sender: TObject);
begin
  { Hide the window and set its state variable to wsMinimized. }
  Hide();
  WindowState := wsMinimized;

  { Show the animated tray icon and also a hint balloon. }
  TrayIcon1.Visible := True;
  TrayIcon1.Animate := True;
//  TrayIcon1.ShowBalloonHint;
end;

procedure TMain.btnClearClick(Sender: TObject);
begin
  mLogLPRServer.Lines.Clear;
  mLogTCPServer.Lines.Clear;
end;

procedure TMain.btnLPRServerClick(Sender: TObject);
var
  i: Integer;
  list : TList;
begin
  if TButton(Sender).Tag = 0 then
  begin
    try
      csLprServer.Open;
      TButton(Sender).Tag := 1;
      TButton(Sender).Caption := 'LPR Server Disconnect';
    except
      on E: Exception do
      begin
        TButton(Sender).Tag := 0;
        TButton(Sender).Caption := 'LPR Server Connect';
      end;
    end;
  end
  else
  begin
    if csLprServer.Active then
    begin
      csLprServer.Close;
      TButton(Sender).Tag := 0;
      TButton(Sender).Caption := 'LPR Server Connect';
    end;
  end;
end;

procedure TMain.FormCreate(Sender: TObject);
begin
  try
    // Load Config
    with TConfig.Create(Self) do
      LoadConfig(ExtractFilePath(Application.ExeName) + ChangeFileExt(ExtractFileName(Application.ExeName), '.ini'));

    sCurrRunDir := aString(ExtractFileDir(Application.ExeName));

    if not DirectoryExists('Log') then
      MkDir('Log');

    // Client
    csLprServer := TClientSocket.Create(Self);
    with csLprServer do
    begin
      ClientType := ctNonBlocking;
      Host := ConfigInfo.LPR_HostIP;
      Port := ConfigInfo.LPR_HostPort;

      OnConnect := csLprServer_Connect;
      OnError   := csLprServer_Error;
      OnRead := csLprServer_Read;
    end;

    // Server
    ssTcpServer := TServerSocket.Create(Self);
    with ssTcpServer do
    begin
      ServerType := stNonBlocking;
      Port := ConfigInfo.TCPServerPort;

      OnClientConnect := ssTcpServer_ClientConnect;
      OnClientDisconnect := ssTcpServer_ClientDisconnect;
      OnClientError := ssTcpServer_ClientError;
      OnClientRead := ssTcpServer_ClientRead;
    end;

    mLogLPRServer.Lines.Clear;
    mLogTCPServer.Lines.Clear;

    iConnectedClients := 0;
  except
    on E: Exception do
    begin
      Assert(false, E.ClassName + ' ' + E.Message);
      ExceptLogging('TfrmMain.FormCreate: ' + aString(E.Message));
    end;
  end;
end;

procedure TMain.FormResize(Sender: TObject);
begin
  mLogLPRServer.Width := ClientWidth div 2;
end;

procedure TMain.FormShow(Sender: TObject);
begin
  if not bStartFlag then
  begin
    btnLPRServer.Click;
    btnTCPServer.Click;
    bStartFlag := not bStartFlag;
  end;
end;

procedure TMain.pmExitClick(Sender: TObject);
begin
  Close();
end;

procedure TMain.csLprServer_Connect(Sender: TObject; Socket: TCustomWinSocket);
begin
  csLprServer.Open;
  ExceptLogging(TClientSocket(Sender).Name + ' 접속성공');
end;

procedure TMain.csLprServer_Error(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  csLprServer.Close;
  btnLPRServer.Tag := 0;
  btnLPRServer.Caption := 'LPR Server Connect';
  ExceptLogging((TClientSocket(Sender).Host) + ':' + IntToStr(TClientSocket(Sender).Port) + ' 소켓 연결끊김 = ' + IntToStr(ErrorCode));
  (Sender as TClientSocket).Socket.Disconnect((Sender as TClientSocket).Socket.SocketHandle);
  ErrorCode := 0;
end;

procedure TMain.csLprServer_Read(Sender: TObject; Socket: TCustomWinSocket);
var
  sRecv: aString;
  i: Integer;
  sTemp: string;
begin
  sRecv := Socket.ReceiveText;

  if string.IsNullOrEmpty(sRecv) then Exit;

  if mLogLPRServer.Lines.Count > 300 then mLogLPRServer.Lines.Clear;
  mLogLPRServer.Lines.Add(sRecv);

  // 여기서 연결된 클라이언트로 send
  if (ssTcpServer.Active) and (ssTcpServer.Socket.ActiveConnections > 0) then
  begin
    for i := 0 to ssTcpServer.Socket.ActiveConnections - 1 do
    begin
      ssTcpServer.Socket.Connections[i].SendText(sRecv);
    end;
  end;

  sRecv := StringReplace(sRecv, 'LPR_N', '', [rfReplaceAll, rfIgnoreCase]);
  if string.IsNullOrEmpty(sRecv) then Exit;

  // 영업차량 Bypass (ReceiveText Parse)
  sTemp := Copy(sRecv, Pos('#', sRecv) + 1, Length(sRecv) - Pos('#', sRecv));

  // 차량번호 추출
  sNowCarNo := Copy(sTemp, 1, Pos('#', sTemp) - 1);

  // Check SalesCar or EmergencyCar and Bar open
  if not string.IsNullOrEmpty(sNowCarNo) then
  begin
    if CheckSalesCar(sNowCarNo) or CheckEmergencyCar(sNowCarNo) then
    begin
      if csLprServer.Active then
      begin
        csLprServer.Socket.SendText(aString(MSG_BAR_OPEN));
        ExceptLogging('입구차단기 Open ' + csLprServer.Host + ':' + IntToStr(csLprServer.Port) + ' / '
                     + IfThen(CheckSalesCar(sNowCarNo), '영업', '긴급') + '차량: ' + sNowCarNo);
      end;
    end;
  end;
end;

procedure TMain.ssTcpServer_ClientConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  ExceptLogging('ssTcpServer_ClientConnect : Connect');
  ExceptLogging('ssTcpServer_ClientConnect : ' + Socket.RemoteAddress + ' , ' + IntToStr(Socket.RemotePort) + '접속');
  iConnectedClients := iConnectedClients + 1;
  lblConnected.Caption := IntToStr(iConnectedClients);
end;

procedure TMain.ssTcpServer_ClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  ExceptLogging('ssTcpServer_ClientDisconnect : DisConnect');
  ExceptLogging('ssTcpServer_ClientDisconnect : ' + Socket.RemoteAddress + ' , ' + IntToStr(Socket.RemotePort) + '종료');
  if iConnectedClients > 0 then
  begin
    iConnectedClients := iConnectedClients - 1;
    lblConnected.Caption := IntToStr(iConnectedClients);
  end;
end;

procedure TMain.ssTcpServer_ClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ExceptLogging('ssHomeinfo_iconClientError : 에러코드 : [' + IntToStr(ErrorCode) + ']');
  ErrorCode := 0;
end;

procedure TMain.ssTcpServer_ClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
  sRecvText, sSend: AnsiString;
begin
  ExceptLogging('tssServerMainClientRead : ' + Socket.RemoteAddress + ' , ' + IntToStr(Socket.RemotePort) + '로 부터 요청전문 수신');
  sRecvText := Socket.ReceiveText;
  ExceptLogging('요청전문 : [' + sRecvText + ']');
  if Pos('jpg', sRecvText) > 0 then
    Exit;

  // LPRServer 로 전달
  if mLogTCPServer.Lines.Count > 300 then mLogTCPServer.Lines.Clear;
  mLogTCPServer.Lines.Add(sRecvText);

  if csLprServer.Active then
  begin
    csLprServer.Socket.SendText(sRecvText);
  end;
end;

procedure TMain.Timer1Timer(Sender: TObject);
begin
  if (not csLprServer.Active) and (TButton(btnLPRServer).Tag = 0) then
  begin
    try
      csLprServer.Open;
      TButton(btnLPRServer).Tag := 1;
      TButton(btnLPRServer).Caption := 'LPR Server Disconnect';
    except
      on E: Exception do
      begin
        TButton(btnLPRServer).Tag := 0;
        TButton(btnLPRServer).Caption := 'LPR Server Connect';
      end;
    end;
  end;

  if (not ssTcpServer.Active) and (TButton(btnTCPServer).Tag = 0) then
  begin
    try
      ssTcpServer.Open;
      TButton(btnTCPServer).Tag := 1;
      TButton(btnTCPServer).Caption := 'TCP Server Close';
    except
      on E: Exception do
      begin
        lblConnected.Caption := '0';
        TButton(btnTCPServer).Tag := 0;
        TButton(btnTCPServer).Caption := 'TCP Server Open';
      end;
    end;
  end
end;

procedure TMain.TrayIcon1DblClick(Sender: TObject);
begin
  { Hide the tray icon and show the window,
  setting its state property to wsNormal. }
  TrayIcon1.Visible := False;
  Show();
  WindowState := wsNormal;
  Application.BringToFront();
end;

function TMain.CheckSalesCar(aCarNumber: string): Boolean;
var
  slSalesCar: TStringList;
  i: Integer;
  c: Char;
begin
  Result := False;

  // 맨앞자리 숫자면 영업차량이 아님
  if (aCarNumber[1] in ['0'..'9']) then Exit;
  if string.IsNullOrEmpty(ConfigInfo.SalesCarNumber) then Exit;

  slSalesCar := TStringList.Create;
  try
    slSalesCar.Delimiter := ',';
    slSalesCar.DelimitedText := ConfigInfo.SalesCarNumber;

    for i := 0 to slSalesCar.Count-1 do
    begin
      if Pos(slSalesCar[i], sNowCarNo) > 0 then
      begin
        Result := True;
        Break;
      end;
    end;

  finally
    slSalesCar.Free;
    slSalesCar := nil;
  end;

end;

function TMain.CheckEmergencyCar(aCarNumbar: string): Boolean;
var
  slEmergencyCar: TStringList;
  i: Integer;
  nEmergencySalesCarPass: Integer;
begin
  Result := False;

  if string.IsNullOrEmpty(ConfigInfo.EmergencyNumber) then Exit;

  slEmergencyCar := TStringList.Create;
  try
    slEmergencyCar.Delimiter := ',';
    slEmergencyCar.DelimitedText := ConfigInfo.EmergencyNumber;

    if not TryStrToInt(Copy(sNowCarNo,1,4), nEmergencySalesCarPass) then
    begin
      for i := 0 to slEmergencyCar.Count-1 do
      begin
        if Pos(slEmergencyCar[i], Copy(sNowCarNo,1,3)) > 0 then
        begin
          Result := True;
          Break;
        end;
      end;
    end;

  finally
    slEmergencyCar.Free;
    slEmergencyCar := nil;
  end;
end;



end.
