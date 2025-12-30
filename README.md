# dotfiles

Dotfiles for development and everyday use.

## Linux / WSL

1. Install [Fish shell](https://fishshell.com/)

2. Make Fish shell default

```bash
echo /usr/bin/fish | sudo tee -a /etc/shells
chsh -s /usr/bin/fish

exec $SHELL  # restart shell
```

3. Install [GitHub CLI](https://github.com/cli/cli/blob/trunk/docs/install_linux.md)

Authenticate

> I have been using SSH lately

```bash
gh auth login
```

4. Install Chezmoi

```fish
sh -c "$(curl -fsLS get.chezmoi.io)"
fish_add_path ./bin
mkdir ~/.local/bin
fish_add_path ~/.local/bin
mkdir ~/.local/share/mise
fish_add_path ~/.local/share/mise
```

## MacOS

1. Install [Homebrew](https://brew.sh/)

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Install Fish shell

```bash
brew install fish
```

3. Make Fish shell default

```bash
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish

exec $SHELL  # restart shell
```

4. Set Development Environment Flag for Chezmoi

Indicates whether this is a development environment that requires Rust, Python, etc.

```shell
echo -e "[data]\ndev_env = true" > ~/.config/chezmoi/chezmoi.toml
```

4. Install Chezmoi

```fish
sh -c "$(curl -fsLS get.chezmoi.io)"
fish_add_path ./bin
fish_add_path ~/.local/bin
fish_add_path ~/.local/share/mise
fish_add_path .cargo/bin
fish_add_path /opt/homebrew/bin
```

To automount an SMB share, try [these instructions](https://www.reddit.com/r/MacOS/comments/1boyxko/comment/lzi97eb/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button).

# Windows

- Install `winget` from [Microsoft Store](https://learn.microsoft.com/en-us/windows/package-manager/winget/)

```bash
winget install Git.Git
winget install twpayne.chezmoi
```

## New Machine

Run these commands, restarting the terminal in between runs, until the settings are applied. It takes at least a few times through for all the config files to take.

```bash
chezmoi init --apply noahbaculi
```

[Chezmoi User Guide](https://www.chezmoi.io/user-guide/command-overview/)

## Enable SSH from WSL

1. Enable SSH from within WSL.
2. Confirm that WSL can be connected to via SSH on the same computer: `ssh [wsl_username]@localhost`
3. From another computer, the WSL instance can be connected with the following chain (jump) command:

```bash
ssh -J [windows_username]@[windows_destination] [wsl_username]@localhost
```

> Note that the WSL usernames should be unique across all the network WSL usernames with SSH enabled to avoid collisions.

## Linux Customization

### Enable UncomplicatedFirewall

```bash
sudo apt install ufw
sudo apt enable ufw
```

### Enable SSH

```bash
sudo apt install openssh-server
sudo systemctl enable ssh
sudo ufw limit 22/tcp comment "SSH"  # Limit SSH port 22 through the firewall

sudo systemctl status ssh
sudo ufw status numbered
```

### Enable Samba File Sharing

[Samba Ubuntu guide](https://ubuntu.com/tutorials/install-and-configure-samba)

### Enable Plex Remote Access

> Must manually specify port `32400` in Plex settings.

```bash
sudo ufw allow 32400/tcp comment "Plex"  # Allow Plex port through the firewall
sudo ufw status numbered
```

### Disable touchpad tap to drag feature on Cinnamon

```shell
gsettings set org.cinnamon.desktop.peripherals.touchpad tap-and-drag false;
```

Source: [Linux Mint Forum](https://forums.linuxmint.com/viewtopic.php?t=354384)

### Add support for 8BitDo Ultimate controller

```bash
printf "ACTION==\"add\", ATTRS{idVendor}==\"2dc8\", ATTRS{idProduct}==\"3106\", RUN+=\"/sbin/modprobe xpad\", RUN+=\"/bin/sh -c 'echo 2dc8 3106 > /sys/bus/usb/drivers/xpad/new_id'\"" | sudo tee /etc/udev/rules.d/99-8bitdo-xinput.rules
sudo udevadm control --reload
```

Source: [Linux Mint Forum](https://forums.linuxmint.com/viewtopic.php?t=404318) & [Gist](https://gist.github.com/ammuench/0dcf14faf4e3b000020992612a2711e2)

## iOS

> Note that many system-level keymaps are not supported. (CAPSLOCK -> ESC)

1. Download a [Nerd Font](https://www.nerdfonts.com/font-downloads) `.zip` archive locally.
2. Install the [iFont app](https://apps.apple.com/us/app/ifont-find-install-any-font/id1173222289) and install the font from the downloaded archive.
3. Install the [iSH app](https://ish.app/)https://ish.app/) and select the installed Nerd Font in the iSH in-app settings.
4. In iSH, install SSH: `apk add openssh`
5. In iSH, SSH to any host for development 🥳
