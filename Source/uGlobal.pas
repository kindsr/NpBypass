unit uGlobal;

interface

uses
  Forms, Vcl.Controls, System.Classes, System.SysUtils;

const
  MSG_BAR_OPEN = 'BAR_OPEN_1';

type
  aString = AnsiString;
  wString = WideString;

type
  TLPRRec = record
    myConLprNo: string;
    imgFile: string;
    carNo: string;
    cTime: string;
    nRecogFlag: string;
    lprName: string;
    myCompName: string;
  end;

var
  sCurrRunDir: aString;

function GetNow() : String;
procedure NormalLogging(sMsg: aString);
procedure ExceptLogging(sMsg: aString; isStartEnd: boolean=False);
function NextModalDialog(Sender: TForm): Integer;
procedure ClearComponent(AComponent: TComponent);

implementation

uses
  DateUtils;


function GetNow() : String;
begin
    Result := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ': ';
end;

procedure NormalLogging(sMsg: aString);
var
  nFile: Integer;
  sFile: aString;
begin
   sFile := sCurrRunDir + '\Non_Reg\' + aString(FormatDateTime('YYMMDD', Now)) + '_Non_Reg.log';

   if FileExists(wString(sFile)) then
   begin
      nFile := FileOpen(wString(sFile), fmOpenWrite);
      FileSeek(nFile, 0, 2);
   end
   else
   begin
      nFile := FileCreate(wString(sFile));
   end;

   if nFile <> -1 then
   begin
      sFile := '[' + aString(FormatDateTime('hh:nn:ss', Now)) + '] ' + sMsg + #13 + #10;
      FileWrite(nFile, PAnsichar(sFile)^, Length(sFile));
      FileClose(nFile);
   end;
end;

procedure ExceptLogging(sMsg: aString; isStartEnd: boolean=False);
var
  nFile: Integer;
  sFile: aString;
begin
    sFile := sCurrRunDir + '\Log\' + aString(FormatDateTime('YYMMDD', Now)) + '.log';

   if FileExists(wString(sFile)) then
   begin
      nFile := FileOpen(wString(sFile), fmOpenWrite);
      FileSeek(nFile, 0, 2);
   end
   else
   begin
      nFile := FileCreate(wString(sFile));
   end;

   if nFile <> -1 then
   begin
      if isStartEnd = True then
        sFile := '**************************************************************' + #13#10 + '[' + aString(FormatDateTime('hh:nn:ss', Now)) + '] ' + sMsg + #13 + #10
      else
        sFile := '[' + aString(FormatDateTime('hh:nn:ss', Now)) + '] ' + sMsg + #13 + #10;
      FileWrite(nFile, PAnsichar(sFile)^, Length(sFile));
      FileClose(nFile);
   end;
end;

function NextModalDialog(Sender: TForm): Integer;
begin
  try
    with Sender do
    begin
      ShowModal;
      Result:= ModalResult;
      Free;
    end;
  except
    on E: Exception do
    begin
      ExceptLogging('NextModalDialog: ' + aString(E.Message));
      Result:= 0;
    end;
  end;
end;

procedure ClearComponent(AComponent: TComponent);
begin

end;

end.
