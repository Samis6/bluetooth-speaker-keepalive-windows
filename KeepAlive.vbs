' Abre o Bluetooth KeepAlive sem janela de console (fica só o ícone na bandeja).
Set fso = CreateObject("Scripting.FileSystemObject")
dir = fso.GetParentFolderName(WScript.ScriptFullName)
CreateObject("WScript.Shell").Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & dir & "\KeepAliveGUI.ps1""", 0, False
