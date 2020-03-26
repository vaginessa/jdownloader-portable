@echo off
cd /D "%~dp0\.."

:: Wait for a stable internet connection
echo Waiting for a stable internet connection...
goto internet
:nointernet
echo Connection unstable. Retrying...
ping 127.0.0.1 -n 61 >nul
:internet
ping google-public-dns-a.google.com >nul
if /I %errorlevel% NEQ 0 goto nointernet
echo Connection is stable.

:: Configuring Git
echo.
echo Configuring Git...
git config core.autocrlf false
git config core.ignorecase false
git config core.fscache true
git config core.longpaths true
git config diff.renameLimit 0
git config status.renameLimit 0
git config merge.renameLimit 0
git config http.postBuffer 1048576000
git config pack.threads 1
git config index.threads 0

:: Fetch GitHub
echo.
echo Synchronizing with GitHub...
git fetch --all

:: Reset repo
echo.
echo Resetting folders...
git reset --hard origin/master
git clean -dffx
git reset --hard origin/master
git clean -dffx

:: Get current JDownloader version
echo.
echo Reading JDownloader version...
set /p oldversion=<App\JDownloader\update\versioninfo\JD\rev
echo Current version: %oldversion%

:: Settings
echo.
echo Applying settings...
mkdir App\JDownloader\cfg >nul
ping 127.0.0.1 -n 2 >nul
echo {>App\JDownloader\cfg\org.jdownloader.gui.jdtrayicon.TrayExtension.json
echo   "oncloseaction" : "EXIT">>App\JDownloader\cfg\org.jdownloader.gui.jdtrayicon.TrayExtension.json
echo }>>App\JDownloader\cfg\org.jdownloader.gui.jdtrayicon.TrayExtension.json
ping 127.0.0.1 -n 2 >nul

:: Start JDownloader
echo.
echo Starting JDownloader...
start "" JDownloaderPortable.exe

:: Wait for updates to finish
echo.
echo Waiting for updates to finish downloading...
ping 127.0.0.1 -n 61 >nul

:: Politely ask the process to stop
echo.
echo Closing JDownloader...
PowerShell.exe Get-Process javaw ^| Where-Object {$_.MainWindowTitle -like '*JDownloader*'} ^| Foreach-Object { $_.CloseMainWindow() ^| Out-Null }

:: Wait for any updates after the fact
echo.
echo Waiting for any leftover updates to finish...
ping 127.0.0.1 -n 61 >nul

:: Make sure it's actually closed now.
taskkill /im javaw.exe
ping 127.0.0.1 -n 11 >nul
taskkill /f /im javaw.exe
ping 127.0.0.1 -n 61 >nul

:: Second pass
:: Settings
echo.
echo Applying settings...
echo {>App\JDownloader\cfg\org.jdownloader.gui.jdtrayicon.TrayExtension.json
echo   "oncloseaction" : "EXIT">>App\JDownloader\cfg\org.jdownloader.gui.jdtrayicon.TrayExtension.json
echo }>>App\JDownloader\cfg\org.jdownloader.gui.jdtrayicon.TrayExtension.json
ping 127.0.0.1 -n 2 >nul

:: Start JDownloader
echo.
echo Starting JDownloader...
start "" JDownloaderPortable.exe

:: Wait for updates to finish
echo.
echo Waiting for updates to finish downloading...
ping 127.0.0.1 -n 61 >nul

:: Politely ask the process to stop
echo.
echo Closing JDownloader...
PowerShell.exe Get-Process javaw ^| Where-Object {$_.MainWindowTitle -like '*JDownloader*'} ^| Foreach-Object { $_.CloseMainWindow() ^| Out-Null }

:: Wait for any updates after the fact
echo.
echo Waiting for any leftover updates to finish...
ping 127.0.0.1 -n 61 >nul

:: Make sure it's actually closed now.
taskkill /im javaw.exe
ping 127.0.0.1 -n 11 >nul
taskkill /f /im javaw.exe
ping 127.0.0.1 -n 61 >nul

:: What version is JDownloader now
echo.
echo Re-reading JDownloader version...
set /p version=<App\JDownloader\update\versioninfo\JD\rev
echo Previous version: %oldversion%
echo New version: %version%

:: Store updates
echo.
echo Storing updates...
git add .
if "%version%" == "%oldversion%" goto norevision
git commit -m "Update JDownloader to revision %version%"
goto revision
:norevision
git commit -m "Update JDownloader"
:revision

:: Push updates
echo.
echo Pushing updates...
git push

:: Tag update
echo.
echo Tagging updates...
git tag "%version%"

:: Push tags
echo.
echo Pushing tags..
git push --tags

:: Clean repo
echo.
echo Cleaning up...
git reset --hard origin/master
git clean -dffx
git reset --hard origin/master
git clean -dffx

:: Close
echo.
echo Done...
exit
