@ECHO OFF

chcp 65001

rem Get the datetime in a format that can go in a filename.
For /f "tokens=1-3 delims=/- " %%a in ('date /t') do (set mydate=%%a%%b%%c)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
rem echo %mydate%%mytime%

SET THEDIR="D:\100_Development\Nexpa.Bypass\Bin"
SET TARGET_FOLDER="\\10.31.3.14\FTP_Data\로컬유인\# 배포버전\Nexpa.Bypass\"

IF EXIST %TARGET_FOLDER%\Nexpa_Bypass.exe (
  IF NOT EXIST %TARGET_FOLDER%\Old\NUL (
    MD %TARGET_FOLDER%\Old
  ) 
  Copy %TARGET_FOLDER%\Nexpa_Bypass.exe %TARGET_FOLDER%\Old\Nexpa_Bypass_%mydate%%mytime%.exe
)

@Echo Copy Nexpa_Bypass.exe from %THEDIR% to %TARGET_FOLDER%
REM Copy %THEDIR%\Nexpa_Bypass.exe %TARGET_FOLDER%

@ECHO Finished copying Nexpa_Host.exe file.

SET THEDIR="D:\100_Development\Nexpa.Bypass"
@Echo Copy ReleaseNote from %THEDIR% to %TARGET_FOLDER%
REM Copy %THEDIR%\ReleaseNote_Nexpa.Bypass.txt %TARGET_FOLDER%

@ECHO Finished copying ReleaseNote file.