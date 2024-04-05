program Nexpa_Bypass;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Main},
  uConfig in 'uConfig.pas' {Config},
  uGlobal in 'uGlobal.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
