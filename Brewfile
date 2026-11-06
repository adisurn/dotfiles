# Homebrew bundle for this macOS dotfiles setup.
# Install with: brew bundle install --file="$(dirname "$0")/Brewfile"

# -----------------------------------------------------------------------------
# Third-party taps
# Trust only the package entries that this Brewfile needs from each tap.
# homebrew/cask-fonts is intentionally omitted: font casks now live in homebrew/cask.
# -----------------------------------------------------------------------------

tap "anomalyco/tap", trusted: { formula: "opencode" }
tap "felixkratz/formulae", trusted: { formula: "sketchybar" }
tap "kiwicanopy/tap", trusted: { cask: "kiwidesk" }
tap "oven-sh/bun", trusted: { formula: "bun" }
tap "th0jensen/fff-gpui", trusted: { formula: "fff-gpui" }

# -----------------------------------------------------------------------------
# Formulae — command-line tools and development
# -----------------------------------------------------------------------------

# Core utilities
brew "coreutils"
brew "bash"
brew "bat"
brew "eza"
brew "zoxide"
brew "stow"
brew "make"
brew "git"
brew "gh"
brew "starship"
brew "fastfetch"
brew "ifstat"
brew "fzf"
brew "fortune"
brew "cowsay"
brew "lolcrab"

# Zsh plugins
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# macOS / SketchyBar utilities
brew "lua"
brew "luarocks"
brew "luacheck"
brew "media-control"
brew "switchaudio-osx"
brew "felixkratz/formulae/sketchybar"
brew "malpern/tap/sketchybar-toggle"

# File finder and AI coding tools
brew "th0jensen/fff-gpui/fff-gpui"
brew "anomalyco/tap/opencode"

# Development toolchains
brew "node"
brew "nvm"
brew "yarn"
brew "pnpm"
brew "oven-sh/bun/bun"
brew "sqlite"
brew "rust"
brew "go"
brew "python"
brew "uv"

# -----------------------------------------------------------------------------
# Casks — applications
# -----------------------------------------------------------------------------

cask "raycast"
cask "ghostty"
cask "keka"
cask "kekaexternalhelper"
cask "obsidian"
cask "super-productivity"
cask "alt-tab"
cask "zen"
cask "vesktop"
cask "zed@preview"
cask "appcleaner"
cask "figma"
cask "claude-code"
cask "ngrok"
cask "linearmouse"
cask "betterdisplay"
cask "tailscale-app"
cask "spotify"

# KiwiDesk requires macOS 14+ and Apple silicon.
cask "kiwicanopy/tap/kiwidesk" if Hardware::CPU.arm?

# Fonts and Apple design tools
cask "font-jetbrains-mono-nerd-font"
cask "font-jetbrains-mono"
cask "font-hack-nerd-font"
cask "sf-symbols"
