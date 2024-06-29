#!/usr/bin/env zsh

fzf-git-branch() {
    # shellcheck disable=SC2016
    git branch --color=always --all --sort=-committerdate | \
        fzf --height 50% --ansi --no-multi --preview-window right:65% \
        --preview 'git log -n 25 --color --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit $(sed "s/.* //" <<< {})' | \
        sed "s/.* //"
}

fzf-git-checkout() {
    local branch

    branch=$(fzf-git-branch)
    if [[ "$branch" = "" ]]; then
        echo "No branch selected."
        return
    fi

    # If branch name starts with 'remotes/' then it is a remote branch. By
    # using --track and a remote branch name, it is the same as:
    # git checkout -b branchName --track origin/branchName
    if [[ "$branch" = 'remotes/'* ]]; then
        git checkout --track $branch
    else
        git checkout $branch;
    fi
}

fzf-git-checkout $@
