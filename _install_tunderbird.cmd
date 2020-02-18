@ECHO OFF

rem Script de instalacao do cliente de email Mozilla Thunderbird - Igor

rem 19/06/2018 - atualizado para 52.8.0
rem 29/03/2018 - atualizado para 52.7.0
rem 08/02/2018 - atualizado para 52.6.0
rem 10/01/2018 - atualizado para 52.5.2
rem 17/07/2017 - atualizado para 52.3.0
rem 05/07/2017 - atualizado para 52.2.1
rem atualizado para 52.0 - 08/04/2016
rem Use a versao 24.8.0 mantida para compatibilidade na migracao entre Eudora/TB.

SETLOCAL EnableDelayedExpansion
IF NOT DEFINED VERSAO SET VERSAO=52.8.0
SET SOFTWARE=%~dp0
SET SOFTWARE=%SOFTWARE:~0,-1%

IF [%PROCESSOR_ARCHITECTURE%] EQU [AMD64] (
  ECHO _OS=64bits / Thunderbird 32-bits
  SET HKLM_SOFTWARE=HKLM\SOFTWARE\Wow6432Node
) ELSE (
  ECHO _OS=32bits / Thunderbird 32-bits
  SET HKLM_SOFTWARE=HKLM\SOFTWARE
)

IF [%1] NEQ [-uninstall] IF [%1] NEQ [-reinstall] (
  FOR /F "tokens=3" %%V in ('reg query "%HKLM_SOFTWARE%\Mozilla\Mozilla Thunderbird" /ve 2^>NUL') do (
    IF [%%V] EQU [%VERSAO%] ECHO [%TIME%] Thunderbird ja esta atualizado: %%V & GOTO :FIM
  )
)

IF [%PROCESSOR_ARCHITECTURE%] EQU [AMD64] (
  FOR /F "tokens=3*" %%U in ('REG QUERY HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion ^| findstr /i /r /c:^"ProgramFilesDir.*x86^"') DO CALL SET THUNDERBIRD_HOME=%%V\Mozilla Thunderbird
) ELSE (
  FOR /F "tokens=2*" %%U in ('REG QUERY HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion ^| findstr ^"ProgramFilesDir^"') DO CALL SET THUNDERBIRD_HOME=%%V\Mozilla Thunderbird
)

tasklist /nh | findstr /i thunderbird.exe >nul
IF %ERRORLEVEL% EQU 0 (
  ECHO [%TIME%] Thunderbird em execucao.
  EXIT /B 1
)
pause
IF EXIST "!THUNDERBIRD_HOME!\uninstall\helper.exe" (
  ECHO [%TIME%] Desinstalando a versao atual ...
  CALL "!THUNDERBIRD_HOME!\uninstall\helper.exe" -ms 2>NUL
  ping -n 10 127.0.0.1 >NUL 2>&1
)

IF EXIST "!THUNDERBIRD_HOME!" rmdir /s /q "!THUNDERBIRD_HOME!"

IF [%1] EQU [-uninstall] GOTO :FIM

ECHO [%TIME%] Instalando Thunderbird %VERSAO% ...
CALL %SOFTWARE%\setup\%VERSAO%\setup.exe /S
ECHO [%TIME%] Saida=%ERRORLEVEL%
IF EXIST "%PUBLIC%\Desktop\Mozilla Thunderbird.lnk" (
  DEL /Q "%PUBLIC%\Desktop\Mozilla Thunderbird.lnk"
) ELSE (
  IF EXIST "%ALLUSERSPROFILE%\Desktop\Mozilla Thunderbird.lnk" (
    DEL /Q "%ALLUSERSPROFILE%\Desktop\Mozilla Thunderbird.lnk"
  )
)

ECHO [%TIME%] Desativando Mozilla Service ...
sc config MozillaMaintenance start= disabled >NUL
sc stop MozillaMaintenance >NUL


ECHO [%TIME%] Aplicando configuracoes ...
> "!THUNDERBIRD_HOME!\autoconfig.js" (
  ECHO // Criado em %DATE% %TIME% - Igor
  ECHO.
  ECHO // Desabilita atualizacao automatica
  ECHO lockPref^(^"app.update.auto^", false^);
  ECHO lockPref^(^"app.update.enabled^", false^);
  ECHO lockPref^(^"app.update.silent^", false^);
  ECHO.
  ECHO // Definicao de extensoes
  ECHO lockPref^(^"extensions.enabledScopes^", 4^);
  ECHO lockPref^(^"extensions.autoDisableScopes^", 11^);
  ECHO.
) && ECHO [%TIME%] .Configuracao 1 [autoconfig.js] ok. || ECHO [%TIME%] .Configuracao 1 [autoconfig.js] falhou.

IF NOT EXIST "!THUNDERBIRD_HOME!\defaults\pref" MKDIR "!THUNDERBIRD_HOME!\defaults\pref"
> "!THUNDERBIRD_HOME!\defaults\pref\thunderbird.js" (
  ECHO // Criado em %DATE% %TIME% - Igor
  ECHO.
  ECHO // bloqueio basico
  ECHO lockPref^(^"app.update.auto^", false^);
  ECHO lockPref^(^"app.update.enabled^", false^);
  ECHO lockPref^(^"app.update.silent^", false^);
  ECHO.
  ECHO // desativa migracao
  ECHO lockPref^(^"mail.ui.show.migration.on.upgrade^", false^);
  ECHO.
  ECHO // desativa instrucoes de uso
  ECHO pref^(^"general.config.obscure_value^", 0^);
  ECHO pref^(^"general.config.filename^", ^"autoconfig.js^"^);
  ECHO.
  ECHO // desativa arquivos offline
  ECHO // 200MB around 8000 messages causes index-file over 35MB, maybe more, but
  ECHO in the test-machine quota filled at that point.
  ECHO.
  ECHO lockPref^(^"mailnews.database.global.indexer.enabled^", false^);
  ECHO lockPref^(^"mail.server.default.offline_download^", false^);
  ECHO lockPref^(^"mail.server.default.autosync_offline_stores^", false^);
  ECHO lockPref^(^"mail.provider.enabled^", false^);
  ECHO lockPref^(^"mail.cloud_files.enabled^", false^);
  ECHO.
  ECHO //remove ^"know your rights^" e outras coisas
  ECHO defaultPref^(^"mail.rights.version^", 1^);
  ECHO defaultPref^(^"toolkit.telemetry.prompted^", true^);
  ECHO defaultPref^(^"toolkit.telemetry.rejected^", true^);
  ECHO.
) && ECHO [%TIME%] .Configuracao 2 [thunderbird.js] ok. || ECHO [%TIME%] .Configuracao 2 [thunderbird.js] falhou.
:FIM
ECHO [%TIME%] Concluido.
ENDLOCAL

