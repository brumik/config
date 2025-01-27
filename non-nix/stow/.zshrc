alias dc="docker compose"
alias t="tmux new-session -A -s main"

# git
alias ggpush="git push"
alias ggpull="git pull"
alias gc="git commit"
alias gcan!="git commit --amend -n --no-edit"
alias gst="git status"

# generic
alias la="ls -la"
alias ll="ls -l"

# nvim
alias vi="nvim"
alias vim="nvim"

# load starship
eval "$(starship init zsh)"
