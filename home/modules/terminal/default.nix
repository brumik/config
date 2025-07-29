{ pkgs, ... }:
{
  home.packages = [
    pkgs.just
    pkgs.tree
  ];

  imports = [
    ./zsh
    ./nvim
    ./tmux
    ./kitty.nix
    ./pet.nix
    ./hx.nix
  ];
}
