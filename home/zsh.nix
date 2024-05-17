{ pkgs, ... }: {
  imports = [
    ./yazi
  ];
  
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "zoxide" "npm" "sudo" "golang" ];
      theme = "robbyrussell";
    };
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # fuzzy find with preview and open in nvim
      fzn = "nvim $(fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}')";
      # fuzzy find with preview
      fzp = "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";
      cat = "bat";
      cd = "z";
    };

    # This extra config loads the secrets file that you can generate on your own.
    # With this you can load env variables with API keys that are sensitive
    # Yes this is circumventing the nix mindset but secrets are hardly specific
    # to your system config, but rather to somebody's elese system's.
    initExtra = ''
      if [ -f ~/.zshsecrets ]; then
          source ~/.zshsecrets
      else
        print "404: ~/.zshsecrets not found."
      fi

      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
      zstyle ':completion:*:git-checkout:*' sort false
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*' menu no
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
      zstyle ':fzf-tab:*' switch-group '<' '>'
    '';

    history = {
      ignoreAllDups = true;
      ignoreDups = true;
      share = true;
    };
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Nord";
    };
  };

  programs.zoxide.enable = true;
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux = {
      enableShellIntegration = true;
    };
  };
  programs.jq.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true; 
  };
}
