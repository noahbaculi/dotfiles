# Set abbreviations
abbr n 'nvim'
abbr gg 'lazygit'

# Functions

## File browse with yazi. Press y to start browsing, press q to quit and change the CWD, press Q to quit without changing the CWD.
function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

# Source
source "$HOME/.cargo/env.fish"
mise activate fish | source
zoxide init fish | source
starship init fish | source
atuin init fish | source

set -gx EDITOR nvim

# Rust ESP32 environment variables
# source "$HOME/export-esp.sh"

