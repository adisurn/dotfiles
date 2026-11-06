# ============================================================
# Oh My Zsh
# ============================================================

export ZSH="$HOME/.oh-my-zsh"

# Completions
fpath=("$HOME/completions" $fpath)

# Plugins
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)

source "$ZSH/oh-my-zsh.sh"


# ============================================================
# Shell Integrations
# ============================================================

# Bun completions
[[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"

# Zoxide
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh --cmd cd)"
fi

# FZF
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)

    bindkey '^Z' fzf-cd-widget
fi

# FZF previews
_fzf_comprun() {
    local command="$1"
    shift

    case "$command" in
        cd)
            fzf "$@" \
                --preview 'eza --tree --color=always --level=2 --git --icons {} | head -200'
            ;;
        *)
            fzf "$@" \
                --preview 'bat --color=always --style=numbers --line-range=:500 {}'
            ;;
    esac
}

# Starship
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# GNU dircolors
if command -v gdircolors >/dev/null 2>&1; then
    eval "$(gdircolors)"
fi


# ============================================================
# Shell Options & Keybindings
# ============================================================

# SSH terminal compatibility
ssh() {
    TERM=xterm-256color command ssh "$@"
}


# ============================================================
# Aliases
# ============================================================

# General
alias e="exit"
alias grep="grep --color=auto"

# Go
alias air='$(go env GOPATH)/bin/air'

# Better cat
if command -v bat >/dev/null 2>&1; then
    alias cat="bat"
fi

# Better ls
if command -v eza >/dev/null 2>&1; then
    alias ls="eza --no-filesize --long --color=always --icons=always --no-user"
fi

# Clear and generate a new quote
# Defined after generate_quote below.


# ============================================================
# Startup Eye Candy
# ============================================================

generate_quote() {
    local -a small_animals
    local -a very_small_animals
    local random_cow

    small_animals=(
        alpaca bong bud-frogs bunny cower default
        elephant elephant-in-snake eyes flaming-sheep
        head-in hellokitty kitty koala llama luke-koala
        meow moofasa moose mutilated sheep skeleton
        small supermilker sus three-eyes tux udder
        vader vader-koala www
    )

    very_small_animals=(
        bunny default hellokitty mutilated small
        supermilker three-eyes www
    )

    # Short terminals: use compact output
    if (( LINES < 20 )); then
        fortune -s | lolcrab

    elif (( LINES < 30 )); then
        random_cow=${very_small_animals[$((RANDOM % ${#very_small_animals[@]} + 1))]}
        fortune -s | cowsay -f "$random_cow" 2>/dev/null | lolcrab

    elif (( LINES < 60 )); then
        random_cow=${small_animals[$((RANDOM % ${#small_animals[@]} + 1))]}
        fortune -s | cowsay -f "$random_cow" 2>/dev/null | lolcrab

    else
        fortune | cowsay -r | lolcrab
    fi
}

print_banner() {
    local banner_height_threshold=30

    if (( LINES >= banner_height_threshold )) &&
       command -v fastfetch >/dev/null 2>&1; then
        fastfetch
        echo
    fi

    generate_quote
}

# Startup banner: only when all dependencies exist
if command -v fortune >/dev/null 2>&1 &&
   command -v cowsay >/dev/null 2>&1 &&
   command -v lolcrab >/dev/null 2>&1; then

    print_banner
    alias c="clear && generate_quote"
fi
