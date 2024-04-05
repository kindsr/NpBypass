unit uQueueThread;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SyncObjs, StdCtrls, ExtCtrls;

Type
  TQueueThread = class(TThread)
  private
    FGuardian: TCriticalSection;
    Flist: TStringList;
  protected
    procedure Execute; override;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Lock: TStringList;
    procedure UnLock;
    procedure Push(const S: String);
    function Pop: String;
    function IsEmpty: Boolean;
    procedure ClearAll;
  end;

implementation

{ TQueueThread }

procedure TQueueThread.ClearAll;
begin
  Lock;
  try
    FList.Clear;
  finally
    UnLock;
  end;
end;

constructor TQueueThread.Create;
begin
  inherited Create(True);
  FGuardian:= TCriticalSection.Create;
  FLIst:= TStringList.Create;
end;

destructor TQueueThread.Destroy;
begin
  FList.Free;
  FGuardian.Free;
  inherited;
end;

procedure TQueueThread.Execute;
begin
  inherited;
//  while not Terminated do
//  begin
//    while not IsEmpty do
//    begin
//      // Queue에 쌓여있는 자료가 있다면 처리
//      Application.ProcessMessages;
//    end;
//
//    Sleep(1000);
//
//    if not Terminated Then
//      Suspend; // pthread_cond_wait()
//  end;
end;

function TQueueThread.IsEmpty: Boolean;
begin
  Lock;
  try
    Result := FList.Count = 0;
  finally
    Unlock
  end;
end;

function TQueueThread.Lock: TStringList;
begin
  FGuardian.Acquire; // pthread_mutex_lock()
  Result := Flist;
end;

function TQueueThread.Pop: String;
begin
  Lock;
  try
    if Flist.Count > 0 then
    begin
      Result := FList[0];
      FList.Delete(0);
    end
    else
      Result := EmptyStr;
  finally
    Unlock;
  end;
end;

procedure TQueueThread.Push(const S: String);
begin
  Lock;
  try
    FList.Add(S);
    if Suspended then
      Resume;
  finally
    UnLock;
  end;
end;

procedure TQueueThread.UnLock;
begin
  FGuardian.Release; // pthread_mutex_unlock()
end;

end.
