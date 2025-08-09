# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Load zsh-autocomplete for fuzzy matching (must be before compinit)
source /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# Load Git completion
zstyle ':completion:*:*:git:*' script $HOME/.config/zsh/git-completion.bash
fpath=($HOME/.config/zsh $fpath)

# compinit is now handled by zsh-autocomplete
# autoload -Uz compinit && compinit

# Pipenv
export PIPENV_VENV_IN_PROJECT=1

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)" # Initialize pyenv when a new shell spawns

# Created by `pipx`
export PATH="$PATH:/Users/ajantrania/.local/bin"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Configure Docker socket path for Docker Desktop on macOS
export DOCKER_HOST=unix://${HOME}/.docker/run/docker.sock

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
# Check that the function `starship_zle-keymap-select()` is defined.
# xref: https://github.com/starship/starship/issues/3418
if [[ "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select" || \
      "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select-wrapped" ]]; then
    zle -N zle-keymap-select "";
fi

eval "$(starship init zsh)"
# starship config palette $STARSHIP_THEME

# ------------------------
# Fix Keybindings
#   Option +         Left/Right   - Word Traversal
#   Option + Shift + Left/Right   - Line Traversal
# ------------------------
# WezTerm
bindkey "^[[1;3D" backward-word
bindkey "^[[1;3C" forward-word
bindkey "^[[1;4D" beginning-of-line
bindkey "^[[1;4C" end-of-line
# VSCode Terminal
bindkey "^[b" backward-word
bindkey "^[f" forward-word
bindkey "^[[1;4D" beginning-of-line
bindkey "^[[1;4C" end-of-line

# This section configures shell command history settings:
# - HISTFILE specifies the file where history is saved (~/.zsh_history)
# - HISTFILESIZE/HISTSIZE set maximum number of history entries to 1 billion
# - INC_APPEND_HISTORY makes commands get written to history file immediately
# - HISTTIMEFORMAT adds timestamps to history entries in [YYYY-MM-DD HH:MM:SS] format
# - EXTENDED_HISTORY enables storing timestamps with history entries
# - HIST_FIND_NO_DUPS prevents duplicate entries when searching history
export HISTFILE=~/.zsh_history
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
# Immediate Append
setopt INC_APPEND_HISTORY
export HISTTIMEFORMAT="[%F %T] "
# Timestamps
setopt EXTENDED_HISTORY
# Skip dubs in history search
setopt HIST_FIND_NO_DUPS

# fzf
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_DEFAULT_COMMAND='rg --hidden -l ""' # Include hidden files

bindkey "ç" fzf-cd-widget # Fix for ALT+C on Mac

# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# fh - search in your command history and execute selected command
fh() {
  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# Activate syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Disable underline
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
# Change colors
# export ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=blue
# export ZSH_HIGHLIGHT_STYLES[precommand]=fg=blue
# export ZSH_HIGHLIGHT_STYLES[arg0]=fg=blue

# Activate autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh


# Set default AWS Profile
export AWS_PROFILE=archodex-apurva-AdministratorAccess