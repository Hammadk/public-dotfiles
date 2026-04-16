# Path to your oh-my-zsh installation.
export ZSH="/Users/hammad/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load?
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# Preferred editor for local and remote sessions
export VISUAL='vim'
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR="open -a RubyMine"
fi

PROMPT="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT+=' %{$fg[cyan]%}%(5~|%-1~/…/%3~|%4~)%{$reset_color%} $(git_prompt_info)'

[[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)

export PATH="/Applications/RubyMine.app/Contents/MacOS:$PATH"
export PATH="/Applications/IntelliJ IDEA.app/Contents/MacOS:$PATH"
alias vimc='vim -p `git status --porcelain | sed s/^...//`'

alias be='bundle exec'
alias bi='bundle install'

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

eval "$(atuin init zsh)"

eval "$(ruby ~/.local/try.rb init ~/src/tries)"

[[ -f ~/.zshrc.private ]] && source ~/.zshrc.private
