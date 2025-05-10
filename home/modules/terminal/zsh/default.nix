{ pkgs, ... }: {
  imports = [
    ./yazi
  ];
  
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ 
        # handy gcan! gco and other shortcuts
        "git"
        # initialize zoxide (later we override cd with z)
        "zoxide"
        # completions for npm and aliases lke npmS
        "npm"
        # press 2x esc to repeat the prev command with sudo
        "sudo"
      ];
      theme = "robbyrussell";
    };
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # fuzzy find with preview and open in nvim
      fzn = "nvim $(fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}')";
      # fuzzy find with preview
      fzp = "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";
      cat = "bat";
      man = "batman";
      cd = "z";
      # git fuzzy branch selector
      gfb = "fzf-git-checkout";
      # github pr find - This needs GITHUB_TOKEN in env with `repo` access for private repos
      ghpr = "(set -e gh pr checkout $(gh pr list | fzf | cut -f1))";
      # github fzf and clone repo
      ghrepo = "gh-fzf-find-repo";

      # custom alias to simplify nix run nixpgks#program
      nr = "nix-runner";

      # If exists map docker compose to dc
      dc = "docker compose";
      # shortcuts
      t = "tmux";
      e = "exit";
    };

    # This extra config loads the secrets file that you can generate on your own.
    # With this you can load env variables with API keys that are sensitive
    # Yes this is circumventing the nix mindset but secrets are hardly specific
    # to your system config, but rather to somebody's elese system's.
    initContent = ''
      if [ -f ~/.zshsecrets ]; then
          source ~/.zshsecrets
      fi
      if [ -f ~/.zshautoload ]; then
          source ~/.zshautoload
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

  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;

  # Add functions to the ~/.zsh/functions folder for autoload
  home.file.".zsh/functions/fzf-git-checkout".source = ./fzf-git-checkout.sh;
  home.file.".zsh/functions/gh-fzf-find-repo".source = ./gh-fzf-find-repo.sh;
  home.file.".zsh/functions/nix-runner".source = ./nix-runner.sh;
  home.file.".zshautoload".source = ./autoload.sh;

  programs.gh = {
    enable = true; 
    settings = {
      git_protocol = "ssh";
    };
  };

  programs.bat = {
    enable = true;
    extraPackages = [ pkgs.bat-extras.batman ];
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
