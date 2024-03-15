# dotfiles

Dotfiles for development, etc.

## Linux / WSL

1. Install Fish shell
  
```bash
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt update
sudo apt install fish
```

2. Make Fish shell default

```bash
echo /usr/bin/fish | sudo tee -a /etc/shells
chsh -s /usr/bin/fish

exec $SHELL  # restart shell
```

3. Install Chezmoi

```fish
sh -c "$(curl -fsLS get.chezmoi.io)"
fish_add_path ./bin
fish_add_path ~/.local/bin
fish_add_path ~/.local/share/mise
```

## MacOS

1. Install Fish shell
  
```bash
brew install fish
```

2. Make Fish shell default

```bash
echo /usr/local/bin/fish | sudo tee -a /etc/shells
chsh -s /usr/local/bin/fish

exec $SHELL  # restart shell
```

3. Install Chezmoi

```fish
sh -c "$(curl -fsLS get.chezmoi.io)"
fish_add_path ./bin
fish_add_path ~/.local/bin
fish_add_path ~/.local/share/mise
```

## Windows

- Install `winget` from [Microsoft Store](https://learn.microsoft.com/en-us/windows/package-manager/winget/)

```bash
winget install Git.Git
winget install twpayne.chezmoi
```

## New Machine

```bash
chezmoi init --apply noahbaculi
```

[Chezmoi User Guide](https://www.chezmoi.io/user-guide/command-overview/)


## iOS

1. Download a [Nerd Font](https://www.nerdfonts.com/font-downloads) `.zip` archive locally.
2. Install the [iFont app](https://apps.apple.com/us/app/ifont-find-install-any-font/id1173222289) and install the font from the downloaded archive.
3. Install the [iSH app](https://ish.app/)https://ish.app/) and select the installed Nerd Font in the iSH in-app settings.
4. In iSH, install SSH: `apk add openssh`
5. In iSH, SSH to any host for development 🥳
