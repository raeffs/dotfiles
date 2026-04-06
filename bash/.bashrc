#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
fi

alias mkdir='mkdir -p'
alias ls='ls -lA --color=auto'
alias grep='grep --color=auto'

if command -v btop &> /dev/null; then
  alias top='btop'
fi

# navigation aliases
alias ..='cd ..'

if command -v starship &> /dev/null; then
  eval "$(starship init bash)"
fi

if command -v zoxide &> /dev/null; then
  eval "$(zoxide init --cmd cd bash)"
fi

export PATH="$HOME/.local/bin:$PATH"

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

export PATH="$HOME/Android/Sdk/platform-tools:$PATH"

export PATH="$HOME/.deno/bin:$PATH"
source $HOME/.local/share/bash-completion/completions/deno.bash
