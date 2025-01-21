# Git
alias g='git'
alias ga='git add'
alias gf='git fetch'
alias gs='git status'

alias grepi='grep -i' 						# Case insensenstive grep
alias grepr='grep -r' 						# Recursive grep
alias ls='ls -GFh'
alias ll='ls -FGlAhp'
alias f='open -a Finder ./'                 # f:            Opens current directory in MacOS Finder
alias c='clear'                             # c:            Clear terminal display
mkcd () { mkdir -p "$1" && cd "$1"; }  		  # mkcd: 		    Makes new directory and jumps inside
alias notify='afplay /System/Library/Sounds/Sosumi.aiff'
alias e="code -n"
alias resource="source ~/.zshrc"