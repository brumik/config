# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs, inputs, ... }: {
  # find-app = pkgs.callPackage ./find-app-xdotool { };
  # find-app-hyprland = pkgs.callPackage ./find-app-hyprland { };
  # bw-setup-secrets = pkgs.callPackage ./bw-setup-secrets { };
  ytsum = inputs.ytsum.packages."${pkgs.system}".default;
  bw-setup-secrets = inputs.bw-setup-secrets.packages."${pkgs.system}".default;
  ollama-obsidian-indexer = inputs.ollama-obsidian-indexer.packages."${pkgs.system}".default;
}
