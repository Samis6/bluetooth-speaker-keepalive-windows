# Bluetooth KeepAlive (GUI version)

🌐 **English** · [Português (Brasil)](README.pt-BR.md)

Stops your Bluetooth speaker from going to sleep or disconnecting on Windows by
playing a silent audio signal every so often. It has its **own window** where you
turn it on/off and adjust everything.

- **Does not start with Windows** — it only runs when you open it.
- No administrator permission required.
- No network access, no data collection: it only plays a local WAV file through the default audio output.

## How to use

1. Download or clone this repository.
2. Double-click `Instalar.cmd` (copies the app to `%LOCALAPPDATA%` and creates a Desktop shortcut).
   - Or, without installing: double-click `KeepAlive.vbs`.
3. The program window opens. In it you can:
   - **Turn it On / Off** with the big button;
   - set the **interval** between pings (default 30 s), the **length** of each ping (default 2 s) and the **audio mode** (true silent or near-silent);
   - choose whether to **turn on automatically when the program opens** (default: unchecked, so it opens turned off);
   - click **Salvar configurações** (Save settings) to apply.
4. Closing the window with the **X** does not quit the program: it stays in the system tray (near the clock, maybe inside the `^` arrow).
   The tray icon is only a shortcut to reopen the window (double-click) or quit (right-click → Sair).
   To quit completely, use the **Encerrar programa** (Quit) button in the window.

> The UI is currently in Portuguese.

> Your Bluetooth speaker must be selected as the Windows audio output
> (Settings → System → Sound → Output).

## If the speaker still turns off

- Lower the interval to 15 s.
- Try the "near-silent" mode.

## Uninstall

Double-click `Desinstalar.cmd`.

## Files

Config and log are stored in `%LOCALAPPDATA%\BluetoothKeepAliveGUI`.

## Credits and license

Idea inspired by [MamunKhan71/bluetooth-speaker-keepalive-windows](https://github.com/MamunKhan71/bluetooth-speaker-keepalive-windows) (Md. Mamun, MIT license),
a windowless installer. This version is a reimplementation in PowerShell/WinForms.
MIT license — see `LICENSE`.
