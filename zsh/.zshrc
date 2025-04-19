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
if [ "$SYSTEM_TYPE" = "aws-work" ]; then
    [ -f "$HOME/.config/zsh/aws-work.zsh" ] && source "$HOME/.config/zsh/aws-work.zsh"
    [ -f "$HOME/.config/zsh/aws-work-private.zsh" ] && source "$HOME/.config/zsh/aws-work-private.zsh"
elif [ "$SYSTEM_TYPE" = "personal" ]; then
    [ -f "$HOME/.config/zsh/aws-personal.zsh" ] && source "$HOME/.config/zsh/aws-personal.zsh"
fi
