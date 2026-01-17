@echo off

set "AppVersion=0.1"

title ColorTuner v%AppVersion%

:: ==========================================
:: 1. AUTO-ELEVACION CORREGIDA
:: ==========================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Solicitando permisos de Administrador...
    echo.
    
    if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs"
    
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~f0""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    
    "%temp%\getadmin.vbs"
    exit /b
)

if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs"

:: ==========================================
:: 2. CORRECCION DE ENTORNO
:: ==========================================
cd /d "%~dp0"
setlocal EnableDelayedExpansion

echo [OK] Permisos de Administrador obtenidos.
echo [OK] Directorio: %CD%
echo.

:: ==========================================
:: 3. VALORES POR DEFECTO
:: ==========================================
set "DEF_Hilight=0 120 215"
set "DEF_HilightText=255 255 255"
set "DEF_HotTrackingColor=0 102 204"
set "DEF_Menu=240 240 240"
set "DEF_MenuText=0 0 0"
set "DEF_Window=255 255 255"
set "DEF_WindowText=0 0 0"

:MAIN_MENU
cls
call :GET_CURRENT_VALUES
echo.
echo  ================================================================
echo   COLOR TUNER v%AppVersion% - PERSONALIZACION PROFUNDA
echo  ================================================================
echo   Estado: ADMINISTRADOR ^| Ruta: %~dp0
echo  ================================================================
echo.
echo   ID  Elemento a Modificar    ^| Original (Factory) ^| Actual (En uso)
echo   ----------------------------------------------------------------
echo   1.  Fondo Seleccion (Hilight) ^| [%DEF_Hilight%]      ^| [%CUR_Hilight%]
echo   2.  Texto Seleccion           ^| [%DEF_HilightText%]  ^| [%CUR_HilightText%]
echo   3.  Mouse Hover (HotTracking) ^| [%DEF_HotTrackingColor%]      ^| [%CUR_HotTrackingColor%]
echo   4.  Fondo Menu                ^| [%DEF_Menu%]    ^| [%CUR_Menu%]
echo   5.  Texto Menu                ^| [%DEF_MenuText%]        ^| [%CUR_MenuText%]
echo   6.  Fondo Ventana (Window)    ^| [%DEF_Window%]    ^| [%CUR_Window%]
echo   7.  Texto Ventana (WindowText) ^| [%DEF_WindowText%]    ^| [%CUR_WindowText%]
echo   ----------------------------------------------------------------
echo   R.  RESTAURAR TODOS LOS VALORES ORIGINALES
echo   S.  APLICAR CAMBIOS (Forzar actualizacion)
echo   U. BUSCAR ACTUALIZACIONES DEL SCRIPT
echo   0.  SALIR
echo.
echo  ================================================================

set "opt="
set /p "opt=Selecciona una opcion: "

if "%opt%"=="1" set "TARGET_KEY=Hilight" & goto :MODIFY_MENU
if "%opt%"=="2" set "TARGET_KEY=HilightText" & goto :MODIFY_MENU
if "%opt%"=="3" set "TARGET_KEY=HotTrackingColor" & goto :MODIFY_MENU
if "%opt%"=="4" set "TARGET_KEY=Menu" & goto :MODIFY_MENU
if "%opt%"=="5" set "TARGET_KEY=MenuText" & goto :MODIFY_MENU
if "%opt%"=="6" set "TARGET_KEY=Window" & goto :MODIFY_MENU
if "%opt%"=="7" set "TARGET_KEY=WindowText" & goto :MODIFY_MENU
if /i "%opt%"=="R" goto :RESTORE_FACTORY
if /i "%opt%"=="S" goto :REFRESH_SYSTEM
if /i "%opt%"=="U" goto :ACTUALIZAR
if /i "%opt%"=="666" (
    echo ╔══════════════════════════════════════════════╗
    echo ║  ¡Encontraste el easter egg!                ║
    echo ║  Si funciona, es pura suerte.               ║
    echo ║  Si no, bueno... ya sabes.                  ║
    echo ╚══════════════════════════════════════════════╝
    pause
    goto :MAIN_MENU
)
if "%opt%"=="0" exit /b
goto :MAIN_MENU

:: ==========================================
:: MENU DE MODIFICACION INDIVIDUAL
:: ==========================================
:MODIFY_MENU
cls
echo.
echo  EDITANDO: %TARGET_KEY%
echo  ----------------------------------------
echo  Valor Actual: !CUR_%TARGET_KEY%!
echo.
echo  [1] Escribir codigo RGB manualmente (Ej: 128 0 128)
echo  [2] Abrir Selector de Color Visual (Paleta de Windows)
echo  [0] Cancelar
echo.

set "subopt="
set /p "subopt=Opcion > "

if "%subopt%"=="1" goto :MANUAL_INPUT
if "%subopt%"=="2" goto :PICKER_INPUT
if "%subopt%"=="0" goto :MAIN_MENU
goto :MODIFY_MENU


:MANUAL_INPUT
echo.
echo  Formatos aceptados:
echo  - RGB: 134 0 255 (tres numeros separados por espacios)
echo  - HEX: #8600FF o 8600FF (con o sin #)
echo.
:VALIDATE_COLOR
set "NEW_RGB="
set /p "NEW_RGB=Ingresa color (RGB o HEX) o 'cancelar' para volver: "

if /i "%NEW_RGB%"=="cancelar" goto :MAIN_MENU
if "%NEW_RGB%"=="" (
    echo [!] No se ingreso ningun valor.
    timeout /t 2 >nul
    goto :VALIDATE_COLOR
)

:: Verificar si es formato HEX (empieza con # o tiene 6 caracteres hexadecimales)
echo "%NEW_RGB%" | findstr /i "^#\?[0-9A-F][0-9A-F]*$" >nul
if errorlevel 1 goto :CHECK_RGB_FORMAT

:: Convertir HEX a RGB
set "HEX_COLOR=%NEW_RGB%"
set "HEX_COLOR=%HEX_COLOR:#=%"
if not "%HEX_COLOR:~0,6%"=="%HEX_COLOR%" (
    echo [!] Codigo HEX invalido. Debe tener 6 caracteres.
    timeout /t 3 >nul
    goto :VALIDATE_COLOR
)

:: Convertir HEX a decimal usando PowerShell
set "NEW_RGB="
for /f "delims=" %%i in ('powershell -Command "[Convert]::ToInt32('%HEX_COLOR:~0,2%', 16); [Convert]::ToInt32('%HEX_COLOR:~2,2%', 16); [Convert]::ToInt32('%HEX_COLOR:~4,2%', 16)"') do (
    if not defined NEW_RGB (
        set "NEW_RGB=%%i"
    ) else (
        set "NEW_RGB=!NEW_RGB! %%i"
    )
)

echo [!] HEX %HEX_COLOR% convertido a RGB: %NEW_RGB%
goto :APPLY_CHANGE

:CHECK_RGB_FORMAT
:: Procesar formato RGB tradicional
set "NEW_RGB=%NEW_RGB:,= %"
set "NEW_RGB=%NEW_RGB:-= %"
set "NEW_RGB=%NEW_RGB:;= %"

:clean_spaces
if defined NEW_RGB (
    if not "!NEW_RGB:  =!"=="!NEW_RGB!" (
        set "NEW_RGB=!NEW_RGB:  = !"
        goto clean_spaces
    )
)

for /f "tokens=* delims= " %%a in ("%NEW_RGB%") do set "NEW_RGB=%%a"

:: Contar componentes
set COMPONENT_COUNT=0
for %%a in (%NEW_RGB%) do set /a COMPONENT_COUNT+=1

if !COMPONENT_COUNT! NEQ 3 (
    echo [!] Formato invalido. Debe ingresar 3 valores RGB o un codigo HEX.
    timeout /t 3 >nul
    goto :VALIDATE_COLOR
)

:: Validar cada componente
set IS_VALID=1
set COMPONENTS=0
for %%a in (%NEW_RGB%) do (
    set /a COMPONENTS+=1
    echo %%a|findstr /r "^[0-9][0-9]*$" >nul
    if errorlevel 1 (
        set IS_VALID=0
    ) else (
        if %%a LSS 0 set IS_VALID=0
        if %%a GTR 255 set IS_VALID=0
    )
)

if !IS_VALID! EQU 0 (
    echo [!] Valores RGB invalidos. Cada numero debe estar entre 0 y 255.
    timeout /t 3 >nul
    goto :VALIDATE_COLOR
)

echo [!] Color RGB ingresado: %NEW_RGB%
goto :APPLY_CHANGE


:PICKER_INPUT
echo.
echo [!] Abriendo paleta de colores... (puede tardar unos segundos)
echo.

set "NEW_RGB="
for /f "tokens=*" %%i in ('powershell -Command "$colorDialog = New-Object System.Windows.Forms.ColorDialog; $colorDialog.FullOpen = $true; if($colorDialog.ShowDialog() -eq ''OK''){Write-Output (''{0} {1} {2}'' -f $colorDialog.Color.R, $colorDialog.Color.G, $colorDialog.Color.B)} else {Write-Output 'CANCEL'}"') do set "NEW_RGB=%%i"

if "%NEW_RGB%"=="" (
    echo [!] Error al abrir el selector de color.
    timeout /t 2 >nul
    goto :MAIN_MENU
)

if "%NEW_RGB%"=="CANCEL" (
    echo [!] Operacion cancelada por el usuario.
    timeout /t 2 >nul
    goto :MAIN_MENU
)

echo [!] Color seleccionado: %NEW_RGB%
goto :APPLY_CHANGE

:APPLY_CHANGE
echo.
echo [*] Aplicando cambios al registro...
reg add "HKEY_CURRENT_USER\Control Panel\Colors" /v %TARGET_KEY% /t REG_SZ /d "%NEW_RGB%" /f >nul

if errorlevel 1 (
    echo [!] Error al actualizar el registro.
) else (
    echo [OK] Registro actualizado correctamente.
    echo [!] Nota: Los cambios pueden requerir reiniciar Explorer.exe o cerrar sesion.
)

timeout /t 3 >nul
goto :MAIN_MENU

:: ==========================================
:: RESTAURACION TOTAL
:: ==========================================
:RESTORE_FACTORY
cls
echo.
echo  !!! ADVERTENCIA !!!
echo  Esto regresara todos los colores a los valores por defecto.
echo.
echo  Presiona cualquier tecla para continuar o CTRL+C para cancelar...
pause >nul

echo [*] Restaurando valores de fabrica...
reg add "HKEY_CURRENT_USER\Control Panel\Colors" /v Hilight /t REG_SZ /d "%DEF_Hilight%" /f >nul
reg add "HKEY_CURRENT_USER\Control Panel\Colors" /v HilightText /t REG_SZ /d "%DEF_HilightText%" /f >nul
reg add "HKEY_CURRENT_USER\Control Panel\Colors" /v HotTrackingColor /t REG_SZ /d "%DEF_HotTrackingColor%" /f >nul
reg add "HKEY_CURRENT_USER\Control Panel\Colors" /v Menu /t REG_SZ /d "%DEF_Menu%" /f >nul
reg add "HKEY_CURRENT_USER\Control Panel\Colors" /v MenuText /t REG_SZ /d "%DEF_MenuText%" /f >nul
reg add "HKEY_CURRENT_USER\Control Panel\Colors" /v Window /t REG_SZ /d "%DEF_Window%" /f >nul
reg add "HKEY_CURRENT_USER\Control Panel\Colors" /v WindowText /t REG_SZ /d "%DEF_WindowText%" /f >nul

echo.
echo  [OK] Valores de fabrica restaurados.
echo  [!] Es posible que necesites reiniciar Explorer.exe o cerrar sesion.
echo.
pause
goto :MAIN_MENU

:: ==========================================
:: REFRESCAR SISTEMA
:: ==========================================
:REFRESH_SYSTEM
echo.
echo [!] Forzando actualizacion del sistema...
echo [!] Esto puede hacer parpadear la pantalla...

:: Notificar al sistema que los colores han cambiado
reg add "HKEY_CURRENT_USER\Control Panel\Colors" /v "Dummy" /t REG_SZ /d "0 0 0" /f >nul
reg delete "HKEY_CURRENT_USER\Control Panel\Colors" /v "Dummy" /f >nul 2>&1

echo [OK] Cambios forzados. Los colores deberian actualizarse.
timeout /t 2 >nul
goto :MAIN_MENU

:: ==========================================
:: LECTURA DE REGISTRO
:: ==========================================
:GET_CURRENT_VALUES
for %%K in (Hilight HilightText HotTrackingColor Menu MenuText Window WindowText) do (
    set "CUR_%%K=Error"
    for /f "tokens=2*" %%A in ('reg query "HKCU\Control Panel\Colors" /v %%K 2^>nul') do (
        set "CUR_%%K=%%B"
    )
)
goto :eof


:ACTUALIZAR
cls
echo =================================================
echo      BUSCANDO ACTUALIZACIONES PARA EL SCRIPT
echo =================================================
echo.
setlocal
set "localVersion=%AppVersion%"
set "repoUser=RichyKunBv"
set "repoName=ColorTuner"
set "repoURL=https://raw.githubusercontent.com/%repoUser%/%repoName%/main"
set "versionFileURL=%repoURL%/version.txt"
set "scriptFileURL=%repoURL%/ColorTuner.bat"
set "tempVersionFile=%temp%\latest_version.txt"
set "tempNewScriptFile=%temp%\ColorTuner_new.bat"
echo [INFO] Comprobando conexion a internet...
ping -n 1 8.8.8.8 >nul 2>&1
if errorlevel 1 (echo [ERROR] No se detecto una conexion a internet. & goto EndUpdate)
echo [OK]   Conexion establecida.
echo.
echo [INFO] Version actual instalada: %localVersion%
echo [INFO] Obteniendo ultima version desde GitHub...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { (New-Object System.Net.WebClient).DownloadFile('%versionFileURL%', '%tempVersionFile%') } catch {}" >nul 2>&1
if not exist "%tempVersionFile%" (echo [ERROR] No se pudo obtener el archivo de version desde GitHub. & goto EndUpdate)
set /p latestVersion=<%tempVersionFile%
echo [INFO] Ultima version disponible: %latestVersion%
echo.
echo [INFO] Comparando versiones...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if ([Version]'%latestVersion%' -gt [Version]'%localVersion%') { exit 1 } else { exit 0 }"
if not errorlevel 1 (echo [OK]   Ya tienes la ultima version o una superior. & goto EndUpdate)
echo [!] Se encontro una nueva version mas reciente (%latestVersion%)!
set /p "doUpdate=Deseas actualizar el script ahora? (S/N): "
if /i not "%doUpdate%"=="S" (echo [INFO] Actualizacion omitida por el usuario. & goto EndUpdate)
cls
echo =================================================
echo      ACTUALIZANDO SCRIPT...
echo =================================================
echo.
echo [+] Descargando script [%latestVersion%]...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { (New-Object System.Net.WebClient).DownloadFile('%scriptFileURL%', '%tempNewScriptFile%') } catch {}" >nul 2>&1
if not exist "%tempNewScriptFile%" (echo [ERROR] La descarga del script actualizado ha fallado. & goto EndUpdate)
echo [OK]   Descarga completada.
echo.
echo [INFO] La aplicacion se reiniciara para finalizar la actualizacion...
timeout /t 3 /nobreak >nul
(
    echo @echo off
    echo title Actualizando...
    echo echo Finalizando, por favor espera...
    echo timeout /t 1 /nobreak ^> nul
    echo copy /Y "%tempNewScriptFile%" "%~f0" ^> nul
    echo del "%tempNewScriptFile%" ^> nul
    echo del "%tempVersionFile%" ^> nul
    echo start "" "%~f0"
) > "%temp%\updater.bat"
start "" /B "%temp%\updater.bat"
exit
:EndUpdate
del "%tempVersionFile%" >nul 2>&1
echo.
pause
goto MAIN_MENU


