{ username }: { pkgs, ... }:
{
  home.packages = [
    pkgs.just
  ];

  imports = [
    (import ./git { inherit username; })
    ./zsh
    ./nvim
    ./tmux
    ./alacritty.nix
    ./kitty.nix
    ./pet.nix
  ];
}
