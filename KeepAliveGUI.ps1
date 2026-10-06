<#
  Bluetooth KeepAlive (versão com interface)

  Mantém a caixa de som Bluetooth acordada tocando um áudio silencioso
  de tempos em tempos.

  O liga/desliga e as configurações ficam na JANELA do programa.
  O ícone da bandeja (perto do relógio) fica sempre lá: botão direito =
  Ligar/Desligar, Abrir ou Sair; duplo clique abre a janela.

  NÃO inicia com o Windows. Você abre quando quiser.
  Não precisa de permissão de administrador.

  Ideia inspirada em MamunKhan71/bluetooth-speaker-keepalive-windows (MIT).
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ---------------------------------------------------------------- caminhos
$AppName    = 'BluetoothKeepAliveGUI'
$AppDir     = Join-Path $env:LOCALAPPDATA $AppName
$ConfigPath = Join-Path $AppDir 'config.json'
$WavPath    = Join-Path $AppDir 'keepalive.wav'
$LogPath    = Join-Path $AppDir 'keepalive.log'
if (-not (Test-Path $AppDir)) { New-Item -ItemType Directory -Path $AppDir | Out-Null }
if ((Test-Path $LogPath) -and ((Get-Item $LogPath).Length -gt 200KB)) { Remove-Item $LogPath -Force -ErrorAction SilentlyContinue }

function Log([string]$m) {
    try { Add-Content -Path $LogPath -Value ('{0:s} {1}' -f (Get-Date), $m) } catch {}
}

# ------------------------------------------------------- instância única
$script:Mutex = New-Object System.Threading.Mutex($false, 'Local\BluetoothKeepAliveGUI')
if (-not $script:Mutex.WaitOne(0, $false)) {
    [System.Windows.Forms.MessageBox]::Show(
        'O Bluetooth KeepAlive já está aberto. Procure o ícone na bandeja do sistema (perto do relógio; talvez dentro da setinha ^) e dê duplo clique para abrir a janela.',
        'Bluetooth KeepAlive', 'OK', 'Information') | Out-Null
    exit
}

# ------------------------------------------------------------ configuração
$script:Config = @{ IntervalSeconds = 30; LengthSeconds = 2; Mode = 'silent'; AutoEnable = $false; Continuous = $false }
$script:Enabled = $false
$script:Quitting = $false
$script:HintShown = $false
$script:LastPing = $null

function Load-Config {
    if (Test-Path $ConfigPath) {
        try {
            $j = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
            foreach ($k in @($script:Config.Keys)) {
                if ($null -ne $j.$k) { $script:Config[$k] = $j.$k }
            }
        } catch { Log "config inválida: $_" }
    }
}
function Save-Config {
    try { $script:Config | ConvertTo-Json | Set-Content -Path $ConfigPath -Encoding UTF8 } catch { Log "erro ao salvar config: $_" }
}

# ---------------------------------------------------------- áudio (WAV)
function New-KeepAliveWav {
    param([string]$Path, [int]$Seconds, [string]$Mode)
    $rate = 44100; $channels = 2
    $frames  = $rate * $Seconds
    $dataLen = $frames * $channels * 2
    $data = New-Object byte[] $dataLen   # zeros = silêncio digital

    if ($Mode -eq 'near') {
        # Quase silencioso: amostras alternando +1 / -1 (inaudível, mas não é zero puro)
        $pattern = [byte[]](1,0,1,0,255,255,255,255)
        [Array]::Copy($pattern, 0, $data, 0, [Math]::Min(8, $dataLen))
        $filled = 8
        while ($filled -lt $dataLen) {
            $n = [Math]::Min($filled, $dataLen - $filled)
            [Buffer]::BlockCopy($data, 0, $data, $filled, $n)
            $filled += $n
        }
    }

    $fs = [System.IO.File]::Create($Path)
    try {
        $bw = New-Object System.IO.BinaryWriter($fs)
        $bw.Write([System.Text.Encoding]::ASCII.GetBytes('RIFF'))
        $bw.Write([int](36 + $dataLen))
        $bw.Write([System.Text.Encoding]::ASCII.GetBytes('WAVEfmt '))
        $bw.Write([int]16)
        $bw.Write([int16]1)
        $bw.Write([int16]$channels)
        $bw.Write([int]$rate)
        $bw.Write([int]($rate * $channels * 2))
        $bw.Write([int16]($channels * 2))
        $bw.Write([int16]16)
        $bw.Write([System.Text.Encoding]::ASCII.GetBytes('data'))
        $bw.Write([int]$dataLen)
        $bw.Write($data)
        $bw.Flush()
    } finally { $fs.Dispose() }
}

# ------------------------------------------------------ player e temporizador
$player = New-Object System.Media.SoundPlayer
$timer  = New-Object System.Windows.Forms.Timer

function Apply-Audio {
    try { $player.Stop() } catch {}
    if ([bool]$script:Config.Continuous) { $secs = 10 } else { $secs = [int]$script:Config.LengthSeconds }
    New-KeepAliveWav -Path $WavPath -Seconds $secs -Mode ([string]$script:Config.Mode)
    $player.SoundLocation = $WavPath
    $player.Load()
    $timer.Interval = [int]$script:Config.IntervalSeconds * 1000
}

function Invoke-Ping {
    try {
        $player.Play()
        $script:LastPing = Get-Date
        Update-Ui
    } catch { Log "erro no ping: $_" }
}
$timer.Add_Tick({ Invoke-Ping })

function Start-KeepAlive {
    $timer.Stop()
    if ([bool]$script:Config.Continuous) {
        # Modo contínuo: silêncio em loop, o stream de áudio nunca fecha
        try { $player.PlayLooping() } catch { Log "erro no loop: $_" }
        $script:LastPing = $null
    } else {
        Invoke-Ping
        $timer.Start()
    }
}

function Stop-KeepAlive {
    $timer.Stop()
    try { $player.Stop() } catch {}
    $script:LastPing = $null
}

# ------------------------------------------------------------------ ícones
function New-StateIcon([bool]$On) {
    $bmp = New-Object System.Drawing.Bitmap 32, 32
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    if ($On) { $c = [System.Drawing.Color]::FromArgb(46, 160, 67) } else { $c = [System.Drawing.Color]::FromArgb(140, 140, 140) }
    $brush = New-Object System.Drawing.SolidBrush $c
    $g.FillEllipse($brush, 1, 1, 30, 30)
    $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::White), 3
    if ($On) {
        $g.DrawArc($pen, 8, 8, 16, 16, -50, 100)
        $g.DrawArc($pen, 3, 3, 26, 26, -50, 100)
        $g.FillEllipse([System.Drawing.Brushes]::White, 9, 13, 6, 6)
    } else {
        $g.DrawLine($pen, 9, 16, 23, 16)
    }
    $g.Dispose(); $brush.Dispose(); $pen.Dispose()
    return [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
}
$iconOn  = New-StateIcon $true
$iconOff = New-StateIcon $false

# ------------------------------------------------------------ janela principal
function New-Ctl($type, [int]$x, [int]$y, [int]$w, [int]$h, $text) {
    $c = New-Object $type
    $c.Location = New-Object System.Drawing.Point($x, $y)
    $c.Size = New-Object System.Drawing.Size($w, $h)
    if ($text) { $c.Text = $text }
    return $c
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Bluetooth KeepAlive'
$form.ClientSize = New-Object System.Drawing.Size(400, 452)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)

$lblStatus = New-Ctl 'System.Windows.Forms.Label' 20 14 230 38 ''
$lblStatus.Font = New-Object System.Drawing.Font('Segoe UI', 20, [System.Drawing.FontStyle]::Bold)
$lblLast = New-Ctl 'System.Windows.Forms.Label' 22 54 360 20 ''
$lblLast.ForeColor = [System.Drawing.Color]::Gray

$btnToggle = New-Ctl 'System.Windows.Forms.Button' 20 84 360 52 ''
$btnToggle.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)

$grp = New-Ctl 'System.Windows.Forms.GroupBox' 20 152 360 234 'Configurações'
$l1 = New-Ctl 'System.Windows.Forms.Label' 12 33 230 20 'Intervalo entre pings (segundos):'
$numInterval = New-Ctl 'System.Windows.Forms.NumericUpDown' 255 30 90 24 ''
$numInterval.Minimum = 5; $numInterval.Maximum = 600
$l2 = New-Ctl 'System.Windows.Forms.Label' 12 67 230 20 'Duração de cada ping (segundos):'
$numLength = New-Ctl 'System.Windows.Forms.NumericUpDown' 255 64 90 24 ''
$numLength.Minimum = 1; $numLength.Maximum = 30
$l3 = New-Ctl 'System.Windows.Forms.Label' 12 101 110 20 'Modo de áudio:'
$cmbMode = New-Ctl 'System.Windows.Forms.ComboBox' 125 98 220 24 ''
$cmbMode.DropDownStyle = 'DropDownList'
[void]$cmbMode.Items.Add('Silêncio total (recomendado)')
[void]$cmbMode.Items.Add('Quase silencioso')
$chkCont = New-Ctl 'System.Windows.Forms.CheckBox' 12 132 340 22 'Modo contínuo (stream sempre aberto, sem pausas)'
$chkAuto = New-Ctl 'System.Windows.Forms.CheckBox' 12 160 340 22 'Ligar automaticamente ao abrir o programa'
$lblTip = New-Ctl 'System.Windows.Forms.Label' 12 190 340 40 'Modo contínuo: evita o atraso no início do som, mas gasta mais bateria.'
$lblTip.ForeColor = [System.Drawing.Color]::Gray
$lblTip.Font = New-Object System.Drawing.Font('Segoe UI', 8)
$grp.Controls.AddRange(@($l1, $numInterval, $l2, $numLength, $l3, $cmbMode, $chkCont, $chkAuto, $lblTip))

$btnSave = New-Ctl 'System.Windows.Forms.Button' 20 398 175 36 'Salvar configurações'
$btnQuit = New-Ctl 'System.Windows.Forms.Button' 250 18 130 32 'Encerrar programa'
$btnTray = New-Ctl 'System.Windows.Forms.Button' 205 398 175 36 'Fechar para a bandeja'

$form.Controls.AddRange(@($lblStatus, $lblLast, $btnQuit, $btnToggle, $grp, $btnSave, $btnTray))

# ------------------------------------------------------------------ bandeja
# Ícone sempre presente: botão direito liga/desliga, abre a janela ou sai.
$notify = New-Object System.Windows.Forms.NotifyIcon
$menu = New-Object System.Windows.Forms.ContextMenuStrip
$miToggle = $menu.Items.Add('Ligar')
$miOpen = $menu.Items.Add('Abrir Bluetooth KeepAlive')
[void]$menu.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))
$miExit = $menu.Items.Add('Sair')
$notify.ContextMenuStrip = $menu

# ---------------------------------------------------------------- lógica UI
function Update-Ui {
    if ($script:Enabled) {
        $lblStatus.Text = '● Ligado'
        $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(46, 160, 67)
        $btnToggle.Text = 'Desligar'
        $miToggle.Text = 'Desligar'
        $notify.Icon = $iconOn
        $form.Icon = $iconOn
        $notify.Text = 'Bluetooth KeepAlive: LIGADO'
    } else {
        $lblStatus.Text = '○ Desligado'
        $lblStatus.ForeColor = [System.Drawing.Color]::Gray
        $btnToggle.Text = 'Ligar'
        $miToggle.Text = 'Ligar'
        $notify.Icon = $iconOff
        $form.Icon = $iconOff
        $notify.Text = 'Bluetooth KeepAlive: DESLIGADO'
    }
    if ($script:Enabled -and [bool]$script:Config.Continuous) {
        $lblLast.Text = 'Reprodução contínua ativa'
    } elseif ($script:LastPing -and $script:Enabled) {
        $lblLast.Text = 'Último ping: ' + $script:LastPing.ToString('HH:mm:ss')
    } else {
        $lblLast.Text = ''
    }
}

function Set-Enabled([bool]$on) {
    $script:Enabled = $on
    if ($on) { Start-KeepAlive } else { Stop-KeepAlive }
    Update-Ui
    Log ('estado: ' + $(if ($on) { 'ligado' } else { 'desligado' }))
}

function Show-Window {
    $form.Show()
    $form.WindowState = 'Normal'
    $form.TopMost = $true
    $form.TopMost = $false
    $form.Activate()
}

function Exit-App {
    $script:Quitting = $true
    $timer.Stop()
    try { $player.Stop() } catch {}
    $notify.Visible = $false
    $notify.Dispose()
    [System.Windows.Forms.Application]::Exit()
}

# ----------------------------------------------------------------- eventos
$btnToggle.Add_Click({ Set-Enabled (-not $script:Enabled) })
$btnQuit.Add_Click({ Exit-App })
$btnTray.Add_Click({ $form.Close() })
$chkCont.Add_CheckedChanged({
    $numInterval.Enabled = -not $chkCont.Checked
    $numLength.Enabled = -not $chkCont.Checked
})
$miToggle.Add_Click({ Set-Enabled (-not $script:Enabled) })
$miOpen.Add_Click({ Show-Window })
$miExit.Add_Click({ Exit-App })
$notify.Add_DoubleClick({ Show-Window })

$btnSave.Add_Click({
    $i = [int]$numInterval.Value
    $l = [int]$numLength.Value
    if ((-not [bool]$chkCont.Checked) -and ($l -ge $i)) {
        [System.Windows.Forms.MessageBox]::Show('A duração do ping precisa ser menor que o intervalo.', 'Bluetooth KeepAlive', 'OK', 'Warning') | Out-Null
        return
    }
    $script:Config.IntervalSeconds = $i
    $script:Config.LengthSeconds = $l
    if ($cmbMode.SelectedIndex -eq 1) { $script:Config.Mode = 'near' } else { $script:Config.Mode = 'silent' }
    $script:Config.AutoEnable = [bool]$chkAuto.Checked
    $script:Config.Continuous = [bool]$chkCont.Checked
    Save-Config
    Apply-Audio
    if ($script:Enabled) { Start-KeepAlive; Update-Ui }
    [System.Windows.Forms.MessageBox]::Show('Configurações salvas.', 'Bluetooth KeepAlive', 'OK', 'Information') | Out-Null
})

# Fechar no X só esconde a janela; o programa continua na bandeja
$form.Add_FormClosing({
    param($s, $e)
    if (-not $script:Quitting -and $e.CloseReason -eq [System.Windows.Forms.CloseReason]::UserClosing) {
        $e.Cancel = $true
        $form.Hide()
        if (-not $script:HintShown) {
            $notify.ShowBalloonTip(3000, 'Bluetooth KeepAlive', 'A janela foi para a bandeja e o programa continua rodando. Duplo clique no ícone abre de novo; botão direito liga, desliga ou sai.', [System.Windows.Forms.ToolTipIcon]::Info)
            $script:HintShown = $true
        }
    }
})

# ------------------------------------------------------------------ início
Load-Config
$numInterval.Value = [int]$script:Config.IntervalSeconds
$numLength.Value = [int]$script:Config.LengthSeconds
if ($script:Config.Mode -eq 'near') { $cmbMode.SelectedIndex = 1 } else { $cmbMode.SelectedIndex = 0 }
$chkAuto.Checked = [bool]$script:Config.AutoEnable
$chkCont.Checked = [bool]$script:Config.Continuous
$numInterval.Enabled = -not $chkCont.Checked
$numLength.Enabled = -not $chkCont.Checked

try { Apply-Audio } catch { Log "erro ao preparar áudio: $_" }

$notify.Visible = $true
if ([bool]$script:Config.AutoEnable) { Set-Enabled $true } else { Update-Ui }
Show-Window

$ctx = New-Object System.Windows.Forms.ApplicationContext
[System.Windows.Forms.Application]::Run($ctx)

$script:Mutex.ReleaseMutex()
