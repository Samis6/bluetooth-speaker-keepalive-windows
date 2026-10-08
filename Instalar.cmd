@echo off
rem Copia o programa para %LOCALAPPDATA% e cria atalhos na Area de Trabalho e no Menu Iniciar.
rem NAO configura inicio automatico com o Windows.
setlocal
set "DEST=%LOCALAPPDATA%\BluetoothKeepAliveGUI"
if not exist "%DEST%" mkdir "%DEST%"
copy /Y "%~dp0KeepAliveGUI.ps1" "%DEST%\KeepAliveGUI.ps1" >nul
copy /Y "%~dp0KeepAlive.vbs" "%DEST%\KeepAlive.vbs" >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "$q=[char]34; $d=$env:LOCALAPPDATA+'\BluetoothKeepAliveGUI'; foreach($f in 'Desktop','Programs'){ $s=(New-Object -ComObject WScript.Shell).CreateShortcut([Environment]::GetFolderPath($f)+'\Bluetooth KeepAlive.lnk'); $s.TargetPath='wscript.exe'; $s.Arguments=$q+$d+'\KeepAlive.vbs'+$q; $s.IconLocation='shell32.dll,168'; $s.Save() }"
echo.
echo Instalado. Atalho "Bluetooth KeepAlive" criado na Area de Trabalho e no Menu Iniciar.
echo Para abrir depois: aperte a tecla Windows e digite "Bluetooth KeepAlive".
echo Abrindo agora... procure o icone na bandeja (perto do relogio).
start "" wscript.exe "%DEST%\KeepAlive.vbs"
timeout /t 3 >nul
