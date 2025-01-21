# zsh Options
setopt HIST_IGNORE_ALL_DUPS

# Custom zsh
[ -f "$HOME/.config/zsh/custom.zsh" ] && source "$HOME/.config/zsh/custom.zsh"

# Aliases
[ -f "$HOME/.config/zsh/aliases.zsh" ] && source "$HOME/.config/zsh/aliases.zsh"

# Work
[ -f "$HOME/.config/zsh/work.zsh" ] && source "$HOME/.config/zsh/work.zsh"
# [ -f "$HOME/.config/zsh/stackery.zsh" ] && source "$HOME/.config/zsh/stackery.zsh"
[ -f "$HOME/.config/zsh/aws.zsh" ] && source "$HOME/.config/zsh/aws.zsh"
[ -f "$HOME/.config/zsh/aws-private.zsh" ] && source "$HOME/.config/zsh/aws-private.zsh"
