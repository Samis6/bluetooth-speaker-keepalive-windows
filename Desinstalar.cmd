@echo off
rem Fecha o programa e remove arquivos e atalho.
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'powershell.exe' -and $_.CommandLine -like '*KeepAliveGUI.ps1*' -and $_.ProcessId -ne $PID } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }; foreach($f in 'Desktop','Programs'){ Remove-Item ([Environment]::GetFolderPath($f)+'\Bluetooth KeepAlive.lnk') -ErrorAction SilentlyContinue }"
timeout /t 1 >nul
rmdir /s /q "%LOCALAPPDATA%\BluetoothKeepAliveGUI" 2>nul
echo Desinstalado.
timeout /t 3 >nul
