# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs, ... }: {
  # the find app is hyprland specific as it is using its own ctl tool
  find-app = pkgs.callPackage ./find-app { };
}
