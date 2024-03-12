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
```

## Windows

- Install `winget` from [Microsoft Store](https://learn.microsoft.com/en-us/windows/package-manager/winget/)

```bash
winget install Git.Git
winget install twpayne.chezmoi
```

## Usage

### New Machine

```bash
chezmoi init --apply noahbaculi
```

[Chezmoi User Guide](https://www.chezmoi.io/user-guide/command-overview/)
