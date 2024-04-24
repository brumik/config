{ ... }: {
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "zoxide" ];
      theme = "robbyrussell";
    };
    enableCompletion = true;
    enableAutosuggestions = false;

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
    '';
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Nord";
    };
  };

  programs.zoxide.enable = true;
  programs.fzf.enable = true;
  programs.jq.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true; 
  };
}
