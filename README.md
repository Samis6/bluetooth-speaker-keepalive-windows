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
2. Double-click `Instalar.cmd` (copies the app to `%LOCALAPPDATA%` and creates Desktop and Start Menu shortcuts; to open it later, press the Windows key and type "Bluetooth KeepAlive").
   - Or, without installing: double-click `KeepAlive.vbs`.
3. The program window opens. In it you can:
   - **Turn it On / Off** with the big button;
   - set the **interval** between pings (default 30 s), the **length** of each ping (default 2 s) and the **audio mode** (true silent or near-silent);
   - enable **continuous mode** (silence played in a loop so the audio stream never closes: no delay or clipped start on the next sound, but uses more battery on the speaker and the PC);
   - choose whether to **turn on automatically when the program opens** (default: unchecked, so it opens turned off);
   - click **Salvar configurações** (Save settings) to apply.
4. Closing the window with the **X** or the **Fechar para a bandeja** (Close to tray) button does not quit the program: it stays in the system tray (near the clock, maybe inside the `^` arrow).
   The tray icon stays there while the program is running: **right-click** it to turn on/off (Ligar/Desligar), open the window (Abrir) or quit (Sair); **double-click** opens the window.
   To quit completely, use the **Encerrar programa** (Quit) button at the top right of the window.

> The UI is currently in Portuguese.

> To keep the icon always visible, drag it from the `^` arrow onto the taskbar (or Settings → Personalization → Taskbar → Other system tray icons). Windows controls this, the program can't force it.

> Your Bluetooth speaker must be selected as the Windows audio output
> (Settings → System → Sound → Output).

## If the speaker still turns off

- If the beginning of sounds is cut off after some idle time, enable **continuous mode**.
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
