# Bluetooth KeepAlive (versão com interface)

🌐 [English](README.md) · **Português (Brasil)**

Impede que a caixa de som Bluetooth entre em repouso ou desconecte no Windows,
tocando um áudio silencioso de tempos em tempos. Tem uma **janela própria** onde
você liga/desliga e ajusta tudo.

- **Não inicia com o Windows** — só roda quando você abre.
- Não precisa de permissão de administrador.
- Nada de rede ou coleta de dados: só toca um WAV local pela saída de áudio padrão.

## Como usar

1. Baixe/clone o repositório.
2. Dê dois cliques em `Instalar.cmd` (copia para `%LOCALAPPDATA%` e cria um atalho na Área de Trabalho).
   - Ou, sem instalar: dois cliques em `KeepAlive.vbs`.
3. Abre a janela do programa. Nela você:
   - **Liga / Desliga** com o botão grande;
   - ajusta o **intervalo** entre pings (padrão 30 s), a **duração** de cada ping (padrão 2 s) e o **modo de áudio** (silêncio total ou quase silencioso);
   - escolhe se quer **ligar automaticamente ao abrir o programa** (padrão: desmarcado, ou seja, abre desligado);
   - clica em **Salvar configurações** para aplicar.
4. Fechar a janela no **X** não encerra o programa: ele fica na bandeja (perto do relógio, talvez dentro da setinha `^`).
   O ícone serve só para reabrir a janela (duplo clique) ou sair (botão direito → Sair).
   Para encerrar de vez, use o botão **Encerrar programa** na janela.

> A caixa Bluetooth precisa estar selecionada como saída de áudio do Windows
> (Configurações → Sistema → Som → Saída).

## Se a caixa ainda desliga

- Reduza o intervalo para 15 s.
- Teste o modo "Quase silencioso".

## Desinstalar

Dois cliques em `Desinstalar.cmd`.

## Arquivos

Config e log ficam em `%LOCALAPPDATA%\BluetoothKeepAliveGUI`.

## Créditos e licença

Ideia inspirada em [MamunKhan71/bluetooth-speaker-keepalive-windows](https://github.com/MamunKhan71/bluetooth-speaker-keepalive-windows) (Md. Mamun, licença MIT),
que é um instalador sem interface. Esta versão é uma reimplementação em PowerShell/WinForms.
Licença MIT — veja `LICENSE`.
