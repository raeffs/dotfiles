#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias mkdir='mkdir -p'
alias ls='ls -lA --color=auto'
alias grep='grep --color=auto'

# navigation aliases
alias ..='cd ..'

if command -v starship &> /dev/null; then
  eval "$(starship init bash)"
fi

if command -v zoxide &> /dev/null; then
  eval "$(zoxide init --cmd cd bash)"
fi
