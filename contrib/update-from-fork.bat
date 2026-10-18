@echo off
rem Updates ReSkate.dll and ReSkateLauncher.exe in a game folder from this fork's "latest" build.
rem Usage: update-from-fork.bat [GAME_FOLDER]   (the folder that has Skate.exe)
rem The folder is remembered, in reskate-update.conf beside this file, after the first run.
setlocal
set "REPO=@REPO@"
set "CONF=%~dp0reskate-update.conf"
set "DIR=%~1"
if "%DIR%"=="" if exist "%CONF%" set /p DIR=<"%CONF%"
if "%DIR%"=="" if exist "%~dp0Skate.exe" set "DIR=%~dp0"
if "%DIR%"=="" (
    echo Usage: %~nx0 GAME_FOLDER   ^(the folder that has Skate.exe^)
    exit /b 1
)
if not exist "%DIR%\Skate.exe" (
    echo No Skate.exe in %DIR%
    exit /b 1
)

set "TMPDIR=%TEMP%\reskate-update"
rmdir /s /q "%TMPDIR%" 2>nul
mkdir "%TMPDIR%" || exit /b 1

for %%F in (ReSkateLauncher.exe ReSkate.dll) do (
    echo Downloading %%F
    set "URL=https://github.com/%REPO%/releases/download/latest/%%F"
    call :download "%%F" || (echo Download of %%F failed & rmdir /s /q "%TMPDIR%" & exit /b 1)
)
for %%F in (ReSkateLauncher.exe ReSkate.dll) do (
    if exist "%DIR%\%%F" copy /y "%DIR%\%%F" "%DIR%\%%F.bak" >nul
    move /y "%TMPDIR%\%%F" "%DIR%\%%F" >nul
)
> "%CONF%" echo %DIR%
rmdir /s /q "%TMPDIR%"
echo Updated %DIR% ^(the old files are kept as .bak^)
exit /b 0

:download
where curl.exe >nul 2>&1
if %errorlevel%==0 (
    curl.exe -fL --silent --show-error -o "%TMPDIR%\%~1" "%URL%"
) else (
    powershell -NoProfile -Command "Invoke-WebRequest -UseBasicParsing -Uri '%URL%' -OutFile '%TMPDIR%\%~1'"
)
exit /b %errorlevel%
