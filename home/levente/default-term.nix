{ username }:
{ pkgs, ... }:
let
  everforest = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "everforest";
    # postInstall = ''
    #   sed -i -e 's|''${PLUGIN_DIR}/everforest-dark-hard.tmuxtheme|''${TMUX_TMPDIR}/everforest-dark-hard.tmuxtheme|g' $target/everforest.tmux
    # '';
    version = "1.0";
    src = pkgs.fetchFromGitHub {
      owner = "donwlewis";
      repo = "everforest-tmux";
      rev = "main"; # or a specific commit hash
      sha256 =
        "sha256-d3PdA+OxgIgwRJcBykYR+bKmWVepM0ValwLfLBflLeI="; # replace with real hash
    };
  };
in {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  home.packages = [
    pkgs.just
    pkgs.tree
    pkgs.opencode
  ];

  imports = [
    ./git.nix
    ../modules/sops.nix
    ../modules/terminal/zsh
    ../modules/terminal/nvim
    ../modules/terminal/tmux
    ../modules/terminal/pet.nix
  ];

  # Nvim
  programs.nixvim.colorschemes.everforest = {
    enable = true;
    settings.background = "hard";
  };

  programs.tmux = {
    plugins = [ everforest ];
  };
}
