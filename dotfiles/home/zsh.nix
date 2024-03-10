{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "zoxide" ];
      theme = "robbyrussell";
    };

    shellAliases = {
      # fuzzy find with preview and open in nvim
      fzn = "nvim $(fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}')";
      # fuzzy find with preview
      fzp = "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";
      cat = "bat";
    };
  };

  home.packages = with pkgs; [
    fzf
    zoxide
    bat
    jq
  ];
}
