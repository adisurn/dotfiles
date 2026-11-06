# ============================================================
# Environment
# ============================================================

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Homebrew
export HOMEBREW_NO_ENV_HINTS=1

if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ============================================================
# PATH
# ============================================================

# Keep PATH entries unique
typeset -U PATH

# User binaries
export PATH="$HOME/.local/bin:$PATH"

# GNU Coreutils
if [[ -d /opt/homebrew/opt/coreutils/libexec/gnubin ]]; then
    export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
fi

# Go
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# ============================================================
# Development Environments
# ============================================================

# Node Version Manager
export NVM_DIR="$HOME/.nvm"

if [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]]; then
    source "/opt/homebrew/opt/nvm/nvm.sh"
fi

# ============================================================
# Applications
# ============================================================

# Editors
export EDITOR="zed"
export VISUAL="zed"

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Vite+
if [[ -f "$HOME/.config/vite-plus/env" ]]; then
    source "$HOME/.config/vite-plus/env"
fi