# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"
# zsh Options
setopt HIST_IGNORE_ALL_DUPS

# System identification (must be first)
[ -f "$HOME/.config/zsh/identify-system.zsh" ] && source "$HOME/.config/zsh/identify-system.zsh"

# Custom zsh
[ -f "$HOME/.config/zsh/custom.zsh" ] && source "$HOME/.config/zsh/custom.zsh"

# Aliases
[ -f "$HOME/.config/zsh/aliases.zsh" ] && source "$HOME/.config/zsh/aliases.zsh"

# Work
[ -f "$HOME/.config/zsh/work.zsh" ] && source "$HOME/.config/zsh/work.zsh"
# [ -f "$HOME/.config/zsh/stackery.zsh" ] && source "$HOME/.config/zsh/stackery.zsh"

# AWS work configurations
if [ "$SYSTEM_TYPE" = "archodex-work" ]; then
    [ -f "$HOME/.config/zsh/archodex.zsh" ] && source "$HOME/.config/zsh/archodex.zsh"
elif [ "$SYSTEM_TYPE" = "aws-work" ]; then
    [ -f "$HOME/.config/zsh/aws-work.zsh" ] && source "$HOME/.config/zsh/aws-work.zsh"
    [ -f "$HOME/.config/zsh/aws-work-private.zsh" ] && source "$HOME/.config/zsh/aws-work-private.zsh"
elif [ "$SYSTEM_TYPE" = "personal" ]; then
    [ -f "$HOME/.config/zsh/aws-personal.zsh" ] && source "$HOME/.config/zsh/aws-personal.zsh"
fi
. "$HOME/.config/zsh/add-local-bin.sh"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/ajantrania/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
