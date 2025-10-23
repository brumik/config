alias dc="docker compose"
alias t="tmux new-session -A -s main"
alias sa='source ~/.zshrc;echo "ZSH aliases sourced."'

# git
alias ggpush="git push"
alias ggpull="git pull"
alias gc="git commit"
alias gcan!="git commit --amend -n --no-edit"
alias gst="git status"
alias gco="git checkout"


# generic
alias la="ls -la"
alias ll="ls -l"

# nvim
alias vi="nvim"
alias vim="nvim"

# load starship (slow)
#eval "$(starship init zsh)"

# Own prompt alternative
autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats '[%b] '

setopt PROMPT_SUBST
PROMPT='%F{blue}%~%f %F{red}${vcs_info_msg_0_}%f'

# Basic history and completion setup
autoload -U compinit; compinit

# Set the up and down arrows to SEARCH and not just go through history
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

# History settings:
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt share_history

# Load all ssh keys
ssh-add --apple-use-keychain ~/.ssh/id_ed25519 &> /dev/null
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_mm &> /dev/null
