{ username }: { ... }:
{
  imports = [
    (import ./git { inherit username; })
    ./zsh
    ./nvim
    ./tmux
    ./alacritty
    ./pet.nix
  ];
}
