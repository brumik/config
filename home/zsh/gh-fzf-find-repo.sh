#!/usr/bin/env zsh

gh-fzf-find-repo() {
  local repo 
  repo=$(gh search repos $1 | fzf | cut -f1)

  if [[ "$repo" = "" ]]; then
      echo "No repo selected."
      return
  fi

  # cd back and forth so we do not need to parse the repo name
  cd ~/Documents && gh repo clone "$repo" && cd -
}

gh-fzf-find-repo $@
