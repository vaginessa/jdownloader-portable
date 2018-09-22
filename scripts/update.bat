@echo off
cd /D "%~dp0\.."

:: Wait for a stable internet connection
echo Waiting for a stable internet connection...
goto internet
:nointernet
echo Connection unstable. Retrying...
ping 127.0.0.1 -n 21 >nul
:internet
ping google-public-dns-a.google.com >nul
if /I %errorlevel% NEQ 0 goto nointernet
echo Connection is stable.

:: Configuring Git
echo.
echo Configuring Git...
git config --global core.autocrlf false
git config core.autocrlf false
git config diff.renameLimit 0
git config merge.renameLimit 0

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
git submodule update --init --recursive

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
copy scripts\org.jdownloader.gui.jdtrayicon.TrayExtension.json App\JDownloader\cfg\org.jdownloader.gui.jdtrayicon.TrayExtension.json
ping 127.0.0.1 -n 2 >nul

:: Start JDownloader
echo.
echo Starting JDownloader...
start "" JDownloaderPortable.exe

:: Wait for updates to finish
echo.
echo Waiting for updates to finish downloading...
ping 127.0.0.1 -n 121 >nul

:: Stop the process
:: The $_.Path variable is probably null so we use $_.MainWindowTitle to
:: determine the correct process instead.
echo.
echo Closing JDownloader...
PowerShell.exe Get-Process javaw ^| Where-Object {$_.MainWindowTitle -like '*JDownloader*'} ^| Foreach-Object { $_.CloseMainWindow() ^| Out-Null }

:: Wait for any updates after the fact
echo.
echo Waiting for any leftover updates to finish...
ping 127.0.0.1 -n 61 >nul

:: What version is JDownloader now
echo.
echo Reading JDownloader version...
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
