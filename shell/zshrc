# Variables
export PATH=$PATH:$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/local/go/bin:$HOME/go/bin:/opt/nvim-linux-x86_64/bin
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="eastwood"
plugins=(git docker sudo)

source $ZSH/oh-my-zsh.sh

# History options
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# Spelling correction
setopt CORRECT

# Aliases
if [ -f ~/.zsh_aliases ]; then
  source ~/.zsh_aliases
fi
