#!/bin/bash

# macOS dotfiles bootstrapper.
# Run from the cloned dotfiles repository, or run this file from anywhere;
# if no local Brewfile is found, the repository is cloned to ~/dotfiles.

set -Eeuo pipefail

# -----------------------------------------------------------------------------
# Configuration
# Override these when running the script if needed:
#   DOTFILES_REPO=https://github.com/you/dotfiles.git ./install.sh
#   DOTFILES_DIR="$HOME/config" ./install.sh
#   UPDATE_DOTFILES=0 ./install.sh
# -----------------------------------------------------------------------------

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/Adisurn/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
UPDATE_DOTFILES="${UPDATE_DOTFILES:-1}"

SBARLUA_REPO="https://github.com/hajiboy95/SbarLua.git"
SBARLUA_REF="fix/reentrant-transactions"
SBAR_LUA_DIR="$HOME/.local/share/sketchybar_lua"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
    printf '\n\033[1;36m==> %s\033[0m\n' "$1"
}

success() {
    printf '\033[1;32m✓ %s\033[0m\n' "$1"
}

warn() {
    printf '\033[1;33m! %s\033[0m\n' "$1" >&2
}

error() {
    printf '\033[1;31m✗ %s\033[0m\n' "$1" >&2
}

on_error() {
    local exit_code=$?
    error "Command failed at line ${BASH_LINENO[0]:-unknown} (exit ${exit_code})."
    exit "$exit_code"
}
trap on_error ERR

# -----------------------------------------------------------------------------
# Platform and Xcode Command Line Tools
# -----------------------------------------------------------------------------

log "Checking macOS prerequisites"

if [[ "$(uname -s)" != "Darwin" ]]; then
    error "This installer is intended for macOS."
    exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
    log "Installing Xcode Command Line Tools"
    xcode-select --install || true
    echo "Complete the Xcode Command Line Tools installation dialog, then rerun this script."
    exit 0
fi

success "Xcode Command Line Tools are installed"

# -----------------------------------------------------------------------------
# Homebrew installation and initialization
# -----------------------------------------------------------------------------

log "Checking Homebrew"

if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Initialize Homebrew for this script process. This handles both Apple Silicon
# (/opt/homebrew) and Intel (/usr/local) installations.
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
else
    error "Homebrew was not found after installation."
    exit 1
fi

success "Homebrew is ready: $(brew --version | head -n 1)"
brew analytics off

# -----------------------------------------------------------------------------
# Get dotfiles before installing the Brewfile
# -----------------------------------------------------------------------------

log "Preparing dotfiles repository"

# When this script is run from inside a cloned repository, use that repository.
# Otherwise, use (or clone) $DOTFILES_DIR.
if [[ -f "$SCRIPT_DIR/Brewfile" ]]; then
    DOTFILES_DIR="$SCRIPT_DIR"
    if [[ "$UPDATE_DOTFILES" == "1" && -d "$DOTFILES_DIR/.git" ]]; then
        git -C "$DOTFILES_DIR" pull --ff-only
    fi
elif [[ -d "$DOTFILES_DIR/.git" ]]; then
    if [[ "$UPDATE_DOTFILES" == "1" ]]; then
        git -C "$DOTFILES_DIR" pull --ff-only
    fi
elif [[ ! -e "$DOTFILES_DIR" ]]; then
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    error "$DOTFILES_DIR exists but is not a Git repository. Move it or set DOTFILES_DIR to another path."
    exit 1
fi

if [[ ! -f "$DOTFILES_DIR/Brewfile" ]]; then
    error "Brewfile not found at $DOTFILES_DIR/Brewfile."
    exit 1
fi

success "Dotfiles repository ready at $DOTFILES_DIR"

# -----------------------------------------------------------------------------
# Homebrew packages
# -----------------------------------------------------------------------------

log "Updating Homebrew metadata"
brew update

log "Installing packages from Brewfile"
# --no-upgrade makes rerunning the bootstrap safer: it installs missing
# dependencies without upgrading every existing package on the machine.
brew bundle install --no-upgrade --file="$DOTFILES_DIR/Brewfile"

success "Homebrew dependencies are installed"

# nvm's Homebrew formula expects this directory to exist. Its shell initialization
# is added idempotently after Stow has deployed ~/.zshrc.
mkdir -p "$HOME/.nvm"

# -----------------------------------------------------------------------------
# SbarLua module for SketchyBar
# -----------------------------------------------------------------------------

log "Checking SbarLua"

if [[ -d "$SBAR_LUA_DIR" ]]; then
    success "SbarLua directory already exists at $SBAR_LUA_DIR"
else
    TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sbarlua.XXXXXX")"

    if git clone "$SBARLUA_REPO" "$TMP_DIR/SbarLua" &&
       git -C "$TMP_DIR/SbarLua" checkout "$SBARLUA_REF" &&
       make -C "$TMP_DIR/SbarLua" install; then
        if [[ -d "$SBAR_LUA_DIR" ]]; then
            success "SbarLua installed at $SBAR_LUA_DIR"
        else
            warn "SbarLua install command succeeded, but $SBAR_LUA_DIR was not created. Check the upstream install target."
        fi
    else
        warn "SbarLua installation failed. Continuing with the remaining setup."
    fi

    rm -rf "$TMP_DIR"
fi

# -----------------------------------------------------------------------------
# Compile the SketchyBar menus helper
# -----------------------------------------------------------------------------

log "Compiling SketchyBar menus helper"

MENU_HELPER_DIR="$DOTFILES_DIR/.config/sketchybar/helpers/menus"

if [[ -d "$MENU_HELPER_DIR" && ( -f "$MENU_HELPER_DIR/Makefile" || -f "$MENU_HELPER_DIR/makefile" ) ]]; then
    if make -C "$MENU_HELPER_DIR"; then
        if [[ -x "$MENU_HELPER_DIR/bin/menus" ]]; then
            success "SketchyBar menus helper compiled"
        else
            warn "The make command succeeded, but bin/menus is missing or not executable."
        fi
    else
        warn "Could not compile the menus helper. Continuing with the remaining setup."
    fi
else
    warn "No Makefile found in $MENU_HELPER_DIR; skipping menus helper compilation."
fi

# -----------------------------------------------------------------------------
# Script permissions
# -----------------------------------------------------------------------------

log "Setting SketchyBar script permissions"

SKETCHYBAR_DIR="$DOTFILES_DIR/.config/sketchybar"

if [[ -d "$SKETCHYBAR_DIR" ]]; then
    find "$SKETCHYBAR_DIR" -type f -name '*.sh' -exec chmod +x {} +
    success "SketchyBar shell scripts are executable"
else
    warn "SketchyBar config directory not found at $SKETCHYBAR_DIR"
fi

# -----------------------------------------------------------------------------
# GNU Stow
# -----------------------------------------------------------------------------

log "Stowing dotfiles"

# This assumes the repository root is your Stow package, matching the original
# layout where `stow --restow .` was used. Ignore bootstrap/metadata files so
# they are not linked into $HOME.
stow \
    --target="$HOME" \
    --restow \
    --ignore='^(Brewfile|install\.sh|README(\..*)?|LICENSE(\..*)?|\.gitignore)$' \
    .

success "Dotfiles stowed"

# -----------------------------------------------------------------------------
# Oh My Zsh
# -----------------------------------------------------------------------------

log "Checking Oh My Zsh"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing Oh My Zsh..."
    # --keep-zshrc is important: Stow may have just linked the repository's
    # ~/.zshrc, and the Oh My Zsh installer must not replace that managed file.
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
else
    success "Oh My Zsh is already installed"
fi

# -----------------------------------------------------------------------------
# Persist Homebrew, GNU Coreutils, and NVM shell initialization
# -----------------------------------------------------------------------------

log "Configuring Zsh environment"

# These updates are idempotent. If a profile is managed by Stow, appending to the
# symlink updates the tracked dotfile itself, which is the intended source of truth.
ZPROFILE="$HOME/.zprofile"
ZSHRC="$HOME/.zshrc"
BREW_SHELLENV_LINE='eval "$(/opt/homebrew/bin/brew shellenv)"'
if [[ "$(brew --prefix)" == "/usr/local" ]]; then
    BREW_SHELLENV_LINE='eval "$(/usr/local/bin/brew shellenv)"'
fi

if [[ ! -e "$ZPROFILE" ]]; then
    touch "$ZPROFILE"
fi
if ! grep -Fqx "$BREW_SHELLENV_LINE" "$ZPROFILE"; then
    {
        printf '\n# Homebrew environment (added by dotfiles installer)\n'
        printf '%s\n' "$BREW_SHELLENV_LINE"
    } >> "$ZPROFILE"
fi

if [[ -f "$ZSHRC" ]]; then
    if ! grep -Fq 'coreutils/libexec/gnubin' "$ZSHRC"; then
        {
            printf '\n# GNU Coreutils (added by dotfiles installer)\n'
            printf '%s\n' 'export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"'
        } >> "$ZSHRC"
    fi

    if ! grep -Fq 'NVM_DIR="$HOME/.nvm"' "$ZSHRC"; then
        cat >> "$ZSHRC" <<'ZSH_CONFIG'

# NVM (Homebrew)
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"
ZSH_CONFIG
    fi
else
    warn "~/.zshrc was not found; add the GNU Coreutils and NVM initialization to your Zsh config if you use them."
fi

success "Zsh environment configured"

# -----------------------------------------------------------------------------
# macOS defaults
# -----------------------------------------------------------------------------

log "Applying macOS defaults"

defaults write com.apple.dock autohide -bool true
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15
defaults write com.apple.dock expose-group-apps -bool true
defaults write com.apple.spaces spans-displays -bool true

killall Dock >/dev/null 2>&1 || true
success "macOS defaults applied (some changes may require logout/restart)"

# -----------------------------------------------------------------------------
# Start SketchyBar
# -----------------------------------------------------------------------------

log "Starting SketchyBar"

if brew list --formula sketchybar >/dev/null 2>&1; then
    brew services start sketchybar
    success "SketchyBar service started"
else
    warn "SketchyBar formula is not installed; skipping service startup."
fi

log "Installation complete"
echo "Dotfiles: $DOTFILES_DIR"
echo "Brewfile: $DOTFILES_DIR/Brewfile"
echo "You may need to open a new terminal session for shell changes to take effect."
