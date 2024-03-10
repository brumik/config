# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs, ... }: {
  # find-app = pkgs.callPackage ./find-app-xdotool { };
  # find-app-hyprland = pkgs.callPackage ./find-app-hyprland { };
  bw-setup-secrets = pkgs.callPackage ./bw-setup-secrets { };
}
