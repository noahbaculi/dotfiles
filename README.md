# dotfiles

Dotfiles for development and everyday use.

## New Machine Setup

### macOS and Linux

On macOS, install the Command Line Tools first and wait for the dialog to finish. Chezmoi needs `git` to clone this repo before any script runs, and Homebrew, cargo, and pgrx need the compiler and linker from the same package:

```sh
xcode-select --install
```

One command does the rest. It installs Homebrew (macOS), Fish, mise, and everything else this repo manages, then makes Fish the login shell:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply noahbaculi
```

The command pauses once to register an SSH key with GitHub. Chrome opens the page with the key already on the clipboard. Press Enter after saving it. Expect three password prompts on macOS: Homebrew's sudo, the `/etc/shells` sudo (usually still cached), and `chsh`. `-b` puts the `chezmoi` binary in `~/.local/bin`, which `config.fish` adds to `PATH`.

Only Apple Silicon Macs are covered. Homebrew lives under `/usr/local` on Intel and the scripts hardcode `/opt/homebrew`.

### Windows

See [Platform Prerequisites](#platform-prerequisites), then:

```bash
winget install twpayne.chezmoi
chezmoi init --apply noahbaculi
```

### Machine Trait Flags

`chezmoi init` prompts once per machine for three trait flags and stores the answers in `~/.config/chezmoi/chezmoi.toml`. Re-running `init` only asks for flags the machine is missing.

| Flag      | Question it answers              | What it gates                                                                                                                                                                               |
| --------- | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `dev_env` | Do I write code here?            | Rust via rustup, dev mise tools, Claude Code configuration (`.claude/`), agentic skill sources in `~/.agents/`, the shared `AGENTS.md` plus Crush, Maki, Opencode, and ccstatusline configs |
| `gui`     | Does it have a display?          | Coding fonts (Maple Mono, Monaspace) on Linux; macOS always installs them                                                                                                                   |
| `work`    | Is this an EnterpriseDB machine? | Excludes the personal `.claude/settings.json`, installs the opencode `workflow-guards` plugin and its tests, and adds the EnterpriseDB section to `AGENTS.md`                               |

For non-interactive setup, pass the answers as flags:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply noahbaculi --promptBool dev_env=true --promptBool gui=true --promptBool work=true
```

Flipping `dev_env` to `false` removes previously-installed agentic tooling under `~/.agents`, `~/.claude`, and the matching entries under `~/.config/` on the next `chezmoi apply`.

### After Setup

1. Open a new terminal. It should start in Fish without errors.
2. Authenticate GitHub CLI and pick SSH, so private clones do not default to HTTPS:

> I have been using SSH lately

```bash
gh auth login
```

3. Check the rest:

- Development tools (if `dev_env = true`) are accessible: `rustc --version`, `mise --version`
- The `.claude/` directory exists in your home directory (if `dev_env = true`)
- Your terminal prompt and shell configuration match the expected appearance

## Platform Prerequisites

### Windows

- Install `winget` from [Microsoft Store](https://learn.microsoft.com/en-us/windows/package-manager/winget/)

```bash
winget install Git.Git
```

## Chezmoi Usage

[Chezmoi User Guide](https://www.chezmoi.io/user-guide/command-overview/)

## Device-Specific Setup

### Enable SSH from WSL

1. Enable SSH from within WSL.
2. Confirm that WSL can be connected to via SSH on the same computer: `ssh [wsl_username]@localhost`
3. From another computer, the WSL instance can be connected with the following chain (jump) command:

```bash
ssh -J [windows_username]@[windows_destination] [wsl_username]@localhost
```

> Note that the WSL usernames should be unique across all the network WSL usernames with SSH enabled to avoid collisions.

### Linux Customization

#### Enable UncomplicatedFirewall

```bash
sudo apt install ufw
sudo apt enable ufw
```

#### Enable SSH

```bash
sudo apt install openssh-server
sudo systemctl enable ssh
sudo ufw limit 22/tcp comment "SSH"  # Limit SSH port 22 through the firewall

sudo systemctl status ssh
sudo ufw status numbered
```

#### Enable Samba File Sharing

[Samba Ubuntu guide](https://ubuntu.com/tutorials/install-and-configure-samba)

#### Enable Plex Remote Access

> Must manually specify port `32400` in Plex settings.

```bash
sudo ufw allow 32400/tcp comment "Plex"  # Allow Plex port through the firewall
sudo ufw status numbered
```

#### Disable touchpad tap to drag feature on Cinnamon

```shell
gsettings set org.cinnamon.desktop.peripherals.touchpad tap-and-drag false;
```

Source: [Linux Mint Forum](https://forums.linuxmint.com/viewtopic.php?t=354384)

#### Add support for 8BitDo Ultimate controller

```bash
printf "ACTION==\"add\", ATTRS{idVendor}==\"2dc8\", ATTRS{idProduct}==\"3106\", RUN+=\"/sbin/modprobe xpad\", RUN+=\"/bin/sh -c 'echo 2dc8 3106 > /sys/bus/usb/drivers/xpad/new_id'\"" | sudo tee /etc/udev/rules.d/99-8bitdo-xinput.rules
sudo udevadm control --reload
```

Source: [Linux Mint Forum](https://forums.linuxmint.com/viewtopic.php?t=404318) & [Gist](https://gist.github.com/ammuench/0dcf14faf4e3b000020992612a2711e2)

### macOS SMB Automount

To automount an SMB share, try [these instructions](https://www.reddit.com/r/MacOS/comments/1boyxko/comment/lzi97eb/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button).

### iOS

> Note that many system-level keymaps are not supported. (CAPSLOCK -> ESC)

1. Download a [Nerd Font](https://www.nerdfonts.com/font-downloads) `.zip` archive locally.
2. Install the [iFont app](https://apps.apple.com/us/app/ifont-find-install-any-font/id1173222289) and install the font from the downloaded archive.
3. Install the [iSH app](https://ish.app/) and select the installed Nerd Font in the iSH in-app settings.
4. In iSH, install SSH: `apk add openssh`
5. In iSH, SSH to any host for development 🥳

## Development

CI checks markdown formatting with [prettier](https://prettier.io) and Lua formatting with [stylua](https://github.com/JohnnyMorganz/StyLua).

A committed pre-commit hook at `.githooks/pre-commit` enforces the same checks locally. Activation is automatic on the first `cd` into the worktree if [mise](https://mise.jdx.dev) is installed and its shell integration is loaded — `mise.toml`'s `[hooks].enter` points `core.hooksPath` at `.githooks`. Each worktree has its own `.git/config`, so this fires per worktree.

Manual activation (or for environments without mise's shell integration):

```bash
mise run setup
# or, without mise:
git config core.hooksPath .githooks
```

Other useful tasks:

```bash
mise run lint   # same checks the hook and CI run
mise run fmt    # auto-fix what `mise run lint` would flag
```

Fix individual violations with `npx prettier --write <file>` or `stylua <file>`.
