:: Developed by Yuri Natan - SESC SP Jundiai
:: Prupose - Help the installation and update clients Thunderbird set up without automatic updates
@echo off
set SCRIPT_VERSION=1.0
set SCRIPT_UPDATED=2020-02-17

:: Standard date format (yyyy-mm-dd)
for /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') do set DTS=%%a
set CUR_DATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%

:: This is useful if we start from a network share; converts CWD to a drive letter
pushd %~dp0
cls


:::::::::::::::
:: VARIABLES :: -- Set these to your desired values
:::::::::::::::
:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\logs
set LOGFILE=%COMPUTERNAME%_Mozilla_Thunderbird_x86_install.log

:: Package to install. Do not use trailing slashes (\)
set BINARY=C:\Scripts\TB60.exe
set FLAGS=/INI="C:\Scripts\Thunderbird_settings.ini"

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::

:: Kill Thunderbird first
echo %CUR_DATE% %TIME% Killing any running Thunderbird instances, please wait...
echo %CUR_DATE% %TIME% Killing any running Thunderbird instances, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
taskkill.exe /fi "IMAGENAME eq thunderbird*" /f /t >> "%LOGPATH%\%LOGFILE%" 2>NUL
wmic process where name="thunderbird.exe" call terminate >> "%LOGPATH%\%LOGFILE%" 2>NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Install the package from a local directory (if all files are in the same directory)
echo %CUR_DATE% %TIME% Installing package...
echo %CUR_DATE% %TIME% Installing package...>> "%LOGPATH%\%LOGFILE%" 2>NUL
"%BINARY%" %FLAGS%
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


echo %CUR_DATE% %TIME% Finishing configuration and cleaning up...
echo %CUR_DATE% %TIME% Finishing configuration and cleaning up...>> "%LOGPATH%\%LOGFILE%" 2>NUL
:: The first command copies the first of two custom preferences files, which is the default new user settings file.
:: The second command copies the second of two custom preferences files, which is the computer-wide settings file.
:: Neither of these contain any settings, they simply redirect Thunderbird to use our settings file on the server. 

:: 64-bit version
if exist "%ProgramFiles(x86)%\Mozilla Thunderbird\" copy /Y "C:\Scripts\channel-prefs.js" "%ProgramFiles(x86)%\Mozilla Thunderbird\defaults\pref\"
:: if exist "%ProgramFiles(x86)%\Mozilla Thunderbird\" copy /Y "%~dp0thunderbird-custom-user-settings.js" "%ProgramFiles(x86)%\Mozilla Thunderbird\defaults\pref"

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
