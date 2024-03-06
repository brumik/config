{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "zoxide" ];
      theme = "robbyrussell";
    };

    shellAliases = {
      fzn = "nvim $(fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}')";
      cat = "bat";
    };
  };

  home.packages = with pkgs; [
    fzf
    zoxide
    bat
  ];
}
