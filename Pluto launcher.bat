@echo off
@title PLUTONIUM LAN LAUNCHER
setlocal


set launching=.\bin\plutonium-bootstrapper-win32.exe
set launcher=.\bin\plutonium-launcher-win32.exe
set latest=cd /D %LOCALAPPDATA%\Plutonium

::config file with username and gamepath
set "inifile=Resources\config.ini"
set powershellscript=Resources\script.ps1
set "sectionS=settings"
set "ininame=username"
set "sectionF=folder"
set "inimw3=folder_mw3"
set "iniwaw=folder_waw"
set "inibo1=folder_bo1"
set "inibo2=folder_bo2"
set "psCommand="(new-object -COM 'Shell.Application')^.BrowseForFolder(0,'Please choose your game folder.',0,0).self.path""


::game paths
::set mw3="D:\modded cod\plutonium\mw3 dodi\pluto_iw5_full_game"
::set mw3=""
::set waw="D:\modded cod\plutonium\T4 aka waw\pluto_t4_full_game"
::set bo1="D:\modded cod\plutonium\T5 BO1\pluto_t5_full_game"
::set bo2="D:\modded cod\plutonium\T6 BO2\pluto_t6_full_game"

call :checkResources
call :makepowershellscript
call :loadConfig


::config
::@REM if exist "Resources\changeme.txt" (
::@REM     set /p name=< Resources\changeme.txt && goto home
::@REM ) else goto case_1


:home
call :folder_mw3
call :folder_waw
call :folder_bo1
call :folder_bo2
MODE 79,20
@Title Home Plutonium Launcher
cls
echo ###############################################################################
echo                         PLUTONIUM LAUNCHER
echo ###############################################################################
echo.
echo   Player Name: %name%
echo.
call :cmdMenuSel "  Launch Online" "  Choose Multiplayer (LAN)" "  Choose Zombies (LAN)" "" "  Settings" "  Exit"
if %ERRORLEVEL% == 1 call :pluto
if %ERRORLEVEL% == 2 call :chooseMultiplayer
if %ERRORLEVEL% == 3 call :chooseZombies
if %ERRORLEVEL% == 4 call :home
if %ERRORLEVEL% == 5 call :settings
if %ERRORLEVEL% == 6 exit

exit /b


::launch multiplayer
:chooseMultiplayer
MODE 79,20
@title Plutonium Multiplayer Launcher
cls
echo ###############################################################################
echo                       PLUTONIUM MULTIPLAYER LAUNCHER
echo ###############################################################################
echo.
call :cmdMenuSel "  Launch Modern Warfare 3 (IW5)" "  Launch Wordl at War (T4)" "  Launch Black Ops (T5)" "  Launch BLACK OPS 2 (T6)" "  Back"

if %ERRORLEVEL% == 1 call :multiplayer_1
if %ERRORLEVEL% == 2 call :multiplayer_2
if %ERRORLEVEL% == 3 call :multiplayer_3
if %ERRORLEVEL% == 4 call :multiplayer_4
if %ERRORLEVEL% == 5 goto home

exit /b


::launch zombies
:chooseZombies
MODE 79,20
@title Plutonium Zombie Launcher
cls
echo ###############################################################################
echo                      PLUTONIUM ZOMBIE LAUNCHER
echo ###############################################################################
echo.
call :cmdMenuSel "  Launch Wordl at War (T4)" "  Launch Black Ops (T5)" "  Launch BLACK OPS 2 (T6)" "  Back"

if %ERRORLEVEL% == 1 call :zombies_1
if %ERRORLEVEL% == 2 call :zombies_2
if %ERRORLEVEL% == 3 call :zombies_3
if %ERRORLEVEL% == 4 goto home

:settings
mode 79,10
@title Plutonium LAN Settings
echo ###############################################################################
echo                         PLUTONIUM LAN SETTINGS
echo ###############################################################################
echo.
call :cmdMenuSel "  Edit Name" "  Edit Gamepath" "  Back"
if %ERRORLEVEL% == 1 call :editName
if %ERRORLEVEL% == 2 call :editGamepath
if %ERRORLEVEL% == 3 call :home
exit /b

:editName
mode 79,10
@title Edit username
cls
echo ###############################################################################
echo                              EDITING USERNAME
echo ###############################################################################
echo.
echo   at the moment the name doesn't save so you have to manually edit the config 
echo   file if you would like to save the name after closing
::del changeme.txt
::setx /f path_to_ini_file.ini section_name key_name new_value
set /p name="Enter Player name: "


powershell -ExecutionPolicy Bypass -File "%powershellscript%" -iniFile "%inifile%" -section "%sectionS%" -key "%ininame%" -newValue "%name%"

goto home
::change gamepath
:editGamepath
::call :folder_mw3
::call :folder_waw
::call :folder_bo1
::call :folder_bo2
mode 79,30
@title Edit Gamepath
cls
echo ###############################################################################
echo                              EDITING GAMEPATH
echo ###############################################################################
echo "If it doesn't work -> Edit your path in the %inifile% file"
echo.
echo   Modern Warfare 3: 
echo   %mw3%
echo.
echo   World at War: 
echo   %waw%
echo.
echo   Black Ops: 
echo   %bo1%
echo.
echo   Black Ops 2: 
echo   %bo2%
echo.
echo.
call :cmdMenuSel "  Edit Path MW3" "  Edit Path WAW" "  Edit Path BO1" "  Edit Path BO2" "  back"

if %ERRORLEVEL% == 1 call :edit_mw3
if %ERRORLEVEL% == 2 call :edit_waw
if %ERRORLEVEL% == 3 call :edit_bo1
if %ERRORLEVEL% == 4 call :edit_bo2
if %ERRORLEVEL% == 5 call :home
exit /b


:checkResources
@Title Downloading cmdMenuSel
MODE 79,10
if not exist "Resources\cmdmenusel.exe" (
mkdir Resources
echo -------------------------------------------------------------------------------
echo ###################### Downloading cmdmenusel...###############################
echo -------------------------------------------------------------------------------
::curl -L  "https://github.com/JOJOVAV/cod-Lan-Launcher/releases/download/first/cmdmenusel.exe" --ssl-no-revoke --output cmdmenusel.exe
curl -L "https://github.com/JOJOVAV/cod-Lan-Launcher/raw/main/cmdmenusel.exe" --ssl-no-revoke --output cmdmenusel.exe

move cmdmenusel.exe Resources
)
exit /b

:makepowershellscript

if exist "%powershellscript%" (
    goto loadConfig
)
else (
        
    echo param ( > "%powershellscript%"
    echo     [string]$iniFile, >> "%powershellscript%"
    echo     [string]$section, >> "%powershellscript%"
    echo     [string]$key, >> "%powershellscript%"
    echo     [string]$newValue >> "%powershellscript%"
    echo ^) >> "%powershellscript%"
    
    echo $content = Get-Content -Path $iniFile >> "%powershellscript%"
    echo $newContent = @() >> "%powershellscript%"
    echo if ($section -eq "settings") { >> "%powershellscript%"
    echo     foreach ($line in $content) { >> "%powershellscript%"
    echo         if ($line -match "^\s*$key\s*=") { >> "%powershellscript%"
    echo             $newLine = "$key=$newValue" >> "%powershellscript%"
    echo             $newContent += $newLine >> "%powershellscript%"
    echo         } else { >> "%powershellscript%"
    
    echo             $newContent += $line >> "%powershellscript%"
    echo         } >> "%powershellscript%"
    echo     } >> "%powershellscript%"
    echo } else { >> "%powershellscript%"
    
    echo     foreach ($line in $content) { >> "%powershellscript%"
    echo         if ($line -match "^\s*$key\s*=") { >> "%powershellscript%"
    echo             $newLine = "$key=""$newValue""" >> "%powershellscript%"
    echo             $newContent += $newLine >> "%powershellscript%"
    echo         } else { >> "%powershellscript%"
    echo             $newContent += $line >> "%powershellscript%"
    echo         } >> "%powershellscript%"
    echo     } >> "%powershellscript%"
    echo } >> "%powershellscript%"
    
    echo $newContent ^| Set-Content -Path $iniFile >> "%powershellscript%"

    exit /b


)




::loading the config or if exist goes to checking name if empty
:loadConfig
if not exist "%inifile%" (
    (
        echo ;the little settings configuration
        echo [settings]
        echo ;format username=yourusername
        echo username=
        echo [folder]
        echo ;format same as the username
        echo ;folder=your\path\to\the\game
        echo ;example folder_bo1="D:\modded cod\plutonium\T5 BO1\pluto_t5_full_game"
        echo folder_mw3=""
        echo folder_waw=""
        echo folder_bo1=""
        echo folder_bo2=""
    ) > "%inifile%" && call :editName
) else call :checkname




:checkname
@REM echo checkname
@REM pause
@REM  for /f "usebackq tokens=1,*" %%A in ("%inifile%") do (
@REM     set "line=%%A"
    
@REM     if "!line:[%sectionS%]!" neq "!line!" (
@REM         for /f "tokens=1,2 delims==" %%B in ("!line!") do (
@REM             if "%%B"=="%ininame%" (
@REM                 if "%%C"=="" (
                                        
@REM                     goto editname
@REM                 ) else (
@REM                     set "name=%%C"
                    
@REM                     exit /b

@REM                 )
@REM             )
@REM         )
@REM     )
@REM )

for /f "tokens=2 delims==" %%A in ('find "%ininame%=" %inifile%') do (
    set "name=%%A"
)
exit /b

::edit folder
:edit_mw3

for /f "usebackq delims=" %%Z in (`powershell %psCommand%`) do set "mw3=%%Z"

powershell -ExecutionPolicy Bypass -File "%powershellscript%" -iniFile "%inifile%" -section "%sectionF%" -key "%inimw3%" -newValue "%mw3%"

goto editGamepath

:edit_waw

for /f "usebackq delims=" %%Y in (`powershell %psCommand%`) do set "waw=%%Y"

powershell -ExecutionPolicy Bypass -File "%powershellscript%" -iniFile "%inifile%" -section "%sectionF%" -key "%iniwaw%" -newValue "%waw%"

goto editGamepath

:edit_bo1

for /f "usebackq delims=" %%X in (`powershell %psCommand%`) do set "bo1=%%X"

powershell -ExecutionPolicy Bypass -File "%powershellscript%" -iniFile "%inifile%" -section "%sectionF%" -key "%inibo1%" -newValue "%bo1%"

goto editGamepath

:edit_bo2

for /f "usebackq delims=" %%W in (`powershell %psCommand%`) do set "bo2=%%W"

powershell -ExecutionPolicy Bypass -File "%powershellscript%" -iniFile "%inifile%" -section "%sectionF%" -key "%inibo2%" -newValue "%bo2%"

goto editGamepath

:cmdMenuSel
Resources\cmdMenuSel 07f0 %*
exit /b

:folder_mw3
for /f "tokens=2 delims==" %%H in ('find "%inimw3%=" %inifile%') do (
    @REM set "%inimw3%=%%H"
    set "mw3=%%H"
)
exit /b

:folder_waw
for /f "tokens=2 delims==" %%I in ('find "%iniwaw%=" %inifile%') do (
    @REM set "iniwaw=%%I"
    set "waw=%%I"
   )
exit /b

:folder_bo1
for /f "tokens=2 delims==" %%J in ('find "%inibo1%=" %inifile%') do (
    @REM set "inibo1=%%J"
    set "bo1=%%J"
   )
   exit /b

:folder_bo2
for /f "tokens=2 delims==" %%L in ('find "%inibo2%=" %inifile%') do (
    @REM set "inibo2=%%L"
    set "bo2=%%L"
   )
exit /b

:pluto
%latest%
start /wait "" "%launcher%"
exit /b



::function to launch the game
:LaunchGame

%latest%
start /wait /abovenormal %launching% %1 %2 -lan -name "%name%"
exit /b

::rem iw5mp = modernwarfare 3 multiplayer
:multiplayer_1 
call :LaunchGame iw5mp %mw3%
exit

::rem t4mp = world at war multiplayer
:multiplayer_2 
call :LaunchGame t4mp %waw%
exit

::rem t5mp = black ops 1 multiplayer
:multiplayer_3 
call :LaunchGame t5mp %bo1%
exit

::rem t6mp = black ops 2 multiplayer
:multiplayer_4 
call :LaunchGame t6mp %bo2%
exit

::rem t4sp = world at war singleplayer/zombies
:zombies_1 
call :LaunchGame t4sp %waw%
exit

::rem t5sp = black ops singleplayer/zombies
:zombies_2 
call :LaunchGame t5sp %bo1%
exit

::rem t6zm = black ops singleplayer/zombies 
:zombies_3 
call :LaunchGame t6zm %bo2%
exit

endlocal
