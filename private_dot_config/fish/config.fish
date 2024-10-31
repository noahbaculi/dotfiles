# Set abbreviations
abbr n 'nvim'
abbr gg 'lazygit'

# Functions

if status --is-interactive
    # Source
    source "$HOME/.cargo/env.fish"
    mise activate fish | source
    zoxide init fish | source
    starship init fish | source
    atuin init fish | source
end

# Rust ESP32 environment variables
# source "$HOME/export-esp.sh"
